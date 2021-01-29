#!/bin/bash

# sh_gamma.sh for batch processing, after sh_setup_gamma and editing configure table
# NOTE: This script wil set cwd as $procdir, please run it in the parent folder of table and data dir
# sh_prechecking.sh will call for sh_grep_S1_dates.sh and sh_downloading_S1_opod.sh
# last edited: 09/01/2020

version="16/01/2021"

if [ "$1" == "--help" ] || [ "$1" == "-help" ] || [ "$1" == "-h" ] || [ "$#" -lt "3"  ]; then
	cat<<END && exit 1 

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
  Batch processing script of SAR data.

  Program:		`basename $0`
  Written by:		Zelong Guo (GFZ, Potsdam)
  First version:	12/12/2020
  Last edited:		$version

  usage:		$(basename $0) <SAR_SATELLITE> <TYPE> <BEGS> <ENDS>
                
  <SAR_SATELLITE>:      (input) SAR Mission, S1, (ALOS)...
  #<TYPE>:               (input) processing type, 2p or ts
  <BEGS>:               (input)
  <ENDS>:               (input)

  data ml coreg ..................
  
    
            CURRENT DIR: $PWD

+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

END
fi


[ -e "sh_gamma.log" ] && rm sh_gamma.log
touch sh_gamma.log

#============ Inputting Parameters ==================#
# OPTIONS: data, ml, coreg, diff, stamps
SAR_SATELLITE=$1
BEGS=$2
ENDS=$3
SAR_SATELLITE=$(echo $SAR_SATELLITE | tr 'A-Z' 'a-z')
BEGS=$(echo $BEGS | tr 'A-Z' 'a-z')
ENDS=$(echo $ENDS | tr 'A-Z' 'a-z')
#====================================================#


#============================================================== Sentinel-1 =====================================================================#
if [ "$SAR_SATELLITE" == "s1" ] || [ "$SAR_SATELLITE" == "sentinel1" ] || [ "$SAR_SATELLITE" == "sentinel-1" ]; then
    export procdir opoddir datadir demdir opod_download_flag miss_type dem_download_flag dem_type max_lat min_lat max_lon min_lon disdem_flag 
    export start_date stop_date pol m1_fswa m1_lswa m1_fbur m1_lbur m2_fswa m2_lswa m2_fbur m2_lbur disslc dissel reference ran_look azi_look 
    export dem_northover dem_eastover cp_sub roff nr loff nl itab_type bperp_min bperp_max delta_T_min delta_T_max
    source sh_read_cfg_S1.sh
    sh_preprocess_S1.sh | tee sh_gamma.log
    procdir=$PWD
    opoddir=$PWD/opod
    datadir=$PWD/data
    demdir=$PWD/dem
    
    #+++++++++++++++++++++++++++++++++ read SLC ++++++++++++++++++++++++++++++
    if  [ "$BEGS" == "data" ]; then
        cp grep_dates_s1? data
       
        cd data
        sh_read_SLC_S1 $opoddir $miss_type $pol $m1_fswa $m1_lswa $m1_fbur $m1_lbur $m2_fswa $m2_lswa $m2_fbur $m2_lbur $disslc $dissel | tee -a sh_gamma.log
        cd $procdir
        if [ "$BEGS" == "$ENDS" ]; then
            echo "READ SLC is finished!\n"
            exit 0
        else
            BEGS="ml"
        fi
	fi
	
	#++++++++++++++++++++++++++++++++++++ multi looking ++++++++++++++++++++++
	if [ "$BEGS" == "ml" ]; then
        sh_multi_looking_S1 $reference $procdir $datadir $demdir $miss_type $m1_fswa $m1_lswa $m1_fbur $m1_lbur $m2_fswa $m2_lswa $m2_fbur $m2_lbur $ran_look $azi_look $dem_northover $dem_eastover | tee -a sh_gamma.log
	    if [ "$BEGS" == "$ENDS" ]; then
            echo "READ SLC is finished!\n"
            exit 0
        else
            BEGS="coreg"
		fi
	fi
	
	#+++++++++++++++++++++++++++++++++++++ coreg ++++++++++++++++++++++++++++
	if [ "$BEGS" == "coreg" ]; then
          sh_coreg_S1 $procdir $miss_type $reference $m1_fswa $m1_lswa $ran_look $azi_look | tee -a sh_gamma.log
          if [ "$BEGS" == "$ENDS" ]; then
            echo "READ SLC is finished!\n"
            exit 0
        else
            BEGS="subset"
            fi
	fi
	
	#+++++++++++++++++++++++++++++++++++++ subset ++++++++++++++++++++++++++++
	if [ "$BEGS" == "subset" ]; then
        sh_diff_S1.sh | tee -a sh_gamma.log
    fi
    
fi

[ -d "$table" ] && mv grep_dates_s1? table
[ -d "$table" ] && mv sh_gamma.log table

#unset pol fswa lswa fbur lbur

### S1_TS_proc ###
---------------------------------------------------------------------------------------------------
#### Expected Structure: ####

***$procdir*** -------------------------------------- cwd of running sh_gamma.sh  
\| \|  \| \|  
\| \| \| \|------------------------------------ ***table*** (***MANDATORY***)  
\| \| \|   
\| \| \| &emsp;	                          / *S1A_IW_SLC**  
\| \| \|--------------- data (MANDATORY) | ...  
\| \|				          \ *S1B_IW_SLC**  
\| \|  
\| \|----------------- opod (OPTIONAL: can be downloaded)  
\|------------------- dem (OPTIONAL: can be downloaded)  
  ...


If you need to concatenate the SLCs of different images:

$procdir ----------- cwd of running sh_gamma.sh
| | | |
| | | |------------- table (MANDATORY)
| | | 
| | |--------------- F477 (contains data, opod and table...) \
| | |  								---> sh_gamma s1 ts data data
| | |--------------- F478 (contains data, opod and table...) /
| | 
| |----------------- data (MANDATORY)                           ---> sh_cat_ScanSAR
|------------------- dem (OPTIONAL: can be downloaded)
  ...


These scripts are employed to process the Sentinel-1 data, for time series processing.

To process the Sentinel-1 data with GAMMA:
    1. Creating the table folder with "sh_setup_gamma" command UNDER THE PROJECT/PROCESS DIRECTORY (i.e. $procdir)
    2. Editting the configure table as you need in the table folder
    3. Back to $procdir directory, running sh_gamma.sh for batch processing, note inputing the PATHES correctly
        3.1 sh_prechecking.sh, which will call for sh_grep_S1_dates.sh and sh_downloading_S1_opod.sh
        3.2 sh_read_SLC.sh, which needs several inputing parameters that output by sh_prechecking.sh
	
NOTE: 
    $ori_SARdir (original SAR directory) and $miss_type (mission type) are two of the inputing parameters of sh_grep_S1_dates,  sh_grep_S1_dates would check the mission type (S1A and/or S1B) in original SAR ZIP directory firstly, if in original SAR directory there is/are:
        1. s1a + s1b data, mission type can be specified as s1a OR s1b (only s1b OR s1b data would be processed in follow-up processing) or both (both of s1a and s1b would be processed in ollow-up processing) in config.table;
        2. s1a data only, mission type can be specified as s1a only in config.table;
        3. s1b data only, mission type can be specified as s1b only in config.table;
        
    if mission type = BOTH, then now only support the setting: m1_fswa=m2_fswa, m1_lswa=m2_lswa (sh_coreg.sh)
	
	The date list file and kml file will be generated under table directory (for GACOS).
	
	$procdir containing subfolder opod, dem, data, multi_looking, coreg, subset and INSAR_$reference (for stamps) is recommanded.
	
    checking the table directory to find the grep_dates_s1[ab] and the log files.

If you want to make time-series analysis with StaMPS, you could use sh_gamma2stamps to prepaer the files.

	
With any problems, please contact Zelong Guo @GFZ:
Email: zelong@gfz-potsdam.de
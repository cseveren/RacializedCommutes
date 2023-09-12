/* REPLICATION MATERIALS FOR
The Problem Has Existed over Endless Years: Racialized Difference in Commuting, 1980-2019"
by devin michelle bunten, Ellen Fu, Lyndsey Rolheiser, and Christopher Severen
Journal of Urban Economics, article 103542

To replicate data construction and results, set global variables DATA and DGIT 
	in lines 23-24, then run lines 29-99 in Stata. You will also need to 
	use R to run the files listed in lines 52-54, 70-71, and 102
	
To replicate results only, set global variables DATA and DGIT 
	in lines 23-24, then run lines 65-100 in Stata. You will also need to 
	use R to run the files listed in lines 52-54, 70-71, and 102

Some analysis files and data creation take a long time to run.

Note some files are very large. We recommend at least 32GB of RAM.
*/

** SET VARIABLES BELOW **
clear
cls

global DATA "C:/Users/Chris.Severen/Dropbox/Data_Projects/RacialCommutingGap"
global DGIT "C:/GitHub/RacializedCommutes"

*******************************
*** Run below this point ***

di	"${DATA}"
di	"${DGIT}"

global SAMPLE = "black-white"  // "black-nonblack" <-> to add: additional functionality for other groups 
								//  + requires changing treatment variable
								
*** PACKAGES ***
*ssc install blindschemes, replace all
*ssc install reghdfe
set scheme plotplainblind


****************************
*** DATA CONSTRUCTION ***

** Main Census/ACS Data Flow (this takes awhile to run)
do 		"${DGIT}/code/build/0_tranmode_race_bins_6070.do" /* Constructs 1960 and 1970 mode shares by race */
do 		"${DGIT}/code/build/0_ipums_carinhh.do" /* Constructs number of cars in hh */
do		"${DGIT}/code/build/0_ipums_1980-2000_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"${DGIT}/code/build/0_ipums_2001-2019_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"${DGIT}/code/build/1_ipums_combine_clean.do" 	/* Calls ./1A_additional_var_prep.do */

** R data prep. Use R to run: (CS is not sure what these do)
* "${DGIT}/code/build/0A_employment_prep.do" 
* "${DGIT}/code/build/0A_nhgis_prep.do" 
* "${DGIT}/code/build/0A_nhgis_prep_revised.do" 

** NHGIS Data Prep
do		"${DGIT}/code/build/0B_nhgis_append.do" 	
do		"${DGIT}/code/build/0C_nhgis_housing_append.do" 	

	
****************************
*** Micro Analysis ***
	/* Note: many files call ${DGIT}/code/analysis/parse_sample.do */

!mkdir "${DGIT}/results/${SAMPLE}/tables"
!mkdir "${DGIT}/results/${SAMPLE}/plots"

* Non-Decomposition Analysis and Graphs
do		"${DGIT}/code/analysis/regs.do"  				/* Create /data/ipums_smaller.csv for R use */	
	/*Note: Also execute ../regs.R for regs too large for Stata  */
	/*Note: Also execute ../regs_lfp.R for regs too large for Stata  */
do		"${DGIT}/code/analysis/lfpr.do"  	
do		"${DGIT}/code/analysis/graphs.do"
do		"${DGIT}/code/analysis/graphs_carinhh.do" 		
do		"${DGIT}/code/analysis/income.do"
do		"${DGIT}/code/analysis/bigcity-diffs.do"
		
* Decomposition
do		"${DGIT}/code/analysis/decomposition_yearbins.do"

* City-Level Preparation
do		"${DGIT}/code/analysis/czFEs_1_make_coefficients.do" /* Calls ./czFEs_1A_regs.do */
do		"${DGIT}/code/analysis/czFEs_2_label_czs.do"
do		"${DGIT}/code/analysis/czFEs_3_add_cz_characteristics.do"
do		"${DGIT}/code/analysis/czFEs_4_add_ma_terms.do"

* City-Level Analysis
do		"${DGIT}/code/build/2_GurenIV.do" 				/* Calls ./1A_additional_var_prep.do */
				/* Must be run after czFEs_* in order to incorporate coefficients */
do		"${DGIT}/code/analysis/city-level_analysis.do" 	/* Calls ./city-level_prep.do */
do		"${DGIT}/code/analysis/city-level_graphs.do"		/* Calls ./city-level_prep.do */

* Tract-Level Analysis
do		"${DGIT}/code/analysis/tract_regs.do" 	

* Housing Price Analysis
do		"${DGIT}/code/analysis/housingprice_ptile_all.do"
do		"${DGIT}/code/analysis/housingprice_ptile_bycz.do"
do		"${DGIT}/code/analysis/housingcost_inverse.do"

* Maps (Run in R)
* "${DGIT}/code/map/make_maps.R" 


/*Reference 
  SAMPLE AND RACE/ETHNICITY VARIABLES: 
	d_white: white
	d_black: black (including two or more races) 
	d_hisp: hispanic (any number of races)
	d_aapi: asian american and pac islander (including two or more races) 
	d_amin: american indian (including two or more races) 
	samp_blw == 1: sample only if d_white==1 or d_black==1
	samp_hiw == 1: sample only if d_white==1 or d_hisp==1
	samp_aaw == 1: sample only if d_white==1 or d_aapi==1
	samp_aiw == 1: sample only if d_white==1 or d_amin==1
  For race/ethnicity vs non-race/ethnicity models, sample includes all obs
*/	
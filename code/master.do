clear
cls

di 	"current user: `c(username)'"
if "`c(username)'" == "USERNAME" {
	global DATA "DROPBOXLOCATION/RacialCommutingGap"
} 
else if "`c(username)'" == "ellenfu" {
	*global DATA "/Users/ellenfu/Dropbox (Penn)/Research/RacialCommutingGap"
	global DATA "C:/Users/ellenfu/Dropbox (Penn)/Research/RacialCommutingGap"
}
else if "`c(username)'" == "C1EXF02" {
	global DATA "C:/Dropbox/Dropbox (Penn)/Research/RacialCommutingGap"
}
else if "`c(username)'" == "RNCNS02" {
	global DATA "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap"
	global DGIT "C:/GitHub/RacializedCommutes"
} 
else if "`c(username)'" == "Chris.Severen" {
	global DATA "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap"
	global DGIT "C:/GitHub/RacializedCommutes"
} 
else if "`c(username)'" == "C1NHS01" {
	global DATA "C:/Dropbox/Dropbox (Phil Research)/RacialCommutingGap"
}
else {
	di "Who are you?"
}

di	"${DATA}"
di	"${DGIT}"

global SAMPLE = "black-white"  // "black-nonblack" <-> to add: additional functionality for other groups 
								//  + requires changing treatment variable
								
*** PACKAGES ***
*ssc install blindschemes, replace all
*ssc install reghdfe

set scheme plotplainblind



*** DATA CONSTRUCTION ***
do 		"${DGIT}/code/build/0_tranmode_race_bins_6070.do" /* Constructs 1960 and 1970 mode shares by race */
do 		"${DGIT}/code/build/0_ipums_carinhh.do" /* Constructs number of cars in hh */
do		"${DGIT}/code/build/0_ipums_1980-2000_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"${DGIT}/code/build/0_ipums_2001-2019_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"${DGIT}/code/build/1_ipums_combine_clean.do" 	/* Calls ./1A_additional_var_prep.do */

	/* incorporate 0B and 0C to workflow -- and the R scripts */ 

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
	*TO BE DELETED /*Note: Also execute .../decomps.R for decomps too large for Stata */
	*TO BE DELETED MAYBE /*Note: Also execute .../decomps_respowtran.R for alternative decomp */
do		"${DGIT}/code/analysis/decomposition_yearbins.do"
*do		"${DGIT}/code/analysis/decomps_powrespuma.do" and _puma

* City-Level Preparation
do		"${DGIT}/code/analysis/czFEs_1_make_coefficients.do" /* Calls ./czFEs_1A_regs.do */
do		"${DGIT}/code/analysis/czFEs_2_label_czs.do"
do		"${DGIT}/code/analysis/czFEs_3_add_cz_characteristics.do"

* City-Level Analysis
do		"${DGIT}/code/build/2_GurenIV.do" 				/* Calls ./1A_additional_var_prep.do */
				/* Must be run after czFEs_* in order to incorporate coefficients */
do		"${DGIT}/code/analysis/city-level_analysis.do" 	/* Calls ./city-level_prep.do */
do		"${DGIT}/code/analysis/city-level_graphs.do"		/* Calls ./city-level_prep.do */

* Tract-Level Analysis
do		"${DGIT}/code/analysis/tract_regs.do" 	




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
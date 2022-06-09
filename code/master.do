clear
cls

di 	"current user: `c(username)'"
if "`c(username)'" == "USERNAME" {
	global ROOT "DROPBOXLOCATION\RacialCommutingGap"
} 
else if "`c(username)'" == "USERNAME" {
	global ROOT "DROPBOXLOCATION\RacialCommutingGap"
} 
else if "`c(username)'" == "ellenfu" {
	*global ROOT "/Users/ellenfu/Dropbox (Penn)/Research/RacialCommutingGap"
	global ROOT "C:\Users\ellenfu\Dropbox (Penn)\Research\RacialCommutingGap"
}
else if "`c(username)'" == "C1EXF02" {
	global ROOT "C:\Dropbox\Dropbox (Penn)\Research\RacialCommutingGap"
}
else if "`c(username)'" == "RNCNS02" {
	global ROOT "C:\Dropbox\Dropbox\Data_Projects\RacialCommutingGap"
} 
else if "`c(username)'" == "C1NHS01" {
	global ROOT "C:\Dropbox\Dropbox (Phil Research)\RacialCommutingGap"
}
else {
	di "Who are you?"
}

di	"$ROOT"

global SAMPLE = "black-white"  // "black-nonblack" <-> to add: additional functionality for other groups 
								//  + requires changing treatment variable
								
*** PACKAGES ***
set scheme plotplainblind
*ssc install blindschemes, replace all


*** DATA CONSTRUCTION ***
do		"$ROOT/empirics/code/build/0_ipums_1980-2000_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"$ROOT/empirics/code/build/0_ipums_2001-2019_prep.do"	/* Calls ./0A_czone_mergers.do */
do		"$ROOT/empirics/code/build/1_ipums_combine_clean.do" 	/* Calls ./1A_additional_var_prep.do */

do 		"$ROOT/empirics/code/build/0_tranmode_race_bins_6070.do" /* Constructs 1960 and 1970 mode shares by race */

*** Micro Analaysis ***
/* Note: many files call $ROOT/empirics/code/analysis/parse_sample.do */

!mkdir "$ROOT/empirics/results/${SAMPLE}/tables"
!mkdir "$ROOT/empirics/results/${SAMPLE}/plots"

do		"$ROOT/empirics/code/analysis/regs.do"  				/* Create /empirics/data/ipums_smaller.csv for R use */	
/*Note: Also execute ../regs.R for regs too large for Stata  */
do		"$ROOT/empirics/code/analysis/graphs.do" 			
do		"$ROOT/empirics/code/analysis/income.do"
****do		"$ROOT/empirics/code/analysis/decomposition.do" Only for trials,
/*Note: Also execute .../decomps.R for decomps too large for Stata */
/*Note: Also execute .../decomps_respowtran.R for alternative decomp */
do		"$ROOT/empirics/code/analysis/decomposition_yearbins.do"
do		"$ROOT/empirics/code/analysis/decomps_powrespuma.do"

do		"$ROOT/empirics/code/analysis/czFEs_1_make_coefficients.do" /* Calls ./czFEs_1A_regs.do */
do		"$ROOT/empirics/code/analysis/czFEs_2_label_czs.do"
do		"$ROOT/empirics/code/analysis/czFEs_3_add_cz_characteristics.do"

do		"$ROOT/empirics/code/build/2_GurenIV.do" 				/* Calls ./1A_additional_var_prep.do */
				/* Must be run after czFEs_* in order to incorporate coefficients */
do		"$ROOT/empirics/code/analysis/city-level_analysis.do" 	/* Calls ./city-level_prep.do */
do		"$ROOT/empirics/code/analysis/city-level_graphs.do"		/* Calls ./city-level_prep.do */

do		"$ROOT/empirics/code/analysis/tract_regs.do" 	




do		"$ROOT/empirics/code/analysis/sample_cut_mode.do"		// UPDATE TO REPRESENT NEW TRANBIN NUMBERS
do		"$ROOT/empirics/code/analysis/sample_cut_southern.do"	// UPDATE TO REPRESENT NEW TRANBIN NUMBERS

*** City Characteristics Analysis *** UPDATE THIS
do		"$ROOT/empirics/code/analysis/regs.do" 				// Double Check REPRESENTs NEW TRANBIN NUMBERS




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
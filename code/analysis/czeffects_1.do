/* NEW SAMPLE AND RACE/ETHNICITY VARIABLES: 
	d_white: white
	d_black: black (including two or more races) 
	d_hisp: hispanic (any number of races)
	d_aapi: asian american and pac islander (including two or more races) 
	d_amin: american indian (including two or more races) 
	samp_blw == 1: sample only if d_white==1 or d_black==1
	samp_hiw == 1: sample only if d_white==1 or d_hisp==1
	samp_aiw == 1: sample only if d_white==1 or d_aapi==1
	samp_aiw == 1: sample only if d_white==1 or d_amin==1
  For race/ethnicity vs non-race/ethnicity models, sample includes all obs
*/	

*********************************************
** Estimate FEs by CZ-yearbin bins **

*est clear
*do "${DGIT}/code/analysis/czFEs_1A_regs.do" d_black all blacknonblack

est clear
use "${DATA}/empirics/data/ipums_vars_standardized.dta", clear
do "${DGIT}/code/analysis/czeffects_1regs.do" d_black samp_blw blackwhite_all

est clear
foreach n in 10 30 36 37 50 60 70 {
	use "${DATA}/empirics/data/ipums_vars_standardized.dta", clear

	keep if tranwork_bin == `n'

	if `n' == 10 {
		local mode = "car"
	}
	if `n' == 30 {
		local mode = "bus"
	}
	if `n' == 36 {
		local mode = "subway"
	}
	if `n' == 37 {
		local mode = "railroad"
	}
	if `n' == 50 {
		local mode = "bike"
	}
	if `n' == 60 {
		local mode = "walk"
	}
	if `n' == 70 {
		local mode = "other"
	}

	do "${DGIT}/code/analysis/czeffects_1regs.do" d_black samp_blw blackwhite_`mode'
	est clear
}


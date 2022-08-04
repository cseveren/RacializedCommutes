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
do "${DGIT}/code/analysis/czFEs_1A_regs.do" d_black samp_blw blackwhite



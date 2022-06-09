// Manually merging CZs 
/*	"New York and Newark"
	"Dallas and Fort Worth-Arlington"
	"Philadelphia and Wilmington"
	"Charlotte and Gastonia-Rock Hill"
	"Hickory and Morganton" */

replace czone= 19400 if czone== 19600
replace czone= 33100 if czone== 33000
replace czone= 19700 if czone== 19800
replace czone= 900 if czone== 800
replace czone= 1100 if czone== 1001
 
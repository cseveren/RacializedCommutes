*******************************************************************************/
clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify rsample
do		"${DGIT}/code/analysis/parse_sample.do"

gcollapse (mean) d_vehinhh [aw=czwt_tt], by(year d_black) 	 	
		
sort year d_black
	
// Mode Shares
twoway (line d_vehinhh year if d_black == 0, lstyle(solid) lcolor(orange))  ///
	(line d_vehinhh year if  d_black == 1, lpattern(dash) lcolor(orange)),  ///
	ytitle("Share with Car in Household") xtitle("Census Year") ylabel(0.5(0.1)1.0, grid gmax) ///
	legend(order(1 "White (18+ with Auto in HH)" 2 "Black (18+ with Auto in HH)") rows(1) pos(6)) 
		
graph export "${DGIT}/results/${SAMPLE}/plots/share_carinhh.png", replace		
			
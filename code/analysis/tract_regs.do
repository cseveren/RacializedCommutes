/*******************************************************************************
* Regressions on tract-level averages
*******************************************************************************/

* Using geonormalized tract data

clear all

use "${ROOT}/empirics/input/tract analysis/trt_data_2010geo.dta", clear
set scheme plotplainblind

foreach v of varlist college-sh_blk {
	rename `v' `v'_obs
}

merge 1:1 geoid10 year using "${ROOT}/empirics/input/tract analysis/trt_data_2010geo_est.dta", keepusing(college-sh_blk)
drop if _merge==2 // Mainly tracts without a commuting time or other important vars
drop _merge

foreach v of varlist college-sh_blk {
	rename `v' `v'_est
}


** Standardize Tract Names (format is SSCCCTTTTTT in 1990 and later, GSS0CCC0TTTTTT)

destring geoid10, replace
format geoid10 %12.0f
rename geoid10 tract10

order tract10 year czone, first

** Other Useful Variables
gen ltt_obs = ln(mean_comm_obs)
gen ltt_est = ln(mean_comm_est)

rename transit_obs sh_transit_obs
rename transit_est sh_transit_est


**
est clear

eststo: reghdfe ltt_obs c.sh_blk_obs#i.year, a(year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk_obs#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk_obs#i.year c.sh_transit_obs#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk_obs#i.year c.sh_transit_obs#i.year c.cbd_dist#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk_obs#i.year c.sh_transit_obs#i.year, a(tract10 czone##year) cluster(czone)


esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/trt_analysis_obs.tex", b(3) se(3) nocon label replace bookt f
est clear

eststo: reghdfe ltt_est c.sh_blk_est#i.year, a(year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year c.cbd_dist#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year, a(tract10 czone##year) cluster(czone)


esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/trt_analysis_est.tex", b(3) se(3) nocon label replace bookt f
est clear








/*

** OLDER Code: without geonorm

clear all

use "${ROOT}/empirics/input/tract analysis/trt_data.dta", clear
set scheme plotplainblind

rename mean_comm mean_comm_obs
merge 1:1 gisjoin year using "${ROOT}/empirics/input/tract analysis/trt_data_est.dta", keepusing(med_hval-share_1018)
drop if _merge==2 // Mainly tracts without a commuting time or other important vars
drop _merge
rename mean_comm mean_comm_est

** Standardize Tract Names (format is SSCCCTTTTTT in 1990 and later, GSS0CCC0TTTTTT)
gen 	tract = gisjoin
replace tract = substr(gisjoin,2,2)+substr(gisjoin,5,3)+substr(gisjoin,9,6) if year==1980
sort tract year
compress 
destring tract, replace
format tract %12.0f

order tract gisjoin year czone, first

** Other Useful Variables
gen ltt_obs = ln(mean_comm_obs)
gen ltt_est = ln(mean_comm_est)

rename transit sh_transit

egen exact_tract = group(tract cbd_dist)

**
est clear

eststo: reghdfe ltt_obs c.sh_blk#i.year, a(year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year c.sh_transit#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year c.sh_transit#i.year c.cbd_dist#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year c.sh_transit#i.year, a(czone##year czone#year#c.cbd_dist) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year c.sh_transit#i.year, a(czone##year tract) cluster(czone)
eststo: reghdfe ltt_obs c.sh_blk#i.year c.sh_transit#i.year, a(czone##year exact_tract) cluster(czone)

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/trt_analysis_obs.tex", b(3) se(3) nocon label replace bookt f
est clear


eststo: reghdfe ltt_est c.sh_blk#i.year, a(year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year c.sh_transit#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year c.sh_transit#i.year c.cbd_dist#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year c.sh_transit#i.year, a(czone##year czone#year#c.cbd_dist) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year c.sh_transit#i.year, a(czone##year tract) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk#i.year c.sh_transit#i.year, a(czone##year exact_tract) cluster(czone)

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/trt_analysis_est.tex", b(3) se(3) nocon label replace bookt f
est clear
*/

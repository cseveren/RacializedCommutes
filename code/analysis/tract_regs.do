/*******************************************************************************
* Regressions on tract-level averages
*******************************************************************************/

* Using geonormalized tract data

clear all

use "${DATA}/empirics/input/tract analysis/trt_data_2010geo.dta", clear
set scheme plotplainblind

foreach v of varlist college-sh_blk {
	rename `v' `v'_obs
}

merge 1:1 geoid10 year using "${DATA}/empirics/input/tract analysis/trt_data_2010geo_est.dta", keepusing(college-sh_blk)
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


esttab using "${DGIT}/results/${SAMPLE}/tables/trt_analysis_obs.tex", b(3) se(3) nocon label replace bookt f
est clear

eststo: reghdfe ltt_est c.sh_blk_est#i.year, a(year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year c.cbd_dist#i.year, a(czone##year) cluster(czone)
eststo: reghdfe ltt_est c.sh_blk_est#i.year c.sh_transit_est#i.year, a(tract10 czone##year) cluster(czone)


esttab using "${DGIT}/results/${SAMPLE}/tables/trt_analysis_est.tex", b(3) se(3) nocon label replace bookt f
est clear




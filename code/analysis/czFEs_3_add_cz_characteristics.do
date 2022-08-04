* 2CALT

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear

** DO NOT OMIT OUT OF SAMPLE, AS THESE ARE AGGREGATE VARIABLES **

** Define Vars **
gen modeshare_car = (tranwork_bin==10)
gen modeshare_bus = (tranwork_bin==30)
gen modeshare_subway = (tranwork_bin==36)
gen modeshare_railroad = (tranwork_bin==37)
gen modeshare_bicycle = (tranwork_bin==50)
gen modeshare_walked = (tranwork_bin==60)
gen modeshare_other = (tranwork_bin==70)

gen modeshare_anytransit = max(modeshare_bus, modeshare_subway, modeshare_railroad)

gen time_car = trantime if (tranwork_bin==10)
gen time_bus = trantime if (tranwork_bin==30)
gen time_subway = trantime if (tranwork_bin==36)
gen time_railroad = trantime if (tranwork_bin==37)
gen time_bicycle = trantime if (tranwork_bin==50)
gen time_walked = trantime if (tranwork_bin==60)
gen time_other = trantime if (tranwork_bin==70)

gen time_anytransit = trantime if (tranwork_bin==30 | tranwork_bin==36 | tranwork_bin==37)

gen time_all = trantime
gen	n_obs = 1

gen ln_time_car = ln(time_car)

gen czwt_tt_black = czwt_tt*d_black

** COLLAPSE 
collapse (rawsum) czwt_tt n_obs n_black=d_black popemp_black=czwt_tt_black (mean) perc_black=d_black modeshare_* time_* ///
			(sd) sd_ltime=ln_trantime sd_time=trantime sd_ltime_auto=ln_time_car sd_time_auto=time_car ///
			(p1) p1_time=trantime (p5) p5_time=trantime (p10) p10_time=trantime (p20) p20_time=trantime ///
			(p80) p80_time=trantime (p90) p90_time=trantime (p95) p95_time=trantime (p99) p99_time=trantime ///
			(mean) valueh housingcost (median) valueh_p50=valueh housingcost_p50=housingcost ///
			[aw=czwt_tt], by(czone_year_bin)

rename czwt_tt popemp

save "${DATA}/empirics/output/czyr_averages.dta", replace

clear

***********************

use "${DATA}/empirics/input/urban_form/CentralityOG.dta", clear
replace year=2019 if year==2018
tempfile centrality
save "`centrality'", replace

use "${DATA}/empirics/input/urban_form/Centrality2.dta", clear
replace year=2019 if year==2018
tempfile centrality2
save "`centrality2'", replace

use "${DATA}/empirics/input/urban_form/Segregation.dta", clear
replace year=2019 if year==2018
tempfile segregation
save "`segregation'", replace

use "${DATA}/empirics/input/urban_form/comm_hval_all.dta", clear
drop if year==2018
rename corr comm_hval_corr_obs
tempfile corrs1
save "`corrs1'", replace

use "${DATA}/empirics/input/urban_form/comm_hval_all_est.dta", clear
drop if year==2018
rename corr comm_hval_corr_est
tempfile corrs2
save "`corrs2'", replace

use "${DATA}/empirics/input/urban_form/GiniEmp1990.dta", clear
append using "${DATA}/empirics/input/urban_form/GiniEmp2000.dta"
append using "${DATA}/empirics/input/urban_form/GiniEmp2010.dta"
append using "${DATA}/empirics/input/urban_form/GiniEmp2018.dta"
replace year=2019 if year==2018
tempfile ginis
save "`ginis'", replace


foreach ff in blacknonblack blackwhite {
	
	use "${DATA}/empirics/output/czyrcoeffs_`ff'_all.dta"
	*use "$ROOT/empirics/output/czyrcoeffs_blackwhite_all.dta"
	
	merge 1:1 czone_year_bin using  "${DATA}/empirics/output/czyr_averages.dta"
	drop _merge
		/* NOTE: Cities that are in using only have no Black residents, or Black is collinear with another base variables */
	replace czone = floor(czone_year_bin/10000) if mi(czone)
	replace year = czone_year_bin - czone*10000 if mi(year)
		
	order 	czone year LargestCity RuralurbanContinuumCode1993 Population1990 popemp n_obs perc_black n_black modeshare_* time_* r?_*, first
	sort czone year

	rename Population1990 pop1990

	foreach v of varlist popemp n_obs perc_black n_black {
		bys czone: egen min_`v' = min(`v')
	}

	rename LargestCity largestcity
	rename RuralurbanContinuumCode1993 ruralurbancont1993
	
	merge 1:1 czone year using "`centrality'" //"$ROOT/empirics/input/urban_form/CentralityOG.dta"
	foreach v of varlist tot_centrality wht_centrality blk_centrality {
		rename `v' `v'_OG
	} 
	drop if _merge==2
	drop _merge
	merge 1:1 czone year using "`centrality2'" //$ROOT/empirics/input/urban_form/Centrality2.dta"
	foreach v of varlist tot_centrality wht_centrality blk_centrality {
		rename `v' `v'_Alt2
	} 
	drop if _merge==2
	drop _merge

	merge 1:1 czone year using "`segregation'" //"$ROOT/empirics/input/urban_form/Segregation.dta"
	drop if _merge==2
	drop _merge
	
	merge 1:1 czone year using "`corrs1'" 
	drop if _merge==2
	drop _merge
	
	merge 1:1 czone year using "`corrs2'" 
	drop if _merge==2
	drop _merge
	
	merge 1:1 czone year using "`ginis'" 
	drop if _merge==2
	drop _merge
	
	merge 1:1 czone year using "${DATA}/empirics/output/gurenIV.dta"
	drop _merge
	
	merge 1:1 czone year using "${DATA}/empirics/input/highways/highways.dta"
// 	foreach v of varlist fira firb lena lenb lenc lenp {
// 		replace `v' = 0 if _merge==1 & year==1980 
// 		replace `v' = 0 if _merge==1 & year==1990 
// 		replace `v' = 0 if _merge==1 & year==2000 
// 	}
	drop _merge
	
	order 	czone year largestcity ruralurbancont1993 pop1990 popemp min_popemp n_obs min_n_obs perc_black min_perc_black n_black min_n_black popemp_black
	sort czone year

	save "${DATA}/empirics/output/czyrall_`ff'.dta", replace
	export delim using "${DATA}/empirics/output/czyrall_`ff'.csv", replace
}

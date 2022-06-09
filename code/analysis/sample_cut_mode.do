/*******************************************************************************
Sample cuts by transit mode

*******************************************************************************/

clear all

ssc install blindschemes, replace all
set scheme plotplainblind

global allwhite "plotregion(fcolor(white)) graphregion(color(white))"

*use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear
use "${ROOT}\empirics\data\ipums_vars_standardized.dta", clear

drop hhwt hhtype statefip puma gq farm ownershpd mortgage rentgrs hhincome valueh ncouples multgen multgend perwt famsize nchlt5 relate related marst birthyr race hispan bpl citizen yrimmig speakeng racesing racesingd empstat empstatd labforce wkswork2 inctot uhrswork movedin puma2010 puma2000 housingcost sample cluster strata ownershp workedyr czwt migsamp d_hisp ftotinc
 
*do 	"$ROOT/empirics/code/analysis/0A_additional_var_prep.do"
do 	"$ROOT\empirics\code\analysis\0A_additional_var_prep.do"

drop d_completed_college d_completed_high_school d_hs d_col educ educd tranwork /*trantime*/ incwage yrcz nchild
drop if czwt_tt==0

foreach var in trantime ln_trantime {
	gen se_`var' = `var'
}


// Specify race sample
global sample = "black-white"  // "black-non-black"

if "${sample}" == "black-white" {
	gen keep = 1 if d_black == 1
	replace keep = 1 if d_white == 1
	keep if keep == 1
	drop keep
}


/*------------------------------------------------------------------------------
	Unconditional plots of raw data
------------------------------------------------------------------------------*/
************************************
*--Plots of raw data
!mkdir "${ROOT}/empirics/results/Plots/Unconditional/${sample}"

foreach n in 1 30 33 34 40 50 60 {
	preserve

	keep if tranwork_bin == `n'

	if `n' == 1 {
		local mode = "car"
	}
	if `n' == 30 {
		local mode = "bus"
	}
	if `n' == 33 {
		local mode = "subway"
	}
	if `n' == 34 {
		local mode = "railroad"
	}
	if `n' == 40 {
		local mode = "bike"
	}
	if `n' == 50 {
		local mode = "walk"
	}
	if `n' == 60 {
		local mode = "other"
	}
		
	collapse (mean) trantime (semean) se_trantime [aw=czwt_tt], by(year d_black) 
	foreach var in trantime {

		gen upper_`var' = `var' + 2*se_`var'
		gen lower_`var' = `var' - 2*se_`var'

		twoway rcap upper_`var' lower_`var' year if d_black  == 0, lstyle(ci) lcolor(blue) || ///
			line `var' year if d_black == 0, lstyle(solid) lcolor(blue) || ///
			rcap upper_`var' lower_`var' year if d_black == 1, lstyle(ci) lcolor(red) || ///
			line `var' year if d_black == 1, lpattern(dash) lcolor(red) ///
			legend(order(2 "White" 4 "Black")) note("unconditional `var' over time, by `mode'") ///
			xtitle("Census Year") ytitle("Commute Time") name(rcap, replace)
			
		graph export "${ROOT}/empirics/results/Plots/Unconditional/${sample}/`var'_`mode'.png", replace	
	}
	
	restore
}
		 

************************************
*--By gender
foreach n in 1 30 33 34 40 50 60 {
	preserve

	keep if tranwork_bin == `n'

	if `n' == 1 {
		local mode = "car"
	}
	if `n' == 30 {
		local mode = "bus"
	}
	if `n' == 33 {
		local mode = "subway"
	}
	if `n' == 34 {
		local mode = "railroad"
	}
	if `n' == 40 {
		local mode = "bike"
	}
	if `n' == 50 {
		local mode = "walk"
	}
	if `n' == 60 {
		local mode = "other"
	}

	collapse (mean) trantime (semean) se_trantime [aw=czwt_tt], by(year d_black sex) 
	twoway (line trantime year if sex == 0 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if sex == 0 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if sex == 1 & d_black == 0, lstyle(solid) lcolor(red))  ///
		(line trantime year if sex == 1 & d_black == 1, lpattern(dash) lcolor(red)),  ///
		ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "Male" 	///
					 3 "Female") rows(1) pos(6))
		graph export "${ROOT}/empirics/results/Plots/Unconditional/${sample}/trantime_bygender_`mode'.png", replace	
		
	restore
}


/*------------------------------------------------------------------------------
	Conditional plots
1) year
2) year + cz
3) year + cz + demo
4) year + cz + mode
5) year + cz + demo + mode
6) year + cz + demo + mode + work
------------------------------------------------------------------------------*/
*set seed 9483
*sample 10

forvalues n = 1/6 {
	gen beta_race_`n' = .
	gen se_race_`n' = .
}

foreach n in /*1*/ 30 33 34 40 50 60 {
	preserve

	keep if tranwork_bin == `n'

	if `n' == 1 {
		local mode = "car"
	}
	if `n' == 30 {
		local mode = "bus"
	}
	if `n' == 33 {
		local mode = "subway"
	}
	if `n' == 34 {
		local mode = "railroad"
	}
	if `n' == 40 {
		local mode = "bike"
	}
	if `n' == 50 {
		local mode = "walk"
	}
	if `n' == 60 {
		local mode = "other"
	}
	
	local years_list 1980 1990 2000 2005 ///
					 2006 2007 2008 2009 ///
					 2010 2011 2012 2013 ///
					 2014 2015 2016 2017 ///
					 2018

	local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
	local work		linc i.inczero occ1990 ind1990 

	set matsize 11000
	foreach y of local years_list {
	
		// (1) year FEs
		qui reg ln_trantime i.d_black if year == `y' [aw=czwt_tt], vce(cluster czone)
		replace beta_race_1 = _b[1.d_black] if year == `y'
		replace se_race_1 = _se[1.d_black] if year == `y'
		
		// (2) year + cz
		qui reg ln_trantime i.d_black i.czone if year == `y' [aw=czwt_tt], vce(cluster czone)
		replace beta_race_2 = _b[1.d_black] if year == `y'		
		replace se_race_2 = _se[1.d_black] if year == `y'
		
		// (3) year + CZ + demo
		qui reg ln_trantime i.d_black i.czone `demog' if year == `y' [aw=czwt_tt], vce(cluster czone)
		replace beta_race_3 = _b[1.d_black] if year == `y'		
		replace se_race_3 = _se[1.d_black] if year == `y'

		// (6) year + CZ + demo + mode + work
		qui reg ln_trantime i.d_black i.czone `demog' `work' if year == `y' [aw=czwt_tt], vce(cluster czone)
		replace beta_race_6 = _b[1.d_black] if year == `y'		
		replace se_race_6 = _se[1.d_black] if year == `y'	
		
	}

	****
	compress
	save "${ROOT}/empirics/data/temp_dta/${sample}/conditional_data_`mode'.dta", replace
	****

	collapse (mean) beta_race* se_race*, by(year)
	drop if mi(beta_race_1)

	forvalues n = 1/6 {
		gen upper_race_`n' = beta_race_`n' + se_race_`n'
		gen lower_race_`n' = beta_race_`n' - se_race_`n'
	}

	twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black)) ///
		(line beta_race_1 year, lstyle(solid) lcolor(black))  ///
		(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red)) ///
		(line beta_race_2 year, lpattern(solid) lcolor(red))  ///
		(rcap upper_race_3 lower_race_3 year , lstyle(ci) lcolor(orange)) ///
		(line beta_race_3 year, lstyle(solid) lcolor(orange))  ///
		(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
		(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
		ytitle("Commute Time") xtitle("Census Year") /*ylabel(0[0.05]0.3)*/ ///
		legend(order(2 "year" 	///
					 4 "year + CZ"	/// 
					 6 "year + CZ + demo"  ///
					 8 "year + CZ + demo + work") rows(2) pos(6))	 
	graph export "${ROOT}/empirics/results/Plots/${sample}/Conditional_oncontrols_`mode'.png", replace

	restore
}


*--Car Only
preserve
set seed 9483
sample 10

keep if tranwork_bin == 1

local years_list 1980 1990 2000 2005 ///
				 2006 2007 2008 2009 ///
				 2010 2011 2012 2013 ///
				 2014 2015 2016 2017 ///
				 2018

local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local work		linc i.inczero occ1990 ind1990 

set matsize 11000
foreach y of local years_list {
	
	// (1) year FEs
	qui reg ln_trantime i.d_black if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_1 = _b[1.d_black] if year == `y'
	replace se_race_1 = _se[1.d_black] if year == `y'
		
	// (2) year + cz
	qui reg ln_trantime i.d_black i.czone if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_2 = _b[1.d_black] if year == `y'		
	replace se_race_2 = _se[1.d_black] if year == `y'
		
	// (3) year + CZ + demo
	qui reg ln_trantime i.d_black i.czone `demog' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_3 = _b[1.d_black] if year == `y'		
	replace se_race_3 = _se[1.d_black] if year == `y'

	// (6) year + CZ + demo + mode + work
	qui reg ln_trantime i.d_black i.czone `demog' `work' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_6 = _b[1.d_black] if year == `y'		
	replace se_race_6 = _se[1.d_black] if year == `y'	
	
}

****
compress
save "${ROOT}/empirics/data/temp_dta/conditional_data_car.dta", replace
****

collapse (mean) beta_race* se_race*, by(year)
drop if mi(beta_race_1)

forvalues n = 1/6 {
	gen upper_race_`n' = beta_race_`n' + se_race_`n'
	gen lower_race_`n' = beta_race_`n' - se_race_`n'
}

twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black)) ///
	(line beta_race_1 year, lstyle(solid) lcolor(black))  ///
	(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red)) ///
	(line beta_race_2 year, lpattern(solid) lcolor(red))  ///
	(rcap upper_race_3 lower_race_3 year , lstyle(ci) lcolor(orange)) ///
	(line beta_race_3 year, lstyle(solid) lcolor(orange))  ///
	(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
	(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
	ytitle("Commute Time") xtitle("Census Year") /*ylabel(0[0.05]0.3)*/ ///
	legend(order(2 "year" 	///
				 4 "year + CZ"	/// 
				 6 "year + CZ + demo"  ///
				 8 "year + CZ + demo + work") rows(2) pos(6))	 
graph export "${ROOT}/empirics/results/Plots/Conditional_oncontrols_car.png", replace

restore








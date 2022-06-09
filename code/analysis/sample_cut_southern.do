/*******************************************************************************
Sample cuts by southern vs non-southern

*******************************************************************************/

clear all

ssc install blindschemes, replace all
set scheme plotplainblind

global allwhite "plotregion(fcolor(white)) graphregion(color(white))"

use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear

drop hhwt hhtype statefip puma gq farm ownershpd mortgage rentgrs hhincome valueh ncouples multgen multgend perwt famsize nchlt5 relate related marst birthyr race hispan bpl citizen yrimmig speakeng racesing racesingd empstat empstatd labforce wkswork2 inctot uhrswork movedin puma2010 puma2000 housingcost sample cluster strata ownershp workedyr czwt migsamp d_hisp ftotinc
 
do 	"$ROOT/empirics/code/analysis/0A_additional_var_prep.do"

drop d_completed_college d_completed_high_school d_hs d_col educ educd tranwork /*trantime*/ incwage yrcz nchild
drop if czwt_tt==0

foreach var in trantime ln_trantime {
	gen se_`var' = `var'
}


/*------------------------------------------------------------------------------
	Unconditional plots of raw data
------------------------------------------------------------------------------*/
************************************
*--Plots of raw data
!mkdir "${ROOT}/empirics/results/Plots/Unconditional"

forvalues n = 0/1 {
	preserve

	keep if d_southern_state == 1
	
	if `n' == 1 {
		local group = "southern"
	}
	if `n' == 0 {
		local group = "nonsouthern"
	}	
		
	collapse (mean) trantime (semean) se_trantime [aw=czwt_tt], by(year d_black) 
	foreach var in trantime {

		gen upper_`var' = `var' + 2*se_`var'
		gen lower_`var' = `var' - 2*se_`var'

		twoway rcap upper_`var' lower_`var' year if d_black  == 0, lstyle(ci) lcolor(blue) || ///
			line `var' year if d_black == 0, lstyle(solid) lcolor(blue) || ///
			rcap upper_`var' lower_`var' year if d_black == 1, lstyle(ci) lcolor(red) || ///
			line `var' year if d_black == 1, lpattern(dash) lcolor(red) ///
			legend(order(2 "White" 4 "Black")) note("unconditional `var' over time") ///
			xtitle("Census Year") ytitle("Commute Time") name(rcap, replace)
			
		graph export "${ROOT}/empirics/results/Plots/Unconditional/`var'_`group'.png", replace	
	}
	
	restore
}
		 

************************************
*--By travel mode
forvalues n = 0/1 {
	preserve

	keep if d_southern_state == 1
	
	if `n' == 1 {
		local group = "southern"
	}
	if `n' == 0 {
		local group = "nonsouthern"
	}

	collapse (mean) trantime ln_trantime (semean) se_trantime se_ln_trantime [aw=czwt_tt], by(year d_black tranwork) 
	twoway (line trantime year if tranwork == 1 & d_black == 0, lstyle(solid) lcolor(orange))  ///
		(line trantime year if tranwork == 1 & d_black == 1, lpattern(dash) lcolor(orange))  ///
		(line trantime year if tranwork == 30 & d_black == 0, lstyle(solid) lcolor(cyan))  ///
		(line trantime year if tranwork == 30 & d_black == 1, lpattern(dash) lcolor(cyan))  ///
		(line trantime year if tranwork == 33 & d_black == 0, lstyle(solid) lcolor(purple))  ///
		(line trantime year if tranwork == 33 & d_black == 1, lpattern(dash) lcolor(purple))  ///
		(line trantime year if tranwork == 34 & d_black == 0, lstyle(solid) lcolor(yellow))  ///
		(line trantime year if tranwork == 34 & d_black == 1, lpattern(dash) lcolor(yellow))  ///
		(line trantime year if tranwork == 40 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if tranwork == 40 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if tranwork == 50 & d_black == 0, lstyle(solid) lcolor(pink))  ///
		(line trantime year if tranwork == 50 & d_black == 1, lpattern(dash) lcolor(pink))  ///
		(line trantime year if tranwork == 60 & d_black == 0, lstyle(solid) lcolor(green))  ///
		(line trantime year if tranwork == 60 & d_black == 1, lpattern(dash) lcolor(green)),  ///
		ylabel(0[20]80) ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "Private Motor Vehicle" 3 "Bus or Streetcar" 	///
					 5 "Subway or Elevated" 7 "Railroad" 9 "Bicycle"    ///
					 11 "Walked Only" 13 "Other") rows(2) pos(6))
		graph export "${ROOT}/empirics/results/Plots/Unconditional/trantime_bymodes_`group'.png", replace	
		
	restore
}


************************************
*--By gender
forvalues n = 0/1 {
	preserve

	keep if d_southern_state == 1
	
	if `n' == 1 {
		local group = "southern"
	}
	if `n' == 0 {
		local group = "nonsouthern"
	}

	collapse (mean) trantime (semean) se_trantime [aw=czwt_tt], by(year d_black sex) 
	twoway (line trantime year if sex == 0 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if sex == 0 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if sex == 1 & d_black == 0, lstyle(solid) lcolor(red))  ///
		(line trantime year if sex == 1 & d_black == 1, lpattern(dash) lcolor(red)),  ///
		ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "Male" 	///
					 3 "Female") rows(1) pos(6))
		graph export "${ROOT}/empirics/results/Plots/Unconditional/trantime_bygender_`group'.png", replace	
		
	restore
}


/*------------------------------------------------------------------------------
	Distributions / histograms, using binwidth 5
------------------------------------------------------------------------------*/
************************************
*--Histograms
gen bin_5 = 1 if trantime < 5
forvalues upper = 10(5)100 {

local i = `upper'/5
disp `i'
local lower = `upper' - 5

replace bin_5 = `i' if trantime >= `lower' & trantime < `upper'

}

forvalues n = 0/1 {
	preserve

	keep if d_southern_state == 1
	
	if `n' == 1 {
		local group = "southern"
	}
	if `n' == 0 {
		local group = "nonsouthern"
	}

	gen freq = 1
	collapse (sum) freq [aw=czwt_tt], by(year d_black bin_5) 
	replace freq = round(freq)  // round to nearest integer
	replace bin_5 = bin_5 * 5
	twoway (hist bin_5 [fw = freq] if d_black == 0, width(5) color(blue)) ///
			(hist bin_5 [fw = freq] if d_black == 1, width(5) fcolor(none) lcolor(red)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) xtitle("Commute Time") ytitle("Density")
	graph export "${ROOT}/empirics/results/Plots/Distributions/histogram_byrace_`group'.png", replace

	local years_list 1980 1990 2000 2005 ///
					 2006 2007 2008 2009 ///
					 2010 2011 2012 2013 ///
					 2014 2015 2016 2017 ///
					 2018
	foreach y of local years_list {

		twoway (hist bin_5 [fw = freq] if year == `y' & d_black == 0, width(5) color(blue)) ///
			(hist bin_5 [fw = freq] if year == `y' & d_black == 1, width(5) fcolor(none) lcolor(red)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) note("Distribution in `y'") ///
			xtitle("Commute Time") ytitle("Density") ylabel(0[0.01]0.04)
			
		graph export "${ROOT}/empirics/results/Plots/Distributions/histogram_byrace_`y'_`group'.png", replace

	}	
	
	restore
}


************************************
*--Histograms, by mode
forvalues n = 0/1 {
	preserve

	keep if d_southern_state == 1
	
	if `n' == 1 {
		local group = "southern"
	}
	if `n' == 30 {
		local group = "nonsouthern"
	}

	gen freq = 1
	collapse (sum) freq [aw=czwt_tt], by(year d_black tranwork bin_5) 
	replace freq = round(freq)  // round to nearest integer
	replace bin_5 = bin_5 * 5
	foreach n in 1 30 33 34 40 50 60 {
		
		local lab = "`: label tranwork_label `n''"
		disp "`lab'"

		twoway (hist bin_5 [fw = freq] if tranwork == `n' & d_black == 0, width(5) color(blue)) ///
				(hist bin_5 [fw = freq] if tranwork == `n' & d_black == 1, width(5) fcolor(none) lcolor(red)), ///
				legend(order(1 "White" 2 "Black") row(1) pos(6)) xtitle("Commute Time") ytitle("Density") ///
				note("`: label tranwork_1b `n''", size(small)) ylabel(0[0.02]0.06)
		graph export "${ROOT}/empirics/results/Plots/Distributions/hist_byrace_`lab'_`group'.png", replace

	}

	local years_list 1980 1990 2000 2005 ///
					 2006 2007 2008 2009 ///
					 2010 2011 2012 2013 ///
					 2014 2015 2016 2017 ///
					 2018
	foreach y of local years_list {

		foreach n in 1 30 33 34 40 50 60 {
		
		local lab = "`: label tranwork_label `n''"
		disp "`lab'"

		twoway (hist bin_5 [fw = freq] if tranwork == `n' & year == `y' & d_black == 0, width(5) color(blue)) ///
			(hist bin_5 [fw = freq] if tranwork == `n' & year == `y' & d_black == 1, width(5) fcolor(none) lcolor(red)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) ///
			xtitle("Commute Time") ytitle("Density") ylabel(0[0.02]0.06) ///
			note("`: label tranwork_1b `n'' in `y'", size(small))
			
		graph export "${ROOT}/empirics/results/Plots/Distributions/hist_byrace_`y'_`lab'_`group'.png", replace

		}
	}	
	
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
************************************
*--Southern
preserve
keep if d_southern_state == 1
*set seed 9483
*sample 10

forvalues n = 4/6 {
	gen beta_race_`n' = .
	gen se_race_`n' = .
}

local years_list 1980 1990 2000 2005 ///
				 2006 2007 2008 2009 ///
				 2010 2011 2012 2013 ///
				 2014 2015 2016 2017 ///
				 2018

local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero occ1990 ind1990 

set matsize 11000
foreach y of local years_list {
/*	
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
*/
	// (4) year + CZ + mode
	qui reg ln_trantime i.d_black i.czone `transpo' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_4 = _b[1.d_black] if year == `y'		
	replace se_race_4 = _se[1.d_black] if year == `y'
	
	// (5) year + CZ + demo + mode
	qui reg ln_trantime i.d_black i.czone `demog' `transpo' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_5 = _b[1.d_black] if year == `y'		
	replace se_race_5 = _se[1.d_black] if year == `y'	

	// (6) year + CZ + demo + mode + work
	qui reg ln_trantime i.d_black i.czone `demog' `transpo' `work' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_6 = _b[1.d_black] if year == `y'		
	replace se_race_6 = _se[1.d_black] if year == `y'	
	
}

****
compress
save "${ROOT}/empirics/data/temp_dta/conditional_data_southern.dta", replace
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
	(rcap upper_race_4 lower_race_4 year , lstyle(ci) lcolor(yellow)) ///
	(line beta_race_4 year, lpattern(solid) lcolor(yellow)) ///
	(rcap upper_race_5 lower_race_5 year , lstyle(ci) lcolor(green)) ///
	(line beta_race_5 year, lpattern(solid) lcolor(green)) ///
	(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
	(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
	ytitle("Commute Time") xtitle("Census Year") ylabel(0[0.05]0.3) ///
	legend(order(2 "year" 	///
				 4 "year + CZ"	/// 
				 6 "year + CZ + demo"  ///
				 8 "year + CZ + mode"  ///
				 10 "year + CZ + demo + mode" ///
				 12 "year + CZ + demo + mode + work") rows(2) pos(6))	 
graph export "${ROOT}/empirics/results/Plots/Conditional_oncontrols_southern.png", replace

restore


************************************
*--Non southern
preserve
keep if d_southern_state == 0

set seed 9483
sample 10

forvalues n = 1/6 {
	gen beta_race_`n' = .
	gen se_race_`n' = .
}

local years_list 1980 1990 2000 2005 ///
				 2006 2007 2008 2009 ///
				 2010 2011 2012 2013 ///
				 2014 2015 2016 2017 ///
				 2018

local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero occ1990 ind1990 

set matsize 11000
foreach y of local years_list {
/*	
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

	// (4) year + CZ + mode
	qui reg ln_trantime i.d_black i.czone `transpo' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_4 = _b[1.d_black] if year == `y'		
	replace se_race_4 = _se[1.d_black] if year == `y'
*/	
	// (5) year + CZ + demo + mode
	qui reg ln_trantime i.d_black i.czone `demog' `transpo' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_5 = _b[1.d_black] if year == `y'		
	replace se_race_5 = _se[1.d_black] if year == `y'	
/*
	// (6) year + CZ + demo + mode + work
	qui reg ln_trantime i.d_black i.czone `demog' `transpo' `work' if year == `y' [aw=czwt_tt], vce(cluster czone)
	replace beta_race_6 = _b[1.d_black] if year == `y'		
	replace se_race_6 = _se[1.d_black] if year == `y'	
*/	
}

****
compress
save "${ROOT}/empirics/data/temp_dta/conditional_data_nonsouthern.dta", replace
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
	(rcap upper_race_4 lower_race_4 year , lstyle(ci) lcolor(yellow)) ///
	(line beta_race_4 year, lpattern(solid) lcolor(yellow)) ///
	(rcap upper_race_5 lower_race_5 year , lstyle(ci) lcolor(green)) ///
	(line beta_race_5 year, lpattern(solid) lcolor(green)) ///
	(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
	(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
	ytitle("Commute Time") xtitle("Census Year") ylabel(0[0.05]0.3) ///
	legend(order(2 "year" 	///
				 4 "year + CZ"	/// 
				 6 "year + CZ + demo"  ///
				 8 "year + CZ + mode"  ///
				 10 "year + CZ + demo + mode" ///
				 12 "year + CZ + demo + mode + work") rows(2) pos(6))	 
graph export "${ROOT}/empirics/results/Plots/Conditional_oncontrols_nonsouthern.png", replace

restore
















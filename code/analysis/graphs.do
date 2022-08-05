/*******************************************************************************
Create graphs:

Plots showing evolution of commuting gap over time, in the style of Currie et al 2021:
1) Unconditional
- plot of raw data
- plots by transit mode, by gender

2) Distributions / histograms
- distribution in commute times
- binwidth 2.5 and 5

3) Conditional plots
- year-czone fixed effects
- demographics
- mode

*******************************************************************************/
clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify sample
do		"${DGIT}/code/analysis/parse_sample.do"

keep if empstat==1 
keep if empstatd==10 || empstatd==14

/*------------------------------------------------------------------------------
	Unconditional plots of raw data
------------------------------------------------------------------------------*/
************************************
*--Plots of raw data
!mkdir "${DGIT}/results/${SAMPLE}/plots/unconditional"

preserve
	foreach var in trantime { //ln_trantime {
		gen se_`var' = `var'
	}
	collapse (mean) trantime ln_trantime (semean) se_trantime [aw=czwt_tt], by(year d_black) 
	foreach var in trantime { //}\ln_trantime {

		gen upper_`var' = `var' + 2*se_`var'
		gen lower_`var' = `var' - 2*se_`var'

		twoway rcap upper_`var' lower_`var' year if d_black  == 0, lstyle(ci) lcolor(blue) || ///
			line `var' year if d_black == 0, lstyle(solid) lcolor(blue) || ///
			rcap upper_`var' lower_`var' year if d_black == 1, lstyle(ci) lcolor(red) || ///
			line `var' year if d_black == 1, lpattern(dash) lcolor(red) ///
			legend(off) text(23.2 2006 "White Commuters") text(26.5 1988 "Black Commuters") ///
			xtitle("Census Year") ytitle("Commute Time (minutes)") name(rcap, replace)
			
// 		twoway rcap upper_`var' lower_`var' year if d_black  == 0, lstyle(ci) lcolor(blue) || ///
// 			line `var' year if d_black == 0, lstyle(solid) lcolor(blue) || ///
// 			rcap upper_`var' lower_`var' year if d_black == 1, lstyle(ci) lcolor(red) || ///
// 			line `var' year if d_black == 1, lpattern(dash) lcolor(red) ///
// 			legend(pos(6) row(1) order(2 "White" 4 "Black")) ///
// 			xtitle("Census Year") ytitle("Commute Time") name(rcap, replace)
			
		graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/`var'.png", replace	
	}
restore	 

************************************
*--By travel mode 
preserve

	collapse (mean) trantime [aw=czwt_tt], by(year_bin d_black tranwork) 	
	
	lab def tranwork_alt 10 "Private Autos" 30 "Bus/Streetcar" ///
					36 "Subway/El" 37 "Railroad" 			///
					50 "Bicycle" 60 "Walked Only" 70 "Other"

	lab val tranwork_bin tranwork_alt	
	
	twoway (line trantime year_bin if d_black==0, lstyle(solid) lcolor(blue)) || ///
		(line trantime year_bin if d_black==1, lpattern(dash) lcolor(red)), ///
		xlabel(1980 "1980" 2019 "2019") xtitle("") ///
		ytitle("Commute Time (minutes)") ///
		legend(pos(6) row(1) label(1 "White") label(2 "Black")) ///
		subtitle(, pos(6)) ///
		by(tranwork, row(1) noixtick noiytick note(""))
	
	graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/trantime_bymodes_spike.png", replace	
	/*
	keep if year_bin==1980 | year_bin==2019
	
	graph bar trantime, vertical over(d_black) over(year_bin) over(tranwork_bin) ///
		legend(label(1 "White commuters") label(2 "Black commuters") rows(1) pos(6))
	
	reshape wide trantime, i(d_black tranwork) j(year_bin)
	gen early = 1980
	gen late = 2019
	
	twoway (pcspike trantime1980 early trantime2019 late if d_black==0) || ///
		(pcspike trantime1980 early trantime2019 late if d_black==1), ///
		xlabel(1980 "1980" 2019 "2019") ///
		by(tranwork, row(1) noixtick legend(off) note(""))

	twoway (line trantime year if tranwork == 10 & d_black == 0, lstyle(solid) lcolor(orange))  ///
		(line trantime year if tranwork == 10 & d_black == 1, lpattern(dash) lcolor(orange))  ///
		(line trantime year if tranwork == 30 & d_black == 0, lstyle(solid) lcolor(cyan))  ///
		(line trantime year if tranwork == 30 & d_black == 1, lpattern(dash) lcolor(cyan))  ///
		(line trantime year if tranwork == 36 & d_black == 0, lstyle(solid) lcolor(purple))  ///
		(line trantime year if tranwork == 36 & d_black == 1, lpattern(dash) lcolor(purple))  ///
		(line trantime year if tranwork == 37 & d_black == 0, lstyle(solid) lcolor(yellow))  ///
		(line trantime year if tranwork == 37 & d_black == 1, lpattern(dash) lcolor(yellow))  ///
		(line trantime year if tranwork == 50 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if tranwork == 50 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if tranwork == 60 & d_black == 0, lstyle(solid) lcolor(pink))  ///
		(line trantime year if tranwork == 60 & d_black == 1, lpattern(dash) lcolor(pink))  ///
		(line trantime year if tranwork == 70 & d_black == 0, lstyle(solid) lcolor(green))  ///
		(line trantime year if tranwork == 70 & d_black == 1, lpattern(dash) lcolor(green)),  ///
		ylabel(0[20]80) ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "Private Motor Vehicle" 3 "Bus or Streetcar" 	///
					 5 "Subway or Elevated" 7 "Railroad" 9 "Bicycle"    ///
					 11 "Walked Only" 13 "Other") rows(2) pos(6))
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/unconditional/trantime_bymodes.png", replace
	
	* This way does line charts, but hard to see	
	collapse (mean) trantime [aw=czwt_tt], by(year d_black tranwork) 	 

	twoway (line trantime year if tranwork == 10 & d_black == 0, lstyle(solid) lcolor(orange))  ///
		(line trantime year if tranwork == 10 & d_black == 1, lpattern(dash) lcolor(orange))  ///
		(line trantime year if tranwork == 30 & d_black == 0, lstyle(solid) lcolor(cyan))  ///
		(line trantime year if tranwork == 30 & d_black == 1, lpattern(dash) lcolor(cyan))  ///
		(line trantime year if tranwork == 36 & d_black == 0, lstyle(solid) lcolor(purple))  ///
		(line trantime year if tranwork == 36 & d_black == 1, lpattern(dash) lcolor(purple))  ///
		(line trantime year if tranwork == 37 & d_black == 0, lstyle(solid) lcolor(yellow))  ///
		(line trantime year if tranwork == 37 & d_black == 1, lpattern(dash) lcolor(yellow))  ///
		(line trantime year if tranwork == 50 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if tranwork == 50 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if tranwork == 60 & d_black == 0, lstyle(solid) lcolor(pink))  ///
		(line trantime year if tranwork == 60 & d_black == 1, lpattern(dash) lcolor(pink))  ///
		(line trantime year if tranwork == 70 & d_black == 0, lstyle(solid) lcolor(green))  ///
		(line trantime year if tranwork == 70 & d_black == 1, lpattern(dash) lcolor(green)),  ///
		ylabel(0[20]80) ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "Private Motor Vehicle" 3 "Bus or Streetcar" 	///
					 5 "Subway or Elevated" 7 "Railroad" 9 "Bicycle"    ///
					 11 "Walked Only" 13 "Other") rows(2) pos(6))
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/unconditional/trantime_bymodes.png", replace		*/
restore

************************************
*--Mode share over time 
preserve

	** Define Mode Share Vars **
	g byte modeshare_car = (tranwork_bin==10)
	g byte modeshare_bus = (tranwork_bin==30)
	g byte modeshare_subway = (tranwork_bin==36)
	g byte modeshare_railroad = (tranwork_bin==37)
	g byte modeshare_bicycle = (tranwork_bin==50)
	g byte modeshare_walked = (tranwork_bin==60)
	g byte modeshare_other = (tranwork_bin==70)

	g byte modeshare_anytransit = max(modeshare_bus, modeshare_subway, modeshare_railroad)

	collapse (mean) modeshare_* [aw=czwt_tt], by(year d_black) 	 	
		
	append using "${DATA}/empirics/output/modeshare_1960_1970.dta"
	
	sort year d_black
	
	// Mode Shares
	twoway (line modeshare_car year if d_black == 0, lstyle(solid) lcolor(orange))  ///
		(line modeshare_car year if  d_black == 1, lpattern(dash) lcolor(orange)),  ///
		ytitle("Mode Share") xtitle("Census Year") ylabel(0.5(0.1)1.0, grid gmax) ///
		legend(order(1 "Auto - (White Commuters)" 2 "Auto - (Black Commuters)") rows(1) pos(6)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/modeshare_auto.png", replace		
			
	twoway (line modeshare_bus year if d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line modeshare_bus year if d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line modeshare_subway year if d_black == 0, lstyle(solid) lcolor(magenta))  ///
		(line modeshare_subway year if d_black == 1, lpattern(dash) lcolor(magenta))  ///
		(line modeshare_railroad year if d_black == 0, lstyle(solid) lcolor(yellow))  ///
		(line modeshare_railroad year if d_black == 1, lpattern(dash) lcolor(yellow)),  ///
		ytitle("Mode Share") xtitle("Census Year") ///
		legend(order(1 "Bus or Streetcar" 	///
					 3 "Subway or Elevated" 5 "Railroad") rows(1) pos(6))
	graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/modeshare_transits.png", replace					 

	twoway (line modeshare_bicycle year if d_black == 0, lstyle(solid) lcolor(cyan))  ///
		(line modeshare_bicycle year if d_black == 1, lpattern(dash) lcolor(cyan))  ///
		(line modeshare_walked year if d_black == 0, lstyle(solid) lcolor(pink))  ///
		(line modeshare_walked year if d_black == 1, lpattern(dash) lcolor(pink))  ///
		(line modeshare_other year if d_black == 0, lstyle(solid) lcolor(green))  ///
		(line modeshare_other year if d_black == 1, lpattern(dash) lcolor(green)),  ///
		ytitle("Mode Share") xtitle("Census Year") ///
		legend(order(1 "Bicycle"    ///
					 3 "Walked Only" 5 "Other") rows(1) pos(6))				 
	graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/modeshare_bikewalkother.png", replace				 
restore


************************************
*--By gender
preserve
	foreach var in trantime ln_trantime {
		gen se_`var' = `var'
	}
	collapse (mean) trantime ln_trantime (semean) se_trantime se_ln_trantime [aw=czwt_tt], by(year d_black sex) 

	twoway (line trantime year if sex == 0 & d_black == 0, lstyle(solid) lcolor(blue))  ///
		(line trantime year if sex == 0 & d_black == 1, lpattern(dash) lcolor(blue))  ///
		(line trantime year if sex == 1 & d_black == 0, lstyle(solid) lcolor(red))  ///
		(line trantime year if sex == 1 & d_black == 1, lpattern(dash) lcolor(red)),  ///
		ytitle("Commute Time") xtitle("Census Year") ///
		legend(order(1 "White, Male" 2 "Black, Male"	///
					 3 "White, Female" 4 "Black, Female") rows(1) pos(6))
		graph export "${DGIT}/results/${SAMPLE}/plots/unconditional/trantime_bygender.png", replace	

restore


/*------------------------------------------------------------------------------
	Distributions / histograms, using binwidth 5
------------------------------------------------------------------------------*/
************************************
*--Kdensity
sum trantime, d

!mkdir "${DGIT}/results/${SAMPLE}/plots/distributions/"

kdensity trantime [aw=czwt_tt], bwidth(5) ytitle("Density") xtitle("Commute Time")
graph export "${DGIT}/results/${SAMPLE}/plots/distributions/kdensity_all_bw5.png", replace

kdensity trantime [aw=czwt_tt], bwidth(2.5) ytitle("Density") xtitle("Commute Time")
graph export "${DGIT}/results/${SAMPLE}/plots/distributions/kdensity_all_bw25.png", replace

twoway (kdensity trantime [aw=czwt_tt] if d_black == 0, bwidth(5) lcolor(blue)) ///
		(kdensity trantime [aw=czwt_tt] if d_black == 1, bwidth(5) lcolor(red)), ///
		legend(order(1 "White" 2 "Black")) xtitle("Commute Time") ytitle("Density") note("")
graph export "${DGIT}/results/${SAMPLE}/plots/distributions/kdensity_byrace_bw5.png", replace


local years_list 1980 1990 2000 2010 2019

foreach y of local years_list {

	twoway (kdensity trantime [aw=czwt_tt] if year_bin == `y' & d_black == 0, width(5) color(blue)) ///
		(kdensity trantime [aw=czwt_tt] if year_bin == `y' & d_black == 1, width(5) fcolor(none) lcolor(red)), ///
		legend(order(1 "White" 2 "Black")) ///
		xtitle("Commute Time") ytitle("Density") ylabel(0[0.01]0.04)
		
	graph export "${DGIT}/results/${SAMPLE}/plots/distributions/kdensity_byrace_`y'_bw5.png", replace

}	


************************************
*--Histograms
gen bin_5 = 1 if trantime < 5
forvalues upper = 10(5)100 {

	local i = `upper'/5
	disp `i'
	local lower = `upper' - 5

	replace bin_5 = `i' if trantime >= `lower' & trantime < `upper'

}

preserve
	gen freq = 1
	collapse (sum) freq [aw=czwt_tt], by(year_bin d_black bin_5) 
	replace freq = round(freq)  // round to nearest integer

	replace bin_5 = (bin_5 - 1) * 5 + 2.5

	hist bin_5 [fw = freq], discrete ytitle("Density") xtitle("Commute Time (minutes)")
	graph export "${DGIT}/results/${SAMPLE}/plots/distributions/hist_all_bw5.png", replace

	twoway (hist bin_5 [fw = freq] if d_black == 0, discrete color(gray) lcolor(none)) ///
			(hist bin_5 [fw = freq] if d_black == 1, discrete fcolor(none) lcolor(black)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) xtitle("Commute Time (minutes)") ytitle("Density")
	graph export "${DGIT}/results/${SAMPLE}/plots/distributions/hist_byrace_bw5.png", replace

	local years_list 1980 1990 2000 2010 2019
	foreach y of local years_list {

		twoway (hist bin_5 [fw = freq] if year_bin == `y' & d_black == 0, discrete color(gray) lcolor(none)) ///
			(hist bin_5 [fw = freq] if year_bin == `y' & d_black == 1, discrete fcolor(none) lcolor(black)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) ///
			xtitle("Commute Time (minutes)") ytitle("Density") ylabel(0[0.01]0.04)
			
		graph export "${DGIT}/results/${SAMPLE}/plots/distributions/hist_byrace_`y'_bw5.png", replace

	}	

restore


************************************
*--Histograms, by mode
preserve

	gen freq = 1
	collapse (sum) freq [aw=czwt_tt], by(year_bin d_black tranwork bin_5) 

	replace freq = round(freq)  // round to nearest integer

	replace bin_5 = (bin_5 - 1) * 5 + 2.5

	foreach n in 10 30 36 37 50 60 70 {
		
		local lab = "`: label tranwork_label `n''"
		disp "`lab'"

		twoway (hist bin_5 [fw = freq] if tranwork_bin == `n' & d_black == 0, discrete color(gray) lcolor(none)) ///
				(hist bin_5 [fw = freq] if tranwork_bin == `n' & d_black == 1, discrete fcolor(none) lcolor(black)), ///
				legend(order(1 "White" 2 "Black") row(1) pos(6)) xtitle("Commute Time") ytitle("Density") ///
				note("`: label tranwork_1b `n''", size(small)) ylabel(0[0.02]0.06)
		graph export "${DGIT}/results/${SAMPLE}/plots/distributions/hist_byrace_`lab'_bw5.png", replace

	}

	local years_list 1980 1990 2000 2010 2019
	foreach y of local years_list {

		foreach n in 10 30 36 37 50 60 70 {
		
		local lab = "`: label tranwork_label `n''"
		disp "`lab'"

		twoway (hist bin_5 [fw = freq] if tranwork_bin == `n' & year_bin == `y' & d_black == 0, discrete color(gray) lcolor(none)) ///
			(hist bin_5 [fw = freq] if tranwork_bin == `n' & year_bin == `y' & d_black == 1, discrete fcolor(none) lcolor(black)), ///
			legend(order(1 "White" 2 "Black") row(1) pos(6)) ///
			xtitle("Commute Time") ytitle("Density") ylabel(0[0.02]0.06) ///
			note("`: label tranwork_1b `n'' in `y' Year Bin", size(small))
			
		graph export "${DGIT}/results/${SAMPLE}/plots/distributions/hist_byrace_`y'_`lab'_bw5.png", replace

		}
	}	

restore


************************************
*--Changes in travel time distribution
// preserve
//
// 	gcollapse (p10) p10_tt=trantime (p25) p25_tt=trantime (p50) p50_tt=trantime ///
// 				(p75) p75_tt=trantime (p90) p90_tt=trantime [aw=czwt_tt], by(year d_blac) 
//	
//	
// 	twoway (line p50_tt year if d_black == 0, lstyle(solid) lcolor(orange))  ///
// 		(line p50_tt year if d_black == 1, lpattern(dash) lcolor(orange)) 
//		
// 		///
// 		(line trantime year if tranwork == 30 & d_black == 0, lstyle(solid) lcolor(cyan))  ///
// 		(line trantime year if tranwork == 30 & d_black == 1, lpattern(dash) lcolor(cyan))  
//		
// restore

/*------------------------------------------------------------------------------
	Conditional plots
1) year
2) year + cz
3) year + cz + demo
4) year + cz + mode
5) year + cz + demo + mode
6) year + cz + demo + mode + work

Then each of the above, by mode
------------------------------------------------------------------------------*/
************************************
*--Year + CZ FEs

local years_list 1980 1990 2000 2005 ///
				 2006 2007 2008 2009 ///
				 2010 2011 2012 2013 ///
				 2014 2015 2016 2017 ///
				 2018 2019


frame create regvalues
frame change regvalues

	gen year = .
	local i = 1
	foreach y of local years_list {
		set obs `i'
		replace year = `y' if mi(year)
		local i = `i'+1
	}
	forvalues n = 1/6 {
		gen beta_race_`n' = .
		gen se_race_`n' = .
		gen	e_df_`n' = .
	}

frame change default

local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero 

!mkdir "${DATA}/empirics/data/temp_dta/${SAMPLE}"
set matsize 11000
foreach y of local years_list {
	
	// (1) year FEs
	qui reg ln_trantime i.d_black if year == `y' [aw=czwt_tt], vce(cluster czone)
	frame change regvalues
		replace beta_race_1 = _b[1.d_black] if year == `y'
		replace se_race_1 = _se[1.d_black] if year == `y'
		replace e_df_1 = e(df_r) if year == `y'
	frame change default
	
	// (2) year + cz
	qui reghdfe ln_trantime i.d_black if year == `y' [aw=czwt_tt], a(czone) vce(cluster czone)
	frame change regvalues
		replace beta_race_2 = _b[1.d_black] if year == `y'		
		replace se_race_2 = _se[1.d_black] if year == `y'
		replace e_df_2 = e(df_r) if year == `y'
	frame change default
	
	// (3) year + CZ + demo
	qui reghdfe ln_trantime i.d_black `demog' ///
		if year == `y' [aw=czwt_tt], a(czone) vce(cluster czone)
	frame change regvalues
		replace beta_race_3 = _b[1.d_black] if year == `y'		
		replace se_race_3 = _se[1.d_black] if year == `y'
		replace e_df_3 = e(df_r) if year == `y'
	frame change default

	// (4) year + CZ + mode
	qui reghdfe ln_trantime i.d_black `transpo' ///
		if year == `y' [aw=czwt_tt], a(czone) vce(cluster czone)
	frame change regvalues
		replace beta_race_4 = _b[1.d_black] if year == `y'		
		replace se_race_4 = _se[1.d_black] if year == `y'
		replace e_df_4 = e(df_r) if year == `y'
	frame change default
	
	// (5) year + CZ + demo + mode
	qui reghdfe ln_trantime i.d_black `demog' `transpo' ///
		if year == `y' [aw=czwt_tt], a(czone) vce(cluster czone)
	frame change regvalues
		replace beta_race_5 = _b[1.d_black] if year == `y'		
		replace se_race_5 = _se[1.d_black] if year == `y'
		replace e_df_5 = e(df_r) if year == `y'
	frame change default
	
	// (6) year + CZ + demo + mode + work
	qui reghdfe ln_trantime i.d_black `demog' `transpo' `work' ///
		if year == `y' [aw=czwt_tt], a(czone ind1990 occ1990) vce(cluster czone)
	frame change regvalues
		replace beta_race_6 = _b[1.d_black] if year == `y'		
		replace se_race_6 = _se[1.d_black] if year == `y'
		replace e_df_6 = e(df_r) if year == `y'
	frame change default
}

****
frame change regvalues
frame regvalues: save "${DATA}/empirics/data/temp_dta/${SAMPLE}/conditional_data_all.dta", replace
****
use "${DATA}/empirics/data/temp_dta/${SAMPLE}/conditional_data_all.dta", clear

drop if mi(beta_race_1)

reshape long beta_race_ se_race_ e_df_, i(year) j(spec)
forvalues n = 1/6 {
	replace year = year+(`n'-3.5)*0.1 if spec==`n'
}
reshape wide

forvalues n = 1/6 {
	gen upper_race_`n' = beta_race_`n' + invttail(e_df_`n', 0.025)*se_race_`n'
	gen lower_race_`n' = beta_race_`n' - invttail(e_df_`n', 0.025)*se_race_`n'
}

twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black)) ///
	(line beta_race_1 year, lstyle(solid) lcolor(black))  ///
	(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red)) ///
	(line beta_race_2 year, lpattern(solid) lcolor(red))  ///
	(rcap upper_race_3 lower_race_3 year , lstyle(ci) lcolor(orange)) ///
	(line beta_race_3 year, lstyle(solid) lcolor(orange))  ///
	(rcap upper_race_4 lower_race_4 year , lstyle(ci) lcolor(gold)) ///
	(line beta_race_4 year, lpattern(solid) lcolor(gold)) ///
	(rcap upper_race_5 lower_race_5 year , lstyle(ci) lcolor(green)) ///
	(line beta_race_5 year, lpattern(solid) lcolor(green)) ///
	(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
	(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
	ytitle("Racialized Difference") xtitle("Census Year") ylabel(0[0.05]0.3, nogrid) xlabel(,nogrid) yline(0, lc(gray) lp(dot)) ///
	legend(order(2 "1: year" 	///
				 4 "2: year + CZ"	/// 
				 6 "3: year + CZ + demo"  ///
				 8 "4: year + CZ + mode"  ///
				 10 "5: year + CZ + demo + mode" ///
				 12 "6: year + CZ + demo + mode + work") rows(2) pos(6))	 
graph export "${DGIT}/results/${SAMPLE}/plots/conditional_oncontrols.png", replace

twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black%30)) ///
	(scatter beta_race_1 year, connect(l) m(i) lstyle(solid) lcolor(black))  ///
	(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red%30)) ///
	(scatter beta_race_2 year, connect(l) m(i) lpattern(dash) lcolor(red))  ///
	(rcap upper_race_4 lower_race_4 year , lstyle(ci) lcolor(gold%30)) ///
	(scatter beta_race_4 year, connect(l) m(o) mc(gold) lpattern(solid) lcolor(gold)) ///
	(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue%30)) ///
	(scatter beta_race_6 year, connect(l) m(dh) mc(blue) lpattern(solid) lcolor(blue)),  ///
	ytitle("Racialized Difference") xtitle("Census Year") ylabel(0[0.05]0.3, nogrid) xlabel(,nogrid) yline(0, lc(gray) lp(dot)) ///
	legend(order(2 "None" 	///
				 4 "CZ"	/// 
				 6 "CZ + mode"  ///
				 8 "CZ + Demo + Mode + Work") rows(2) pos(6) subtitle("Controls:     ", pos(9)))	 
graph export "${DGIT}/results/${SAMPLE}/plots/conditional_oncontrols_simpler.png", replace

frame change default
frame drop regvalues

** MODE SPECIFIC 
local years_list 1980 1990 2000 2005 ///
				 2006 2007 2008 2009 ///
				 2010 2011 2012 2013 ///
				 2014 2015 2016 2017 ///
				 2018 2019
				 
foreach mm in 10 30 36 37 50 60 70 {

	if `mm' == 10 {
		local mode = "car"
	}
	if `mm' == 30 {
		local mode = "bus"
	}
	if `mm' == 36 {
		local mode = "subway"
	}
	if `mm' == 37 {
		local mode = "railroad"
	}
	if `mm' == 50 {
		local mode = "bike"
	}
	if `mm' == 60 {
		local mode = "walk"
	}
	if `mm' == 70 {
		local mode = "other"
	}

	frame create regvalues
	frame change regvalues

		gen year = .
		local i = 1
		foreach y of local years_list {
			set obs `i'
			replace year = `y' if mi(year)
			local i = `i'+1
		}
		foreach n in 1 2 3 6 {
			gen beta_race_`n' = .
			gen se_race_`n' = .
			gen	e_df_`n' = .
		}

	frame change default

	local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
	local transpo	i.tranwork_bin
	local work		linc i.inczero 

	foreach y of local years_list {
		
		// (1) year FEs
		qui reg ln_trantime i.d_black if year == `y' & tranwork_bin==`mm' [aw=czwt_tt], vce(cluster czone)
		frame change regvalues
			replace beta_race_1 = _b[1.d_black] if year == `y'
			replace se_race_1 = _se[1.d_black] if year == `y'
			replace e_df_1 = e(df_r) if year == `y'
		frame change default
		
		// (2) year + cz
		qui reghdfe ln_trantime i.d_black if year == `y' & tranwork_bin==`mm' [aw=czwt_tt], a(czone) vce(cluster czone)
		frame change regvalues
			replace beta_race_2 = _b[1.d_black] if year == `y'		
			replace se_race_2 = _se[1.d_black] if year == `y'
			replace e_df_2 = e(df_r) if year == `y'
		frame change default
		
		// (3) year + CZ + demo
		qui reghdfe ln_trantime i.d_black `demog' ///
			if year == `y' & tranwork_bin==`mm' [aw=czwt_tt], a(czone) vce(cluster czone)
		frame change regvalues
			replace beta_race_3 = _b[1.d_black] if year == `y'		
			replace se_race_3 = _se[1.d_black] if year == `y'
			replace e_df_3 = e(df_r) if year == `y'
		frame change default

		// (6) year + CZ + demo + mode + work
		qui reghdfe ln_trantime i.d_black `demog' `work' ///
			if year == `y' & tranwork_bin==`mm' [aw=czwt_tt], a(czone ind1990 occ1990) vce(cluster czone)
		frame change regvalues
			replace beta_race_6 = _b[1.d_black] if year == `y'		
			replace se_race_6 = _se[1.d_black] if year == `y'
			replace e_df_6 = e(df_r) if year == `y'
		frame change default
	}

	****
	frame change regvalues
	frame regvalues: save "${DATA}/empirics/data/temp_dta/${SAMPLE}/conditional_data_`mode'.dta", replace
	****
	
	frame change default
	frame drop regvalues
}
clear frames 
		 
foreach mm in 10 30 36 37 50 60 70 {

	if `mm' == 10 {
		local mode = "car"
	}
	if `mm' == 30 {
		local mode = "bus"
	}
	if `mm' == 36 {
		local mode = "subway"
	}
	if `mm' == 37 {
		local mode = "railroad"
	}
	if `mm' == 50 {
		local mode = "bike"
	}
	if `mm' == 60 {
		local mode = "walk"
	}
	if `mm' == 70 {
		local mode = "other"
	}

	use "${DATA}/empirics/data/temp_dta/${SAMPLE}/conditional_data_`mode'.dta", clear

	drop if mi(beta_race_1)

	reshape long beta_race_ se_race_ e_df_, i(year) j(spec)
	foreach n in 1 2 3 6 {
		replace year = year+(`n'-3.5)*0.08 if spec==`n'
	}
	reshape wide

	foreach n in 1 2 3 6 {
		gen upper_race_`n' = beta_race_`n' + invttail(e_df_`n', 0.025)*se_race_`n'
		gen lower_race_`n' = beta_race_`n' - invttail(e_df_`n', 0.025)*se_race_`n'
	}

	twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black)) ///
		(line beta_race_1 year, lstyle(solid) lcolor(black))  ///
		(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red)) ///
		(line beta_race_2 year, lpattern(solid) lcolor(red))  ///
		(rcap upper_race_3 lower_race_3 year , lstyle(ci) lcolor(orange)) ///
		(line beta_race_3 year, lstyle(solid) lcolor(orange))  ///
		(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue)) ///
		(line beta_race_6 year, lpattern(solid) lcolor(blue)),  ///
		ytitle("Commuting Gap") xtitle("Census Year") ylabel(, nogrid) xlabel(,nogrid) yline(0, lc(gray) lp(dot)) /// ///
		legend(order(2 "1: year" 	///
					 4 "2: year + CZ"	/// 
					 6 "3: year + CZ + demo"  ///
					 8 "6: year + CZ + demo + work") rows(1) pos(6))	 
	graph export "${DGIT}/results/${SAMPLE}/plots/conditional_oncontrols_`mode'.png", replace
	
	twoway (rcap upper_race_1 lower_race_1 year , lstyle(ci) lcolor(black%30)) ///
		(scatter beta_race_1 year, connect(l) m(i) lstyle(solid) lcolor(black))  ///
		(rcap upper_race_2 lower_race_2 year , lstyle(ci) lcolor(red%30)) ///
		(scatter beta_race_2 year, connect(l) m(i) lpattern(dash) lcolor(red))  ///
		(rcap upper_race_6 lower_race_6 year , lstyle(ci) lcolor(blue%30)) ///
		(scatter beta_race_6 year, connect(l) m(dh) mc(blue) lpattern(solid) lcolor(blue)),  ///
		ytitle("Racialized Difference") xtitle("Census Year") ylabel(, nogrid) xlabel(,nogrid) yline(0, lc(gray) lp(dot)) /// ///
		legend(order(2 "None" 	///
					 4 "CZ"	/// 
					 6 "CZ + demo + work") rows(1) pos(6) subtitle("Controls:   ", pos(9)))	 
	graph export "${DGIT}/results/${SAMPLE}/plots/conditional_oncontrols_`mode'_simpler.png", replace

	clear
}



/*******************************************************************************
First Regressions:

- Main table
- By mode
- By city/metro -- what groups do we have? south vs non-south


*******************************************************************************/

clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify rsample
do		"${DGIT}/code/analysis/parse_sample.do"

drop racamind racasian racblk racpacis racwht racnum trantime czwt_tt_orig d_hisp d_aapi d_amin samp_blw samp_hiw samp_aaw samp_aiw d_completed_college d_completed_high_school d_southern_state age_bin d_white sex 

** Main analysis **

est clear

*preserve  // can we run the by mode part using the entire sample?
*set seed 9483
*sample 10

reghdfe ln_trantime d_black [aw=czwt_tt], a(year_bin) vce(cluster czone)

gen ln_trantime_q99 = ln_trantime
replace ln_trantime_q99 = ln(99) if empstat!=1

gen ln_trantime_q95 = ln_trantime
replace ln_trantime_q95 = ln(60) if empstat!=1

bys czone_year_bin: gegen ltt_czq95_temp = pctile(ln_trantime) [aw=czwt_tt], p(95)
gen ln_trantime_czq95 = ln_trantime
replace ln_trantime_czq95 = ltt_czq95_temp if empstat!=1
drop ltt_czq95_temp

** Main Table: Single Coefficient

local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero 
	/* work also include ind1990 and occ1990 as absorbed FEs */

eststo: reghdfe ln_trantime d_black [aw=czwt_tt], a(year_bin) vce(cluster czone)
eststo: reghdfe ln_trantime d_black [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
eststo: reghdfe ln_trantime d_black `demog' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
eststo: reghdfe ln_trantime d_black `transpo' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
eststo: reghdfe ln_trantime d_black `demog' `transpo' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
eststo: reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], a(czone_year_bin ind1990 occ1990) vce(cluster czone)

esttab using "${DGIT}/results/${SAMPLE}/tables/gap_aveallyears_all.tex", b(3) se(3) nocon keep(*d_black*) label replace bookt f
est clear


** Main Table: Year Coefficients + Interactions

gegen puma_yrbncz = group(puma_yrbn czone) // Ensures pumas are within CZs (they should be, but areal merges mess with that)

compress
drop empstatd labforce  

preserve 
	drop  tranwork_bin linc inczero ind1990 occ1990 division pwpumast pwpuma_yr puma_yrbn puma_yr puma_yrbncz housingcost valueh
	export delim using "${DATA}/empirics/data/ipums_smaller_lfp.csv", replace nolab
restore	
	
keep if empstat==1 

gen other8 = 0
gen transit8 = 0

replace transit8 = 1 if (czone==19400 | /// NYC
						czone==20500 | /// Boston 
						czone==24300 | /// Chicago
						czone==19700 | /// Philadelphia
						czone==11304 | /// DC
						czone==37800 | /// SF
						czone==9100 | /// Atlanta
						czone==38300) // LA

replace other8 = 1 if (czone==33100 | /// DFW
						czone==32000 | /// Houston
						czone==7000 | /// Miami
						czone==35001 | /// Phoenix
						czone==39400 | /// Seattle
						czone==11600 | /// Detroit
						czone==38000 | /// San Diego
						czone==21501) // Twin Cities

gen hi_variety = 0
gen lo_variety = 0
gen no_variety = 0

replace hi_variety = 1 if (czone==19400 | /// NYC
						czone==11304 | /// DC
						czone==9100 | /// Atlanta
						czone==11600 | /// Detroit
						czone==11302 | /// Baltimore
						czone==2000 | /// V Beach
						czone==5202 | /// Memphis
						czone==2400 | /// Richmond
						czone==10600) // Birmingham
						
replace lo_variety = 1 if (czone==38300 | /// LA
						czone==24300 | /// Chicago
						czone==33100 | /// DFW
						czone==32000 | /// Houston
						czone==7000 | /// Miami
						czone==19700 | /// Philadelphia
						czone==20500 | /// Boston 
						czone==35001 | /// Phoenix
						czone==6700 | /// Tampa
						czone==24701 | /// St. Louis
						czone==900 | /// Charlotte
						czone==7400 | /// Orlando
						czone==16300 | /// Pittsburgh
						czone==12701 | /// Cincinatti
						czone==29502 | /// Kansas City
						czone==15900 | /// Columbus OH
						czone==15200 | /// Cleveland 
						czone==14200 | /// Indianapolis
						czone==5600 | /// Nashville
						czone==24100 | /// Milwaukee
						czone==7600 | /// Jacksonville
						czone==33803 | /// OK City
						czone==1701 | /// Raleigh
						czone==13101 | /// Louisville KY
						czone==3300 | /// NOLA
						czone==20901 | /// Hartford
						czone==18000 | /// Buffalo/Rochester
						czone==12200 | /// Grand Rapids
						czone==30402) // Tulsa
						
						
replace no_variety = 1 if (czone==37800 | /// SF
						czone==39400 | /// Seattle
						czone==21501 | /// Twin Cities
						czone==38000 | /// San Diego
						czone==28900 | /// Denver
						czone==31301 | /// San Antonio
						czone==38801 | /// Portland
						czone==37400 | /// Sacramento
						czone==37901 | /// Las Vegas
						czone==31201 | /// Austin
						czone==37500 | /// San Jose
						czone==36100 | /// SLC
						czone==35100) // Tucson
							
						


*save "${DATA}/empirics/data/ipums_smaller.dta", replace
export delim using "${DATA}/empirics/data/ipums_smaller.csv", replace nolab

/* This is implemented in R for faster execution
preserve
	*set seed 9483
	*sample 20

	local demog_yr 		1.female#i.year_bin i.educ_bin#i.year_bin c.age#i.year_bin c.age2#i.year_bin 1.d_marr#i.year_bin 1.d_head#i.year_bin 1.child_1or2#i.year_bin 1.child_gteq3#i.year_bin
	local transpo_yr	i.tranwork_bin#i.year_bin
	local work_yr		c.linc#i.year_bin 1.inczero#i.year_bin
		/* work also include ind1990 and occ1990 as absorbed FEs */

	local st = "$S_TIME"	
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin [aw=czwt_tt], a(year) vce(cluster czone) compact
	elapse "`st'" 
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin [aw=czwt_tt], a(czone_year_bin) vce(cluster czone) compact
	elapse "`st'" 
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin `demog_yr' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone) compact pool(1)
	elapse "`st'" 
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin `transpo_yr' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone) compact pool(1)
	elapse "`st'" 
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin `demog_yr' `transpo_yr' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone) compact pool(1)
	elapse "`st'" 
	eststo: reghdfe ln_trantime 1.d_black#i.year_bin `demog_yr' `transpo_yr' `work_yr' [aw=czwt_tt], a(czone_year_bin ind1990#year_bin occ1990#year_bin) vce(cluster czone) compact pool(1)
	elapse "`st'" 

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/gap_yearspecific_all_20p.tex", b(3) se(3) nocon keep(*d_black*) label replace bookt f
	est clear
restore
*/



**** Regs by mode -- run on full sample
local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero 
	/* work also include ind1990 and occ1990 as absorbed FEs */

local demog_yr 		1.female#i.year_bin i.educ_bin#i.year_bin c.age#i.year_bin c.age2#i.year_bin 1.d_marr#i.year_bin 1.d_head#i.year_bin 1.child_1or2#i.year_bin 1.child_gteq3#i.year_bin
local work_yr		c.linc#i.year_bin 1.inczero#i.year_bin

foreach n in 10 30 36 37 50 60 70 {
	preserve

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

	// Single Coefficient
	eststo: reghdfe ln_trantime d_black [aw=czwt_tt], a(year_bin) vce(cluster czone)
	eststo: reghdfe ln_trantime d_black [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
	eststo: reghdfe ln_trantime d_black `demog' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
	eststo: reghdfe ln_trantime d_black `transpo' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
	eststo: reghdfe ln_trantime d_black `demog' `transpo' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
	eststo: reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], a(czone_year_bin ind1990 occ1990) vce(cluster czone)

	esttab using "${DGIT}/results/${SAMPLE}/tables/gap_aveallyears_`mode'.tex", b(3) se(3) nocon keep(*d_black*) label replace bookt f
	est clear

	if `n' != 10 {
	// Year Coefficients + Interactions (for cars, run in R)
		eststo: reg ln_trantime 1.d_black#i.year_bin [aw=czwt_tt], vce(cluster czone)
		eststo: reghdfe ln_trantime 1.d_black#i.year_bin [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
		eststo: reghdfe ln_trantime 1.d_black#i.year_bin `demog_yr' [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
		eststo: reghdfe ln_trantime 1.d_black#i.year_bin `demog_yr' `work_yr' [aw=czwt_tt], a(czone_year_bin ind1990#year_bin occ1990#year_bin) vce(cluster czone)

		esttab using "${DGIT}/results/${SAMPLE}/tables/gap_yearspecific_`mode'.tex", b(3) se(3) nocon keep(*d_black*) label replace bookt f
		est clear
	}
	restore


	
}



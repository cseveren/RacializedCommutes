
/***************************************
** 0) Set up file path
** 1) Recode and Create Dummies, round 1
** 2) Create Sample Weights so they sum up correctly within year bins
** 2) Create Sample indicators
** 3) Shrink data and Create further useful categories
***************************************/

** 0) Set up

use "${DATA}/empirics/output/ipums_prepped_2001-2019", clear

append using "${DATA}/empirics/output/ipums_prepped_1980-2000.dta", gen(source)

recast float inctot ftotinc incwage, force

compress

drop costelec costgas bedrooms yngch eldch school afactor availble looking source

*******************************
** 1) Recode and create dummies, round 1
*******************************
	 
replace sex = sex-1 
label define sex_label 0 "male" 1 "female", replace

label values sex sex_label

gen byte d_southern_state = .
replace d_southern_state = 1 if statefip == 46 | statefip == 28 | /// 
								statefip == 12 | statefip == 1 |  ///
								statefip == 13 | statefip == 22 | ///
								statefip == 48 | statefip == 51 | ///
								statefip == 5 | statefip == 37 |  ///
								statefip == 47 

replace d_southern_state = 0 if	statefip != 46 & statefip != 28 & /// 
								statefip != 12 & statefip != 1 &  ///
								statefip != 13 & statefip != 22 & ///
								statefip != 48 & statefip != 51 & ///
								statefip != 5 & statefip != 37 &  ///
								statefip != 47 							
								
// South Carolina, Mississippi, Florida, Alabama, Georgia,
// Louisiana, Texas, Virginia, Arkansas, North Carolina, and Tennessee.

** YEAR BINS **
gen int year_bin = cond(year == 1980, 1980, ///
			   cond(year == 1990, 1990, ///
			   cond(year == 2000, 2000, ///
			   cond(year <= 2011, 2010, ///
			   cond(year <= 2019, 2019, .)))))		
	
gen long czone_year_bin = czone*10000+year_bin
	
compress

*******************************
** 2) Create Sample Weights so they sum up correctly within year bins
*******************************

** If summing by year_bin, need to use these.
gen czwt_tt2 = czwt_tt
replace czwt_tt2 = czwt_tt/7 if year_bin==2010
replace czwt_tt2 = czwt_tt/8 if year_bin==2019

rename czwt_tt czwt_tt_orig
rename czwt_tt2 czwt_tt

*******************************
** 3) Create Race Vars and Sample Indicators
*******************************

** Demograhics
tab race racblk /* shows that there is some overlap */

//race + ethnicity
g byte 	d_white = 0
replace d_white = 1 if race==1

g byte 	d_black = 0 
replace d_black = 1 if race==2 | racblk==2

g byte 	d_hisp = 0 
replace d_hisp = 1 if hispan!=0 

g byte 	d_aapi = 0 
replace d_aapi = 1 if race==4 | race==5 | race==6 | racasian==2 | racpacis==2

g byte 	d_amin = 0
replace d_amin = 1 if race==3 | racamind==2

** Samples
g byte 	samp_blw = (d_white==1 | d_black==1) 
g byte 	samp_hiw = (d_white==1 | d_hisp==1) 
g byte 	samp_aaw = (d_white==1 | d_aapi==1) 
g byte 	samp_aiw = (d_white==1 | d_amin==1) 

/* Note, the Black v non-Black, Hispanic v non-Hispanic, and AAPI v non-AAPI
 samples are the whole data set */

compress

*******************************
** 4) Shrink data
*******************************
drop if czwt_tt==0 | czwt_tt==.

drop hhwt hhtype statefip puma farm ownershp mortgage hhincome ncouples multgen multgend perwt famsize nchlt5 related birthyr race hispan bpl citizen yrimmig speakeng racesing racesingd wkswork2 inctot uhrswork movedin sample cluster strata workedyr czwt migsamp ftotinc
 
*******************************
** 5) Additional var creation + add in div indicators
*******************************

do 	"${DGIT}/code/build/1A_additional_var_prep.do"

drop educ educd tranwork incwage yrcz nchild marst relate 

preserve

	use "${DATA}/empirics/input/crosswalks/cw_czone_division/cw_czone_division.dta", clear

	gen division = 0
	replace division = 1 if reg_neweng==1
	replace division = 2 if reg_midatl==1
	replace division = 3 if reg_encen==1
	replace division = 4 if reg_wncen==1
	replace division = 5 if reg_satl==1
	replace division = 6 if reg_escen==1
	replace division = 7 if reg_wscen==1
	replace division = 8 if reg_mount==1
	replace division = 9 if reg_pacif==1

	lab def div_lb 1 "neweng" ///
					2 "midatl" ///
					3 "encen" ///
					4 "wncen" ///
					5 "satl" ///
					6 "escen" ///
					7 "wscen" ///
					8 "mount" ///
					9 "pacif"

	lab val division div_lb	
	drop reg_*
	compress
	
	tempfile div_cz
	save "`div_cz'", replace
	
restore

capture drop _merge

merge m:1 czone using "`div_cz'"
drop if _merge==2
replace division=9 if _merge==1 // All pacific locations in AK/HI
drop 	_merge
lab 	val division div_lb


** PUMA Coding

g long  puma_yrbn = ctygrp1980*100 + 80 if year_bin==1980 & !mi(ctygrp1980)
replace puma_yrbn = puma1990*100 + 90 if year_bin==1990 & !mi(puma1990)
replace puma_yrbn = puma2000*100 + 00 if year_bin==2000 & !mi(puma2000)
replace puma_yrbn = puma2000*100 + 10 if year_bin==2010 & !mi(puma2000)
replace puma_yrbn = puma2010*100 + 19 if year_bin==2019 & !mi(puma2010)

gegen long puma_yr = group(puma_yrbn year_bin) 

drop ctygrp1980 puma1990 puma2000 puma2010

g long pwpumast = pwstate2*100000 + powpuma if !mi(pwstate2) & !mi(powpuma)
gegen long pwpuma_yr = group(pwpumast year_bin)

drop pwstate2 powpuma

/*
foreach y of numlist 1980 1990 2000 2010 2019 {
	unique puma_yr if year_bin==`y'
	unique pwpuma_yr if year_bin==`y'
}
*/

** COMPRESS **
compress	
drop if mi(czone)


save "${DATA}/empirics/output/ipums_vars_standardized", replace

clear

/*****************************
** Data Prep:
**   0) Create narrow dataset for ease of use
** 		- fewer variables, can add omitted vars back if needed // NS modified
**   1) Create files by year AND                               // NS modified
**   2) Merge to commuting zone crosswalks year
**   3) Make adjustments to weights
**   4) Append together
**   5) Adjustments for differences in transit vars coding
** 	 6) Merge together some CZs manually
** 	 7) Adjust prices (DONE) & make common topcodes (NOT DONE) // NS modified
**   8) Make useful variables fixed effects (save time later)
**   9) Create dataset for 2001-2004 (PUMAs not recorded)      // NS added
**   10) Append 1980-2000 data with 2005-2018                  // NS added
*****************************/

***********************************
** -1) Clean up the DDorn Merges **
/* There are a lot of very small weights --> better to set those to 0 */


use		"$ROOT\empirics\input\crosswalks\cw_puma2010_czone\cw_puma2010_czone.dta", clear

bys puma2010: egen puma2010_totalpre = sum(afactor)
sum afactor, d
drop if afactor<=0.006 // Smallest afactor in 2000
bys puma2010: egen puma2010_totalpost = sum(afactor)

sum puma2010_totalpost, d

replace afactor = afactor / puma2010_totalpost /* Rescale */

drop puma2010_totalpost puma2010_totalpre 
recast long czone 
recast float afactor, force

tempfile cx2010
save	"`cx2010'", replace

*****************************
** 0) Create narrow dataset

use		"$ROOT\empirics\input\ipums_pwpumas\ipums_pwpumas.dta", clear
drop if pwpuma00==0 | pwpuma00==1 /* not identifieable, N/A, or didn't work in US/PR */
drop if pwpuma==0 | pwpuma==999   /* N/A or abroad */

gen 	powpuma = pwpuma00
replace powpuma = pwpuma if mi(pwpuma00)

keep 	year sample serial pernum powpuma pwstate2

tempfile workpuma
save "`workpuma'", replace

clear
use		"$ROOT\empirics\input\ipums01-18\ipums2001-2018_race_vars.dta"
append using "$ROOT\empirics\input\ipums19\ipums19.dta"

keep if empstatd==10 | empstatd==14 /* Much faster if only consider people with trantime */

merge 1:1 year sample serial pernum using "`workpuma'"
drop if _merge==2

drop 	_merge serial region gqtype gqtyped propinsr proptx99 ///
		costwatr costfuel nmothers nfathers pernum raced hispand ///
		bpld occ1950 occ2010 ind1950 indnaics poverty ///
		sample cbserial cluster region stateicp strata gqtype gqtyped propinsr ///
		workedy ownershp 

compress

tempfile data_all
save 	"`data_all'"

*****************************
** 1) Create files by year AND 2) Merge to CZ crosswalks AND 3) Adjust weights

** 2001-2011

keep if year >= 2002 & year <= 2011

gen 	puma2000 = 10000*statefip + puma

joinby 	puma2000 using "$ROOT\empirics\input\crosswalks\cw_puma2000_czone\cw_puma2000_czone.dta", unmatched(both) _merge(m2000)
tab 	m2000

gen 	czwt = afactor * perwt

compress

tempfile data_2001_2011
save 	"`data_2001_2011'"

** 2012-2019

use 	"`data_all'"

keep if year >= 2012 & year <= 2019

gen 	puma2010 = 100000*statefip + puma // Multiply be 10E5 rather than 10E4 since Dorn says: The geography codes concatenate the state FIPS code (first two digits) with the PUMA code
										  //(last four digits in 1990 and 2000, last five digits in 2010)

joinby 	puma2010 using "`cx2010'", unmatched(both) _merge(m2010)
tab 	m2010

gen 	czwt = afactor * perwt

compress

*****************************
** 4) Append

append 	using "`data_2001_2011'"
drop	m2000 m2010

** Correct for PUMA changes induced by Hurricane Katrina, adjust for fw

replace czone = 3300 if puma==77777
replace afactor = 1 if puma==77777
replace czwt = afactor * perwt if puma==77777

// drop 	cntygp98 puma puma2000 m2000 puma1990 m1990 ctygrp1980 m1980

*replace year = 2010 if year==2011 GOT TO CUT THIS
tab year [aw=czwt]

compress

*****************************
** 5) Adjustments to transit vars, user cost of housing

** trantime is coded as 0 for unemployed and not in labor force, set to .
replace trantime = . if tranwork==0

** trantime is top-coded differently in different census years, 99 is the smallest topcode
replace trantime = 99 if trantime>99 & trantime!=. 

/* use czwt_tt for trantime ONLY, otherwise czwt */
gen 	czwt_tt = czwt

bys year: sum trantime [aw=czwt_tt], d 

compress

** User cost of housing

replace costelec = . if costelec>9000
replace costgas = . if costgas>9000
replace valueh = . if valueh==9999999
replace rentgrs = . if rentgrs==0

gen 	housingcost = .
replace	housingcost = 0.0785*valueh + costelec + costgas if ownershpd==12 | ownershpd==13
replace housingcost = 12*rentgrs if ownershpd==22


*****************************
** 6) Manually merge some CZs

do		"$ROOT/empirics/code/build/0A_czone_mergers.do"
 
*****************************
** 7) Real dollars
**   Using CPI Adjustment Calculator: https://data.bls.gov/cgi-bin/cpicalc.pl
**   to Jan 2010 = 1:

/******************
	0.86 for 2018
	0.87 for 2018
	0.89 for 2017
	0.91 for 2016
	0.93 for 2015
	0.93 for 2014
	0.94 for 2013
	0.96 for 2012
	0.98 for 2011

	1.03 for 2009
	1.03 for 2008
	1.07 for 2007
	1.09 for 2006
	1.14 for 2005
	1.17 for 2004
	1.19 for 2003
	1.22 for 2002
	1.24 for 2001	
	1.28 for 2000
	1.70 for 1990
	2.79 for 1980
******************/

replace incwage = . if incwage == 999998 | incwage == 999999 

replace hhincome = . if hhincome == 9999999

local pvars rentgrs hhincome valueh inctot ftotinc incwage housingcost

foreach v of local pvars {
	replace `v' = `v'*2.79 if year==1980
	replace `v' = `v'*1.70 if year==1990
	replace `v' = `v'*1.28 if year==2000
	replace `v' = `v'*1.24 if year==2001
	replace `v' = `v'*1.22 if year==2002
	replace `v' = `v'*1.19 if year==2003
	replace `v' = `v'*1.17 if year==2004
	replace `v' = `v'*1.14 if year==2005
	replace `v' = `v'*1.09 if year==2006
	replace `v' = `v'*1.07 if year==2007
	replace `v' = `v'*1.03 if year==2008
	replace `v' = `v'*1.03 if year==2009
	replace `v' = `v'*0.98 if year==2011
	replace `v' = `v'*0.96 if year==2012
	replace `v' = `v'*0.94 if year==2013
	replace `v' = `v'*0.93 if year==2014
	replace `v' = `v'*0.93 if year==2015
	replace `v' = `v'*0.91 if year==2016
	replace `v' = `v'*0.89 if year==2017
	replace `v' = `v'*0.87 if year==2018
	replace `v' = `v'*0.86 if year==2019
}

compress

*****************************
** 7) Create common real value topcodes for wage, housing, rent prices


*****************************
** 8) Useful vars

** Fixed effects
gegen 	yrcz 	 = group(year czone)


*********************************************
** 10) Save

compress

save "$ROOT\empirics\output\ipums_prepped_2001-2019", replace

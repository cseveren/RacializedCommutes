clear

/*****************************
** Data Prep:
**   0) Create narrow dataset for ease of use
** 		- fewer variables, can add omitted vars back if needed
**   1) Create files by year AND
**   2) Merge to commuting zone crosswalks year
**   3) Make adjustments to weights
**   4) Append together
**   5) Adjustments for differences in transit vars coding
** 	 6) Merge together some CZs manually
** 	 7) Adjust prices (DONE) & make common topcodes (NOT DONE)
**   8) Make useful variables fixed effects (save time later)
*****************************/

*****************************
** 0) Create narrow dataset with PWPUMAs and cars in HH

use		"${DATA}/empirics/input/ipums_pwpumas/ipums_pwpumas.dta"
replace pwpuma00=. if pwpuma00==0 | pwpuma00==1 /* not identifieable, N/A, or didn't work in US/PR */
replace pwpuma=.  if pwpuma==0 | pwpuma==999   /* N/A or abroad */

gen 	powpuma = pwpuma00
replace powpuma = pwpuma if mi(pwpuma00)

keep 	year sample serial pernum powpuma pwstate2

tempfile workpuma
save "`workpuma'
clear

use		"${DATA}/empirics/input/ipums80-00_2/ipums1980-2000_all.dta"

drop if year>=2001 & year<=2004
drop if age<18 //** NEED NILF FOR LFP SELECTION keep if empstatd==10 | empstatd==14 /* Much faster if only consider people with trantime */

merge 1:1 year sample serial pernum using "`workpuma'"
drop if _merge==2
drop _merge

merge 1:1 year sample serial pernum using "${DATA}/empirics/output/carinhh.dta"
drop if _merge==2

drop 	_merge serial region gqtype gqtyped proptxin propinsr proptx99 ///
		costwatr costfuel nmothers nfathers pernum raced hispand ///
		bpld occ1950 occ2010 ind1950 indnaics poverty
		
compress

tempfile data_all
save 	"`data_all'"

*****************************
** 1) Create files by year AND 2) Merge to CZ crosswalks AND 3) Adjust weights

** 1980

keep if year==1980

gen 	ctygrp1980 = 1000*statefip + cntygp98 

joinby 	ctygrp1980 using "${DATA}/empirics/input/crosswalks/cw_ctygrp1980_czone/cw_ctygrp1980_czone_corr.dta", unmatched(both) _merge(m1980)

gen 	czwt = afactor * perwt

tempfile data_1980
save 	"`data_1980'"
clear

** 1990 

use 	"`data_all'"

keep if year==1990

gen 	puma1990 = 10000*statefip + puma 

joinby 	puma1990 using "${DATA}/empirics/input/crosswalks/cw_puma1990_czone/cw_puma1990_czone.dta", unmatched(both) _merge(m1990)

gen 	czwt = afactor * perwt

tempfile data_1990
save 	"`data_1990'"
clear

** 2000 

use 	"`data_all'"

keep if year==2000

gen 	puma2000 = 10000*statefip + puma

joinby 	puma2000 using "${DATA}/empirics/input/crosswalks/cw_puma2000_czone/cw_puma2000_czone.dta", unmatched(both) _merge(m2000)

gen 	czwt = afactor * perwt

*****************************
** 4) Append and quality adjust housing

append 	using "`data_1990'"
append 	using "`data_1980'"

drop m2000 m1990 m1980 puma

tab year [aw=czwt]

replace valueh = . if valueh==9999999
replace rentgrs = . if rentgrs==0

gen lhval = ln(valueh)
gen lrent = ln(rentgrs)
gen lhval_adj = .
gen lrent_adj = .

preserve
	keep if year==1980
	levelsof ctygrp1980, local(geo1980)

	foreach g of local geo1980 {
		capture quietly reg lhval ib1960.bltyr_est ib3.rooms_bed ib6.rooms_total if ctygrp1980==`g' [aw=czwt], notab
		capture quietly predict hvalhat if e(sample)==1, xb
		capture replace lhval_adj = lhval - hvalhat + _b[_cons] if e(sample)==1
		capture drop hvalhat
		
		capture quietly reg lrent ib1960.bltyr_est ib2.rooms_bed ib4.rooms_total if ctygrp1980==`g' [aw=czwt], notab
		capture quietly predict renthat if e(sample)==1, xb
		capture replace lrent_adj = lrent - renthat + _b[_cons] if e(sample)==1
		capture drop renthat
	}
	drop 	cntygp98 rooms_bed rooms_total bltyr_est
	
	tempfile hd1980
	save "`hd1980'"
restore

preserve
	keep if year==1990
	levelsof puma1990, local(geo1990)

	foreach g of local geo1990 {
		capture quietly reg lhval ib1970.bltyr_est ib3.rooms_bed ib6.rooms_total if puma1990==`g' [aw=czwt], notab
		capture quietly predict hvalhat if e(sample)==1, xb
		capture replace lhval_adj = lhval - hvalhat + _b[_cons] if e(sample)==1
		capture drop hvalhat
		
		capture quietly reg lrent ib1970.bltyr_est ib2.rooms_bed ib4.rooms_total if puma1990==`g' [aw=czwt], notab
		capture quietly predict renthat if e(sample)==1, xb
		capture replace lrent_adj = lrent - renthat + _b[_cons] if e(sample)==1
		capture drop renthat
	}
	drop 	cntygp98 rooms_bed rooms_total bltyr_est
	
	tempfile hd1990
	save "`hd1990'"
restore

keep if year==2000
levelsof puma2000, local(geo2000)

foreach g of local geo2000 {
	capture quietly reg lhval ib1980.bltyr_est ib3.rooms_bed ib6.rooms_total if puma2000==`g' [aw=czwt], notab
	capture quietly predict hvalhat if e(sample)==1, xb
	capture replace lhval_adj = lhval - hvalhat + _b[_cons] if e(sample)==1
	capture drop hvalhat
	
	capture quietly reg lrent ib1980.bltyr_est ib2.rooms_bed ib4.rooms_total if puma2000==`g' [aw=czwt], notab
	capture quietly predict renthat if e(sample)==1, xb
	capture replace lrent_adj = lrent - renthat + _b[_cons] if e(sample)==1
	capture drop renthat
}

drop 	cntygp98 rooms_bed rooms_total bltyr_est

append using "`hd1990'"
append using "`hd1980'"

recast float lhval_adj lrent_adj

compress

*****************************
** 5) Adjustments to transit vars, user cost of housing

** trantime is coded as 0 for unemployed and not in labor force, set to .
replace trantime = . if tranwork==0

** trantime is top-coded differently in different census years, 99 is the smallest topcode
replace trantime = 99 if trantime>99 & trantime!=. 

** trantime was sampled differently in the 1980 census, see  https://usa.ipums.org/usa-action/variables/TRANTIME#description_section
replace trantime = . if migsamp==1

/* use czwt_tt for trantime ONLY, otherwise czwt */
gen 	czwt_tt = czwt
replace czwt_tt = 2*czwt if year==1980
replace czwt_tt = . if migsamp==1 & year==1980

bys year: sum trantime [aw=czwt_tt], d 

drop if migsamp==1 & year==1980

compress

** User cost of housing

replace costelec = . if costelec>9000
replace costgas = . if costgas>9000

gen 	housingcost = .
replace	housingcost = 0.0785*valueh + costelec + costgas if ownershp==1
replace housingcost = 12*rentgrs if ownershpd==22


*****************************
** 6) Manually merge some CZs

do		"${DGIT}/code/build/0A_czone_mergers.do"


*****************************
** 7) Real dollars
**   Using CPI Adjustment Calculator: https://data.bls.gov/cgi-bin/cpicalc.pl
**   to Jan 2010 = 1, 1.28 for 2000, 1.70 for 1990, 2.79 for 1980
**   Rounding saves a little space

replace incwage = . if incwage == 999998 | incwage == 999999 
replace ftotinc = . if ftotinc == 9999998 | ftotinc == 9999999
replace hhincome = . if hhincome == 9999999

local pvars rentgrs hhincome valueh inctot ftotinc incwage housingcost

foreach v of local pvars {
	replace `v' = `v'*2.79 if year==1980
	replace `v' = round(`v')
}

foreach v of local pvars {
	replace `v' = `v'*1.70 if year==1990
	replace `v' = round(`v')
}

foreach v of local pvars {
	replace `v' = `v'*1.28 if year==2000
	replace `v' = round(`v')
}

compress

*****************************
** 7) Create common real value topcodes for wage, housing, rent prices


*****************************
** 8) Useful vars

** Fixed effects
egen 	yrcz 	 = group(year czone)


*******************************
** SAVE

compress
save "${DATA}/empirics/output/ipums_prepped_1980-2000", replace
clear


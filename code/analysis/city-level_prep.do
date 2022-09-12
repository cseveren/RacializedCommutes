drop if min_n_black==0
bys czone: egen n_yrs = count(czone)

/* diagnostics 
gen lblack = ln(n_black)
gen lpopblack = ln(popemp_black)

scatter lblack lpopblack if year==1980
scatter lblack lpopblack if year==1990
scatter lblack lpopblack if year==2000
scatter lblack lpopblack if year==2010
scatter lblack lpopblack if year==2019

pwcorr lblack lpopblack if year==1980
pwcorr lblack lpopblack if year==1990
pwcorr lblack lpopblack if year==2000
pwcorr lblack lpopblack if year==2010
pwcorr lblack lpopblack if year==2019
*/ 

** Determine Sample Selection (to remove measurement errors) **
sum min_popemp min_n_obs min_perc_black min_n_black, d

sum r6_stderr if min_n_black <= 10
sum r6_stderr if min_n_black > 10 & min_n_black <= 25
sum r6_stderr if min_n_black > 25 & min_n_black <= 50
sum r6_stderr if min_n_black > 50 & min_n_black <= 75
sum r6_stderr if min_n_black > 75 & min_n_black <= 100
sum r6_stderr if min_n_black > 100

** Variable Creation
gen lpop = ln(popemp)
gen lmodeshare_anytransit = ln(modeshare_anytransit)
gen ltime_anytransit = ln(time_anytransit)
gen ltime_car = ln(time_car)

gen lpopblack = ln(perc_black*popemp)
gen lpercblack = ln(perc_black)
gen lpopbl_X_sdltrantime = lpopblack * sd_ltime

gen timegap_1_99 = p99_time-p1_time
gen timegap_5_95 = p95_time-p5_time
gen timegap_10_90 = p90_time-p10_time

gen lhval = ln(valueh)

gen len_ab = lena+lenb
gen lmiles_a = ln(lena)
gen lmiles_b = ln(lenb)
gen lmiles_ab = ln(len_ab)
gen miles_per_cap = len_ab/popemp

gen yri = 1 if year==1980
replace yri = 2 if year==1990
replace yri = 3 if year==2000
replace yri = 4 if year==2010
replace yri = 5 if year==2019

xtset czone yri

** Extra Vars
gen	bigger = (min_popemp>200000)
gen bw_gini = gini_blk-gini_wht

** Prep other variables

gen lnma_citysp = ln(ma_ratio_citysp)
gen lnma_common = ln(ma_ratio_common_wwage)

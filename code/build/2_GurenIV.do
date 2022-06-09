
***CZ by year Bin***
/*use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear

keep 	valueh d_black czwt_tt czone_year_bin czone year_bin

collapse (mean) m_valueh=valueh sh_black=d_black (median) p50_valueh=valueh [aw=czwt_tt], by(czone_year_bin czone year_bin)

tempfile czone_aves
save 	"`czone_aves'", replace
*/

***Census Division Averages***

use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear

keep 	division year_bin valueh d_black czwt_tt czone_year_bin czone

collapse (mean) m_valueh=valueh sh_black=d_black (median) p50_valueh=valueh (rawsum) czwt_tt [aw=czwt_tt], by(czone_year_bin czone division year_bin)

bys division year_bin: gegen totalave = sum(m_valueh*czwt_tt)
bys division year_bin: gegen totalsum = sum(czwt_tt)

replace totalave = totalave - m_valueh*czwt_tt
replace totalsum = totalsum - czwt_tt

gen 	divprice = totalave / totalsum

drop 	totalave totalsum
save "${ROOT}/empirics/data/housing_prices_czonedivyear.dta", replace

clear
use "${ROOT}/empirics/data/housing_prices_czonedivyear.dta"
rename year_bin year
merge 1:1 czone year using "$ROOT/empirics/output/czyrall_blackwhite.dta", keepusing(r6_estimate)
drop _merge

** Reg model
gen 	lhval = ln(m_valueh)
gen 	ldiv_hval = ln(divprice)

gen yri = 1 if year==1980
replace yri = 2 if year==1990
replace yri = 3 if year==2000
replace yri = 4 if year==2010
replace yri = 5 if year==2019

** Testing
reghdfe lhval ldiv_hval i.yri, a(czone) cluster(czone)
reghdfe lhval ldiv_hval, a(i.czone##c.yri) cluster(czone)

xtset czone yri

reghdfe D.lhval D.ldiv_hval i.yri, noa cluster(czone)
reghdfe D.lhval D.ldiv_hval, a(czone) cluster(czone)

** Main model
reghdfe lhval sh_black, a(i.czone##c.yri divpredA=i.czone##c.ldiv_hval) cluster(czone)
sum divpredASlope1 if year==2019, d
gen gurenIV_A = divpredASlope1*ldiv_hval

reghdfe lhval sh_black r6_estimate, a(i.czone##c.yri divpredB=i.czone##c.ldiv_hval) cluster(czone)
sum divpredBSlope1 if year==2019, d
gen gurenIV_B = divpredBSlope1*ldiv_hval


** Saving

keep czone year division gurenIV_?

save "${ROOT}/empirics/output/gurenIV.dta", replace
clear

** <asrol> is nice but does not support weight


***CZ by year Bin***
/*use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear

keep 	valueh d_black czwt_tt czone_year_bin czone year_bin

collapse (mean) m_valueh=valueh sh_black=d_black (median) p50_valueh=valueh [aw=czwt_tt], by(czone_year_bin czone year_bin)

tempfile czone_aves
save 	"`czone_aves'", replace
*/

*bysort division year_bin: asrol valueh, stat(mean) xf(czone) gen(specific_average)
*bysort division year_bin: asrol valueh, stat(median) xf(czone) gen(specific_median)
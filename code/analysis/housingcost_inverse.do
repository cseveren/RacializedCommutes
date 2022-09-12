
clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify sample
do		"${DGIT}/code/analysis/parse_sample.do"

keep if empstat==1 
keep if empstatd==10 | empstatd==14

// Make smaller for speed/ease
drop racamind racasian racblk racpacis racwht racnum trantime czwt_tt_orig d_hisp d_aapi d_amin samp_blw samp_hiw samp_aaw samp_aiw d_completed_college d_completed_high_school d_southern_state age_bin d_white sex

** housing prices
est clear

eststo: reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==1980 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==1990 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==2000 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2010 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)


esttab using "${DGIT}/results/${SAMPLE}/tables/housingprice_gradient.tex", b(3) se(3) nocon label replace bookt f stats(gradifblackb gradifblackse N, fmt(%9.3f %9.3f %10.0g))
est clear

** rents

eststo: reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==1980 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==1990 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime  if year_bin==2000 [aw=czwt_tt], a(czone_year_bin##d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2010 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)

eststo: reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black czone_year_bin#tranwork_bin) vce(cluster czone)
lincomestadd _b[ln_trantime] + _b[1.d_black#c.ln_trantime], statname(gradifblack) format(%9.3f)


esttab using "${DGIT}/results/${SAMPLE}/tables/housingprice_gradient_rent.tex", b(3) se(3) nocon label replace bookt f stats(gradifblackb gradifblackse N, fmt(%9.3f %9.3f %10.0g))
est clear



/* older material
reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==1980 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==1990 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2000 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black) vce(cluster czone)

reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==1980 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==1990 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2000 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)
reghdfe lrent_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(czone_year_bin##year czone_year_bin#d_black) vce(cluster czone)




reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==1980 & tranwork_bin==10 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)

reghdfe lhval_adj ln_trantime 1.d_black#c.ln_trantime if year_bin==2019 & tranwork_bin==10 [aw=czwt_tt], a(czone_year_bin##d_black) vce(cluster czone)

reghdfe lhval_adj ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==1980 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==1990 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==2000 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(czone_year_bin##year) vce(cluster czone)

reghdfe lhval_adj ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==2019 [aw=czwt_tt], a(puma_yr) vce(cluster czone)


reghdfe lhval_adj ln_trantime if year_bin==1980 & d_black==1 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime if year_bin==1990 & d_black==1 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime if year_bin==2000 & d_black==1 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe lhval_adj ln_trantime if year_bin==2019 & d_black==1 [aw=czwt_tt], a(czone_year_bin##year) vce(cluster czone)

*/

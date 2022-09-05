
clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify sample
do		"${DGIT}/code/analysis/parse_sample.do"

keep if empstat==1 
keep if empstatd==10 | empstatd==14

// Make smaller for speed/ease
drop racamind racasian racblk racpacis racwht racnum trantime czwt_tt_orig d_hisp d_aapi d_amin samp_blw samp_hiw samp_aaw samp_aiw d_completed_college d_completed_high_school d_southern_state age_bin d_white sex

drop if inlist(year_bin, 1990, 2000, 2010)


gen ln_hc = ln(housingcost)
gen ln_hval = ln(valueh)
gen ln_rent = ln(rentgrs)

tab ownershpd year_bin
tab ownershpd year_bin, nol
gen d_own = inlist(ownershpd,10,12,13)
drop if inlist(ownershpd, 0, 21)


reghdfe ln_hc 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  [aw=czwt_tt], a(czone_year_bin##d_own) vce(cluster czone)

reghdfe ln_hc 1980.year_bin#c.ln_trantime 1.d_black#1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime 1.d_black#2019.year_bin#c.ln_trantime [aw=czwt_tt], a(czone_year_bin##d_own) vce(cluster czone)



reghdfe ln_hc 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  year_bin [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)

reghdfe ln_hc 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  year_bin [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)

reghdfe ln_hc 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  i.year_bin##i.ownershpd [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)

reghdfe ln_hval 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  i.year_bin##i.ownershpd [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
reghdfe ln_rent 1980.year_bin#c.ln_trantime 2019.year_bin#c.ln_trantime  i.year_bin##i.ownershpd [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)


reghdfe ln_hc ln_trantime d_black 1.d_black#c.ln_trantime if year_bin==1980 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
		reghdfe, coeflegend
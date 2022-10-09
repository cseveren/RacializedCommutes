use "${DATA}/empirics/output/czyrall_blackwhite.dta", clear

do 	"${DGIT}/code/analysis/city-level_prep.do"

keep if min_n_black>50
keep if min_popemp>=1000
keep if n_yrs==5
* leaves 1690 obs for 338 CZs *

est clear

set scheme plotplainblind

** Motivation for city size restriction
preserve 
	gen popcat = .
	replace popcat = 3 if inrange(min_popemp, 0, 100000)
	replace popcat = 4 if inrange(min_popemp, 100001, 200000)
	replace popcat = 5 if inrange(min_popemp, 200001, 500000)
	replace popcat = 6 if inrange(min_popemp, 500001, 1000000)
	replace popcat = 7 if inrange(min_popemp, 1000001, 100000000)


	collapse (mean) r6_estimate [aw=popemp_black], by(popcat year)

	twoway (line r6_estimate year if popcat==3, lc(gs11) lp(dash)) || ///
			(line r6_estimate year if popcat==4, lc(ltblue) lp(dash)) || ///
			(line r6_estimate year if popcat==5, lc(midblue) lp(solid)) || ///
			(line r6_estimate year if popcat==6, lc(blue) lp(solid)) || ///
			(line r6_estimate year if popcat==7, lc(navy) lp(solid)), ///
			yline(0, lc(black) lp(dot)) ylabel(, nogrid) xlabel(, nogrid) ///
			legend(off) ytitle("Mean Residual Difference (RRD)," "by Minimum Employed Population") xtitle("Year") ///
			text(-0.011 2005 "<100k", si(medsmall) c(gs11)) ///
			text(-0.009 2016 "[100k,200k]", si(medsmall) c(ltblue)) ///
			text(0.0357 1983.5 "(200k, 500k]", si(medsmall) c(midblue)) ///
			text(0.075 1993.5 "(500k, 1 mil.]", si(medsmall) c(blue)) ///
			text(0.124 2011 ">1 mil.", si(medsmall) c(navy))

	graph export "${DGIT}/results/${SAMPLE}/plots/rrd_by_population.png", replace
restore 
	
	
foreach n of numlist 6 {
	
	gen L4_r`n'_estimate = L4.r`n'_estimate
	
	if `n'==2 {
		local nlab "Covars: None"
	}
	else if `n'==3 {
		local nlab "Covars: Demog"
	}
	else if `n'==4 {
		local nlab "Covars: Mode"
	}
	else if `n'==5 {
		local nlab "Covars: Demog + Mode"
	}
	else if `n'==6 {
		local nlab "Covars: Demog + Mode + Work"
	}
	
	local nlab 

	reg r`n'_estimate L4_r`n'_estimate [w=popemp_black], robust
	local coef : di %9.3f _b[L4_r`n'_estimate]
	local se : di %9.3f _se[L4_r`n'_estimate]
	twoway (line r`n'_estimate r`n'_estimate, lc(gray)) || ///
		(scatter r`n'_estimate L4_r`n'_estimate [w=popemp_black], msymbol(oh) mc(black) ) || ///
		(lfit r`n'_estimate L4_r`n'_estimate [w=popemp_black], lcolor(dkorange)), ///
		legend(off) ylabel(,nogrid) xlabel(,nogrid) ///
		yline(0, lc(gray) lp(dot)) xline(0, lc(gray) lp(dot)) ylabel(-0.4(0.4)0.5, nogrid) xlabel(-0.4(0.4)0.5, nogrid)  /// 
		xtitle("RRD in 1980") ytitle("RRD in 2012-19") yscale(range(-0.4 0.5)) xscale(range(-0.4 0.5)) ///
		text(0.3 -0.25 "Slope: `coef'" "Standard Error: `se'", j(right) si(medsmall) c(dkorange))
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/persistance_`n'.png", replace
	
	
	twoway (scatter r`n'_estimate lpop if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lpop if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lpop if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lpop if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Population)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/popchange_`n'.png", replace	
	
	twoway (scatter r`n'_estimate perc_black if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate perc_black if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate perc_black if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate perc_black if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Percent Black") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 

	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/percblack_`n'.png", replace	
	
	twoway (scatter r`n'_estimate diss if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate diss if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate diss if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate diss if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Residential Segregation (Dissimilarity)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/segdiss_`n'.png", replace
	
	
	twoway (scatter r`n'_estimate gini_blk if year==1990, m(o) mc(gray) ) || ///
		(lpoly r`n'_estimate gini_blk if year==1990 [aw=popemp_black], lc(gray) lp(solid)) || ///
		(scatter r`n'_estimate gini_blk if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate gini_blk if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1990" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Employment Concentration (GINI) - Black Workers") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/giniblk_`n'.png", replace
	
	twoway (scatter r`n'_estimate gini_wht if year==1990, m(o) mc(gray) ) || ///
		(lpoly r`n'_estimate gini_wht if year==1990 [aw=popemp_black], lc(gray) lp(solid)) || ///
		(scatter r`n'_estimate gini_wht if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate gini_wht if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1990" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Employment Concentration (GINI) - White Workers") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/giniwht_`n'.png", replace
	
	twoway (scatter r`n'_estimate tot_centrality_OG if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate tot_centrality_OG if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate tot_centrality_OG if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate tot_centrality_OG if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Centrality (Bento et al. '05)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/centrality_`n'.png", replace
	
	twoway (scatter r`n'_estimate lmiles_ab if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lmiles_ab if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lmiles_ab if year==2000, m(dh) mc(green%80) ) || ///
		(lpoly r`n'_estimate lmiles_ab if year==2000 [aw=popemp_black], lc(green%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2000")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Highway Miles)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/highways_`n'.png", replace
	
	twoway (scatter r`n'_estimate modeshare_anytransit if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate modeshare_anytransit if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate modeshare_anytransit if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate modeshare_anytransit if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Transit Mode Share") ytitle("Residual Difference") yscale(range(-0.5 0.5)) 
	
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/transitshare_`n'.png", replace	
	
		
	twoway (scatter r`n'_estimate time_car if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate time_car if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate time_car if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate time_car if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Travel Time - Car") ytitle("Residual Difference") yscale(range(-0.5 0.5))
	
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/traveltimecar_`n'.png", replace
	
	twoway (scatter r`n'_estimate comm_hval_corr_est if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate comm_hval_corr_est if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate comm_hval_corr_est if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate comm_hval_corr_est if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Corr(Commute Time, Housing Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5))
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/commhvalcorr_`n'.png", replace
	
	twoway (scatter r`n'_estimate lhval if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lhval if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lhval if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lhval if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Average House Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5))
		
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/houseprice_`n'.png", replace
	
}
	

/*
	
gen citytype = 0

replace citytype = 2 if (czone==19400 | /// NYC
						czone==20500 | /// Boston 
						czone==24300 | /// Chicago
						czone==19700 | /// Philadelphia
						czone==11304 | /// DC
						czone==37800 | /// SF
						czone==9100 | /// Atlanta
						czone==38300) // LA

replace citytype = 1 if (czone==33100 | /// DFW
						czone==32000 | /// Houston
						czone==7000 | /// Miami
						czone==35001 | /// Phoenix
						czone==39400 | /// Seattle
						czone==11600 | /// Detroit
						czone==38000 | /// San Diego
						czone==21501) // Twin Cities

collapse (mean) r6_estimate[aw=popemp_black], by(citytype year)

**
twoway (line r6_estimate year if citytype==0) || ///
		(line r6_estimate year if citytype==1) || ///
		(line r6_estimate year if citytype==2)

twoway (lpoly r6_estimate lpop if year==2019 [aw=popemp_black], bw(0.5)) || ///
		(scatter r6_estimate lpop if year==2019 & inrange(r6_estimate, -0.3, 0.3))
*/
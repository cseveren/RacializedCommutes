use "${DATA}/empirics/output/czyrall_blackwhite.dta", clear

do 	"${DGIT}/code/analysis/city-level_prep.do"

est clear

!mkdir "${DGIT}/results/${SAMPLE}/plots/citylevel"

set scheme plotplainblind

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
	
	
** OLDER  
/*	
{
	twoway (scatter r`n'_estimate lpop if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lpop if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lpop if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lpop if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Population)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/popchange_`n'.png", replace	
	
	twoway (scatter r`n'_estimate perc_black if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate perc_black if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate perc_black if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate perc_black if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Percent Black") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")

	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/percblack_`n'.png", replace	
	
	twoway (scatter r`n'_estimate lpopblack if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lpopblack if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lpopblack if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lpopblack if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Black Population)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/popblack_`n'.png", replace
		
	twoway (scatter r`n'_estimate lmodeshare_anytransit if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lmodeshare_anytransit if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lmodeshare_anytransit if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lmodeshare_anytransit if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Mode Share - Any Transit)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/transitsharelog_`n'.png", replace	
	
	twoway (scatter r`n'_estimate ltime_car if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate ltime_car if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate ltime_car if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate ltime_car if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Travel Time - Car)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/traveltimecar_`n'.png", replace
	
	twoway (scatter r`n'_estimate ltime_anytransit if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate ltime_anytransit if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate ltime_anytransit if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate ltime_anytransit if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Travel Time - Any Transit)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/traveltimeanytransit_`n'.png", replace
	
	twoway (scatter r`n'_estimate sd_time if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate sd_time if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate sd_time if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate sd_time if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("SD of Travel Time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/sdtraveltime_`n'.png", replace
	
	twoway (scatter r`n'_estimate sd_ltime if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate sd_ltime if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate sd_ltime if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate sd_ltime if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("SD of Ln(Travel Time)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")	
		
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/sdlntraveltime_`n'.png", replace
		
	twoway (scatter r`n'_estimate lpopbl_X_sdltrantime  if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lpopbl_X_sdltrantime  if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lpopbl_X_sdltrantime  if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lpopbl_X_sdltrantime  if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Black Population) X SD of Ln(Travel Time)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")	
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/popblack_X_sdlntraveltime_`n'.png", replace
			
	twoway (scatter r`n'_estimate ruralurbancont1993 if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate ruralurbancont1993 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate ruralurbancont1993 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate ruralurbancont1993 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Rural Urban Continuum (1993)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/ruralurban93_`n'.png", replace
	

	
	twoway (scatter r`n'_estimate tot_centrality_OG if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate tot_centrality_OG if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate tot_centrality_OG if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate tot_centrality_OG if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Centrality (Bento et al.)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/centralityOG_`n'.png", replace
	
	twoway (scatter r`n'_estimate tot_centrality_Alt2 if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate tot_centrality_Alt2 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate tot_centrality_Alt2 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate tot_centrality_Alt2 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Centrality (Lyndsey's Other Measure)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/centralityLR_`n'.png", replace
	
	twoway (scatter r`n'_estimate timegap_10_90 if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate timegap_10_90 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate timegap_10_90 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate timegap_10_90 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("p90 - p10 Commuting Time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/timegap9010_`n'.png", replace
	
	twoway (scatter r`n'_estimate timegap_5_95 if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate timegap_5_95 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate timegap_5_95 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate timegap_5_95 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("p95 - p5 Commuting Time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/timegap9505_`n'.png", replace
		

	
	twoway (scatter r`n'_estimate hutchens if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate hutchens if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate hutchens if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate hutchens if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Residential Segregation (Hutchen's)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/seghutch_`n'.png", replace
	
	twoway (scatter r`n'_estimate lhval if year==1980, m(o) mc(black) ) || ///
		(lpoly r`n'_estimate lhval if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r`n'_estimate lhval if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r`n'_estimate lhval if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Mean Housing Value)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")

	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/loghval_`n'.png", replace
			
	twoway (scatter r6_estimate comm_hval_corr if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate comm_hval_corr if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate comm_hval_corr if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate comm_hval_corr if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Corr(Com Time, Housing Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/commhvalcorr_`n'.png", replace
	
	twoway (scatter r6_estimate pdiff_mean if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate pdiff_mean if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate pdiff_mean if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate pdiff_mean if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("PDiffMean(Com Time, Housing Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	graph export "${ROOT}/empirics/results/${SAMPLE}/plots/citylevel/pdiff_`n'.png", replace
	

}

}
est clear

** Extra Vars
gen	bigger = (min_popemp>200000)

** Cross sectional regressions

local clist perc_black ///
			modeshare_anytransit time_anytransit time_car lena lenb len_ab lmiles_a lmiles_b lmiles_ab miles_per_cap ///
			diss hutchens ///
			tot_centrality_OG blk_centrality_OG wht_centrality_OG bw_diff gini_tot gini_blk gini_wht bw_gini ///
			comm_hval_corr pdiff_mean
			

foreach y of numlist 1980 2000 2019 {

	local explvar
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=popemp_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
	macro drop explvar
}

foreach y of numlist 1980 2000 2019 {

	local explvar
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=popemp_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
	macro drop explvar
}

** Simple Correlates
est clear

foreach y of numlist 1980 2019 {
	eststo: reg r6_estimate lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' & bigger==1 [aw=popemp_black], vce(cluster czone)
}

eststo: reghdfe r6_estimate lpop [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_pop.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_pop.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

** Commuting Characteristics 
foreach v of varlist modeshare_anytransit time_anytransit time_car lena lenb len_ab lmiles_a lmiles_b lmiles_ab miles_per_cap {
	eststo: reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_commuting_nocontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_commuting_nocontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

foreach v of varlist modeshare_anytransit time_anytransit time_car lena lenb len_ab lmiles_a lmiles_b lmiles_ab {
	eststo: reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_commuting_wcontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_commuting_wcontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

** Segregation 

foreach v of varlist diss hutchens {
	eststo: reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_segregation_nocontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_segregation_nocontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

foreach v of varlist diss hutchens {
	eststo: reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_segregation_wcontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_segregation_wcontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

** Urban Form 

capture gen bw_gini = gini_blk-gini_wht

foreach v of varlist tot_centrality_OG blk_centrality_OG wht_centrality_OG bw_diff gini_tot gini_blk gini_wht bw_gini {
	eststo: reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_urbanform_nocontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_urbanform_nocontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

foreach v of varlist tot_centrality_OG blk_centrality_OG wht_centrality_OG bw_diff gini_tot gini_blk gini_wht bw_gini {
	eststo: reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_urbanform_wcontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_urbanform_wcontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

** Increased Selection on Access 

foreach v of varlist comm_hval_corr pdiff_mean {
	eststo: reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_hpsort_nocontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_hpsort_nocontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

foreach v of varlist comm_hval_corr pdiff_mean {
	eststo: reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	eststo: reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_hpsort_wcontrol.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_hpsort_wcontrol.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

** Housing IV

eststo: reghdfe r6_estimate lhval [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lhval perc_black [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: ivreghdfe r6_estimate (lhval=gurenIV_B) [aw=popemp_black], a(czone yri) cluster(czone) first 
eststo: ivreghdfe r6_estimate perc_black (lhval=gurenIV_B) [aw=popemp_black], a(czone yri) cluster(czone) first
eststo: ivreghdfe r6_estimate perc_black (lhval=gurenIV_A) [aw=popemp_black], a(czone yri) cluster(czone) first
eststo: ivreghdfe r6_estimate perc_black (lhval=gurenIV_B) if bigger==1 [aw=popemp_black], a(czone yri) cluster(czone) first
	
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_housing.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_housing.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
est clear





** OLDER OLDER
** Declare varlists
local clist modeshare_anytransit time_car time_anytransit time_all sd_time sd_time_auto timegap_5_95 timegap_10_90 tot_centrality_OG wht_centrality_OG blk_centrality_OG blk_centrality_Alt2 wht_centrality_Alt2 tot_centrality_Alt2 diss hutchens lhval comm_hval_corr pdiff_mean gini_tot gini_wht gini_blk gini_bw
 
local clistshort lpop perc_black lhval modeshare_anytransit time_car time_anytransit tot_centrality_OG diss hutchens gini_tot comm_hval_corr pdiff_mean

local clistnopop perc_black lhval modeshare_anytransit time_car time_anytransit tot_centrality_OG diss hutchens gini_tot comm_hval_corr pdiff_mean


** Cross sectional regressions

foreach y of numlist 1980 1990 2000 2010 2019 {

	local explvar
	
	eststo, title("Population"): 	reg r6_estimate lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo, title("p_black"): 		reg r6_estimate perc_black lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo, title("p_blackXlpop"): 	reg r6_estimate perc_black lpop c.perc_black#c.lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=popemp_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
	macro drop explvar
}

foreach y of numlist 1980 1990 2000 2010 2019 {

	local explvar
	
	foreach v of local clistshort {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=popemp_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_short_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_short_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
}
	
foreach y of numlist 1980 1990 2000 2010 2019 {
	
	local explvar
	
	foreach v of local clistnopop {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=popemp_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}
	di "`explvar'"

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_shortpop_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend drop(lpop)
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_shortpop_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend drop(lpop)
	
	est clear
}




** Panel measures
local explvar
foreach v of local clist {
	eststo, title("`v'"): 		reghdfe r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
est clear

	/* Groups(general 3, commuting 3, urban form 4, sorting 2) */
local explvar
foreach v of local clistshort {
	eststo, title("`v'"): 		reghdfe r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_short.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_short.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
est clear
	

	/* Groups(general 3, commuting 3, urban form 4, sorting 2) */
local explvar
foreach v of local clistnopop {
	eststo, title("`v'"): 		reghdfe r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_shortpop.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_shortpop.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
est clear	
	
	
	/*
	
** Sand Box **
/*	
	scatter sd_time time_all // SD of time increase in level
	scatter sd_ltime time_all // SD of time increase in level but not in log-level

	twoway (scatter r6_estimate timegap_10_90 if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate timegap_10_90 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate timegap_10_90 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate timegap_10_90 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("p90 - p10 Commuting Time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	
	twoway (scatter r6_estimate timegap_5_95 if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate timegap_5_95 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate timegap_5_95 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate timegap_5_95 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("p95 - p5 Commuting Time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
		
	twoway (scatter r6_estimate diss if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate diss if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate diss if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate diss if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Residential Segregation (Dissimilarity)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	twoway (scatter r6_estimate hutchens if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate hutchens if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate hutchens if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate hutchens if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Residential Segregation (Hutchen's)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	twoway (scatter r6_estimate lpopblack if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate lpopblack if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate lpopblack if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate lpopblack if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Log(Black Population)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	twoway (scatter r6_estimate sd_time if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate sd_time if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate sd_time if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate sd_time if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("SD of travel time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	twoway (scatter r6_estimate lpopbl_X_sdltrantime  if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate lpopbl_X_sdltrantime  if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate lpopbl_X_sdltrantime  if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate lpopbl_X_sdltrantime  if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("SD of travel time") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	twoway (scatter r6_estimate tot_centrality_OG if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate tot_centrality_OG if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate tot_centrality_OG if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate tot_centrality_OG if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Centrality (Bento et al.)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	twoway (scatter r6_estimate tot_centrality_Alt2 if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate tot_centrality_Alt2 if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate tot_centrality_Alt2 if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate tot_centrality_Alt2 if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Centrality (Lyndsey's Other Measure)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")

	twoway (scatter r6_estimate lhval if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate lhval if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate lhval if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate lhval if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Ln(Mean Housing Value)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	twoway (scatter r6_estimate corr if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate corr if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate corr if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate corr if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Corr(-Com Time, Housing Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
		
	twoway (scatter r6_estimate pdiff_mean if year==1980, m(o) mc(black) ) || ///
		(lpoly r6_estimate pdiff_mean if year==1980 [aw=popemp_black], lc(black) lp(solid)) || ///
		(scatter r6_estimate pdiff_mean if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate pdiff_mean if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1980" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("PDiffMean(-Com Time, Housing Price)") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
	
	twoway (scatter r6_estimate gini_blk if year==1990, m(o) mc(gray) ) || ///
		(lpoly r6_estimate gini_blk if year==1990 [aw=popemp_black], lc(gray) lp(solid)) || ///
		(scatter r6_estimate gini_blk if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r6_estimate gini_blk if year==2019 [aw=popemp_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Difference in 1990" 3 "Difference in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Jobs/Res GINI - Total") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
*/

** PLOTS **

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
	
	*local popvar min_popemp
	local popvar popemp
	gen popcat = .
	replace popcat = 3 if inrange(`popvar', 0, 100000)
	replace popcat = 4 if inrange(`popvar', 100001, 200000)
	replace popcat = 5 if inrange(`popvar', 200001, 500000)
	replace popcat = 6 if inrange(`popvar', 500001, 1000000)
	replace popcat = 7 if inrange(`popvar', 1000001, 100000000)


	collapse (mean) r6_estimate [aw=popemp_black], by(popcat year)

	twoway (line r6_estimate year if popcat==3, lc(gs11) lp(dash)) || ///
			(line r6_estimate year if popcat==4, lc(ltblue) lp(dash)) || ///
			(line r6_estimate year if popcat==5, lc(midblue) lp(solid)) || ///
			(line r6_estimate year if popcat==6, lc(blue) lp(solid)) || ///
			(line r6_estimate year if popcat==7, lc(navy) lp(solid)), ///
			yline(0, lc(black) lp(dot)) ylabel(, nogrid) xlabel(, nogrid) ///
			legend(off) ytitle("Mean Residual Difference (RRD)," "by Employed Population") xtitle("Year") ///
			text(-0.011 2005 "<100k", si(medsmall) c(gs11)) ///
			text(-0.009 2016 "[100k,200k]", si(medsmall) c(ltblue)) ///
			text(0.0357 1983.5 "(200k, 500k]", si(medsmall) c(midblue)) ///
			text(0.075 1993.5 "(500k, 1 mil.]", si(medsmall) c(blue)) ///
			text(0.124 2011 ">1 mil.", si(medsmall) c(navy))

	graph export "${DGIT}/results/${SAMPLE}/plots/rrd_by_population.png", replace
	graph export "${DGIT}/results/${SAMPLE}/plots/rrd_by_population.eps", replace
restore 
	
	
foreach n of numlist 6 {
	
	gen L4_r`n'_estimate = L4.r`n'_estimate
	
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
	graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/persistance_`n'.eps", replace
	
	
}
	

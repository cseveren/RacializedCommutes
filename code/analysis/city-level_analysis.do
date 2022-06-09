use "$ROOT/empirics/output/czyrall_blackwhite.dta", clear

sum r6_estimate [aw=popemp] if year==1980 // Measures of Delta^Unexplained
sum r6_estimate [aw=popemp] if year==2019 // Measures of Delta^Unexplained

do 	"$ROOT/empirics/code/analysis/city-level_prep.do"

export delim using "$ROOT/empirics/output/czyrall_blackwhite_cleaned.csv", replace
est clear


*************
** Table 4, Part I

estpost tabstat r6_estimate [aw=popemp_black], by(year) stat(count mean sd min max) nototal

estpost tabstat r6_estimate [aw=n_black], by(year) stat(count mean sd min max) nototal
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_summaryweights.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace

est clear
estpost tabstat r6_estimate, by(year) stat(count mean sd min max) nototal
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_summarynoweights.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace

est clear

** Table 4, Part II
estpost tabstat popemp perc_black diss gini_blk gini_wht tot_centrality_OG len_ab modeshare_anytransit time_car valueh comm_hval_corr_est [aw=n_black], stat(count mean sd min max) col(stat)
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_summaryurbanform.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace
est clear

*************
** Table 5
foreach y of numlist 1980 2019 {
	eststo: reg r6_estimate lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' & bigger==1 [aw=popemp_black], vce(cluster czone)
}

eststo: reghdfe r6_estimate lpop [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table5.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table5.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

*************
** Table 6 (just larger cities)
local explvar
foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car {
	eststo, title("`v'"): reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table6_nocontrol.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table6_nocontrol.csv", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

local explvar
foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car {
	eststo, title("`v'"): reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table6_wcontrol.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table6_wcontrol.csv", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

*************
** Table 7 (Housing IV)

eststo: reghdfe r6_estimate lhval [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lhval lpop perc_black [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: ivreghdfe r6_estimate (lhval=gurenIV_B) [aw=popemp_black], a(czone yri) cluster(czone) first 
estadd scalar cdval = `e(cdf)'
estadd scalar kpval = `e(widstat)'
eststo: ivreghdfe r6_estimate lpop perc_black (lhval=gurenIV_B) [aw=popemp_black], a(czone yri) cluster(czone) first
estadd scalar cdval = `e(cdf)'
estadd scalar kpval = `e(widstat)'
eststo: reghdfe r6_estimate comm_hval_corr_est [aw=popemp_black], a(czone yri) vce(cluster czone)

eststo: reghdfe r6_estimate lhval [aw=popemp_black] if bigger==1, a(czone yri) vce(cluster czone) 
eststo: reghdfe r6_estimate lhval lpop perc_black [aw=popemp_black] if bigger==1, a(czone yri) vce(cluster czone)
eststo: ivreghdfe r6_estimate (lhval=gurenIV_B) [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) first 
estadd scalar cdval = `e(cdf)'
estadd scalar kpval = `e(widstat)'
eststo: ivreghdfe r6_estimate lpop perc_black (lhval=gurenIV_B) [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) first
estadd scalar cdval = `e(cdf)'
estadd scalar kpval = `e(widstat)'
eststo: reghdfe r6_estimate comm_hval_corr_est [aw=popemp_black] if bigger==1, a(czone yri) vce(cluster czone)
	
	
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table7_main.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend scalar(cdval kpval)
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table7_main.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend scalar(cdval kpval)
	
est clear

** First Stage

eststo: reghdfe lhval gurenIV_B [aw=popemp_black], a(czone yri) cluster(czone) 
eststo: reghdfe lhval gurenIV_B lpop perc_black [aw=popemp_black], a(czone yri) cluster(czone) 

eststo: reghdfe lhval gurenIV_B [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) 
eststo: reghdfe lhval gurenIV_B lpop perc_black [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) 

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table7_firststage.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_table7_firststage.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend

est clear

*****Components of variation


** Note, uses different weighting scheme to maintain overall features
foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est {
	reghdfe	r6_estimate `v' [aw=popemp], a(czone year) vce(cluster czone)
	local decomp_`v' = _b[`v']
}

{
	frame create allcities
	frame change allcities	

	use "$ROOT/empirics/output/czyrall_blackwhite.dta"
	
		
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

	foreach v of varlist lmiles_ab {
		sum `v' [aw=popemp] if year==1980 
			local m1980_`v' = r(mean)
		sum `v' [aw=popemp] if year==2000 
			local m2000_`v' = r(mean)
		
		local change_`v' = `decomp_`v''*(`m2000_`v''-`m1980_`v'')
		di `change_`v''
	}
	
	foreach v of varlist gini_blk gini_wht {
		sum `v' [aw=popemp] if year==1990 
			local m1990_`v' = r(mean)
		sum `v' [aw=popemp] if year==2019 
			local m2019_`v' = r(mean)
		
		local change_`v' = `decomp_`v''*(`m2019_`v''-`m1990_`v'')
		di `change_`v''
	}
	
	foreach v of varlist diss tot_centrality_OG modeshare_anytransit time_car lhval comm_hval_corr_est {
		sum `v' [aw=popemp] if year==1980 
			local m1980_`v' = r(mean)
		sum `v' [aw=popemp] if year==2019 
			local m2019_`v' = r(mean)
		
		di `decomp_`v''
		local change_`v' = `decomp_`v''*(`m2019_`v''-`m1980_`v'')
		di `change_`v''
	}
}	

frame change default
frame drop allcities
//
// macro drop decomp_* mean_*


***** MAKE BIG APPENDIX TABLES


local clist perc_black lhval ///
			modeshare_anytransit time_anytransit time_car lmiles_a lmiles_ab ///
			diss hutchens ///
			tot_centrality_OG blk_centrality_OG wht_centrality_OG bw_diff gini_tot gini_blk gini_wht bw_gini ///
			comm_hval_corr pdiff_mean
			

foreach y of numlist 1980 2000 2019 {

	local explvar
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=n_black], vce(cluster czone)
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
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=n_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
	macro drop explvar
}


local explvar
foreach v of local clist {
	eststo, title("`v'"): reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

local explvar
foreach v of local clist {
	eststo, title("`v'"): reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear


preserve
	keep if bigger==1

	foreach y of numlist 1980 2000 2019 {

		local explvar
		
		foreach v of local clist {
			capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=n_black], vce(cluster czone)
			capture: local explvar `explvar' `v' var
		}

		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'_big.tex", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'_big.csv", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		
		est clear
		macro drop explvar
	}

	foreach y of numlist 1980 2000 2019 {

		local explvar
		
		foreach v of local clist {
			capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=n_black], vce(cluster czone)
			capture: local explvar `explvar' `v' var
		}

		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'_big.tex", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'_big.csv", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		
		est clear
		macro drop explvar
	}


	local explvar
	foreach v of local clist {
		eststo, title("`v'"): reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
		local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon_big.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon_big.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	est clear

	local explvar
	foreach v of local clist {
		eststo, title("`v'"): reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
		local explvar `explvar' `v' var
	}

	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop_big.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop_big.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	est clear
restore
















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
	
	eststo, title("Population"): 	reg r6_estimate lpop if year==`y' [aw=n_black], vce(cluster czone)
	eststo, title("p_black"): 		reg r6_estimate perc_black lpop if year==`y' [aw=n_black], vce(cluster czone)
	eststo, title("p_blackXlpop"): 	reg r6_estimate perc_black lpop c.perc_black#c.lpop if year==`y' [aw=n_black], vce(cluster czone)
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=n_black], vce(cluster czone)
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
		capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=n_black], vce(cluster czone)
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
		capture: eststo, title("`v'"): 		reg r6_estimate `v' lpop if year==`y' [aw=n_black], vce(cluster czone)
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
	eststo, title("`v'"): 		reghdfe r6_estimate `v' [aw=n_black], a(czone year) vce(cluster czone)
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
	eststo, title("`v'"): 		reghdfe r6_estimate `v' [aw=n_black], a(czone year) vce(cluster czone)
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
	eststo, title("`v'"): 		reghdfe r6_estimate `v' lpop [aw=n_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_shortpop.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_regs_panel_shortpop.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
est clear	
	
	
	/*
	
** Experiments in autocorrelation, etc.	
	pdiff_mean corr gini_tot gini_wht gini_blk gini_bw
reghdfe r6_estimate gini_blk lpop [aw=n_black], a(czone yri) vce(cluster czone) resid
	
reghdfe r6_estimate lpop [aw=n_black], a(czone yri) vce(cluster czone) resid
predict rrr, resid

reghdfe rrr l.rrr, noa vce(cluster czone)

reghdfe r6_estimate lpop lhval [aw=n_black], a(czone yri) vce(cluster czone) resid
predict rr4, resid


reghdfe rr4 l.rr4, noa vce(cluster czone)
	
reghdfe r6_estimate lpop [aw=n_black], a(czone yri) vce(cluster czone)	
reghdfe d.r6_estimate d.lpop [aw=n_black], a(yri) vce(cluster czone)	
	
reghdfe r6_estimate lpop lhval [aw=n_black], a(czone yri) vce(cluster czone)	
reghdfe d.r6_estimate d.lpop d.lhval [aw=n_black], a(yri) vce(cluster czone)	
	
/*	
** OLDER BELOW 

/*
eststo, title("Population"): 	reghdfe r6_estimate lpop [aw=n_black], a(czone year) vce(cluster czone)
eststo, title("p_black"): 		reghdfe r6_estimate perc_black lpop [aw=n_black], a(czone year) vce(cluster czone)
eststo, title("p_blackXlpop"): 	reghdfe r6_estimate perc_black lpop c.perc_black#c.lpop [aw=n_black], a(czone year) vce(cluster czone)
*/

reghdfe r6_estimate lpercblack sd_ltrantime lpop [aw=n_black], a(czone year) cluster(czone)

reghdfe r6_estimate lpercblack ltime_car c.lpercblack#c.ltime_car lpop [aw=n_black], a(czone year) cluster(czone)


reghdfe r6_estimate tot_centrality_OG lpop [aw=n_black], a(czone year) cluster(czone)
reghdfe r6_estimate tot_centrality_Alt2 lpop [aw=n_black], a(czone year) cluster(czone)

reghdfe r6_estimate lpopblack tot_centrality_OG lpop [aw=n_black], a(czone year) cluster(czone)

eststo: reghdfe r2_estimate lpop perc_black lmodeshare_anytransit ltime_anytransit ltime_car [aw=n_black], a(czone year) cluster(czone)
eststo: reghdfe r3_estimate lpop perc_black lmodeshare_anytransit ltime_anytransit ltime_car [aw=n_black], a(czone year) cluster(czone)
eststo: reghdfe r4_estimate lpop perc_black lmodeshare_anytransit ltime_anytransit ltime_car [aw=n_black], a(czone year) cluster(czone)
eststo: reghdfe r5_estimate lpop perc_black lmodeshare_anytransit ltime_anytransit ltime_car [aw=n_black], a(czone year) cluster(czone)
eststo: reghdfe r6_estimate lpop perc_black lmodeshare_anytransit ltime_anytransit ltime_car [aw=n_black], a(czone year) cluster(czone)

esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/citylevel_explanatory.tex", b(3) se(3) nocon label replace bookt f
est clear

reg r2_estimate L.r2_estimate i.year [aw=n_black], cluster(czone)

/*
** Reg Analysis /*
foreach h in 2 {
	reghdfe r`h'_estimate lpop i.year [aw=n_black], a(czone) cluster(czone)
	reghdfe r`h'_estimate perc_black i.year [aw=n_black], a(czone) cluster(czone)
	reghdfe r`h'_estimate modeshare_anytransit i.year [aw=n_black], a(czone) cluster(czone)
	reghdfe r`h'_estimate lmodeshare_anytransit i.year [aw=n_black], a(czone) cluster(czone)
	reghdfe r`h'_estimate time_anytransit i.year [aw=n_black], a(czone) cluster(czone)
	reghdfe r`h'_estimate time_car i.year [aw=n_black], a(czone) cluster(czone)
}


	twoway (scatter r3_estimate ltime_anytransit if year==1980, m(o) mc(black) ) || ///
		(lpoly r3_estimate ltime_anytransit if year==1980 [aw=n_black], lc(black) lp(solid)) || ///
		(scatter r3_estimate ltime_anytransit if year==2019, m(dh) mc(blue%80) ) || ///
		(lpoly r3_estimate ltime_anytransit if year==2019 [aw=n_black], lc(blue%80) lp(dash)), ///
		legend(pos(6) row(1) order(1 "Gaps in 1980" 3 "Gaps in 2012-19")) ///
		yline(0, lc(gray) lp(dot)) ylabel(-0.5(0.5)0.5, nogrid) xlabel(,nogrid) ///
		xtitle("Travel Time - Any Transit") ytitle("Residual Difference") yscale(range(-0.5 0.5)) note("`nlab'")
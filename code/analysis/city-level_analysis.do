
use "${DATA}/empirics/output/czyrall_blackwhite.dta", clear

sum r6_estimate [aw=popemp] if year==1980 // Measures of Delta^Unexplained
sum r6_estimate [aw=popemp] if year==2019 // Measures of Delta^Unexplained

do 	"${DGIT}/code/analysis/city-level_prep.do"

export delim using "${DATA}/empirics/output/czyrall_blackwhite_cleaned.csv", replace
est clear

keep if min_n_black>50
keep if min_popemp>=1000
keep if n_yrs==5
* leaves 1690 obs for 338 CZs *

preserve
	keep if year==1980 | year==2019
	keep czone year largestcity pop1990 min_popemp perc_black r6_estimate

	reshape wide perc_black r6_estimate, i(czone) j(year)
	order largestcity czone pop1990 min_popemp perc_black2019 perc_black1980 r6_estimate2019 r6_estimate1980, first
	gsort -pop1990
	
	keep if min_popemp>=200000
	gen r6_diff = r6_estimate2019 - r6_estimate1980
	
	gsort -r6_estimate2019
	
	egen rank2019 = rank(r6_estimate2019), track
	egen rank1980 = rank(r6_estimate1980), track
	egen rankdiff = rank(r6_diff), track
	
	keep largestcity czone r6_estimate2019 rank2019 r6_estimate1980 rank1980 r6_diff rankdiff
	order largestcity czone r6_estimate2019 rank2019 r6_estimate1980 rank1980 r6_diff rankdiff, first
	format r6_estimate2019 r6_estimate1980 r6_diff %9.3f
	
	tostring r6_estimate2019, replace format(%4.3f) force
	tostring r6_estimate1980, replace format(%4.3f) force
	tostring r6_diff, replace format(%4.3f) force
	
	texsave using "${DGIT}/results/${SAMPLE}/tables/orderedlist_rrd.tex", replace
	*dataout, save("${DGIT}/results/${SAMPLE}/tables/orderedlist_rrd.tex") tex
	*tabstat czone r6_estimate2019 rank2019 r6_estimate1980 rank1980 r6_diff rankdiff, by(largestcity)
	
restore


est clear


***********
** New Market Access Results
eststo: reghdfe r6_estimate ma_ratio_citysp [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lnma_citysp [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate ma_ratio_common_wwage [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lnma_common [aw=popemp_black], a(czone yri) vce(cluster czone)

eststo: reghdfe r6_estimate ma_ratio_citysp if bigger==1 [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lnma_citysp if bigger==1 [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate ma_ratio_common_wwage if bigger==1 [aw=popemp_black], a(czone yri) vce(cluster czone)
eststo: reghdfe r6_estimate lnma_common if bigger==1 [aw=popemp_black], a(czone yri) vce(cluster czone)

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_marketaccess_rrd.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) ///
	legend rename(ma_ratio_citysp macc lnma_citysp lmacc ma_ratio_common_wwage macc lnma_common lmacc)
est clear	

foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est {
	eststo, title("`v'"): reghdfe	ma_ratio_citysp `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_marketaccess_mechanism_all.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear
	
foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est {
	eststo, title("`v'"): reghdfe	ma_ratio_citysp `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_marketaccess_mechanism_big.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear


*************
** Summary of RDD, Part I

estpost tabstat r6_estimate [aw=popemp_black], by(year) stat(count mean sd min max) nototal
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_summaryweights_all.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace
est clear

estpost tabstat r6_estimate if bigger==1 [aw=popemp_black], by(year) stat(count mean sd min max) nototal
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_summaryweights_big.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace
est clear

estpost tabstat r6_estimate if bigger!=1 [aw=popemp_black], by(year) stat(count mean sd min max) nototal
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_summaryweights_small.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace
est clear

** Summary of RDD, Part II
/*
estpost tabstat popemp perc_black ma_ratio_citysp diss gini_blk gini_wht tot_centrality_OG len_ab modeshare_anytransit time_car valueh comm_hval_corr_est [aw=popemp_black], stat(count mean sd min max) col(stat)
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_summaryurbanform.tex", ///
	booktabs cells("count mean(fmt(3)) sd(fmt(3)) min(fmt(3)) max(fmt(3))") replace
est clear
*/
*************
** Population and Racial Composition
foreach y of numlist 1980 2019 {
	eststo: reg r6_estimate lpop if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' [aw=popemp_black], vce(cluster czone)
	eststo: reg r6_estimate lpop perc_black if year==`y' & bigger==1 [aw=popemp_black], vce(cluster czone)
}

eststo: reghdfe r6_estimate lpop [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black [aw=popemp_black], a(czone year) vce(cluster czone)
eststo: reghdfe r6_estimate lpop perc_black if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table5.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table5.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

*************
** Correlates of RRD
local explvar
foreach v of varlist ma_ratio_citysp diss tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est {
	eststo, title("`v'"): reghdfe	r6_estimate `v' if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
	
	capture sum `v' if bigger==1 & year==1980 [aw=popemp_black]
	capture estadd scalar mn1980 = `r(mean)'
	capture sum `v' if bigger==1 & year==1990 [aw=popemp_black]
	capture estadd scalar mn1990 = `r(mean)'
	capture sum `v' if bigger==1 & year==2000 [aw=popemp_black]
	capture estadd scalar mn2000 = `r(mean)'
	capture sum `v' if bigger==1 & year==2010 [aw=popemp_black]
	capture estadd scalar mn2010 = `r(mean)'
	capture sum `v' if bigger==1 & year==2019 [aw=popemp_black]
	capture estadd scalar mn2019 = `r(mean)'

}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table6_nocontrol.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend ///
	stats(mn1980 mn1990 mn2000 mn2010 mn2019 r2 N, fmt(%9.4f %9.4f %9.4f %9.4f %9.4f %9.4f %9.0g))
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table6_nocontrol.csv", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

local explvar
foreach v of varlist ma_ratio_citysp diss tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est {
	eststo, title("`v'"): reghdfe	r6_estimate `v' lpop if bigger==1 [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table6_wcontrol.tex", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table6_wcontrol.csv", ///
	rename(`explvar') b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

*************
** Housing IV

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
	
	
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table7_main.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend scalar(cdval kpval)
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table7_main.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend scalar(cdval kpval)
	
est clear

** First Stage

eststo: reghdfe lhval gurenIV_B [aw=popemp_black], a(czone yri) cluster(czone) 
eststo: reghdfe lhval gurenIV_B lpop perc_black [aw=popemp_black], a(czone yri) cluster(czone) 

eststo: reghdfe lhval gurenIV_B [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) 
eststo: reghdfe lhval gurenIV_B lpop perc_black [aw=popemp_black] if bigger==1, a(czone yri) cluster(czone) 

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table7_firststage.tex", ///
	b(4) se(4) nocon mlabels(,titles) replace bookt f legend r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_table7_firststage.csv", ///
	b(4) se(4) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend

est clear

*****Components of variation

/*
** Note, uses different weighting scheme to maintain overall features
foreach v of varlist diss gini_blk gini_wht tot_centrality_OG lmiles_ab modeshare_anytransit time_car lhval comm_hval_corr_est lnma_citysp {
	reghdfe	r6_estimate `v' [aw=popemp], a(czone year) vce(cluster czone)
	local decomp_`v' = _b[`v']
}

local vlist speed dist ma_white ma_black ratio

import delim "${DATA}/empirics/output/market_access_cityspecificelasticity.csv", clear
drop v1 niter
destring speed-ratio, i("NA") replace

foreach v of local vlist {
	rename `v' ma_`v'_citysp
}
tempfile ma_citysp
save "`ma_citysp'"

* New
{
	frame create allcities
	frame change allcities	

	use "${DATA}/empirics/output/czyrall_blackwhite.dta"
	
		
	merge 1:1 czone year using "`ma_citysp'"
	drop if _merge==2
	drop _merge

	gen lnma_citysp = ln(ma_ratio_citysp)
	
	gen yri = 1 if year==1980
	replace yri = 2 if year==1990
	replace yri = 3 if year==2000
	replace yri = 4 if year==2010
	replace yri = 5 if year==2019

	xtset czone yri
	
	foreach v of varlist lnma_citysp {
		sum `v' [aw=popemp] if year==1990 
			local m1990_`v' = r(mean)
		sum `v' [aw=popemp] if year==2019 
			local m2019_`v' = r(mean)
		
		local change_`v' = `decomp_`v''*(`m2019_`v''-`m1990_`v'')
		di `change_`v''
	}
}	

frame change default
frame drop allcities


* Older
{
	frame create allcities
	frame change allcities	

	use "${DATA}/empirics/output/czyrall_blackwhite.dta"
	
		
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
*/

***** MAKE BIG APPENDIX TABLES
** May drop in final version


local clist perc_black lhval ///
			modeshare_anytransit time_anytransit time_car lmiles_a lmiles_ab ///
			diss hutchens ///
			tot_centrality_OG blk_centrality_OG wht_centrality_OG bw_diff gini_tot gini_blk gini_wht bw_gini ///
			comm_hval_corr_est pdiff_mean
			

foreach y of numlist 1980 2000 2019 {

	local explvar
	
	foreach v of local clist {
		capture: eststo, title("`v'"): 		reg r6_estimate `v' if year==`y' [aw=n_black], vce(cluster czone)
		capture: local explvar `explvar' `v' var
	}

	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'.csv", ///
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

	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	
	est clear
	macro drop explvar
}


local explvar
foreach v of local clist {
	eststo, title("`v'"): reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon.csv", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
est clear

local explvar
foreach v of local clist {
	eststo, title("`v'"): reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
	local explvar `explvar' `v' var
}

esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop.tex", ///
	rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop.csv", ///
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

		esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'_big.tex", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_nocon_`y'_big.csv", ///
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

		esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'_big.tex", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_xsec_all_lpop_`y'_big.csv", ///
			rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
		
		est clear
		macro drop explvar
	}


	local explvar
	foreach v of local clist {
		eststo, title("`v'"): reghdfe	r6_estimate `v' [aw=popemp_black], a(czone year) vce(cluster czone)
		local explvar `explvar' `v' var
	}

	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon_big.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_nocon_big.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	est clear

	local explvar
	foreach v of local clist {
		eststo, title("`v'"): reghdfe	r6_estimate `v' lpop [aw=popemp_black], a(czone year) vce(cluster czone)
		local explvar `explvar' `v' var
	}

	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop_big.tex", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace bookt f r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	esttab using "${DGIT}/results/${SAMPLE}/tables/citylevel_regs_panel_all_lpop_big.csv", ///
		rename(`explvar') b(3) se(3) nocon mlabels(,titles) replace csv r2(3) starlevels(+ 0.10 * 0.05 ** 0.01 *** 0.001) legend
	est clear
restore


	
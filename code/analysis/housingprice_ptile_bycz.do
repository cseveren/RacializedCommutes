
clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify sample
do		"${DGIT}/code/analysis/parse_sample.do"

keep if empstat==1 
keep if empstatd==10 | empstatd==14

// Make smaller for speed/ease
drop racamind racasian racblk racpacis racwht racnum trantime czwt_tt_orig d_hisp d_aapi d_amin samp_blw samp_hiw samp_aaw samp_aiw d_completed_college d_completed_high_school d_southern_state age_bin d_white sex

drop if year_bin==1990
drop if year_bin==2000
drop if year_bin==2010

** Set up housing Vingtiles **

foreach hvar of varlist housingcost valueh rentgrs {
	
	egen hc_vigntile = xtile(`hvar'), by(czone_year_bin) n(20)

	frame create regvalues_h
	frame change regvalues_h

		gen vigntile = .
		foreach v of numlist 1/20 {
			set obs `v'
			replace vigntile = `v' if mi(vigntile)
		}
		forvalues n = 1/4 {
			gen beta_`n' = .
			gen se_`n' = .
			gen	e_df_`n' = .
		}

	frame change default

	**

	reghdfe ln_trantime 1.d_black#i.hc_vigntile ib10.hc_vigntile if year_bin==1980 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
	reghdfe, coeflegend

	frame change regvalues_h
	foreach v of numlist 1/20 {
		capture replace beta_1 = _b[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace se_1 = _se[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace e_df_1 = e(df_r) if vigntile == `v'
	}
	frame change default


	reghdfe ln_trantime 1.d_black#i.hc_vigntile ib10.hc_vigntile if year_bin==2019 [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)

	frame change regvalues_h
	foreach v of numlist 1/20 {
		capture replace beta_2 = _b[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace se_2 = _se[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace e_df_2 = e(df_r) if vigntile == `v'
	}
	frame change default


	local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
	local cargq 	d_gq d_vehinhh
	local transpo	i.tranwork_bin
	local work		linc i.inczero 
		
	reghdfe ln_trantime 1.d_black#i.hc_vigntile ib10.hc_vigntile `demog' `cargq' `transpo' `work' if year_bin==1980 [aw=czwt_tt], a(czone_year_bin occ1990 ind1990) vce(cluster czone)

	frame change regvalues_h
	foreach v of numlist 1/20 {
		capture replace beta_3 = _b[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace se_3 = _se[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace e_df_3 = e(df_r) if vigntile == `v'
	}
	frame change default

	reghdfe ln_trantime 1.d_black#i.hc_vigntile ib10.hc_vigntile `demog' `cargq' `transpo' `work' if year_bin==2019 [aw=czwt_tt], a(czone_year_bin occ1990 ind1990) vce(cluster czone)

	frame change regvalues_h
	foreach v of numlist 1/20 {
		capture replace beta_4 = _b[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace se_4 = _se[1.d_black#`v'.hc_vigntile] if vigntile == `v'
		capture replace e_df_4 = e(df_r) if vigntile == `v'
	}
	frame change default
	drop hc_vigntile
	
	**
	frame regvalues_h: save "${DATA}/empirics/data/temp_dta/${SAMPLE}/hous_`hvar'_bycz.dta", replace
	frame drop regvalues_h
}
****

foreach hvar in housingcost valueh rentgrs {
	use "${DATA}/empirics/data/temp_dta/${SAMPLE}/hous_`hvar'_bycz.dta", clear

	drop if mi(beta_1)

	reshape long beta_ se_ e_df_, i(vigntile) j(spec)
	forvalues n = 1/4 {
		replace vigntile = vigntile+(`n'-2.5)*0.07 if spec==`n'
	}
	reshape wide

	replace vigntile = vigntile*5 - 2.5

	forvalues n = 1/4 {
		gen upper_`n' = beta_`n' + invttail(e_df_`n', 0.025)*se_`n'
		gen lower_`n' = beta_`n' - invttail(e_df_`n', 0.025)*se_`n'
	}

	if "`hvar'"=="housingcost" {
		local vartitle "Housing Cost"
	} 
	else if "`hvar'"=="valueh" {
		local vartitle "House Value"
	}
	else if "`hvar'"=="rentgrs" {
		local vartitle "Rental Price"
	}
	
	twoway (rcap upper_1 lower_1 vigntile, lstyle(ci) lcolor(black%80)) ///
		(scatter beta_1 vigntile, connect(l) m(i) lstyle(solid) lcolor(black))  ///
		(rcap upper_2 lower_2 vigntile, lstyle(ci) lcolor(blue%80)) ///
		(scatter beta_2 vigntile, connect(l) m(t) mc(blue) lpattern(solid) lcolor(blue))  ///
		(rcap upper_3 lower_3 vigntile, lstyle(ci) lcolor(black%40)) ///
		(scatter beta_3 vigntile, connect(l) m(i) lstyle(solid) lcolor(black%80) lp(dash))  ///
		(rcap upper_4 lower_4 vigntile, lstyle(ci) lcolor(blue%40)) ///
		(scatter beta_4 vigntile, connect(l) m(t) mc(blue) lpattern(solid) lcolor(blue%80) lp(dash)),  ///
		ytitle("Racialized Difference") xtitle("`vartitle' Centile (20 bins within CZ)") ylabel(0[0.1]0.4, nogrid) ///
		xlabel(0(10)100,nogrid) yline(0, lc(gray) lp(dot)) ///
		legend(order(2 "1980 - Controls: CZ" 	///
					 6 "1980 - Controls: CZ + demo + cargq + mode + work"  ///
					 4 "2019 - Controls: CZ"	/// 
					 8 "2019 - Controls: CZ + demo + cargq + mode + work") rows(2) pos(6)) 
	graph export "${DGIT}/results/${SAMPLE}/plots/hous_`hvar'_bycz.png", replace
}

clear frames

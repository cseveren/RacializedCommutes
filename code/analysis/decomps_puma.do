/*******************************************************************************
Decompositions for each year_bins
*******************************************************************************/

clear all

use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify rsample
do		"$ROOT/empirics/code/analysis/parse_sample.do"

keep if year_bin>=2000
*keep if year_bin==2000
egen puma_yrbncz = group(puma_yrbn czone) // Ensures pumas are within CZs (they should be, but areal merges mess with that)
egen pwpuma_yrbncz = group(pwpuma_yr czone) // Ensures pumas are within CZs (they should be, but areal merges mess with that)
compress

/*------------------------------------------------------------------------------
	Decomposition done manually
1) Run separate regs on black and white samples
2) Save the coefficients and covariate means
3) Plug into decomposition formula

	Assuming pooled betas:
1) regress y on x1 (d_black) + x2 to get beta***
2) breaking x2 into several groups: demographics, transit, work, and CZs
3) for each subgroup:
regress x2 beta*** on x1 (black). the coefficient on x1 is how much of x1 can be explained by x2

------------------------------------------------------------------------------*/
** Method 1: POW and RES separate 
foreach y in 2000 2010 2019 {

	preserve
		keep if year_bin==`y'
		
		* HOW TO GET PUMA vs CZONE
// 		reg ln_trantime d_black [aw=czwt_tt], vce(cluster czone)
// 		reghdfe ln_trantime d_black [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
// 		reghdfe ln_trantime d_black [aw=czwt_tt], a(temppuma=puma_yrbncz) vce(cluster czone)
// 		reg temppuma d_black [aw=czwt_tt], vce(cluster czone) // THIS IS PUMA+CZONE CONTRIBUTION TO BETA
// 		reghdfe temppuma d_black [aw=czwt_tt], a(czone) vce(cluster czone) // THIS IS PUMA ONLY CONTRIBUTION TO BETA
		
		* MORE DETAILED
// 		reg ln_trantime d_black [aw=czwt_tt], vce(cluster czone)
//  		reghdfe ln_trantime d_black [aw=czwt_tt], a(czone_year_bin) vce(cluster czone)
//  		reghdfe ln_trantime d_black [aw=czwt_tt], a(temppuma_res=puma_yrbncz temppuma_pow=pwpuma_yrbncz) vce(cluster czone)
//		
// 		gen temppuma_all = temppuma_res+temppuma_pow
// 		reg temppuma_all d_black [aw=czwt_tt], vce(cluster czone) // A explained by puma, pwpuma, and cz
// 		reghdfe temppuma_res d_black [aw=czwt_tt], a(czone) vce(cluster czone) // B explained by puma
// 		reghdfe temppuma_pow d_black [aw=czwt_tt], a(czone) vce(cluster czone) // C explained by pwpuma
// 		reghdfe temppuma_all d_black [aw=czwt_tt], a(czone) vce(cluster czone) // D explained by puma and pwpuma
// 		*A - D // explained by CZ, below is reg way to get there:
//		reghdfe temppuma_all d_black [aw=czwt_tt], a(tempcz=czone) vce(cluster czone) // A explained by puma, pwpuma, and cz
//		reg tempcz d_black [aw=czwt_tt], vce(cluster czone) // This is also A - D
		
		eststo clear

// 		res_place 	a.puma_yrbncz
// 		pow_place 	a.pwpuma_yr a.ind1990 a.occ1990
// 		transpo 	i.tranwork_bin 
// 		otherstuff 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3 linc inczero 
	
		local demog female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
		local transpo i.tranwork_bin
		local work linc inczero 
		
		** Step 1: run reghdfe on full sample to estimate pooled betas, saving FEs
		foreach var in female educ_bin age age2 d_marr d_head child_1or2 child_gteq3 tranwork_bin linc inczero { 
			gen beta_`var' = .
		}
		
		eststo betas1, title("fullsample"): reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], ///
			a(beta_puma=puma_yrbncz beta_ind1990=ind1990 beta_occ1990=occ1990) vce(cluster czone)
		local explbeta = _b[d_black]
		keep if e(sample)==1
		
		foreach var in female age age2 d_marr d_head child_1or2 child_gteq3 linc inczero { 
			replace beta_`var' = _b[`var']
		}
		forvalues n = 1/4 {
			replace beta_educ_bin = _b[`n'.educ_bin] if educ_bin == `n'
		}
		foreach n in 10 30 36 37 50 60 70 {
			replace beta_tranwork_bin = _b[`n'.tranwork_bin] if tranwork_bin == `n'
		}
		gen beta_cons = _b[_cons]
		
		eststo betas0, title("baseline"): reg ln_trantime d_black [aw=czwt_tt], vce(cluster czone)
		local fullbeta = _b[d_black]
		
		est restore betas1
		estadd scalar divval = 100*(`explbeta'/`fullbeta')
		
		** Step 2: divide covariates into groups and calculate x*beta
		foreach var in female age age2 d_marr d_head child_1or2 child_gteq3 linc inczero { 
			gen xb_`var' = `var' * beta_`var'
		}
		gen xb_educ_bin=.
		forvalues n = 1/4 {
			replace xb_educ_bin = beta_educ_bin if educ_bin == `n'
		}
		gen xb_tranwork_bin=.
		foreach n in 10 30 36 37 50 60 70 {
			replace xb_tranwork_bin = beta_tranwork_bin if tranwork_bin == `n'
		}
		foreach var in puma ind1990 occ1990 {
			gen xb_`var' = beta_`var'
		}
		
		
		** Step 3: regress xb on d_black and multiply gammas by betas
		// Reg using each group (demographics, transit, work, cz)
		gen xb_demographics = xb_female + xb_educ_bin + xb_age + xb_age2 + xb_d_marr + xb_d_head + xb_child_1or2 + xb_child_gteq3 
		gen xb_transit = xb_tranwork_bin
		gen xb_work = xb_linc + xb_inczero + xb_ind1990 + xb_occ1990

		foreach group in demographics transit work puma {	
			eststo, title("`group'"): reg xb_`group' d_black [aw=czwt_tt], vce(cluster czone)
			estadd scalar divval = 100*(_b[d_black]/`fullbeta')
		}
		eststo, title("respuma_no_czone"): reghdfe xb_puma d_black [aw=czwt_tt], a(xb_czone=czone) vce(cluster czone)
		estadd scalar divval = 100*(_b[d_black]/`fullbeta')
		
		eststo, title("just_czone"): reg xb_czone d_black [aw=czwt_tt], vce(cluster czone) 
		estadd scalar divval = 100*(_b[d_black]/`fullbeta')
		
		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/decompwpuma_bygroup`y'.tex", b(3) se(3) nocon keep(*d_black*) ///
			label replace bookt f stats(divval, fmt(%9.1f))
		estout using "${ROOT}/empirics/results/${SAMPLE}/tables/decompwpuma_bygroup`y'.xls", keep(*d_black*) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) ///
			stats(r2 N, label("R-squared" "Number of Observations")) label legend replace

	restore
}


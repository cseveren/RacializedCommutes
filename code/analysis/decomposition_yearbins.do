/*******************************************************************************
Decompositions for each year_bins
*******************************************************************************/

clear all

use "${ROOT}/empirics/data/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify rsample
do		"$ROOT/empirics/code/analysis/parse_sample.do"


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

foreach y in 1980 1990 2000 2010 2019 {

	preserve
		keep if year_bin==`y'
		eststo clear

		eststo betas0, title("baseline"): reg ln_trantime d_black [aw=czwt_tt], vce(cluster czone)
		
		local fullbeta = _b[d_black]

		local demog female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
		local transpo i.tranwork_bin
		local work linc inczero 

		*reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], a(czone_year_bin ind1990 occ1990) vce(cluster czone)

		** Step 1: run reghdfe on full sample to estimate pooled betas, saving FEs
		foreach var in female educ_bin age age2 d_marr d_head child_1or2 child_gteq3 tranwork_bin linc inczero { 
			gen beta_`var' = .
		}

		eststo betas1, title("fullsample"): reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], ///
			a(beta_czone_year_bin=czone_year_bin beta_ind1990=ind1990 beta_occ1990=occ1990) vce(cluster czone)
		estadd scalar divval = 100*(_b[d_black]/`fullbeta')
			
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
		foreach var in czone_year_bin ind1990 occ1990 {
			gen xb_`var' = beta_`var'
		}


		** Step 3: regress xb on d_black and multiply gammas by betas
		// Reg using each covariate separately
		foreach var in female educ_bin age age2 d_marr d_head child_1or2 child_gteq3 tranwork_bin linc inczero czone_year_bin ind1990 occ1990 {
			eststo, title("`var'"): reg xb_`var' d_black [aw=czwt_tt], vce(cluster czone)
		}

		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/decomposition_bycovariate_`y'.tex", b(3) se(3) nocon keep(*d_black*) replace
		estout using "${ROOT}/empirics/results/${SAMPLE}/tables/decomposition_bycovariate_`y'.xls", keep(*d_black*) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) ///
			stats(r2 N, label("R-squared" "Number of Observations")) label legend replace	
		est drop est? est??

		// Reg using each group (demographics, transit, work, cz)
		gen xb_demographics = xb_female + xb_educ_bin + xb_age + xb_age2 + xb_d_marr + xb_d_head + xb_child_1or2 + xb_child_gteq3 
		gen xb_transit = xb_tranwork_bin
		gen xb_work = xb_linc + xb_inczero + xb_ind1990 + xb_occ1990
		gen xb_cz = xb_czone_year_bin 

		foreach group in demographics transit work cz {	
			eststo, title("`group'"): reg xb_`group' d_black [aw=czwt_tt], vce(cluster czone)
			estadd scalar divval = 100*(_b[d_black]/`fullbeta')
		}

		esttab using "${ROOT}/empirics/results/${SAMPLE}/tables/decomposition_bygroup`y'.tex", b(3) se(3) nocon keep(*d_black*) ///
			label replace bookt f stats(divval, fmt(%9.1f))
		estout using "${ROOT}/empirics/results/${SAMPLE}/tables/decomposition_bygroup`y'.xls", keep(*d_black*) ///
			starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par(`"="("'`")""') fmt(3))) ///
			stats(r2 N, label("R-squared" "Number of Observations")) label legend replace
		est clear

	restore
}




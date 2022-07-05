/* NEW SAMPLE AND RACE/ETHNICITY VARIABLES: 
	d_white: white
	d_black: black (including two or more races) 
	d_hisp: hispanic (any number of races)
	d_aapi: asian american and pac islander (including two or more races) 
	d_amin: american indian (including two or more races) 
	samp_blw == 1: sample only if d_white==1 or d_black==1
	samp_hiw == 1: sample only if d_white==1 or d_hisp==1
	samp_aiw == 1: sample only if d_white==1 or d_aapi==1
	samp_aiw == 1: sample only if d_white==1 or d_amin==1
  For race/ethnicity vs non-race/ethnicity models, sample includes all obs
*/	

*********************************************
** Estimate FEs by CZ-yearbin bins **

*est clear
*do "${DGIT}/code/analysis/czFEs_1A_regs.do" d_black all blacknonblack

est clear
use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
keep if samp_blw==1
keep if empstat==1


frames create resultsto czone year_bin b_resid dcz ddemog dtran dwork b0alt
/* Approach:
foreach czone_year_bin
	1. Estimate big/full regression
	2. Save e(sample)==1 for future regs and betas for decomposition
	3. Calculate gammas by multiplying betas by observed covariates
	4. Calculate projection by regressing gammas on d_black
	5. Do small regression on demeaned values 
*/

* remove if missing values
local allv d_black female educ_bin age age2 d_marr d_head child_1or2 child_gteq3 tranwork_bin linc inczero czone year_bin ind1990 occ1990 czwt_tt
foreach v of local allv {
	drop if mi(`v')
}

* generate placeholder variables for coefficients on dummy/continuous vars
foreach var in female educ_bin age age2 d_marr d_head child_1or2 child_gteq3 tranwork_bin linc inczero { 
	gen beta_`var' = .
}

** WORKING
gen one=1

sum d_black
display `r(mean)'
reghdfe ln_trantime one [aw=czwt_tt], a(test1=i.czone_year_bin#c.d_black) vce(cluster czone)
gen shifter = _b[one]
gen sh_ln_trantime = ln_trantime-shifter
drop if e(sample)!=1


preserve 
	keep if year==1980
	keep if d_black==1
	collapse (mean) test1Slope1 (sum) czwt_tt, by(czone year_bin czone_year_bin)

	drop czone_year_bin
	
	rename test1Slope1 b0
	rename czwt_tt czpop
	
	tempfile aggresults
	save "`aggresults'", replace
restore 
drop one shifter	
	
** END WORKING

* useful macros
local demog female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo i.tranwork_bin
local work linc inczero 

levelsof czone, local(czlist)
display `czlist'

quietly {
foreach cz of local czlist {

	foreach y in 1980 1990 2000 2010 2019 {

		preserve
			keep if year_bin==`y' & czone==`cz'
			eststo clear

			** Step 1-2: run reghdfe on full sample to estimate pooled betas, saving FEs and everything

			* run main model
			reghdfe sh_ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], ///
				a(beta_ind1990=ind1990 beta_occ1990=occ1990) vce(robust)
				*a(beta_czone_year_bin=czone_year_bin beta_ind1990=ind1990 beta_occ1990=occ1990) vce(cluster czone)
				
			keep if e(sample)==1
			
			local b1 = _b[d_black]
			local a_cons = _b[_cons]
			
			sum d_black [aw=czwt_tt]
			local mult=1/(1-`r(mean)')
			local b_cz = `mult'*`a_cons' // Note this will only "kind of work" bc which categories are omitted might change across regs...
			
			foreach var in female age age2 d_marr d_head child_1or2 child_gteq3 linc inczero { 
				capture replace beta_`var' = _b[`var']
			}
			forvalues n = 1/4 {
				capture replace beta_educ_bin = _b[`n'.educ_bin] if educ_bin == `n'
			}
			foreach n in 10 30 36 37 50 60 70 {
				capture replace beta_tranwork_bin = _b[`n'.tranwork_bin] if tranwork_bin == `n'
			}
			
			** Step 3a: divide covariates into groups and calculate x*beta
			foreach var in female age age2 d_marr d_head child_1or2 child_gteq3 linc inczero { 
				capture gen xb_`var' = `var' * beta_`var'
			}
			gen xb_educ_bin=.
			forvalues n = 1/4 {
				capture replace xb_educ_bin = beta_educ_bin if educ_bin == `n'
			}
			gen xb_tranwork_bin=.
			foreach n in 10 30 36 37 50 60 70 {
				capture replace xb_tranwork_bin = beta_tranwork_bin if tranwork_bin == `n'
			}
			foreach var in ind1990 occ1990 {
				capture gen xb_`var' = beta_`var'
			}

			** Step 3b: regress xb on d_black and multiply gammas by betas
			// Reg using each group (demographics, transit, work, cz)
			gegen xb_demographics = rowtotal(xb_female xb_educ_bin xb_age xb_age2 xb_d_marr xb_d_head xb_child_1or2 xb_child_gteq3)
			gen xb_transit = xb_tranwork_bin
			gegen xb_work = rowtotal(xb_linc xb_inczero xb_ind1990 xb_occ1990)

			** Step 4:
			foreach group in demographics transit work {	
				reg xb_`group' d_black [aw=czwt_tt], robust noconstant
				local b_`group' = _b[d_black]
			}
			
			*reg ln_trantime d_black [aw=czwt_tt], robust
			*local b_cz = _b[d_black]
			
			reg sh_ln_trantime d_black [aw=czwt_tt], noconstant robust
			local b0 = _b[d_black]

			frame post resultsto (`cz') (`y') (`b1') (`b_cz') (`b_demographics') (`b_transit') (`b_work') (`b0')
			est clear

		restore
	}
}
}

frame change resultsto

merge 1:1 czone year_bin using "`aggresults'"



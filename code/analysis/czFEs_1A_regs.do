
use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
keep if empstat==1 
keep if empstatd==10 | empstatd==14

gen all=1

local dvar `1'
local dsamp `2'
local dout `3'

keep if `dsamp'==1
drop all

** Macros for covariates
local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local cargq 	d_gq d_vehinhh
local transpo	i.tranwork_bin
local work		linc i.inczero 
	/* work also include ind1990 and occ1990 as absorbed FEs */

tempfile r2coeffs
tempfile r6coeffs	

tempfile lev2coeffs
tempfile lev6coeffs	
	
*Reg Col 2
quietly parmby "reg ln_trantime `dvar' [aw=czwt_tt]", by(czone_year_bin) saving("`r2coeffs'", replace)
quietly parmby "reg trantime `dvar' [aw=czwt_tt]", by(czone_year_bin) saving("`lev2coeffs'", replace)

*Reg Col 6
quietly parmby "reghdfe ln_trantime `dvar' `demog' `cargq' `transpo' `work' [aw=czwt_tt], a(ind1990 occ1990)", by(czone_year_bin) saving("`r6coeffs'", replace)
quietly parmby "reghdfe trantime `dvar' `demog' `cargq' `transpo' `work' [aw=czwt_tt], a(ind1990 occ1990)", by(czone_year_bin) saving("`lev6coeffs'", replace)

** Combining
preserve 
foreach i of numlist 2 6 {
	clear
	use "`r`i'coeffs'"
	
	keep if parm == "`dvar'"
	drop parmseq 
	
	gen czone = floor(czone_year_bin/10000)
	gen year = czone_year_bin-10000*czone
	
	capture save "${DATA}/empirics/output/czyrcoeffs_`dout'_r`i'.dta", replace
}
restore

preserve 
foreach i of numlist 2 6 {
	clear
	use "`lev`i'coeffs'"
	
	keep if parm == "`dvar'"
	drop parmseq 
	
	gen czone = floor(czone_year_bin/10000)
	gen year = czone_year_bin-10000*czone
	
	capture save "${DATA}/empirics/output/czyrcoeffs_`dout'_lev`i'.dta", replace
}
restore

foreach i of numlist 2 6 {
	clear
	use "${DATA}/empirics/output/czyrcoeffs_`dout'_r`i'.dta"
	
	gen versi = `i'
	gen verss = "r`i'_"
	
	keep czone_year_bin czone year estimate stderr p vers?
	
	tempfile rr`i'
	save "`rr`i''", replace
}

foreach i of numlist 2 6 {
	clear
	use "${DATA}/empirics/output/czyrcoeffs_`dout'_lev`i'.dta"
	
	gen versi = `i'
	gen verss = "lev`i'_"
	
	keep czone_year_bin czone year estimate stderr p vers?
	
	tempfile ll`i'
	save "`ll`i''", replace
}

clear
foreach i of numlist 2 6 {
	append using "`rr`i''"
	append using "`ll`i''"
}

drop versi
reshape wide @estimate @stderr @p, i(czone_year_bin czone year) j(verss) string

save "${DATA}/empirics/output/czyrcoeffs_`dout'_all.dta", replace
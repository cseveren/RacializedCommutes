clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify sample
do		"${DGIT}/code/analysis/parse_sample.do"

keep if empstat==1

gen other8 = 0
gen transit8 = 0

replace transit8 = 1 if (czone==19400 | /// NYC
						czone==20500 | /// Boston 
						czone==24300 | /// Chicago
						czone==19700 | /// Philadelphia
						czone==11304 | /// DC
						czone==37800 | /// SF
						czone==9100 | /// Atlanta
						czone==38300) // LA

replace other8 = 1 if (czone==33100 | /// DFW
						czone==32000 | /// Houston
						czone==7000 | /// Miami
						czone==35001 | /// Phoenix
						czone==39400 | /// Seattle
						czone==11600 | /// Detroit
						czone==38000 | /// San Diego
						czone==21501) // Twin Cities
					
keep if other8==1 | transit8==1
egen puma_yrbncz = group(puma_yrbn czone)

compress


est clear

** Macros for covariates
local demog 	female i.educ_bin age age2 d_marr d_head child_1or2 child_gteq3
local transpo	i.tranwork_bin
local work		linc i.inczero 
	/* work also include ind1990 and occ1990 as absorbed FEs */

tempfile cz_coeffs	
tempfile puma_coeffs

** Run Models
quietly parmby "reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], a(ind1990 occ1990)", by(czone_year_bin) saving("`cz_coeffs'", replace)

keep if year_bin>=2000
quietly parmby "reghdfe ln_trantime d_black `demog' `transpo' `work' [aw=czwt_tt], a(ind1990 occ1990 puma_yrbncz)", by(czone_year_bin) saving("`puma_coeffs'", replace)

use "`cz_coeffs'", clear
keep if parm == "d_black"
drop parmseq 
gen czone = floor(czone_year_bin/10000)
gen year = czone_year_bin-10000*czone
save "${DATA}/empirics/output/czyrcoeffs_bigcities_nopuma.dta", replace

use "`puma_coeffs'"
keep if parm == "d_black"
drop parmseq 
gen czone = floor(czone_year_bin/10000)
gen year = czone_year_bin-10000*czone
save "${DATA}/empirics/output/czyrcoeffs_bigcities_puma.dta", replace

use "${DATA}/empirics/output/czyrcoeffs_bigcities_nopuma.dta", clear
rename estimate est_nopuma
merge 1:1 czone_year_bin using "${DATA}/empirics/output/czyrcoeffs_bigcities_puma.dta", keepusing(estimate)
rename estimate est_puma
drop stderr dof t p min95 max95 _merge

gen czname = ""
replace czname = "NYC" if czone==19400
replace czname = "Bos." if czone==20500
replace czname = "Chic." if czone==24300
replace czname = "Phil." if czone==19700
replace czname = "DC" if czone==11304
replace czname = "SF" if czone==37800
replace czname = "Atl." if czone==9100
replace czname = "LA" if czone==38300
replace czname = "DFW" if czone==33100
replace czname = "Hous." if czone==32000
replace czname = "Miami" if czone==7000
replace czname = "Phnx." if czone==35001
replace czname = "Sea." if czone==39400
replace czname = "Det" if czone==11600
replace czname = "SD" if czone==38000
replace czname = "Minn." if czone==21501


lab def czname_alt 19400 "New York City" ///
				   20500 "Boston" ///
				   24300 "Chicago" ///
				   19700 "Philadelphia" ///
				   11304 "Wash. DC" ///
				   37800 "San Francisco" ///
				   9100 "Atlanta" ///
				   38300 "Los Angeles"  ///
				   33100 "DFW" ///
				   32000 "Houston" ///
				   7000 "Miami" ///
				   35001 "Phoenix" ///
				   39400 "Seattle" ///
				   11600 "Detroit" ///
				   38000 "San Diego" ///
				   21501 "Minn.-St Paul"

lab val czone czname_alt	

/*
twoway (line est_nopuma year if czone==19400) || ///
		(line est_puma year if czone==19400), ///
		yscale(range(0 0.2)) ylabel(0(0.05)0.2, nogrid) xlabel(, nogrid) ///
		yline(0, lc(gray) lp(dot)) legend(off)*/

twoway (line est_nopuma year) || ///
		(line est_puma year), ///
		yscale(range(0 0.2)) ylabel(0(0.05)0.25, nogrid) xlabel(1980 "1980" 2019 "2019", nogrid) ///
		xtitle("") ytitle("Residual Racialized Difference") ///
		yline(0, lc(gray) lp(dot)) legend(row(2) label(1 "Residual Racialized Difference (RRD)") label(2 "RRD with PUMA fixed effects")) ///
		by(czone, noixtick noiytick note("")) subtitle(, pos(12) margin(b=-6)) ///
		ysize(6.5) xsize(5.5)

graph export "${DGIT}/results/${SAMPLE}/plots/citylevel/bigcity_changesovertime.png", replace




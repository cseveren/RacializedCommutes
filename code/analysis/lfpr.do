clear all

use "${DATA}/empirics/output/ipums_vars_standardized.dta", clear
set scheme plotplainblind

// Specify rsample
do		"${DGIT}/code/analysis/parse_sample.do"

gen emp = inlist(empstatd, 10, 14)

keep emp year_bin d_black d_fem czwt_tt

lab def srace 0 "White" 1 "Black"
lab def sfemale  0 "Male" 1 "Female"
lab val d_black srace
lab val d_fem sfemale

levelsof year_bin, local(yrb)
foreach y of local yrb {
	sum emp if d_black==0 & d_fem==0 & year_bin==`y' [aw=czwt_tt]
	local c1_`y'=r(mean)
	local c1_`y': di %4.3f `c1_`y''
	sum emp if d_black==0 & d_fem==1 & year_bin==`y' [aw=czwt_tt]
	local c2_`y'=r(mean)
	local c2_`y': di %4.3f `c2_`y''
	sum emp if d_black==0 & year_bin==`y' [aw=czwt_tt]
	local c3_`y'=r(mean)
	local c3_`y': di %4.3f `c3_`y''
	
	sum emp if d_black==1 & d_fem==0 & year_bin==`y' [aw=czwt_tt]
	local c4_`y'=r(mean)
	local c4_`y': di %4.3f `c4_`y''
	sum emp if d_black==1 & d_fem==1 & year_bin==`y' [aw=czwt_tt]
	local c5_`y'=r(mean)
	local c5_`y': di %4.3f `c5_`y''
	sum emp if d_black==1 & year_bin==`y' [aw=czwt_tt]
	local c6_`y'=r(mean)
	local c6_`y': di %4.3f `c6_`y''
}


texdoc init "${DGIT}/results/${SAMPLE}/tables/lfpr_emp.tex", replace force
tex & White & White & White & Black & Black & Black \\
tex & Male & Female & Total & Male & Female & Total \\
tex \addlinespace \hline
foreach y of local yrb {
	tex `y' & `c1_`y'' & `c2_`y'' & `c3_`y'' & `c4_`y'' & `c5_`y'' & `c6_`y''  \\
}
texdoc close


** prep data for inclusion
local vlist speed dist ma_white ma_black ratio

import delim "${DATA}/empirics/output/market_access_cityspecificelasticity.csv", clear
drop v1 niter
destring speed-ratio, i("NA") replace

foreach v of local vlist {
	rename `v' ma_`v'_citysp
}
tempfile ma_citysp
save "`ma_citysp'"

import delim "${DATA}/empirics/output/market_access_commonelasticity.csv", clear
drop v1 niter
destring speed-ratio, i("NA") replace

foreach v of local vlist {
	rename `v' ma_`v'_common_wwage
}
tempfile ma_common
save "`ma_common'"

import delim "${DATA}/empirics/output/market_access_commonelasticity_nowage.csv", clear
drop v1 niter
destring speed-ratio, i("NA") replace

foreach v of local vlist {
	rename `v' ma_`v'_common_nwage
}
tempfile ma_common_nwage
save "`ma_common_nwage'"


use "${DATA}/empirics/output/czyrall_blackwhite.dta", clear


merge 1:1 czone year using "`ma_citysp'"
drop if _merge==2
drop _merge
merge 1:1 czone year using "`ma_common'"
drop if _merge==2
drop _merge
merge 1:1 czone year using "`ma_common_nwage'"
drop if _merge==2
drop _merge


save "${DATA}/empirics/output/czyrall_blackwhite.dta", replace


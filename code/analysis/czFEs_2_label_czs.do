** 2Balt add in largest city name from czlma903.xls

import excel using "${DATA}/empirics/input/crosswalks/cz_names/czlma903.xls", clear firstrow

rename NameoflargestplaceinCommuti LargestCity
rename CZ90 czone
destring czone, replace

do		"${DGIT}/code/build/0A_czone_mergers.do"

replace LargestCity = "New York city, NY (and Newark, NJ)" if czone==19400
replace LargestCity = "Dallas, TX (and Forth Worth, TX)" if czone==33100
replace LargestCity = "Philadelphia, PA (and Wilmington, DE)" if czone==19700
replace LargestCity = "Charlotte, NC (and Gastonia, NC)" if czone==900
replace LargestCity = "Hickory, NC (and Boone, NC)" if czone==1100

preserve
	keep czone LargestCity
	duplicates drop czone, force
	tempfile namescodes
	save "`namescodes'", replace
restore

drop CountyFIPSCode CountyName Distance CZ80 MSA1993 MSAName StatePlaceCode LargestCity

destring RuralurbanContinuumCode1993, replace

collapse (rawsum) Population1990 (mean) RuralurbanContinuumCode1993 [aw=Population1990], by(czone)

merge 1:1 czone using "`namescodes'"
drop _merge

tempfile zonenames
save "`zonenames'", replace

export delimited "${DATA}/empirics/output/cz_names.csv", replace

clear

foreach ff in blacknonblack blackwhite {
	use "${DATA}/empirics/output/czyrcoeffs_`ff'_all.dta"

	merge m:1 czone using "`zonenames'"
	drop _merge

	save, replace
	clear
}
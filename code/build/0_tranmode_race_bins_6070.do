use		"$ROOT\empirics\input\ipums60-70\ipums1960-1970.dta", clear

drop serial region statefip puma gqtype gqtyped farm ownershp ///	
			ownershpd rentgrs costelec costgas costwatr costfuel ///
			valueh bedrooms ncouples nmothers nfathers multgen ///
			multgend pernum famsize nchild eldch yngch relate /// 	
			related school educ educd empstat labforce occ1950 ///
			occ1990 occ2010 ind1950 ind1990 wkswork2 looking ///
			inctot ftotinc incwage poverty movedin
			
**Transpo Mode Bins**

/** Categories:
		10 : Private Motor Vehicle (Auto, Motorcycle, Taxi)
		30 : Bus or Streetcar (including Trolley and Light Rail)
		36 : Subway or Elevated
		37 : Railroad (Long-distance Train or Commuter Train)
		50 : Bicycle
		60 : Walked Only
		70 : Other
	
	** No bicycle mode for 1960 & 1970 **
*/	
drop if tranwork==80 | tranwork==0

gen tranwork_bin = tranwork

replace tranwork_bin = 10 if tranwork==11 | tranwork==12 | tranwork==13 | tranwork == 38
replace tranwork_bin = 30 if tranwork==33

lab def tranwork_1b 10 "Private Motor Vehicle" 30 "Bus or Streetcar" ///
					36 "Subway or Elevated" 37 "Railroad" ///
					50 "Bicycle" 60 "Walked Only" 70 "Other"

lab val tranwork_bin tranwork_1b	

gen modeshare_car = (tranwork_bin==10)
gen modeshare_bus = (tranwork_bin==30)
gen modeshare_subway = (tranwork_bin==36)
gen modeshare_railroad = (tranwork_bin==37)
gen modeshare_walked = (tranwork_bin==60)
gen modeshare_other = (tranwork_bin==70)

gen modeshare_anytransit = max(modeshare_bus, modeshare_subway, modeshare_railroad)


**Race Variables**

gen race_bin = race
replace race_bin = 4 if race==4 | race==5 | race==6

lab def race_lab 1 "White" 2 "Black" 3 "American Indian" 4 "Asian" 7 "Other"
lab val race_bin race_lab

**Collapse

collapse (mean) modeshare_* [aw=perwt], by(year race_bin)
keep if race_bin==1 | race_bin==2
gen d_black=(race_bin==2)

save 	"$ROOT/empirics/output/modeshare_1960_1970.dta", replace
clear
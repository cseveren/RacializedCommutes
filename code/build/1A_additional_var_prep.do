replace age = 90 if age>90 & !mi(age)

capture gen ln_trantime = ln(trantime)
capture gen age2 = age^2
capture gen female = sex

** AGE BINS **
gen age_bin = cond(age <= 29, 2, ///
			   cond(age <= 39, 3, ///
			   cond(age <= 49, 4, ///
			   cond(age <= 100, 5, 9))))
			   
lab def age_lb 2 "18-29" 3 "30-39" 4 "40-49" 5 "50+" 9 "INVESTIGATE"
lab val age_bin age_lb

** EDUCATION BINS **
gen educ_bin = 1 if educ == 0 | educ == 1 | educ == 2 | ///
								  educ == 3 | educ == 4 | educ == 5 
replace educ_bin = 2 if educ == 6 | educ == 7 | educ == 8 | educ == 9 
replace educ_bin = 3 if educ == 10
replace educ_bin = 4 if educ == 11

lab def educ_lb 1 "less than HS" 2 "HS" 3 "College" 4 "Professional/Graduate"
lab val educ_bin educ_lb	

gen d_completed_college = educ
replace d_completed_college = 1 if educ == 10 | educ == 11
replace d_completed_college = 0 if educ != 10 & educ != 11

gen d_completed_high_school = educ
replace d_completed_high_school = 1 if educ >= 6 & educ <= 11
replace d_completed_high_school = 0 if educ < 6 | educ > 11

** TRANSPO MODE BINS **
	/* UPDATED FOR 2019 and LATER VINTAGES */

drop if tranwork == 80     // remove worked at home

/** Categories:
		10 : Private Motor Vehicle (Auto, Motorcycle, Taxi)
		30 : Bus or Streetcar (including Trolley and Light Rail)
		36 : Subway or Elevated
		37 : Railroad (Long-distance Train or Commuter Train)
		50 : Bicycle
		60 : Walked Only
		70 : Other
*/		

gen tranwork_bin = tranwork

replace tranwork_bin = 10 if tranwork == 11 | tranwork == 14 | tranwork == 15 | tranwork == 20 | tranwork == 38
replace tranwork_bin = 30 if tranwork == 31 | tranwork == 32 | tranwork == 33 | tranwork == 34 | tranwork == 35    
replace tranwork_bin = 70 if tranwork == 39

lab def tranwork_1b 10 "Private Motor Vehicle" 30 "Bus or Streetcar" ///
					36 "Subway or Elevated" 37 "Railroad" 			///
					50 "Bicycle" 60 "Walked Only" 70 "Other"

lab val tranwork_bin tranwork_1b	

** OTHER DEMOGRAPHICS **

//gender
gen		d_fem = 0
replace	d_fem = 1 if sex==1

// children
gen child_1or2 = (nchild==1 | nchild==2)
gen child_gteq3 = (nchild>=3)


//marital + hh status
gen		d_marr = 0
replace d_marr = 1 if marst==1 | marst==2

gen		d_head = 0
replace d_head = 1 if relate==1 & relate!=.

gen		d_spouse = 0
replace d_spouse = 1 if relate==2 & relate!=.


** DEAL WITH WAGE DIFFERENCES **
drop if mi(incwage)
gen  	inczero = incwage==0
gen 	linc = ln(incwage)
replace linc = 0 if linc==.
	

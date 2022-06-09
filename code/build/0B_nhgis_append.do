
clear
cls

import delimited "$ROOT\empirics\input\nhgis\data\all_1980.csv"

tostring year, replace

replace white = "." if white == "NA"
destring white, replace

replace black = "." if black == "NA"
destring black, replace

replace totalhousingunits = "." if totalhousingunits == "NA"
destring totalhousingunits, replace

replace hispanicoriginbyracecount = "." if hispanicoriginbyracecount == "NA"
destring hispanicoriginbyracecount, replace

replace totalpopulation = "." if totalpopulation == "NA"
destring totalpopulation, replace

replace structurebuilt = "." if structurebuilt == "NA"
destring structurebuilt, replace 

tempfile 1980
save "`1980'", replace

clear

import delimited "$ROOT\empirics\input\nhgis\data\all_1990.csv"

tostring year, replace

tempfile 1990
save "`1990'", replace

clear

import delimited "$ROOT\empirics\input\nhgis\data\all_2000.csv"

tostring year, replace

tempfile 2000
save "`2000'", replace

clear

import delimited "$ROOT\empirics\input\nhgis\data\acs_2006_2010.csv"

tempfile acs_2006_2010
save "`acs_2006_2010'"

clear

import delimited "$ROOT\empirics\input\nhgis\data\acs_2014_2018.csv"

append using "`acs_2006_2010'"
append using "`2000'"
append using "`1990'"
append using "`1980'", force

// save "$ROOT\empirics\input\nhgis\data\demographic_housing_data"


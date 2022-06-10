/*******************************************************************************
Appends the NHGIS files with median housing prices and median/mean commute times
*******************************************************************************/

// Crosswalk file for tract: nhgis0001_ts_nominal_tract.do

clear

// Housing prices
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds104_1980_tract.do"
tempfile 1980
save `1980', replace
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds120_1990_tract.do"
tempfile 1990
save `1990', replace

// Commute times
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds107_1980_tract.do"
tempfile 1980
save `1980', replace
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds123_1990_tract.do"
tempfile 1990
save `1990', replace

// Both housing prices and commute times
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds151_2000_tract.do"
tempfile 2000
save `2000', replace
do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds176_20105_2010_tract.do"
tempfile 2006_2010
save `2006_2010', replace

do "${ROOT}/empirics/data/nhgis0001_fixed/nhgis0001_ds244_20195_2019_tract.do"
tempfile 2015_2019
save `2015_2019', replace








* NOTE: You need to set the Stata working directory to the path
* where the data file is located.

set more off

clear
quietly infix              ///
  int     year      1-4    ///
  long    sample    5-10   ///
  double  serial    11-18  ///
  double  cbserial  19-31  ///
  double  hhwt      32-41  ///
  double  cluster   42-54  ///
  double  strata    55-66  ///
  byte    gq        67-67  ///
  byte    rooms     68-69  ///
  byte    builtyr   70-70  ///
  byte    builtyr2  71-72  ///
  byte    bedrooms  73-74  ///
  byte    autos     75-75  ///
  byte    trucks    76-76  ///
  byte    vehicles  77-77  ///
  int     pernum    78-81  ///
  double  perwt     82-91  ///
  byte    sex       92-92  ///
  int     age       93-95  ///
  using "${DATA}/empirics/input/ipums_carinhh/usa_00038.dat"

replace hhwt     = hhwt     / 100
replace perwt    = perwt    / 100

format serial   %8.0f
format cbserial %13.0f
format hhwt     %10.2f
format cluster  %13.0f
format strata   %12.0f
format perwt    %10.2f

label var year     `"Census year"'
label var sample   `"IPUMS sample identifier"'
label var serial   `"Household serial number"'
label var cbserial `"Original Census Bureau household serial number"'
label var hhwt     `"Household weight"'
label var cluster  `"Household cluster for variance estimation"'
label var strata   `"Household strata for variance estimation"'
label var gq       `"Group quarters status"'
label var rooms    `"Number of rooms"'
label var builtyr  `"Age of structure"'
label var builtyr2 `"Age of structure, decade"'
label var bedrooms `"Number of bedrooms"'
label var autos    `"Automobiles available"'
label var trucks   `"Trucks and vans available"'
label var vehicles `"Vehicles available"'
label var pernum   `"Person number in sample unit"'
label var perwt    `"Person weight"'
label var sex      `"Sex"'
label var age      `"Age"'

label define year_lbl 1850 `"1850"'
label define year_lbl 1860 `"1860"', add
label define year_lbl 1870 `"1870"', add
label define year_lbl 1880 `"1880"', add
label define year_lbl 1900 `"1900"', add
label define year_lbl 1910 `"1910"', add
label define year_lbl 1920 `"1920"', add
label define year_lbl 1930 `"1930"', add
label define year_lbl 1940 `"1940"', add
label define year_lbl 1950 `"1950"', add
label define year_lbl 1960 `"1960"', add
label define year_lbl 1970 `"1970"', add
label define year_lbl 1980 `"1980"', add
label define year_lbl 1990 `"1990"', add
label define year_lbl 2000 `"2000"', add
label define year_lbl 2001 `"2001"', add
label define year_lbl 2002 `"2002"', add
label define year_lbl 2003 `"2003"', add
label define year_lbl 2004 `"2004"', add
label define year_lbl 2005 `"2005"', add
label define year_lbl 2006 `"2006"', add
label define year_lbl 2007 `"2007"', add
label define year_lbl 2008 `"2008"', add
label define year_lbl 2009 `"2009"', add
label define year_lbl 2010 `"2010"', add
label define year_lbl 2011 `"2011"', add
label define year_lbl 2012 `"2012"', add
label define year_lbl 2013 `"2013"', add
label define year_lbl 2014 `"2014"', add
label define year_lbl 2015 `"2015"', add
label define year_lbl 2016 `"2016"', add
label define year_lbl 2017 `"2017"', add
label define year_lbl 2018 `"2018"', add
label define year_lbl 2019 `"2019"', add
label define year_lbl 2020 `"2020"', add
label values year year_lbl

label define sample_lbl 202004 `"2016-2020, PRCS 5-year"'
label define sample_lbl 202003 `"2016-2020, ACS 5-year"', add
label define sample_lbl 202001 `"2020 ACS"', add
label define sample_lbl 201904 `"2015-2019, PRCS 5-year"', add
label define sample_lbl 201903 `"2015-2019, ACS 5-year"', add
label define sample_lbl 201902 `"2019 PRCS"', add
label define sample_lbl 201901 `"2019 ACS"', add
label define sample_lbl 201804 `"2014-2018, PRCS 5-year"', add
label define sample_lbl 201803 `"2014-2018, ACS 5-year"', add
label define sample_lbl 201802 `"2018 PRCS"', add
label define sample_lbl 201801 `"2018 ACS"', add
label define sample_lbl 201704 `"2013-2017, PRCS 5-year"', add
label define sample_lbl 201703 `"2013-2017, ACS 5-year"', add
label define sample_lbl 201702 `"2017 PRCS"', add
label define sample_lbl 201701 `"2017 ACS"', add
label define sample_lbl 201604 `"2012-2016, PRCS 5-year"', add
label define sample_lbl 201603 `"2012-2016, ACS 5-year"', add
label define sample_lbl 201602 `"2016 PRCS"', add
label define sample_lbl 201601 `"2016 ACS"', add
label define sample_lbl 201504 `"2011-2015, PRCS 5-year"', add
label define sample_lbl 201503 `"2011-2015, ACS 5-year"', add
label define sample_lbl 201502 `"2015 PRCS"', add
label define sample_lbl 201501 `"2015 ACS"', add
label define sample_lbl 201404 `"2010-2014, PRCS 5-year"', add
label define sample_lbl 201403 `"2010-2014, ACS 5-year"', add
label define sample_lbl 201402 `"2014 PRCS"', add
label define sample_lbl 201401 `"2014 ACS"', add
label define sample_lbl 201306 `"2009-2013, PRCS 5-year"', add
label define sample_lbl 201305 `"2009-2013, ACS 5-year"', add
label define sample_lbl 201304 `"2011-2013, PRCS 3-year"', add
label define sample_lbl 201303 `"2011-2013, ACS 3-year"', add
label define sample_lbl 201302 `"2013 PRCS"', add
label define sample_lbl 201301 `"2013 ACS"', add
label define sample_lbl 201206 `"2008-2012, PRCS 5-year"', add
label define sample_lbl 201205 `"2008-2012, ACS 5-year"', add
label define sample_lbl 201204 `"2010-2012, PRCS 3-year"', add
label define sample_lbl 201203 `"2010-2012, ACS 3-year"', add
label define sample_lbl 201202 `"2012 PRCS"', add
label define sample_lbl 201201 `"2012 ACS"', add
label define sample_lbl 201106 `"2007-2011, PRCS 5-year"', add
label define sample_lbl 201105 `"2007-2011, ACS 5-year"', add
label define sample_lbl 201104 `"2009-2011, PRCS 3-year"', add
label define sample_lbl 201103 `"2009-2011, ACS 3-year"', add
label define sample_lbl 201102 `"2011 PRCS"', add
label define sample_lbl 201101 `"2011 ACS"', add
label define sample_lbl 201008 `"2010 Puerto Rico 10%"', add
label define sample_lbl 201007 `"2010 10%"', add
label define sample_lbl 201006 `"2006-2010, PRCS 5-year"', add
label define sample_lbl 201005 `"2006-2010, ACS 5-year"', add
label define sample_lbl 201004 `"2008-2010, PRCS 3-year"', add
label define sample_lbl 201003 `"2008-2010, ACS 3-year"', add
label define sample_lbl 201002 `"2010 PRCS"', add
label define sample_lbl 201001 `"2010 ACS"', add
label define sample_lbl 200906 `"2005-2009, PRCS 5-year"', add
label define sample_lbl 200905 `"2005-2009, ACS 5-year"', add
label define sample_lbl 200904 `"2007-2009, PRCS 3-year"', add
label define sample_lbl 200903 `"2007-2009, ACS 3-year"', add
label define sample_lbl 200902 `"2009 PRCS"', add
label define sample_lbl 200901 `"2009 ACS"', add
label define sample_lbl 200804 `"2006-2008, PRCS 3-year"', add
label define sample_lbl 200803 `"2006-2008, ACS 3-year"', add
label define sample_lbl 200802 `"2008 PRCS"', add
label define sample_lbl 200801 `"2008 ACS"', add
label define sample_lbl 200704 `"2005-2007, PRCS 3-year"', add
label define sample_lbl 200703 `"2005-2007, ACS 3-year"', add
label define sample_lbl 200702 `"2007 PRCS"', add
label define sample_lbl 200701 `"2007 ACS"', add
label define sample_lbl 200602 `"2006 PRCS"', add
label define sample_lbl 200601 `"2006 ACS"', add
label define sample_lbl 200502 `"2005 PRCS"', add
label define sample_lbl 200501 `"2005 ACS"', add
label define sample_lbl 200401 `"2004 ACS"', add
label define sample_lbl 200301 `"2003 ACS"', add
label define sample_lbl 200201 `"2002 ACS"', add
label define sample_lbl 200101 `"2001 ACS"', add
label define sample_lbl 200008 `"2000 Puerto Rico 1%"', add
label define sample_lbl 200007 `"2000 1%"', add
label define sample_lbl 200006 `"2000 Puerto Rico 1% sample (old version)"', add
label define sample_lbl 200005 `"2000 Puerto Rico 5%"', add
label define sample_lbl 200004 `"2000 ACS"', add
label define sample_lbl 200003 `"2000 Unweighted 1%"', add
label define sample_lbl 200002 `"2000 1% sample (old version)"', add
label define sample_lbl 200001 `"2000 5%"', add
label define sample_lbl 199007 `"1990 Puerto Rico 1%"', add
label define sample_lbl 199006 `"1990 Puerto Rico 5%"', add
label define sample_lbl 199005 `"1990 Labor Market Area"', add
label define sample_lbl 199004 `"1990 Elderly"', add
label define sample_lbl 199003 `"1990 Unweighted 1%"', add
label define sample_lbl 199002 `"1990 1%"', add
label define sample_lbl 199001 `"1990 5%"', add
label define sample_lbl 198007 `"1980 Puerto Rico 1%"', add
label define sample_lbl 198006 `"1980 Puerto Rico 5%"', add
label define sample_lbl 198005 `"1980 Detailed metro/non-metro"', add
label define sample_lbl 198004 `"1980 Labor Market Area"', add
label define sample_lbl 198003 `"1980 Urban/Rural"', add
label define sample_lbl 198002 `"1980 1%"', add
label define sample_lbl 198001 `"1980 5%"', add
label define sample_lbl 197009 `"1970 Puerto Rico Neighborhood"', add
label define sample_lbl 197008 `"1970 Puerto Rico Municipio"', add
label define sample_lbl 197007 `"1970 Puerto Rico State"', add
label define sample_lbl 197006 `"1970 Form 2 Neighborhood"', add
label define sample_lbl 197005 `"1970 Form 1 Neighborhood"', add
label define sample_lbl 197004 `"1970 Form 2 Metro"', add
label define sample_lbl 197003 `"1970 Form 1 Metro"', add
label define sample_lbl 197002 `"1970 Form 2 State"', add
label define sample_lbl 197001 `"1970 Form 1 State"', add
label define sample_lbl 196002 `"1960 5%"', add
label define sample_lbl 196001 `"1960 1%"', add
label define sample_lbl 195001 `"1950 1%"', add
label define sample_lbl 194002 `"1940 100% database"', add
label define sample_lbl 194001 `"1940 1%"', add
label define sample_lbl 193004 `"1930 100% database"', add
label define sample_lbl 193003 `"1930 Puerto Rico"', add
label define sample_lbl 193002 `"1930 5%"', add
label define sample_lbl 193001 `"1930 1%"', add
label define sample_lbl 192003 `"1920 100% database"', add
label define sample_lbl 192002 `"1920 Puerto Rico sample"', add
label define sample_lbl 192001 `"1920 1%"', add
label define sample_lbl 191004 `"1910 100% database"', add
label define sample_lbl 191003 `"1910 1.4% sample with oversamples"', add
label define sample_lbl 191002 `"1910 1%"', add
label define sample_lbl 191001 `"1910 Puerto Rico"', add
label define sample_lbl 190004 `"1900 100% database"', add
label define sample_lbl 190003 `"1900 1% sample with oversamples"', add
label define sample_lbl 190002 `"1900 1%"', add
label define sample_lbl 190001 `"1900 5%"', add
label define sample_lbl 188003 `"1880 100% database"', add
label define sample_lbl 188002 `"1880 10%"', add
label define sample_lbl 188001 `"1880 1%"', add
label define sample_lbl 187003 `"1870 100% database"', add
label define sample_lbl 187002 `"1870 1% sample with black oversample"', add
label define sample_lbl 187001 `"1870 1%"', add
label define sample_lbl 186003 `"1860 100% database"', add
label define sample_lbl 186002 `"1860 1% sample with black oversample"', add
label define sample_lbl 186001 `"1860 1%"', add
label define sample_lbl 185002 `"1850 100% database"', add
label define sample_lbl 185001 `"1850 1%"', add
label values sample sample_lbl

label define gq_lbl 0 `"Vacant unit"'
label define gq_lbl 1 `"Households under 1970 definition"', add
label define gq_lbl 2 `"Additional households under 1990 definition"', add
label define gq_lbl 3 `"Group quarters--Institutions"', add
label define gq_lbl 4 `"Other group quarters"', add
label define gq_lbl 5 `"Additional households under 2000 definition"', add
label define gq_lbl 6 `"Fragment"', add
label values gq gq_lbl

label define rooms_lbl 00 `"N/A"'
label define rooms_lbl 01 `"1 room"', add
label define rooms_lbl 02 `"2"', add
label define rooms_lbl 03 `"3"', add
label define rooms_lbl 04 `"4"', add
label define rooms_lbl 05 `"5"', add
label define rooms_lbl 06 `"6"', add
label define rooms_lbl 07 `"7"', add
label define rooms_lbl 08 `"8"', add
label define rooms_lbl 09 `"9 (9+, 1960-2007)"', add
label define rooms_lbl 10 `"10"', add
label define rooms_lbl 11 `"11"', add
label define rooms_lbl 12 `"12"', add
label define rooms_lbl 13 `"13"', add
label define rooms_lbl 14 `"14"', add
label define rooms_lbl 15 `"15"', add
label define rooms_lbl 16 `"16"', add
label define rooms_lbl 17 `"17"', add
label define rooms_lbl 18 `"18"', add
label define rooms_lbl 19 `"19"', add
label define rooms_lbl 20 `"20"', add
label define rooms_lbl 21 `"21"', add
label define rooms_lbl 22 `"22"', add
label define rooms_lbl 23 `"23"', add
label define rooms_lbl 24 `"24"', add
label define rooms_lbl 25 `"25"', add
label define rooms_lbl 26 `"26"', add
label define rooms_lbl 27 `"27"', add
label define rooms_lbl 30 `"30"', add
label values rooms rooms_lbl

label define builtyr_lbl 0 `"N/A"'
label define builtyr_lbl 1 `"0-1 year old"', add
label define builtyr_lbl 2 `"2-5 years"', add
label define builtyr_lbl 3 `"6-10 years"', add
label define builtyr_lbl 4 `"11-20 years"', add
label define builtyr_lbl 5 `"21-30 years"', add
label define builtyr_lbl 6 `"31-40 years (31+ in 1960, 1970)"', add
label define builtyr_lbl 7 `"41-50 years (41+ in 1980)"', add
label define builtyr_lbl 8 `"51-60 years (51+ in 1990)"', add
label define builtyr_lbl 9 `"61+ years"', add
label values builtyr builtyr_lbl

label define builtyr2_lbl 00 `"N/A"'
label define builtyr2_lbl 01 `"1939 or earlier"', add
label define builtyr2_lbl 02 `"1940-1949"', add
label define builtyr2_lbl 03 `"1950-1959"', add
label define builtyr2_lbl 04 `"1960-1969"', add
label define builtyr2_lbl 05 `"1970-1979"', add
label define builtyr2_lbl 06 `"1980-1989"', add
label define builtyr2_lbl 07 `"1990-1994 (1990-1999 in the 2005-onward ACS and the PRCS)"', add
label define builtyr2_lbl 08 `"1995-1999 (1995-1998 in the 2000-2002 ACS)"', add
label define builtyr2_lbl 09 `"2000-2004 (1999-2002 in the 2000-2002 ACS)"', add
label define builtyr2_lbl 10 `"2005 (2005 or later in datasets containing 2005, 2006, or 2007 ACS/PRCS data)"', add
label define builtyr2_lbl 11 `"2006"', add
label define builtyr2_lbl 12 `"2007"', add
label define builtyr2_lbl 13 `"2008"', add
label define builtyr2_lbl 14 `"2009"', add
label define builtyr2_lbl 15 `"2010"', add
label define builtyr2_lbl 16 `"2011"', add
label define builtyr2_lbl 17 `"2012"', add
label define builtyr2_lbl 18 `"2013"', add
label define builtyr2_lbl 19 `"2014"', add
label define builtyr2_lbl 20 `"2015"', add
label define builtyr2_lbl 21 `"2016"', add
label define builtyr2_lbl 22 `"2017"', add
label define builtyr2_lbl 23 `"2018"', add
label define builtyr2_lbl 24 `"2019"', add
label define builtyr2_lbl 25 `"2020"', add
label values builtyr2 builtyr2_lbl

label define bedrooms_lbl 00 `"N/A"'
label define bedrooms_lbl 01 `"No bedrooms"', add
label define bedrooms_lbl 02 `"1"', add
label define bedrooms_lbl 03 `"2"', add
label define bedrooms_lbl 04 `"3"', add
label define bedrooms_lbl 05 `"4 (1970-2000, 2000-2007 ACS/PRCS)"', add
label define bedrooms_lbl 06 `"5+ (1970-2000, 2000-2007 ACS/PRCS)"', add
label define bedrooms_lbl 07 `"6"', add
label define bedrooms_lbl 08 `"7"', add
label define bedrooms_lbl 09 `"8"', add
label define bedrooms_lbl 10 `"9"', add
label define bedrooms_lbl 11 `"10"', add
label define bedrooms_lbl 12 `"11"', add
label define bedrooms_lbl 13 `"12"', add
label define bedrooms_lbl 14 `"13"', add
label define bedrooms_lbl 15 `"14"', add
label define bedrooms_lbl 16 `"15"', add
label define bedrooms_lbl 17 `"16"', add
label define bedrooms_lbl 18 `"17"', add
label define bedrooms_lbl 19 `"18"', add
label define bedrooms_lbl 20 `"19"', add
label define bedrooms_lbl 21 `"20"', add
label define bedrooms_lbl 22 `"21"', add
label values bedrooms bedrooms_lbl

label define autos_lbl 0 `"N/A"'
label define autos_lbl 1 `"No automobile"', add
label define autos_lbl 2 `"1"', add
label define autos_lbl 3 `"2"', add
label define autos_lbl 4 `"3+"', add
label values autos autos_lbl

label define trucks_lbl 0 `"N/A"'
label define trucks_lbl 1 `"No trucks or vans"', add
label define trucks_lbl 2 `"1 available"', add
label define trucks_lbl 3 `"2"', add
label define trucks_lbl 4 `"3+"', add
label values trucks trucks_lbl

label define vehicles_lbl 0 `"N/A"'
label define vehicles_lbl 1 `"1 available"', add
label define vehicles_lbl 2 `"2"', add
label define vehicles_lbl 3 `"3"', add
label define vehicles_lbl 4 `"4"', add
label define vehicles_lbl 5 `"5"', add
label define vehicles_lbl 6 `"6 (6+, 2000, ACS and PRCS)"', add
label define vehicles_lbl 7 `"7+"', add
label define vehicles_lbl 9 `"No vehicles available"', add
label values vehicles vehicles_lbl

label define sex_lbl 1 `"Male"'
label define sex_lbl 2 `"Female"', add
label values sex sex_lbl

label define age_lbl 000 `"Less than 1 year old"'
label define age_lbl 001 `"1"', add
label define age_lbl 002 `"2"', add
label define age_lbl 003 `"3"', add
label define age_lbl 004 `"4"', add
label define age_lbl 005 `"5"', add
label define age_lbl 006 `"6"', add
label define age_lbl 007 `"7"', add
label define age_lbl 008 `"8"', add
label define age_lbl 009 `"9"', add
label define age_lbl 010 `"10"', add
label define age_lbl 011 `"11"', add
label define age_lbl 012 `"12"', add
label define age_lbl 013 `"13"', add
label define age_lbl 014 `"14"', add
label define age_lbl 015 `"15"', add
label define age_lbl 016 `"16"', add
label define age_lbl 017 `"17"', add
label define age_lbl 018 `"18"', add
label define age_lbl 019 `"19"', add
label define age_lbl 020 `"20"', add
label define age_lbl 021 `"21"', add
label define age_lbl 022 `"22"', add
label define age_lbl 023 `"23"', add
label define age_lbl 024 `"24"', add
label define age_lbl 025 `"25"', add
label define age_lbl 026 `"26"', add
label define age_lbl 027 `"27"', add
label define age_lbl 028 `"28"', add
label define age_lbl 029 `"29"', add
label define age_lbl 030 `"30"', add
label define age_lbl 031 `"31"', add
label define age_lbl 032 `"32"', add
label define age_lbl 033 `"33"', add
label define age_lbl 034 `"34"', add
label define age_lbl 035 `"35"', add
label define age_lbl 036 `"36"', add
label define age_lbl 037 `"37"', add
label define age_lbl 038 `"38"', add
label define age_lbl 039 `"39"', add
label define age_lbl 040 `"40"', add
label define age_lbl 041 `"41"', add
label define age_lbl 042 `"42"', add
label define age_lbl 043 `"43"', add
label define age_lbl 044 `"44"', add
label define age_lbl 045 `"45"', add
label define age_lbl 046 `"46"', add
label define age_lbl 047 `"47"', add
label define age_lbl 048 `"48"', add
label define age_lbl 049 `"49"', add
label define age_lbl 050 `"50"', add
label define age_lbl 051 `"51"', add
label define age_lbl 052 `"52"', add
label define age_lbl 053 `"53"', add
label define age_lbl 054 `"54"', add
label define age_lbl 055 `"55"', add
label define age_lbl 056 `"56"', add
label define age_lbl 057 `"57"', add
label define age_lbl 058 `"58"', add
label define age_lbl 059 `"59"', add
label define age_lbl 060 `"60"', add
label define age_lbl 061 `"61"', add
label define age_lbl 062 `"62"', add
label define age_lbl 063 `"63"', add
label define age_lbl 064 `"64"', add
label define age_lbl 065 `"65"', add
label define age_lbl 066 `"66"', add
label define age_lbl 067 `"67"', add
label define age_lbl 068 `"68"', add
label define age_lbl 069 `"69"', add
label define age_lbl 070 `"70"', add
label define age_lbl 071 `"71"', add
label define age_lbl 072 `"72"', add
label define age_lbl 073 `"73"', add
label define age_lbl 074 `"74"', add
label define age_lbl 075 `"75"', add
label define age_lbl 076 `"76"', add
label define age_lbl 077 `"77"', add
label define age_lbl 078 `"78"', add
label define age_lbl 079 `"79"', add
label define age_lbl 080 `"80"', add
label define age_lbl 081 `"81"', add
label define age_lbl 082 `"82"', add
label define age_lbl 083 `"83"', add
label define age_lbl 084 `"84"', add
label define age_lbl 085 `"85"', add
label define age_lbl 086 `"86"', add
label define age_lbl 087 `"87"', add
label define age_lbl 088 `"88"', add
label define age_lbl 089 `"89"', add
label define age_lbl 090 `"90 (90+ in 1980 and 1990)"', add
label define age_lbl 091 `"91"', add
label define age_lbl 092 `"92"', add
label define age_lbl 093 `"93"', add
label define age_lbl 094 `"94"', add
label define age_lbl 095 `"95"', add
label define age_lbl 096 `"96"', add
label define age_lbl 097 `"97"', add
label define age_lbl 098 `"98"', add
label define age_lbl 099 `"99"', add
label define age_lbl 100 `"100 (100+ in 1960-1970)"', add
label define age_lbl 101 `"101"', add
label define age_lbl 102 `"102"', add
label define age_lbl 103 `"103"', add
label define age_lbl 104 `"104"', add
label define age_lbl 105 `"105"', add
label define age_lbl 106 `"106"', add
label define age_lbl 107 `"107"', add
label define age_lbl 108 `"108"', add
label define age_lbl 109 `"109"', add
label define age_lbl 110 `"110"', add
label define age_lbl 111 `"111"', add
label define age_lbl 112 `"112 (112+ in the 1980 internal data)"', add
label define age_lbl 113 `"113"', add
label define age_lbl 114 `"114"', add
label define age_lbl 115 `"115 (115+ in the 1990 internal data)"', add
label define age_lbl 116 `"116"', add
label define age_lbl 117 `"117"', add
label define age_lbl 118 `"118"', add
label define age_lbl 119 `"119"', add
label define age_lbl 120 `"120"', add
label define age_lbl 121 `"121"', add
label define age_lbl 122 `"122"', add
label define age_lbl 123 `"123"', add
label define age_lbl 124 `"124"', add
label define age_lbl 125 `"125"', add
label define age_lbl 126 `"126"', add
label define age_lbl 129 `"129"', add
label define age_lbl 130 `"130"', add
label define age_lbl 135 `"135"', add
label values age age_lbl

** Building characteristics recoding
gen bltyr_est = .

*1980
replace bltyr_est = 1979 if year==1980 & builtyr==1
replace bltyr_est = 1975 if year==1980 & builtyr==2
replace bltyr_est = 1970 if year==1980 & builtyr==3
replace bltyr_est = 1960 if year==1980 & builtyr==4
replace bltyr_est = 1950 if year==1980 & builtyr==5
replace bltyr_est = 1940 if year==1980 & builtyr==6
replace bltyr_est = 1930 if year==1980 & builtyr==7

*1990
replace bltyr_est = 1989 if year==1990 & builtyr==1
replace bltyr_est = 1985 if year==1990 & builtyr==2
replace bltyr_est = 1980 if year==1990 & builtyr==3
replace bltyr_est = 1970 if year==1990 & builtyr==4
replace bltyr_est = 1960 if year==1990 & builtyr==5
replace bltyr_est = 1950 if year==1990 & builtyr==6
replace bltyr_est = 1940 if year==1990 & builtyr==7
replace bltyr_est = 1930 if year==1990 & builtyr==8

*2000
replace bltyr_est = 1999 if year==2000 & builtyr==1
replace bltyr_est = 1995 if year==2000 & builtyr==2
replace bltyr_est = 1990 if year==2000 & builtyr==3
replace bltyr_est = 1980 if year==2000 & builtyr==4
replace bltyr_est = 1970 if year==2000 & builtyr==5
replace bltyr_est = 1960 if year==2000 & builtyr==6
replace bltyr_est = 1950 if year==2000 & builtyr==7
replace bltyr_est = 1940 if year==2000 & builtyr==8
replace bltyr_est = 1930 if year==2000 & builtyr==9

* 2005 and later
foreach y of numlist 2005/2019 {
	replace bltyr_est = 2005 if year==`y' & builtyr2==10
	replace bltyr_est = 2000 if year==`y' & builtyr2==9
	replace bltyr_est = 1990 if year==`y' & builtyr2==7
	replace bltyr_est = 1980 if year==`y' & builtyr2==6
	replace bltyr_est = 1970 if year==`y' & builtyr2==5
	replace bltyr_est = 1960 if year==`y' & builtyr2==4
	replace bltyr_est = 1950 if year==`y' & builtyr2==3
	replace bltyr_est = 1940 if year==`y' & builtyr2==2
	replace bltyr_est = 1930 if year==`y' & builtyr2==1
}
local i = 11
foreach y of numlist 2006/2019 {
	replace bltyr_est = `y' if inrange(year,2008,2019) & builtyr2==`i'
	local i = `i'+1
	display `i'
}

gen rooms_bed = .
replace rooms_bed = bedrooms - 1 
replace rooms_bed = . if bedrooms==0
replace rooms_bed = 5 if bedrooms>=6 & !mi(bedrooms)

gen rooms_total = .
replace rooms_total = rooms
replace rooms_total = . if rooms==0
replace rooms_total = 9 if rooms>=9 & !mi(rooms)



** Vehicle recoding 
keep year sample serial pernum autos trucks vehicles bltyr_est rooms_bed rooms_total
* recode to something reasonable
replace vehicles = . if vehicles==0
replace vehicles = 0 if vehicles==9

replace autos = . if autos==0
replace autos = autos-1

replace trucks = . if trucks==0
replace trucks = trucks-1

replace vehicles = autos+trucks if year==1980
replace vehicles = 3 if vehicles>3 & !mi(vehicles)

label drop vehicles_lbl trucks_lbl autos_lbl
bys year: tab vehicles 

drop autos trucks
compress

save "${DATA}/empirics/output/carinhh.dta", replace
clear

# ***********************************
# 0) Setup
# 1) Import & Reshape Data
# 2) Import GIS data for 1980 & 1990
# 3) Merge 100% and sample datasets
# ) Write data for stata importing
# **********************************

# ========
# 0) Setup
# ========

wd <- "C:\\Dropbox\\Dropbox (Phil Research)\\RacialCommutingGap"
setwd(wd)

pacman::p_load(sf,
               haven,
               tidyverse)


# =================================
# 1) Import Data and Reshape Longer
# =================================

one_hundred_perc_1980 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0009_ds104_1980_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Housing Units" = "C8Y001", "White" = "C9D001", "Black" = "C9D002")

sample_based_1980 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0009_ds107_1980_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "DEQ1979-March 1980" = DEQ001,
                                                              "DEQ1975-1978" = DEQ002,
                                                              "DEQ1970-1974" = DEQ003,
                                                              "DEQ1960-1969" = DEQ004,
                                                              "DEQ1950-1959" = DEQ005,
                                                              "DEQ1940-1949" = DEQ006,
                                                              "DEQ1939 or earlier"= DEQ007,
         "DFNNot of Spanish origin" = DFN001,
         "DFNMexican" = DFN002,
         "DFNPuerto Rican" = DFN003,
         "DFNCuban" = DFN004,
         "DFNOther Spanish: White, Black, American Indian, Eskimo, Aleut, and Asian and Pacific Islander" = DFN005,
         "DFNOther Spanish: Other (Race N.E.C.)" = DFN006) %>% 
  pivot_longer(., cols = starts_with("DFN"), names_prefix = "DFN", names_to = "Hispanic Origin by Race", values_to = "Hispanic Origin by Race Count") %>% # variable is Spanish Origin and Race
  pivot_longer(., cols = starts_with("DEQ"), names_prefix = "DEQ", names_to = "Year Structure Built", values_to = "Structure Built Count")

pop_counts_1980 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0009_ds116_1980_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Population" = C6W001)

one_hundred_perc_1990 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0011_ds120_1990_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "White" = EUY001, "Black" = EUY002, "Total Housing Units" = ESA001, "ET2Not of Hispanic origin >> White" = ET2001,
                                                                             "ET2Not of Hispanic origin >> Black" = ET2002,
                                                                             "ET2Not of Hispanic origin >> American Indian, Eskimo, or Aleut" = ET2003,
                                                                             "ET2Not of Hispanic origin >> Asian or Pacific Islander" = ET2004,
                                                                             "ET2Not of Hispanic origin >> Other race" = ET2005,
                                                                             "ET2Hispanic origin >> White" = ET2006,
                                                                             "ET2Hispanic origin >> Black" = ET2007,
                                                                             "ET2Hispanic origin >> American Indian, Eskimo, or Aleut" = ET2008,
                                                                             "ET2Hispanic origin >> Asian or Pacific Islander" = ET2009,
                                                                             "ET2Hispanic origin >> Other race" = ET2010) %>% 
  pivot_longer(., cols = starts_with("ET2"), names_prefix = "ET2", names_to = "Hispanic Origin by Race", values_to = "Hispanic Origin by Race Count")

sample_based_1990 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0011_ds123_1990_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Population" = E0H001,
         "EX71989 to March 1990" = EX7001,
         "EX71985 to 1988" = EX7002,
         "EX71980 to 1984" = EX7003,
         "EX71970 to 1979" = EX7004,
         "EX71960 to 1969" = EX7005,
         "EX71950 to 1959" = EX7006,
         "EX71940 to 1949"= EX7007,
         "EX71939 or earlier" = EX7008) %>% 
  pivot_longer(., cols = starts_with("EX7"), names_prefix = "EX7", names_to = "Year Structure Built", values_to = "Structure Built Count")

one_hundred_perc_2000 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0009_ds146_2000_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Population" =  FL5001, "White" =  FL9001, "Black" = FL9002, "Total Housing Units" = FKI001)

sample_based_2000 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0009_ds151_2000_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, 
         "GHJNot of Hispanic origin >> White Alone" = GHJ001,
         "GHJNot Hispanic or Latino >> Black or African American alone" = GHJ002,
         "GHJNot Hispanic or Latino >> American Indian and Alaska Native alone" = GHJ003,
         "GHJNot Hispanic or Latino >> Asian alone" = GHJ004,
         "GHJNot Hispanic or Latino >> Native Hawaiian and Other Pacific Islander alone" = GHJ005,
         "GHJNot Hispanic or Latino >> Some other race alone" = GHJ006,
         "GHJNot Hispanic or Latino >> Two or more races" = GHJ007,
         "GHJHispanic or Latino >> White alone" = GHJ008,
         "GHJHispanic or Latino >> Black or African American alone" = GHJ009,
         "GHJHispanic or Latino >> American Indian and Alaska Native alone" = GHJ010,
         "GHJHispanic or Latino >> Asian alone" = GHJ011,
         "GHJHispanic or Latino >> Native Hawaiian and Other Pacific Islander alone" = GHJ012,
         "GHJHispanic or Latino >> Some other race alone" = GHJ013,
         "GHJHispanic or Latino >> Two or more races" = GHJ014,
         "GAJBuilt 1999 to March 2000" = GAJ001,
         "GAJBuilt 1995 to 1998" = GAJ002,
         "GAJBuilt 1990 to 1994" = GAJ003,
         "GAJBuilt 1980 to 1989" = GAJ004,
         "GAJBuilt 1970 to 1979" = GAJ005,
         "GAJBuilt 1960 to 1969" = GAJ006,
         "GAJBuilt 1950 to 1959" = GAJ007,
         "GAJBuilt 1940 to 1949" = GAJ008, 
         "GAJBuilt 1939 or earlier" = GAJ009) %>% 
  pivot_longer(., cols = starts_with("GHJ"), names_prefix = "GHJ", names_to = "Hispanic Origin by Race", values_to = "Hispanic Origin by Race Count") %>% 
  pivot_longer(., cols = starts_with("GAJ"), names_prefix = "GAJ", names_to = "Year Structure Built", values_to = "Structure Built Count")

acs_2006_2010 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0011_ds176_20105_2010_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Population" = JMAE001, "White" = JMBE002, "Black" = JMBE003, "Total Housing Units" = JRIE001,
         "JMJETotal" = JMJE001,
         "JMJENot Hispanic or Latino" = JMJE002,
         "JMJENot Hispanic or Latino: White alone" = JMJE003,
         "JMJENot Hispanic or Latino: Black or African American alone" = JMJE004,
         "JMJENot Hispanic or Latino: American Indian and Alaska Native alone" = JMJE005,
         "JMJENot Hispanic or Latino: Asian alone" = JMJE006,
         "JMJENot Hispanic or Latino: Native Hawaiian and Other Pacific Islander alone" = JMJE007,
         "JMJENot Hispanic or Latino: Some other race alone" = JMJE008,
         "JMJENot Hispanic or Latino: Two or more races" = JMJE009,
         "JMJENot Hispanic or Latino: Two or more races: Two races including Some other race" = JMJE010,
         "JMJENot Hispanic or Latino: Two or more races: Two races excluding Some other race, and three or more races" = JMJE011,
         "JMJEHispanic or Latino" = JMJE012,
         "JMJEHispanic or Latino: White alone" = JMJE013,
         "JMJEHispanic or Latino: Black or African American alone" = JMJE014,
         "JMJEHispanic or Latino: American Indian and Alaska Native alone" = JMJE015,
         "JMJEHispanic or Latino: Asian alone" = JMJE016,
         "JMJEHispanic or Latino: Native Hawaiian and Other Pacific Islander alone" = JMJE017,
         "JMJEHispanic or Latino: Some other race alone" = JMJE018,
         "JMJEHispanic or Latino: Two or more races" = JMJE019,
         "JMJEHispanic or Latino: Two or more races: Two races including Some other race" = JMJE020,
         "JMJEHispanic or Latino: Two or more races: Two races excluding Some other race, and three or more races" = JMJE021,
         "JSDETotal" = JSDE001,
         "JSDEBuilt 2005 or later" = JSDE002,
         "JSDEBuilt 2000 to 2004" = JSDE003,
         "JSDEBuilt 1990 to 1999" = JSDE004,
         "JSDEBuilt 1980 to 1989" = JSDE005,
         "JSDEBuilt 1970 to 1979" = JSDE006,
         "JSDEBuilt 1960 to 1969" = JSDE007,
         "JSDEBuilt 1950 to 1959" = JSDE008, 
         "JSDEBuilt 1940 to 1949" = JSDE009,
         "JSDEBuilt 1939 or earlier" = JSDE010) %>% 
  pivot_longer(., cols = starts_with("JMJE"), names_prefix = "JMJE", names_to = "Hispanic Origin by Race", values_to = "Hispanic Origin by Race Count") %>% 
  pivot_longer(., cols = starts_with("JSDE"), names_prefix = "JSDE", names_to = "Year Structure Built", values_to = "Structure Built Count")

acs_2014_2018 <- read_csv(".\\empirics\\input\\nhgis\\data\\nhgis0011_ds239_20185_2018_tract.csv") %>% 
  select(YEAR, GISJOIN, STATEA, COUNTYA, "Total Population" = AJWME001, "White" = AJWNE002, "Black" = AJWNE003, "Total Housing Units" = AJ1SE001,     
         "AJWVETotal" = AJWVE001,
         "AJWVENot Hispanic or Latino" = AJWVE002,
         "AJWVENot Hispanic or Latino: White alone" = AJWVE003,
         "AJWVENot Hispanic or Latino: Black or African American alone" = AJWVE004,
         "AJWVENot Hispanic or Latino: American Indian and Alaska Native alone" = AJWVE005,
         "AJWVENot Hispanic or Latino: Asian alone" = AJWVE006,
         "AJWVENot Hispanic or Latino: Native Hawaiian and Other Pacific Islander alone" = AJWVE007,
         "AJWVENot Hispanic or Latino: Some other race alone" = AJWVE008,
         "AJWVENot Hispanic or Latino: Two or more races" = AJWVE009,
         "AJWVENot Hispanic or Latino: Two or more races: Two races including Some other race" = AJWVE010,
         "AJWVENot Hispanic or Latino: Two or more races: Two races excluding Some other race, and three or more races" = AJWVE011,
         "AJWVEHispanic or Latino" = AJWVE012,
         "AJWVEHispanic or Latino: White alone" = AJWVE013,
         "AJWVEHispanic or Latino: Black or African American alone" = AJWVE014,
         "AJWVEHispanic or Latino: American Indian and Alaska Native alone" = AJWVE015,
         "AJWVEHispanic or Latino: Asian alone" = AJWVE016,
         "AJWVEHispanic or Latino: Native Hawaiian and Other Pacific Islander alone" = AJWVE017,
         "AJWVEHispanic or Latino: Some other race alone" = AJWVE018,
         "AJWVEHispanic or Latino: Two or more races" = AJWVE019,
         "AJWVEHispanic or Latino: Two or more races: Two races including Some other race" = AJWVE020,
         "AJWVEHispanic or Latino: Two or more races: Two races excluding Some other race, and three or more races" = AJWVE021, 
         "AJM2ETotal" = AJ2ME001,
         "AJM2EBuilt 2014 or later" = AJ2ME002,
         "AJM2EBuilt 2010 to 2013" = AJ2ME003,
         "AJM2EBuilt 2000 to 2009" = AJ2ME004,
         "AJM2EBuilt 1990 to 1999" = AJ2ME005,
         "AJM2EBuilt 1980 to 1989" = AJ2ME006,
         "AJM2EBuilt 1970 to 1979" = AJ2ME007,
         "AJM2EBuilt 1960 to 1969" = AJ2ME008,
         "AJM2EBuilt 1950 to 1959" = AJ2ME009, 
         "AJM2EBuilt 1940 to 1949" = AJ2ME010,
         "AJM2EBuilt 1939 or earlier" = AJ2ME011) %>% 
  pivot_longer(., cols = starts_with("AJWVE"), names_prefix = "AJWVE", names_to = "Hispanic Origin by Race", values_to = "Hispanic Origin by Race Count") %>% 
  pivot_longer(., cols = starts_with("AJM2E"), names_prefix = "AJM2E", names_to = "Year Structure Built", values_to = "Structure Built Count")

# ======
# 2) GIS
# ======

gis_1980 <- read_sf(".\\empirics\\input\\nhgis\\1980_SHAPEAREA_only\\US_tract_1980.shp")
gis_1990 <- read_sf(".\\empirics\\input\\nhgis\\1990_SHAPEAREA_only\\US_tract_1990.shp")
gis_2000 <- read_sf(".\\empirics\\input\\nhgis\\2000_SHAPEAREA_only\\US_tract_2000.shp")
gis_2010 <- read_sf(".\\empirics\\input\\nhgis\\2010_SHAPEAREA_only\\US_tract_2010.shp")
gis_2018 <- read_sf(".\\empirics\\input\\nhgis\\2018_SHAPEAREA_only\\US_tract_2018.shp")

# ggplot(data = gis_1980) +
#   geom_sf() +
#   theme_minimal()

gis_1980 %>%
  st_as_sf(coords = c("lat", "lon"), crs="+proj=longlat +datum=NAD27 +no_defs") %>% # give CRS already in data & target type
  st_transform()


# =====================
# 3) Within year merge
# =====================

all_1980 <- full_join(one_hundred_perc_1980, sample_based_1980) %>% 
  full_join(., pop_counts_1980) %>% 
  mutate(across(STATEA:COUNTYA, ~ as.double(.))) %>% 
  full_join(., gis_1980) %>%
  select(-starts_with("NHGIS"), -GISJOIN2)

all_1990 <- full_join(one_hundred_perc_1990, sample_based_1990) %>% 
  full_join(., gis_1990) %>% 
  select(-starts_with("NHGIS"), -GISJOIN2)

all_2000 <- full_join(one_hundred_perc_2000, sample_based_2000)


# ==================================================
# 4) CZ-county crosswalks and Downtown Lon/Lat Data
# ==================================================

cbsa_cbd <- read_csv(".\\empirics\\data\\urban form\\cbsa_cbd_info.csv")
county_to_cbsa <- read_csv(".\\empirics\\data\\urban form\\county_to_cbsa.csv")
cw_cty_czone <- read_dta(".\\empirics\\input\\crosswalks\\cw_cty_czone\\cw_cty_czone.dta")


county_cz_cbd <- full_join(cbsa_cbd, county_to_cbsa, by = c("cbsa_code" = "cbsa10")) %>% 
  left_join(., cw_cty_czone, by = c("county" = "cty_fips")) %>% 
  select(county, state, czone, cbd_lat, cbd_lon)

all_1980 %>% 
  left_join(., county_cz_cbd, by = c("COUNTYA" = "county", "STATEA" = "state")) # check if char in one and double in other


# ===============
# 4) Export data
# ===============

# write_csv(all_1980, "all_1980.csv")
# write_csv(all_1990, "all_1990.csv")
# write_csv(all_2000, "all_2000.csv")
# write_csv(acs_2006_2010, "acs_2006_2010.csv")
# write_csv(acs_2014_2018, "acs_2014_2018.csv")




rm(list = ls())

# Define project directory
cdir <- "C:\\Users\\Chris.Severen\\Dropbox\\Data_Projects/RacialCommutingGap/"
gdir <- "C:\\GitHub\\RacializedCommutes\\"
######################################################
## BELOW THIS POINT, code should just run ##

setwd(cdir)

# load packages; version numbers are noted for each package used.
library(fixest)  # v 0.10.0
library(broom)  # v 0.7.4
library(tidyverse)  # v 1.3.0 
library(data.table)
library(haven)

myDict = c("d_black::1:year_bin::1980" = "$1[\\text{Black}] \\times t_{1980}$",
           "d_black::1:year_bin::1990" = "$1[\\text{Black}] \\times t_{1990}$",
           "d_black::1:year_bin::2000" = "$1[\\text{Black}] \\times t_{2000}$",
           "d_black::1:year_bin::2010" = "$1[\\text{Black}] \\times t_{2005--11}$",
           "d_black::1:year_bin::2019" = "$1[\\text{Black}] \\times t_{2012--19}$")

##########################################

#ipums <- as.data.table(read_dta("./empirics/data/ipums_smaller.dta"))
ipums <- fread("./empirics/data/ipums_smaller.csv")

##  Full Models by Year, CZFEs

T1B.1 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


T1B.2 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1B.3 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1B.4 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3] +
                 year_bin[d_gq, d_vehinhh],
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1B.5 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1B.6 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(T1B.1,T1B.2,T1B.3,T1B.4,T1B.5,T1B.6,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_all.tex") )

#income coeffs
Inc.6 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) + i(year_bin, linc) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(Inc.6)

##  Car Only by Year, CZFEs

TC.1 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
               subset = (ipums$tranwork_bin==10),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


TC.2 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
              subset = (ipums$tranwork_bin==10), 
              ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

TC.3 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
              subset = (ipums$tranwork_bin==10), 
              ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

TC.4 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                year_bin^educ_bin +
                year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3] +
                year_bin[d_gq, d_vehinhh],
              subset = (ipums$tranwork_bin==10), 
              ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

TC.5 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums$tranwork_bin==10),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(TC.1,TC.2,TC.3,TC.4,TC.5,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_car.tex") )


## Mode comparisons

TC.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums$tranwork_bin==30),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

TC.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                   subset = (ipums$tranwork_bin==36),
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

TC.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = (ipums$tranwork_bin==60),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(T1B.6,TC.5,TC.bus,TC.subway,TC.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_modcomps.tex") )


## Mode Comparisons, CZFEs, subsets of cities

# Transit 8
T8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
                subset = (ipums$transit8==1),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


T8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums$tranwork_bin==10) & (ipums$transit8==1)),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


T8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==30) & (ipums$transit8==1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      year_bin[d_gq, d_vehinhh] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums$tranwork_bin==36) & (ipums$transit8==1)),
                    ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums$tranwork_bin==60) & (ipums$transit8==1)),
                  ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

# Other 8
To8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  year_bin^tranwork_bin +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums$other8==1),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums$tranwork_bin==10) & (ipums$other8==1)),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


To8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums$tranwork_bin==30) & (ipums$other8==1)),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                     year_bin[d_gq, d_vehinhh] +
                     ind1990^year_bin + occ1990^year_bin,
                   subset = ((ipums$tranwork_bin==36) & (ipums$other8==1)),
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==60) & (ipums$other8==1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


# All others
Toth.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   year_bin^tranwork_bin +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


Toth.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==10) & (ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


Toth.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==30) & (ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

Toth.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      year_bin[d_gq, d_vehinhh] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums$tranwork_bin==36) & (ipums$transit8!=1) & (ipums$other8!=1)),
                    ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

Toth.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums$tranwork_bin==60) & (ipums$transit8!=1) & (ipums$other8!=1)),
                  ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(T8.all,T8.car,T8.bus,T8.subway,T8.walk,
       To8.all,To8.car,To8.bus,To8.walk,
       Toth.all,Toth.car,Toth.bus,Toth.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_citygroups.tex") )


#########################
## With PUMAs
########################

ipums_0018 <- ipums %>%
  filter(year>=2000)

rm(ipums)

P.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                year_bin^educ_bin +
                year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                year_bin[d_gq, d_vehinhh] +
                ind1990^year_bin + occ1990^year_bin,
              subset = (ipums_0018$tranwork_bin==10),
              ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==30),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==36),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$tranwork_bin==60),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(P.all,P.car,P.bus,P.subway,P.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecificpumas_modcomps.tex") )

# Transit 8

P8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$transit8==1),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8==1)),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8==1)),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$transit8==1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$transit8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)


# Other 8
Po8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  year_bin^tranwork_bin +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$other8==1),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$other8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$other8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                     year_bin[d_gq, d_vehinhh] +
                     ind1990^year_bin + occ1990^year_bin,
                   subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$other8==1)),
                   ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$other8==1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

# All others
Poth.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   year_bin^tranwork_bin +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      year_bin[d_gq, d_vehinhh] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                    ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(P8.all,P8.car,P8.bus,P8.subway,P8.walk,
       Po8.all,Po8.car,Po8.bus,Po8.walk,
       Poth.all,Poth.car,Poth.bus,Poth.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecificpumas_citygroups.tex") )



#########################
## With POW PUMAs
########################


PW.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

PW.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==10),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

PW.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin[d_gq, d_vehinhh] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==30),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

PW.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = (ipums_0018$tranwork_bin==36),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

PW.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$tranwork_bin==60),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(PW.all,PW.car,PW.bus,PW.subway,PW.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecificpowpumas.tex") )

# Transit 8

WP8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  year_bin^tranwork_bin +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$transit8==1),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WP8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WP8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin[d_gq, d_vehinhh] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WP8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                     year_bin[d_gq, d_vehinhh] +
                     ind1990^year_bin + occ1990^year_bin,
                   subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$transit8==1)),
                   ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WP8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$transit8==1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)


# Other 8
WPo8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   year_bin^tranwork_bin +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = (ipums_0018$other8==1),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPo8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$other8==1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPo8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin[d_gq, d_vehinhh] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$other8==1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPo8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      year_bin[d_gq, d_vehinhh] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$other8==1)),
                    ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPo8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$other8==1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

# All others
WPoth.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    year_bin^tranwork_bin +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPoth.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPoth.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    year_bin[d_gq, d_vehinhh] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPoth.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                       year_bin^educ_bin +
                       year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                       year_bin[d_gq, d_vehinhh] +
                       ind1990^year_bin + occ1990^year_bin,
                     subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                     ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

WPoth.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz^pwpuma_yr + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                     year_bin[d_gq, d_vehinhh] +
                     ind1990^year_bin + occ1990^year_bin,
                   subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                   ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(WP8.all,WP8.car,WP8.bus,WP8.subway,WP8.walk,
       WPo8.all,WPo8.car,WPo8.bus,WPo8.walk,
       WPoth.all,WPoth.car,WPoth.bus,WPoth.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecificpowpumas_citygroups.tex") )
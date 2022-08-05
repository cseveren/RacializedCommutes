rm(list = ls())

# Define project directory
cdir <- "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap/"
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

## income check

# inccheck_unc0 <- feols(ln_trantime ~ i(year_bin, linc) + i(year_bin, i.inczero) | czone_year_bin,
#                       ipums, cluster = "czone", weights = ipums$czwt_tt, mem.clean = TRUE)
# ff_unc0 <- fixef(inccheck_unc0)
# 
# etable(inccheck_unc0)
# 
# inccheck_unc <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
#                     year_bin[linc, inczero],
#                   ipums, cluster = "czone", weights = ipums$czwt_tt, mem.clean = TRUE)
# ff_unc <- fixef(inccheck_unc)
# 
# inccheck_con <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
#                  year_bin^educ_bin +
#                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
#                  year_bin^tranwork_bin +
#                  ind1990^year_bin + occ1990^year_bin,
#                ipums, cluster = "czone", weights = ipums$czwt_tt, mem.clean = TRUE)
# ff_con <- fixef(inccheck_con)
# 
# ff_unc$`year_bin[[linc]]`
# ff_con$`year_bin[[linc]]`
# 
# rm(inccheck_unc, inccheck_con, ff_unc, ff_con)



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

T1C.4 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums$tranwork_bin==10),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(TC.1,TC.2,TC.3,T1C.4, keep = "d_black",
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_car.tex") )


## Mode comparisons

T1C.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums$tranwork_bin==30),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1C.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                   subset = (ipums$tranwork_bin==36),
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T1C.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = (ipums$tranwork_bin==60),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

etable(T1B.6,T1C.4,T1C.bus,T1C.subway,T1C.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_modcomps.tex") )


## Mode Comparisons, CZFEs, subsets of cities

# Transit 8
T8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
                subset = (ipums$transit8==1),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


T8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums$tranwork_bin==10) & (ipums$transit8==1)),
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


T8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==30) & (ipums$transit8==1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums$tranwork_bin==36) & (ipums$transit8==1)),
                    ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

T8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums$tranwork_bin==60) & (ipums$transit8==1)),
                  ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

# Other 8
To8.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  year_bin^tranwork_bin +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums$other8==1),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums$tranwork_bin==10) & (ipums$other8==1)),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


To8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums$tranwork_bin==30) & (ipums$other8==1)),
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                     ind1990^year_bin + occ1990^year_bin,
                   subset = ((ipums$tranwork_bin==36) & (ipums$other8==1)),
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

To8.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==60) & (ipums$other8==1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


# All others
Toth.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   year_bin^tranwork_bin +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


Toth.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==10) & (ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


Toth.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums$tranwork_bin==30) & (ipums$transit8!=1) & (ipums$other8!=1)),
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

Toth.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums$tranwork_bin==36) & (ipums$transit8!=1) & (ipums$other8!=1)),
                    ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

Toth.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums$tranwork_bin==60) & (ipums$transit8!=1) & (ipums$other8!=1)),
                  ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(T8.all,T8.car,T8.bus,T8.subway,T8.walk,
       To8.all,To8.car,To8.bus,To8.walk,
       Toth.all,Toth.car,Toth.bus,Toth.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecific_citygroups.tex") )




## With PUMAs


ipums_0018 <- ipums %>%
  filter(year>=2000)

rm(ipums)

P.all <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                year_bin^educ_bin +
                year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                ind1990^year_bin + occ1990^year_bin,
              subset = (ipums_0018$tranwork_bin==10),
              ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==30),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = (ipums_0018$tranwork_bin==36),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
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
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$transit8==1),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8==1)),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 ind1990^year_bin + occ1990^year_bin,
               subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8==1)),
               ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

P8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
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
                  year_bin^tranwork_bin +
                  ind1990^year_bin + occ1990^year_bin,
                subset = (ipums_0018$other8==1),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$other8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                  ind1990^year_bin + occ1990^year_bin,
                subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$other8==1)),
                ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Po8.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                     year_bin^educ_bin +
                     year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
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
                   year_bin^tranwork_bin +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.car <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==10) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.bus <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                   year_bin^educ_bin +
                   year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                   ind1990^year_bin + occ1990^year_bin,
                 subset = ((ipums_0018$tranwork_bin==30) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                 ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.subway <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                      year_bin^educ_bin +
                      year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                      ind1990^year_bin + occ1990^year_bin,
                    subset = ((ipums_0018$tranwork_bin==36) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                    ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)

Poth.walk <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | puma_yrbncz + 
                    year_bin^educ_bin +
                    year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                    ind1990^year_bin + occ1990^year_bin,
                  subset = ((ipums_0018$tranwork_bin==60) & (ipums_0018$transit8!=1) & (ipums_0018$other8!=1)),
                  ipums_0018, cluster = "czone", weights = ipums_0018$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(P8.all,P8.car,P8.bus,P8.subway,P8.walk,
       Po8.all,Po8.car,Po8.bus,Po8.walk,
       Poth.all,Poth.car,Poth.bus,Poth.walk,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\gap_yearspecificpumas_citygroups.tex") )

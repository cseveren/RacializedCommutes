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

myDict = c("d_black::1:year_bin::1980" = "$1[\\text{Black}] \\times t_{1980}$",
           "d_black::1:year_bin::1990" = "$1[\\text{Black}] \\times t_{1990}$",
           "d_black::1:year_bin::2000" = "$1[\\text{Black}] \\times t_{2000}$",
           "d_black::1:year_bin::2010" = "$1[\\text{Black}] \\times t_{2005--11}$",
           "d_black::1:year_bin::2019" = "$1[\\text{Black}] \\times t_{2012--19}$")

##########################################

ipums <- fread("./empirics/data/ipums_smaller_lfp.csv")

## Note: occasionally running all these models back-to-back will challenge memory resources, resulting in
## the error: "Error in feols(...  : 
##             Error : cannot allocate vector of size XXX Gb"
## If this occurs, simply wait a short period of time and run the error-generating model. It should execute.

## Main (full sample) LFP robustness

RB_0.1 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


RB_0.2 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

RB_0.3 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


RB_A.1 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


RB_A.2 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

RB_A.3 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


RB_C.1 <- feols(ln_trantime_q99 ~ i(d_black,i.year_bin, 0) | year_bin,
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


RB_C.2 <- feols(ln_trantime_q99 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

RB_C.3 <- feols(ln_trantime_q99 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(RB_0.1, RB_A.1, RB_C.1, keep = "d_black", digits=3)
etable(RB_0.2, RB_A.2, RB_C.2, keep = "d_black", digits=3)
etable(RB_0.3, RB_A.3, RB_C.3, keep = "d_black", digits=3)

etable(RB_0.1, RB_A.1, RB_C.1, RB_0.2, RB_A.2, RB_C.2, RB_0.3, RB_A.3, RB_C.3, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr.tex") )


## Prime age LFP (all)

PA_0.1 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_0.2 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_0.3 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.1 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.2 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.3 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                subset = (ipums$age>=25 & ipums$age<=54), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

           
etable(PA_0.1, PA_A.1, PA_0.2, PA_A.2, PA_0.3, PA_A.3, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_primeage.tex") )


## Prime age LFP (male)

PA_0.1m <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_0.2m <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_0.3m <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.1m <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.2m <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.3m <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                  year_bin^educ_bin +
                  year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==0), 
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(PA_0.1m, PA_A.1m, PA_0.2m, PA_A.2m, PA_0.3m, PA_A.3m, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_primeage_male.tex") )


## Prime age LFP (female)

PA_0.1f <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_0.2f <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_0.3f <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.1f <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.2f <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.3f <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                   year_bin^educ_bin +
                   year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$female==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(PA_0.1f, PA_A.1f, PA_0.2f, PA_A.2f, PA_0.3f, PA_A.3f, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_primeage_female.tex") )



## Main (full sample) LFP robustness with car in HH


VH_0.3 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                        year_bin^educ_bin +
                        year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

VH_0.4 <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                        year_bin^educ_bin +
                        year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, d_vehinhh],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


VH_A.3 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                        year_bin^educ_bin +
                        year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

VH_A.4 <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                        year_bin^educ_bin +
                        year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, d_vehinhh],
                ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(VH_0.3, VH_0.4, VH_A.3, VH_A.4, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_vehinhh.tex") )



## Prime age with veh

PA_0.1veh <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_0.2veh <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_0.3veh <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                         year_bin^educ_bin +
                         year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.1veh <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.2veh <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.3veh <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                         year_bin^educ_bin +
                         year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                 subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==1), 
                 ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(PA_0.1veh, PA_A.1veh, PA_0.2veh, PA_A.2veh, PA_0.3veh, PA_A.3veh, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_primeage_veh1.tex") )


## Prime age w/o veh

PA_0.1nov <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | year_bin,
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_0.2nov <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_0.3nov <- feols(ln_trantime ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                           year_bin^educ_bin +
                           year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.1nov <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | year_bin,
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


PA_A.2nov <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin, 
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

PA_A.3nov <- feols(ln_trantime_czq95 ~ i(d_black,i.year_bin, 0) | czone_year_bin + 
                           year_bin^educ_bin +
                           year_bin[age, age2, d_marr, d_head, child_1or2, child_gteq3],
                   subset = (ipums$age>=25 & ipums$age<=54 & ipums$d_vehinhh==0), 
                   ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)


etable(PA_0.1nov, PA_A.1nov, PA_0.2nov, PA_A.2nov, PA_0.3nov, PA_A.3nov, 
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\bounds_lfpr_primeage_veh0.tex") )



#data_lfpr <- ipums %>%
#        select(year_bin, empstat, d_black, d_fem, czwt_tt, d_vehinhh) %>%
#        mutate(inlf = (empstat==1|empstat==2))

#lfpr_by_group <- data_lfpr[ ,lapply(.SD, weighted.mean, w=czwt_tt), by = list(year_bin, d_fem, d_black)]

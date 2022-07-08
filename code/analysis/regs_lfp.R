rm(list = ls())

# Define project directory
cdir <- "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap/"
######################################################
## BELOW THIS POINT, code should just run ##

setwd(cdir)

# load packages; version numbers are noted for each package used.
library(fixest)  # v 0.10.0
library(broom)  # v 0.7.4
library(tidyverse)  # v 1.3.0 
library(data.table)

##########################################

ipums <- fread("./empirics/data/ipums_smaller_lfp.csv")


##  Full Models by Year, CZFEs

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


etable(T1B.1,T1B.2,T1B.3,T1B.4,T1B.5,T1B.6, keep = "d_black", tex=TRUE, digits=3, replace=TRUE,
       file = paste0(cdir,"/empirics/results/black-white/tables/gap_yearspecific_all.tex") )


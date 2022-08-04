rm(list = ls())

# Define project directory
cdir <- "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap/"
gdir <- "C:\\GitHub\\RacializedCommutes\\"
######################################################
## BELOW THIS POINT, code should just run ##

setwd(cdir)

# load packages; version numbers are noted for each package used.
#library(fixest)  # v 0.8.2
library(broom)  # v 0.7.4
library(tidyverse)  # v 1.3.0 
library(data.table)

# library(devtools)
# install_github("lrberge/fixest")
library(fixest)  # v 0.10.0


myDict = c("d_black::1:year_bin::1980" = "$1[\\text{Black}] \\times t_{1980}$",
           "d_black::1:year_bin::1990" = "$1[\\text{Black}] \\times t_{1990}$",
           "d_black::1:year_bin::2000" = "$1[\\text{Black}] \\times t_{2000}$",
           "d_black::1:year_bin::2010" = "$1[\\text{Black}] \\times t_{2005--11}$",
           "d_black::1:year_bin::2019" = "$1[\\text{Black}] \\times t_{2012--19}$")

##########################################

ipums <- fread("./empirics/data/ipums_smaller.csv")

baseline <- feols(ln_trantime ~ i(d_black) | year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, lean = TRUE, mem.clean = TRUE)

allin <- feols(ln_trantime ~ i(d_black) | czone_year_bin + 
                 year_bin^educ_bin +
                 year_bin[female, age, age2, d_marr, d_head, child_1or2, child_gteq3, linc, inczero] +
                 year_bin^tranwork_bin +
                 ind1990^year_bin + occ1990^year_bin,
               ipums, cluster = "czone", weights = ipums$czwt_tt, mem.clean = TRUE, combine.quick = FALSE)

fevals = predict(allin, fixef=TRUE)

preddata = data.table(ipums$d_black,ipums$czwt_tt, ipums$czone)
setnames(preddata,"V1","d_black")
setnames(preddata,"V2","czwt_tt")
setnames(preddata,"V3","czone")

preddata$xb_demographics = fevals$`year_bin[[female]]` * ipums$female +
  fevals$`year_bin^educ_bin` +
  fevals$`year_bin[[age]]` * ipums$age +
  fevals$`year_bin[[age2]]` * ipums$age2 +
  fevals$`year_bin[[d_marr]]` * ipums$d_marr +
  fevals$`year_bin[[d_head]]` * ipums$d_head +
  fevals$`year_bin[[child_1or2]]` * ipums$child_1or2 +
  fevals$`year_bin[[child_gteq3]]` * ipums$child_gteq3 

preddata$xb_transit = fevals$`year_bin^tranwork_bin` 

preddata$xb_work = fevals$`occ1990^year_bin` +
  fevals$`ind1990^year_bin` +
  fevals$`year_bin[[linc]]` * ipums$linc +
  fevals$`year_bin[[inczero]]` * ipums$inczero
  
preddata$xb_cz = fevals$`czone_year_bin` + 
  fevals$`year_bin`

dcomp_demo <- feols(xb_demographics ~ i(d_black),
                  preddata, cluster = "czone", weights = preddata$czwt_tt, lean = TRUE, mem.clean = TRUE)

dcomp_transit <- feols(xb_transit ~ i(d_black),
                    preddata, cluster = "czone", weights = preddata$czwt_tt, lean = TRUE, mem.clean = TRUE)

dcomp_work <- feols(xb_work ~ i(d_black),
                    preddata, cluster = "czone", weights = preddata$czwt_tt, lean = TRUE, mem.clean = TRUE)

dcomp_cz <- feols(xb_cz ~ i(d_black),
                    preddata, cluster = "czone", weights = preddata$czwt_tt, lean = TRUE, mem.clean = TRUE)



etable(baseline,allin,dcomp_demo,dcomp_transit,dcomp_work,dcomp_cz,
       keep = "t_", tex=TRUE, digits=3, replace=TRUE, dict = myDict,
       file = paste0(gdir,"\\results\\black-white\\tables\\decomposition_bygroup.tex") )

percentages <- c(allin$coefficients[[1]]/baseline$coefficients[[1]],
  dcomp_demo$coefficients[[2]]/baseline$coefficients[[1]],
  dcomp_transit$coefficients[[2]]/baseline$coefficients[[1]],
  dcomp_work$coefficients[[2]]/baseline$coefficients[[1]],
  dcomp_cz$coefficients[[2]]/baseline$coefficients[[1]])

write.csv(percentages,paste0(gdir,"\\results\\black-white\\tables\\decomposition_bygroup_percentages.tex"))


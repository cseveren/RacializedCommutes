rm(list = ls())

# Define project directory
cdir <- "C:/Dropbox/Dropbox/Data_Projects/RacialCommutingGap/"
gdir <- "C:\\GitHub\\RacializedCommutes\\"
######################################################
## BELOW THIS POINT, code should just run ##

setwd(cdir)

# load packages; version numbers are noted for each package used.
library(fixest)  # v 0.10.0
library(tidyverse)  # v 1.3.0
library(data.table)
library(dplyr)

source(paste0(gdir,"code/analysis/market_access_helper.R"))

##########################################
# read data
aa <- read.csv("./empirics/input/urban_form/market_access_build/dist_mat/100_dist_1990.csv")
popemp1990 <- fread("./empirics/input/urban_form/market_access_build/zip_lonlat1990.csv")


# set parameters
dmin <- 1


########

ap <- prepdata(aa)

popemp_small <- popemp1990[popemp1990$zcta %in% ap$zips]
LF <- matrix(popemp_small$emp, 1, ap$nz)
LR <- matrix(popemp_small$pop_emp, ap$nz, 1)
LF <- LF * sum(LR) / sum(LF) # Scale LF to LR deal with cross-CZ population flows

ap$dmat[ap$dmat<dmin] <- dmin

dmattheta04 <- ap$dmat^(-0.4)
dmattheta08 <- ap$dmat^(-0.8)
phi04 <- findphi(dmattheta04, LF, LR, ap$nz)
phi08 <- findphi(dmattheta08, LF, LR, ap$nz)

plot(phi04$Ri, phi04$Fj)
plot(phi08$Ri, phi08$Fj)

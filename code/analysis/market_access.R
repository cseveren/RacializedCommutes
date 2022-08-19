rm(list = ls())

# Define project directory
cdir <- "C:/Users/Chris.Severen/Dropbox/Data_Projects/RacialCommutingGap/"
gdir <- "C:\\GitHub\\RacializedCommutes\\"
######################################################
## BELOW THIS POINT, code should just run ##

setwd(cdir)

# load packages; version numbers are noted for each package used.
library(data.table)
library(dplyr)

source(paste0(gdir,"code/analysis/market_access_helper.R"))

##########################################
# read data
aa <- read.csv("./empirics/input/urban_form/market_access_build/dist_mat/19400_dist_1990.csv")
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

dmattheta <- ap$dmat^(-0.8)
phi <- findphi(dmattheta, LF, LR, ap$nz)

plot(phi$Ri, phi$Fj)


aa_num <- sum((LR/sum(LR)) * (phi$Ri^-1) * rSums(rExpand(ap$dmat * dmattheta, LF/phi$Fj, ap$nz), ap$nz))
aa_denom <- sum((LR/sum(LR)) * (phi$Ri^-1) * rSums(rExpand(dmattheta, LF/phi$Fj, ap$nz), ap$nz))

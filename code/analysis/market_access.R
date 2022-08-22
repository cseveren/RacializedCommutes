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
# read data¶
loc <- "./empirics/input/urban_form/market_access_build/dist_mat/"
popemp1990 <- popdata("./empirics/input/urban_form/market_access_build/zip_lonlat1990.csv") 
popemp2000 <- popdata("./empirics/input/urban_form/market_access_build/zip_lonlat2000.csv")
popemp2010 <- popdata("./empirics/input/urban_form/market_access_build/zip_lonlat2010.csv")
popemp2019 <- popdata("./empirics/input/urban_form/market_access_build/zip_lonlat2018.csv")
czdata <- fread("./empirics/output/czyrall_blackwhite.csv") %>%
  select(czone, year, largestcity, time_all)

####
#bb <- popemp1990[popemp1990$czone==19700]
########
theta <- -1.4
yrlist <- as.integer(c(1990, 2000, 2010, 2019))
czlist <- unique(czdata$czone)

outframe <- data.frame(matrix(ncol=7, nrow=length(yrlist)*length(czlist)))

i <-1 
for (y in yrlist) {
  for (c in czlist) {
    speedma <- findspeedma(loc, c, y, eval(as.name(paste0("popemp",as.character(y)))), czdata, theta)
    outframe[i,1] <- c
    outframe[i,2] <- y
    outframe[i,3] <- speedma$speed
    outframe[i,4] <- speedma$MAwhite
    outframe[i,5] <- speedma$MAblack
    outframe[i,6] <- speedma$nz
    outframe[i,7] <- speedma$niter
    i <- i+1
  }
}

colnames(outframe) <- c("czone","year","speed","MA_white","MA_black","nzips","niters")
finalframe <- outframe[order(outframe$nzips,outframe$niters), ] %>%
  mutate(ratio = MA_black/MA_white)




sp1 <- findspeedma(loc, 19700, 1990, popemp1990, czdata, theta=-1.4, long=T)

ap <- prepdata2(loc,19400,1990)


popemp_small <- popemp1990[popemp1990$zcta %in% ap$zips]
LF <- matrix(popemp_small$emp, 1, ap$nz)
LR <- matrix(popemp_small$pop_emp, ap$nz, 1)
LF <- LF * sum(LR) / sum(LF) # Scale LF to LR deal with cross-CZ population flows

ap$dmat[ap$dmat<dmin] <- dmin

dmattheta <- ap$dmat^(-0.8)
phi <- findphi(dmattheta, LF, LR, ap$nz)

plot(phi$Ri, phi$Fj)


avedist <- sum((LR/sum(LR)) * (phi$Ri^-1) * rSums(rExpand(ap$dmat * dmattheta, LF/phi$Fj, ap$nz), ap$nz))
avespeed <- avedist / avetime



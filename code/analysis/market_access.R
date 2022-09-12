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
  select(czone, year, largestcity, time_all, inc)

czdata$inc <- czdata$inc/1000

####
#bb <- popemp1990[popemp1990$czone==19700]
########
theta <- 3.398
kappa_semi <- -0.013
kappa_elast <- 25*kappa_semi
yrlist <- as.integer(c(1990, 2000, 2010, 2019))
czlist <- unique(czdata$czone)

outframe1 <- data.frame(matrix(ncol=8, nrow=length(yrlist)*length(czlist)))
outframe2 <- data.frame(matrix(ncol=8, nrow=length(yrlist)*length(czlist)))
outframe3 <- data.frame(matrix(ncol=8, nrow=length(yrlist)*length(czlist)))

# cz-yr specific time elasticity, full wage data
i <-1 
for (y in yrlist) {
  for (c in czlist) {
    speedma <- findspeedma(loc, c, y, eval(as.name(paste0("popemp",as.character(y)))), czdata, theta, kappa_semi, time_elasticity=T)
    outframe1[i,1] <- c
    outframe1[i,2] <- y
    outframe1[i,3] <- speedma$speed
    outframe1[i,4] <- speedma$dist
    outframe1[i,5] <- speedma$MAwhite
    outframe1[i,6] <- speedma$MAblack
    outframe1[i,7] <- speedma$nz
    outframe1[i,8] <- speedma$niter
    i <- i+1
  }
}

colnames(outframe1) <- c("czone","year","speed","dist","MA_white","MA_black","nzips","niters")
finalframe1 <- outframe1[order(outframe1$nzips,outframe1$niters), ] %>%
  mutate(ratio = MA_black/MA_white)

# common time elasticity, full wage data
i <-1 
for (y in yrlist) {
  for (c in czlist) {
    speedma <- findspeedma(loc, c, y, eval(as.name(paste0("popemp",as.character(y)))), czdata, theta, kappa_elast, time_elasticity=F)
    outframe2[i,1] <- c
    outframe2[i,2] <- y
    outframe2[i,3] <- speedma$speed
    outframe2[i,4] <- speedma$dist
    outframe2[i,5] <- speedma$MAwhite
    outframe2[i,6] <- speedma$MAblack
    outframe2[i,7] <- speedma$nz
    outframe2[i,8] <- speedma$niter
    i <- i+1
  }
}

colnames(outframe2) <- c("czone","year","speed","dist","MA_white","MA_black","nzips","niters")
finalframe2 <- outframe2[order(outframe2$nzips,outframe2$niters), ] %>%
  mutate(ratio = MA_black/MA_white)


# common time elasticity, no wage data
i <-1 
for (y in yrlist) {
  for (c in czlist) {
    speedma <- findspeedma(loc, c, y, eval(as.name(paste0("popemp",as.character(y)))), czdata, theta, kappa_elast, time_elasticity=F, common_wage=T)
    outframe3[i,1] <- c
    outframe3[i,2] <- y
    outframe3[i,3] <- speedma$speed
    outframe3[i,4] <- speedma$dist
    outframe3[i,5] <- speedma$MAwhite
    outframe3[i,6] <- speedma$MAblack
    outframe3[i,7] <- speedma$nz
    outframe3[i,8] <- speedma$niter
    i <- i+1
  }
}

## write out
colnames(outframe3) <- c("czone","year","speed","dist","MA_white","MA_black","nzips","niters")
finalframe3 <- outframe3[order(outframe3$nzips,outframe3$niters), ] %>%
  mutate(ratio = MA_black/MA_white)


write.csv(finalframe1,"./empirics/output/market_access_cityspecificelasticity.csv")
write.csv(finalframe2,"./empirics/output/market_access_commonelasticity.csv")
write.csv(finalframe3,"./empirics/output/market_access_commonelasticity_nowage.csv")

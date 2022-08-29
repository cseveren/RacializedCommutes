
## FUNCTIONS

################
# wrapper

findspeedma <- function(dfolder, cz, yr, popfile, timefile, theta, kappa, dmin=1, plot=F, long=F, time_elasticity=T) {
  
  # prep average time and wage
  avetime <- timefile[timefile$czone==cz & timefile$year==yr]$time_all
  avew <- timefile[timefile$czone==cz & timefile$year==yr]$inc
  
  # commuting elasticity and logic
  if (time_elasticity==T) {
    commute_elast <- avetime*theta*kappa
  } else if (time_elasticity==F) {
    commute_elast <- theta*kappa
  }
  
  if (commute_elast>=0) {
    stop("Error: Commuting elasticity (avetime*theta*kappa OR theta*kappa) must be less than zero.")
  }
  
  # prep distance info
  if (yr==2019) {
    dinfo <- prepdata2(dfolder,cz,2018)
  } else {
    dinfo <- prepdata2(dfolder,cz,yr)
  }

  # prep population data
  popemp <- popfile[popfile$zcta %in% dinfo$zips]
  popemp <- popemp[order(popemp),]

  # rescale: because priority is the scale of phi_R, shift sum(LR) to match sum(LF)
  LF <- matrix(as.numeric(popemp$emp), 1, dinfo$nz)
  LR <- matrix(as.numeric(popemp$pop_emp), dinfo$nz, 1)
  
  if (length(as.numeric(popemp$emp))!=dinfo$nz ||
      length(as.numeric(popemp$pop_emp))!=dinfo$nz ||
      dinfo$nz==1) {
    return(list(speed = NA,
                dist = NA,
                MAwhite = NA,
                MAblack = NA,
                nz = NA,
                niter = NA)) 
  }
  
  LF[is.na(LF)] <- 0
  LR[is.na(LR)] <- 0
  
  LR <- LR * sum(LF) / sum(LR)

  # prep and transform distance matrix
  dinfo$dmat[dinfo$dmat<dmin] <- dmin
  dmattheta <- dinfo$dmat^(commute_elast)

  # find phis (phi-tildes); plot if necessary for troublshooting
  phi <- findphi(dmattheta, LF, LR, dinfo$nz)
  if (plot==T) {
    plot(phi$Ri, phi$Fj)
  }

  # calculate average distance and average speed
  avedist <- sum((LR/sum(LR)) * (phi$Ri^-1) * rSums(rExpand(dinfo$dmat * dmattheta, LF/(phi$Fj), dinfo$nz), dinfo$nz))
  avespeed <- avedist / avetime
  
  # scale for wage
  varsigma <- avew^(-1) * sum( (LF/sum(LF)) * (LF/(phi$Fj))^(1/theta), na.rm = TRUE) 
  
  truphi_Ri <- phi$Ri/( (varsigma^theta) * (avespeed^(commute_elast)) )
  truphi_Fj <- phi$Fj/( (varsigma^theta) * (avespeed^(commute_elast)) )
  
  # truephis
  #truephi_Ri <- 
  
  # calculate MA differential
  pRwhite <- as.numeric(popemp$nh_white)/sum(as.numeric(popemp$nh_white), na.rm = TRUE)
  pRblack <- as.numeric(popemp$nh_black)/sum(as.numeric(popemp$nh_black), na.rm = TRUE)
  
  MAwhite <- sum(truphi_Ri * pRwhite, na.rm = TRUE)
  MAblack <- sum(truphi_Ri * pRblack, na.rm = TRUE)
  
  if (MAwhite==0) {
    MAwhite <- NA
  }
  if (MAblack==0) {
    MAblack <- NA
  }
  
  if (long==TRUE) {
    return(list(speed = avespeed,
                dist = avedist,
                MAwhite = MAwhite,
                MAblack = MAblack,
                nz = dinfo$nz,
                niter = phi$iter,
                LR=LR,
                LRraw=popemp$pop_emp,
                LF=LF,
                LFraw=popemp$emp,
                truphi_Ri = truphi_Ri,
                truphi_Fj = truphi_Fj,
                rawphi_Ri = phi$Ri,
                rawphi_Fj = phi$Fj,
                dmat=dinfo$dmat))
  } else {
    return(list(speed = avespeed,
                dist = avedist,
                MAwhite = MAwhite,
                MAblack = MAblack,
                nz = dinfo$nz,
                niter = phi$iter))
  }
}


################
# data prep functions 

prepdata <- function(rawmat) {
  zips <- as.character(rawmat$zcta) %>%
    sapply(function(x){if(nchar(x)<5){paste0("0",x)}else{x}}) %>%
    as.vector()
  n <- ncol(rawmat)-1
  
  dmat <- as.matrix(rawmat[,1:n+1])   
  
  list(dmat=dmat,
       zips=zips,
       nz=n)
}

prepdata2 <- function(folder, cz, yr) {
  distmat <- read.csv(paste0(folder, as.character(cz), "_dist_", as.character(yr), ".csv"))
  prepdata(distmat)
}

popdata <- function(pfile) {
  
  pdata <- fread(pfile) %>%
    mutate(zcta = as.character(zcta))
  pdata$zcta <- sapply(pdata$zcta, function(x){if(nchar(x)<5){paste0("0",x)}else{x}})
  
  return(pdata)
}

################
# solver functions
findphi <- function(dmthta, LF, LR, nz, tol=1e-8) {
  
  phiR_k <- rep(1000, 1, nz) 
  phiF_k <- rep(1000, 1, nz) 
  
  conv <- 1
  iter <- 1
  
  while (conv>tol && iter<10000) {
    
    phiR_z <- rSums(rExpand(dmthta, LF/phiF_k, nz), nz)
    phiF_z <- cSums(cExpand(dmthta, LR/phiR_k, nz), nz)
    
    conv <- cvecNormDist(phiR_z, phiR_k, nz) + rvecNormDist(phiF_z, phiF_k, nz)

    if (iter==1) {
      phiR_k <- phiR_z
      phiF_k <- phiF_z
    } else {
      phiR_k <- vecUpdate(phiR_k, phiR_z, 0.8)
      phiF_k <- vecUpdate(phiF_k, phiF_z, 0.8)
    }

    iter <- iter+1
  }
  
  if(conv<=tol){
    print(paste0("Phi's converged to <=", tol, " in ", iter-1, " iterations."))
    olist <- list(Ri = phiR_z,
                  Fj = phiF_z,
                  iter = iter)
    
    return(olist)
  } else {
    stop("Phi's did not converge in <10000 iterations.") 
  }
}

################
# helper function

cSums <- function(mat, n){
  # Column sum that force returns a row vector
  matrix(.colSums(mat, n, n, na.rm = TRUE), 1, n)
}

rSums <- function(mat, n){
  # Row sum that force returns a column vector
  matrix(.rowSums(mat, n, n, na.rm = TRUE), n, 1)
}

cExpand <- function(mat, cvec, n){
  # Repeat-mulitplies a column vector to all columns of a matrix
  matrix(rep(cvec, n), n, n) * mat
}

rExpand <- function(mat, rvec, n){
  # Repeat-mulitplies a row vector to all rows of a matrix
  matrix(rep(rvec, n), n, n, byrow=TRUE) * mat
}

cvecNormDist <- function(vec0, vec1, n){
  colSums(abs(vec0 - vec1))/n
}

rvecNormDist <- function(vec0, vec1, n){
  rowSums(abs(vec0 - vec1))/n
}

vecUpdate <- function(vec0, vec1, wt){
  # Update vec with weight wt on vec1 and (1-wt) on vec0
  (1-wt)*vec0 + wt*vec1
}
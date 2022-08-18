
## FUNCTIONS
################
# data prep functions 

prepdata <- function(rawmat) {
  zips <- rawmat$zcta
  n <- ncol(rawmat)-1
  
  dmat <- as.matrix(rawmat[,1:n+1])   
  
  list(dmat=dmat,
       zips=zips,
       nz=n)
}


################
# solver functions
findphi <- function(dmthta, LF, LR, nz, tol=0.00000001) {
  
  phiR_k <- rep(1000, 1, nz) 
  phiF_k <- rep(1000, 1, nz) 
  
  conv <- 1
  iter <- 1
  
  while (conv>tol && iter<1000) {
    
    phiR_z <- rSums(rExpand(dmthta, LF/phiF_k, nz), nz)
    phiF_z <- cSums(cExpand(dmthta, LR/phiR_k, nz), nz)
    
    conv <- cvecNormDist(phiR_z, phiR_k, nz) + rvecNormDist(phiF_z, phiF_k, nz)

    if (iter==1) {
      phiR_k <- phiR_z
      phiF_k <- phiF_z
    } else {
      phiR_k <- vecUpdate(phiR_k, phiR_z, 0.75)
      phiF_k <- vecUpdate(phiF_k, phiF_z, 0.75)
    }
    
    iter <- iter+1
  }
  
  if(conv<=tol){
    print(paste0("Phi's converged to <=", tol, " in ", iter-1, " iterations."))
    olist <- list(Ri = phiR_z,
                  Fj = phiF_z)
    
    return(olist)
  } else {
    stop("Phi's did not converge in <1000 iterations.") 
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
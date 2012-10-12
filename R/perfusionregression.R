perfusionregression <- function( mask_img , mat , xideal , nuis , m0, dorobust = 0 )
{
getPckg <- function(pckg) install.packages(pckg, repos = "http://cran.r-project.org")

print("standard regression")
cbfform<-formula(  mat ~   xideal )
rcbfform<-formula(  mat[,vox] ~   xideal )
if ( ! is.null( nuis ) )
  {
  cbfform<-formula(  mat ~   xideal + nuis )
  rcbfform<-formula(  mat[,vox] ~   xideal + nuis )
  }
mycbfmodel<-lm( cbfform  ) # standard regression
betaideal<-(mycbfmodel$coeff)[2,]
cbfi <- antsImageClone( mask_img )
m0vals <-m0[ mask_img == 1 ]
m0vals[ m0vals ==  0] <- mean( m0vals , na.rm = T)
cbfi[ mask_img == 1 ] <- betaideal / m0vals

if ( dorobust > 0 )
  {
  pckg = try(require(robust))
  if(!pckg) 
    {
    cat("Installing 'robust' from CRAN\n")
    getPckg("robust")
    require("robust")
    }
  # robust procedure Yohai, V.J. (1987) High breakdown-point and high efficiency estimates for regression.  _The Annals of Statistics_ *15*, 642-65
  if ( dorobust > 1 ) { print("dorobust too large, setting to 0.95"); dorobust <- 0.95; }
  print(paste("begin robust regression:",dorobust*100,"%"))
  ctl<-lmrob.control( "KS2011", max.it = 1000 )
  regweights<-rep(0,nrow(mat))
  rbetaideal<-rep(0,ncol(mat))
  vox<-1
  ct<-0
  skip<-20
  visitvals<-( skip:floor( (ncol(mat)-1) / skip ) ) * skip
  print( dim(nuis) )
  mynodes<-round( detectCores() / 2 ) # round( getOption("mc.cores", 2L) / 2 )
  print( paste( "nodes:" , mynodes ) )
#  cl<-makeForkCluster( nnodes = mynodes )
#  registerDoParallel( cl , cores = mynodes ) 
  rgw<-regweights
  myct<-0
  ptime <- system.time({
#  rgw<-foreach(vox=visitvals,.combine="+",.init=regweights,.verbose=F) %dopar% {
  for ( vox in visitvals ) {
    try(  mycbfmodel<-lmrob( rcbfform , control = ctl ) , silent=T )
    rbetaideal[vox]<-mycbfmodel$coeff[2]
    if ( ! is.null(   mycbfmodel$weights ) )
      {
      rgw<-rgw + mycbfmodel$weights
      myct<-myct+1 
      }
    }
  })
  regweights<-(rgw/myct)
  print(paste("donewithrobreg",myct))
  print(regweights)
  print(paste(ptime))
  # now use the weights in a weighted regression
  indstozero<-which( regweights < ( dorobust * max(regweights ) ) )
  if ( length( indstozero ) < 20 ) 
    {
    indstozero<-which( regweights < ( 0.95 * dorobust * max(regweights ) ) )
    }
  if ( length( indstozero ) < 20 ) 
    {
    indstozero<-which( regweights < ( 0.50 * dorobust * max(regweights ) ) )
    }
  regweights[ indstozero ]<-0 # hard thresholding 
  print(regweights)
  mycbfmodel<-lm( cbfform , weights = regweights ) # standard weighted regression
  betaideal<-(mycbfmodel$coeff)[2,]
  cbfi[ mask_img == 1 ] <- betaideal / m0vals # robust results
  print(paste("Rejected",length( indstozero ) / nrow( mat ) * 100 ," % " ))
  }
return( cbfi )
}
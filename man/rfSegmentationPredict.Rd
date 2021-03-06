% Generated by roxygen2 (4.1.0): do not edit by hand
% Please edit documentation in R/rfSegmentationPredict.R
\name{rfSegmentationPredict}
\alias{rfSegmentationPredict}
\title{A rfSegmentationPredict function.}
\usage{
rfSegmentationPredict(rfSegmentationModel, featureimages, mask,
  verbose = FALSE)
}
\arguments{
\item{rfSegmentationModel}{input rf model}

\item{featureimages}{input list of antsImage feature images}

\item{mask}{antsImage mask}

\item{verbose}{bool}
}
\value{
segmentation is output
}
\description{
Predict image segmentation via random forests.
}
\examples{
if ( usePkg('randomForest') ) {
img<-antsImageRead( getANTsRData("r16") ,2)
mask<-getMask( img )
mask2<-getMask( img )
mask<-iMath(mask,'ME',25)
mask2[ mask == 1 ]<-0
segs<-kmeansSegmentation( img, k=3, kmask = mask)
fimgs<-list( img )
rfsegs<-rfSegmentation( segs$segmentation, fimgs , ntrees=100 )
rfseg2<-rfSegmentationPredict(  rfsegs$rfModel , fimgs , mask2 )
plot( rfseg2 )
}
}
\author{
Tustison NJ, Avants BB
}


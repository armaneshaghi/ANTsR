#' LabelGeometryMeasures
#'
#' Wrapper for the ANTs funtion LabelGeometryMeasures
#'
#' @param ... see ants function
#' @return none
#' @author Avants BB
#'
#' @export LabelGeometryMeasures
LabelGeometryMeasures <- function(...) {
  veccer <- c(...)
  veccer2 <- veccer
  if (length(veccer) > 1) {
    img1 <- antsImageClone(veccer[[2]])
    img1int <- antsImageClone(img1, "unsigned int")
    veccer2[[2]] <- img1int
  }
  pp <- .Call("LabelGeometryMeasures", .int_antsProcessArguments(veccer2))
}

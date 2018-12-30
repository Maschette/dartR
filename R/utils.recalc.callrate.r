#' A utility script to recalculate the callrate by locus after some populations have been deleted
#'
#' SNP datasets generated by DArT have missing values primarily arising from failure to call a SNP because of a mutation
#' at one or both of the the restriction enzyme recognition sites. The locus metadata supplied by DArT has callrate included,
#' but the call rate will change when some individuals are removed from the dataset. This script recalculates the callrate
#' and places these recalculated values in the appropriate place in the genlight object.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param v -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' @return The modified genlight object
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' #result <- dartR:::utils.recalc.callrate(testset.gl)

utils.recalc.callrate <- function(x, v=2) {
 
  if(class(x)!="genlight") {
    cat("Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  # Work around a bug in adegenet if genlight object is created by subsetting
  x@other$loc.metrics <- x@other$loc.metrics[1:nLoc(x),]
  
  if (v > 0) {
    cat("Starting utils.recalc.callrate: Recalculating CallRate\n")
  }
  if (is.null(x@other$loc.metrics$CallRate)) {
    x@other$loc.metrics$CallRate <- array(NA,nLoc(x))
    if (v >= 3){
      cat("  Locus metric CallRate does not exist, creating slot @other$loc.metrics$CallRate\n")
    }
  }
  # Do the deed
     x@other$loc.metrics$CallRate <- 1-(glNA(x,alleleAsUnit=FALSE))/nInd(x)

  if (v > 0) {
    cat("Completed: utils.recalc.callrate\n\n")
  }
     
   return(x)
}


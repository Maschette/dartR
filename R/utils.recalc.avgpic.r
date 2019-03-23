#' A utility script to recalculate the OneRatioRef, OneRatioSnp, PICRef, PICSnp, and AvgPIC by locus after some
#' populations have been deleted.
#'
#' The locus metadata supplied by DArT has OneRatioRef, OneRatioSnp, PICRef, PICSnp, and AvgPIC included,
#' but the allelec composition will change when some individuals are removed from the dataset and so the initial statistics will
#' no longer apply. This script recalculates these statistics and places the recalculated values in the appropriate place 
#' in the genlight object.
#' 
#' If the locus metadata OneRatioRef|Snp, PICRef|Snp and/or AvgPIC do not exist, the script
#' creates and populates them.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]
#' @return The modified genlight object
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @seealso \code{\link{utils.recalc.metrics}} for recalculating all metrics, \code{\link{utils.recalc.callrate}} for recalculating CallRate,
#' \code{\link{utils.recalc.freqhomref}} for recalculating frequency of homozygous reference, \code{\link{utils.recalc.freqhomsnp}} for recalculating frequency of homozygous alternate,
#' \code{\link{utils.recalc.freqhet}} for recalculating frequency of heterozygotes, \code{\link{gl.recalc.maf}} for recalculating minor allele frequency,
#' \code{\link{gl.recalc.rdepth}} for recalculating average read depth
#' @examples
#' #result <- utils.recalc.avgpic(testset.gl)

utils.recalc.avgpic <- function(x, verbose=2) {

# TIDY UP FILE SPECS

  outfilespec <- file.path(outpath, outfile)
  funname <- match.call()[[1]]

# FLAG SCRIPT START

  if (verbose < 0 | verbose > 5){
    cat("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n")
    verbose <- 2
  }

  if (verbose > 0) {
    cat("Starting",funname,"\n")
  }

# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
  # Work around a bug in adegenet if genlight object is created by subsetting
    x@other$loc.metrics <- x@other$loc.metrics[1:nLoc(x),]
  # Set a population if none is specified (such as if the genlight object has been generated manually)
    if (is.null(pop(x)) | is.na(length(pop(x))) | length(pop(x)) <= 0) {
      if (verbose >= 2){ cat("  Population assignments not detected, individuals assigned to a single population labelled 'pop1'\n")}
      pop(x) <- array("pop1",dim = nLoc(x))
      pop(x) <- as.factor(pop(x))
    }
  # Check for monomorphic loci
    tmp <- gl.filter.monomorphs(x)
    if ((nLoc(tmp) < nLoc(x)) & verbose >= 2) {cat("  Warning: genlight object contains monomorphic loci\n")}

# FUNCTION SPECIFIC ERROR CHECKING

  if (is.null(x@other$loc.metrics$AvgPIC)) {
    x@other$loc.metrics$AvgPIC <- array(NA,nLoc(x))
    if (verbose >= 3){
      cat("  Locus metric AvgPIC does not exist, creating slot @other$loc.metrics$AvgPIC\n")
    }
  }
  if (is.null(x@other$loc.metrics$OneRatioRef)) {
    x@other$loc.metrics$OneRatioRef <- array(NA,nLoc(x))
    if (verbose >= 3){
      cat("  Locus metric OneRatioRef does not exist, creating slot @other$loc.metrics$OneRatioRef\n")
    }
  }
  if (is.null(x@other$loc.metrics$OneRatioSnp)) {
    x@other$loc.metrics$OneRatioSnp <- array(NA,nLoc(x))
    if (verbose >= 3){
      cat("  Locus metric OneRatioSnp does not exist, creating slot @other$loc.metrics$OneRatioSnp\n")
    }
  }
  if (is.null(x@other$loc.metrics$PICRef)) {
    x@other$loc.metrics$PICRef <- array(NA,nLoc(x))
    if (verbose >= 3){
      cat("  Locus metric PICRef does not exist, creating slot @other$loc.metrics$PICRef\n")
    }
  }
  if (is.null(x@other$loc.metrics$PICSnp)) {
    x@other$loc.metrics$PICSnp <- array(NA,nLoc(x))
    if (verbose >= 3){
      cat("  Locus metric PICSnp does not exist, creating slot @other$loc.metrics$PICSnp\n")
    }
  }

# DO THE JOB

     t <- as.matrix(x)
       if (verbose >= 2){cat("  Recalculating OneRatioRef, OneRatioSnp, PICRef, PICSnp, AvgPIC\n")}
     
     for (i in 1:nLoc(x)) {
       c0 <- length(t[t[,i]==0 & !is.na(t[,i]),i])
       c1 <- length(t[t[,i]==1 & !is.na(t[,i]),i])
       c2 <- length(t[t[,i]==2 & !is.na(t[,i]),i])
       c <- (c0+c1+c2)
       x@other$loc.metrics$OneRatioRef[i] <- (c0+c1)/c
       x@other$loc.metrics$OneRatioSnp[i] <- (c1+c2)/c
       OneRatioRef <- x@other$loc.metrics$OneRatioRef[i]
       OneRatioSnp <- x@other$loc.metrics$OneRatioSnp[i]
       ZeroRatioRef <- 1 - OneRatioRef
       ZeroRatioSnp <- 1 - OneRatioSnp
       x@other$loc.metrics$PICRef[i] <- 1 - ((OneRatioRef*OneRatioRef) + (ZeroRatioRef*ZeroRatioRef))
       x@other$loc.metrics$PICSnp[i] <- 1 - ((OneRatioSnp*OneRatioSnp) + (ZeroRatioSnp*ZeroRatioSnp))
       x@other$loc.metrics$AvgPIC[i] <- (x@other$loc.metrics$PICRef[i] + x@other$loc.metrics$PICSnp[i])/2
     }

# FLAG SCRIPT END

  if (verbose > 0) {
    cat("Completed:",funname,"\n")
  }

   return(x)
}

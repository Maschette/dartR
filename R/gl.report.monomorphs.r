#' Report monomorphic loci
#'
#' This script reports the number of monomorphic locim and those with all NAsm from a genlight \{adegenet\} object
#'
#' A DArT dataset will not have monomorphic loci, but they can arise, along with loci that are scored all NA, when populations or individuals are deleted.
#' Retaining monomorphic loci unnecessarily increases the size of the dataset and will affect some calculations.
#' 
#' Note that for SNP data, NAs likely represent null alleles; in tag presence/absence data, NAs represent missing values (presence/absence could not 
#' be reliably scored)
#' 
#' @param x -- name of the input genlight object [required]
#' @param silent -- if FALSE, function returns an object, otherwise NULL [default TRUE]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default NULL]
#' @return NULL
#' @rawNamespace import(adegenet, except = plot)
#' @import plyr utils
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#' gl.report.monomorphs(testset.gl)
#' # SilicoDArT data
#' #gl.report.monomorphs(testset.gs)

gl.report.monomorphs <- function (x, silent=TRUE, verbose=NULL) {
  
# TRAP COMMAND, SET VERSION

  funname <- match.call()[[1]]
  build <- "Jacob"

# SET VERBOSITY
  # set verbosity
  if (is.null(verbose) & !is.null(x@other$verbose)) verbose=x@other$verbose
  if (is.null(verbose)) verbose=2
  
 
  if (verbose < 0 | verbose > 5){
      cat(paste("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to default 2\n"))
      verbose <- 2
  }

# FLAG SCRIPT START


  if (verbose >= 1){
    cat("Starting",funname,"\n")
  }
  
  # STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    stop("Fatal Error: genlight object required!")
  }
  
  if (all(x@ploidy == 1)){
    cat("  Processing Presence/Absence (SilicoDArT) data\n")
    data.type <- "SilicoDArT"
  } else if (all(x@ploidy == 2)){
    cat("  Processing a SNP dataset\n")
    data.type <- "SNP"
  } else {
    stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)!")
  }
  
# DO THE JOB
  
  hold <- x
  na.counter <- 0
  loc.list <- array(NA,nLoc(x))
  
  if (verbose >= 2){
    cat("  Identifying monomorphic loci\n")
  }  
  # Tag presence/absence data
  if (data.type=="SilicoDArT"){
    mat <- as.matrix(x)
    lN <- locNames(x)
    for (i in 1:nLoc(x)){
      row <- mat[,i] # Row for each locus
      if (all(row == 0, na.rm=TRUE) | all(row == 1, na.rm=TRUE) | all(is.na(row))){
        loc.list[i] <- lN[i]
        if (all(is.na(row))){
          na.counter = na.counter + 1
        }
      }
    }                          
  } 
  
  # SNP data
  if (data.type=="SNP"){
    mat <- as.matrix(x)
    lN <- locNames(x)
    for (i in 1:nLoc(x)){
      row <- mat[,i] # Row for each locus
      if (all(row == 0, na.rm=TRUE) | all(row == 2, na.rm=TRUE) | all(is.na(row))){
        loc.list[i] <- lN[i]
        if (all(is.na(row))){
          na.counter = na.counter + 1
        }
      }
    }                          
  } 
  
  # Remove NAs from list of monomorphic loci and loci with all NAs
  loc.list <- loc.list[!is.na(loc.list)]
  
  # remove monomorphic loc and loci with all NAs
  if(length(loc.list) > 0){
    x <- gl.drop.loc(x,loc.list=loc.list,verbose=0)
  } 
  
  # Report results
    cat("\n  No. of loci:",nLoc(hold),"\n")
    cat("    Polymorphic loci:", nLoc(x),"\n")
    cat("    Monomorphic loci:", nLoc(hold)-nLoc(x)-na.counter,"\n")
    cat("    Loci scored all NA:",na.counter,"\n")
    cat("  No. of individuals:",nInd(x),"\n")
    cat("  No. of populations:",nPop(x),"\n\n")

# FLAG SCRIPT END

    if (verbose > 0) {
      cat("Completed:",funname,"\n")
    }
    
    if(silent==TRUE){
      return(NULL)
    } else{
      return(NULL)
    } 

}


% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.recalc.callrate.r
\name{utils.recalc.callrate}
\alias{utils.recalc.callrate}
\title{A utility script to recalculate the callrate by locus after some populations have been deleted}
\usage{
utils.recalc.callrate(x, v = 2)
}
\arguments{
\item{x}{-- name of the genlight object containing the SNP data [required]}

\item{v}{-- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2]}
}
\value{
The modified genlight object
}
\description{
SNP datasets generated by DArT have missing values primarily arising from failure to call a SNP because of a mutation
at one or both of the the restriction enzyme recognition sites. The locus metadata supplied by DArT has callrate included,
but the call rate will change when some individuals are removed from the dataset. This script recalculates the callrate
and places these recalculated values in the appropriate place in the genlight object.
}
\examples{
result <- dartR:::utils.recalc.callrate(testset.gl)
}
\author{
Arthur Georges (glbugs@aerg.canberra.edu.au)
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilMWRinputcheck.R
\name{utilMWRinputcheck}
\alias{utilMWRinputcheck}
\title{Check if required inputs are present for a function}
\usage{
utilMWRinputcheck(inputs, nocheck = NULL)
}
\arguments{
\item{inputs}{list of arguments passed from the parent function}

\item{nocheck}{optional character vector of inputs not to check, allows for optional inputs}
}
\value{
NULL if all inputs are present, otherwise an error message indicating which inputs are missing
}
\description{
Check if required inputs are present for a function
}
\examples{
inputchk <- formals(tabMWRcom)
inputchk$res <- system.file('extdata/ExampleResults.xlsx', package = 'MassWateR')
inputchk$frecom <- system.file('extdata/ExampleDQOFrequencyCompleteness.xlsx', 
  package = 'MassWateR')
inputchk$cens <- system.file('extdata/ExampleCensored.xlsx', package = 'MassWateR')

utilMWRinputcheck(inputchk)
}

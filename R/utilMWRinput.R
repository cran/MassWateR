#' Utility function to import data as paths or data frames
#' 
#' @param res character string of path to the results file or \code{data.frame} for results returned by \code{\link{readMWRresults}}
#' @param acc character string of path to the data quality objectives file for accuracy or \code{data.frame} returned by \code{\link{readMWRacc}}
#' @param frecom character string of path to the data quality objectives file for frequency and completeness or \code{data.frame} returned by \code{\link{readMWRfrecom}}
#' @param sit character string of path to the site metadata file or \code{data.frame} for site metadata returned by \code{\link{readMWRsites}}
#' @param wqx character string of path to the wqx metadata file or \code{data.frame} for wqx metadata returned by \code{\link{readMWRwqx}}
#' @param cens character string of path to the censored data file or \code{data.frame} for censored data returned by \code{\link{readMWRcens}}
#' @param fset optional list of inputs with elements named \code{res}, \code{acc}, \code{frecom}, \code{sit}, \code{wqx}, or \code{cens}, overrides the other arguments, see details
#' @param runchk  logical to run data checks with \code{\link{checkMWRresults}}, \code{\link{checkMWRacc}}, \code{\link{checkMWRfrecom}}, \code{\link{checkMWRsites}}, \code{\link{checkMWRwqx}}, or \code{\link{checkMWRcens}}, applies only if \code{res}, \code{acc}, \code{frecom}, \code{sit}, \code{wqx}, or \code{cens} are file paths
#' @param warn logical to return warnings to the console (default)
#'
#' @details The function is used internally by others to import data from paths to the relevant files or as data frames returned by \code{\link{readMWRresults}}, \code{\link{readMWRacc}}, \code{\link{readMWRfrecom}}, \code{\link{readMWRsites}}, \code{\link{readMWRwqx}}, or \code{\link{readMWRcens}}.  For the former, the full suite of data checks can be evaluated with \code{runkchk = T} (default) or suppressed with \code{runchk = F}.
#' 
#' The \code{fset} argument can used in place of the preceding arguments. The argument accepts a list with named elements as \code{res}, \code{acc}, \code{frecom}, \code{sit}, \code{wqx}, or \code{cens}, where the elements are either character strings of the path or data frames to the corresponding inputs. Missing elements will be interpreted as \code{NULL} values.  This argument is provided as convenience to apply a single list as input versus separate inputs for each argument. 
#' 
#' Any of the arguments for the data files can be \code{NULL}, used as a convenience for downstream functions that do not require all. 
#'
#' @return A six element list with the imported results, data quality objective files, site metadata, wqx metadata, and censored data named \code{"resdat"}, \code{"accdat"}, \code{"frecomdat"}, \code{"sitdat"}, \code{"wqxdat"}, and \code{"censdat"} respectively.
#' 
#' @export
#'
#' @examples
#' ##
#' # using file paths
#' 
#' # results path
#' respth <- system.file('extdata/ExampleResults.xlsx', package = 'MassWateR')
#' 
#' # accuracy path
#' accpth <- system.file('extdata/ExampleDQOAccuracy.xlsx', package = 'MassWateR')
#' 
#' # frequency and completeness path
#' frecompth <- system.file('extdata/ExampleDQOFrequencyCompleteness.xlsx', 
#'      package = 'MassWateR')
#' 
#' # site path
#' sitpth <- system.file('extdata/ExampleSites.xlsx', package = 'MassWateR')
#' 
#' # wqx path
#' wqxpth <- system.file('extdata/ExampleWQX.xlsx', package = 'MassWateR')
#' 
#' # censored path
#' censpth <- system.file('extdata/ExampleCensored.xlsx', package = 'MassWateR')
#' 
#' inp <- utilMWRinput(res = respth, acc = accpth, frecom = frecompth, sit = sitpth, 
#'   wqx = wqxpth, cens = censpth)
#' inp$resdat
#' inp$accdat
#' inp$frecomdat
#' inp$sitdat
#' inp$wqxdat
#' inp$censdat
#' 
#' ##
#' # using data frames
#' 
#' # results data
#' resdat <- readMWRresults(respth)
#' 
#' # accuracy data
#' accdat <- readMWRacc(accpth)
#' 
#' # frequency and completeness data
#' frecomdat <- readMWRfrecom(frecompth)
#' 
#' # site data
#' sitdat <- readMWRsites(sitpth)
#' 
#' # wqx data
#' wqxdat <- readMWRwqx(wqxpth)
#' 
#' # censored data
#' censdat <- readMWRcens(censpth)
#' 
#' inp <- utilMWRinput(res = resdat, acc = accdat, frecom = frecomdat, sit = sitdat, 
#'    wqx = wqxdat, cens = censdat)
#' inp$resdat
#' inp$accdat
#' inp$frecomdat
#' inp$sitdat
#' inp$wqxdat
#' inp$censdat
#' 
#' ##
#' # using fset as list input
#' 
#' # input with paths to files
#' fset <- list(
#'   res = respth, 
#'   acc = accpth, 
#'   frecom = frecompth,
#'   sit = sitpth, 
#'   wqx = wqxpth, 
#'   cens = censpth
#' )
#' utilMWRinput(fset = fset)
utilMWRinput <- function(res = NULL, acc = NULL, frecom = NULL, sit = NULL, wqx = NULL, cens = NULL, fset = NULL, runchk = TRUE, warn = TRUE){
  
  ##
  # fset argument for list of files inputs
  if(!is.null(fset)){
    
    res <- fset$res
    acc <- fset$acc
    frecom <- fset$frecom
    sit <- fset$sit
    wqx <- fset$wqx
    cens <- fset$cens
  
  }
  
  ##
  # results input
  
  # data frame
  if(inherits(res, 'data.frame'))
    resdat <- res
  
  # import from path
  if(inherits(res, 'character')){
    
    respth <- res
    chk <- file.exists(respth)
    if(!chk)
      stop('File specified with res not found')
    
    resdat <- readMWRresults(respth, runchk = runchk, warn = warn)
    
  }
  
  if(inherits(res, 'NULL'))
    resdat <-  NULL
  
  ##
  # dqo accuracy input
  
  # data frame
  if(inherits(acc, 'data.frame'))
    accdat <- acc
  
  # import from path
  if(inherits(acc, 'character')){
    
    accpth <- acc
    chk <- file.exists(accpth)
    if(!chk)
      stop('File specified with acc not found')
    
    accdat <- readMWRacc(accpth, runchk = runchk, warn = warn)
    
  }
  
  if(inherits(acc, 'NULL'))
    accdat <-  NULL
  
  ##
  # dqo frequency and completeness input
  
  # data frame
  if(inherits(frecom, 'data.frame'))
    frecomdat <- frecom
  
  # import from path
  if(inherits(frecom, 'character')){
    
    frecompth <- frecom
    chk <- file.exists(frecompth)
    if(!chk)
      stop('File specified with frecom not found')
    
    frecomdat <- readMWRfrecom(frecompth, runchk = runchk, warn = warn)
    
  }
  
  if(inherits(frecom, 'NULL'))
    frecomdat <- NULL

  ##
  # site data

  # data frame
  if(inherits(sit, 'data.frame'))
    sitdat <- sit
  
  # import from path
  if(inherits(sit, 'character')){
    
    sitpth <- sit
    chk <- file.exists(sitpth)
    if(!chk)
      stop('File specified with sit not found')
    
    sitdat <- readMWRsites(sitpth, runchk = runchk)
    
  }
  
  if(inherits(sit, 'NULL'))
    sitdat <- NULL
  
  ##
  # wqx data
  
  # data frame
  if(inherits(wqx, 'data.frame'))
    wqxdat <- wqx
  
  # import from path
  if(inherits(wqx, 'character')){
    
    wqxpth <- wqx
    chk <- file.exists(wqxpth)
    if(!chk)
      stop('File specified with wqx not found')
    
    wqxdat <- readMWRwqx(wqxpth, runchk = runchk, warn = warn)
    
  }
  
  if(inherits(wqx, 'NULL'))
    wqxdat <- NULL
  
  ##
  # censored data
  
  # data frame
  if(inherits(cens, 'data.frame'))
    censdat <- cens
  
  # import from path
  if(inherits(cens, 'character')){
    
    censpth <- cens
    chk <- file.exists(censpth)
    if(!chk)
      stop('File specified with cens not found')
    
    censdat <- readMWRcens(censpth, runchk = runchk, warn = warn)
    
  }
  
  if(inherits(cens, 'NULL'))
    censdat <- NULL
  
  ##
  # output
  
  out <- list(
    resdat = resdat,
    accdat = accdat,
    frecomdat = frecomdat,
    sitdat = sitdat,
    wqxdat = wqxdat,
    censdat = censdat
  )
  
  return(out)
  
}

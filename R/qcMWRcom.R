#' Run quality control completeness checks for water quality monitoring results
#'
#' @param res character string of path to the results file or \code{data.frame} for results returned by \code{\link{readMWRresults}}
#' @param frecom character string of path to the data quality objectives file for frequency and completeness or \code{data.frame} returned by \code{\link{readMWRfrecom}}
#' @param cens character string of path to the censored data file or \code{data.frame} returned by \code{\link{readMWRcens}}, optional
#' @param fset optional list of inputs with elements named \code{res}, \code{acc}, \code{frecom}, \code{sit}, or \code{wqx} overrides the other arguments
#' @param runchk  logical to run data checks with \code{\link{checkMWRresults}} and \code{\link{checkMWRfrecom}}, applies only if \code{res} or \code{frecom} are file paths
#' @param warn logical to return warnings to the console (default)
#'
#' @details The function can be used with inputs as paths to the relevant files or as data frames returned by \code{\link{readMWRresults}}, \code{\link{readMWRfrecom}}, and \code{\link{readMWRcens}} (optional).  For the former, the full suite of data checks can be evaluated with \code{runkchk = T} (default) or suppressed with \code{runchk = F}.  In the latter case, downstream analyses may not work if data are formatted incorrectly. For convenience, a named list with the input arguments as paths or data frames can be passed to the \code{fset} argument instead. See the help file for \code{\link{utilMWRinput}}.
#' 
#' Note that frequency is only evaluated on parameters in the \code{Parameter} column in the data quality objectives frequency and completeness file.  A warning is returned if there are parameters in \code{Parameter} in the frequency and completeness file that are not in \code{Characteristic Name} in the results file. 
#' 
#' Similarly, parameters in the results file in the \code{Characteristic Name} column that are not found in the data quality objectives frequency and completeness file are not evaluated.  A warning is returned if there are parameters in \code{Characteristic Name} in the results file that are not in \code{Parameter} in the frequency and completeness file.  
#' 
#' A similar warning is returned if there are parameters in the censored data, if provided, that are not in the results file.  However, an error is returned if there are parameters in the data quality objectives frequency and completeness file that are not in the censored data file. 
#' 
#' All warnings can be suppressed by setting \code{warn = FALSE}. 
#' 
#' @return The output shows the completeness checks from the combined files.  Each row applies to a completeness check for a parameter. The \code{datarec} and \code{qualrec} columns show the number of data records and qualified records, respectively. The \code{datarec} column specifically shows only records not for quality control by excluding those as duplicates, blanks, or spikes in the count. The \code{standard} column shows the relevant percentage required for the quality control check from the quality control objectives file, the \code{complete} column shows the calculated completeness taken from the input data, and the \code{met} column shows if the standard was met by comparing if \code{complete} is greater than or equal to \code{standard}.
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
#' # frequency and completeness path
#' frecompth <- system.file('extdata/ExampleDQOFrequencyCompleteness.xlsx', 
#'      package = 'MassWateR')
#'
#' # censored path
#' censpth <- system.file('extdata/ExampleCensored.xlsx', 
#'      package = 'MassWateR')
#' 
#' qcMWRcom(res = respth, frecom = frecompth, cens = censpth)
#' 
#' ##
#' # using data frames
#' 
#' # results data
#' resdat <- readMWRresults(respth)
#' 
#' # frequency and completeness data
#' frecomdat <- readMWRfrecom(frecompth)
#' 
#' # censored data
#' censdat <- readMWRcens(censpth)
#' 
#' qcMWRcom(res = resdat, frecom = frecomdat, cens = censdat)
#' 
qcMWRcom <- function(res = NULL, frecom = NULL, cens = NULL, fset = NULL, runchk = TRUE, warn = TRUE){
  
  utilMWRinputcheck(mget(ls()), 'cens')
  
  ##
  # get user inputs
  inp <- utilMWRinput(res = res, frecom = frecom, cens = cens, fset = fset, runchk = runchk, warn = warn)
  resdat <- inp$resdat
  frecomdat <- inp$frecomdat
  censdat <- inp$censdat
  
  ##
  # check parameter matches between results and completeness
  frecomprm <- sort(unique(frecomdat$Parameter))
  resdatprm <- sort(unique(resdat$`Characteristic Name`))
  
  # check parameters in completeness can be found in results  
  chk <- frecomprm %in% resdatprm
  if(any(!chk) & warn){
    tochk <- frecomprm[!chk]
    warning('Parameters in quality control objectives for frequency and completeness not found in results data: ', paste(tochk, collapse = ', '), call. = FALSE)
  }
  
  # check parameters in results can be found in completeness
  chk <- resdatprm %in% frecomprm
  if(any(!chk) & warn){
    tochk <- resdatprm[!chk]
    warning('Parameters in results data not found in quality control objectives for frequency and completeness: ', paste(tochk, collapse = ', '), call. = FALSE)
  }
  
  ##
  # check parameter matches between results and censored, only if censored data provided
  if(!is.null(censdat)){
    
    censprm <- sort(unique(censdat$Parameter))
    resdatprm <- sort(unique(resdat$`Characteristic Name`))
    
    # check parameters in censored can be found in results  
    chk <- censprm %in% resdatprm
    if(any(!chk) & warn){
      tochk <- censprm[!chk]
      warning('Parameters in censored data not found in results data: ', paste(tochk, collapse = ', '), call. = FALSE)
    }
    
    # check parameters in completeness can be found in censored
    chk <- frecomprm %in% censprm
    if(any(!chk) & warn){
      tochk <- resdatprm[!chk]
      stop('Parameters in quality control objectives for frequency and completeness data not found in censored data: ', paste(tochk, collapse = ', '), call. = FALSE)
    }

  }
  
  # parameters for completeness checks
  prms <- intersect(resdatprm, frecomprm)

  resall <- NULL
  
  # run completeness checks
  for(prm in prms){
    
    # subset results data
    resdattmp <- resdat %>% 
      dplyr::filter(`Characteristic Name` == prm)

    # number of qualified records
    qualrec <- sum(!is.na(resdattmp$`Result Measure Qualifier`), na.rm = TRUE)
    
    # number of data records
    datarec <- sum(resdattmp$`Activity Type` %in% c("Field Msr/Obs", "Sample-Routine"), na.rm = T)
    
    # compile results
    res <- tibble::tibble(
      Parameter = prm, 
      datarec = datarec,
      qualrec = qualrec
    )
    
    resall <- dplyr::bind_rows(resall, res)
    
  }

  # frecomdat long format
  frecomdat <- frecomdat %>% 
    dplyr::select(Parameter, standard = `% Completeness`)

  # combine
  resall <- resall %>% 
    dplyr::left_join(frecomdat, by = 'Parameter') 
  
  # add censored data if provided, otherwise enter 0
  if(!is.null(censdat)) {
    resall <- resall %>% 
      dplyr::left_join(censdat, by = 'Parameter')
  } else {
    resall$`Missed and Censored Records` <- 0L
  }
  
  # create summaries
  out <- resall %>% 
    dplyr::mutate(
      complete = ifelse(
        !is.na(standard), 100 * (1 - (qualrec + `Missed and Censored Records`) / (datarec + `Missed and Censored Records`)),
        NA_real_
      ),
      met = complete >= standard
    )
  
  return(out)
  
}

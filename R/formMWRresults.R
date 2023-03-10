#' Format water quality monitoring results
#'
#' @param resdat input data frame for results
#' @param tzone character string for time zone
#'
#' @details This function is used internally within \code{\link{readMWRresults}} to format the input data for downstream analysis.  The formatting includes:
#' 
#' \itemize{
#'   \item{Fix date and time inputs: }{Activity Start Date is converted to YYYY-MM-DD as a date object, Actvity Start Time is convered to HH:MM as a character to fix artifacts from Excel import},
#'   \item{Minor formatting for Result Unit: }{For conformance to WQX, e.g., ppt is changed to ppth, s.u. is changed to NA}
#'   \item{Convert characteristic names: }{All parameters in \code{Characteristic Name} are converted to \code{Simple Parameter} in \code{\link{paramsMWR}} as needed}
#' }
#' 
#' @import dplyr
#' @import tidyr
#' 
#' @return A formatted data frame of the water quality monitoring results file
#' 
#' @export
#'
#' @examples
#' library(dplyr)
#' 
#' respth <- system.file('extdata/ExampleResults.xlsx', package = 'MassWateR')
#' 
#' resdat <- suppressWarnings(readxl::read_excel(respth, na = c('NA', 'na', ''), guess_max = Inf)) %>% 
#'   dplyr::mutate_if(function(x) !lubridate::is.POSIXct(x), as.character)
#'   
#' formMWRresults(resdat)
formMWRresults <- function(resdat, tzone = 'America/Jamaica'){
  
  # format input
  out <- resdat %>% 
    mutate(
      `Activity Start Date` = lubridate::force_tz(`Activity Start Date`, tzone = tzone), 
      `Activity Start Date` = lubridate::ymd(`Activity Start Date`),
      `Activity Start Time` = gsub('^.*\\s', '', as.character(`Activity Start Time`)),
      `Activity Start Time` = gsub(':00$', '', `Activity Start Time`)
    )

  # convert ph s.u. to NA, salinity ppt to ppth 
  out <- out %>% 
    mutate(
      `Result Unit` = trimws(`Result Unit`),
      `Result Unit` = gsub('^ppt$', 'ppth', `Result Unit`) ,
      `Result Unit` = ifelse(
        `Characteristic Name` == 'pH' & `Result Unit` == 's.u.', 
        NA_character_, 
        `Result Unit`
      )
    )
  
  # convert all characteristic names to simple
  out <- dplyr::mutate(out, # match any entries in Characteristic Name that are WQX Parameter to Simple Parameter
    `Characteristic Name` = ifelse(
      `Characteristic Name` %in% paramsMWR$`WQX Parameter`,
      paramsMWR$`Simple Parameter`[match(`Characteristic Name`, paramsMWR$`WQX Parameter`)], 
      `Characteristic Name`
      )
    )
  
  return(out)
  
}

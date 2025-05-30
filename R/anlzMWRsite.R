#' Analyze data by sites in results file
#' 
#' Analyze data by sites in results file
#'
#' @param res character string of path to the results file or \code{data.frame} for results returned by \code{\link{readMWRresults}}
#' @param param character string of the parameter to plot, must conform to entries in the \code{"Simple Parameter"} column of \code{\link{paramsMWR}}
#' @param acc character string of path to the data quality objectives file for accuracy or \code{data.frame} returned by \code{\link{readMWRacc}}
#' @param sit optional character string of path to the site metadata file or \code{data.frame} of site metadata returned by \code{\link{readMWRsites}}, required if \code{locgroup} is not \code{NULL}
#' @param fset optional list of inputs with elements named \code{res}, \code{acc}, \code{frecom}, \code{sit}, or \code{wqx} overrides the other arguments
#' @param thresh character indicating if relevant freshwater or marine threshold lines are included, one of \code{"fresh"}, \code{"marine"}, or \code{"none"}, or a single numeric value to override the values included with the package
#' @param type character indicating \code{"box"}, \code{"jitterbox"}, \code{"bar"}, \code{"jitterbar"} or \code{"jitter"}, see details
#' @param threshlab optional character string indicating legend label for the threshold, required only if \code{thresh} is numeric
#' @param threshcol character indicating color of threshold lines if available
#' @param site character string of sites to include, default all
#' @param resultatt character string of result attributes to plot, default all
#' @param locgroup character string of location groups to plot from the \code{"Location Group"} column in the site metadata file, optional and only if \code{sit} is not \code{NULL}
#' @param dtrng character string of length two for the date ranges as YYYY-MM-DD, default all
#' @param confint logical indicating if confidence intervals are shown, only applies if \code{type} is \code{"bar"} or \code{"jitterbar"}
#' @param fill numeric indicating fill color for boxplots or barplots
#' @param alpha numeric from 0 to 1 indicating transparency of fill color
#' @param width numeric for width of boxplots or barplots
#' @param yscl character indicating one of \code{"auto"} (default), \code{"log"}, or \code{"linear"}, see details
#' @param sumfun character indicating one of \code{"auto"}, \code{"mean"}, \code{"geomean"}, \code{"median"}, \code{"min"}, or \code{"max"}, see details
#' @param byresultatt logical indicating if the plot has sites grouped separately by result attributes, see details
#' @param ttlsize numeric value indicating font size of the title relative to other text in the plot
#' @param bssize numeric for overall plot text scaling, passed to \code{\link[ggplot2]{theme_minimal}}
#' @param runchk logical to run data checks with \code{\link{checkMWRresults}} or \code{\link{checkMWRacc}}, applies only if \code{res} or \code{acc} are file paths
#' @param warn logical to return warnings to the console (default)
#'
#' @return A \code{\link[ggplot2]{ggplot}} object that can be further modified.
#' 
#' @details Summaries of a parameter for each site are shown as boxplots if \code{type = "box"} or as barplots if \code{type = "bar"}.  Points can be jittered over the boxplots by setting \code{type = "jitterbox"} or jittered over the barplots by setting \code{type = "jitterbar"}.  Setting \code{type = "jitter"} will show only the jittered points.  For \code{type = "bar"} or \code{type = "jitterbar"}, 95% confidence intervals can also be shown if \code{confint = TRUE} and they can be estimated (i.e., more than one result value per bar and \code{sumfun} is \code{"auto"}, \code{"mean"}, or \code{"geomean"}). 
#'
#' Threshold lines applicable to marine or freshwater environments can be included in the plot by using the \code{thresh} argument.  These thresholds are specific to each parameter and can be found in the \code{\link{thresholdMWR}} file.  Threshold lines are plotted only for those parameters with entries in \code{\link{thresholdMWR}} and only if the value in \code{`Result Unit`} matches those in \code{\link{thresholdMWR}}. The threshold lines can be suppressed by setting \code{thresh = 'none'}. A user-supplied numeric value can also be used for the \code{thresh} argument to override the default values. An appropriate label must also be supplied to \code{threshlab} if \code{thresh} is numeric.
#'  
#' The y-axis scaling as arithmetic (linear) or logarithmic can be set with the \code{yscl} argument.  If \code{yscl = "auto"} (default), the scaling is  determined automatically from the data quality objective file for accuracy, i.e., parameters with "log" in any of the columns are plotted on log10-scale, otherwise arithmetic. Setting \code{yscl = "linear"} or \code{yscl = "log"} will set the axis as linear or log10-scale, respectively, regardless of the information in the data quality objective file for accuracy.
#' 
#' Similarly, the data will be summarized if \code{type} is \code{"bar"} or \code{"jitterbar"} based on the value passed to \code{sumfun}.  The default if no value is provided to \code{sumfun} is to use the appropriate summary based on the value provided to \code{yscl}.  If \code{yscl = "auto"} (default), then \code{sumfun = "auto"}, and the mean or geometric mean is used for the summary based on information in the data quality objective file for accuracy. Using \code{yscl = "linear"} or \code{yscl = "log"} will default to the mean or geometric mean summary if no value is provided to \code{sumfun}.  Any other appropriate value passed to \code{sumfun} will override the value passed to \code{yscl}.  Valid summary functions for \code{sumfun} include \code{"auto"}, \code{"mean"}, \code{"geomean"}, \code{"median"}, \code{"min"}, or \code{"max"}). 
#' 
#' Any entries in \code{resdat} in the \code{"Result Value"} column as \code{"BDL"} or \code{"AQL"} are replaced with appropriate values in the \code{"Quantitation Limit"} column, if present, otherwise the \code{"MDL"} or \code{"UQL"} columns from the data quality objectives file for accuracy are used.  Values as \code{"BDL"} use one half of the appropriate limit.
#' 
#' The \code{byresultatt} argument can be used to group sites separately by result attributes.  For example, sites with E. coli samples can be grouped by \code{"Dry"} or \code{"Wet"} conditions if present in the \code{"Result Attribute"} column.   Filtering by sites first using the \code{site} argument is advised to reduce the amount of data that are plotted. The grouping can be filtered further by passing appropriate values in the \code{"Result Attribute"} column to the \code{resultatt} argument. Note that specifying result attributes with \code{resultatt} and setting \code{byresultatt = FALSE} will filter the plot data by the result attributes but will not plot the results separately. 
#' 
#' @export
#'
#' @examples
#' # results data path
#' respth <- system.file('extdata/ExampleResults.xlsx', package = 'MassWateR')
#' 
#' # results data
#' resdat <- readMWRresults(respth)
#' 
#' # accuracy path
#' accpth <- system.file('extdata/ExampleDQOAccuracy.xlsx', 
#'      package = 'MassWateR')
#' 
#' # accuracy data
#' accdat <- readMWRacc(accpth)
#' 
#' # site data path
#' sitpth <- system.file('extdata/ExampleSites.xlsx', package = 'MassWateR')
#' 
#' # site data
#' sitdat <- readMWRsites(sitpth)
#' 
#' # site trends, boxplot
#' anlzMWRsite(res = resdat, param = 'DO', acc = accdat, type = 'box', thresh = 'fresh')
#' 
#' # site trends, barplot
#' anlzMWRsite(res = resdat, param = 'DO', acc = accdat, type = 'bar', thresh = 'fresh')
#' 
#' # site trends, May to July only
#' anlzMWRsite(res = resdat, param = 'DO', acc = accdat, type = 'box', thresh = 'fresh',
#'      dtrng = c('2022-05-01', '2022-07-31'))
#'      
#' # grouping by result attribute
#' anlzMWRsite(res = resdat, param = 'DO', acc = accdat, type = 'box', thresh = 'fresh',
#'      site = c('ABT-062', 'ABT-077'), byresultatt = TRUE)
#'      
#' # site trends by location group, requires sitdat
#' anlzMWRsite(res = resdat, param = 'DO', acc = accdat, sit = sitdat, type = 'box', 
#'      thresh = 'fresh', locgroup = 'Assabet')
#'      
anlzMWRsite <- function(res = NULL, param, acc = NULL, sit = NULL, fset = NULL, type = c('box', 'jitterbox', 'bar', 'jitterbar', 'jitter'), thresh, threshlab = NULL, threshcol = 'tan', site = NULL, resultatt = NULL, locgroup = NULL, dtrng = NULL, confint = FALSE, fill = 'lightgreen', alpha = 0.8, width = 0.8, yscl = 'auto', sumfun = yscl, byresultatt = FALSE, ttlsize =  1.2, bssize = 11, runchk = TRUE, warn = TRUE){
  
  # remove site from input list check because optional
  chkin <- mget(ls())
  chkin <- chkin[!names(chkin) %in% 'sit']
  utilMWRinputcheck(chkin)
  
  type <- match.arg(type)
  
  # inputs
  inp <- utilMWRinput(res = res, acc = acc, sit = sit, fset = fset, runchk = runchk, warn = warn)
  
  # results data
  resdat <- utilMWRfiltersurface(inp$resdat) 
  
  # accuracy data
  accdat <- inp$accdat
  
  # site data
  sitdat <- inp$sitdat
  
  # filter
  resdat <- utilMWRfilter(resdat = resdat, sitdat = sitdat, param = param, dtrng = dtrng, site = site, resultatt = resultatt, locgroup = locgroup, allresultatt = byresultatt)
  
  # fill BDL, AQL
  resdat <- utilMWRlimits(resdat = resdat, accdat = accdat, param = param, warn = warn)
  
  # get thresholds
  threshln <- utilMWRthresh(resdat = resdat, param = param, thresh = thresh, threshlab = threshlab)
  
  # get y axis scaling
  logscl <- utilMWRyscale(accdat = accdat, param = param, yscl = yscl)
  
  ##
  # plot prep
  
  thm <- ggplot2::theme_minimal(base_size = bssize) + 
    ggplot2::theme(
      panel.grid.major.x = ggplot2::element_blank(), 
      panel.grid.minor.x = ggplot2::element_blank(),
      panel.grid.minor.y = ggplot2::element_blank(), 
      axis.text.x = ggplot2::element_text(angle = 45, size = ggplot2::rel(0.9), hjust = 1), 
      legend.position = 'top',
      legend.key.width = ggplot2::unit(1.05, "cm"),
      plot.title = ggplot2::element_text(size = ggplot2::rel(ttlsize))
    )
  
  toplo <- resdat
  
  ylab <- unique(toplo$`Result Unit`)
  
  # title, changed below as needed if summarized
  ttl <- utilMWRtitle(param = param, site = site, dtrng = dtrng, locgroup = locgroup, resultatt = resultatt)
  
  p <- ggplot2::ggplot()
  
  # add threshold lines
  if(!is.null(threshln)){
    
    threshln <- na.omit(threshln)
    
    p <- p + 
      ggplot2::geom_hline(data = threshln, ggplot2::aes(yintercept  = thresh, linetype = label, size = label), color = threshcol) + 
      ggplot2::scale_linetype_manual(values = threshln$linetype) + 
      ggplot2::scale_size_manual(values = threshln$size)
    
  }
  
  # boxplot, not by result attribute
  if((type == 'box' | type == 'jitterbox') & !byresultatt){
    
    toplo <- toplo %>% 
      dplyr::group_by(`Monitoring Location ID`) %>% 
      dplyr::mutate(
        outlier = utilMWRoutlier(`Result Value`, logscl = logscl)
      ) %>% 
      dplyr::ungroup()
    
    p <- p +
      ggplot2::geom_boxplot(data = toplo, ggplot2::aes(x = `Monitoring Location ID`, y = `Result Value`), 
                            outlier.size = 1, fill = fill, alpha = alpha, width = width)
    
  }
  
  # boxplot, by result attribute
  if((type == 'box' | type == 'jitterbox') & byresultatt){
    
    toplo <- toplo %>% 
      dplyr::group_by(`Monitoring Location ID`, `Result Attribute`) %>% 
      dplyr::mutate(
        outlier = utilMWRoutlier(`Result Value`, logscl = logscl)
      ) %>% 
      dplyr::ungroup()
    
    p <- p +
      ggplot2::geom_boxplot(data = toplo, ggplot2::aes(x = `Result Attribute`, y = `Result Value`),
                            outlier.size = 1, fill = fill, alpha = alpha, width = width) + 
      ggplot2::facet_grid(~`Monitoring Location ID`)
    
  }
  
  # jitter if box, not by result attribute
  if(type == 'jitterbox' & !byresultatt){
    
    jitplo <- toplo %>% 
      dplyr::filter(!outlier)
    
    p <- p + 
      ggplot2::geom_point(data = jitplo, ggplot2::aes(x = `Monitoring Location ID`, y = `Result Value`), position = ggplot2::position_dodge2(width = 0.7 * width), alpha = 0.5, size = 1)
    
  }
  
  # jitter if box, by result attribute
  if(type == 'jitterbox' & byresultatt){
    
    jitplo <- toplo %>% 
      dplyr::filter(!outlier)
    
    p <- p + 
      ggplot2::geom_point(data = jitplo, ggplot2::aes(x = `Result Attribute`, y = `Result Value`), position = ggplot2::position_dodge2(width = 0.7 * width), alpha = 0.5, size = 1)
    
  }
  
  # barplot
  if((type == 'bar' | type == 'jitterbar') & !byresultatt){
    
    ttl <- utilMWRtitle(param = param, accdat = accdat, sumfun = sumfun, site = site, dtrng = dtrng, locgroup = locgroup, resultatt = resultatt)
    
    toplo <- toplo %>% 
      dplyr::group_by(`Monitoring Location ID`)
    
    # get summarized data
    toplobr <- utilMWRsummary(toplo, accdat = accdat, param = param, sumfun = sumfun, confint = confint)
    
    p <- p +
      ggplot2::geom_bar(data = toplobr, ggplot2::aes(x = `Monitoring Location ID`, y = `Result Value`),
                        fill = fill, stat = 'identity', alpha = alpha, width = width)
    
    # make sure confint is calculated
    chkbar <- any(!is.na(toplobr$lov))
    
    if(confint & chkbar)
      p <- p + 
        ggplot2::geom_errorbar(data = toplobr, ggplot2::aes(x = `Monitoring Location ID`, ymin = lov, ymax = hiv), width = 0.2 * width)
    
  }
  
  # barplot, by result attribute
  if((type == 'bar' | type == 'jitterbar') & byresultatt){
    
    ttl <- utilMWRtitle(param = param, accdat = accdat, sumfun = sumfun, site = site, dtrng = dtrng, locgroup = locgroup, resultatt = resultatt)
    
    toplo <- toplo %>% 
      dplyr::group_by(`Monitoring Location ID`, `Result Attribute`)
    
    # get summarized data
    toplobr <- utilMWRsummary(toplo, accdat = accdat, param = param, sumfun = sumfun, confint = confint)

    p <- p +
      ggplot2::geom_bar(data = toplobr, ggplot2::aes(x = `Result Attribute`, y = `Result Value`), 
                        fill = fill, stat = 'identity', alpha = alpha, width = width) + 
      ggplot2::facet_grid(~`Monitoring Location ID`)
    
    # make sure confint is calculated
    chkbar <- any(!is.na(toplobr$lov))
    
    if(confint & chkbar)
      p <- p +
        ggplot2::geom_errorbar(data = toplobr, ggplot2::aes(x = `Result Attribute`, ymin = lov, ymax = hiv), width = 0.2 * width)
    
  }
  
  if(type %in% c('jitterbar', 'jitter') & !byresultatt){
    
    p <- p + 
      ggplot2::geom_point(data = toplo, ggplot2::aes(x = `Monitoring Location ID`, y = `Result Value`), position = ggplot2::position_dodge2(width = 0.7 * width), alpha = 0.5, size = 1)
    
  }
  
  if(type %in% c('jitterbar', 'jitter') & byresultatt){
    
    p <- p +
      ggplot2::geom_point(data = toplo, ggplot2::aes(x = `Result Attribute`, y = `Result Value`), position = ggplot2::position_dodge2(width = 0.7 * width), alpha = 0.5, size = 1) + 
      ggplot2::facet_grid(~`Monitoring Location ID`)
    
  }
  
  if(logscl)
    p <- p + ggplot2::scale_y_log10()
  
  p <- p +
    thm +
    ggplot2::labs(
      y = ylab, 
      title = ttl, 
      linetype = NULL,
      size = NULL, 
      alpha = NULL,
      x = NULL
    )
  
  # add panel box if by result attribute
  if(byresultatt)
    p <- p  + 
      ggplot2::theme(
        panel.background = ggplot2::element_rect(fill = NA)
      )
  
  return(p)
  
}


##' This function uses the Bloomberg API to retrieve ticks for the requested security.
##'
##' @title Get Ticks from Bloomberg
##' @param security A character variable describing a valid security ticker
##' @param eventType A character variable describing an event type. Multiple events can be specified
##' by a list \code{c("TRADE", "BEST_BID", "BEST_ASK")}, default is \sQuote{TRADE}
##' @param startTime A Datetime object with the start time, defaults
##' to one hour before current time
##' @param endTime A Datetime object with the end time, defaults
##' to current time
##' @param setCondCodes A boolean indicating whether to return any ticks with condition codes,
##' associated with extraordinary trading and quoting circumstances,
##' defaults to \sQuote{FALSE}. Similar to setting \code{CondCodes = S} and \code{QRM = S} in Excel API
##' @param verbose A boolean indicating whether verbose operation is
##' desired, defaults to \sQuote{FALSE}
##' @param returnAs A character variable describing the type of return
##' object; currently supported are \sQuote{matrix} (also the default),
##' \sQuote{fts}, \sQuote{xts} and \sQuote{zoo}  
##' @param tz A character variable with the desired local timezone,
##' defaulting to the value \sQuote{TZ} environment variable, and
##' \sQuote{UTC} if unset
##' @param con A connection object as returned by a \code{blpConnect} call
##' @return A numeric matrix with elements \sQuote{time}, (as a
##' \sQuote{POSIXct} object), \sQuote{values} and \sQuote{sizes}, or
##' an object of the type selected in \code{returnAs}.
##' @author Dirk Eddelbuettel
getTicks <- function(security,
                     eventType = c("TRADE"),
                     startTime = Sys.time()-60*60,
                     endTime = Sys.time(),
                     verbose = FALSE,
                     returnAs = getOption("blpType", "matrix"),
                     setCondCodes = FALSE,
                     tz = Sys.getenv("TZ", unset="UTC"),
                     con = .pkgenv$con) {

    fmt <- "%Y-%m-%dT%H:%M:%S"
    startUTC <- format(startTime, fmt, tz="UTC")
    endUTC <- format(endTime, fmt, tz="UTC")
    res <- getTicks_Impl(con, security, eventType, startUTC, endUTC, setCondCodes, verbose)

    attr(res[,1], "tzone") <- tz
    
    res <- switch(returnAs,
                  matrix = res,                # default is matrix
                  fts    = fts::fts(res[,1], res[,-1]),
                  xts    = xts::xts(res[,-1], order.by=res[,1]),
                  zoo    = zoo::zoo(res[,-1], order.by=res[,1]),
                  res)                         # fallback is also matrix
    return(res)   # to return visibly
}

#' Create a reducer
#'
#' @param init An initializing function.
#' @param reducefn A reducer function.
#' @param name A name for the reducer
#'
#' @export
reducer <- function(initialfn = NULL, reducefn = NULL, name = NULL) {

  message <- "Please provide an initializing function, a reducer function, and a name."
  stop_if_any_null(message, initialfn, reducefn, name)

  if (class(name) != "character" || length(name) > 1) stop("'name' must be a character")
  if (class(initialfn) == "character") initialfn <- htmlwidgets::JS(initialfn)
  if (class(reducefn) == "character") reducefn <- htmlwidgets::JS(reducefn)

  if (class(initialfn) != "JS_EVAL") stop("'initialfn' must be of class character or JS_EVAL")
  if (class(reducefn) != "JS_EVAL") stop("'reducefn' must be of class character or JS_EVAL")

  list(initialfn = initialfn,
       reducefn = reducefn,
       name = name)
}


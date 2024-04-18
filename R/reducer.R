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

  if (class(initialfn) != "JS_EVAL") stop("Initializing function must be created with htmlwidgets::JS()")
  if (class(reducefn) != "JS_EVAL") stop("Reducer function must be created with htmlwidgets::JS()")

  list(initialfn = initialfn,
       reducefn = reducefn,
       name = name)
}


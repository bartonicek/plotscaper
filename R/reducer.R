#' Construct a Reducer
#'
#' Constructs a reducer that can be used to show different summaries
#' in a `plotscaper` figure. Specifically, the function creates a list with
#' three values: an `initialfn`, a `reducefn`, and a `name`.
#' @details
#' `reducefn` and `initialfn` should be interpretable as JavaScript functions
#' (either strings or objects constructed with `htmlwidgets::JS`). Further:
#'
#' - `initialfn` should take no arguments and just return some value (i.e. a thunk).
#' - `reducefn` should take two arguments `previous` and `next` and return a result
#' of the same type as `previous`.
#'
#' @param initialfn An JavaScript initializing function
#' @param reducefn A JavaScript reducer function specified
#' @param name A name for the reducer (a string)
#' @returns A reducer (which is just a `list`)
#'
#' @examples
#' r <- reducer(initialfn = "() => -Infinity",
#'              reducefn = "(a, b) => Math.max(a, b)",
#'              name = "max")
#' set_scene(mtcars) |>
#'   add_barplot(c("cyl", "mpg"), options = list(reducer = r))
#'
#' @export
reducer <- function(initialfn = NULL, reducefn = NULL, name = NULL) {

  message <- "Please provide an initializing function, a reducer function, and a name."
  stop_if_any_null(message, initialfn, reducefn, name)

  if (!inherits(name, "character") || length(name) > 1) stop("'name' must be a character")
  if (inherits(initialfn, "character")) initialfn <- htmlwidgets::JS(initialfn)
  if (inherits(reducefn, "character")) reducefn <- htmlwidgets::JS(reducefn)

  if (!inherits(initialfn, "JS_EVAL")) stop("'initialfn' must be of class character or JS_EVAL")
  if (!inherits(reducefn, "JS_EVAL")) stop("'reducefn' must be of class character or JS_EVAL")

  list(initialfn = initialfn,
       reducefn = reducefn,
       name = name)
}


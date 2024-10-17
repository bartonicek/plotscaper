#' Create a reducer
#'
#' Constructs a reducer that can be used to show alternative summaries
#' in a `plotscaper` plot.
#'
#' @details
#' `reducefn` and `initialfn` should be strings interpretable
#' as JavaScript functions. Further:
#'
#' - `initialfn` should take 0 arguments and just return some value (i.e. a thunk).
#' - `reducefn` should take two arguments `previous` and `next` and return a result
#' of the same type as `previous`.
#'
#' @param initialfn An JavaScript initializing function
#' @param reducefn A JavaScript reducer function specified
#' @param name A name for the reducer (a string)
#' @returns A reducer (which is really just a `list` with some additional formatting)
#'
#' @examples
#' r <- reducer(initialfn = "() => 0",
#'              reducefn = "(x, y) => Math.max(x, y)",
#'              name = "max")
#' create_schema(mtcars) |>
#'   add_barplot(c("cyl", "mpg"), options = list(reducer = r))
#'
#' @export
reducer <- function(initialfn = NULL, reducefn = NULL, name = NULL) {

  message <- "Please provide an initializing function, a reducer function, and a name."
  stop_if_any_null(message, initialfn, reducefn, name)

  list(initialfn = jsonlite::unbox(initialfn),
       reducefn = jsonlite::unbox(reducefn),
       name = jsonlite::unbox(name))
}


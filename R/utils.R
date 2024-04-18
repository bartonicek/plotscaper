
stop_if_any_null <- function(message = NULL, ...) {
  to_check <- list(...)

  for (i in 1:length(to_check)) {
    if (is.null(to_check[[i]])) stop(message)
  }
}


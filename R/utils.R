
stop_if_any_null <- function(message = NULL, ...) {
  to_check <- list(...)

  for (i in 1:length(to_check)) {
    if (is.null(to_check[[i]])) stop(message)
  }
}

check_type <- function(scene, encoding, type) {
  scene$x$types[encoding] == type
}

check_missing <- function(scene, encoding) {
  length(setdiff(encoding, names(scene$x$types))) != 0
}

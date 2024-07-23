
`%unpack%` <- function(vars, list) {
  for(v in vars) assign(v, list[[v]], parent.frame())
}

infer_plotscape_type <- function(x) {
  typeMap <- list(
    numeric = "continuous",
    integer = "continuous",
    character = "discrete",
    factor = "discrete",
    logical = "discrete"
  )

  typeMap[[class(x)[which(class(x) %in% names(typeMap))]]]
}

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

snake_to_camel <- function(x) {
  gsub("_(\\w?)", "\\U\\1", x, perl = TRUE)
}

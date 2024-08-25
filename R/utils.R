
last <- function(list) {
  list[[length(list)]]
}

push <- function(list, x) {
  list[[length(list) + 1]] <- x
  list
}

stop_if_any_null <- function(message = NULL, ...) {
  to_check <- list(...)

  for (i in 1:length(to_check)) {
    if (is.null(to_check[[i]])) stop(message)
  }
}

is_scalar <- function(x) {
  is.atomic(x) && length(x) == 1
}

deep_unbox <- function(x) {
  if (is_scalar(x)) return(jsonlite::unbox(x))
  else if (is.list(x)) {
    for (key in names(x)) x[[key]] <- deep_unbox(x[[key]])
    return(x)
  }
  else return(x)
}

snake_to_camel <- function(x) {
  gsub("_(\\w?)", "\\U\\1", x, perl = TRUE)
}

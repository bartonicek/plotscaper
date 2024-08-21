
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

snake_to_camel <- function(x) {
  gsub("_(\\w?)", "\\U\\1", x, perl = TRUE)
}



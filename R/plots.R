#' Create a plotscaper mapping
#'
#' A helper function to create an aesthetic mapping for plotscaper plots
#'
#' @param x Variable mapped to the x-aesthetic (string)
#' @param y Variable mapped to the y-aesthetic (string)
#' @param size Variable mapped to the size aesthetic (string)
#'
#' @export
ps_map <- function(x = NULL, y = NULL, size = NULL) {
  map <- list(x = x, y = y, size = size)
  map[lengths(map) > 0] # Remove NULL elements
}


#' Add a ready-made plot to a plotscaper scene
#'
#' Function that appends a ready-made plot of a specific type to an existing plotscaper scene
#'
#' @param scene A plotscaper scene object
#' @param type A string declaring the type of plot to be added, e.g. "scatter", "histo", "bar", "square"
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
#'
#' @examples
#' s1 <- scene(mtcars, 900, 500)
#' s1 |> ps_wrapper_plot(type = "scater", mapping = list(x = "wt", y = "mpg"))
ps_wrapper_plot <- function(scene, type, mapping) {

  if (type %in% c("scatter") & is.null(mapping$y)) stop("Please supply a valid y mapping")

  scene$x$types <- c(scene$x$types, type)
  scene$x$mappings <- append(scene$x$mappings, list(mapping))
  scene
}

#' Add a scatterplot to a plotscaper scene
#'
#' Function that appends a ready-made scatterplot to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "scatter", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_scatter <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "scatter", mapping, ...)
}

#' Add a barplot to a plotscaper scene
#'
#' Function that appends a ready-made barplot to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "bar", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_bar <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "bar", mapping, ...)
}

#' Add a histogram to a plotscaper scene
#'
#' Function that appends a ready-made histogram to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "histo", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_histo <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "histo", mapping, ...)
}

#' Add a squareplot to a plotscaper scene
#'
#' Function that appends a ready-made "squareplot" to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "histo", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_square <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "square", mapping, ...)
}

#' Add a bubbleplot to a plotscaper scene
#'
#' Function that appends a ready-made bubbleplot/bubblechart to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "histo", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_bubble <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "bubble", mapping, ...)
}

#' Add a square heatmap to a plotscaper scene
#'
#' Function that appends a ready-made "square heatmap" (with square size representing count, not colour) to a plotscaper scene. A wrapper for ps_wrapper_plot(scene, type = "histo", mapping)
#'
#' @param scene A plotscaper scene object
#' @param mapping A mapping created with `ps_map()` or a list that declares how variables in the data (belonging to scene) map to visual aesthetics/encodings
#'
#' @export
ps_squareheat <- function(scene, mapping, ...) {
  ps_wrapper_plot(scene, "squareheat", mapping, ...)
}

#' Create an Interactive Visual Scene
#'
#' Function that creates a skeleton of an interactive visual scene.
#'
#' @param data A data object that can be converted to JSON, preferably in long format
#' @param width Width of the visual scene
#' @param height Height of the visual scene
#'
#' @import htmlwidgets
#' @export
#'
#' @examples scene(mtcars, 900, 500)
#' |> ps_wrapper_plot("scatter", list(x = "wt", y = "mpg"))
#' |> ps_wrapper_plot("bar", list(x = "cyl", y = "_indicator"))
ps_scene <- function(data, width = NULL, height = NULL, elementId = NULL) {

  # forward options using x
  x = list(
    data = data,
    types = c(),
    mappings = list(),
    dims = list()
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'plotscapeTest',
    x,
    width = width,
    height = height,
    package = 'plotscapeTest',
    elementId = elementId
  )
}

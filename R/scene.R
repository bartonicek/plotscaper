#' Set up an interactive scene
#'
#' This function constructs the underlying skeleton of an interactive
#' `plotscaper` scene. Specifically, it parses the data, sends it to
#' to `plotscape` via `htmlwidgets`, and sets up the scene object which
#' takes care of adding plots and between-plot interactions.
#'
#' @param data A dataframe that will be converted to JSON
#' (missing values are not currently supported).
#' @param width Width of the scene
#' @param height Height of the scene
#'
#' @examples
#' set_scene(mtcars) |> add_scatterplot(c("wt", "mpg"))
#' @import htmlwidgets
#' @export
set_scene <- function(data, width = NULL, height = NULL, elementId = NULL) {

  typeMap <- list(
    numeric = "continuous",
    integer = "continuous",
    character = "discrete",
    factor = "discrete"
  )

  n_complete <- sum(complete.cases(data))
  n_missing <- nrow(data) - n_complete

  if (n_missing > 0) {
    warning(paste("Removed", n_missing, "rows with missing values from the data"))
    data <- na.omit(data)
  }

  types <- lapply(as.list(data), function(x) {
    typeMap[[class(x)[which(class(x) %in% names(typeMap))]]]
  })

  # forward options using x
  x = list(
    data = data,
    types = types,
    plots = list()
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'plotscaper',
    x,
    width = width,
    height = height,
    package = 'plotscaper',
    elementId = elementId
  )
}

#' Shiny bindings for plotscaper
#'
#' Output and render functions for using plotscaper within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a plotscaper
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name plotscaper-shiny
#'
#' @export
plotscaperOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'plotscaper', width, height, package = 'plotscaper')
}

#' @rdname plotscaper-shiny
#' @export
renderPlotscaper <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, plotscaperOutput, env, quoted = TRUE)
}

#' Set up an interactive scene
#'
#' This function constructs a skeleton of an interactive
#' `plotscaper` figure. Specifically, it parses the data to JSON,
#' creates an object of class `htmlwidget` and sends it
#' additional information that is necessary to set up the figure,
#' such as the variable types,
#' the URL of the websocket server (if interactive), etc..
#' The figure gets rendered when the resulting `htmlwidget`
#' object gets printed.
#'
#' @param data A dataframe that will be converted to JSON
#' (missing values are currently not supported).
#' @param options A list of options
#' @param width Width of the scene
#' @param height Height of the scene
#' @param elementId An id of the element to render the widget in
#' @returns An object of class `htmlwidget`
#'
#' @examples
#' set_scene(mtcars) |> add_scatterplot(c("wt", "mpg"))
#' @import htmlwidgets
#' @export
set_scene <- function(data = NULL, options = NULL,
                      width = NULL, height = NULL, elementId = NULL) {

  if (is.null(data)) stop("Please provide a valid dataset.")

  # check for missing data
  n_complete <- sum(stats::complete.cases(data))
  n_missing <- nrow(data) - n_complete

  if (n_missing > 0) {
    warning(paste("Removed", n_missing, "rows with missing values from the data"))
    data <- stats::na.omit(data)
  }

  # infer plotscape variable types
  types <- lapply(as.list(data), infer_plotscape_type)

  # rename scene options to snake case
  if (!is.null(options)) {
    options <- stats::setNames(options, snake_to_camel(names(options)))
  }

  server <- plotscaper_global$server
  if (!is.null(server)) {
    url <- paste0("ws://", server$getHost(), ":", server$getPort(), "/")
    options$websocketURL <- url
  }

  # forward options using x
  x = list(
    data = data,
    queue = list(),
    options = options
  )

  # create widget
  widget <- htmlwidgets::createWidget(
    x,
    name = 'plotscaper',
    width = width,
    height = height,
    package = 'plotscaper',
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      viewer.padding = 0,
      browser.fill = TRUE
    )
  )

  scene <- list(widget = widget)
  class(scene) <- "scene"

  scene$add_plot <- function(type = NULL, variables = NULL, options = NULL) {
    mutate_scene(scene, add_plot, type, variables, options)
  }

  scene$pop_plot <- function() mutate_scene(scene, pop_plot)
  scene$remove_plot <- function(id) mutate_scene(scene, remove_plot, id)
  scene$select_cases <- function(cases) mutate_scene(scene, select_cases, cases)
  scene$assign_cases <- function(cases, group = 1) {
    mutate_scene(scene, assign_cases, cases, group)
  }

  scene$selected_cases <- function() query_scene(scene, selected_cases)
  scene$assigned_cases <- function(group = 1) {
    query_scene(scene, assigned_cases, group)
  }

  scene
}

#' @export
print.scene <- function(x) {
  print(x$widget)
}

mutate_scene <- function(scene, fn, ...) {
  s <- fn(scene, ...)
  message <- last(s$widget$x$queue)
  server_send(message)
  invisible(scene)
}

query_scene <- function(scene, fn, ...) {
  s <- fn(scene, ...)
  message <- last(s$widget$x$queue)
  server_await(message)
}

#' Set interactive scene layout
#'
#' This function sets a layout for a `plotscaper` scene, similar to the
#' `graphics::layout` function.
#'
#' @param scene A `plotscaper` scene
#' @param layout A numeric matrix of contiguous rectangle ids
#' @returns The scene back
#' @export
set_layout <- function(scene = NULL, layout = NULL) {
  if (is.null(layout) || !is.matrix(layout) || !is.numeric(layout)) {
    stop("Please provide a valid layout in the form of a numeric matrix.")
  }

  scene$x$layout <- layout
  scene
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

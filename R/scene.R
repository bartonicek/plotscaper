#' Create a `plotscaper` schema
#'
#' This function constructs a schema of an interactive
#' `plotscaper` figure.
#'
#' @param data A dataframe
#' @param options A list of options
#' @returns An object of class `plotscaper_schema`
#'
#' @examples
#' create_schema(mtcars) |> add_scatterplot(c("wt", "mpg")) |> render()
#' @export
create_schema <- function(data = NULL) {

  if (is.null(data)) stop("Please provide a data set.")

  # Check for missing data
  n_complete <- sum(stats::complete.cases(data))
  n_missing <- nrow(data) - n_complete

  if (n_missing > 0) {
    warning(paste("Removed", n_missing, "rows with missing values from the data"))
    data <- stats::na.omit(data)
  }

  schema <- list(data = data, queue = list())
  schema <- structure(schema, class = "plotscaper_schema")
  schema
}

#' @export
print.plotscaper_schema <- function(schema) {
  cat(paste0("plotscaper schema:\n",
             paste(" ", schema$queue, collapse = "\n")))
}

#' Render a `plotscaper` schema
#'
#' This function takes a `plotscaper` schema and renders it as a
#' concrete `htmlwidgets` widget.
#'
#' @param schema A `plotscaper` schema object
#' @param width Width
#' @param height Height
#' @param elementId Id of the HTML element
#'
#' @export
render <- function(schema, width = NULL, height = NULL,
                   elementId = NULL, options = NULL) {

  scene <- new.env()

  # Rename options keys to camel case
  if (!is.null(options)) {
    options <- stats::setNames(options, snake_to_camel(names(options)))
  }

  server <- plotscaper_global$server
  if (is.null(server) && interactive()) {
    start_server()
    server <- plotscaper_global$server
  }

  if (!is.null(server)) {
    url <- paste0("ws://", server$getHost(), ":", server$getPort(), "/")
    options$websocketURL <- url
    scene$server <- server
  }

  queue <- list()
  for (message in schema$queue) {
    queue <- push(queue, format_message(message))
  }

  data <- schema$data
  params <- list(data = data, queue = queue, options = options)

  # Create htmlwidgets widget
  scene$widget <- htmlwidgets::createWidget(
    x = params,
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

  scene$rendered <- FALSE
  scene$data <- data
  scene$uuid <- uuid::UUIDgenerate()
  class(scene) <- "plotscaper_scene"

  scene
}

#' @export
print.plotscaper_scene <- function(scene) {
  scene$rendered <- TRUE
  print(scene$widget)
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

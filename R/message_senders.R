
dispatch_message <- function(x, ...) UseMethod("dispatch_message")

#' @export
dispatch_message.plotscaper_schema <- function(schema, message) {
  schema$queue <- push(schema$queue, message)
  schema
}

#' @export
dispatch_message.plotscaper_scene <- function(scene, message) {
  await <- message$await
  message <- format_message(message)

  if (!scene$rendered) {
    scene$widget$x$queue <- push(scene$widget$x$queue, message)
    print(scene)
    return(invisible())
  }

  if (!is.null(await) && await) {
    return(server_await(scene, message))
  }

  server_send(scene, message)
}

#' Add a plot to a scene or schema
#'
#' This function adds a plot to an existing `plotscaper`
#' scene or schema. Not meant to be called directly
#' but instead with a wrapper function such as
#' [add_scatterplot()].
#'
#' @param x A plotscaper scene or schema
#' @param spec A list with the plot specification
#' @export
add_plot <- function(x, spec) {

  type <- spec$type
  variables <- spec$variables
  spec <- spec$options

  if (is.null(type) || !(type %in% plot_types)) {
    stop(paste("Please provide a valid plot type:",
               paste(plot_types, collapse = ', ')))
  }

  if (is.null(variables)) stop("Please provide encoding variables")
  for (key in names(spec)) {
    spec[[key]] <- jsonlite::unbox(spec[[key]])
  }

  data <- c(list(type = jsonlite::unbox(type), variables = variables), spec)
  message <- list(type = "add-plot", data = data)

  dispatch_message(x, message)
}

plot_types <- c("scatter", "bar", "histo", "histo2d",
                "fluct", "pcoords")

#' Remove the last plot from a scene or schema
#'
#' This function removes the last plot from a `plotscaper`
#' scene or schema.
#'
#' @param x A plotscaper scene or schema
#' @export
pop_plot <- function(x) {
  dispatch_message(x, list(type = "pop-plot"))
}

#' Remove specific plot from a scene or schema
#'
#' This function removes a specific plot from a `plotscaper`
#' scene or schema.
#'
#' @param x A plotscaper scene or schema
#' @param id A string id of the plot. See [id]
#'
#' @export
remove_plot <- function(x, id = NULL) {
  if (is.null(id) || !is.character(id)) {
    stop("Please provide a plot id (e.g. 'plot1' or 'scatter3')")
  }
  data <- list(id = jsonlite::unbox(id))
  message <- list(type = "remove-plot", data = data)
  dispatch_message(x, message)
}

#' Select cases of the data
#'
#' This function selects specific cases (rows of the data)
#' within a `plotscaper` scene or schema by assigning
#' them to transient selection.
#' Transient group assignment is removed by clicking.
#'
#' @param x A `plotscaper` scene or schema
#' @param cases The cases (rows) to select
#' @export
select_cases <- function(x, cases = NULL) {
  if (is.null(cases) || !is.numeric(cases)) {
    stop("Please provide a list of cases you want to select")
  }
  cases <- cases - 1 # Correct for 0-based indexing on the JavaScript side
  data <- list(cases = cases)
  message <- list(type = "set-selected", data = list(cases = cases))
  dispatch_message(x, message)
}

#' Assign cases to a group
#'
#' This function assigns specific cases (rows of the data)
#' to a permanent group within a `plotscaper` scene or schema.
#' Permanent group assignments are only removed by double-clicking.
#'
#' @param x A `plotscaper` scene or schema
#' @param cases The cases (rows) to select
#' @param group The group to assign the cases to (can be 1, 2, or 3)
#' @export
assign_cases <- function(x, cases = NULL, group = 1) {
  if (is.null(cases) || !is.numeric(cases)) {
    stop("Please provide a list of cases you want to assign to a group")
  }
  if (!is.numeric(group)) stop("Please provide a numeric group id (1-3)")
  cases <- cases - 1 # Correct for 0-based indexing on the JavaScript side
  data <- list(cases = cases, group = jsonlite::unbox(group))
  message <- list(type = "set-assigned", data = data)
  dispatch_message(x, message)
}

#' Check selected cases
#'
#' This function returns the cases of the data which are selected
#' within a `plotscaper` scene.
#'
#' @param x A `plotscaper` scene
selected_cases <- function(x) {
  message <- list(type = "get-selected", await = TRUE)
  dispatch_message(x, message)
}

#' Check assigned cases
#'
#' This function returns the cases of the data which
#' are assigned to a specific permanent group within
#' a `plotscaper` scene.
#'
#' @param x A `plotscaper` scene
#' @param group The group to retrieve the cases of (can be: 1, 2, or 3)
assigned_cases <- function(x, group = 1) {
  data <- list(group = group)
  message <- list(type = "get-assigned", await = TRUE, data = data)
  dispatch_message(x, message)
}

#' Reset a scene or schema
#'
#' This function resets a `plotscaper` scene or schema.
#' All selection/group assignment will be removed, and
#' axis limits/levels of zoom will be restored to default.
#'
#' @param x A `plotscaper` scene or schema
#' @export
reset <- function(x) {
  dispatch_message(x, list(type = "reset"))
}

#' Set values of a scale
#'
#' This function sets the values of a scale within one plot
#' inside a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema
#' @param id A string id of the plot. See [id]
#' @param scale A string identifying scale. Can be: "x", "y", "area", or "size".
#' @param min Scale minimum. Only works for continuous scales
#' @param max Scale maximum. Only works for continuous scales
#' @param breaks A vector of scale breaks. Only works for discrete scales.
#' The values should be the same as in the original scale, just different order.
#' @param direction Scale direction. Can be `1` or `-1`
#' @param mult Scale multiplier
#'
#' @export
set_scale <- function(x, id = NULL, scale = NULL, min = NULL, max = NULL,
                      breaks = NULL, direction = NULL, mult = NULL,
                      default = NULL) {

  if (is.null(id)) stop("Please specify a plot id")
  if (is.null(scale)) stop("Please specify a valid scale: x, y, area, or size")

  data <- list(id = id, scale = scale, min = min,
               max = max, mult = mult, default = default)
  for (key in names(data)) data[[key]] <- jsonlite::unbox(data[[key]])
  data$labels <- breaks

  message <- list(type = "set-scale", data = data)
  dispatch_message(x, message)
}

#' Zoom into an area of a plot
#'
#' This function zooms into a rectangular area of the specified
#' plot. The coordinates of the rectangular area can be specified
#' with either percentages of the plotting region, absolute
#' coordinates (pixels), or data coordinates.
#'
#' @param x A plotscaper scene or schema
#' @param id A string id of the plot. See [id]
#' @param coords The coordinates of a rectangle to
#' zoom into, in the following order: `x0, y0, x1, y1`
#' @param units The units with which to interpret the coordinates.
#' Can be "pct" (percentages of the plotting region), "abs" (absolute
#' screen coordinates, in pixels), or "data" (data coordinates;
#' only works if both scales are continuous).
#'
#' @export
zoom <- function(x, id = NULL, coords = NULL, units = "pct") {
  data <- list(id = jsonlite::unbox(id), coords = coords,
               units = jsonlite::unbox(units))
  message <- list(type = "zoom", data = data)
  dispatch_message(x, message)
}

#' Plot id
#'
#' A string which uniquely identifies a plot `plotscaper` scene or schema.
#'
#' @details
#' `id` is a string that uniquely identifies a plot  within a
#' `plotscaper` scene or schema. It can match a plot
#' based on its position (e.g. "plot1", "plot2", ...),
#' in the order the plots were added, left-to-right top-to-bottom,
#' or it can match plot based on type (e.g. "scatter1" or "barplot3"),
#' again, in order of addition.
#'
#' If the plot is matched based on type, the morphemes "plot" and
#' "gram" are ignored, such that e.g. "scatterplot1" is the same as
#' "scatter1" and "histogram2d4" is the same as "histo2d4".
#'
#' The string can also be shortened, e.g. "p1" for "plot1",
#' "s2" for "scatter2",  or "hh3" for "histo2d3".
#' @export
id <- NULL



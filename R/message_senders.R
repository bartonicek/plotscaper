
dispatch_message <- function(x, ...) UseMethod("dispatch_message")

#' @export
dispatch_message.plotscaper_schema <- function(schema, fn, ...) {
  message <- fn(schema, ...)
  schema$queue <- push(schema$queue, message)
  schema
}

#' @export
dispatch_message.plotscaper_scene <- function(scene, fn, ...) {
  message <- fn(scene, ...)
  server_send(format_message(message))
}

#' @export
add_plot <- function(x, ...) UseMethod("add_plot")
pop_plot <- function(x) UseMethod("pop_plot")
remove_plot <- function(x, ...) UseMethod("remove_plot")
select_cases <- function(x) UseMethod("select_cases")
assign_cases <- function(x, ...) UseMethod("assign_cases")
selected_cases <- function(x) UseMethod("selected_cases")
assigned_cases <- function(x, ...) UseMethod("assigned_cases")

plot_types <- c("scatter", "bar", "histo", "histo2d", "fluct", "line", "note")

#' Add a plot to a plotscaper scene
#' @export
add_plot.plotscaper_schema <- function(schema, options = NULL) {
  dispatch_message(schema, add_plot_message, options)
}

#' @export
add_plot.plotscaper_scene <- function(scene, options = NULL) {
  dispatch_message(scene, add_plot_message, options)
}

add_plot_message <- function(x, options) {

  type <- options$type
  variables <- options$variables
  options <- options$options

  if (is.null(type) || !(type %in% plot_types)) {
    stop(paste("Please provide a valid plot type:",
               paste(plot_types, collapse = ', ')))
  }

  if (is.null(variables)) stop("Please provide encoding variables")
  for (key in names(options)) {
    options[[key]] <- jsonlite::unbox(options[[key]])
  }

  data <- c(list(type = jsonlite::unbox(type), variables = variables), options)
  message <- list(type = "add-plot", data = data)
  message
}

#' @export
pop_plot.plotscaper_schema <- function(schema) {
  dispatch_message(schema, pop_plot_message)
}

#' @export
pop_plot.plotscaper_scene <- function(scene) {
  dispatch_message(scene, pop_plot_message)
}

pop_plot_message <- function(x) list(type = "pop-plot")

#' @export
remove_plot.plotscaper_schema <- function(schema, id = NULL) {
  dispatch_message(schema, remove_plot_message, id)
}

#' @export
remove_plot.plotscaper_scene <- function(scene, id = NULL) {
  dispatch_message(scene, remove_plot_message, id)
}

remove_plot_message <- function(x, id = NULL) {
  if (is.null(id)) stop("Please provide a plot id (e.g. 'plot1' or 'scatter3')")
  data <- list(id = jsonlite::unbox(id))
  list(type = "remove-plot", data = data)
}

#' Select cases
#'
#' Select specific cases (rows of the data) by assigning them
#' to transient selection. Note that transient selection is removed when
#' any plot is clicked. To make the selection more permanent, use `assign_cases()`.
#'
#' @param scene A `plotscaper` scene
#' @param cases The cases (rows) to select
#' @returns Nothing (a pure side-effect)
#'
#' @export
select_cases <- function(scene, cases = NULL) {
  cases <- cases - 1 # Correct for 0-based indexing on the JavaScript side
  list(type = "set-selected", cases = cases)
}

#' Assigns cases to a specific group
#'
#' Assigns specific cases (rows of the data) to a permanent group.
#' Permanent group assignments are only removed by double-clicking.
#'
#' @param scene A `plotscaper` scene
#' @param cases The cases (rows) to select
#' @param group The group to assign the cases to (can be: `1`, `2`, or `3`)
#' @returns Nothing (a pure side-effect)
#'
#' @export
assign_cases <- function(scene, cases = NULL, group = 1) {
  cases <- cases - 1 # Correct for 0-based indexing on the JavaScript side
  data <- list(group = group, cases = cases)
  msg <- format_message("set-assigned", data)

  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
}

#' Check which cases are selected
#'
#' Check which cases of the data are transiently selected
#' within the current plotscaper scene.
#'
#' @param scene A `plotscaper` scene
#' @param resolvefn Function to call after the server receives a response from
#' the scene. Defaults to `print`.
#' @returns Nothing (use `resolvefn` to save output)
#' @examples
#' # Assign selected cases to the `cases` variable
#' # selected_cases(resolvefn = function(x) cases <<- x)
selected_cases <- function(scene, resolvefn = print) {
  msg <- format_message("get-selected")
  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
}

#' Check which cases are assigned to a specific group
#'
#' Check which cases of the data are assigned to a permanent group.
#' Note that permanent group assignments are only removed by double-clicking.
#'
#' @param scene A `plotscaper` scene
#' @param group The group to retrieve the cases of (can be: `1`, `2`, or `3`)
#' @param resolvefn Function to call after the server receives a response from
#' the scene. Defaults to `print`.
#' @returns Nothing (use `resolvefn` to save output)
#' @examples
#' # Assign selected cases to the `cases` variable
#' # selected_cases(resolvefn = function(x) cases <<- x)
assigned_cases <- function(scene, group = 1, resolvefn = print) {
  data <- list(group = group)
  msg <- format_message("get-assigned", data)
  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
}


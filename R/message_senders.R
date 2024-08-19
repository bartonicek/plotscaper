plot_types <- c("scatter", "bar", "histo", "histo2d",
                "fluct", "line", "note")

#' Add a plot to a plotscaper scene
#' @export
add_plot <- function(scene, type = NULL, variables = NULL, options = NULL) {

  if (is.null(type) || !(type %in% plot_types)) {
    stop(paste("Please provide a valid plot type:",
               paste(plot_types, collapse = ', ')))
  }

  if (is.null(variables)) stop("Please provide encoding variables")

  for (key in names(options)) {
    options[[key]] <- jsonlite::unbox(options[[key]])
  }

  data <- c(list(type = jsonlite::unbox(type), variables = variables), options)
  msg <- format_message("add-plot", data)
  scene$widget$x$queue <- push(scene$widget$x$queue, msg)

  scene
}

#' @export
pop_plot <- function(scene) {
  msg <- format_message("pop-plot")
  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
}

#' @export
remove_plot <- function(scene, id = NULL) {
  if (is.null(id)) stop("Please provide plot id such as 'plot1' or 'scatter3'")
  data <- list(id = jsonlite::unbox(id))
  msg <- format_message("remove-plot", data)

  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
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
  data <- list(cases = cases)
  msg <- format_message("set-selected", data)

  scene$widget$x$queue <- push(scene$widget$x$queue, msg)
  scene
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


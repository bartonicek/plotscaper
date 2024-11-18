
#' Dispatches a message to a plotscaper scene or schema
#' @param x A plotscaper scene or schema
#' @param message A list that will get converted to JSON message at appropriate time
#' @returns The scene or schema back
#' @export
dispatch_message <- function(x, message) UseMethod("dispatch_message")

#' @export
dispatch_message.plotscaper_schema <- function(x, message) {
  x$queue <- push(x$queue, message)
  x
}

#' @export
dispatch_message.plotscaper_scene <- function(x, message) {

  if (!interactive()) {
    stop("You can only send messages to scene from within an interactive R session",
         call. = FALSE)
  }

  await <- message$await
  message <- format_message(message)

  if (!x$rendered) {
    x$widget$x$queue <- push(x$widget$x$queue, message)
    return(x)
  }

  if (!is.null(await) && await) {
    return(server_await(x, message))
  }

  server_send(x, message)
  invisible(x)
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
#' @returns The scene or schema back
#'
#' @export
add_plot <- function(x, spec) {

  type <- spec$type
  variables <- spec$variables
  queries <- spec$queries

  if (is.null(type) || !(type %in% plot_types)) {
    stop(paste("Please provide a valid plot type:",
               paste(plot_types, collapse = ', ')), .call = FALSE)
  }

  if (is.null(variables)) {
    stop("Please provide encoding variables", .call = FALSE)
  }

  data <- deep_unbox(spec)

  # Undo jsonlite::unbox for variables and queries (= vectors)
  data$variables <- variables
  data$queries <- queries

  data$id <- jsonlite::unbox(uuid::UUIDgenerate())

  message <- list(type = "add-plot", data = data)
  dispatch_message(x, message)
}

plot_types <- c("scatter", "bar", "bibar", "histo", "histo2d",
                "fluct", "pcoords")

#' Remove the last plot from a scene or schema
#'
#' This function removes the last plot from a `plotscaper`
#' scene or schema.
#'
#' @param x A plotscaper scene or schema
#' @returns The scene or schema back
#'
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
#' @returns The scene or schema back
#'
#' @export
#'
remove_plot <- function(x, id = NULL) {
  if (is.null(id) || !is.character(id)) {
    stop("Please provide a plot id (e.g. 'plot1' or 'scatter3')", .call = TRUE)
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
#' @returns The scene or schema back
#'
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
#' @returns The scene or schema back
#'
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

#' Get selected cases
#'
#' This function returns the cases of the data which are selected
#' within a `plotscaper` scene.
#'
#' @param x A `plotscaper` scene
#' @returns A numeric vector of case ids
#'
#' @export
selected_cases <- function(x) {
  message <- list(type = "get-selected", await = TRUE)
  dispatch_message(x, message)
}

#' Get assigned cases
#'
#' This function returns the cases of the data which
#' are assigned to a specific permanent group within
#' a `plotscaper` scene.
#'
#' @param x A `plotscaper` scene
#' @param group The group to retrieve the cases of (can be: 1, 2, or 3)
#' @returns A numeric vector of case ids
#'
#' @export
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
#' @returns The scene or schema back
#'
#' @export
reset <- function(x) {
  dispatch_message(x, list(type = "reset"))
}

#' Get a plot scale
#'
#' This function returns a specific scale from a specifc plot
#' in a `plotscaper` scene.
#'
#' @param x A `plotscaper` scene
#' @param id A string id of the plot. See [id]
#' @param scale A string id of the scale (`x`, `y`, `width`, `height`, `area`, or `size`)
#' @returns A list of scale properties
#'
#' @details
#' This function is primarily meant for internal use, however, you can
#' use it to learn how `plotscaper` implements scales. The output can look
#' a bit overwhelming, however, it's not too complicated once you understand
#' how `plotscaper` scales work.
#'
#' Each scale has two important properties:
#'
#' - Domain: The space values are translated *from*
#' - Codomain: The space values are translated *to*
#'
#' For example, in a typical scatterplot, the `x` scale might have the range of
#' the data (e.g. `[1, 10]`) as its domain and the width of the plotting region
#' as its codomain (e.g. `[0, 800]` pixels).
#'
#' The scale's job is to link the domain and codomain, such that
#' we can *push* values forward through the scale, first through the domain
#' and then the codomain. This is done by translating to an intermediate
#' range `[0, 1]`. For example, using the `x` scale above, we might first
#' translate the value `5.5` to `0.5` (midpoint of the domain) and then
#' translate `0.5` to `400` (midpoint of the codomain). We may also be able
#' to reverse the process and *pull* values back through the scale, first
#' through the codomain and then through the domain.
#'
#' Scale, domain, and codomain each have `props` and `defaults` properties
#' which store the relevant values. For example, for a continuous scale,
#' `props` and `defaults` store the `min` and `max` as well as a transformation
#' function and its inverse (`trans`, `inv`), for a discrete point scale,
#' they store the vector of labels, their order, etc...
#'
#' On `scale`, the `props` and `defaults` store the following properties:
#' `zero`, `one`, `scale`, `mult`. The `zero` and `one` properties modify where
#' the normalized domain values get placed in the codomain, and vice versa.
#' Suppose our `x` (`[1, 10]`, `[0, 800]` px) scale had `zero = 0.1` and `one = 0.9`.
#' Then data values get pushed to the following intermediate values:
#'
#' - The value `1` to `0.1` since `0.1 + (1 - 1) / (10 - 1) * (0.9 - 0.1) = 0.1`
#' - The value `2` to `0.1889` since `0.1 + (2 - 1) / (10 - 1) * (0.9 - 0.1) = 0.1889`
#' - The value `3` to `0.2778` since `0.1 + ((3 - 1) / (10 - 1)) * (0.9 - 0.1) = 0.2778`
#' - ...
#' - The value `10` to `0.9` since `0.1 + ((10 - 1) / (10 - 1)) * (0.9 - 0.1) = 0.9`
#'
#' When those values get translated to the space of the codomain,
#' we end up with 10% margins on each side, i.e.
#'
#' - The value `1` gets pushed to `80` pixels
#' - ...
#' - The value `10` gets pushed to `720` pixels
#'
#' The `scale` and `mult` properties both multiply the normalized domain values.
#' They work the same way, however, they are different semantically: `scale` is
#' meant to be constant whereas `mult` may change dynamically,
#' through interaction. For example, by default, in a barplot, the `width` scale
#' gets assigned the `scale` value of `1 / k`, where `k` is the number of
#' categories/bars, and a `mult` value of 0.9. This means that each bar is
#' `1 / k * 0.9 * [plot width in pixels]` wide, and we can dynamically make it
#' wider or narrower by pressing the `+/-` keys to modify the `mult` property
#' (but not the `scale` property).
#'
#' @export
get_scale <- function(x, id = NULL, scale = NULL) {
  if (is.null(id)) stop("Please specify a plot id")
  if (is.null(scale)) {
    stop("Please specify a valid scale: x, y, width, height, area, or size")
  }

  data <- list(id = jsonlite::unbox(id), scale = jsonlite::unbox(scale))
  message <- list(type = "get-scale", await = TRUE, data = data)
  dispatch_message(x, message)
}

#' Set values of a scale
#'
#' This function sets the values of a scale within one plot
#' inside a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema
#' @param id A string id of the plot. See [id]
#' @param scale A string identifying scale. Can be: "x", "y", "area", or "size".
#' @param min Scale minimum (continuous scales only)
#' @param max Scale maximum (continuous scales only)
#' @param transformation A transformation to apply ("log10" or "sqrt", continuous only)
#' @param breaks A vector of discrete breaks (discrete scale only)
#' @param zero The proportion of codomain to which the smallest/first value gets mapped to
#' @param one The proportion of codomain to which largest/last value gets mapped to
#' @param direction Scale direction. Can be `1` or `-1`
#' @param mult Scale multiplier
#' @param default Whether to set other arguments as scale defaults
#' @param unfreeze Whether to unfreeze frozen parameters (such as the lower y-axis limit in barplot)
#' @returns The scene or schema back
#'
#' @export
set_scale <- function(x, id = NULL, scale = NULL, min = NULL, max = NULL,
                      transformation = NULL, breaks = NULL, zero = NULL,
                      one = NULL, direction = NULL, mult = NULL,
                      default = NULL, unfreeze = NULL) {

  if (is.null(id)) stop("Please specify a plot id")
  if (is.null(scale)) {
    stop("Please specify a valid scale: x, y, width, height, area, or size")
  }

  data <- list(id = id, scale = scale,
               min = min, max = max, transformation = transformation,
               zero = zero, one = one, direction = direction, mult = mult,
               default = default, unfreeze = unfreeze)

  for (key in names(data)) data[[key]] <- jsonlite::unbox(data[[key]])
  if (!is.null(breaks)) data$labels <- as.character(breaks)

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
#' @returns The scene or schema back
#'
#' @export
zoom <- function(x, id = NULL, coords = NULL, units = "pct") {
  if (is.null(id)) stop("Please specify a plot id")
  data <- list(id = jsonlite::unbox(id), coords = coords,
               units = jsonlite::unbox(units))
  message <- list(type = "zoom", data = data)
  dispatch_message(x, message)
}

#' Set interactive scene layout
#'
#' This function sets a layout for a `plotscaper` scene. Similar to the
#' `graphics::layout` function.
#'
#' @param x A `plotscaper` scene
#' @param layout A numeric matrix of plot ids, arranged into contiguous rectangles
#' @returns The scene or schema back
#'
#' @export
set_layout <- function(x, layout = NULL) {
  if (is.null(layout)) stop("Please provide layout as a numeric matrix.")
  data <- list(layout = layout - 1) # Correct for 0-based indexing
  message <- list(type = "set-layout", data = data)
  dispatch_message(x, message)
}

#' Set interactive scene layout
#'
#' This function clears an existing layout. See [set_layout()].
#'
#' @param x A `plotscaper` scene
#' @returns The scene or schema back
#'
#' @export
clear_layout <- function(x) {
  message <- list(type = "clear-layout")
  dispatch_message(x, message)
}

#' Normalize a plot
#'
#' This function switches the representation of a plot to a normalized one,
#' e.g. spineplot, spinogram, etc...
#'
#' @param x A `plotscaper` scene
#' @param id A string id of the plot. See [id]
#' @returns The scene or schema back
#'
#' @export
normalize <- function(x, id = NULL) {
  if (is.null(id)) stop("Please specify a plot id")
  message <- list(type = "normalize", data = list(id = jsonlite::unbox(id)))
  dispatch_message(x, message)
}

#' Set reactive parameters
#'
#' This functions sets reactive paramaters on a plot such as a histogram.
#'
#' @param x A `plotscaper` scene
#' @param id A string id of the plot. See [id]
#' @param width Histogram binwidth
#' @param anchor Histogram anchor
#' @param width_x 2D histogram binwidth (x-axis)
#' @param anchor_x 2D histogram anchor (x-axis)
#' @param width_y 2D histogram binwidth (y-axis)
#' @param anchor_y 2D histogram anchor (y-axis)
#' @returns The scene or schema back
#'
#' @export
set_parameters <- function(x, id = NULL, width = NULL, anchor = NULL,
                      width_x = NULL, anchor_x = NULL,
                      width_y = NULL, anchor_y = NULL) {

  if (is.null(id)) stop("Please specify a plot id")

  data <- list(id = id, width = width, anchor = anchor, width1 = width_x,
               anchor1 = anchor_x, width2 = width_y, anchor2 = anchor_y)

  for (key in names(data)) data[[key]] <- jsonlite::unbox(data[[key]])

  message <- list(type = "set-parameters", data = data)
  dispatch_message(x, message)
}

#' Return a list of plot ids from a plotscaper scene or schema
#' @param x A plotscaper scene or schema
#' @returns The scene or schema back
#'
#' @export
get_plot_ids <- function(x) UseMethod("get_plot_ids")

#' @export
get_plot_ids.plotscaper_schema <- function(x) {
  messages <- x$queue

  plots <- c()
  counts <- list()

  for (msg in messages) {
    if (msg$type == "pop-plot") {
      plots <- plots[-length(plots)]
    } else if (msg$type == "remove-plot") {
      id <- msg$data$id
      plots <- plots[-which(plots == id)]
      plots <- update_counts(plots)
    } else if (msg$type == "add-plot") {
      plot_type <- msg$data$type

      if (is.null(counts[[plot_type]])) {
        counts[[plot_type]] <- 1
      }

      plots <- c(plots, paste0(plot_type, counts[[plot_type]]))
      counts[[plot_type]] <- counts[[plot_type]] + 1
    }
  }

  update_counts(plots)
}

update_counts <- function(plots) {
  counts <- list()
  result <- c()

  for (plot in plots) {
    plot_number <- numeric_suffix(plot)
    plot_type <- gsub(plot_number, "", plot)

    if (is.null(counts[[plot_type]])) {
      counts[[plot_type]] <- 1
    }

    new_number <- counts[[plot_type]]
    result <- c(result, paste0(plot_type, new_number))
    counts[[plot_type]] <- counts[[plot_type]] + 1
  }

  result
}

#' @export
get_plot_ids.plotscaper_scene <- function(x) {
  message <- list(type = "get-plot-ids", await = TRUE)
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



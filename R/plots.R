
plot_types <- c("scatter", "bar", "histo", "histo2d",
                "fluct", "pcoords", "note")

#' Add plot to an interactive scene
#'
#' This function adds the specification for a additional plot to
#' an existing `plotscaper` scene (`htmlwidget`) object. The type of plot is
#' specified via a string. Variable encodings are specified via a vector
#' of character strings, corresponding to the names of the variables in
#' the data.
#'
#' @details
#' This function is used internally in specialized wrapper functions such as [add_scatterplot]
#' or [add_barplot], and I recommend to use these functions instead.
#'
#' Note that the variable encodings specified via the `encoding` argument
#' are different from aesthetic encodings used in Grammar of Graphics
#' (GoG)-based systems such as `ggplot2`.
#' That is, code like the following:
#'
#' ```
#' add_plot("scatter", c(x = "wt", y = "mpg"))
#' ```
#'
#' will not work. This is because, in `plotscaper`,
#' data variables are mapped to intermediate "summary" variables which may
#' be subject to some statistical transformations,
#' and only after that happens can these summary variables
#' be mapped to aesthetic variables. I.e. there is a three-step model:
#'
#' \deqn{\textbf{data}
#' \overset{\text{summarize}}{\longrightarrow} \textbf{summaries}
#' \overset{\text{encode}}{\longrightarrow} \textbf{aesthetics}}
#'
#' The reason for this departure from the GoG style of specifying aesthetics
#' is that some interactive plots are difficult to express
#' as a clean 1-to-1 mapping from data to aesthetics.
#'
#' For example, in a spinogram (a scaled version
#' of histogram - click on a histogram and press the "N" key),
#' the y-axis variable is
#' scaled count, and x-axis variable is cumulative (absolute) count.
#' Neither of these variables come directly from the data, and both
#' represent a transformation of the same underlying summary variable
#' (count within bins). In fact, the underlying summary variable in a
#' spinogram is exactly the same as the one histogram uses - it is
#' just transformed differently and mapped to different aesthetics in
#' each kind of plot.
#'
#'
#' @param scene A `plotscaper` scene object
#' @param type A string representing the plot type
#' @param encoding A vector of variable encodings
#' @param options A list of options
#' @returns The scene back (with the added specification for the plot)
#'
#' @import htmlwidgets
#' @export
add_plot <- function(scene, type = NULL, encoding = NULL, options = NULL) {

  if (is.null(type) || !(type %in% plot_types)) {
    stop(paste("Please provide a valid plot type:",
               paste(plot_types, collapse = ', ')))
  }

  ignore_encodings <- ifelse(is.null(options$ignore_encodings), FALSE,
                             options$ignore_encoding)

  if (!ignore_encodings && is.null(encoding)) {
    stop("Please provide variable encodings")
  }

  keys <- names(encoding)
  if (!ignore_encodings && is.null(keys)) {
    keys <- paste0("v", 1:length(encoding))
    encoding <- split(encoding, keys)
  }

  scene$x$plots[[length(scene$x$plots) + 1]] <- list(type = type,
                                                     encoding = encoding,
                                                     options = options)
  scene
}

#' Add a scatterplot to an interactive scene
#'
#' This function adds a scatterplot to an interactive scene.
#'
#' @param scene A `plotscaper` scene object
#' @param encoding A vector of variable encodings:
#' `v1` and `v2` (discrete or continuous), `v3` continuous (optional)
#' @returns The scene back
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
add_scatterplot <- function(scene, encoding = NULL) {
  if (is.null(encoding)) stop("Please provide a valid encoding: 'v1' and 'v2', 'v3' optional")
  add_plot(scene, "scatter", encoding)
}

#' Add a barplot to an interactive scene
#'
#' This function adds a barplot to an interactive scene.
#' Can be transformed into spineplot by pressing the normalize ("N") key.
#'
#' @param scene A `plotscaper` scene object
#' @param encoding Encoding of the variables:
#' `v1` a discrete variable, `v2` a continuous variable (optional)
#' @param options A list of options
#' @returns The scene back
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
add_barplot <- function(scene, encoding = NULL, options = NULL) {
  if (is.null(encoding)) stop("Please provide a valid encoding: 'v1' (optionally 'v2' continuous)")
  add_plot(scene, "bar", encoding, options)
}

#' Add a histogram to an interactive scene
#'
#' This function adds a histogram to an interactive scene.
#' Can be transformed into spinogram by pressing the normalize ("N") key.
#'
#' @param scene A `plotscaper` scene object.
#' @param encoding Encoding of the variables:
#' `v1` a continuous variable, `v2` a continuous variable (optional).
#' @param options A list of options.
#' @returns The scene back.
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
#'
add_histogram <- function(scene, encoding = NULL, options = NULL) {
  if (is.null(encoding)) stop("Please provide a valid encoding: 'v1' continuous (optionally 'v2' continuous)")
  if (!check_type(scene, encoding[1], "continuous")) stop("'v1' must be continuous")
  add_plot(scene, "histo", encoding, options)
}

#' Add a fluctuation diagram to an interactive scene
#'
#' This function adds a fluctuation diagram to an interactive scene.
#' The squares' areas can be normalized by pressing the normalize ("N") key.
#'
#' @param scene A `plotscaper` scene object
#' @param encoding Encoding of the variables:
#' `v1` and `v2` discrete variables
#' @param options A list of options
#' @returns The scene back
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
add_fluctplot <- function(scene, encoding = NULL, options = NULL) {
  if (is.null(encoding)) stop("Please provide a valid encoding: 'v1' and 'v2', 'v3' continuous optional")
  add_plot(scene, "fluct", encoding)
}

#' Add a parallel coordinates plot to an interactive scene
#'
#' This function adds a parallel coordinates plot to an interactive scene
#' The variables can be put on common scale by pressing the normalize ("N")
#' key (only works if all continuous).
#'
#' @param scene A `plotscaper` scene object.
#' @param encoding Encoding of the variables:
#' `v1`, `v2`, `v3`, ... (continuous or discrete variables).
#' @returns The scene back
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
add_parcoords <- function(scene, encoding = NULL) {
  if (is.null(encoding)) stop("Please provide valid encodings: 'v1', 'v2', 'v3', ...")
  add_plot(scene, "pcoords", encoding)
}

#' Add a 2D histogram to an interactive scene
#'
#' This function adds a 2D histogram to an interactive scene
#' The squares' areas can be normalized by pressing the normalize ("N") key.
#'
#' @param scene A `plotscaper` scene object
#' @param encoding Encoding of the variables: `v1` and `v2` continuous
#' @returns The scene back
#'
#' @seealso [add_plot()]
#'
#' @import htmlwidgets
#' @export
add_histogram2d <- function(scene, encoding = NULL) {
  if (is.null(encoding)) stop("Please provide valid encodings: 'v1' and 'v2' continuos, 'v3' optional")
  add_plot(scene, "histo2d", encoding)
}

#' Add a not(e)plot to an interactive scene
#'
#' Function that adds a "noteplot" to an interactive scene. This is not
#' an actual plot but just a simple HTML `textarea` element that you can
#' use to take notes.
#'
#' @param scene A `plotscaper` scene object
#' @returns The scene back
#'
#' @import htmlwidgets
#' @export
add_notes <- function(scene) {
  add_plot(scene, "note", NULL, list(ignore_encodings = TRUE))
}



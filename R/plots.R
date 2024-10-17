#' Add a scatterplot to a scene or schema
#'
#' This function adds a scatterplot to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' two continuous or discrete (required), one continuous (optional)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_scatterplot <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 2) {
    stop("Please provide at least two variables")
  }

  check_variables(x, variables)

  spec <- c(list(type = "scatter", variables = variables), options)
  add_plot(x, spec)
}

#' Add a barplot to a scene or schema
#'
#' This function adds a barplot to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' one discrete (required), one continuous (optional)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_barplot <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 1) {
    stop("Please provide at least one variable")
  }
  check_variables(x, variables)

  spec <- c(list(type = "bar", variables = variables), options)
  add_plot(x, spec)
}

#' Add a mirrored barplot to a scene or schema
#'
#' This function adds a mirrored barplot to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' one discrete (required), one or two continuous (required)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_bibarplot <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 2) {
    stop("Please provide at least one discrete and one continuous variable")
  }
  check_variables(x, variables)

  spec <- c(list(type = "bibar", variables = variables), options)
  add_plot(x, spec)
}

#' Add a histogram to a scene or schema
#'
#' This function adds a histogram to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' one continuous (required), one continuous (optional)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_histogram <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 1) {
    stop("Please provide at least one continuous variable")
  }
  check_variables(x, variables)

  spec <- c(list(type = "histo", variables = variables), options)
  add_plot(x, spec)
}

#' Add a fluctuation diagram to a scene or schema
#'
#' This function adds a fluctuation diagram to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' two discrete (required), one continuous (optional)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_fluctplot <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 2) {
    stop("Please provide at least discrete variables")
  }
  check_variables(x, variables)

  spec <- c(list(type = "fluct", variables = variables), options)
  add_plot(x, spec)
}

#' Add a parallel coordinates plot to a scene or schema
#'
#' This function adds a parallel coordinates plot
#' to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' at least two continuous or discrete variables
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_pcoords <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 2) {
    stop("Please provide at one variable")
  }
  check_variables(x, variables)

  spec <- c(list(type = "pcoords", variables = variables), options)
  add_plot(x, spec)
}

#' Add a 2D histogram to a scene or schema
#'
#' This function adds a 2D histogram to a `plotscaper` scene or schema.
#'
#' @param x A `plotscaper` scene or schema object
#' @param variables A vector of variable names:
#' two continuous (required), one continuous (optional)
#' @param options A list of options
#' @returns The scene or schema back, with the plot added appropriately
#'
#' @seealso [add_plot()]
#' @export
add_histogram2d <- function(x, variables = NULL, options = NULL) {
  if (is.null(variables) || length(variables) < 2) {
    stop("Please provide at least two continuous variables")
  }
  check_variables(x, variables)

  spec <- c(list(type = "histo2d", variables = variables), options)
  add_plot(x, spec)
}

check_variables <- function(x, variables) {
  missing <- setdiff(variables, names(x$data))
  if (length(missing) > 0) {
    stop(paste("The following variables are missing from data:",
               paste(missing, collapse = ", ")))
  }
}

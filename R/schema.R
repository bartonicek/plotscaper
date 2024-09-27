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
create_schema <- function(data = NULL, options = NULL) {
  if (is.null(data)) stop("Please provide a data set.")

  # If data is character, assume we're trying to fetch from url
  if (is.character(data)) {
    tryCatch(
      data <- data.frame(jsonlite::read_json(data, simplifyVector = TRUE)),
      warning = function(w) {
        stop(paste0("Failed to fetch data from the following URL/path: ", "'", data, "'"),
             call. = FALSE)
      }
    )
  }

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
print.plotscaper_schema <- function(x, ...) {
  cat(paste0("plotscaper schema:\n",
             paste(" ", x$queue, collapse = "\n")))
}

# .DollarNames.plotscaper_schema <- function(x, pattern) {
#   c(names(x), get_plot_keys(x))
# }
#
# `$.plotscaper_schema` <- function(x, i) {
#
# }
#
# `[[.plotscaper_schema` <- function(x, i) {
#   if (!is.numeric(i)) NextMethod()
#
# }
#
# get_plot_keys <- function(schema) {
#   counts <- list()
#   plots <- c()
#
#   for (msg in schema$queue) {
#     type <- msg$type
#     plot_type <- msg$data$type
#     if (!(type == "add-plot")) next
#     if (is.null(counts[[plot_type]])) counts[[plot_type]] = 0
#     counts[[plot_type]] <- counts[[plot_type]] + 1
#
#     plots <- c(plots, paste0(plot_type, counts[[plot_type]]))
#   }
#
#   plots
# }
#
#



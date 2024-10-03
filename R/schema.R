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
  formatted_messages <- lapply(x$queue, print_format_message)
  formatted <- paste(formatted_messages, collapse = "\n")
  cat(paste0("plotscaper schema:\n", formatted))
}

print_format_message <- function(msg) {
  type <- msg$type
  data <- msg$data[names(msg$data) != "id"]

  data_string <- ""
  if (length(data) > 0) {
    data_string <- paste0(names(data), ": ", data, collapse = ", ")
  }

  paste(type, "{", data_string, "}")
}





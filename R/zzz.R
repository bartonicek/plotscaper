#' A Plotscaper Global Configuration Object
#'
#' Used mainly for setting up the HTTP server for communication
#' between an interactive R session and the figure.
#' @export
plotscaper_global <- new.env(parent = emptyenv())

globals <- list(
  host = "127.0.0.1",
  port = 3000,
  server = NULL,
  connections = list(),
  show_message = TRUE,
  async = list(
    resolve = NULL,
    reject = NULL
  )
)

list2env(globals, plotscaper_global)

.onAttach <- function(...) {
  if (interactive()) start_server()
}

.onUnattach <- function(...) {
  if (!is.null( server)) {
     server$stop()
  }
}


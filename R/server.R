#' Start a server for communication between the R session and `plostcaper` scenes
#'
#' This function starts an `httpuv` server for an interactive communication
#' between the R session and `plotscaper` scenes.
#' Uses `plotscaper_global` options.
#' @param random_port Whether to use a random port number.
#' Useful if the default port is already taken.
#' @returns Nothing (called for side effects)
#'
#' @export
start_server <- function(random_port = FALSE) {
  if (random_port) plotscaper_global$port <- httpuv::randomPort()
  launch()
}

error_message <- paste("Failed to launch httpuv server for communication between the R session and figure.",
                       "If address is already in use, try plotscaper::start_server(random_port = TRUE) or httpuv::stopAllServers().")

launch <- function() {
  host <- plotscaper_global$host
  port <- plotscaper_global$port
  tryCatch({
    plotscaper_global$server <- httpuv::startServer(host, port, handler)
  }, error = function(error) stop(error_message, call. = FALSE))

  message(paste0("Server started on port ", plotscaper_global$port,
                 " (handles communication between R session and figure)."))
}

handler <- list(
  onWSOpen = function(ws) {
    ws$onMessage(function(binary, msg) {
      msg <- jsonlite::fromJSON(msg)
      type <- msg$type
      sender <- msg$sender

      if (is.null(sender)) stop("Message is missing sender id")
      if (is.null(type)) stop("Message is missing type")

      if (sender == "scene" && type == "connected") {
        plotscaper_global$scene <- ws
        if (plotscaper_global$show_messages) message(connected_message)
        return(invisible())
      }

      result <- NULL

      if (sender == "scene") {
        if (!(type %in% names(message_handlers))) {
          stop(paste0("Unrecognized message type: '", type, "'."))
        }
        result <- message_handlers[[type]](msg)
        plotscaper_global$result <- result
      }

    })

    ws$onClose(function() {
      plotscaper_global$scene <- NULL
      if (plotscaper_global$show_messages) message("Scene disconnected from server.")
    })
  }
)

connected_message <- paste("Scene connected to server!",
"Try calling `scene |> select_cases(1:10)`.",
"\nTo suppress these messages, set `plotscaper_global$show_messages <- FALSE`.")

server_send <- function(scene, message) {
  check_connections()
  plotscaper_global$scene$send(message)
}

server_await <- function(scene, msg) {
  check_connections()

  plotscaper_global$result <- NULL
  plotscaper_global$scene$send(msg)
  httpuv::service()

  return(plotscaper_global$result)
}

format_message <- function(list) {
  jsonlite::toJSON(list(
    sender = jsonlite::unbox("server"),
    target = jsonlite::unbox("scene"),
    type = jsonlite::unbox(list$type),
    data = list$data
  ))
}

check_connections <- function() {
  if (is.null(plotscaper_global$server)) {
    stop("No running server. Start it with plotscaper::start_server().")
  }
  if (is.null(plotscaper_global$scene)) {
    stop("No scene connected to server. Did you forget to call `render(launch_server = TRUE)`?")
  }
}


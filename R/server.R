#' Start a server for interactive figure use
#'
#' Starts an httpuv server for an interactive communication with the plotscaper scene.
#' Relies on `plotscaper_global` options.
#' @param random_port Whether to use a random port number. Useful if default port is already taken.
#' @returns Nothing (a pure side-effect)
#' @export
start_server <- function(random_port = FALSE) {
  if (random_port) plotscaper_global$port <- httpuv::randomPort()
  tryCatch(launch(), error = function() message(error_message))
}

error_message <- "Failed to launch an httpuv server for interactive communication between R session and the figure.
If address is in use, try plotscaper::start_server(random_port = TRUE) or httpuv::stopAllServers()."

launch <- function() {
  host <- plotscaper_global$host
  port <- plotscaper_global$port
  plotscaper_global$server <- httpuv::startServer(host, port, handler)

  message(paste0("Server started on port ", plotscaper_global$port,
                 " (handles communication between R session and figure)."))
}

handler <- list(
  onWSOpen = function(ws) {
    ws$onMessage(function(binary, msg) {

      msg <- jsonlite::fromJSON(msg)
      type <- msg$type
      sender <- msg$sender

      if (is.null(sender)) {
        stop("Message has no sender id.")
      }

      result <- NULL

      if (sender == "scene" && type == "connected") {
        plotscaper_global$scene <- ws
        if (plotscaper_global$show_messages) message(connected_message)
        return()
      }

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
      if (plotscaper_global$show_messages) message("Figure disconnected from server.")
    })
  }
)

connected_message <- "Figure connected to server! Try calling `select_cases(1:10)`.
To suppress these messages, set `plotscaper_global$show_messages <- FALSE`."

server_send <- function(msg, res = NULL) {
  if (is.null(plotscaper_global$scene)) {
    stop("No figure connected to server. Did you forget to `print()`?")
  }

  if (!is.null(res)) plotscaper_global$async$resolve <- res
  plotscaper_global$scene$send(msg)
}

server_await <- function(msg) {
  if (is.null(plotscaper_global$scene)) {
    stop("No figure connected to server. Did you forget to `print()`?")
  }

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
    stop("The server is not connected to a figure.")
  }
}


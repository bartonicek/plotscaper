#' Start a server for interactive figure use
#'
#' Starts an httpuv server for an interactive communication with the plotscaper figure.
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

      result <- NULL
      if (type == "connected") msg$ws <- ws
      if (sender == "figure") result <- message_handlers[[type]](msg)

      if (is.null(plotscaper_global$async$resolve)) return()
      plotscaper_global$async$resolve(result)
      plotscaper_global$async$resolve <- NULL
    })
  }
)

figure_message <- "Figure connected to server! Try calling `mark_cases(1:10)`.
To suppress this message, set `plotscaper_global$show_message <- FALSE`."

message_handlers <- list(
  connected = function(msg) {
    plotscaper_global$connections[[msg$sender]] <- msg$ws
    if (plotscaper_global$show_message) message(figure_message)
  },
  selected = function(msg) {
    case_list <- msg$data
    result <- list()

    for (k in names(case_list)) {
      cases <- case_list[[k]] + 1 # Correct for 0-based indexing
      label <- group_label(group_index(as.numeric(k)))
      result[[label]] <- cases
    }

    rev(result)
  }
)

server_send <- function(msg, res = NULL) {
  if (!is.null(res)) plotscaper_global$async$resolve <- res
  plotscaper_global$connections$figure$send(msg)
}

server_message <- function(type, data) {
  jsonlite::toJSON(list(
    sender = jsonlite::unbox("server"),
    type = jsonlite::unbox(type),
    data = data
  ))
}

check_connections <- function() {
  if (is.null(plotscaper_global$server)) {
    stop("No running server. Start it with plotscaper::start_server().")
  }
  if (is.null(plotscaper_global$connections$figure)) {
    stop("The server is not connected to a figure.")
  }
}

#' Mark rows of the data
#'
#' Assign specific rows of the data to a given group
#' within the current plotscaper figure.
#'
#' @param row_ids The ids (row numbers) of the cases
#' @param group Which group to assign the cases to
#' @returns Nothing (a pure side-effect)
#'
#' @export
mark_cases <- function(row_ids = NULL, group = 2) {
  check_connections()

  group <- jsonlite::unbox(group_index(group))
  indices <- row_ids - 1 # Correct for 0-based indexing

  data <- list(indices = indices, group = group)
  msg <- server_message("mark", data)

  server_send(msg)
}

#' Check selected rows of the data
#'
#' Check which cases of the data are selected
#' within the current plotscaper figure.
#'
#' @param group Which group to assign the cases to
#' @param resolvefn Function to call after the server receives a response from
#' the figure. Defaults to `print`
#' @returns Nothing (use `resolvefn` to save output)
#' @examples
#' # Assign selected cases from group 2 to the `cases` variable
#' # selected_cases(2, resolvefn = function(x) cases <<- x)
#' @export
selected_cases <- function(group = 1:8, resolvefn = print) {
  group <- group_index(group)
  msg <- server_message("selected", list(group = group))
  server_send(msg, resolvefn)
}

group_index <- function(group) {
  pmax(0, pmin(8 - group, 8)) # plotscape uses reverse group ordering
}

group_label <- function(group) {
  transient <- ifelse(group > 4, " Transient", "")
  group <- (group - 1) %% 4 + 1
  paste0("Group ", group, transient)
}


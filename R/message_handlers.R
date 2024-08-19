message_handlers <- list(
  `get-selected` = function(msg) {
    if (length(msg$data$cases) == 0) return(numeric(0))
    return(msg$data$cases + 1)
  },
  `get-assigned` = function(msg) {
    if (length(msg$data$cases) == 0) return(numeric(0))
    return(msg$data$cases + 1)
  }
)

message_handlers <- list(
  `get-selected` = function(msg) {
    if (length(msg$data$cases) == 0) return(numeric(0))
    msg$data$cases + 1
  },
  `get-assigned` = function(msg) {
    if (length(msg$data$cases) == 0) return(numeric(0))
    msg$data$cases + 1
  },
  `get-plot-ids` = function(msg) {
    ids <- msg$data$ids
    unname(sapply(ids, increment_suffix))
  },
  `get-scale` = function(msg) {
    msg$data$scale
  }
)

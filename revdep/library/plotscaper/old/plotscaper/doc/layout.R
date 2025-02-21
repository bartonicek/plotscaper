## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------

library(plotscaper)

names(airquality) <- c("ozone", "solar radiation", "wind", 
                       "temperature", "month", "day")

schema <- create_schema(airquality) |>
  add_scatterplot(c("solar radiation", "ozone")) |>
  add_barplot(c("day")) |>
  add_histogram(c("wind")) |>
  add_pcoords(names(airquality))

schema |> render()


## -----------------------------------------------------------------------------
schema |> 
  remove_plot("bar1") |> # Remove the first barplot added to the figure
  pop_plot() |> # Remove the last plot added to the figure - typically, the bottom-right one
  render()

## -----------------------------------------------------------------------------
# # NOT RUN - this only makes sense inside a running R session
# scene <- create_schema(airquality) |> render()
# 
# scene |> add_scatterplot(c("solar radiation", "ozone"))
# scene |> add_barplot(c("day")) # Oops, maybe I want a histogram instead
# scene |> pop_plot()
# scene |> add_histogram(c("wind"))

## -----------------------------------------------------------------------------

# 1. Big scatterplot on the top left
# 2. Small barplot on the top right
# 3. Small histogram on the right
# 4. Wide parallel coordinates plot on the bottom
# 0. (empty space on the bottom right)

layout <- matrix(c(
  1, 1, 2,
  1, 1, 3,
  4, 4, 0
), ncol = 3, byrow = TRUE)

schema |> set_layout(layout) |> render()

## -----------------------------------------------------------------------------
# layout <- matrix(c(
#   2, 1, # Cannot split plotting regions like this
#   1, 2
# ), ncol = 2)


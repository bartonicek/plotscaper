library(plotscaper)

scene <- create_schema(mtcars) |>
  add_scatterplot(c("wt", "mpg")) |>
  render()

scene |> set_scale("plot1", "x", min = 0, max = 10)
scene |> set_scale("plot1", "y", direction = -1)
scene |> set_scale("plot1", "size", mult = 3)

x <- scene |> get_scale("plot1", "x")
y <- scene |> get_scale("plot1", "y")
size <- scene |> get_scale("plot1", "size")

stopifnot(
  x$domain$props$min == 0 &&
  x$domain$props$max == 10 &&
  x$props$zero == 0 &&
  x$props$one == 1
)

stopifnot(
  y$props$direction == -1
)

stopifnot(
  size$props$mult == 3
)


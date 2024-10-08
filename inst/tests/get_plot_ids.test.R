library(plotscaper)

schema <- create_schema(mtcars) |>
  add_scatterplot(c("wt", "mpg")) |>
  add_scatterplot(c("wt", "mpg")) |>
  add_scatterplot(c("wt", "mpg")) |>
  add_barplot(c("cyl")) |>
  add_barplot(c("am"))

stopifnot(
  all.equal(schema |> get_plot_ids(),
            c("scatter1", "scatter2", "scatter3", "bar1", "bar2"))
)

stopifnot(
  all.equal(schema |> pop_plot() |> get_plot_ids(),
            c("scatter1", "scatter2", "scatter3", "bar1"))
)

stopifnot(
  all.equal(schema |> remove_plot("scatter2") |> get_plot_ids(),
            c("scatter1", "scatter2", "bar1", "bar2"))
)

scene <- schema |> render()

scene
stopifnot(
  all.equal(scene |> get_plot_ids(),
            c("scatter1", "scatter2", "scatter3", "bar1", "bar2"))
)

scene |> pop_plot()

stopifnot(
  all.equal(scene |> get_plot_ids(),
            c("scatter1", "scatter2", "scatter3", "bar1"))
)

scene |> remove_plot("scatter2")

stopifnot(
  all.equal(scene |> get_plot_ids(),
            c("scatter1", "scatter2", "bar1"))
)

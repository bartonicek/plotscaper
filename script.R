
devtools::load_all()

ps_scene(mtcars, 900, 600) |>
  ps_scatter(mapping = ps_map("wt", "mpg")) |>
  ps_histo(ps_map("drat")) |>
  ps_scatter(ps_map("disp", "qsec")) |>
  ps_bar(ps_map("am")) |>
  ps_wrapper_plot("square", ps_map("gear", "cyl"))

ps_scene(iris, 900, 300) |>
  ps_scatter(list(x = "Sepal.Width", y = "Sepal.Length")) |>
  ps_bar(list(x = "Species", y = "_indicator")) |>
  ps_scatter(list(x = "Petal.Width", y = "Sepal.Length"))

s1 <- ps_scene(anscombe, 1000, 1000)
for (i in 1:4) {
  mapping <- list(x = paste0("x", i), y = paste0("y", i))
  s1 <- s1 |> ps_scatter(mapping)
}
s1

ps_scene(MASS::Boston, 900, 500) |>
  ps_scatter(list(x = "age", y = "medv")) |>
  ps_bar(list(x = "chas")) |>
  ps_scatter(list(x = "nox", y = "dis")) |>
  ps_histo(list(x = "crim")) |>
  ps_histo(list(x = "ptratio"))


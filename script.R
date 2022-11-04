
devtools::load_all()
devtools::install()

lay1 <- matrix(c(1, 1, 2,
                 1, 1, 3,
                 4, 4, 5),
               nrow = 3, byrow = TRUE)

ps_scene(mtcars, layout = lay1) |>
  ps_scatter(ps_map("wt", "mpg")) |>
  ps_bar(ps_map("cyl")) |>
  ps_square(ps_map("gear", "am")) |>
  ps_histo(ps_map("disp")) |>
  ps_bar(ps_map("vs"))

ps_scene(iris) |>
  ps_scatter(list(x = "Sepal.Width", y = "Sepal.Length")) |>
  ps_bar(list(x = "Species", y = "_indicator")) |>
  ps_scatter(list(x = "Petal.Width", y = "Petal.Length"))

s1 <- ps_scene(anscombe, 500, 500)
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


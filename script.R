
devtools::load_all()
lay1 <- matrix(c(1, 1, 2,
                 1, 1, 3,
                 4, 4, 5), nrow = 3, byrow = TRUE)

heavy_cars <- which(mtcars$wt > 3)
ps_scene(mtcars, layout = lay1) |>
  ps_scatter(ps_map("wt", "mpg")) |>
  ps_square(ps_map("gear", "am")) |>
  ps_bar(ps_map("cyl")) |>
  ps_histo(ps_map("disp")) |>
  ps_bubble(ps_map("carb", "vs")) |>
  ps_premark(heavy_cars, 2)

library(tidyverse)

ps_scene(mpg) |>
  ps_scatter(ps_map("cty", "displ")) |>
  ps_bar(ps_map("manufacturer"))


lay2 <- matrix(c(1, 2, 3, 3), ncol = 2, byrow = TRUE)
ps_scene(iris, layout = lay2) |>
  ps_squareheat(ps_map("Sepal.Width", "Sepal.Length")) |>
  ps_squareheat(ps_map("Petal.Width", "Petal.Length")) |>
  ps_bar(ps_map("Species"))

library(tidyverse)
devtools::load_all()

lay3 <- matrix(c(1, 1, 2, 3), ncol = 2, byrow = TRUE)
data3 <- diamonds[sample(nrow(diamonds), 1e4, replace = FALSE), ]
ps_scene(data3, layout = lay3) |>
  ps_scatter(ps_map("carat", "price")) |>
  ps_histo(ps_map("table")) |>
  ps_square(ps_map("color", "clarity"))

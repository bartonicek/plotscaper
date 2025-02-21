## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  fig.width = 6.5,
  fig.height = 4,
  comment = "#>")

## -----------------------------------------------------------------------------
library(plotscaper)

url <- "https://raw.githubusercontent.com/bartonicek/plotscape/master/datasets/diamonds.json"

create_schema(url) |>
  add_scatterplot(c("carat", "price")) |>
  add_barplot(c("color")) |>
  set_scale("plot1", "size", mult = 0.1) |>
  render()

## -----------------------------------------------------------------------------
# library(screenshot)
# library(magick)
# 
# url <- "https://raw.githubusercontent.com/bartonicek/plotscape/master/datasets/diamonds.json"
# 
# # Code to take the screenshot of the current page
# create_schema(url) |>
#   add_scatterplot(c("carat", "price")) |>
#   add_barplot(c("color")) |>
#   set_scale("plot1", "size", mult = 0.1) |>
#   render()
# 
# sc <- screenshot()
# image <- image_read(sc)
# image2 <- image_crop(image, geometry_area(600, 500, 1125, 50))
# image3 <- image_draw(image2)
# points(290, 140, cex = 10, col = "red", lwd = 5)
# dev.off()
# 
# image_write(image3, "./man/figures/browser.png")

## -----------------------------------------------------------------------------
knitr::include_graphics("../man/figures/browser.png")


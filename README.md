
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Plotscaper

<!-- badges: start -->
<!-- badges: end -->

Plotscaper is an R package designed for making interactive figures for
data exploration. All plots in `plotscaper` support linked selection by
default, as well as wide variety of other interactions, including,
zooming, panning, reordering, and parameter manipulation.

## Quick start

To get started, install `plotscaper` with:

``` r
devtools::install_github("bartonicek/plotscaper")
```

Next, open up RStudio and run the following code:

``` r
library(plotscaper)

create_schema(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot(c("city")) |>
  add_histogram(c("sqft")) |>
  add_fluctplot(c("beds", "baths")) |>
  add_histogram2d(c("sqft", "price")) |>
  add_pcoords(names(sacramento)) |> 
  render()
```

In your viewer, you should now see something like the image above,
however, your version should be fully interactive (Github doesn’t allow
JavaScript in `README.md`, hence why the image above is static, however,
the other vignettes should work okay).

Try clicking and dragging to select a few points on the scatterplot!

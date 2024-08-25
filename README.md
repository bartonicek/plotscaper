
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

names(airquality) <- c("ozone", "solar radiation", "wind", 
                       "temperature", "month", "day")

create_schema(airquality) |>
  add_scatterplot(c("solar radiation", "ozone")) |>
  add_barplot(c("day", "ozone"), list(reducer = "max")) |>
  add_histogram(c("wind")) |>
  add_pcoords(names(airquality)[1:4]) |>
  render()
#> Warning in create_schema(airquality): Removed 42 rows with missing values from
#> the data
```

<img src="man/figures/readme1.pngunnamed-chunk-3-1.png" style="display: block; margin: auto;" />

In your viewer, you should now see something like the image above,
however, your version should be fully interactive. Try clicking and
dragging to select a few points on the scatterplot!

(Github doesn’t allow JavaScript in `README.md`, hence why the image
above is just a static snapshot, however, other vignettes should have
fully interactive figures)

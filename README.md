
- [Plotscaper](#plotscaper)
  - [Quick start](#quick-start)
  - [Anatomy of a `plotscaper` figure](#anatomy-of-a-plotscaper-figure)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# Plotscaper

<!-- badges: start -->
<!-- badges: end -->

Plotscaper is a package for making linked interactive figures for data
exploration.

## Quick start

To get started, install `plotscaper` from [GitHub](https://github.com/)
with:

``` r
devtools::install_github("bartonicek/plotscape", subdir = "/packages/plotscaper")
```

Next, open up RStudio and run the following code:

``` r
library(plotscaper)

layout <- matrix(c(
  1, 1, 2, 3,
  1, 1, 4, 5,
  6, 7, 7, 7
), ncol = 4, byrow = TRUE)

set_scene(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot("city") |>
  add_histogram(c("sqft")) |>
  add_fluctplot(c("beds", "baths")) |>
  add_histogram2d(c("sqft", "price")) |>
  add_notes() |>
  add_parcoords(names(sacramento)) |>
  set_layout(layout)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

In your viewer, you should now see something like the image above,
however, your version should be fully interactive (the snapshot above is
static is because `README.md` does not allow JavaScript, unfortunately).

Try moving your mouse somewhere over the big scatterplot on the top
left, clicking and dragging to select some points. You should see the
corresponding cases highlight across all the other plots!

There are many other ways interacting with the figure. Click on the
question mark button in the top right of the figure to see a list of the
available options.

## Anatomy of a `plotscaper` figure

There are quite a few things happening in the code above. Let’s break it
down piece by piece.

First, whenever we want to create a `plotscaper` figure, we need to set
up a scene. A scene is a kind of context into which all plots get
placed.

To set up a scene, run:

``` r
set_scene(data = sacramento)
```

where `data` is a `data.frame` object. Here we’re using the Sacramento
housing dataset from the `caret` package.

On its own, however, a scene doesn’t do anything. To create an
interactive figure, we need to populate it with plots. That’s what the
various `add_*` functions are for:

``` r
set_scene(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot("city")
```

![](man/figures/README-unnamed-chunk-5-1.png)<!-- -->

As you can see above, this creates a simple interactive figure with a
scatterplot and a barplot. Not much more to it. We identify what
variables we want to plot by a simple character vector of their names.

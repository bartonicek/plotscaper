# Zoom into an area of a plot

This function zooms into a rectangular area of the specified plot. The
coordinates of the rectangular area can be specified with either
percentages of the plotting region, absolute coordinates (pixels), or
data coordinates.

## Usage

``` r
zoom(x, id = NULL, coords = NULL, units = "pct")
```

## Arguments

- x:

  A plotscaper scene or schema

- id:

  A string id of the plot. See
  [id](https://bartonicek.github.io/plotscaper/reference/id.md)

- coords:

  The coordinates of a rectangle to zoom into, in the following order:
  `x0, y0, x1, y1`

- units:

  The units with which to interpret the coordinates. Can be "pct"
  (percentages of the plotting region), "abs" (absolute screen
  coordinates, in pixels), or "data" (data coordinates; only works if
  both scales are continuous).

## Value

The scene or schema back

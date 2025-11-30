# Set reactive parameters

This functions sets reactive paramaters on a plot such as a histogram.

## Usage

``` r
set_parameters(
  x,
  id = NULL,
  width = NULL,
  anchor = NULL,
  width_x = NULL,
  anchor_x = NULL,
  width_y = NULL,
  anchor_y = NULL
)
```

## Arguments

- x:

  A `plotscaper` scene

- id:

  A string id of the plot. See
  [id](https://bartonicek.github.io/plotscaper/reference/id.md)

- width:

  Histogram binwidth

- anchor:

  Histogram anchor

- width_x:

  2D histogram binwidth (x-axis)

- anchor_x:

  2D histogram anchor (x-axis)

- width_y:

  2D histogram binwidth (y-axis)

- anchor_y:

  2D histogram anchor (y-axis)

## Value

The scene or schema back

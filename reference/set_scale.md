# Set values of a scale

This function sets the values of a scale within one plot inside a
`plotscaper` scene or schema.

## Usage

``` r
set_scale(
  x,
  id = NULL,
  scale = NULL,
  min = NULL,
  max = NULL,
  transformation = NULL,
  breaks = NULL,
  zero = NULL,
  one = NULL,
  direction = NULL,
  mult = NULL,
  default = NULL,
  unfreeze = NULL
)
```

## Arguments

- x:

  A `plotscaper` scene or schema

- id:

  A string id of the plot. See
  [id](https://bartonicek.github.io/plotscaper/reference/id.md)

- scale:

  A string identifying scale. Can be: "x", "y", "area", or "size".

- min:

  Scale minimum (continuous scales only)

- max:

  Scale maximum (continuous scales only)

- transformation:

  A transformation to apply ("log10" or "sqrt", continuous only)

- breaks:

  A vector of discrete breaks (discrete scale only)

- zero:

  The proportion of codomain to which the smallest/first value gets
  mapped to

- one:

  The proportion of codomain to which largest/last value gets mapped to

- direction:

  Scale direction. Can be `1` or `-1`

- mult:

  Scale multiplier

- default:

  Whether to set other arguments as scale defaults

- unfreeze:

  Whether to unfreeze frozen parameters (such as the lower y-axis limit
  in barplot)

## Value

The scene or schema back

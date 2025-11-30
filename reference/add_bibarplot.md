# Add a mirrored barplot to a scene or schema

This function adds a mirrored barplot to a `plotscaper` scene or schema.

## Usage

``` r
add_bibarplot(x, variables = NULL, options = NULL)
```

## Arguments

- x:

  A `plotscaper` scene or schema object

- variables:

  A vector of variable names: one discrete (required), one or two
  continuous (required)

- options:

  A list of options

## Value

The scene or schema back, with the plot added appropriately

## See also

[`add_plot()`](https://bartonicek.github.io/plotscaper/reference/add_plot.md)

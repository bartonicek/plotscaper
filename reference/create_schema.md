# Create a `plotscaper` schema

This function constructs a schema of an interactive `plotscaper` figure.

## Usage

``` r
create_schema(data = NULL, options = NULL)
```

## Arguments

- data:

  A dataframe

- options:

  A list of options

## Value

An object of class `plotscaper_schema`

## Examples

``` r
create_schema(mtcars) |> add_scatterplot(c("wt", "mpg")) |> render()
```

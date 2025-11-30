# Create a reducer

Constructs a reducer that can be used to show alternative summaries in a
`plotscaper` plot.

## Usage

``` r
reducer(initialfn = NULL, reducefn = NULL, name = NULL)
```

## Arguments

- initialfn:

  An JavaScript initializing function

- reducefn:

  A JavaScript reducer function specified

- name:

  A name for the reducer (a string)

## Value

A reducer (which is really just a `list` with some additional
formatting)

## Details

`reducefn` and `initialfn` should be strings interpretable as JavaScript
functions. Further:

- `initialfn` should take 0 arguments and just return some value (i.e. a
  thunk).

- `reducefn` should take two arguments `previous` and
  [`next`](https://rdrr.io/r/base/Control.html) and return a result of
  the same type as `previous`.

## Examples

``` r
r <- reducer(initialfn = "() => 0",
             reducefn = "(x, y) => Math.max(x, y)",
             name = "max")
create_schema(mtcars) |>
  add_barplot(c("cyl", "mpg"), options = list(reducer = r))
#> plotscaper schema:
#> add-plot { type: bar, variables: c("cyl", "mpg"), reducer: list(initialfn = "() => 0", reducefn = "(x, y) => Math.max(x, y)", name = "max") }
```

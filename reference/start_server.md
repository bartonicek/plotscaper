# Start a server for communication between the R session and `plostcaper` scenes

This function starts an `httpuv` server for an interactive communication
between the R session and `plotscaper` scenes. Uses `plotscaper_global`
options.

## Usage

``` r
start_server(random_port = FALSE)
```

## Arguments

- random_port:

  Whether to use a random port number. Useful if the default port is
  already taken.

## Value

Nothing (called for side effects)

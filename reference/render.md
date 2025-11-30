# Render a schema into an interactive scene

This function takes a `plotscaper` schema and renders it as a concrete
`htmlwidgets` widget.

## Usage

``` r
render(
  schema,
  launch_server = TRUE,
  width = NULL,
  height = NULL,
  elementId = NULL,
  options = NULL
)
```

## Arguments

- schema:

  A `plotscaper` schema object

- launch_server:

  Whether to launch a httpuv server for interaction with figure

- width:

  Width

- height:

  Height

- elementId:

  Id of the HTML element to render the scene in (optional)

- options:

  A list of options

## Value

An object of class `plotscaper_scene`

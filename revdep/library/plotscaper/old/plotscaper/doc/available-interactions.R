## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(plotscaper)

schema <- create_schema(mtcars) |> 
  add_scatterplot(c("wt", "mpg")) |> 
  add_barplot(c("cyl"))

schema |> select_cases(1:10) |> render()

## -----------------------------------------------------------------------------
schema |> 
  assign_cases(1:10) |> # Use e.g. 'group = 2' to assign to a different group
  render()

## -----------------------------------------------------------------------------
schema |> 
  assign_cases(which(mtcars$cyl == 8)) |>
  select_cases(which(mtcars$am == 1)) |>
  render()

## -----------------------------------------------------------------------------
schema |> zoom("plot1", c(0.25, 0.25, 0.75, 0.75)) |> render()

## -----------------------------------------------------------------------------
schema |> zoom("plot1", c(0, 0, 10, 50), units = "data") |> render()

## -----------------------------------------------------------------------------
schema |> get_plot_ids()

## -----------------------------------------------------------------------------
schema |> 
  set_scale("plot1", "x", zero = 0.6, one = 1.4) |> # zero/one = default value + 0.5
  set_scale("plot2", "x", zero = 0.6, one = 1.4) |> # ditto
  render()

## -----------------------------------------------------------------------------
schema |> 
  set_scale("plot1", "x", zero = 0, one = 1) |> 
  set_scale("plot1", "y", zero = 0, one = 1) |>
  # Barplot scales are a bit more complicated:
  # - for 'y' scale, zero is frozen (i.e. panning stretches bars up and down) 
  #   so we need to unfreeze this parameter to modify it
  # - for 'width', there is one more parameter that determines the width of the bar
  set_scale("plot2", "x", zero = 0, one = 1) |> 
  set_scale("plot2", "y", zero = 0, one = 1, unfreeze = TRUE) |>
  set_scale("plot2", "width", zero = 0, one = 1, mult = 1) |> 
  render()

## -----------------------------------------------------------------------------
schema |> 
  set_scale("plot1", "x", transformation = "log10") |> 
  set_scale("plot1", "y", transformation = "sqrt") |>
  render()

## -----------------------------------------------------------------------------
# # NOT RUN - this only works in an active R session
# scene |> get_scale("plot1", "x")

## -----------------------------------------------------------------------------
schema |> 
  set_scale("plot1", "x", zero = 0, one = 1, min = 0, max = 10) |> 
  set_scale("plot1", "y", zero = 0, one = 1, min = 0, max = 50) |>
  render()

## -----------------------------------------------------------------------------
schema |> set_scale("plot1", "y", direction = -1) |> render()

## -----------------------------------------------------------------------------
schema |>
  set_scale("plot2", "x", breaks = c("6", "4", "8")) |>
  render()

## -----------------------------------------------------------------------------
schema |> select_cases(5:15) |> render()
schema |> select_cases(5:15) |> normalize("plot2") |> render()

## -----------------------------------------------------------------------------
create_schema(mtcars) |> 
  add_scatterplot(c("wt", "mpg")) |>
  add_histogram(c("wt")) |> 
  set_parameters("plot1", width = 1, anchor = 0.5) |>
  render()

## -----------------------------------------------------------------------------
names(airquality) <- c("ozone", "solar radiation", "wind", 
                       "temperature", "month", "day")

create_schema(airquality) |>
  add_histogram2d(c("solar radiation", "ozone")) |>
  add_pcoords(names(airquality)) |>
  set_parameters("plot1", width_x = 30, width_y = 15, 
                  anchor_x = 0, anchor_y = 0) |>
  render()



## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>")

## -----------------------------------------------------------------------------
# devtools::install_github("bartonicek/plotscaper")

## -----------------------------------------------------------------------------
library(plotscaper)

httpuv::stopAllServers()

names(airquality) <- c("ozone", "solar radiation", "wind", 
                       "temperature", "month", "day")

create_schema(airquality) |>
  add_scatterplot(c("solar radiation", "ozone")) |>
  add_barplot(c("day", "ozone"), list(reducer = "max")) |>
  add_histogram(c("wind")) |>
  add_pcoords(names(airquality)[1:4]) |>
  render()

## -----------------------------------------------------------------------------
library(palmerpenguins)

penguins <- na.omit(penguins) # missing data is not supported yet, unfortunately
names(penguins) <- names(penguins) |> gsub("(_mm|_g)", "", x = _)

schema <- create_schema(penguins) |> 
  add_scatterplot(c("body_mass", "flipper_length")) |> 
  add_barplot(c("species")) |>
  add_fluctplot(c("species", "sex")) |>
  add_histogram(c("bill_length"))

## -----------------------------------------------------------------------------
schema

## -----------------------------------------------------------------------------
schema <- schema |>
  assign_cases(which(penguins$species == "Adelie")) |>
  set_scale("plot1", "x", min = 0) |>
  set_scale("plot1", "size", max = 5)

schema

## -----------------------------------------------------------------------------
scene <- schema |> render()
scene

## -----------------------------------------------------------------------------
# scene |> select_cases(1:10)

## -----------------------------------------------------------------------------
# # NOT RUN
# scene <- schema |> select_cases(20:30) |> render()
# scene
# scene

## -----------------------------------------------------------------------------
# # NOT RUN
# scene <- schema |> render()
# scene |> select_cases(20:30)
# scene |> select_cases(20:30)

## -----------------------------------------------------------------------------
try({
interactive()
scene |> select_cases(1:10)
})

## -----------------------------------------------------------------------------
# scene |> selected_cases()
# scene |> assigned_cases()

## -----------------------------------------------------------------------------
# start_server(random_port = TRUE) # Starts a server on a new random port

## -----------------------------------------------------------------------------
# httpuv::stopAllServers() # Stops all servers, now you should be able to relaunch the server

## -----------------------------------------------------------------------------

schema <- create_schema(penguins)
keys <- names(penguins)[4:6]

# Loop through combinations of columns
for (i in seq_along(keys)) {
  for (j in seq_along(keys)) {
    # Add a scatterplot if row & column no.'s are different
    if (i != j) schema <- schema |> add_scatterplot(c(keys[i], keys[j]))
    # Add a histogram if row & column no.'s match
    else schema <- schema |> add_histogram(c(keys[i])) 
  }
}

# Options to make the plots fit better within the available space
opts <- list(size = 5, axis_title_size = 0.75, axis_label_size = 0.5)
schema |> render(options = opts)

## -----------------------------------------------------------------------------
# scene <- create_schema(penguins) |> render(opts)
# 
# scene |> add_histogram(c("bill_depth"))
# scene |> add_scatterplot(c("bill_depth", "flipper_length"))
# scene |> add_scatterplot(c("bill_depth", "body_mass"))
# ...


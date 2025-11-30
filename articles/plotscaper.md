# Introduction to plotscaper

To get started, install `plotscaper` with:

``` r
devtools::install_github("bartonicek/plotscaper")
```

Next, open up RStudio and run the following code:

``` r
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
#> Warning in create_schema(airquality): Removed 42 rows with missing values from
#> the data
```

Try clicking and dragging to select some points in the scatterplot. You
should see the corresponding cases get highlighted within the barplot!

There are many other ways interacting with `plotscaper` figures,
including:

- Zooming and panning
- Changing the size of objects
- Increasing/decreasing the opacity (alpha)
- Manipulating parameters such as histogram binwidth and anchor
- Modifying axis limits and ordering discrete axes

Importantly, many of these interactions can either be done manually, by
interacting with the figure (client-side), or programmatically, by
calling functions from inside a running R session (“server-side”).

## The scene and the schema

To take full advantage of `plotscaper`, you need to understand two core
functions: `create_schema` and `render`. We’ll explore this on the
example of the `penguins` data set (Horst, Hill, and Gorman 2020).

### Creating a schema

The `create_schema` function initializes a *schema* - a sort of a recipe
which we can use to define the figure. Like in other data visualization
packages, we build up the schema step-by-step, by calling functions that
append additional information to it:

``` r
library(palmerpenguins)
#> 
#> Attaching package: 'palmerpenguins'
#> The following objects are masked from 'package:datasets':
#> 
#>     penguins, penguins_raw

penguins <- na.omit(penguins) # missing data is not supported yet, unfortunately
names(penguins) <- names(penguins) |> gsub("(_mm|_g)", "", x = _)

schema <- create_schema(penguins) |> 
  add_scatterplot(c("body_mass", "flipper_length")) |> 
  add_barplot(c("species")) |>
  add_fluctplot(c("species", "sex")) |>
  add_histogram(c("bill_length"))
```

The schema then is really just a list of messages:

``` r
schema
#> plotscaper schema:
#> add-plot { type: scatter, variables: c("body_mass", "flipper_length") }
#> add-plot { type: bar, variables: species }
#> add-plot { type: fluct, variables: c("species", "sex") }
#> add-plot { type: histo, variables: bill_length }
```

Typically, you’ll use the schema to add more plots. However, you can
also do other things such as select cases or set axis limits:

``` r
schema <- schema |>
  assign_cases(which(penguins$species == "Adelie")) |>
  set_scale("plot1", "x", min = 0) |>
  set_scale("plot1", "size", max = 5)

schema
#> plotscaper schema:
#> add-plot { type: scatter, variables: c("body_mass", "flipper_length") }
#> add-plot { type: bar, variables: species }
#> add-plot { type: fluct, variables: c("species", "sex") }
#> add-plot { type: histo, variables: bill_length }
#> set-assigned { cases: c(`1` = 0, `2` = 1, `3` = 2, `4` = 3, `5` = 4, `6` = 5, `7` = 6, `8` = 7, `9` = 8, `10` = 9, `11` = 10, `12` = 11, `13` = 12, `14` = 13, `15` = 14, `16` = 15, `17` = 16, `18` = 17, `19` = 18, `20` = 19, `21` = 20, `22` = 21, `23` = 22, `24` = 23, `25` = 24, `26` = 25, `27` = 26, `28` = 27, `29` = 28, `30` = 29, `31` = 30, `32` = 31, `33` = 32, `34` = 33, `35` = 34, `36` = 35, `37` = 36, `38` = 37, `39` = 38, `40` = 39, `41` = 40, `42` = 41, `43` = 42, `44` = 43, `45` = 44, `46` = 45, `47` = 46, `48` = 47, 
#> `49` = 48, `50` = 49, `51` = 50, `52` = 51, `53` = 52, `54` = 53, `55` = 54, `56` = 55, `57` = 56, `58` = 57, `59` = 58, `60` = 59, `61` = 60, `62` = 61, `63` = 62, `64` = 63, `65` = 64, `66` = 65, `67` = 66, `68` = 67, `69` = 68, `70` = 69, `71` = 70, `72` = 71, `73` = 72, `74` = 73, `75` = 74, `76` = 75, `77` = 76, `78` = 77, `79` = 78, `80` = 79, `81` = 80, `82` = 81, `83` = 82, `84` = 83, `85` = 84, `86` = 85, `87` = 86, `88` = 87, `89` = 88, `90` = 89, `91` = 90, `92` = 91, `93` = 92, `94` = 93, 
#> `95` = 94, `96` = 95, `97` = 96, `98` = 97, `99` = 98, `100` = 99, `101` = 100, `102` = 101, `103` = 102, `104` = 103, `105` = 104, `106` = 105, `107` = 106, `108` = 107, `109` = 108, `110` = 109, `111` = 110, `112` = 111, `113` = 112, `114` = 113, `115` = 114, `116` = 115, `117` = 116, `118` = 117, `119` = 118, `120` = 119, `121` = 120, `122` = 121, `123` = 122, `124` = 123, `125` = 124, `126` = 125, `127` = 126, `128` = 127, `129` = 128, `130` = 129, `131` = 130, `132` = 131, `133` = 132, `134` = 133, 
#> `135` = 134, `136` = 135, `137` = 136, `138` = 137, `139` = 138, `140` = 139, `141` = 140, `142` = 141, `143` = 142, `144` = 143, `145` = 144, `146` = 145), group: 1 }
#> set-scale { scale: x, min: 0 }
#> set-scale { scale: size, max: 5 }
```

In fact, most of the things you can do with the schema you can also do
interactively, and vice versa. We will see that in the next section.

### Rendering a scene

When it finally comes a time to turn the recipe into an actual
interactive figure or *scene*, we can do so by calling the `render`
function:

``` r
scene <- schema |> render()
scene
```

The `render` function takes the schema and turns it into a `htmlwidgets`
widget that we can interact with in RStudio viewer or embed in RMarkdown
documents. However, it can also do a little bit more than that.

*If you’re following along in RStudio*, try this:

``` r
scene |> select_cases(1:10)
```

You should see some cases of the data get highlighted. Importantly,
notice that the figure does not get re-rendered!

## The difference between scene and schema

Whereas the `create_schema` merely initializes a recipe which is just a
regular R object (a `list`), the `render` function renders the recipe
into an `htmlwidgets` widget, *and*, if inside a running R session, it
also launches an `httpuv` server for direct communication between the R
session and the figure.

We can use (mostly) the same functions to modify schema (created by call
to `create_schema`) and scene (created by call to `render`). The
difference is that while calling functions with a schema as the first
argument merely appends the corresponding message to the recipe, calling
functions with scene immediately sends a message to the figure via the
server.

That is, while the following code:

``` r
# NOT RUN
scene <- schema |> select_cases(20:30) |> render()
scene
scene
```

causes two full re-renders, the following code:

``` r
# NOT RUN
scene <- schema |> render()
scene |> select_cases(20:30)
scene |> select_cases(20:30)
```

causes only one render (if inside a running R session).

In other words, `plotscaper` functions such as `add_*`, `set_selected`,
and `set_scale` behave differently based on whether we call them on
scene or schema:

- **Schema**: calling a function lazily appends to a list of messages
  that will get executed in the future, when the schema is rendered
- **Scene**: calling a function immediately sends a message to the scene
  and mutates its state

The second method only works if we are in an interactive R session
because we need a server to communicate with the figure.

This is why running the following code (while the document you’re
reading is being knitted) throws an error:

``` r
interactive()
#> [1] FALSE
scene |> select_cases(1:10)
#> Error: You can only send messages to scene from within an interactive R session
```

When we knit an RMarkdown document, we generate a static HTML file. By
default, we cannot communicate with this file since it’s just a big blob
of HTML, CSS, and JavaScript. To only way to change the file is to
rewrite it. Thus, in RMarkdown, we can really only really write the
schema and `render` - we can’t do anything with the figure once it’s
been rendered.

In contrast, inside an interactive R session, we can launch a server
that will listen and respond to messages from the R session and send
them to the figure (and also send messages from the figure back to the R
session - this is done via WebSockets).

This also means there are some functions that it only make sense to use
inside a running R session. For example, the following functions query
the selection status of the figure:

``` r
scene |> selected_cases()
scene |> assigned_cases()
```

That means that you can, for example, render a figure, select some cases
of the data using a mouse, and then call `scene |> selected_cases()` to
get the row indices of those cases. This doesn’t really make sense when
writing a schema - the only way to select cases is via an explicit call
to `select_cases`, so we would be querying cases that we have already
specified before.

Likewise, there are functions such as `pop_plot` and `remove_plot` which
can be used to remove plots from scene. These don’t really make sense to
use while writing a schema - if you know that you don’t want a specific
plot, you can just delete the line which adds it to the recipe. However,
they *do* make sense when interacting with a scene inside a running R
session. Perhaps you found some interesting trend in your data and want
to see if it holds in other plots, but you’re running out of space in
the viewer - you can `pop_plot` to remove the last plot and `add_*` to
add a new plot, all the while keeping the rest of the state of the
figure intact!

## Troubleshooting the scene

Sometimes, when rendering multiple figures quickly, the figure may fail
to connect to the server or the server may failed to be launched
altogether. Often, the cause is that the default port number is already
taken. I will try to fix this bug in the future, however, for the time
being, you can always fix it by running either of the following
functions:

``` r
start_server(random_port = TRUE) # Starts a server on a new random port
```

or:

``` r
httpuv::stopAllServers() # Stops all servers, now you should be able to relaunch the server
```

## Bonus: Scatterplot matrix

Since the schema is lazy, we can use it to generate figures
programmatically. For example, here’s how we could create an interactive
scatterplot matrix (SPLOM) of the penguins data set:

``` r

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
```

Just to re-iterate the point from the previous section, we could also do
this interactively, by writing out the calls to add the plots ourselves:

``` r
scene <- create_schema(penguins) |> render(opts)

scene |> add_histogram(c("bill_depth"))
scene |> add_scatterplot(c("bill_depth", "flipper_length"))
scene |> add_scatterplot(c("bill_depth", "body_mass"))
...
```

However, having to do this for all nine plots might quickly get tedious.

As such, there are different reasons why you might want to do something
using a scene, a schema, or some combination of both. If you’re writing
an RMarkdown document, you don’t really have a choice - you can’t do
anything to a scene once it’s rendered.

Inside an interactive R session, you have more options. You can decide
you first want to create a highly customized schema and only then start
interacting with the figure live. Or you can just immediately fire off
`scene <- create_schema(data) |> render()` and do everything
interactively.

Each approach has some advantages and some disadvantages. With the
schema way, you can always re-create most of the state, so if you mess
up and need to go back, you can just print `scene` and you’re good to
go. With the interactive scene way, you’re more flexible and you have
the immediate feedback in seeing how the figure changes in front of you,
however, it may be more difficult to recover some state if there are
many intermediate steps.

## References

Horst, Allison Marie, Alison Presmanes Hill, and Kristen B Gorman. 2020.
*Palmerpenguins: Palmer Archipelago (Antarctica) Penguin Data*.
<https://doi.org/10.5281/zenodo.3960218>.

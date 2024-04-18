
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Plotscaper

<!-- badges: start -->
<!-- badges: end -->

Plotscaper is an R package designed for making interactive figures
geared towards data exploration. All plots in a `plotscaper` figure
support linked highlighting by default, and include a wide variety of
other interactions, including switching representation, changing
parameters, zooming, panning, and reordering.

## Quick start

To get started, install `plotscaper` with:

``` r
devtools::install_github("bartonicek/plotscape/packages/plotscaper")
```

Next, open up RStudio and run the following code:

``` r
library(plotscaper)
#> 
#> Attaching package: 'plotscaper'
#> The following object is masked from 'package:base':
#> 
#>     options

layout <- matrix(c(
  1, 1, 2, 3,
  1, 1, 4, 5,
  6, 7, 7, 7
), ncol = 4, byrow = TRUE)

set_scene(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot("city") |>
  add_histogram(c("sqft")) |>
  add_fluctplot(c("beds", "baths")) |>
  add_histogram2d(c("sqft", "price")) |>
  add_notes() |>
  add_parcoords(names(sacramento)) |>
  set_layout(layout)
```

<img src="man/figures/README-unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

In your viewer, you should now see something like the image above,
however, your version should be fully interactive (the above image is a
static snapshot is because `README.md` does not allow JavaScript,
unfortunately).

Try moving your mouse somewhere over the big scatterplot on the top
left, clicking and dragging to select some points. You should see the
corresponding cases highlight across all the other plots!

There are many other ways interacting with `plotscaper` figures. The
list includes:

- Assigning selected cases to persistent groups
- Changing the size of objects
- Increasing/decreasing the opacity (alpha)
- Panning
- Manipulating parameters such as histogram binwidth and anchor
- Modifying continuous axis limits
- Sorting and reordering discrete axes
- Changing the size of the individual plots

Click on the question mark in the top right of the figure to see the
list plus the corresponding key/mouse bindings.

## Anatomy of a `plotscaper` figure

There are quite a few things happening in the code of the figure above.
Let’s break it down piece by piece.

First, whenever we want to create a `plotscaper` figure, we need to set
up a scene. A scene is a kind of context into which all plots get
placed.

To set up a scene, run:

``` r
set_scene(data = sacramento)
```

where `data` is a `data.frame` object. Here we’re using the Sacramento
housing dataset from the `caret` package.

On its own, however, a scene doesn’t do anything. To create an
interactive figure, we need to populate it with plots. That’s what the
various `add_*plot` functions are for:

``` r
set_scene(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot("city")
```

<img src="man/figures/README-unnamed-chunk-5-1.png" width="75%" height="75%" style="display: block; margin: auto;" />

As you can see above, this creates a simple interactive figure with a
scatterplot and a barplot. Not much more to it. We specify which
variables we want to plot by a simple character vector of their names.

Each `plotscaper` figure is a `htmlwidgets` widget, which means that,
whenever we print the underlying object, `htmlwidgets` generates and
packages up the underlying HTML and sends it to the RStudio viewer
(which is a kind of Web browser). Thus, if we do something like this,
nothing happens:

``` r
s <- set_scene(sacramento) |>
  add_scatterplot(c("longitude", "latitude")) |>
  add_barplot("city")
```

However, printing the `s` object generates the figure:

``` r
s
```

<img src="man/figures/README-unnamed-chunk-7-1.png" width="75%" height="75%" style="display: block; margin: auto;" />

We can use this fact to generate figures programmatically using R. For
example, here’s how we could create an interactive scatterplot matrix
(SPLOM) of the `Iris` dataset:

``` r

iris_smaller <- iris[, 1:3]
keys <- names(iris_smaller)

s <- set_scene(iris_smaller)

for (i in 1:3) {
  for (j in 1:3) {
    # Add a scatterplot if row & column no.'s different
    if (i != j) s <- s |> add_scatterplot(c(keys[i], keys[j]))
    # Add a histogram if row & column no.'s match
    else s <- s |> add_histogram(c(keys[i])) 
  }
}

s
```

<img src="man/figures/README-unnamed-chunk-8-1.png" style="display: block; margin: auto;" />

### Layout

We can control the figure layout by using the `set_layout` function.
This works similar to the `layout` function from the `graphics` package.
We give it a matrix of numeric values representing the plot ids, and the
figure automatically resizes the plots based on how many equal-sized
rectangles in a grid each plot takes up.

Here’s how we can create a figure with large scatterplot on the
top-left, a tall histogram on the right-hand side, a short wide
histogram on the bottom, and a small section for notes (not-(e)-plot,
pardon the pun) on the bottom-right:

``` r

layout <- matrix(c(
  1, 1, 2,
  1, 1, 2,
  3, 3, 4
), ncol = 3, byrow = TRUE)

set_scene(sacramento) |>
  add_scatterplot(c("sqft", "price")) |>
  add_histogram("price") |>
  add_histogram("sqft") |>
  add_notes() |>
  set_layout(layout)
```

<img src="man/figures/README-unnamed-chunk-9-1.png" style="display: block; margin: auto;" />

(it doesn’t matter in which order we call the `add_*` and `set_layout`
function, as all the important stuff happens when the HTML for the
figure gets generated)

The individual plots can still be resized by pressing and holding the
`S` key and then dragging a widget in the bottom right of the plot area.
Note however that this may result in gaps in the layout.

## Reducers

> This section goes into the deeper properties of `plotscaper`,

One of the main goals of the `plotscaper` project is to explore the ways
of combining graphical objects and statistics to produce interactive
visualizations that behave in some specific, consistent ways. Phew, that
was a mouthful.

A key idea for achieving this is the concept of reducers. A reducer is a
pair of functions:

- An *initial function* (`initialfn`) which takes no arguments and
  produces some value (also known as a “thunk”).
- A *reduce function* (`reducefn`) which combines two values to produce
  a new one.

Further, `initialfn` and `reducefn` must have the following two
properties:

``` r
reducefn(a, initialfn()) === a                                  # Unitality
reducefn(reducefn(a, b), c) === reducefn(a, reducefn(b, c))     # Associativity
```

If you’re familiar with how R’s higher-order `Reduce` function, `reduce`
/ `fold` functions from other programming languages, or if you know
something about [Monoids](https://en.wikipedia.org/wiki/Monoid), then
this should be fairly familiar. If this all looks weird to you, don’t
worry, it looked weird to me the first time I saw it too.

The important thing to grasp is that some functions that behave this way
and others don’t. For example, summation behaves like this:

``` r
1 + 0 == 1
#> [1] TRUE
(1 + 2) + 3 == 1 + (2 + 3)
#> [1] TRUE
```

multiplication does as well:

``` r
10 * 1 == 10
#> [1] TRUE
(10 * 20) * 30 == 10 * (20 * 30)
#> [1] TRUE
```

concatenation of strings too:

``` r
paste0("a", "") == "a"
#> [1] TRUE
paste0(paste0("a", "b"), "c") == paste0("a", paste0("b", "c"))
#> [1] TRUE
```

but, for example, exponentiation does not:

``` r
(2)^1 == 1                    # This is okay
#> [1] FALSE
(2 ^ 3) ^ 4 == 2 ^ (3 ^ 4)    # But this is not!
#> [1] FALSE
```

In `plotscaper`, we use reducers to compute the statistics underlying
the visualization. It is necessary for them to have the above properties
because otherwise otherwise some key graphical operations such as
stacking would not work.

But, I hear you say: “why is stacking important? can’t we just use
dodging?” I would argue that in the context of interactive graphics,
dodging is not a good idea, for several reasons. If we want our plots to
support bi-directional linked selection, then every graphical object
needs to be able to:

1.  Be selected
2.  Display selected parts
3.  (do both in a sensible manner)

This can be a problem with dodging. Specifically, since the parts of
each object are independent, linked selection can cause the overall
shape of the plot to vary wildly. For example, in a dodged barplot,
linked selection can cause bars to shrink and grow erratically, and
flicker in and out of existence. Further, since the height of the
tallest dodged sub-bar can change with selection, we may have to change
axis limits as well.

In contrast, in a stacked barplot, the overall shape of the plot stays
constant throughout linked selection. This is because the heights of the
stacked sub-bars add up to the height of the whole bars:

``` r
library(ggplot2)
library(patchwork)

set.seed(12345)
mtcars$cyl1 <- factor(mtcars$cyl)
mtcars$cyl2 <- factor(sample(mtcars$cyl))
mtcars$cyl3 <- factor(sample(mtcars$cyl))

p0 <- ggplot(mtcars, aes(am)) + 
  scale_x_continuous(breaks = c(0, 1), expand = c(0.2, 0.2)) +
  scale_y_continuous(breaks = seq(0, 24, by = 2), expand = c(0, 1)) +
  scale_fill_brewer(palette = "Set2") +
  guides(fill = "none") + 
  theme_bw() +
  theme(panel.grid = element_blank())

p <- list()

for (i in 1:3) {
  p[[i]] <- p0 + geom_bar(aes(fill = .data[[paste0("cyl", i)]]), width = 0.75)
  p[[3 + i]] <- p0 + geom_bar(aes(fill = .data[[paste0("cyl", i)]]), 
                              position = "dodge")
}

(p[[1]] + p[[2]] + p[[3]]) / (p[[4]] + p[[5]] + p[[6]])
```

<img src="man/figures/README-unnamed-chunk-15-1.png" style="display: block; margin: auto;" />

> Notice that in the top row, the overall shape of the bars remains the
> same, whereas in the bottom row it changes drastically. Also notice
> that in the bottom row, the upper y-axis limit changes from plot to
> plot. Finally, look at the bars in the middle bottom plot belonging to
> the category 1 - they are wider because the bar representing the
> orange subcategory is missing.

I haven’t found any good citation for this so far, but from my own
experience I would argue that interactive figures that change less with
interaction are more visually appealing and easier to read than figures
that change a lot. Also, from the [Gestalt principles of visual
perception](http://www.scholarpedia.org/article/Gestalt_principles), we
know that if we want to group things visually together, we place them in
a common, closed region. This is what stacking does.

However, for stacking to produce meaningful statistics, the summaries we
are stacking need to be *stackable*. For example, stacking counts and
sums produces bars which show a valid overall statistics, however,
stacking means does not. For example, the height of the bars in the
following plot is completely meaningless:

``` r
p0 + 
  geom_bar(aes(y = mpg, fill = cyl1), stat = "summary", fun = "mean",
           position = "stack") + # Just to highlight that we are, indeed, stacking 
  scale_y_continuous()
```

<img src="man/figures/README-unnamed-chunk-16-1.png" style="display: block; margin: auto;" />

> What kind of statistic is a sum of means?

And this is precisely what the definition of reducers guarantees.

``` r

library(htmlwidgets)

reducer1 <- reducer(
  name = "max",
  initialfn = JS("() => -Infinity"),
  reducefn = JS("(a, b) => Math.max(a, b)")
)

set_scene(sacramento) |>
  add_scatterplot(c("sqft", "price")) |>
  add_barplot(c("city", "price"), 
              options(reducer = reducer1))
```

<img src="man/figures/README-unnamed-chunk-17-1.png" style="display: block; margin: auto;" />

## Performance

While `plotscaper` wasn’t designed specifically for performance, it can
perform fairly well on moderately-sized datasets (thanks largely to the
work of the super smart people who optimize the JavaScript engines like
V8, rather than any real ability on my part).

For example, if you want to put it to a stress test, try creating a
figure with the entire `diamonds` dataset from the `ggplot2` package:

``` r
set_scene(ggplot2::diamonds) |>
  add_scatterplot(c("carat", "price")) |>
  add_fluctplot(c("cut", "color")) |>
  add_barplot(c("color"))
```

<img src="man/figures/README-unnamed-chunk-18-1.png" style="display: block; margin: auto;" />

With 50,000 cases, dragging to select points in the scatterplot becomes
a bit sluggish on my machine, but still fast enough to give the figure
an “interactive” rather than “slideshow” feel. Your mileage may vary.
Note that most of the slowdown is due to rendering rather than
computation - removing the scatterplot with its 50,000 points makes the
interactions a lot snappier.

Also, frustratingly, there seems to be a small slowdown when interacting
with the figure in the RStudio viewer panel rather than in the browser
window. Interestingly, this does not seem to be related to the dataset
size. I’m not very familiar with the RStudio internals and have no idea
why this might be, but for now, if you want faster interactions I
recommend just opening up a browser window, e.g. by clicking the icon in
the top right of the viewer:

<img src="man/figures/browser.png" width="75%" height="75%" style="display: block; margin: auto;" />

(if you know the reason behind this slowdown, please email me at
<abar435@aucklanduni.ac.nz>)

Anyway, if you need fast figures with larger datasets, I recommend:

- Run the figure in the browser rather than viewer
- Use plots which summarize the data (e.g. barplots, 2D histograms),
  rather than plots which show all of the datapoints
- If everything else fails, subsample the data

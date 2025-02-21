## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>")

## -----------------------------------------------------------------------------
library(plotscaper)

names(airquality) <- c("ozone", "solar radiation", "wind", 
                       "temperature", "month", "day")

create_schema(airquality) |>
  add_scatterplot(c("solar radiation", "ozone")) |>
  add_barplot(c("month")) |>
  render()


## -----------------------------------------------------------------------------
library(ggplot2)

mtcars$am <- factor(mtcars$am)
mtcars$cyl <- factor(mtcars$cyl)

## -----------------------------------------------------------------------------
theme_set(theme_bw() + 
            theme(panel.grid = element_blank(),
                  panel.border = element_blank(),
                  panel.background = element_rect(fill = "whitesmoke")))

ggplot(mtcars, aes(x = cyl, y = mpg, fill = am)) +
  geom_bar(stat = "summary", fun = mean) +
  scale_fill_manual(values = c("#92c9f6", "#377eb8")) +
  guides(fill = "none")

## -----------------------------------------------------------------------------
# geom_bar(stat = "summary", fun = mean)

## -----------------------------------------------------------------------------
# geom_bar(stat = "summary", fun = mean, position = "stack")

## -----------------------------------------------------------------------------
mean(1:3)
mean(mean(1:2), 3)

## -----------------------------------------------------------------------------
ggplot(mtcars, aes(x = cyl, y = mpg, fill = am)) +
  geom_bar(stat = "summary", fun = mean, position = "dodge") +
  scale_fill_manual(values = c("#92c9f6", "#377eb8")) +
  guides(fill = "none")

## -----------------------------------------------------------------------------
library(patchwork)
set.seed(59450)

mtcars$am1 <- factor(sample(rep(0:1, c(28, 4))))
mtcars$am2 <- factor(sample(rep(0:1, c(16, 16))))
mtcars$am3 <- factor(sample(rep(0:1, c(4, 28))))

p0 <- ggplot(mtcars, aes(cyl)) + 
  scale_y_continuous(breaks = seq(0, 24, by = 2), expand = c(0, 1)) +
  scale_fill_manual(values = c("#92c9f6", "#377eb8")) +
  labs(x = NULL, y = NULL) +
  guides(fill = "none")

p <- list()

for (i in 1:3) {
  p[[i]] <- p0 + geom_bar(aes(fill = .data[[paste0("am", i)]]), width = 0.75)
  p[[3 + i]] <- plot_spacer()
  p[[6 + i]] <- p0 + geom_bar(aes(fill = .data[[paste0("am", i)]]), 
                              position = "dodge")
}

wrap_plots(p, nrow = 3, heights = c(1, 0.2, 1))

## -----------------------------------------------------------------------------
prod(2:4)
prod(prod(2:3), 4)

## -----------------------------------------------------------------------------
max(c(1, 2, 999))
max(max(1, 2), 999)

## -----------------------------------------------------------------------------
euclid_norm_append <- function(x, y = 0) sqrt(sum(x^2) + sum(y^2))

euclid_norm_append(c(1, 2), 3)
euclid_norm_append(c(1, 2, 3))

## -----------------------------------------------------------------------------
(2^3)^4
2^(3^4)

## -----------------------------------------------------------------------------
# Make the reducer - really just an R list() with some serialization metadata
max_reducer <- reducer(
  name = "max",
  initialfn = "() => 0",
  reducefn = "(x, y) => Math.max(x, y)"
)

create_schema(airquality) |>
  add_scatterplot(c("solar radiation", "ozone")) |>
  add_barplot(c("day", "ozone"), options = list(reducer = max_reducer)) |>
  render()



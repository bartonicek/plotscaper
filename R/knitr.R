.onLoad <- function(...) {
  vctrs::s3_register("knitr::knit_print", "plotscaper_scene")
}

knit_print.plotscaper_scene <- function(x, ..., options = NULL) {
  knitr::knit_print(x$widget, options = options, ...)
}


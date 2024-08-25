#' @import knitr
#' @method knit_print plotscaper_scene
#' @export
knit_print.plotscaper_scene <- function(x, ..., options = NULL) {
  knitr::knit_print(x$widget, options = options, ...)
}


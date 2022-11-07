#' Pre-mark cases in the data
#'
#' @param scene A plotscaper scene object
#' @param indices A vector of indices indicating which cases in the data should be marked
#' @param mapping A number indicating which membership should be assigned to the cases
#'
#' @export

ps_premark <- function(scene, indices, membership) {
  scene$x$premark$indices <- append(scene$x$premark$indices, list(indices - 1))
  scene$x$premark$membership <- append(scene$x$premark$membership, list(membership))
  scene
}

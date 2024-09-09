#' Contextualize R objects
#'
#' @param objects A list of R objects to be contextualized.
#' @return An object of class "ask_context"
#' @export
context_objects <- function(objects) {
  rlang::check_installed("constructive")
  context("Object code" = c("```", constructive::construct_multi(objects)$code, "```"))
}

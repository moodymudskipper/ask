globals <- new.env()
globals$memoised <- list()

#' Fetch the last updated conversation
#'
#' @export
last_conversation <- function() {
  globals$last_conversation
}

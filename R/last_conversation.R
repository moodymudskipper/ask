globals <- new.env()

#' Fetch the last updated conversation
#'
#' @export
last_conversation <- function() {
  globals$last_conversation
}

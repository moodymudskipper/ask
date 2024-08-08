#' Ask in the context of a script
#'
#' @inheritParams ask
#' @param path path to a script, if left NULL the active script is considered
#' @param ... forwarded to `ask()`
#'
#' @export
ask_script <- function(content = listen(), path = NULL, ...) {
  if (is.null(path)) {
    current_file_contents <- rstudioapi::getSourceEditorContext()$contents
  } else {
    current_file_contents <- readLines(path)
  }

  content <- prefix(
    content,
    "I have a request about a R script",
    "Request:"
  )
  content <- suffix(
    content,
    "My Code:",
    current_file_contents
  )
  ask(content, ...)
}

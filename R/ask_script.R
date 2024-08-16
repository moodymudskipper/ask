#' Ask in the context of a script
#'
#' @inheritParams ask
#' @param file path to a script, if left NULL the active script is considered
#' @param ... forwarded to `ask()`
#'
#' @export
ask_script <- function(content = listen(), file = NULL, context = NULL,  ...) {
  context <- context(
    context_script(file),
    context
  )
  ask(content, context, ...)
}

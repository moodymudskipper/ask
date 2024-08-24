#' Ask a boolean question
#'
#' @inheritParams ask
#' @param ... forwarded to `ask()`
#' @param unit Optional, if not the SI is used, but better provide it.
#'
#' @export
ask_boolean <- function(prompt = listen(), context = NULL, ...) {
  context <- context(
    context_boolean(),
    context
  )
  conversation <- ask(prompt, context, ...)
  answer <- extract_last_answer(conversation)
  as.logical(answer)
}

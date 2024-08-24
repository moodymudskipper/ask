#' @export
#' @rdname ask_boolean
ask_numeric <- function(prompt = listen(), unit = NULL, context = NULL, ...) {
  context <- context(
    context_numeric(unit),
    context
  )
  conversation <- ask(prompt, context, ...)
  answer <- extract_last_answer(conversation)
  answer <- gsub("[^0-9.]", "", answer)
  suppressWarnings(as.numeric(answer))
}

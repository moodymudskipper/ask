#' Ask a boolean question
#'
#' @inheritParams ask
#' @param ... forwarded to `ask()`
#' @param unit Optional, if not the SI is used, but better provide it.
#'
#' @export
ask_boolean <- function(content = listen(), context = NULL, ...) {
  context <- context(
    context_boolean(),
    context
  )
  x <- ask(content, context, ...)
  last_response <- x[[length(x)]]$response
  data <- response_data(last_response)
  out <- data$choices$message$content
  as.logical(out)
}

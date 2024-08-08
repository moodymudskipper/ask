#' Ask a boolean question
#'
#' @inheritParams ask
#' @param ... forwarded to `ask()`
#' @param unit Optional, if not the SI is used, but better provide it.
#'
#' @export
ask_boolean <- function(content = listen(), ...) {
  content <- prefix(
    content,
    "For this request answer only TRUE or FALSE or NA.",
    "The answer is upper case, no quotes or punctuation.",
    "If the answer is not clear or the question is not boolean: return NA.",
    "Request:"
  )
  response <- ask_response(list(list(role = "user", content = content)), ...)
  data <- response_data(response)
  out <- data$choices$message$content
  as.logical(out)
}

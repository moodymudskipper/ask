#' @export
#' @rdname ask_boolean
ask_numeric <- function(content = listen(), unit = NULL, context = NULL, ...) {
  context <- context(
    context_numeric(unit),
    context
  )
  x <- ask(content, context, ...)
  last_response <- x[[length(x)]]$response
  data <- response_data(last_response)
  out <- data$choices$message$content
  out <- gsub("[^0-9.]", "", out)
  suppressWarnings(as.numeric(out))
}

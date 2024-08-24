extract_last_answer <- function(conversation) {
  last_response <- conversation[[length(conversation)]]$response
  data <- response_data(last_response)
  if (!is.null(data$error)) {
    abort(data$error$message)
  }
  if (startsWith(data$model, "llama")) {
    answer <- data$response
  } else {
    answer <- data$choices$message$content
  }
  answer
}

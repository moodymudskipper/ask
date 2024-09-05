extract_answers <- function(conversation) {
  data <- conversation$data
  # currently we support only one model per conversation
  model <- data$model[[1]]
  if (startsWith(model, "llama")) {
    answer <- data$response
  } else {
    answer_df <- dplyr::tibble(
      role = data$choices$message$role,
      message = data$choices$message$content
    )
  }
  answer_df
}

extract_last_answer <- function(conversation) {
  data <- conversation$data[nrow(conversation),]
  if (startsWith(data$model, "llama")) {
    answer <- data$response
  } else {
    answer <- data$choices$message$content
  }
  answer
}

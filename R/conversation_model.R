conversation_model <- function(conversation) {
  model <- conversation$data[[1]]$model
  if (is.null(model)) {
    abort("Couldn't extract model name from `conversation`")
  }
  model
}

conversation_model_family <- function(conversation) {
  model_family(conversation_model(conversation))
}

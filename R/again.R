#' Ask again
#'
#' Ask the same thing again, by default with the same parameters, if `cache`
#' is used a new request will be sent for the given arguments, and cached
#' instead of the older value.
#'
#' @inheritParams follow_up
#' @export
again <- function(
    conversation = last_conversation(),
    model = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL,
    api_key = NULL) {
  last <- conversation[nrow(conversation),]
  conversation <- ask_impl(
    prompt = NULL,
    conversation = conversation,
    model = model %||% last$data$model,
    api_args = api_args %||% last$api_args,
    cache = cache,
    api_key = api_key
  )
  conversation
}

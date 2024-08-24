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
    model = getOption("ask.model", "gpt-4o"),
    seed = NULL,
    temperature = NULL,
    top_p = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  last <- conversation[[length(conversation)]]
  conversation <- ask_impl(
    prompt = NULL,
    conversation = conversation,
    model = model %||% last$model,
    seed = seed %||% last$seed,
    temperature = temperature %||% last$temperature,
    top_p = top_p %||% last$top_p,
    cache = cache,
    api_key = api_key
  )
  conversation
}

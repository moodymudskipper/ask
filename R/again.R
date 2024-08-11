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
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = NULL,
    top_p = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")) {

  messages <- lapply(conversation, function(x) {
    list(
      list(
        role = "user",
        content = x$prompt
      ),
      list(
        role = "assistant",
        content = response_data(x$response)$choices$message$content
      )
    )
  })
  messages <- unlist(messages, recursive = FALSE)
  messages[[length(messages)]] <- NULL
  last <- conversation[[length(conversation)]]
  ask_impl(
    messages = messages,
    model = model %||% last$model,
    seed = seed %||% last$seed,
    temperature = temperature %||% last$temperature,
    top_p = top_p %||% last$top_p,
    cache = cache,
    api_key = api_key,
    forget = TRUE
  )
}

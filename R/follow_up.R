#' follow up
#'
#' @inheritParams ask
#' @param conversation A conversation, initiated by `ask()` or followed up by
#'   `follow_up()`
#' @param model,seed,temperature,top_p inherited by default from the last item
#' of `conversation` by default
#'
#' @return a conversation object
#' @export
follow_up <- function(
    content = listen(),
    conversation = last_conversation(),
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = NULL,
    top_p = NULL,
    local_seed = NULL,
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
  content <- paste(content, collapse = "\n")
  messages[[length(messages) + 1]] <- list(role = "user", content = content)
  last <- conversation[[length(conversation)]]
  new_conversation <- ask_impl(
    messages = messages,
    model = model %||% last$model,
    seed = seed %||% last$seed,
    temperature = temperature %||% last$temperature,
    top_p = top_p %||% last$top_p,
    local_seed = local_seed,
    api_key = api_key
  )
  conversation <- structure(c(conversation, new_conversation), class = "conversation")
  globals$last_conversation <- conversation
  conversation
}

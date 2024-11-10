#' Follow up a request
#'
#' Continue a conversation, by default with the same parameters.
#'
#' @inheritParams ask
#' @param conversation A conversation, initiated by `ask()` or followed up by
#'   `follow_up()`
#' @param model,api_args inherited from the last item
#' of `conversation` by default
#'
#' @return a conversation object
#' @export
follow_up <- function(
    prompt = listen(),
    context = NULL,
    conversation = last_conversation(),
    image = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL,
    api_key = NULL) {
  # FIXME: check that we stay in the same model family

  last <- conversation[nrow(conversation),]
  conversation <- ask_impl(
    prompt = prompt,
    context = context,
    conversation = conversation,
    model = conversation_model(conversation),
    image = image,
    cache = cache,
    api_args = api_args %||% last$api_args[[1]],
    api_key = api_key
  )
  conversation
}


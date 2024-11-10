#' Follow up a request
#'
#' Continue a conversation, by default with the same parameters.
#'
#' @inheritParams ask
#' @param conversation A conversation, initiated by `ask()` or followed up by
#'   `follow_up()`
#' @param model,seed,temperature,top_p inherited from the last item
#' of `conversation` by default
#'
#' @return a conversation object
#' @export
follow_up <- function(
    prompt = listen(),
    context = NULL,
    conversation = last_conversation(),
    seed = NULL,
    temperature = NULL,
    top_p = NULL,
    image = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  # FIXME: check that we stay in the same model family

  last <- conversation[nrow(conversation),]
  conversation <- ask_impl(
    prompt = prompt,
    context = context,
    conversation = conversation,
    model = conversation_model(conversation),
    seed = seed %||% last$seed,
    temperature = temperature %||% last$temperature,
    top_p = top_p %||% last$top_p,
    image = image,
    cache = cache,
    api_key = api_key
  )
  conversation
}


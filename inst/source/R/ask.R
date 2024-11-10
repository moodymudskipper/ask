#' Ask anything
#'
#' @param prompt Your request, a string or a character vector that will be
#'   concatenated to a string with line breaks as separators.
#' @param context An object of class "ask_context" usually built from a call
#'   to `context()` or a `context_*()` function. It is used to define a "system"
#'   message that define the behavior, tone or focus of the assistant.
#' @param model The model to choose, see https://platform.openai.com/docs/models
#'   or call `all_models()` for chatgpt model, or use ollama models such as
#'   "llama3.1".
#' @param api_args Additional arguments to the api, depend on the model and rarely needed, most useful ones
#'   include `temperature` and `seed`.
#' @param image Path or URL to image to provide. Only considered for gpt models.
#' @param cache A path where to cache the outputs, or "ram" to store them
#' in RAM. useful to spare tokens and to have reproducible code.
#' @param api_key API key
#'
#' @return a converstaion object
#' @export
ask <- function(
    prompt = listen(),
    context = NULL,
    model = getOption("ask.model", "gpt-4o"),
    image = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL,
    api_key = NULL
    ) {
  ask_impl(
    prompt = prompt,
    context = context,
    model = model,
    image = image,
    cache = cache,
    api_args = api_args,
    api_key = api_key
  )
}


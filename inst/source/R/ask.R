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
#' @param temperature Choose higher `temperature` for more diverse and
#'   unexpected results, and lower `temperature` for more controlled and
#'   consistent text.
#' @param top_p Choose high `top_p` for creative applications like storytelling,
#'   poetry, or brainstorming. Choose low `top_p` for applications requiring
#'   precision and coherence, such as technical writing, factual prompt, or summarization.
#' @param image Path or URL to image to provide. Only considered for gpt models.
#' @param seed The seed used by the model, makes things more reproducible, but
#'   not completely, due to the nature of LLMs. See `cache` to work around
#'   that.
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
    seed = NULL,
    temperature = 1,
    top_p = 1,
    image = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")
    ) {

  ask_impl(
    prompt = prompt,
    context = context,
    model = model,
    seed = seed,
    temperature = temperature,
    top_p = top_p,
    image = image,
    cache = cache,
    api_key = api_key
  )
}


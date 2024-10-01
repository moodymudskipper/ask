#' Ask and copy output to clipboard
#'
#' This function behaves like `ask()` but copies the output to the clipboard.
#'
#' @inheritParams ask
#' @export
ask_clipboard <- function(
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
  rlang::check_installed("clipr")
  conversation <- ask(
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
  answer <- extract_last_answer(conversation)
  clipr::write_clip(answer, allow_non_interactive = TRUE)
  invisible(conversation)
}


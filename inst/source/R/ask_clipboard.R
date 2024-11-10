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
    image = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL,
    api_key = NULL
) {
  rlang::check_installed("clipr")
  conversation <- ask(
    prompt = prompt,
    context = context,
    model = model,
    image = image,
    cache = cache,
    api_args = api_args,
    api_key = api_key
  )
  answer <- extract_last_answer(conversation)
  clipr::write_clip(answer, allow_non_interactive = TRUE)
  invisible(conversation)
}


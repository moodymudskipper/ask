#' Contextualize clipboard content
#'
#' @return An object of class "ask_context"
#' @export
context_clipboard <- function() {
  rlang::check_installed("clipr")
  clipboard_content <- clipr::read_clip(allow_non_interactive = TRUE)


  # Check if the clipboard content is valid R code
  is_valid_r_code <- TRUE
  code <- try(parse(text = clipboard_content), silent = TRUE)
  if (
    inherits(code, "try-error") ||
    (length(clipboard_content) == 1 && is.symbol(code[[1]]))
  ) {
    is_valid_r_code <- FALSE
  }
  if (is_valid_r_code) {
    context("Clipboard content" := c("```", clipboard_content, "```"))
  } else {
    context("Clipboard content" := clipboard_content)
  }
}



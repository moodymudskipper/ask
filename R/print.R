#' @export
print.conversation <- function(x, ...) {
  answer <- extract_last_answer(x)
  writeLines(answer)
  invisible(x)
}

response_data <- function(x) {
  raw_content <- httr::content(x, "raw")
  char_content <- rawToChar(raw_content)
  jsonlite::fromJSON(char_content)
}

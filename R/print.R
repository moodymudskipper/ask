#' @export
print.conversation <- function(x, ...) {
  last_response <- x[[length(x)]]$response
  data <- response_data(last_response)
  cat(data$choices$message$content)
  invisible(x)
}

response_data <- function(x) {
  raw_content <- httr::content(x, "raw")
  char_content <- rawToChar(raw_content)
  jsonlite::fromJSON(char_content)
}

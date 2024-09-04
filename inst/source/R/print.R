#' @export
print.conversation <- function(x, ...) {
  answer <- extract_last_answer(x)
  writeLines(answer)
  invisible(x)
}

response_data <- function(x) {
  raw_content <- httr::content(x, "raw")
  char_content <- rawToChar(raw_content)
  data <- jsonlite::fromJSON(char_content)
  if (!is.null(data[["error"]])) {
    abort(data$error$message)
  }
  if (startsWith(data$model, "llama")) {
    data$context <- list(data$context)
    data <- dplyr::as_tibble(data)
  } else {
    data$usage <- dplyr::as_tibble(data$usage)
    # some versions of the api contain NULL elements
    data <- Filter(Negate(is.null), data)
    data$system_fingerprint <- NULL
    data <- dplyr::as_tibble(data)
  }
  data
}

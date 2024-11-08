#' @export
print.conversation <- function(x, ..., venue = "viewer") {
  if (venue == "console") {
    answer <- extract_last_answer(x)
    writeLines(answer)
  } else if (venue == "viewer") {
    rmd <- build_convo_rmd(x)
    html <- tempfile(fileext = ".html")
    rmarkdown::render(rmd, output_file = html, quiet = TRUE)
    viewer2(html)
  }
  invisible(x)
}

response_data <- function(x) {
  raw_content <- httr::content(x, "raw")
  char_content <- rawToChar(raw_content)
  data <- jsonlite::parse_json(char_content)
  data
}

#' listen to voice input
#'
#' @return A string
#' @export
listen <- function() {
  out <- NULL # for check notes, will be defined by python script
  file <- system.file("speech_to_r.py", package = "ask")
  writeLines(cli::col_red("Listening..."))
  reticulate::source_python(file)
  out
}



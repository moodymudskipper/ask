prefix <- function(content, ...) {
  content <- paste(content, collapse = "\n")
  prefix <- paste(c(...), collapse = "\n")
  paste0(prefix, "\n\n", content)
}

suffix <- function(content, ...) {
  content <- paste(content, collapse = "\n")
  suffix <- paste(c(...), collapse = "\n")
  paste0(content, "\n\n", suffix)
}


build_convo_rmd <- function(convo, path = tempfile(fileext = ".Rmd")) {
  code <- rmd_header
  questions <- convo$prompt
  if (conversation_model_family(convo) == "gpt") {
    # consider structured output if relevant
    tool_calls <- NULL # convo$data$choices$message$tool_calls
    if (!is.null(tool_calls) && all(lengths(tool_calls))) {
      answers <- tool_calls
    } else {
      answers <- purrr::map_chr(convo$data, list("choices", 1, "message", "content"))
    }
  } else if (conversation_model_family(convo) == "anthropic") {
    tool_calls <- NULL # convo$data$choices$message$tool_calls
    if (!is.null(tool_calls) && all(lengths(tool_calls))) {
      answers <- tool_calls
    } else {
      answers <- purrr::map_chr(convo$data, list("content", 1,  "text"))
    }
  } else if (conversation_model_family(convo) == "llama") {
    answers <- purrr::map_chr(convo$data, "response")
  }

  n <- length(questions)
  for (i in seq_len(n)) {
    code <- c(code, build_html_message(questions[[i]], "question"))
    code <- c(code, build_html_message(answers[[i]], "answer", i == n))
  }
  code <- paste(code, collapse = "\n")
  writeLines(code, con = path)
  return(path)
}


truncate <- function(x, n = 80) {
  lines <- strsplit(x, "\n")[[1]]
  if (length(lines) == 1 && nchar(x) <= n) return(x)
  if (startsWith(lines[1], "```")) {
    return("*code*")
  } else   if (startsWith(lines[1], "* ") || startsWith(lines[1], "- ")) {
    return("*list*")
  }
  short <- substr(lines[1], 1, n-3)
  odd_backquotes <- sum(strsplit(short, "")[[1]] == "`") %% 2
  if (odd_backquotes) {
    if (endsWith(short, "`")) {
      short <- substr(short, 1, n-4)
    } else {
      short <- paste0(short, "`")
    }
  }
  paste0(short, "...")
}

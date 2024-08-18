#' Ask for script updates in place
#'
#' This will change files in place a terminal command in a new terminal, and print extra
#' information in the R console.
#'
#' @inheritParams ask
#' @param ... Forwarded to `ask()`
#'
#' @export
#' @examples
#' \dontrun{
#' ask_in_place("update the existing readme with useful missing info", context = context_repo())
#' ask_terminal("show the latest 5 changes in compact form")
#' }
ask_in_place <- function(content = listen(), context = NULL, ...) {
  context <- context(
    context_in_place(),
    context
  )
  x <- ask(content, context, ...)
  last_response <- x[[length(x)]]$response
  data <- response_data(last_response)
  out <- data$choices$message$content
  out <- strsplit(out, "\n")[[1]]
  chunks <- split(out, cumsum(startsWith(out, "- file: ")))
  if (!startsWith(chunks[[1]][1], "- file: ")) {
    writeLines(chunks[[1]])
    chunks[[1]] <- NULL
  }
  for (chunk in chunks) {
    # remove dash and space
    file <- sub("^- file: ", "", chunk[[1]])
    # remove potential quotes
    file <- sub("^'(.*)'$", "\\1", file)
    file <- sub("^`(.*)`$", "\\1", file)
    # remove file line
    chunk <- chunk[-1]

    # if the code is empty, remove the file
    if (all(sub(" ", "", chunk) == "")) {
      file.remove(file)
      next
    }

    # remove opening and closing  code chunk triple backquotes if relevant
    if (startsWith(chunk[[1]], "```")) {
      chunk <- chunk[-1]
      if (!startsWith(chunk[[length(chunk)]], "```")) {
        abort("unexpected answer format")
      }
      chunk <- chunk[-length(chunk)]
    }
    if (!dir.exists(dirname(file))) {
      dir.create(dirname(file), recursive = TRUE)
    }
    writeLines(chunk, file)
  }
  out
  invisible(x)
}

context_in_place <- function() {
  context(
    "Output format" = c(
      "You are a helpful R assistant.",
      "Your task is to provide the full code of scripts that have been created,",
      "modified, or deleted.",
      "It is absolutely essential to provide the output structured as follows",
      "You will provide the output as bullet points",
      "These bulletpoints must be formatted as '- file: FILE'",
      "where FILE is to be replaced by the full relative file path",
      "in a R repository. (created if relevant)",
      "These might for instance be scripts in the 'R' folder,",
      "tests under 'tests/testthat/' (in that case no need to attach testthat),",
      "a 'README.Rmd' file (always prefer .Rmd to .md), a 'NEWS.md' file or any other file.",
      "Under each bullet point you will print the new code of each affected file, and nothing else.",
      "Deleted file are displayed with no code.",
      "NEVER provide additional information after bullet points.",
      "If you must provide extra information, provide it at the top before any bullet point,",
      "and not as a bullet point."
      # for some reason the following makes too many NAs happen, so better
      # do this with post-processing
      # "If the request is not related to R script creation, modification or deletion,",
      # " the answer should only be 'NA' and nothing more."
    )
  )
}

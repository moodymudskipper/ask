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

  # edit file lines
  out <- gsub("\n#? *-[fF]ile:", "\n -file:", out)

  # make sure file lines are outside of the chunks
  out <- gsub(
    "\n(```[^\n]*\n)(^- file: [^\n]*\n)",
    "\n\\2\\1",
    out,
  )

  out <- strsplit(out, "\n")[[1]]

  chunks <- split(out, cumsum(grepl("^- [fF]ile: ", out)))
  # capture and print header text if relevant
  if (!grepl("^- [fF]ile: ", chunks[[1]][1])) {
    # writeLines(chunks[[1]])
    chunks[[1]] <- NULL
  }
  for (chunk in chunks) {

    # remove dash and space
    file <- sub("^- [fF]ile: ", "", chunk[[1]])
    # remove potential quotes
    file <- sub("^'(.*)'$", "\\1", file)
    file <- sub("^`(.*)`$", "\\1", file)
    # remove file line
    chunk <- chunk[-1]

    triple_bq_lgl <- startsWith(chunk, "```")
    chunk <- chunk[!cumprod(!triple_bq_lgl) & !rev(cumprod(!rev(triple_bq_lgl)))]

    # if the code is empty, remove the file
    if (!length(chunk) || all(sub(" ", "", chunk) == "")) {
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
      "You are a helpful R assistant, assuming we are working in a R package",
      "or an R project folder.",
      "Your task is to provide the full code of scripts that have been created,",
      "modified, or deleted.",
      "A renaming operation is the combination of a creation (copy) and a deletion.",
      "It is absolutely essential to provide the output structured as follows:",
      "* Part 1 (optional): Start your answer with optional commentary about the",
      "  rest of the answer. Avoid whenever possible.",
      "* Part2: for each created, modified or deleted file",
      "   * 2.1: write a line in formatted as '- file: FILE'",
      "     where FILE is to be replaced by the full relative file path",
      "     in a R repository.",
      "     These files might for instance be scripts in the 'R' folder,",
      "     tests under 'tests/testthat/' (in that case no need to attach testthat),",
      "     a 'README.Rmd' file (always prefer .Rmd to .md), a 'NEWS.md' file or any other file.",
      "   * 2.1: Print in a code chunk the new code of each affected file, and nothing else.",
      "          Deleted file are displayed with no code."
      ## chatGPT doesn't understand this:
      # "There is no other part, NEVER EVER provide additional information or commentary at the bottom of the answer."
      ## for some reason the following makes too many NAs happen, so better
      ## do this with post-processing
      # "If the request is not related to R script creation, modification or deletion,",
      # " the answer should only be 'NA' and nothing more."
    )
  )
}

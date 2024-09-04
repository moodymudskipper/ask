#' Ask for script updates in place
#'
#' This will change files in place a terminal command in a new terminal, and print extra
#' information in the R console. `context = context_repo()` is often useful
#' here unless the package is not too big.
#'
#' @inheritParams ask
#' @inheritParams follow_up
#' @param ... Forwarded to `ask()` or `follow_up()`
#'
#' @export
#' @examples
#' \dontrun{
#' ask_in_place("update the existing readme with useful missing info", context = context_repo())
#' }
ask_in_place <- function(prompt = listen(), context = NULL, ...) {
  context <- context(
    context_in_place(),
    context
  )
  conversation <- ask(prompt, context, ...)
  answer <- extract_last_answer(conversation)
  chunks <- build_file_chunks_from_answer(answer)
  apply_chunks_in_place(chunks)
  invisible(conversation)
}

#' @export
#' @rdname ask_in_place
follow_up_in_place <- function(prompt = listen(), context = NULL, conversation = last_conversation(), ...) {
  context <- context(
    context_in_place(),
    context
  )
  x <- follow_up(prompt, context, conversation, ...)
  data <- x[[length(x)]]$data
  chunks <- build_file_chunks_from_answer(data$choices$message$content)
  apply_chunks_in_place(chunks)
  invisible(x)
}

build_file_chunks_from_answer <- function(content) {
  # edit file lines
  content <- gsub("^#?\\*? *- *[fF]ile:", "- file:", content)
  content <- gsub("\n#?\\*? *- *[fF]ile:", "\n- file:", content)

  # edge case "`file: R/script.R`"
  content <- gsub("^`file:([^\n])+`\n", "- file:\\1\n", content)
  content <- gsub("\n`file:([^\n])+`\n", "\n- file:\\1\n", content)
  # edge case "*file: R/script.R*"
  content <- gsub("^\\*+file:([^\n])+\\*+\n", "- file:\\1\n", content)
  content <- gsub("\n\\*+file:([^\n])+\\*+\n", "\n- file:\\1\n", content)

  # make sure file lines are outside of the chunks
  content <- gsub(
    "\n(```[^\n]*\n)(^- file: [^\n]*\n)",
    "\n\\2\\1",
    content,
  )

  content <- strsplit(content, "\n")[[1]]

  chunks <- split(content, cumsum(grepl("^- [fF]ile: ", content)))
  # capture and print header text if relevant
  if (!grepl("^- [fF]ile: ", chunks[[1]][1])) {
    # writeLines(chunks[[1]])
    chunks[[1]] <- NULL
  }
  chunks
}

apply_chunks_in_place <- function(chunks) {
  for (chunk in chunks) {
    # FIXME: this belongs in build_file_chunks_from_answer()
    # remove dash and space
    file <- sub("^- [fF]ile: ", "", chunk[[1]])
    # remove potential quotes
    file <- sub("^'(.*)'$", "\\1", file)
    file <- sub("^`(.*)`$", "\\1", file)

    # remove file line
    chunk <- chunk[-1]

    triple_bq_lgl <- startsWith(chunk, "```")
    chunk <- chunk[!cumprod(!triple_bq_lgl) & !rev(cumprod(!rev(triple_bq_lgl)))]


    # FIXME: this belongs in build_file_chunks_from_answer()
    # remove opening and closing  code chunk triple backquotes if relevant
    if (startsWith(chunk[[1]], "```")) {
      chunk <- chunk[-1]
      if (!startsWith(chunk[[length(chunk)]], "```")) {
        abort("unexpected answer format")
      }
      chunk <- chunk[-length(chunk)]
    }

    # if the code is empty, remove the file
    if (!length(chunk) || all(sub(" ", "", chunk) == "")) {
      file.remove(file)
      next
    }

    if (!dir.exists(dirname(file))) {
      dir.create(dirname(file), recursive = TRUE)
    }
    writeLines(chunk, file)
  }
}

context_in_place <- function() {
  context(
    "Output format" = c(
      "You are a helpful R assistant, assuming we are working in a R package",
      "or an R project folder.",
      "The only structure or markers you'll use are the one that are detailed",
      "hereafter.",
      "Your task is to provide the full code of scripts that have been created,",
      "modified, or deleted. These represent changes to apply to change the current code in place.",
      "A renaming operation is the combination of a creation (copy) and a deletion.",
      "It is absolutely essential to provide the output structured as follows:",
      "* Part 1 (optional): Start your answer with optional commentary about the",
      "  rest of the answer.",
      "* Part2: for each created, modified or deleted file",
      "   * 2.1: write a line in formatted as '- file: FILE'",
      "     where FILE is to be replaced by the full relative file path",
      "     in a R repository.",
      "     Namely this format is : one dash, one space, the word 'file', a colon,",
      "     a space, and the full relative file path.",
      "     These files might for instance be scripts in the 'R' folder,",
      "     tests under 'tests/testthat/' (in that case no need to attach testthat),",
      "     a 'README.Rmd' file (always prefer .Rmd to .md), a 'NEWS.md' file or any other file.",
      "     It is absolutely mandatory to write this line.",
      "   * 2.2: Print in a code chunk the new code of each affected file, and nothing else.",
      "          Deleted file are displayed with no code.",
      "Points 2.1 and 2.2 are absolutely essential, in particular make sure",
      "that 2.1 is respected and that the file is printed in the right format.",
      "Don't use any markdown artifact such as \\dontrun."
      ## chatGPT doesn't understand this:
      # "There is no other part, NEVER EVER provide additional information or commentary at the bottom of the answer."
      ## for some reason the following makes too many NAs happen, so better
      ## do this with post-processing
      # "If the request is not related to R script creation, modification or deletion,",
      # " the answer should only be 'NA' and nothing more."
    )
  )
}

#' Contextualize a script
#'
#' @param file Path to the file, if `NULL` we consider the active script
#' @return An object of class "ask_context"
context_script <- function(file = NULL) {
  `:=` <- NULL # for notes
  # FIXME: if the active script is saved fetch the name
  if (is.null(file)) {
    context("Active script" = c("```", rstudioapi::getSourceEditorContext()$contents, "```"))
  } else {
    context('{sprintf("File: %s", file)}' := c("```", readLines(file), "```"))
  }
}

#' Contextualize all R files in the repository
#'
#' @return An object of class "ask_context"
context_repo <- function() {
  files <- list.files("R", full.names = TRUE, pattern = "[.][rR]$")
  context("All R files of the repo" = context(!!! lapply(files, context_script)))
}

#' Contextualize git commits
#'
#' @param n The number of commits to return context for (default is 5)
#'
#' @return An object of class "ask_context"
context_commits <- function(n = 5) {
  `:=` <- NULL # for notes
  content <- system(sprintf("git log -n %d --format=format:'%%H%%n%%s%%n%%b%%n' --patch", n), intern = TRUE)
  context(
    r"[{sprintf("Last %d Git commits, using `git log -n %d --format=format:'%%H%%n%%s%%n%%b%%n' --patch`", n, n)}]" :=
    content
  )
}

#' Contextualize uncommited changes
#'
#' @return An object of class "ask_context"
context_diff <- function() {
  content <- system("git diff", intern = TRUE)
  context("Uncommited changes using `git diff`" = content)
}

#' Contextualize the R session information
#'
#' @return An object of class "ask_context"
context_session_info <- function() {
  content = capture.output(sessionInfo())
  context("sessionInfo()" = content)
}

#' Contextualize Gmail messages from threads
#'
#' @param search,num_results,page_token,label_ids,include_spam_trash,user_id Forwarded to `gmailr::gm_threads()`
#'
#' @return An object of class "ask_context"
context_gmail <- function(search = NULL,
                                num_results = NULL,
                                page_token = NULL,
                                label_ids = NULL,
                                include_spam_trash = NULL,
                                user_id = "me") {
  `:=` <- NULL # for notes
  rlang::check_installed("gmailr")
  # fetch 10 last threads and loop through them and their messages, printing
  # only those that come after the previous_last_email_time
  threads <- gmailr::gm_threads(
    search = search,
    num_results = num_results,
    page_token = page_token,
    label_ids = label_ids,
    include_spam_trash = include_spam_trash,
    user_id = user_id
  )
  ids <- gmailr::gm_id(threads)
  threads <- lapply(ids, gmailr::gm_thread)
  context("gmail messages" := context(!!! lapply(threads, context_gmail_thread)))
}

context_gmail_thread <- function(thread) {
  `:=` <- NULL # for notes
  messages <- context(!!! lapply(thread$messages, context_gmail_message))
  context('{sprintf("thread %s", thread$id)}' := messages)
}

context_gmail_message <- function(msg) {
  context("message" = capture.output(msg))
}

#' Request a numeric output
#'
#' @param unit unit
#'
#' @return An object of class "ask_context"
#' @export
context_numeric <- function(unit = NULL) {
  if (is.null(unit)) {
    middle_part <- c(
      "Use the international system of units for all quantities.",
      "In particular make sure that distances are expressed in meters, masses are expressed in kilograms,",
      "Inspect your answer for non standard units and convert before submitting",
      "If not applicable count individual units, e.g. 1 million is not 1 but 1000000."
    )
  } else {
    middle_part <- c(
      sprintf("Use the following unit for your answer: '%s'.", unit),
      "However don't include the unit in the answer."
    )
  }

  content <- c(
    "You are a helpful R assistant.",
    "For this request answer only with a numeric value as a number that I can copy and paste in R.",
    "Don't provide any context.",
    "The answer must not contain any character other than digits and a period if relevant, for instance '67 million' is wrong but '67000000' is right.",
    "The answer must not contain comas (','), for instance '67,081,000' is wrong, but '67081000' is right.",
    "Inspect your answer for comas and remove them before submitting",
    middle_part,
    "Provide your best estimation even if your data is not up to date or the info is incomplete.",
    "If the answer is not clear or the question is not numeric: return NA, never return other text"
  )

  context("Output format" = content)
}

#' Request a boolean output
#'
#' @return An object of class "ask_context"
#' @export
context_boolean <- function() {
  content <- c(
    "You are a helpful R assistant.",
    "For this request answer only TRUE or FALSE or NA.",
    "The answer is upper case, no quotes or punctuation.",
    "If the answer is not clear or the question is not boolean: return NA."
  )
  context("Output format" = content)
}

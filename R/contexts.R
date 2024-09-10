#' Contextualize a script
#'
#' @param file Path to the file, if `NULL` we consider the active script
#' @return An object of class "ask_context"
#' @export
context_script <- function(file = NULL) {
  if (is.null(file)) {
    path <- rstudioapi::getSourceEditorContext()$path
    if (path == "") {
      context("Active script" = c("```", rstudioapi::getSourceEditorContext()$contents, "```"))
    } else {
      path <- fs::path_rel(path)
      context("Active script ({path})" := c("```", rstudioapi::getSourceEditorContext()$contents, "```"))
    }
  } else {
    # so missing files don't break context features
    if (!file.exists(file)) return(NULL)
    context('File: {file}' := c("```", readLines(file), "```"))
  }
}

#' Contextualize all R files in the repository
#'
#' @return An object of class "ask_context"
#' @export
context_repo <- function() {
  files <- list.files("R", full.names = TRUE, pattern = "[.][rR]$")
  context(
    "Special files" = context(
      context_script("README.Rmd"),
      context_script("NAMESPACE"),
      context_script("DESCRIPTION"),
      context_script("LICENSE"),
      context_script("LICENSE.md")
    ),
    "R folder content" = context(!!! lapply(files, context_script))
  )
}

#' Contextualize git commits
#'
#' @param n The number of commits to return context for (default is 5)
#'
#' @return An object of class "ask_context"
#' @export
context_commits <- function(n = 5) {
  content <- system(sprintf("git log -n %d --format=format:'%%H%%n%%s%%n%%b%%n' --patch", n), intern = TRUE)
  context(
    r"[{sprintf("Last %d Git commits, using `git log -n %d --format=format:'%%H%%n%%s%%n%%b%%n' --patch`", n, n)}]" :=
    content
  )
}

#' Contextualize uncommited changes
#'
#' @return An object of class "ask_context"
#' @export
context_diff <- function() {
  content <- system("git diff", intern = TRUE)
  context("Uncommited changes using `git diff`" = content)
}

#' Contextualize the R session information
#'
#' @return An object of class "ask_context"
#' @export
context_session_info <- function() {
  content = capture.output(sessionInfo())
  context("sessionInfo()" = content)
}

#' Contextualize Gmail messages from threads
#'
#' @param search,num_results,page_token,label_ids,include_spam_trash,user_id Forwarded to `gmailr::gm_threads()`
#'
#' @return An object of class "ask_context"
#' @export
context_gmail <- function(search = NULL,
                                num_results = 5,
                                page_token = NULL,
                                label_ids = NULL,
                                include_spam_trash = NULL,
                                user_id = "me") {
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

context_tibble <- function() {
  content <- c(
    "You are a helpful R assistant.",
    "For this request answer only with a call to tibble::tibble().",
    "Respect the column names provided by the user if relevant, and respect their case.",
    "If no column name is provided, provide some reasonable ones in snake_case."
  )
  context("Output format" = content)
}

#' Contextualize an url
#'
#' @return An object of class "ask_context"
#' @param url An url
#' @export
context_url <- function(url) {
  tmp <- tempfile(fileext = ".html")
  download.file(url, tmp)
  context('URL: {url}' := c("```", readLines(tmp, warn = FALSE), "```"))
}


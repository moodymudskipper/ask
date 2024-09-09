#' Ask to open one or several files
#'
#' @inheritParams ask
#' @return A conversation object
#' @export
#' @examples
#' \dontrun{
#' ask_open("the file(s) touched by the last commit", context_commits())
#' ask_open("the script were roxygen2 imports are defined", context_repo())
#' }
ask_open <- function(
    prompt,
    context = NULL,
    model = getOption("ask.model", "gpt-4o"),
    seed = NULL,
    temperature = 1,
    top_p = 1,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")
) {

  context <- context(context_open(), context)

  conversation <- ask(
    prompt = prompt,
    context = context,
    model = model,
    seed = seed,
    temperature = temperature,
    top_p = top_p,
    cache = cache,
    api_key = api_key
  )

  # Extract file paths from the conversation
  file_paths <- extract_last_answer(conversation)
  file_paths <- unlist(strsplit(file_paths, "\n"))

  # Open each file in the RStudio IDE
  if (!is.null(file_paths) && !any(file_paths == "NA")) {
    lapply(file_paths, rstudioapi::navigateToFile)
  }

  invisible(conversation)
}

context_open <- function() {
  content <- c(
    "You are a helpful R assistant.",
    "Your task is to provide a list of files that match the given description.",
    "The list should only contain the relative paths of the files, separated by new lines.",
    "The output should not include any other commentary or explanation, just the file paths.",
    "If no files are relevant, return 'NA'."
  )
  context("Output format" = content)
}

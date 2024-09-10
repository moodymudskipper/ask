#' ask for anything or any change
#'
#' `ask_smart()` guesses which `ask*()` function and which `context*()`
#' function is appropriate, so you don't need to think too much or know the
#' package in depth.
#'
#' It works by calling a llm twice, first to figure out the proper functions
#' to use, then through these functions. As a consequence it is slower and spends
#' more token (with an increased chance of reaching the limit of maximum tokens
#' per minute)
#'
#' @inheritParams ask
#' @export
ask_smart <- function(
    prompt = listen(),
    context = NULL,
    model = getOption("ask.model", "gpt-4o"),
    seed = NULL,
    temperature = 1,
    top_p = 1,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")
) {
  context <- context(context, context_smart())
  conversation <- ask(
    prompt,
    context,
    model = getOption("ask.model", "gpt-4o"),
    seed = seed,
    temperature = temperature,
    top_p = top_p,
    cache = cache,
    api_key = api_key
  )
  content <- extract_last_answer(conversation)
  triple_bq_lgl <- startsWith(content, "```")
  if (any(triple_bq_lgl)) {
    content <- content[!cumprod(!triple_bq_lgl) & !rev(cumprod(!rev(triple_bq_lgl)))]
  }
  content <- strsplit(content, "\n")[[1]]
  if (startsWith(content[[1]], "```")) {
    if (length(content) == 1 && endsWith(content[[1]], "```")) {
      content <- sub("^```(.*)```$", "\\1", content)
    } else {
      content <- content[-1]
      if (!startsWith(content[[length(content)]], "```")) {
        abort("unexpected answer format")
      }
      content <- content[-length(content)]
    }
  }
  content <- paste(content, collapse = "\n")
  content <- sub("^`(.*)`$", "\\1", content)
  if (!grepl("^ask.*\\(.*\\)$", content)) {
    msg <- "oops! It seems `ask_smart()` wasn't smart enough! It couldnt create a proper call to answer your request."
    info1 <- "The most explicit your input, the most likely you are to get a proper output."
    info2 <- "Sometimes you might need a second or third try to get it right."
    abort(c(msg, i = info1, i = info2))
  }
  mc <- match.call()
  args <- as.list(mc[-1])
  args$prompt <- NULL
  args$contect <- NULL
  call <- parse(text = content)[[1]]
  call[[1]] <- call("::", as.symbol("ask"), call[[1]])
  if (length(call) == 3) call[[3]] <- call("::", as.symbol("ask"), call[[3]])
  call <- as.call(c(as.list(call), args))
  content <- rlang::expr_deparse(call)
  rstudioapi::sendToConsole(content)
}

context_smart <- function() {
  content <- c(
    "You are a helpful R assistant, your user is working in a project or a package.",
    "Your role is to translate a request into a call to functions from the {ask} package,",
    "whose source is reproduced at the bottom of this message.",
    "More specifically we expect from you a call to the relevant `ask()` or `ask_*()` function",
    "using the minimal necessary `context_()` function, so that running it will answer the request adequately.",
    "For instance context_script() is used if we need the active's script code (or if the user mention uses termes like 'this script'),",
    "and context_repo() is used if we need all the code.",
    "Avoid using `context_repo()` if it's not really needed, for instance if no context is needed at all",
    "or if context_script() is enough.",
    "The answer should come in the form `<ask_function>(<user_request>, <context_function>())`",
    "where :",
    "* <ask_function> is : ask, ask_in_place, ask_terminal, ask_tibble... or any other ask_* function of the package",
    "* <user_request> is : the untouched user request",
    "* <context_function> is : a context function such as context_script, context_repo, context_commits... or any other exported context_* function from the package",
    "<context_function> can be omitted if no context is necessary.",
    "Provide no other commentary, for instance if the question is 'what is my last commit about?'",
    "the answer should be `ask_terminal(\"what is my last commit about?\", context_commits(n = 1))`"
  )
  context("Output format" = content, context_source())
}

context_source <- function() {
  source_dir <- system.file("source", package = "ask")
  r_files <- list.files(file.path(source_dir, "R"), full.names = TRUE)
  context(
    "Special files" = context(
      context_script(file.path(source_dir, "README.Rmd")),
      context_script(file.path(source_dir, "NAMESPACE")),
      context_script(file.path(source_dir, "DESCRIPTION")),
    ),
    "R folder content" = context(!!! lapply(r_files, context_script))
  )
}

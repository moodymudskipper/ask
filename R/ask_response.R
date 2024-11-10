# low level wrappers to httr::POST, return a json response
ask_response_chatgpt <- function(
    messages,
    model = getOption("ask.model", "gpt-4o"),
    tools = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY"),
    api_args = NULL) {
  if (!curl::has_internet()) {
    msg <- "gpt models require an internet connection"
    info1 <- "You are not connected"
    abort(c(msg, x = info1))
  }

  api_url <- "https://api.openai.com/v1/chat/completions"
  headers <- httr::add_headers(
    `Content-Type` = "application/json",
    Authorization = paste("Bearer", api_key)
  )
  body <- list(
    model = model,
    messages = messages,
    tools = tools
  )
  body <- c(body, api_args)
  if (is.null(tools)) body$tools <- NULL

  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )
  response
}

ask_response_ollama <- function(
    prompt = listen(),
    context = NULL,
    model = "llama3.1",
    llama_context = NULL,
    format = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL) {
  api_url <- "http://localhost:11434/api/generate"
  headers <- httr::add_headers(
    `Content-Type` = "application/json"
  )
  body <- list(
    model = model,  # Use the correct model name
    prompt = prompt,
    stream = FALSE,  # Set to false to get the complete response at once
    options = api_args
  )
  if (!is.null(format)) body$format <- format
  body$system <- context
  body$context <- llama_context

  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )
  response
}


# anthropic models :
# https://docs.anthropic.com/en/docs/about-claude/models

ask_response_anthropic <- function(
    messages,
    system,
    model = getOption("ask.model", "claude-3-5-sonnet-latest"),
    ...,
    tools = NULL,
    api_key = Sys.getenv("ANTHROPIC_API_KEY"),
    `anthropic-version` = "2023-06-01",
    `anthropic-beta` = "computer-use-2024-10-22"
    ) {
  if (!curl::has_internet()) {
    msg <- "anthropic models require an internet connection"
    info1 <- "You are not connected"
    abort(c(msg, x = info1))
  }
  api_url <- "https://api.anthropic.com/v1/messages"
  headers <- httr::add_headers(
    "x-api-key" = api_key,
    "content-type" = "application/json",
    "anthropic-version" = `anthropic-version`, # "2023-06-01",
    "anthropic-beta" = `anthropic-beta` # "computer-use-2024-10-22"
  )

  # Payload setup
  # FIXME: transmit parameters from `...` or `api_args` once fixed
  body <- list(
    model = "claude-3-5-sonnet-20241022",
    max_tokens = 1024,
    messages = messages
  )

  # defined likw this so we don't add elements when NULL
  body$tools <- tools
  body$system <- system

  # API request
  response <- httr::POST(
    api_url,
    headers,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json"
  )

  response
}

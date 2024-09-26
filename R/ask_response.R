# low level wrappers to httr::POST, return a json response
ask_response_chatgpt <- function(
    messages,
    model = getOption("ask.model", "gpt-4o"),
    seed = NULL,
    temperature = 1,
    top_p = 1,
    n = 1,
    tools = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  api_url <- "https://api.openai.com/v1/chat/completions"
  headers <- httr::add_headers(
    `Content-Type` = "application/json",
    Authorization = paste("Bearer", api_key)
  )
  body <- list(
    model = model,
    messages = messages,
    temperature = temperature,
    top_p = top_p,
    tools = tools,
    n = n
  )
  if (is.null(tools)) body$tools <- NULL
  body$seed <- seed
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
    seed = NULL,
    temperature = 1,
    top_p = 1,
    format = NULL,
    cache = getOption("ask.cache")) {
  api_url <- "http://localhost:11434/api/generate"
  headers <- httr::add_headers(
    `Content-Type` = "application/json"
  )
  # Define the request body with the options for temperature and top_p
  body <- list(
    model = model,  # Use the correct model name
    prompt = prompt,
    stream = FALSE,  # Set to false to get the complete response at once
    options =
      list(
        temperature = temperature,  # Set temperature to 0.7
        top_p = top_p         # Set top_p to 0.9
      )
  )
  if (!is.null(format)) body$format <- format

  body$options$seed <- seed
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

#' Ask chat gpt anything
#'
#' @param content Your request: a string, or a vector that will be concatenated to a string with
#'   line breaks as separators.
#' @param model The model to choose, see https://platform.openai.com/docs/models
#'   or call `all_models()`
#' @param temperature Choose higher `temperature` for more diverse and
#'   unexpected results, and lower `temperature` for more controlled and
#'   consistent text.
#' @param top_p Choose high `top_p` for creative applications like storytelling,
#'   poetry, or brainstorming. Choose low `top_p` for applications requiring
#'   precision and coherence, such as technical writing, factual content, or summarization.
#' @param seed The seed used by the model, makes things more reproducible, but
#'   not completely, due to the nature of LLMs. See `local_seed` to work around
#'   that.
#' @param local_seed If used, the result of a query is memoised so it will be
#'   constant in the session, and quick to fetch. This ensures true reproducibility. Can be
#'   used without using `seed`
#' @param api_key API key
#'
#' @return a converstaion object
#' @export
ask <- function(
    content = listen(),
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = 1,
    top_p = 1,
    local_seed = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  content <- paste(content, collapse = "\n")
  ask_impl(
    messages = list(list(role = "user", content = content)),
    model = model,
    seed = seed,
    temperature = temperature,
    top_p = top_p,
    local_seed = local_seed,
    api_key = api_key
  )
}

# wraps ask_response() to :
# * handle memoisation
# * build a conversation object
# * cache it to globals$last_conversation and return it
ask_impl <- function(
    messages,
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = 1,
    top_p = 1,
    n = 1,
    local_seed = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY"),
    memoised = FALSE) {
  if (!is.null(local_seed) && !memoised) {
    return(
      ask_impl_memoised(
        messages = messages,
        model = model,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        n = n,
        local_seed = local_seed,
        api_key = api_key,
        memoised = TRUE
      )
    )
  }
  response <- ask_response(
    messages,
    model,
    seed,
    temperature,
    top_p,
    n,
    api_key
  )
  conversation <- structure(
    list(
      list(
        prompt = messages[[length(messages)]]$content,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        response = response
      )
    ),
    class = c("conversation")
  )
  globals$last_conversation <- conversation
  conversation
}

# low level, feed raw inputs to API call and get "response" object
ask_response <- function(
    messages,
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = 1,
    top_p = 1,
    n = 1,
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
    n = n
  )
  body$seed <- seed
  response <- httr::POST(
    url = api_url,
    body = jsonlite::toJSON(body, auto_unbox = TRUE),
    encode = "json",
    config = headers
  )
  response
}

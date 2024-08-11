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
#'   not completely, due to the nature of LLMs. See `cache` to work around
#'   that.
#' @param cache A path where to cache the outputs, or "ram" to store them
#' in RAM. useful to spare tokens and to have reproducible code.
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
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  content <- paste(content, collapse = "\n")
  ask_impl(
    messages = list(list(role = "user", content = content)),
    model = model,
    seed = seed,
    temperature = temperature,
    top_p = top_p,
    cache = cache,
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
    cache = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY"),
    forget = FALSE) {
  if (!is.null(cache)) {
    if (cache %in% names(globals$memoised)) {
      memoised_fun <- globals$memoised[[cache]]
      if (forget) {
        memoise::drop_cache(memoised_fun)(
          messages = messages,
          model = model,
          seed = seed,
          temperature = temperature,
          top_p = top_p,
          n = n,
          api_key = api_key
        )
      }
    } else {
      if (cache == "ram") {
        memoised_fun <- memoise::memoise(ask_impl)
      } else {
        memoised_fun <- memoise::memoise(
          ask_impl,
          cache = memoise::cache_filesystem(cache)
        )
      }
      globals$memoised[[cache]] <- memoised_fun
    }
    return(
      memoised_fun(
        messages = messages,
        model = model,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        n = n,
        api_key = api_key
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

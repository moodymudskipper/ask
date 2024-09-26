# Engine of ask(), follow_up(), again() for internal use
# * preprocess the prompt and context into a string
# * handle memoisation
# * Wraps the ask_response_* functions and additionally :
# * Handle follow up of previous conversation
# * Build a conversation object, cache it to globals$last_conversation and return it
ask_impl <- function(
    prompt,
    context = NULL,
    conversation = NULL,
    model = "gpt-4o-2024-08-06",
    seed = NULL,
    temperature = 1,
    top_p = 1,
    n = 1,
    cache = NULL,
    tools = NULL,
    api_key = Sys.getenv("OPENAI_API_KEY")) {
  if (rlang::is_na(seed)) seed <- NULL
  # process prompt and context -------------------------------------------------
  forget <- FALSE
  if (is.null(prompt)) {
    forget <- TRUE
    if (is.null(conversation)) {
      abort("`prompt` and `conversation` can't be `NULL` at the same time")
    }
    conv_len <- nrow(conversation)
    prompt <- conversation$prompt[[conv_len]]
    conversation <- conversation[-conv_len,]
    if (!nrow(conversation)) conversation <- NULL
  }
  prompt <- paste(prompt, collapse = "\n")
  if (!is.null(context) && !is.character(context)) {
    context <- c(
      "You are a useful R programming assistant provided the following context.",
      flatten_context(context)
    )
    context <- paste(context, collapse = "\n")
  }

  # return cached result if relevant -------------------------------------------
  if (!is.null(cache)) {
    # FIXME: we might as well keep the same param order
    cached <- withr::with_envvar(
      # we use this trick to make sure we don't memoise the api key
      c(OPENAI_API_KEY = api_key),
      return_cached(
        cache,
        forget,
        prompt,
        context,
        conversation,
        model,
        seed,
        temperature,
        top_p,
        n)
    )
    globals$last_conversation <- cached
    return(cached)
  }

  # response -------------------------------------------------------------------
  # FIXME: higher level wrappers with same inputs?
  model_family <- model_family(model)
  if (model_family == "gpt") {
    if (!curl::has_internet()) {
      msg <- "gpt models require an internet connection"
      info1 <- "You are not connected"
      abort(c(msg, x = info1))
    }
    if (!is.null(context)) {
      messages = list(
        list(role = "system", content = context),
        list(role = "user", content = prompt)
      )
    } else {
      messages = list(list(role = "user", content = prompt))
    }
    if (!is.null(conversation)) {
      old_messages <- lapply(
        split(conversation, seq(nrow(conversation))),
        function(x) {
          list(
            list(
              role = "user",
              content = x$prompt
            ),
            list(
              role = "assistant",
              content = x$data$choices$message$content
            )
          )
        })
      old_messages <- unlist(unname(old_messages), recursive = FALSE)
      messages <- c(old_messages, messages)
    }

    response <- ask_response_chatgpt(
      messages = messages,
      model = model,
      seed = seed,
      temperature = temperature,
      top_p = top_p,
      tools = tools,
      api_key = api_key
    )
  } else if (model_family == "llama") {
    if (!is.null(conversation)) {
      llama_context <- conversation$data$context[[nrow(conversation)]]
    } else {
      llama_context <- NULL
    }

    response <- ask_response_ollama(
      prompt = prompt,
      context = context,
      llama_context = llama_context,
      model = model,
      seed = seed,
      temperature = temperature,
      top_p = top_p,
      cache = cache
    )
  }

  # conversation ---------------------------------------------------------------
  conversation <-
    append_conversation(conversation, prompt, seed, temperature, top_p, response)
  conversation
}

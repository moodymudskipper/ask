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
    model = getOption("ask.model", "gpt-4o"),
    image = NULL,
    cache = NULL,
    tools = NULL,
    api_args = NULL,
    api_key = NULL) {
  api_key <- api_key %||% default_api_key(model)
  image64 <- NULL
  # process prompt and context -------------------------------------------------
  processed <- process_prompt_and_conversation(prompt, conversation)
  prompt <- processed$prompt
  conversation <- processed$conversation
  context <- process_context(context)

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
        image,
        api_args = api_args)
    )
    globals$last_conversation <- cached
    return(cached)
  }

  # response -------------------------------------------------------------------
  model_family <- model_family(model)
  if (model_family == "gpt") {
    messages <- build_openai_messages(prompt, context, image, conversation)
    response <- ask_response_chatgpt(
      messages = messages,
      model = model,
      tools = tools,
      api_args = api_args,
      api_key = api_key
    )
  } else if (model_family == "llama") {
    llama_context <- extract_llama_conversation_history(conversation)
    response <- ask_response_ollama(
      prompt = prompt,
      context = context,
      llama_context = llama_context,
      model = model,
      cache = cache,
      api_args = api_args
    )
  } else if (model_family == "anthropic") {
    messages <- build_anthropic_messages(prompt, context, image, conversation)
    response <- ask_response_anthropic(
      messages = messages,
      system = context,
      model = model,
      tools = tools,
      api_args = api_args,
      api_key = api_key
    )
  }

  # conversation ---------------------------------------------------------------
  conversation <-
    append_conversation(
      conversation,
      prompt,
      response,
      image = image,
      api_args = api_args
    )
  conversation
}

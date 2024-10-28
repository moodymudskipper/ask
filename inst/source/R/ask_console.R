#' Ask in the Console
#'
#' These are simple wrappers around `ask()` and `follow_up()`, that print to the
#' console rather than the viewer (Something that can also be achieved with
#' `print(ask(...), venue = "console")`). Only the last answer is printed but the
#' output object is still the entire conversation.
#'
#' @inheritParams ask
#' @inheritParams follow_up
#' @param follow_up Whether to automatically follow up in the console, press
#' Esc or Ctrl+C to exit the chat.
#' @return The result from the `ask()` function.
#' @export
ask_console <- function(
    prompt = listen(),
    context = NULL,
    model = getOption("ask.model", "gpt-4o"),
    seed = NULL,
    temperature = 1,
    top_p = 1,
    image = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY"),
    follow_up = FALSE
) {
  context_lazy <- substitute(context)
    conversation <- ask(
        prompt = prompt,
        context = eval.parent(context_lazy),
        model = model,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        image = image,
        cache = cache,
        api_key = api_key
    )
    print(conversation, venue = "console")
    if (follow_up) {
      repeat {
        prompt <- readline(">>> ")
        conversation <- follow_up(
          prompt,
          context = eval.parent(context_lazy),
          conversation = conversation,
          model = model,
          seed = seed,
          temperature = temperature,
          top_p = top_p,
          image = image,
          cache = cache,
          api_key = api_key
        )
        print(conversation, venue = "console")
      }
    }
    invisible(conversation)
}

#' @export
#' @rdname ask_console
follow_up_console <- function(
    prompt = listen(),
    context = NULL,
    conversation = last_conversation(),
    model = NULL,
    seed = NULL,
    temperature = NULL,
    top_p = NULL,
    image = NULL,
    cache = getOption("ask.cache"),
    api_key = Sys.getenv("OPENAI_API_KEY")
) {
    conversation <- follow_up(
        prompt = prompt,
        context = context,
        conversation = conversation,
        model = model,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        image = image,
        cache = cache,
        api_key = api_key
    )
    print(conversation, venue = "console")
    invisible(conversation)
}


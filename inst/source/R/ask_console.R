#' Ask in the Console
#'
#' These are simple wrappers around `ask()` and `follow_up()`, that print to the
#' console rather than the viewer (Something that can also be achieved with
#' `print(ask(...), venue = "console")`). Only the last answer is printed but the
#' output object is still the entire conversation.
#'
#' @inheritParams ask
#' @inheritParams follow_up
#' @param follow_up Whether to automatically follow up in the console, this
#' triggers an interactive prompt that you can exit by pressing
#' Esc or Ctrl+C..
#' @return The result from the `ask()` function.
#' @export
ask_console <- function(
    prompt = listen(),
    context = NULL,
    model = getOption("ask.model", "gpt-4o"),
    image = NULL,
    cache = getOption("ask.cache"),
    api_args = NULL,
    api_key = NULL,
    follow_up = FALSE
) {
  context_lazy <- substitute(context)
    conversation <- ask(
        prompt = prompt,
        context = eval.parent(context_lazy),
        model = model,
        image = image,
        cache = cache,
        api_args = api_args,
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
          image = image,
          cache = cache,
          api_args = api_args,
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
    image = NULL,
    cache = getOption("ask.cache"),
    ap_args = NULL,
    api_key = NULL
) {
    conversation <- follow_up(
        prompt = prompt,
        context = context,
        conversation = conversation,
        model = model,
        image = image,
        cache = cache,
        api_args = api_args,
        api_key = api_key
    )
    print(conversation, venue = "console")
    invisible(conversation)
}


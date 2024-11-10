process_prompt_and_conversation <- function(prompt, conversation) {
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
  list(prompt = prompt, conversation = conversation)
}

process_context <- function(context) {
  if (!is.null(context) && !is.character(context)) {
    context <- c(
      "You are a useful R programming assistant provided the following context.",
      flatten_context(context)
    )
    context <- paste(context, collapse = "\n")
  }
  context
}

# messages is a list
# each message has a role (system, user, assistant) and content
# system is optional, its content is made from context
# user content is made from the prompts and images
# assistant content is made of outputs from the API
# A given API call only returns the latest assistant message, to provide history
# we need to rebuild the messages from the conversation object
build_openai_messages <- function(prompt, context, image, conversation) {
  image_content <- function(image) {
    if (is.null(image)) return(NULL)
    lapply(image, function(img) {
      img64 <- base64enc::base64encode(img)
      list(
        type = 'image_url',
        image_url = list(url = sprintf("data:image/png;base64,%s", img64))
      )
    })
  }

  # old messages
  if (!is.null(conversation)) {
    old_messages <- lapply(
      split(conversation, seq(nrow(conversation))),
      function(x) {
        list(
          list(role = "user", content = c(
            list(list(type = "text", text = x$prompt)),
            image_content(x$image[[1]])
          )),
          x$data[[1]]$choices[[1]]$message
        )
      })
    old_messages <- unlist(unname(old_messages), recursive = FALSE)
  } else {
    old_messages <- NULL
  }

  # new message
  new_message <- c(
    if (!is.null(context)) list(list(role = "system", content = context)),
    list(list(role = "user", content = c(
      list(list(type = "text", text = prompt)),
      image_content(image) # NULL (ignored) if not applicable
    )))
  )

  c(old_messages, new_message)
}

build_anthropic_messages <- function(prompt, context, image, conversation) {
  image_content <- function(image) {
    if (is.null(image)) return(NULL)
    lapply(image, function(img) {
      img64 <- base64enc::base64encode(img)
      list(
        type = 'image',
        source = list(
          type = "base64",
          media_type = "image/png",
          data = img64
        )
      )
    })
  }

  # old messages
  if (!is.null(conversation)) {
    old_messages <- lapply(
      split(conversation, seq(nrow(conversation))),
      function(x) {
        list(
          list(role = "user", content = c(
            list(list(type = "text", text = x$prompt)),
            image_content(x$image[[1]])
          )),
          x$data[[1]][c("role", "content")] # $choices[[1]]$message
        )
      })
    old_messages <- unlist(unname(old_messages), recursive = FALSE)
  } else {
    old_messages <- NULL
  }

  # new message
  new_message <- c(
    if (!is.null(context)) list(list(role = "system", content = context)),
    list(list(role = "user", content = c(
      list(list(type = "text", text = prompt)),
      image_content(image) # NULL (ignored) if not applicable
    )))
  )

  c(old_messages, new_message)
}

extract_llama_conversation_history <- function(conversation) {
  if (!is.null(conversation)) {
    llama_context <- conversation$data$context[[nrow(conversation)]]
  } else {
    llama_context <- NULL
  }
  llama_context
}

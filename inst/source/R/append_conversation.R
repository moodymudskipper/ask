# build conversation from response, cache it, return it
append_conversation <- function(conversation, prompt, seed, temperature, top_p, response) {
  new_conversation <- dplyr::bind_rows(
    conversation,
    dplyr::tibble(
      prompt = prompt,
      seed = seed %||% NA_integer_,
      temperature = temperature,
      top_p = top_p,
      data = response_data(response),
      response = list(response)
    )
  )

  new_conversation <- structure(
    new_conversation,
    class = c("conversation", "tbl_df", "tbl", "data.frame")
  )
  globals$last_conversation <- new_conversation
  # override if relevant
  if (!is.null(conversation)) {
    i <- which(vapply(globals$conversations, identical, logical(1), conversation))
    if (length(i)) {
      i <- i[length(i)] # we might have duplicate convos, in that case, follow up with the latest
      globals$conversations[[i]] <- new_conversation
    }
    return(new_conversation)
  }
  globals$conversations[[length(globals$conversations) + 1]] <- new_conversation
  new_conversation
}

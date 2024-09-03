# build conversation from response, cache it, return it
append_conversation <- function(conversation, prompt, seed, temperature, top_p, response) {
  conversation <- dplyr::bind_rows(
    conversation,
    tibble::tibble(
      prompt = prompt,
      seed = seed %||% NA_integer_,
      temperature = temperature,
      top_p = top_p,
      data = response_data(response),
      response = list(response)
    )
  )

  conversation <- structure(
    conversation,
    class = c("conversation", "tbl_df", "tbl", "data.frame")
  )
  globals$last_conversation <- conversation
  conversation
}

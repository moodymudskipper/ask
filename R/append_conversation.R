# build conversation from response, cache it, return it
append_conversation <- function(conversation, prompt, seed, temperature, top_p, response) {
  conversation <- structure(
    c(
      conversation,
      list(
        list(
          prompt = prompt,
          seed = seed,
          temperature = temperature,
          top_p = top_p,
          response = response
        )
      )
    ),
    class = c("conversation")
  )
  globals$last_conversation <- conversation
  conversation
}

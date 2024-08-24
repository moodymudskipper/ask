test_that("manual tests", {
  skip()
  # getNamespaceExports("ask")
  ask("Who is James Bond (one sentence)")
  last_conversation()
  again()

  ask_numeric("how many dwarves in Snow White?")
  ask_boolean("Are dwarves smaller?")
  ask_terminal("how much disk space do i have left?")

  ask_numeric("how many dwarves in Snow White?", model = "llama3.1")
  ask_boolean("Are dwarves smaller?", model = "llama3.1")
  ask_terminal("how much disk space do i have left?", model = "llama3.1")

  context_session_info()
  context_repo()
  context_script()
  context_gmail()
  context_diff()
  context_commits()
  context_smith <- context("Smith family" = "The Smith family is John, Wendy, and their 3 kids Boris, Judith and Michael.")
  context_johnson <- context("Johnson family" = "The Johnson family is Robert and his sister Brenda.")
  context_house <- context("House" = "The Smiths and the Johnsons live together in the big pink house")
  context_johnson
  full_context <- context(
    Families = context(context_smith, context_johnson),
    context_house
  )
  full_context
  ask("What are the names of the kids who live in the big pink house ?", context = full_context)
  ask("What are the names of the kids who live in the big pink house ?", context = full_context, model = "llama3.1")

  # getNamespaceExports("ask")
  ask("Who is James Bond (one sentence)", cache = "cache")

  # todo: not quite there, cache is noit
  again(cache = "cache")
})

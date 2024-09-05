test_that("manual tests", {
  skip()
  # getNamespaceExports("ask")
  ask("Who is James Bond (one sentence)")
  last_conversation()
  again()
  follow_up("who played him first? (just the name)")
  again()

  ask_numeric("how many dwarves in Snow White?")
  ask_boolean("Are dwarves smaller?")
  ask_terminal("how much disk space do i have left?")

  ask("Who is James Bond (one sentence)", model = "llama3.1")
  last_conversation()
  again()
  follow_up("who played him first? (just the name)")
  again()

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
  context_johnson <- context("Johnson family" = "The Johnson family is Robert and his sister Brenda, both retired.")
  context_house <- context("House" = "The Smiths and the Johnsons live together in the big pink house, except for Michael who moved out last year")
  context_johnson
  full_context <- context(
    Families = context(context_smith, context_johnson),
    context_house
  )
  full_context
  ask("What are the names of the kids who live in the big pink house ?", context = full_context)
  ask("What are the names of the kids who live in the big pink house ?", context = full_context, model = "llama3.1")

  ask_tibble(
    "Consider all the data for 2014 and provide a tibble with date, country, event, venue, and supporting bands. Use NA when you don't know or the data is unavailable.",
    context_url("https://www.snuffband.com/gig-history")
  )


  ask("Who is James Bond (one sentence)", cache = "cache")
  again(cache = "cache")
  ask("Who is James Bond (one sentence)", cache = "cache")

  getNamespaceExports("ask")
})

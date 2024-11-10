default_api_key <- function(model) {
  family <- model_family(model)
  switch(
    family,
    "llama" = NA,
    "gpt" = Sys.getenv("OPENAI_API_KEY"),
    "anthropic" = Sys.getenv("ANTHROPIC_API_KEY"),
  )
}

#' List OpenAI current models
#'
#' @inheritParams ask
#'
#' @return A tibble
#' @export
all_models <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  url <- "https://api.openai.com/v1/models"
  response <- httr::GET(url, httr::add_headers(Authorization = paste("Bearer", api_key)))
  models_json <- httr::content(response, "text", encoding = "UTF-8")
  models_df <- jsonlite::fromJSON(models_json)$data
  class(models_df$created) <- c("POSIXct", "POSIXt")
  models_df[order(models_df$created, decreasing = TRUE), ]
}

#' List all current models
#'
#' These are all current models from openai, anthropic and ollama. We don't
#' guarantee that they all work with ask though as we've tested a limited amount.
#' ChatGPT, Claude, and llama models seem to work ok, please open a ticket
#' to request further support.
#'
#' @inheritParams ask
#'
#' @return A tibble
#' @export
all_models <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  list(
    openai = all_openai_models(),
    anthropic = all_anthropic_models(),
    ollama = all_ollama_models()
  )
}

all_openai_models <- function(api_key = Sys.getenv("OPENAI_API_KEY")) {
  url <- "https://api.openai.com/v1/models"
  response <- httr::GET(url, httr::add_headers(Authorization = paste("Bearer", api_key)))
  models_json <- httr::content(response, "text", encoding = "UTF-8")
  models_df <- jsonlite::fromJSON(models_json)$data
  class(models_df$created) <- c("POSIXct", "POSIXt")
  models_df[order(models_df$created, decreasing = TRUE), ]
}

all_ollama_models <- function() {
  url <- "https://ollama.com/library"
  webpage <- xml2::read_html(url)
  name <- rvest::html_text(rvest::html_nodes(webpage, '.text-xl'), trim = TRUE)
  description <- rvest::html_text(rvest::html_nodes(webpage, '.text-md'), trim = TRUE)
  capabilities <- sapply(groups, function(x) {
    capabilities <- rvest::html_text(rvest::html_nodes(x, '.text-indigo-600'), trim = TRUE)
    if (!length(capabilities)) return(NA_character_)
    toString(unlist(capabilities))
  })
  sizes <- sapply(groups, function(x) {
    sizes <- rvest::html_text(rvest::html_nodes(x, '.text-blue-600'), trim = TRUE)
    if (!length(sizes)) return(NA_character_)
    toString(unlist(sizes))
  })
  pulls_tags_weeks <- strsplit(
    rvest::html_text(rvest::html_nodes(webpage, ".space-x-5"), trim = TRUE),
    #"\n              \n\\s+"
    "[ \U{A0}\n]+"
  )
  #pulls_tags_weeks <- lapply(pulls_tags_weeks, sub, pattern = "[ \U{A0}\n]+", replacement = " ")
  pulls_tags_weeks <- setNames(
    as.data.frame(do.call(rbind, pulls_tags_weeks)[,c(1,3,6)]),
    c("pulls", "tags", "weeks_since_update")
  )
  out <- cbind(name, description, capabilities, sizes, pulls_tags_weeks)
  tibble::as_tibble(out)
}

all_anthropic_models <- function() {
  url <- "https://docs.anthropic.com/en/docs/about-claude/models"
  webpage <- xml2::read_html(url)
  tables <- rvest::html_table(webpage)
  # sanity checks
  msg <- sprintf(
    "oops! The format or the doc at %s changed. Please consult the online doc and report the issue.",
    url
  )
  if (length(tables) != 4) abort(msg)
  valid_cols_in_1_and_2 <- identical(colnames(tables[[1]]), colnames(tables[[2]]))
  rows_to_test <-
    c("Description", "Strengths", "Multilingual", "Vision",
      "API model name", "Comparative latency", "Context window", "Max output",
      "Cost (Input / Output per MTok)", "Training data cut-off")
  valid_rows_in_3_and_4 <-
    all(rows_to_test %in% tables[[3]][[1]]) &&
    all(rows_to_test %in% tables[[4]][[1]])
  if (!valid_cols_in_1_and_2 || !valid_rows_in_3_and_4) abort(msg)

  t3 <- setNames(as.data.frame(t(tables[[3]][-1])), tables[[3]][[1]])
  t4 <- setNames(as.data.frame(t(tables[[4]][-1])), tables[[4]][[1]])
  t4$`Message Batches API` <- NA # in t3 but absent from t4
  t4$`API format` <- NULL # not informative and not in t3
  # t3$legacy <- FALSE
  # t4$legacy <- TRUE
  t12 <- rbind(tables[[1]], tables[[2]])
  t34 <- rbind(t3,t4)
  out <- merge(t12, t34, by.x = "Model", by.y = "row.names", all = TRUE)
  tibble::as_tibble(out[order(sub("^.*(20[0-9]{6}).*$", "\\1", out$`Anthropic API`), decreasing = TRUE),])
}

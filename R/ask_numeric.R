#' @export
#' @rdname ask_boolean
ask_numeric <- function(content = listen(), unit = NULL, ...) {
  if (is.null(unit)) {
    unit_prompt <- c(
      "Use the international system of units for all quantities.",
      "In particular make sure that distances are expressed in meters, masses are expressed in kilograms,",
      "Inspect your answer for non standard units and convert before submitting",
      "If not applicable count individual units, e.g. 1 million is not 1 but 1000000."
    )
  } else {
    unit_prompt <- c(
      sprintf("Use the following unit for your answer: '%s'.", unit),
      "However don't include the unit in the answer."
    )
  }

  prefix <- c(
    "For this request answer only with a numeric value as a number that I can copy and paste in R.",
    "Don't provide any context.",
    "The answer must not contain any character other than digits and a period if relevant, for instance '67 million' is wrong but '67000000' is right.",
    "The answer must not contain comas (','), for instance '67,081,000' is wrong, but '67081000' is right.",
    "Inspect your answer for comas and remove them before submitting",
    unit_prompt,
    "Provide your best estimation even if your data is not up to date or the info is incomplete.",
    "If the answer is not clear or the question is not numeric: return NA, never return other text",
    "Request:"
  )

  content <- prefix(content, prefix)
  response <- ask_response(list(list(role = "user", content = content)), ...)
  data <- response_data(response)
  out <- data$choices$message$content
  out <- gsub("[^0-9.]", "", out)
  suppressWarnings(as.numeric(out))
}

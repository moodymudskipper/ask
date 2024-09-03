#' Ask for a tibble
#'
#' @inheritParams ask
#' @param ... forwarded to `ask()`
#'
#' @export
ask_tibble <- function(prompt = listen(), context = NULL, ...) {
  context <- context(
    context_tibble(),
    context
  )
  conversation <- ask(prompt, context, ...)
  answer <- extract_last_answer(conversation)
  code <- strsplit(answer, "\n")[[1]]
  ind <- which(startsWith(code, "```"))
  if (!length(ind) %in% c(0,2)) abort("unexpected answer! try again!")
  if (length(ind)) {
    code <- code[(ind[[1]] + 1):(ind[[2]] - 1)]
  }
  if (startsWith(code[[1]], "`") && endsWith(code[[1]], "`")) {
    code <- substr(code, 2, nchar(code)-1)
  }
  # we use vec_c because LLMs sometime use trailing commas in c as in c(1,2,), which fails
  out <- eval(parse(text=code), envir = list(c = vctrs::vec_c))
  # convert character "NA" to proper NA
  out[out == "NA"] <- NA
  # convert dates encoded as character to proper dates
  out[] <- lapply(out, function(x) {
    if (is.character(x) &&  all(is.na(x) | grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", x))) {
      x <- as.Date(x)
    }
    x
  })
  out
}

#' Ask for a terminal command
#'
#' This will suggest a terminal command in a new terminal, and print extra
#' information in the R console.
#'
#' @inheritParams ask
#' @param ... Forwarded to `ask()`
#'
#' @export
#' @examples
#' \dontrun{
#' ask_terminal("who contributed to this project?")
#' ask_terminal("show the latest 5 changes in compact form")
#' }
ask_terminal <- function(content = listen(), context = NULL, ...) {
  context <- context(
    context_terminal(),
    context
  )
  x <- ask(content, context, ...)
  last_response <- x[[length(x)]]$response
  data <- response_data(last_response)
  out <- data$choices$message$content
  out <- strsplit(out, "\n+")[[1]]
  # despite instructions, it's common to have the code between "```"
  command <- out[!startsWith(out, "```") & !startsWith(out, "#") & !startsWith(out, "~~~") ][[1]]
  names(out) <- rlang::rep_along(out, "i")
  rlang::inform(out)
  id <- rstudioapi::terminalCreate()
  rstudioapi::terminalActivate(id)
  rstudioapi::terminalSend(id, command)
}

context_terminal <- function() {
  context(
    "Output format" = c(
      "You are a helpul assistant providing terminal commands such as git, sed or others.",
      "Start with a code chunk containing an uncommented terminal command.",
      "Strive to avoid interactive mode unless absolutely necessary.",
      "Strive to provide a single terminal command but do use several commands when necessary to avoid using '&&'.",
      "On subsequent lines, provide concise explanations."
    )
  )
}

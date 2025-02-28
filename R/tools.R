# we need a null placeholder for screenshot

#' Use tools to get structured output
#'
#' @param name A string
#' @param description A string
#' @param parameters An object defined with `json_object()`
#'
#' @export
#'
#' @examples
#' ask:::ask_impl("click at the center of the screen, my resolution is 1024 x 800", tools = list(tool_click(), tool_screenshot()))
#' tool_screenshot <- new_tool(
#'   "screenshot",
#'   "Instruct the user to take a screenshot",
#'  )
#' new_tool(
#'   "mac_terminal",
#'   "Provide the macOS terminal command that will fulfill the request. It can be used for instance to run an app or interrogate the system",
#'   command = "The terminal command",
#'   text = "A comment on why we use the given command"
#' )

#' context_computer <- "you'll iterate with the user using the tools at your disposal to request for screenshots, clicks etc, to browse the internet you can open a browser through the terminal, take screenshots and guide the user"
#' ask:::ask_impl("what app is my screen showing now ?", context_computer, tools = tools_openai)
#' response_data(last_conversation()$response[[1]]) |> constructive::construct()
#' ask:::ask_impl("Find a picture of a poodle online for me", context_computer, tools = tools_openai)
#' new_claude_tool(
#'   "mac_terminal",
#'   "Provide the macOS terminal command that will fulfill the request. It can be used for instance to run an app or interrogate the system",
#'   command = "The terminal command"
#' )
new_tool <- function(name, description, parameters = json_object()) {
  if (!is.null(parameters) && !identical(attr(parameters, "json_type"), "object")) {
    abort("`parameters` must be defined with `json_object()`")
  }
  out <- list(
    name = name,
    description = description
  )
  out$parameters <- parameters
  out
}

process_tools <- function(tools, model) {
  if (is.null(tools)) return(tools)
  lapply(tools, process_tool, model)
}

process_tool <- function(tool, model) {
  switch(
    model_family(model),
    "gpt" = process_tool_openai(tool),
    "anthropic" = process_tool_claude(tool),
    "llama" = NULL
  )
}

process_tool_openai <- function(tool) {
  #tool$strict <- TRUE
  list(
    type = "function",
    `function` = tool
  )
}

process_tool_claude <- function(tool) {
  names(tool)[[3]] <- "input_schema"
  tool
}

tool_screenshot <- function() {
  new_tool(
    "screenshot",
    "Instruct the user to take a screen shot to feed to the chat in the next message"
  )
}

tool_click <- function() {
  new_tool(
    "click",
    "Instruct the user to click at the provided coordinates",
    json_object(
      json_properties(
        x = json_number("The x coordinate where to click"),
        y = json_number("The y coordinate where to click")
      )
    )
  )
}

tools_computer <- function() {
  list(
    new_tool(
      "screenshot",
      "Instruct the user to take a screen shot to feed to the chat in the next message",
      json_object()
    ),
    new_tool(
      "click",
      "Instruct the user to click at the provided coordinates",
      json_object(
        json_properties(
          x = json_number("The x coordinate where to click"),
          y = json_number("The y coordinate where to click")
        ),
        required = c("x", "y"),
        additionalProperties = FALSE
      )
    ),
    new_tool(
      "mac_terminal",
      "Provide the macOS terminal command that will fulfill the request. It can be used for instance to run an app or interrogate the system",
      json_object(
        json_properties(
          command = json_string("The terminal command"),
          text = json_string("A comment on why we use the given command")
        ),
        required = c("command", "text")
      )
    )
  )
}


# new_open_ai_tool <- function(name, description, ...) {
#   tool <- list(
#     type = "function",
#     "function" = list(
#       name = name,
#       description = description
#     )
#   )
#   args <- list(...)
#   if (length(args)) {
#     args <- lapply(args, function(x) if(is.character(x)) new_open_ai_tool_arg(x) else x)
#     required <- as.list(names(Filter(function(x) x$required, args)))
#     args <- lapply(args, function(x) {x$required <- NULL; x})
#     tool$`function`$parameters <- list(
#       type = "object",
#       properties = args
#     )
#     if (length(required)) tool$`function`$parameters$required <- required
#   }
#   tool
# }
#
# # enum is used if there are finite choices for an arg, we have to test if it's similar for Claude
# new_open_ai_tool_arg <- function(description, type = "string", enum = NULL, required = TRUE) {
#   out <- list(type = type, description = description, required = required)
#   if (!is.null(enum)) {
#     out$enum <- enum
#   }
#   out
# }
#
# new_claude_tool <- function(name, description, ...) {
#   tool <- list(
#       name = name,
#       description = description
#     )
#   args <- list(...)
#   if (length(args)) {
#     args <- lapply(args, function(x) if(is.character(x)) new_claude_tool_arg(x) else x)
#     required <- as.list(names(Filter(function(x) x$required, args)))
#     args <- lapply(args, function(x) {x$required <- NULL; x})
#     tool$input_schema <- list(
#       type = "object",
#       properties = args
#     )
#     if (length(required)) tool$input_schema$required <- required
#   }
#   tool
# }
#
# # litterally the same as new_open_ai_tool_arg
# new_claude_tool_arg <- function(description, type = "string", required = TRUE) {
#   list(type = type, description = description, required = required)
# }
#
# tools_computer_openai <- function() {
#   tools_openai <- list(
#     new_open_ai_tool(
#       "screenshot",
#       "Instruct the user to take a screen shot to feed to the chat in the next message"
#     ),
#     new_open_ai_tool(
#       "click",
#       "Instruct the user to click at the provided coordinates",
#       x = new_open_ai_tool_arg("The x coordinate where to click", "number"),
#       y = new_open_ai_tool_arg("The y coordinate where to click", "number")
#     ),
#     new_open_ai_tool(
#       "mac_terminal",
#       "Provide the macOS terminal command that will fulfill the request. It can be used for instance to run an app or interrogate the system",
#       command = "The terminal command",
#       text = "A comment on why we use the given command"
#     )
#   )
# }
#
#

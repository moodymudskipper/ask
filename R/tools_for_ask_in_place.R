tools_for_ask_in_place <- function() {
  # list(
  #   list(
  #     type = "function",
  #     `function` = list(
  #       name = "apply_changes",
  #       description = "Apply changes to files according to the provided structured data.",
  #       strict = TRUE,
  #       parameters = list(
  #         type = "object",
  #         properties = list(
  #           changes = list(
  #             type = "array",
  #             items = list(
  #               type = "object",
  #               properties = list(
  #                 file = list(type = "string"),
  #                 content = list(type = "string")
  #               ),
  #               required = c("file", "content"),
  #               additionalProperties = FALSE
  #             )
  #           )
  #         ),
  #         required = list("changes"),
  #         additionalProperties = FALSE
  #       )
  #     )
  #   )
  # )
  list(
    name = "apply_changes",
    description = "Apply changes to files according to the provided structured data.",
    strict = TRUE,
    parameters = json_object(
      properties = json_properties(
        changes = json_array(
          items = json_object(
            properties = json_properties(
              file = json_string(),
              content = json_string()
            ),
            required = c("file", "content"),
            additionalProperties = FALSE
          )
        )
      ),
      required = list("changes"),
      additionalProperties = FALSE
    )
  )
}



tools_for_ask_in_place2 <- function() {
  list(
    list(
      type = "function",
      `function` = list(
        name = "apply_changes",
        description = "Apply changes to files according to the provided structured data.",
        strict = TRUE,
        parameters = json_object(
          properties = json_properties(
            changes = json_array(
              items = json_object(
                properties = json_properties(
                  file = json_string(),
                  content = json_string()
                ),
                required = c("file", "content"),
                additionalProperties = FALSE
              )
            )
          ),
          required = list("changes"),
          additionalProperties = FALSE
        )
      )
    )
  )
}

open_ai_click_tool <- function() {
  list(
    type = "function",
    `function` = list(
      name = "click",
      description = "Instruct the user to click at the provided coordinates",
      parameters = list(
        type = "object",
        properties = list(
          x = list(type = "number", description = "The x coordinate where to click"),
          y = list(type = "number", description = "The y coordinate where to click")
        ),
        required = list("x", "y")
      )
    )
  )
}

claude_click_tool <- function() {
  list(
    name = "click",
    description = "Instruct the user to click at the provided coordinates",
    input_schema = list(
      type = "object",
      properties = list(
        x = list(type = "number", description = "The x coordinate where to click"),
        y = list(type = "number", description = "The y coordinate where to click")
      ),
      required = list("x", "y")
    )
  )
}

open_ai_click_tool2 <- function() {
  list(
    type = "function",
    `function` = list(
      name = "click",
      description = "Instruct the user to click at the provided coordinates",
      parameters = json_object(
        properties = json_properties(
          x = json_number("The x coordinate where to click"),
          y = json_number("The y coordinate where to click")
        ),
        required = list("x", "y")
      )
    )
  )
}

claude_click_tool2 <- function() {
  list(
    name = "click",
    description = "Instruct the user to click at the provided coordinates",
    input_schema = json_object(
      properties = json_properties(
        x = json_number("The x coordinate where to click"),
        y = json_number("The y coordinate where to click")
      ),
      required = list("x", "y")
    )
  )
}

format_tool_openai <- function(tool) {
  tool$strict <- TRUE
  list(
    type = "function",
    `function` = tool
  )
}

format_tool_claude <- function(tool) {
  names(tool)[[3]] <- "input_schema"
  tool
}

if (FALSE) {
  tool <- new_tool(
    "click",
    "Instruct the user to click at the provided coordinates",
    json_object(
      properties = json_properties(
        x = json_number("The x coordinate where to click"),
        y = json_number("The y coordinate where to click")
      ),
      required = list("x", "y")
    )
  )

  foo <- format_tool_openai(tool)
  bar <- format_tool_claude(tool)
  waldo::compare(foo, open_ai_click_tool())
  waldo::compare(bar, claude_click_tool())
}


tools_for_ask_in_place3 <- function() {
  new_tool(
    "apply_changes",
    "Apply changes to files according to the provided structured data.",
    #strict = TRUE,
    json_object(
      json_properties(
        changes = json_array(
          json_object(
            properties = json_properties(
              file = json_string(),
              content = json_string()
            ),
            required = c("file", "content"),
            additionalProperties = FALSE
          )
        )
      ),
      required = list("changes"),
      additionalProperties = FALSE
    )
  )
}

tools_for_ask_in_place <- function() {
  list(
    list(
      type = "function",
      `function` = list(
        name = "apply_changes",
        description = "Apply changes to files according to the provided structured data.",
        strict = TRUE,
        parameters = list(
          type = "object",
          properties = list(
            changes = list(
              type = "array",
              items = list(
                type = "object",
                properties = list(
                  file = list(type = "string"),
                  content = list(type = "string")
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

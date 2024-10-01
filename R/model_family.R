model_family <- function(model) {
  if (startsWith(model, "gpt") || startsWith(model, "chatgpt") || startsWith(model, "o1-")) {
    "gpt"
  } else   if (startsWith(model, "llama")) {
    "llama"
  } else {
    abort("unsupported")
  }
}

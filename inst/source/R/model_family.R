model_family <- function(model) {
  if (startsWith(model, "gpt") || startsWith(model, "chatgpt")) {
    "gpt"
  } else   if (startsWith(model, "llama")) {
    "llama"
  } else {
    abort("unsupported")
  }
}

model_family <- function(model) {
  if (startsWith(model, "gpt")) {
    "gpt"
  } else   if (startsWith(model, "llama")) {
    "llama"
  } else {
    abort("unsupported")
  }
}

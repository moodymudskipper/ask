context_clipboard <- function() {
  # Capture the content of the clipboard
  clipboard_content <- readClipboard()
  
  # Create the context object
  context <- list(
    type = "clipboard",
    content = clipboard_content
  )
  
  # Print the content of the clipboard
  cat("Clipboard content:", clipboard_content, "\n")
  
  return(context)
}

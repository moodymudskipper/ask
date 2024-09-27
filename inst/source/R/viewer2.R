viewer2 <- function(html) {
  if (isTRUE(getOption("knitr.in.progress"))) {
    content <- readLines(html, warn = FALSE)
    content <- content[!grepl("^<!DOCTYPE html>", content, ignore.case = TRUE)]
    # Embed the HTML content within a box when knitting
    cat(
      "\n<div style='border:1px solid #ddd;padding:10px;'>\n",
      content,
      "\n</div>\n",
      # Added bottom padding outside the div
      "<div style='padding-bottom:10px;'></div>\n",
      sep = "\n"
    )
  } else {
    # Use rstudioapi::viewer() in regular cases
    rstudioapi::viewer(html)
  }
}







build_convo_rmd <- function(convo, path = tempfile(fileext = ".Rmd")) {
  header <-  r"[---
title: conversation
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

<script>
document.addEventListener("DOMContentLoaded", function() {
  document.querySelectorAll("details").forEach(function(details) {
    details.addEventListener("toggle", function() {
      var summary = this.querySelector("summary");
      if (this.open) {
        summary.dataset.originalText = summary.textContent;
        summary.textContent = "";
      } else {
        summary.textContent = summary.dataset.originalText;
      }
    });
  });
});
</script>

<style>
h1.title {
  display: none;
}
body {
  background-color: #F9fc0f5; /* Light grey background */
  margin-left: 20px; /* Add left margin */
  margin-right: 20px; /* Add left margin */
  margin-top: 20px; /* Add left margin */
}

.question {
  background-color: #b3cde0; /* Light blue color */
  border: 1px solid #ccc;
  border-radius: 10px; /* Rounding the corners */
  padding: 10px;
  margin-bottom: 5px;
}

.answer {
  background-color: #dbfadc;
  border: 1px solid #ccc;
  border-radius: 10px; /* Rounding the corners */
  padding: 10px;
  margin-top: 5px;
}

/* Hide the align left div */
.align-left {
  display: none;
}
</style>

<div class="align-left">
<details>
#
</details>
</div>]"

convo <- dplyr::as_tibble(convo)

code <- header
questions <- convo$prompt
if (model_family(convo$data$model[[1]]) == "gpt") {
  answers <- convo$data$choices$message$content
} else {

}

make_chunk <- function(content, type, last = FALSE) {
  if (nchar(content) > 80) {
    first_line <- strsplit(content, "\n")[[1]][1]
    if (startsWith(first_line, "```")) {
      summary <- "*code*"
    } else {
      summary <- paste0(substr(first_line, 1, 80), "...")
    }
    sprintf(r"[<div class="%s">
<details%s>
<summary>%s</summary>
%s
</details>
</div>
<p>]",
type,
if (last) " open" else "",
summary,
content
    )
  } else {
    sprintf(r"[<div class="%s">
%s
</div>
<p>]",
type,
content
    )
  }
}

n <- length(questions)
for (i in seq_len(n)) {
  code <- c(code, make_chunk(questions[[i]], "question"))
  code <- c(code, make_chunk(answers[[i]], "answer", i == n))
}
code <- paste(code, collapse = "\n")
writeLines(code, con = path)
return(path)
}

build_html_message <- function(content, type, last = FALSE) {
  if (nchar(content) > 80) {
    sprintf(rmd_summary_pattern,
            type,
            if (last) " open" else "",
            truncate(content),
            content
    )
  } else {
    sprintf(rmd_non_summary_pattern,
            type,
            content
    )
  }
}

rmd_header <- r"[---
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

rmd_summary_pattern <- r"[<div class="%s">
<details%s>
<summary>%s</summary>
%s
</details>
</div>
<p>]"

rmd_non_summary_pattern <- r"[<div class="%s">
%s
</div>
<p>]"

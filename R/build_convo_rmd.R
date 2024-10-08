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
  # consider structured output if relevant
  tool_calls <- convo$data$choices$message$tool_calls
  if (!is.null(tool_calls) && all(lengths(tool_calls))) {
    answers <- tool_calls
  } else {
    answers <- convo$data$choices$message$content
  }
} else {
  answers <- convo$data$response
}
make_chunk <- function(content, type, last = FALSE) {
  if (is.list(content)) {
    if (!is.data.frame(content)) content <- content[[1]]
    content <- content$`function`$arguments
    # sometimes, randomly, we get a vector rather than a single element, so we have
    # to repair it
    if (length(content) > 1) {
      inside <- gsub(r"[^\{"changes": \[(.*)\]\}$]", "\\1", content)
      content <- sprintf(r"[{"changes": [%s]}]", paste(inside, collapse = ","))
    }
    content <- jsonlite::prettify(content)
    content <- sprintf("```json\n%s\n```", content)
  }

  if (nchar(content) > 80) {
    sprintf(r"[<div class="%s">
<details%s>
<summary>%s</summary>
%s
</details>
</div>
<p>]",
type,
if (last) " open" else "",
truncate(content),
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


truncate <- function(x, n = 80) {
  lines <- strsplit(x, "\n")[[1]]
  if (length(lines) == 1 && nchar(x) <= n) return(x)
  if (startsWith(lines[1], "```")) {
    return("*code*")
  } else   if (startsWith(lines[1], "* ") || startsWith(lines[1], "- ")) {
    return("*list*")
  }
  short <- substr(lines[1], 1, n-3)
  odd_backquotes <- sum(strsplit(short, "")[[1]] == "`") %% 2
  if (odd_backquotes) {
    if (endsWith(short, "`")) {
      short <- substr(short, 1, n-4)
    } else {
      short <- paste0(short, "`")
    }
  }
  paste0(short, "...")
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ask_smart.R
\name{ask_smart}
\alias{ask_smart}
\title{ask for anything or any change}
\usage{
ask_smart(
  prompt = listen(),
  context = NULL,
  model = getOption("ask.model", "gpt-4o"),
  seed = NULL,
  temperature = 1,
  top_p = 1,
  cache = getOption("ask.cache"),
  api_key = Sys.getenv("OPENAI_API_KEY")
)
}
\arguments{
\item{prompt}{Your request, a string or a character vector that will be
concatenated to a string with line breaks as separators.}

\item{context}{An object of class "ask_context" usually built from a call
to \code{context()} or a \verb{context_*()} function. It is used to define a "system"
message that define the behavior, tone or focus of the assistant.}

\item{model}{The model to choose, see https://platform.openai.com/docs/models
or call \code{all_models()} for chatgpt model, or use ollama models such as
"llama3.1".}

\item{seed}{The seed used by the model, makes things more reproducible, but
not completely, due to the nature of LLMs. See \code{cache} to work around
that.}

\item{temperature}{Choose higher \code{temperature} for more diverse and
unexpected results, and lower \code{temperature} for more controlled and
consistent text.}

\item{top_p}{Choose high \code{top_p} for creative applications like storytelling,
poetry, or brainstorming. Choose low \code{top_p} for applications requiring
precision and coherence, such as technical writing, factual prompt, or summarization.}

\item{cache}{A path where to cache the outputs, or "ram" to store them
in RAM. useful to spare tokens and to have reproducible code.}

\item{api_key}{API key}
}
\description{
\code{ask_smart()} guesses which \verb{ask*()} function and which \verb{context*()}
function is appropriate, so you don't need to think too much or know the
package in depth.
}
\details{
It works by calling a llm twice, first to figure out the proper functions
to use, then through these functions. As a consequence it is slower and spends
more token (with an increased chance of reaching the limit of maximum tokens
per minute)
}

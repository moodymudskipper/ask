% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ask_console.R
\name{ask_console}
\alias{ask_console}
\alias{follow_up_console}
\title{Ask in the Console}
\usage{
ask_console(
  prompt = listen(),
  context = NULL,
  model = getOption("ask.model", "gpt-4o"),
  seed = NULL,
  temperature = 1,
  top_p = 1,
  image = NULL,
  cache = getOption("ask.cache"),
  api_key = Sys.getenv("OPENAI_API_KEY"),
  follow_up = FALSE
)

follow_up_console(
  prompt = listen(),
  context = NULL,
  conversation = last_conversation(),
  model = NULL,
  seed = NULL,
  temperature = NULL,
  top_p = NULL,
  image = NULL,
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

\item{image}{Path or URL to image to provide. Only considered for gpt models.}

\item{cache}{A path where to cache the outputs, or "ram" to store them
in RAM. useful to spare tokens and to have reproducible code.}

\item{api_key}{API key}

\item{follow_up}{Whether to automatically follow up in the console, press
Esc or Ctrl+C to exit the chat.}

\item{conversation}{A conversation, initiated by \code{ask()} or followed up by
\code{follow_up()}}
}
\value{
The result from the \code{ask()} function.
}
\description{
These are simple wrappers around \code{ask()} and \code{follow_up()}, that print to the
console rather than the viewer (Something that can also be achieved with
\code{print(ask(...), venue = "console")}). Only the last answer is printed but the
output object is still the entire conversation.
}

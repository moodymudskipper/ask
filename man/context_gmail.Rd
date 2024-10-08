% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/contexts.R
\name{context_gmail}
\alias{context_gmail}
\title{Contextualize Gmail messages from threads}
\usage{
context_gmail(
  search = NULL,
  num_results = 5,
  page_token = NULL,
  label_ids = NULL,
  include_spam_trash = NULL,
  user_id = "me"
)
}
\arguments{
\item{search, num_results, page_token, label_ids, include_spam_trash, user_id}{Forwarded to \code{gmailr::gm_threads()}}
}
\value{
An object of class "ask_context"
}
\description{
Contextualize Gmail messages from threads
}

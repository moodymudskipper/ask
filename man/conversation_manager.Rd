% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conversation_manager.R
\name{conversation_manager}
\alias{conversation_manager}
\title{Conversation Manager}
\usage{
conversation_manager()
}
\value{
A conversation
}
\description{
A small shiny app to manage all conversations. Whenever an \verb{ask*()} function is used (not just \code{ask()}), a new conversation
is recorded and can be accessed through the conversation manager. There we
can expand or remove conversations, or even start a new one from scratch.
When you pick a conversation you leave the shiny app and the chosen conversation is
printed in the viewer and stored as \code{last_conversation()} so you can use
\code{follow_up()} or \code{again()} to expand it..
}

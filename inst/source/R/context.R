# A context atomic is made of a label and content, where the content is a character or a context object
# a context object is a vector of such objects
# ... can be named character or unnamed context, if a label is provided, contexts are nested under this label

#' Build a context object
#'
#' Build an object of class "ask_context" to be used in the `context` argument.
#' of `ask*` functions. Most of the time using the provided `context_*()` functions
#' is sufficient.
#'
#' `context()` can be used :
#'
#' * To combine existing contexts, as in  `context(context1, context2)`
#' * To define a completely new context as in
#' * To nest contexts as in `context("new label" = context(context1, context2))`
#' * For any combination of the above
#'
#' They are implemented as nested lists so the labels can be numbered when flattened
#' internally in `ask*()` functions or when printing them. Run examples below to see
#' how this works.
#'
#' @param ... named character vectors, or other context ojects (named or not).
#'   These dots are dynamic in the rlang sense (``?rlang::`dyn-dots` ``) so they
#'   can be conveniently named using glue syntax and `:=`.
#'
#' @return An object of class `"ask_context"`
#' @export
#'
#' @examples
#' context_smith <- context(
#'   "Smith family" =
#'     "The Smith family is John, Wendy, and their 3 kids Boris, Judith and Michael."
#' )
#' context_johnson <- context("Johnson family" = "The Johnson family is Robert and his sister Brenda.")
#' context_house <- context(
#'   "House" =
#'     "The Smiths and the Johnsons live in the same house, called 'the happy place',"
#' )
#' context_johnson
#' full_context <- context(
#'   Families = context(context_smith, context_johnson),
#'   context_house
#' )
#' full_context
#' \dontrun{
#' ask("What are the names of the kids that live in the happy place", context = full_context)
#' ask_numeric("How many people live in the happy place?", context = full_context)
#' ask_boolean("Are Robert and Brenda related?", context = full_context)
#' }
context <- function(...) {
  dots <- rlang::list2(...)
  dots <- Filter(Negate(is.null), dots)
  contexts <- Map(
    function(x, nm) {
      if (is.character(x)) {
        if (nm == "") {
          abort("character inputs must be named")
        }
        x <- paste(x, collapse = "\n")
        out <- structure(list(list(label = nm, content = x)))
        return(out)
      }
      if (!inherits(x, "ask_context")) {
        abort("x must be a character or a context")
      }
      if (nm == "") return(x)
      structure(list(list(label = nm, content = x)))

    },
    dots,
    rlang::names2(dots),
    USE.NAMES = FALSE
  )
  suppressWarnings(
    structure(do.call(c, contexts), class = "ask_context")
  )
}

flatten_context <- function(context, prefix = "") {
 out <- NULL
   if (prefix == "") {
   # out <- "~~~~ GENERAL CONTEXT ~~~~"
    sep <- ""
  } else {
    #out <- sprintf("~~~~ context %s ~~~~ %s ~~~~", prefix, context$label)
    sep <- "."
  }

  if (is.character(context$content)) return(c(out, context$content))
  for (i in seq_along(context)) {
    prefix_i <- paste0(prefix, sep, i)
    atomic_context <- context[[i]]
    out_i1 <- sprintf("~~~~ context %s ~~~~ %s ~~~~", prefix_i, atomic_context$label)
    if (is.character(atomic_context$content)) {
      out_i2 <- atomic_context$content
    } else {
      out_i2 <- flatten_context(atomic_context$content, prefix_i)
    }
    out <- c(out, out_i1, out_i2)
  }
  out
}

#' @export
print.ask_context <- function(x, ...) {
  writeLines("<ask_context>")
  writeLines(flatten_context(x))
  invisible(x)
}

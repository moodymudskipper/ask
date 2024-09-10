#' Contextualize GitHub issues
#'
#' @param repo A string in the form 'my.org/my.repo' specifying the repository.
#'   If not provided, will be fetched from the URL field of the DESCRIPTION file.
#' @param state State of the issues to return ('open', 'closed', or 'all').
#' @param labels A vector of labels to filter the issues by.
#' @param sort What to sort the results by
#' @param direction The direction to sort the results by.
#' @param since A date or time used to only show results that were last updated after the given time.
#' @param n Number of results (max 100).
#' @param filter A string, see details.
#'
#' @section values for filter:
#'
# - **assigned** (default): Issues assigned to the authenticated user.
# - **created**: Issues created by the authenticated user.
# - **mentioned**: Issues mentioning the authenticated user.
# - **subscribed**: Issues the user is subscribed to.
# - **all**: All issues owned by the authenticated user.
#'
#' @return An object of class "ask_context"
#' @export
context_github <- function(
    repo = NULL,
    state = c("open", "closed", "all"),
    filter = c("assigned", "created", "mentioned", "subscribed", "all"),
    labels = NULL,
    sort = c("created", "updated", "comments"),
    direction = c("asc", "desc"),
    since = NULL,
    n = 30
) {
  # FIXME: instead of using per_page, pick an actual number of result and deal with the pagination.
  # only needed if we need more than 100 results.
  # FIXME: this doesn't include the comments, for those we need to use comments_url and send extra requests
  # we might have an 'include comments' arg
  # FIXME: the gemeral context should be accurately described, for instance if investigating
  # closed issue the AI should not infer that the repo only contains closed issues

  # note: arg checks and preprocessing happend in get_github_data
  data <- get_github_data(
    repo = repo,
    state = state,
    filter = filter,
    labels = labels,
    sort = sort,
    direction = direction,
    since = since,
    n = n
  )
  data$user <- data$user$login # so we have a flat data.frame, the rest is not very informative
  labs <- vapply(data$labels, paste, character(1), collapse = ", ")
  data$labels <- "" # to avoid weird rstudio crash
  data$labels <- labs
  data$assignees <- sapply(data$assignees, paste, collapse = ", ")
  data$reactions <- data$reactions$total_count
  data$body[is.na(data$body)] <- "(No description)"
  keep <- c("number", "title", "user", "labels", "state", "locked", "assignees", "milestone", "comments", "created_at", "updated_at", "closed_at", "reactions")
  if (! "pull_request" %in% names(data)) {
    data_issues <- data
    context_metadata_prs <- NULL
    context_content_prs <- NULL
  } else {
    issue_lgl <- is.na(data$pull_request$url)
    data_issues <- data[issue_lgl,]
    data_prs <- data[!issue_lgl,]
    data_prs$merged_at <- data_prs$pull_request$merged_at
    metadata_prs <- data_prs[c(keep, "merged_at")]
    context_metadata_prs <- context("Github Pull Requests metadata" = knitr::kable(metadata_prs))
    rows <- unname(split(data_prs[c("number", "title", "body")], seq_len(nrow(data_prs))))
    context_content_prs <- context(
      "Github Pull Request description" = context(
        !!!lapply(rows, context_github_issue, pr = TRUE)
      )
    )
  }
  if (!nrow(data_issues)) {
    context_metadata_issues <- NULL
    context_content_issues <- NULL
  } else {
    metadata_issues <- data_issues[keep]
    context_metadata_issues <- context("Github Issues metadata" = knitr::kable(metadata_issues))
    rows <- unname(split(data_issues[c("number", "title", "body")], seq_len(nrow(data_issues))))
    context_content_issues <- context("Github issues content" = context(!!!lapply(rows, context_github_issue)))
  }

  context_github <- context(
    "Github issues for repo " = context(
      context_metadata_issues,
      context_content_issues,
      context_metadata_prs,
      context_content_prs,
    ))
  context_github
}

get_github_data <-  function(
    repo = NULL,
    state = c("open", "closed", "all"),
    filter = c("assigned", "created", "mentioned", "subscribed", "all"),
    labels = NULL,
    sort = c("created", "updated", "comments"),
    direction = c("asc", "desc"),
    since = NULL,
    n = 30,
    include_comments = FALSE
) {
  # arg checks and preprocessing -----------------------------------------------

  if (is.null(repo)) {
    repo <- try(
      silent = TRUE,
      {
        desc <- readLines("DESCRIPTION")
        url_line <- desc[startsWith(desc, "URL:")]
        sub("^URL: https://github.com/", "", url_line)
      }
    )
    if (inherits(repo, "try-error")) {
      abort("`repo` must be either provided or parseable from the DESCRIPTION file")
    }
  }

  state <- arg_match(state)
  filter <- arg_match(filter)
  if (!is.null(labels)) labels <- paste(labels, collapse=",")
  sort <- arg_match(sort)
  direction <- arg_match(direction)
  if (!is.null(since)) since <- convert_to_iso8601(since)

  if (include_comments) {
    abort("including comments is not supported yet")
  }

  ## filter: Determines which issues to return (this parameter is available only for user-specific endpoints, such as /user/issues).
  #
  # assigned (default): Issues assigned to the authenticated user.
  # created: Issues created by the authenticated user.
  # mentioned: Issues mentioning the authenticated user.
  # subscribed: Issues the user is subscribed to.
  # all: All issues owned by the authenticated user.
  ## state: Filters issues based on their state.
  #
  # open
  # closed
  # all
  ## labels: A comma-separated list of label names. Issues must have all of the specified labels to be included. By default, no issues are filtered by labels.
  #
  ## sort: Specifies the property to sort the results by.
  #
  # created
  # updated
  # comments
  ## direction: The direction to sort the results.
  #
  # asc: Ascending order.
  # desc (default): Descending order.
  ## since: Only issues updated at or after this time are returned. The time must be specified in ISO 8601 format (YYYY-MM-DDTHH:MM:SSZ).
  #
  ## assignee: Filters issues based on the user to whom they are assigned.
  #
  # none: Issues without an assignee.
  # *: Issues assigned to any user.
  # {username}: Issues assigned to the specified user.
  ## creator: Filters issues based on the user who created them.
  #
  ## mentioned: Filters issues that mention a particular user.
  #
  ## milestone: Filters issues based on the milestone they are associated with.
  #
  # none: Issues without a milestone.
  # *: Issues with any milestone.
  # {number}: Issues assigned to the specified milestone.
  ## per_page: The number of results to return per page (maximum is 100). The default value is 30.
  #
  ## page: The page number of the results to fetch.

  api_url <- sprintf("https://api.github.com/repos/%s/issues", repo)
  params <- list(
    repo = repo,
    state = state,
    filter = filter,
    labels = labels,
    sort = sort,
    direction = direction,
    since = since,
    per_page = n
  )

  response <- httr::GET(api_url, query = params)
  issues <- httr::content(response, "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(issues)
  dplyr::as_tibble(data)
}

context_github_issue <- function(data, pr = FALSE) {
  if (pr) {
    header <- sprintf("Github Pull request #%s: %s", data$number, data$title)
  } else {
    header <- sprintf("Github Issue #%s: %s", data$number, data$title)
  }
  context("{header}" := data$body)
}

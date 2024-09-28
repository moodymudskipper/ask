#' Contextualize ClickUp data
#'
#' Fetch data from ClickUp and build a context using the `context()` function.
#'
#' @param team_id The ID of the ClickUp team for which to fetch data.
#' @param api_key API key for ClickUp.
#' @param num_tasks The number of recent tasks to fetch for each list (default is 5).
#' @return An object of class "ask_context"
#' @export
context_clickup <- function(team_id = Sys.getenv("CLICKUP_TEAM_ID"), api_key = Sys.getenv("CLICKUP_API_TOKEN"), num_tasks = 5) {
  base_url <- "https://api.clickup.com/api/v2"

  # Fetch all spaces for the team
  spaces_url <- paste0(base_url, "/team/", team_id, "/space")
  spaces_response <- httr::GET(
    spaces_url,
    httr::add_headers(Authorization = api_key)
  )
  spaces <- httr::content(spaces_response, "text", encoding = "UTF-8")
  spaces <- jsonlite::fromJSON(spaces)$spaces
  spaces <- unname(split(spaces, seq_len(nrow(spaces))))
  space_contexts <- lapply(spaces, fetch_space_context, api_key=api_key, base_url=base_url, num_tasks=num_tasks)
  context("ClickUp Data" = context(!!! space_contexts))
}

fetch_space_context <- function(space, api_key, base_url, num_tasks) {
  space_id <- space$id
  space_name <- space$name

  # Fetch all lists for the space
  lists_url <- paste0(base_url, "/space/", space_id, "/list")
  lists_response <- httr::GET(
    lists_url,
    httr::add_headers(Authorization = api_key)
  )
  lists <- httr::content(lists_response, "text", encoding = "UTF-8")
  lists <- jsonlite::fromJSON(lists)$lists
  if (!NROW(lists)) return(NULL)

  lists <- unname(split(lists, seq_len(nrow(lists))))
  list_contexts <- lapply(lists, fetch_list_context, api_key=api_key, base_url=base_url, num_tasks=num_tasks)
  list_contexts <- Filter(Negate(is.null), list_contexts)
  if (!length(list_contexts)) return(NULL)
  context("Space: {space_name}" := context(!!! list_contexts))
}

fetch_list_context <- function(list, api_key, base_url, num_tasks) {
  list_id <- list$id
  list_name <- list$name

  # Fetch recent tasks for the list
  tasks_url <- httr::modify_url(
    paste0(base_url, "/list/", list_id, "/task"),
    query = list(page = 0, order_by = "created", reverse = "true", subtasks = "false")
  )
  tasks_response <- httr::GET(
    tasks_url,
    httr::add_headers(Authorization = api_key)
  )
  tasks <- httr::content(tasks_response, "text", encoding = "UTF-8")
  tasks <- jsonlite::fromJSON(tasks)$tasks

  if (!NROW(tasks)) return(NULL)

  tasks <- unname(split(tasks, seq_len(nrow(tasks))))
  task_contexts <- lapply(tasks[1:num_tasks], fetch_task_context)
  context("List: {list_name}" := context(!!! task_contexts))
}

fetch_task_context <- function(task) {
  task_name <- task$name
  task_desc <- task$description
  task_status <- task$status$status

  context(
    "Task: {task_name}" := c(
      sprintf("Description: %s", task_desc),
      sprintf("Status: %s", task_status)
    )
  )
}

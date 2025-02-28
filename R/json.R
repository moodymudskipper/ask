

#' JSON schema helpers
#'
#' These are helpers meant to be used recursively in the `parameters` argument
#' of `new_tool()`. These build JSON schema element, or more precisely R nested
#' lists that can be converted to proper JSON schemas by `jsonlite::toJSON()`.
#' We support only very basic features of JSON schemas, if these are not sufficient
#' for your requirements when buidimg tools, please open a ticket.
#'
#' @param properties An object built with `json_properties()`
#' @param required An optional character vector of names of required properties
#' @param additionalProperties Either a boolean to allow or disallow additional properties,
#'   or a an object built with `json_properties()` to specify a format that additional
#'   properties must conform to. In its absence it's considered `TRUE`.
#' @param description A string. Mostly useful for atomic items but can be used in `json_array()`
#' or `json_object()` as well
#' @param ...,items Named objects, either basic objects built by `json_number()`, `json_string()`,
#' or `json_boolean()`, or recursive objects built by `json_array()` or `json_object()`
#'
#' @export
json_object <- function(properties = json_properties(placeholder = json_null()), description = NULL, required = names(properties), additionalProperties = FALSE) {
  out <- list(type = "object")
  out$properties <- properties
  out$description <- description
  out$required <- as.list(required)
  out$additionalProperties <- additionalProperties
  structure(out, json_type = "object")
}

#' @export
#' @rdname json_object
json_properties <- function(...) {
  list(...)
}

#' @export
#' @rdname json_object
json_array <- function(items, description = NULL) {
  out <- list(type = "array", items = items)
  out$description <- description
  out
}

#' @export
#' @rdname json_object
json_string <- function(description = NULL) {
  out <- list(type = "string")
  out$description <- description
  out
}

#' @export
#' @rdname json_object
json_number <- function(description = NULL) {
  out <- list(type = "number")
  out$description <- description
  out
}

#' @export
#' @rdname json_object
json_boolean <- function(description = NULL) {
  out <- list(type = "boolean")
  out$description <- description
  out
}

#' @export
#' @rdname json_object
json_null <- function(description = NULL) {
  out <- list(type = "null")
  out$description <- description
  out
}

convert_to_iso8601 <- function(datetime) {
  # Convert the input datetime to ISO 8601 format string
  iso8601_str <- format(datetime, "%Y-%m-%dT%H:%M:%SZ")
  return(iso8601_str)
}

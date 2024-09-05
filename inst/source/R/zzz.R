
ask_impl_memoised <- NULL
list_models <- NULL

.onLoad <- function(...) {
  all_models <<- memoise::memoise(all_models)
  if (package_is_ask()) copy_source()
}

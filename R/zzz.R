
ask_impl_memoised <- NULL
list_models <- NULL

.onLoad <- function(...) {
  ask_impl_memoised <<- memoise::memoise(ask_impl)
  all_models <- memoise::memoise(all_models)
}

return_cached <- function(
    cache,
    forget,
    prompt,
    context,
    conversation,
    model,
    api_args,
    image) {
  if (cache %in% names(globals$memoised)) {
    memoised_fun <- globals$memoised[[cache]]
    if (forget) {
      memoise::drop_cache(memoised_fun)(
        prompt = prompt,
        context = context,
        conversation = conversation,
        model = model,
        api_args = api_args,
        image = image
      )
    }
  } else {
    if (cache == "ram") {
      memoised_fun <- memoise::memoise(ask_impl)
    } else {
      memoised_fun <- memoise::memoise(
        ask_impl,
        cache = memoise::cache_filesystem(cache)
      )
    }
    globals$memoised[[cache]] <- memoised_fun
  }
  return(
    memoised_fun(
      prompt = prompt,
      context = context,
      conversation = conversation,
      model = model,
      api_args = api_args,
      image = image
    )
  )
}

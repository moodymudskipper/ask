return_cached <- function(
    cache,
    forget,
    prompt,
    context,
    conversation,
    model,
    seed,
    temperature,
    top_p,
    n) {
  if (cache %in% names(globals$memoised)) {
    memoised_fun <- globals$memoised[[cache]]
    if (forget) {
      memoise::drop_cache(memoised_fun)(
        prompt = prompt,
        context = context,
        conversation = conversation,
        model = model,
        seed = seed,
        temperature = temperature,
        top_p = top_p,
        n = n
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
      seed = seed,
      temperature = temperature,
      top_p = top_p,
      n = n
    )
  )
}

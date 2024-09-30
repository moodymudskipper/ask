
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ask

{ask} anwsers natural language queries trough diverse actions (not just
a text answer as is done by simpler interfaces to LLMs) using optional
contextual information.

The function you use decides the type of action, it takes the query as
its first argument :

- `ask()`: Text output through a UI in the viewer pane
- `ask_in_place()`: Script edits
- `ask_clipboard()`: Text output copied to the clipboard
- `ask_terminal()`: Copy a command to the terminal
- `ask_tibble()`, `ask_numeric()`, `ask_boolean()`: Actual R objects
- `ask_open()`: Open a script
- `ask_smart()`: Anything, will run a first API call to guess which
  function and context you need, and a second to actually answer the
  query.

The context is provided as a second argument, and we have a collection
of function to make this easy.

- `context_repo()`: Consider your active repo
- `context_package()`: Consider any package
- `context_script()`: Consider the active script, or any given script
- `context_clipboard`: Use clipboard content as context
- `context_url`: Use html content of url as context
- … (many more)

It is built on top of chatgpt (default) or llama for now.

## Installation

Install with:

``` r
pak::pak("moodymudskipper/ask")
```

You’ll need either:

- an OpenAI API key linked to a credit card :
  <https://openai.com/index/openai-api/>
- An installation of Ollama : <https://ollama.com/download>

A quick comparison of *gpt-4o* (OpenAI) and *llama3.1* (Ollama)
according to just me.

|                      | OpenAI   | Ollama            |
|----------------------|----------|-------------------|
| Result relevance     | ⭐⭐⭐⭐ | ⭐⭐⭐            |
| Change code in place | ⭐⭐⭐   | 🌜                |
| Speed                | ⭐⭐⭐   | ⭐⭐              |
| Data protection      | ⭐⭐     | ⭐⭐⭐⭐ (local!) |
| Price                | 💰       | 🆓                |

## ask, follow up and build a conversation

`ask()` a question to start a conversation

``` r
library(ask)
ask("where is the Eiffel tower? 1 sentence")
```

![](inst/readme_ask1.png)

To follow up a query, no need to store the previous output, we keep it
in a global variable (accessible with `last_conversation()`) so you
might simply call `follow_up()`.

``` r
follow_up("is it tall? 1 sentence")
```

![](inst/readme_ask2.png)

If you’re not happy with an answer you might ask again. This will
replace the latest follow up rather than add an extra message as would
be the case if we reran the last command.

``` r
again()
```

![](inst/readme_ask3.png)

To access previous conversation you might call `conversation_manager()`,
it will open a shiny app in the viewer where you can browse your
history, continue a conversation or pick one to print and continue with
`follow_up()` or `again()`

## Examples

``` r
ask(
  "What S3 methods does this register? just a bullet list", 
  context_script(system.file("NAMESPACE", package = "ask"))
)
```

![](inst/readme_ask4.png)

``` r
# this works because the package is small enough!
ask(
    "how to set environment variables locally using this package? 1 sentence", 
    context_package("withr")
)
```

![](inst/readme_ask5.png)

Some contexts are too big, this happens often with `context_package()`
or `context_repo()`.

``` r
ask(
    "what version is installed and what features were added for this version? 1 sentence", 
    context_package("rlang")
)
#> Error in `response_data()`:
#> ! Request too large for gpt-4o in organization org-Q6n98iXzy6UPHiel732RUDnh on tokens per min (TPM): Limit 30000, Requested 151125. The input or output tokens must be reduced in order to run successfully. Visit https://platform.openai.com/account/rate-limits to learn more.
```

In these cases we can sometimes manage the context window. In the case
of `context_package()` code is not included by default but the help
files are and they sometimes take too many tokens for a LLM query.

``` r
ask(
    "what version is installed and what features were added for this version? 1 sentence", 
    context_package("rlang", help_files = FALSE)
)
```

![](inst/readme_ask6.png)

``` r
ask_tibble(
    "extract the key dates and events", 
    context_url("https://en.wikipedia.org/wiki/R_(programming_language)")
)
#> # A tibble: 3 × 2
#>   date              event                              
#>   <chr>             <chr>                              
#> 1 August 1993       Posted a binary of R on StatLib    
#> 2 December 5, 1997  R became a GNU project             
#> 3 February 29, 2000 First official 1.0 version released
```

``` r
# simulate clipboard use
clipr::write_clip(
  "Grocery list: 2 apples, 1 banana, 7 carrots",
  allow_non_interactive = TRUE
  )
ask_numeric("How many fruits will I buy ?", context_clipboard())
#> [1] 3
```

``` r
# this was run manually (not reproducible because of context and output)
ask_terminal("what git command can I run to check would did the latest changes to the `ask()` function?", context_repo())
```

![](inst/readme_terminal.png)

## Update the code base in place

Even more interesting is using those to change your code in place, for
this we use the `ask_in_place()` function.

Try things like :

``` r
ask_in_place("write roxygen2 documentation for functions in the active script", context_script())
ask_in_place("write tests for my_function()", context_script())
ask_in_place("move my_function() to its own script", context_script())
ask_in_place("write a README for this package", context_repo())
```

## Caching system

Caching is useful to spare tokens and because LLMs don’t always answer
the same thing when asked twice.

There’s a `cache` argument to most functions but the recommended use
would be to set `options(ask.cache = "my_cache_folder")`. Then `ask()`
will return the same thing when called with the same prompt and other
parameters, calling `again()` on a conversation triggers a new answer
and replaces the cache.

“ram” is a special value to store the cache in memory rather than disk.

## Speech to text

If no input is provided we use speech to text, to end either click on
“Done” or say “stop listening”. At the moment this only works on macOS
and if Chrome is installed.

``` r
ask() # ask a question
```

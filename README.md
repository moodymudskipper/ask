
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ask

{ask} is designed to ask R anything with minimal effort. This includes
changing code in place and sending commands to the terminal. To do so we
use natural language (typed or spoken), and simple well documented
functions with nice names and good defaults.

Things we can do :

- ask to document a function in place
- ask to write tests for a functions
- refactor a function
- summarize the latest git commits
- split a script into several scripts

It is built on top chatgpt (default) or llama for now. chatGPT 4o gives
impressive results, The small llama model doesn’t perform that well
unfortunately and I haven’t tried the bigger ones.

It’s in progress and I don’t worry too much about breaking things or
renaming functions. But it’s definitely already useful, I’ve actually
used it already to design itself!

## Installation

install with:

``` r
pak::pak("moodymudskipper/ask")
```

You’ll also need a chatgpt api key and/or to install llama.

For the speech to text feature you’ll need pythin and might need:

    brew install portaudio
    pip install SpeechRecognition
    pip install pyAudio

The first one for MacOS only, not sure about other systems, hopefully
the errors will guide you, use the `ask()` function!

## Simple cases

When we don’t providing a `context` argument, the package is a simple
interface to the API, with a system to cache the last result so the use
is very comfortable

``` r
library(ask)

ask("where is the Eiffel tower?")
#> The Eiffel Tower is located in Paris, France. It is situated on the Champ de Mars near the Seine River. The exact address is Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France.
```

``` r

follow_up("is it high?")
#> Yes, the Eiffel Tower is quite tall. It stands at a height of approximately 330 meters (1,083 feet), including its antennas. When it was completed in 1889, it was the tallest man-made structure in the world until the completion of the Chrysler Building in New York City in 1930. The tower has three levels that are accessible to the public, with the highest observation deck located at about 276 meters (906 feet) above the ground, offering spectacular views of Paris.
```

``` r

again()
#> Your question is quite broad and lacks context. "Is it high?" could refer to a variety of things, such as altitude, temperature, price, or even a person's state of being. Could you please provide more details or clarify what specifically you're asking about? This will help me give you a more accurate and useful response.
```

## Speech to text

If no input is provided we use speech to text, say “stop listening” to
interrupt the recording, or wait until the time out threshold is
reached.

``` r
ask() # ask a question
```

## Using contexts

More interesting however is to ask with a context, context objects are
basically tools to build system messages (directives that sets the
context or behavior for the model) often using data like file content,
git history, active script etc…

``` r
# run manually after the README was done
ask("what is this file about, in one sentence?", context = context_script())
# This file is a README script for the `ask` R package that explains its goals, installation process, usage examples, and future development ideas.
ask("what are my last commits about?", context_commits(n = 2))
```

(We could also have called
`ask_script("what is this file about, in one sentence?")` here)

Here are some contexts that you might find useful:

- `context_script()`: Active script by default, but we can provide any
  path
- `context_repo()`: All R scripts of the repo, README, NAMESPACE,
  DESCRIPTION, LICENSE, LICENSE.md. This might be too much for your LLM
  context window if you have a repo of a decent size.
- `context_session_info()` Basically the output of `SessionInfo()`
- `context_gmail()` : Email threads, you probably need to restrict
  `num_results`
- `context_diff()` : Uncommitted changes
- `context_commits()` : Committed changes

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

## Returning R objects

We have some functions to return objects of given types. If you use
cache you can write reproducible scripts using those.

``` r
ask_numeric("How many dwarves in Snow White?")
#> [1] 7
```

``` r

ask_boolean("Do birds sing?")
#> [1] TRUE
```

``` r

ask_boolean("Is the Earth flat?")
#> [1] FALSE
```

``` r

ask_boolean("Does God exist")
#> [1] NA
```

``` r

ask_boolean("potatoe")
#> [1] NA
```

``` r

ask_tibble("Snow White Dwarves + favourite pizza")
#> # A tibble: 7 × 2
#>   dwarf   favourite_pizza
#>   <chr>   <chr>          
#> 1 Dopey   Margherita     
#> 2 Grumpy  Pepperoni      
#> 3 Happy   BBQ Chicken    
#> 4 Sleepy  Vegetarian     
#> 5 Bashful Hawaiian       
#> 6 Sneezy  Four Cheese    
#> 7 Doc     Marinara
```

``` r

ask_tibble("gdps of small countries")
#> # A tibble: 5 × 2
#>   country            gdp
#>   <chr>            <dbl>
#> 1 Tuvalu             42 
#> 2 Nauru             133.
#> 3 Kiribati          198.
#> 4 Marshall Islands  244.
#> 5 Palau             268.
```

## Terminal operations

Because copying and pasting to the terminal is a pain `ask_terminal()`
will do it for you, with commands taking into account your context if
you provide it. It doesn’t run those as this would be unsafe, so you’ll
still have to press Enter.

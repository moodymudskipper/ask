
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ask

Another interface to chatgpt with R, but the goal ultimately here is to
integrate it in the R workflow by creating specialized wrappers.

## Installation

install with

``` r
pak::pak("moodymudskipper/ask")
```

## Example

``` r
library(ask)

ask("where is the Eiffel tower?")
#> The Eiffel Tower is located in Paris, France. It is situated on the Champ de Mars, a large public greenspace near the Seine River.
```

``` r

follow_up("is it high?")
#> Yes, the Eiffel Tower is quite high. It stands at approximately 330 meters (about 1,083 feet) tall, including its antennas. When it was completed in 1889, it was the tallest man-made structure in the world until the Chrysler Building in New York City was finished in 1930. The tower remains one of the most recognizable and iconic structures in the world.
```

``` r

again()
#> Yes, the Eiffel Tower is quite high. It stands at approximately 330 meters (1,083 feet) tall, including its antennas. When it was completed in 1889, it was the tallest man-made structure in the world, a title it held for over 40 years until the completion of the Chrysler Building in New York City in 1930.
```

``` r

ask_numeric("how many dwarves in Snow White?")
#> [1] 7
```

``` r

ask_boolean("Do birds sing?")
#> [1] TRUE
```

``` r

ask_boolean("Is the earth flat?")
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

If no input is provided we use speech to text, say “stop listening” to
interrupt the recording, or wait until the time out threshold is
reached.

Call `ask_document()` to query in context to the active script. For
instance: `ask_document("add roxygen2 doc to these functions")`,
`ask_document("can this be simplified?")`,
`ask_document("rewrite this in data.table")`.

We plan to develop more such functions to help R development not only
through questions but also script creations or in place modifications
that we can then review through git diffs.

Would be great to have for instance :

- `ask_repo()`
- `ask_email()`
- `ask_calendar()`
- `ask_git()`

To do so we need to fetch the info, turn it into english text and use it
to enrich prompts.

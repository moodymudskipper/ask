
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ask

Another interface to chatGPT with R, but the goal ultimately here is to
integrate it in the R workflow by creating specialized wrappers.

For the speech to text feature you might need.

    brew install portaudio
    pip install SpeechRecognition
    pip install pyAudio

The first one for MacOS only, not sure about other systems, hopefully
the errors will guide you, use the `ask()` function!

## Installation

install with

``` r
pak::pak("moodymudskipper/ask")
```

## Example

``` r
library(ask)

ask("where is the Eiffel tower?")
#> The Eiffel Tower is located in Paris, France, specifically on the Champ de Mars near the Seine River. Its address is Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France.
```

``` r

follow_up("is it high?")
#> Yes, the Eiffel Tower is quite high. It stands at approximately 330 meters (about 1,083 feet) tall, including its antennas. When it was completed in 1889, it was the tallest man-made structure in the world, and it remained so until the completion of the Chrysler Building in New York City in 1930. It is still an iconic and towering landmark.
```

``` r

again()
#> Yes, the Eiffel Tower is quite tall. It stands at approximately 330 meters (about 1,083 feet) including its antennas. When it was completed in 1889, it was the tallest man-made structure in the world until the Chrysler Building in New York City was finished in 1930. The tower's height and iconic design make it a prominent landmark in Paris.
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

Call `ask_script()` to query in context to the active script. For
instance: `ask_script("add roxygen2 doc to these functions")`,
`ask_script("can this be simplified?")`,
`ask_script("rewrite this in data.table")`.

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

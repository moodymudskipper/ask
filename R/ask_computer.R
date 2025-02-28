# fixme: we need ask_tool first, returns action and arg, then apply_tool()
# ask_tool behaves depending on model family, not apply tool
# we also probably need jsonlite::parse_json instead of fromJSON, would simplify many things
# the conversation obj could be restructured to contain input (prompt temp etc), response_json, and response_list (do we really need it ?)
# we also need a separate helper to extract messages from a conversation.

ask_computer <- function(prompt) {

  conv <- ask_impl(prompt, tools = tools_computer_openai(), context = context_computer)

  repeat {
    message(sprintf(
      "step (%s) --------------------------------------------------------",
      nrow(conv)
    ))

    #repeat {
      res <- ask_impl(prompt, tools = tools_computer_openai(), context = context_computer, conversation = conv)
      # if (res$type == "error" && res$error$type == "overloaded_error") {
      #   rlang::inform(c(sprintf("%s: %s", res$error$type, res$error$message), i = "we'll wait 5 sec and try again"))
      #   Sys.sleep(5)
      # } else {
      #   break
      # }
    #}

    # if (res$type == "error") {
    #   messages <<- messages
    #   abort(sprintf("%s: %s", res$error$type, res$error$message))
    # }

    # fetch text response, usually it's in the first element, sometimes absent
    # I've never seen text out of the 1st element but we prefer to be general
    # text <- unlist(lapply(res$content, function(x) x$text))
    # if (!length(text)) text <- "*no text in response*"
    # writeLines(text)

    print(res$content)
    stop_reason <- conv$data$choices$finish_reason
    if (!length(stop_reason)) browser()
    if (stop_reason == "tool_calls") {
      content <- conv$data$choices$message$tool_calls
      for (content in res$content) {
        if (content$type != "tool_use") next
        name <- content$name
        action <- content$input$action
        image <- NULL
        if (name == "computer" && action == "screenshot") {
          message("* Taking a screenshot")
          image <- apple_screenshot("test.png")
          messages <- append_to_last_message(messages, content, image = image)
        } else if (name == "computer" && action == "key") {
          message(sprintf("* triggering hotkey: %s", content$input$text))
          apple_hotkey(content$input$text)
          messages <- append_to_last_message(messages, content, image = image)
        } else if (name == "computer" && action == "type") {

          message(sprintf("* typing: %s", content$input$text))
          apple_keystroke(content$input$text)
          messages <- append_to_last_message(messages, content)
        } else if (name == "computer" && action == "mouse_move") {
          x <- content$input$coordinate[[1]]
          y <- content$input$coordinate[[2]]

          # from trial and error
          x <- round(1.04 * x) # tweak
          y <- round(1.04 * y) # tweak
          content$input$coordinate[[1]] <- x
          content$input$coordinate[[2]] <- y

          message(sprintf("* Moving cursor to: %s, %s", x, y))
          apple_move_cursor(x, y)
          messages <- append_to_last_message(messages, content)
          message("sleep 1 sec to see new cursor position")
          Sys.sleep(1)
        }  else if (name == "computer" && action == "left_click") {
          message("* left click")
          apple_left_click()
          messages <- append_to_last_message(messages, content)
        } else if (name == "computer" && action == "right_click") {
          message("* right click")
          apple_right_click()
          messages <- append_to_last_message(messages, content)
        } else if (name == "bash") {
          # NA for mac
        } else if (name == "mac_terminal") {
          message("* Call terminal command: %s", content$input$command)
          system(content$input$command)
          messages <- append_to_last_message(messages, content)
        }
      }
    } else {
      break
    }
  }
}


context_computer <- function() {
  txt <-   system <- paste(
    sep = "\n",
    "<SYSTEM_CAPABILITY>",
    "* You are utilising a MacBook Air 4. with internet access.",
    # "* Using bash tool you can start GUI applications, but you need to set export DISPLAY=:1 and use a subshell. For example \"(DISPLAY=:1 xterm &)\". GUI apps run with bash tool will appear within your desktop environment, but they may take some time to appear. Take a screenshot to confirm it did.",
    # "* When using your bash tool with commands that are expected to output very large quantities of text, redirect into a tmp file and use str_replace_editor or `grep -n -B <lines before> -A <lines after> <query> <filename>` to confirm output.",
    "* When viewing a page it can be helpful to zoom out so that you can see everything on the page.  Either that, or make sure you scroll down to see everything before deciding something isn't available.",
    "* When using your computer function calls, they take a while to run and send back to you.  Where possible/feasible, try to chain multiple of these calls all into one function calls request.",
    "* The current date is {datetime.today().strftime('%A, %B %-d, %Y')}.",
    "* In particular apps can be opened with `open -a \"APPNAME\"` or `open -a \"APPNAME\" \"FILE\"`",
    "* Use Firefox for browsing, or the specific browser the user requests you to use.",
    "* To save a picture, right click on it, then press the 'q' key to select 'Save Image As', then press enter to enter the save as dialog.",
    "* Whenever you use a hotkey, make sure that the hotkey is relevant to the active app, and describe what it's meant to achieve in your message.",
    "</SYSTEM_CAPABILITY>",
    "",
    "<IMPORTANT>",
    "* The first thing you do after opening a new app is to maximize it using the `Ctrl Command F` hotkey.",
    "* To open apps, favor terminal commands over clicks.",
    "* In a web browser to go to the url input field press command L.",
    "* Always refuse the cookies if a pop up comes up in a web browser.",
    "* Always refuse the translation if a pop up comes up in a web browser.",
    "* Sometimes a window is closed by mistake, be sure to verify with each screenshot that the relevant window is there, if it is not, re-open the app.",
    "* When using a web browser, if a startup wizard appears, IGNORE IT.  Do not even click \"skip this step\".  Instead, click on the address bar where it says \"Search or enter address\", and enter the appropriate search term or URL there.",
    "* If the item you are looking at is a pdf, if after taking a single screenshot of the pdf it seems that you want to read the entire document instead of trying to continue to read the pdf from your screenshots + navigation, determine the URL, use curl to download the pdf, install and use pdftotext to convert it to a text file, and then read that text file directly with your StrReplaceEditTool.",
    "</IMPORTANT>"
  )
  context(
    Behavior = text
  )
}

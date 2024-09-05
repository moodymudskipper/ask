#' listen to voice input
#'
#' @return A string
#' @param verbose whether to print the recorded text as a message
#' @export
listen <- function(verbose = TRUE) {
  app_env <- environment()
  send_event_from_backend_to_frontend <- function(session, data) {
    session$sendCustomMessage(
      type = data$event,
      message = data
    )
  }
  server <- \(input, output, session) {
    close_and_quit <- function() {
      session$close()
      quit_browser()
      out <- sub(" ?stop listening$", "", input$listening_text)
      out <- sub("^[ \n]+", "", out)
      if (verbose) rlang::inform(paste(c("You asked:", out), collapse = "\n"))
      rlang::return_from(app_env, out)
    }

    shiny::observeEvent(input$close_app, {
      close_and_quit()
    })

    shiny::observeEvent(input$done, {
      close_and_quit()
    })
  }

  scr <- htmltools::tags$script(htmltools::HTML(htmlwidgets::JS('
          Shiny.addCustomMessageHandler(type = "ask", function(message) {
             Shiny.setInputValue("listening_text", "");
             document.querySelector("#listening_text").innerHTML = "";
          })
          artyom.addCommands([{
            description:"It will save the text it recognizes.",
            indexes: ["*"],
            smart: true,
            action : function(i, wildcard, sentence){
              var sel = document.querySelector("#listening_text")
              if(wildcard.length > 0) {
                text = sel.value + "\\n" + wildcard;
                Shiny.setInputValue("listening_text", text);
                sel.value = text;
                console.log("Adding text:" + text);
              }
              if(wildcard.includes("stop listening")){
                Shiny.setInputValue("close_app", true)
                console.log("Stop listening");
              }
            }
          }]);
          artyom.redirectRecognizedTextOutput(function(text, isFinal){
              var sel = document.querySelector("#recognized_text")
              if(isFinal){
                  sel.innerHTML = "";
              }else{
                  sel.innerHTML = text;
              }
          });
          document.addEventListener("DOMContentLoaded", function(){
              artyom.initialize({
                  lang: "en-US",
                  debug: true,
                  continuous: true,
                  listen: true
              });
          });
    ')))

  miniUI::miniPage(
    htmltools::tags$head(
      htmltools::tags$script('window.moveTo(0,0);window.resizeTo(500,250);'),
      htmltools::singleton(htmltools::tags$script(src="//cdn.jsdelivr.net/gh/sdkcarlos/artyom.js@master/build/artyom.window.min.js")),
      htmltools::tags$script('window.artyom = window.artyom || new Artyom();')
    ),
    miniUI::miniContentPanel(
      htmltools::tags$div(htmltools::tags$p("Listening: ", shiny::span(id = "recognized_text"))),
      htmltools::tags$div(
        shiny::textAreaInput(inputId = "listening_text", label = "", value = "", width = "100%", height = "100px", resize = "none"),
        shiny::actionButton("done", "Done")
      )
    ),
    scr
  ) -> ui
  ui |>
    shiny::runGadget(
      server = server,
      viewer = function(url) {
        open_browser(url)
      }
    )
}

open_browser <- function(url, browser = getOption("ask.browser", "chrome")) {
  rlang::arg_match(browser, c("chrome", "safari", "edge"))
  sysname <- Sys.info()[["sysname"]]
  if (sysname == "Darwin") sysname <- "MacOS"
  out <- switch(
    sysname,
    MacOS = open_browser_macos(url),
    Linux = open_browser_linux(url),
    Windows = open_browser_windows(url)
  )
  if (is.null(out)) {
    abort(sprintf("'%s' is not supported for '%s'", browser, sysname))
  }
  out
}

open_browser_macos <- function(url, browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = open_chrome_macos(url),
    safari = open_safari_macos(url)
  )
}

open_browser_windows <- function(url, browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = open_chrome_windows(url),
    edge = open_edge_windows(url)
  )
}

open_browser_linux <- function(url, browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = open_chrome_linux(url),
  )
}

open_chrome_macos <- function(url) {
  command <- sprintf('"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --app="%s"', url)
  system(command)
}

open_safari_macos <- function(url) {
  command <- sprintf('open -a Safari -n "%s"', url)
  system(command)
}

# open_firefox_macos <- function(url) {
#   command <- sprintf('open -a "Firefox" "%s"', url)
#   system(command)
# }

open_chrome_windows <- function(url) {
  command <- sprintf('start chrome --app="%s"', url)
  system(command)
}

open_edge_windows <- function(url) {
  command <- sprintf('start msedge --app="%s"', url)
  system(command)
}

open_chrome_linux <- function(url) {
  command <- sprintf('google-chrome --app="%s" &', url)
  system(command)
}

quit_browser <- function(browser = getOption("ask.browser", "chrome")) {
  rlang::arg_match(browser, c("chrome", "safari", "edge"))
  sysname <- Sys.info()[["sysname"]]
  if (sysname == "Darwin") sysname <- "MacOS"
  out <- switch(
    sysname,
    MacOS = quit_browser_macos(),
    Linux = quit_browser_linux(),
    Windows = quit_browser_windows()
  )
  if (is.null(out)) {
    abort(sprintf("'%s' is not supported for '%s'", browser, sysname))
  }
  out
}

quit_browser_macos <- function(browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = quit_chrome_macos(),
    safari = quit_safari_macos()
  )
}

quit_browser_windows <- function(browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = quit_chrome_windows(),
    edge = quit_edge_windows()
  )
}

quit_browser_linux <- function(browser = getOption("ask.browser", "chrome")) {
  switch(
    browser,
    chrome = quit_chrome_linux(),
  )
}

quit_chrome_macos <- function() {
  system("osascript -e 'tell application \"Google Chrome\" to close (windows where visible is true)'")
}

quit_safari_macos <- function() {
  system("osascript -e 'tell application \"Safari\" to quit'")
}

quit_chrome_windows <- function() {
  command <- 'nircmd win close class active'
  system(command)
}

quit_edge_windows <- function() {
  command <- 'nircmd win close class active'
  system(command)
}

quit_chrome_linux <- function() {
  system("xdotool getactivewindow windowclose")
}

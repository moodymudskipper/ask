rlang::check_installed("shiny")
rlang::check_installed("htmltools")
rlang::check_installed("htmlwidgets")
rlang::check_installed("miniUI")
rlang::check_installed("ask", action = \(pkg, ... ) remotes::install_github("moodymudskipper/ask"))
library(shiny)
library(htmltools)
library(htmlwidgets)
library(miniUI)
library(ask)

askAddin <- \() {
    send_event_from_backend_to_frontend <- function(session, data) {
        print("send_event_from_backend_to_frontend: ")
        print(data)
        session$sendCustomMessage(
            type = data$event,
            message = data
        )
    }
    server <- \(input, output, session) {
        shiny::observeEvent(input$ask, {
            print("input$listening_text")
            print(input$listening_text)
            ret <- ask::ask(input$listening_text, api_key = Sys.getenv("OPENAI_API_KEY"))
            response <- capture.output(str(ret))
            print("response")
            print(response)
            send_event_from_backend_to_frontend(session, data = list(
                event = "ask",
                listening_text = input$listening_text,
                response = response
            ))
        })
    }
    google_chrome <- \(url, browser = getOption("browser"), encodeIfNeeded = FALSE) utils::browseURL(url, browser = "google-chrome", encodeIfNeeded)
    scr <- htmltools::tags$script(htmltools::HTML(htmlwidgets::JS('
          Shiny.addCustomMessageHandler(type = "ask", function(message) {
             response = JSON.stringify(message.response);
             document.querySelector("#response").innerHTML = response;
             Shiny.setInputValue("listening_text", "");
             document.querySelector("#listening_text").innerHTML = "";
          })
          function ask(){
            content = document.querySelector("#listening_text").innerHTML
            Shiny.setInputValue(\"ask\", {"content":  content}, {
                priority: \"event\"
            })
          }
          artyom.addCommands([{
            description:"It will save the text it recognizes.",
            indexes: ["*"],
            smart: true,
            action : function(i, wildcard, sentence){
              var sel = document.querySelector("#listening_text")
              if(wildcard.includes("stop listening")){
                ask("what")
                console.log("Stop listening");
              }
              else if(wildcard.includes("start listening")) {
                Shiny.setInputValue("listening_text", "");
                sel.innerHTML = "";
                console.log("Start listening");
              }
              else if(typeof(wildcard) != "undefined" && wildcard.length > 0) {
                text = sel.innerHTML + "\\n" + wildcard
                Shiny.setInputValue("listening_text", text);
                sel.innerHTML = text;
                console.log("Adding text:" + text);
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
    # print(scr)
    miniUI::miniPage(
        htmltools::singleton(htmltools::tags$head(
            htmltools::tags$script(src="//cdn.jsdelivr.net/gh/sdkcarlos/artyom.js@master/build/artyom.window.min.js"),
            htmltools::tags$script('window.artyom = window.artyom || new Artyom();')
        )),
        miniUI::gadgetTitleBar("Ask"),
        miniUI::miniContentPanel(
            htmltools::tags$div( htmltools::tags$p("Listening: ", span(id = "recognized_text"))),
            htmltools::tags$div(
                shiny::textAreaInput(inputId = "listening_text", label = "Prompt", rows=5, cols=40)
            ),
            htmltools::tags$div(
                tags$button(id = "ask", "Ask", onClick = "ask()")
            ),
            htmltools::tags$div(
                htmltools::tags$strong("Response"),
                htmltools::tags$pre(id = "response")
            ),
        ),
        scr
    ) -> ui
    ui |>
        shiny::runGadget(
            server = server,
            viewer = google_chrome
        )
}

askAddin()

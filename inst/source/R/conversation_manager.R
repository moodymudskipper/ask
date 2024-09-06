conversation_manager <- function() {
  # FIXME: inspect the cache to add more conversations
  if (!length(globals$conversations)) {
    inform("No conversation were started")
    return(invisible(NULL))
  }

  build_choices <- function(conversations) {
    choices <- seq_along(conversations)
    nms <- sapply(globals$conversations, function(convo) {
      question <- convo$prompt[1]
      if (nchar(question) > 60) {
        paste0(substr(question, 1, 57), "...")
      } else {
        question
      }
    })
    nms <- sprintf("%s: %s", choices, nms)
    names(choices) <- nms
    choices
  }

  ui <- shiny::fluidPage(
    style = "margin: 0.5em",
    shiny::fluidRow(
      style = "display: flex; align-items: center;", # Ensure everything is horizontally aligned
      shiny::div(
        style = "flex: 1;",
        shiny::selectInput(
          "conversation",
          "Select Conversation:",
          choices = build_choices(globals$conversations),
          selected = length(globals$conversations),
          width = "100%" # Make the select input take the full available width
        )
      ),
      shiny::div(
        style = "flex: 0 0 auto; margin-left: 1em;",
        shiny::actionButton("pick_button", "Pick", class = "btn-success", title = "return current conversation"),
        shiny::actionButton("drop_button", "Drop", class = "btn-danger", title = "drop from history"),
        shiny::actionButton("close_button", "X", class = "btn-secondary", title = "close app")
      )
    ),
    shiny::fluidRow(
      shiny::uiOutput("convo_ui")
    ),
    shiny::fluidRow(
      style = "margin-top: 1em; display: flex; align-items: center; flex-direction: column;", # Add space before the follow-up section and align items
      shiny::div(
        style = "flex: 1; width: 100%;",
        shiny::textAreaInput(
          "follow_up_text",
          "Follow up:",
          "",
          width = "100%",
          resize = "vertical" # Allow vertical resize only
        )
      ),
      shiny::div(
        style = "flex: 0 0 auto; margin-top: 0em; align-self: flex-start;", # Add margin above the button and left-align it
        shiny::actionButton("follow_up_button", HTML("&#9654;"), class = "btn-primary")  # Arrow pointing to the right
      )
    )
  )

  server <- function(input, output, session) {
    return_value <- shiny::reactiveVal(NULL)
    drop_counter <- shiny::reactiveVal(0)

    conversation <- shiny::reactive({
      drop_counter() # Add this to create reactive dependency
      globals$conversations[[as.numeric(input$conversation)]]
    })

    observeEvent(input$pick_button, {
      shiny::stopApp(conversation())
    })
    observeEvent(input$close_button, {
      shiny::stopApp()
    })

    observeEvent(input$drop_button, {
      globals$conversations <- globals$conversations[-as.numeric(input$conversation)]
      if (length(globals$conversations)) {
        updateSelectInput(
          session,
          "conversation",
          choices = build_choices(globals$conversations),
          selected = min(as.numeric(input$conversation), length(globals$conversations))
        )
        drop_counter(drop_counter() + 1) # Increment drop_counter to trigger UI refresh
      } else {
        inform("No conversation were started")
        shiny::stopApp()
      }
    })

    output$convo_ui <- shiny::renderUI({
      convo <- conversation()
      rmd <- build_convo_rmd(convo)
      html <- tempfile(fileext = ".html")
      rmarkdown::render(rmd, output_file = html, quiet = TRUE)
      suppressWarnings(htmltools::includeHTML(html))
    })

    observeEvent(input$follow_up_button, {
      req(input$follow_up_text)
      convo <- follow_up(prompt = input$follow_up_text, conversation = conversation())
      globals$conversations[[as.numeric(input$conversation)]] <- convo
      drop_counter(drop_counter() + 1) # Increment to trigger UI refresh
      updateSelectInput(
        session, "conversation",
        choices = build_choices(globals$conversations),
        selected = as.numeric(input$conversation)
      )
    })
  }

  shiny::runApp(
    shiny::shinyApp(ui, server),
    launch.browser = shiny::paneViewer(),
    quiet = TRUE
  )
}

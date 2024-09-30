#' Conversation Manager
#'
#' A small shiny app to manage all conversations. Whenever an `ask*()` function is used (not just `ask()`), a new conversation
#' is recorded and can be accessed through the conversation manager. There we
#' can expand or remove conversations, or even start a new one from scratch.
#' When you pick a conversation you leave the shiny app and the chosen conversation is
#' printed in the viewer and stored as `last_conversation()` so you can use
#' `follow_up()` or `again()` to expand it..
#'
#' @param conversations
#'
#' @return
#' @export
#'
#' @examples
conversation_manager <- function() {
  # UI =========================================================================

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
    shinyjs::useShinyjs(),
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
        shiny::actionButton("new_button", "New", class = "btn-info", title = "start a new conversation"),
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
        shiny::uiOutput("text_area_ui")
      ),
      shiny::div(
        style = "flex: 0 0 auto; margin-top: 0em; align-self: flex-start;", # Add margin above the button and left-align it
        shiny::uiOutput("action_button_ui")
      )
    )
  )

  # SERVER =====================================================================

  server <- function(input, output, session) {
    return_value <- shiny::reactiveVal(NULL)
    drop_counter <- shiny::reactiveVal(0)
    new_convo_active <- shiny::reactiveVal(length(globals$conversations) == 0)

    conversation <- shiny::reactive({
      if (!length(globals$conversations)) {
        return(NULL)
      }
      drop_counter() # Add this to create reactive dependency
      globals$conversations[[min(as.numeric(input$conversation), length(globals$conversations))]]
    })

    # Top right buttons --------------------------------------------------------

    # NEW
    observeEvent(input$new_button, {
      new_convo_active(TRUE)
    })

    observeEvent(req(new_convo_active()), {
      shinyjs::disable("new_button")
      shinyjs::disable("pick_button")
      choices <- length(globals$conversations) + 1
      names(choices) <- sprintf("%s: NEW", length(globals$conversations) + 1)
      updateSelectInput(
        session, "conversation",
        choices = choices
      )
    })

    # PICK
    observeEvent(input$pick_button, {
      shiny::stopApp(conversation())
    })

    # CLOSE
    observeEvent(input$close_button, {
      shiny::stopApp()
    })

    # DROP
    observeEvent(input$drop_button, {
      if (new_convo_active()) {
        new_convo_active(FALSE)
        updateSelectInput(
          session,
          "conversation",
          choices = build_choices(globals$conversations),
          selected = min(as.numeric(input$conversation), length(globals$conversations))
        )
        shinyjs::enable("new_button")
        shinyjs::enable("pick_button")
        return(NULL)
      }

      globals$conversations <- globals$conversations[-as.numeric(input$conversation)]
      if (length(globals$conversations)) {
        updateSelectInput(
          session,
          "conversation",
          choices = build_choices(globals$conversations),
          selected = min(as.numeric(input$conversation), length(globals$conversations))
        )
        drop_counter(drop_counter() + 1) # trigger UI refresh
      } else {
        new_convo_active(TRUE)
      }
    })

    # conversation -------------------------------------------------------------

    output$convo_ui <- shiny::renderUI({
      if (new_convo_active()) {
        return(NULL)
      }

      convo <- conversation()
      if (is.null(convo)) return(NULL)
      rmd <- build_convo_rmd(convo)
      html <- tempfile(fileext = ".html")
      rmarkdown::render(rmd, output_file = html, quiet = TRUE)
      suppressWarnings(htmltools::includeHTML(html))
    })

    # ask/follow up text box ---------------------------------------------------

    output$text_area_ui <- shiny::renderUI({
      if (new_convo_active()) {
        shiny::textAreaInput(
          "ask_text",
          "Ask:",
          "",
          width = "100%",
          resize = "vertical" # Allow vertical resize only
        )
      } else {
        shiny::textAreaInput(
          "follow_up_text",
          "Follow up:",
          "",
          width = "100%",
          resize = "vertical" # Allow vertical resize only
        )
      }
    })

    # ask/follow up buttons ----------------------------------------------------

    output$action_button_ui <- shiny::renderUI({
      if (new_convo_active()) {
        shiny::actionButton("ask_button", HTML("&#9654;"), class = "btn-primary")
      } else {
        shiny::actionButton("follow_up_button", HTML("&#9654;"), class = "btn-primary")
      }
    })

    observeEvent(input$ask_button, {
      req(input$ask_text)
      convo <- ask(prompt = input$ask_text)
      updateSelectInput(
        session,
        "conversation",
        choices = build_choices(globals$conversations),
        selected = length(globals$conversations)
      )
      new_convo_active(FALSE)
      shinyjs::enable("new_button")
      shinyjs::enable("pick_button")
      drop_counter(drop_counter() + 1) # trigger UI refresh
    })

    observeEvent(input$follow_up_button, {
      req(input$follow_up_text)
      convo <- follow_up(prompt = input$follow_up_text, conversation = conversation())
      globals$conversations[[as.numeric(input$conversation)]] <- convo
      drop_counter(drop_counter() + 1) # trigger UI refresh
      updateSelectInput(
        session, "conversation",
        choices = build_choices(globals$conversations),
        selected = as.numeric(input$conversation)
      )
      shiny::updateTextAreaInput(session, "follow_up_text", value = "")
    })
  }

  # run ------------------------------------------------------------------------

  shiny::runApp(
    shiny::shinyApp(ui, server),
    launch.browser = shiny::paneViewer(),
    quiet = TRUE
  )
}

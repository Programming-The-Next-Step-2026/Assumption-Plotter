#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(AssumptionPlotter)
library(datasets)
library(bslib)
library(DT)
library(sass)

# Define UI for application that draws a histogram
ui <- page_navbar(
  # id = "main_page",
  # title = HTML("
  #   <b>AssumptionPlotter</b>
  #              "),
  id = "main_page",

  title = tags$span(
    tags$img(src = "logo.png", height = "30px"),
    tags$b("AssumptionPlotter")
  ),
  bg = "red",
  inverse = TRUE,
  fillable = TRUE,
  theme = bs_theme(
    base_font = font_google("Merriweather")
  ),
  nav_panel(title = "Start",
            p(HTML("

              <p> <b>Welcome to AssumptionPlotter!</b></p>

              <p>For now, this package aims to give you an intuition for whether
              a selected set of statistical models can account for what you want
              to observe in your <i>intensive longitudinal data</i>.</p>

              <p>Thus, this package is useful for anyone conducting <b style='color:blue;'>EMA/ESM</b>
              research.</p>

              <p>The package includes the following steps:</p>
              <ol>
                <li>Choose your dataset</li>
                <li>Plot your dataset</li>
                <li>Check model assumptions</li>
              </ol>

              <p>Unfortunately for now, you cannot use your own data.</p>
              "

                   )),
            actionButton(
              inputId= "go_data",
              label= "Choose your dataset"
            )

  ),
  nav_panel(title = "Data",
            p(""),
            radioButtons(
              "data_pick",
              "Dataset",

              choices = c(
                "Datasets from openESM" = "builtin",
                "Upload your own data" = "upload"
              )
            ),

            uiOutput("data_select"),
            actionButton(
              inputId= "go_plot",
              label= "Plot your data"
            ),
            DT::DTOutput("chosenData")
            ),
  nav_panel(title = "Plot",
            p("Data visualization"),
            layout_sidebar(
              sidebar = sidebar(HTML("
                                     <b>Options</b>
                                     <p>hello</p>
                                     ")),
              # uiOutput("summary_box"),
              navset_card_tab(
                nav_panel(
                  title= "Plot",
                  card(
                    card_header("Assumption Plot"),
                    plotOutput("test_plot")
                  )
                ),
                nav_panel(
                  title = "Checks",
                  p(HTML("
                         <ol>
                         <li>hello </li>
                         </ol>"))
                )
              ),


            )
            ),
  nav_spacer(),
  nav_menu(
    title = "More",
    align = "right",
    nav_item(tags$a("EMA Datasets", href = "https://openesmdata.org/datasets/",
                    target = "_blank")),
    nav_item(tags$a("Github", href = "https://github.com/Programming-The-Next-Step-2026/Assumption-Plotter",
                    target = "_blank"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  output$test_plot <- renderPlot({

    data <- switch(
      input$dataset,
      mtcars=mtcars,
      iris=iris,
      cars=cars
    )
    plot(data[,1],data[,2])
    })

  ##### ACTION BUTTONS #####
  observeEvent(input$go_plot, {

    updateNavbarPage(
    session,
    "main_page",
    selected = "Plot"
    )
  })

  observeEvent(input$go_data, {

    updateNavbarPage(
    session,
    "main_page",
    selected = "Data"
    )
  })

  output$summary_box <- renderUI({

    data <- switch(
      input$dataset,
      mtcars = mtcars,
      iris = iris,
      cars = cars
    )

    n_cols <- ncol(data)
    n_rows <- nrow(data)
    n_na <- sum(is.na(data))

    value_box(
      title = paste0("Dataset summary: ", input$dataset),

      value = paste0(n_cols, " cols • ", n_rows, " rows"),

      showcase = bsicons::bs_icon("bar-chart"),

      theme = value_box_theme(bg="black", fg="white"),

      footer = paste("Total NA values:", n_na)
    )
  })


  ##### DATA PAGE #####

  output$chosenData <- DT::renderDT({

    data <- if (input$data_pick == "builtin") {

      switch(
        input$dataset,
        mtcars = mtcars,
        iris = iris,
        cars = cars
      )

    } else {

      req(input$file)

      read.csv(input$file$datapath)
    }

    DT::datatable(
      head(data),
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  output$data_select <- renderUI({

    if (input$data_pick == "builtin") {

      radioButtons(
        "dataset",
        "Choose your dataset",

        choiceNames = list(

          card(card_header(tags$a("mtcars", href="https://openesmdata.org/datasets/",
                                  target = "_blank")), p("Motor Trend cars")),
          card(card_header("iris"), p("Fisher flowers")),
          card(card_header("cars"), p("Base R cars dataset"))
        ),

        choiceValues = c("mtcars", "iris", "cars"),
        inline = TRUE
      )

    } else {

      tagList(

        fileInput(
          "file",
          "You can only upload a CSV file",
          accept = c(".csv")
        ),

        p(HTML("<p> Your file should needs to meet at least the following criteria
          for the app to run smoothly:</p>
          <ol>
          <li>The  </li>

          </ol>
          first row = column names)"))
      )

    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)

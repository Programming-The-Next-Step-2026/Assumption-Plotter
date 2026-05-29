ui <- bslib::page_navbar(
  id = "main_page",

  title = tags$span(
    tags$img(src = "logo.png", height = "30px"),
    tags$b("AssumptionPlotter")
  ),
  bg = "#b22222",
  inverse = TRUE,
  fillable = TRUE,
  theme = bslib::bs_theme(
    base_font = bslib::font_google("Merriweather")
  ),
  bslib::nav_panel(title = "Start",
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
  bslib::nav_panel(title = "Data",
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
  bslib::nav_panel(title = "Plot",
            p("Data visualization"),
            bslib::layout_sidebar(
              sidebar = bslib::sidebar(

                HTML("<b>Options</b>"),

                # ----------------------------
                # 1. Participant
                # ----------------------------
                uiOutput("participant_ui"),

                # ----------------------------
                # 2. Variables (dynamic)
                # ----------------------------
                uiOutput("variable_ui"),

                # ----------------------------
                # 3. Trend line
                # ----------------------------
                checkboxInput(
                  "add_trend",
                  "Show trend line",
                  value = FALSE
                ),

                selectInput(
                  "trend_type",
                  "Trend type",
                  choices = c("lm", "loess"),
                  selected = "lm"
                ),

                # ----------------------------
                # 4. Imputation
                # ----------------------------
                checkboxInput(
                  "impute_toggle",
                  "Impute missing data",
                  value = FALSE
                ),

                conditionalPanel(
                  condition = "input.impute_toggle == true",

                  selectInput(
                    "impute_method",
                    "Imputation method",
                    choices = c("mean", "mode"),
                    selected = "mean"
                  )
                ),

                hr(),

                # ----------------------------
                # 5. Theme
                # ----------------------------
                selectInput(
                  "theme_choice",
                  "Theme",
                  choices = c("classic", "minimal", "bw"),
                  selected = "classic"
                ),

                # ----------------------------
                # 6. Palette
                # ----------------------------
                textInput(
                  "palette",
                  "Palette (hex colors, comma-separated)",
                  placeholder = "#1b9e77,#d95f02,#7570b3"
                )

              ),
              # uiOutput("summary_box"),
              bslib::navset_card_tab(
                bslib::nav_panel(
                  title= "Plot",
                  bslib::card(
                    bslib::card_header("Assumption Plot"),
                    plotOutput("test_plot"),
                    # plotly::plotlyOutput("test_plot", height = "600px")
                  )
                ),
                bslib::nav_panel(
                  title = "Checks",
                  p(HTML("
                         <ol>
                         <li>Is there variability?</li>
                         <li>Is there a trend?</li>
                         </ol>"))
                )
              ),
              actionButton(
                inputId= "go_back",
                label= "Back to data"
              )


            )
            ),
  bslib::nav_spacer(),
  bslib::nav_menu(
    title = "More",
    align = "right",
    bslib::nav_item(tags$a("EMA Datasets", href = "https://openesmdata.org/datasets/",
                    target = "_blank")),
    bslib::nav_item(tags$a("Github", href = "https://github.com/Programming-The-Next-Step-2026/Assumption-Plotter",
                    target = "_blank"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {

  active_data <- reactiveVal(NULL)
  active_dataset_name <- reactiveVal(NULL)

  plot_data_reactive <- reactive({

    req(input$dataset)

    df <- switch(
      input$dataset,
      menghini_2023 = AssumptionPlotter::menghini_2023,
      geschwind_2013 = AssumptionPlotter::geschwind_2013,
      contreras_2020 = AssumptionPlotter::contreras_2020
    )

    missing <- switch(
      input$dataset,
      menghini_2023 = AssumptionPlotter::missing_menghini_2023,
      geschwind_2013 = AssumptionPlotter::missing_geschwind_2013,
      contreras_2020 = AssumptionPlotter::missing_contreras_2020
    )

    df2 <- reconstruct_data(df, missing)

    df2

  })

  output$participant_ui <- renderUI({

    req(plot_data_reactive())

    selectInput(
      "participant",
      "Participant",
      choices = unique(plot_data_reactive()$id)
    )

  })

  output$variable_ui <- renderUI({

    df <- plot_data_reactive()

    vars <- grep("^var_", names(df), value = TRUE)

    checkboxGroupInput(
      "variables",
      "Variables",
      choices = vars,
      selected = vars
    )

  })

  output$test_plot <- renderPlot({

    req(plot_data_reactive())

    # parse palette input (comma-separated hex -> character vector)
    palette_vec <- NULL
    if (!is.null(input$palette) && nzchar(trimws(input$palette))) {
      palette_vec <- strsplit(input$palette, ",")[[1]]
      palette_vec <- trimws(palette_vec)
    }



    plot_ild(
      df = plot_data_reactive(),
      participant = input$participant,
      variables = input$variables,
      expected_days = switch(input$dataset,
                             menghini_2023 = 3,
                             geschwind_2013 = 10,
                             contreras_2020 = 7
      ),
      beeps_per_day = switch(input$dataset,
                             menghini_2023 = 7,
                             geschwind_2013 = 10,
                             contreras_2020 = 10
      ),
      include_na = NULL,
      impute = if (isTRUE(input$impute_toggle)) input$impute_method else "none",
      add_trend = input$add_trend,
      trend_type = input$trend_type,
      theme_choice = input$theme_choice,
      palette = if (length(palette_vec) > 0) palette_vec else NULL
    )

  })

  # output$test_plot <- plotly::renderPlotly({
  #   req(plot_data_reactive())
  #   req(input$participant)
  #
  #   # ensure variables exist and at least one is selected
  #   vars_selected <- input$variables
  #   vars_available <- grep("^var_", names(plot_data_reactive()), value = TRUE)
  #   vars <- intersect(vars_selected %||% character(0), vars_available)
  #   shiny::validate(shiny::need(length(vars) > 0, "Please select at least one variable that exists in this dataset."))
  #
  #
  #
  #   # parse palette input (comma-separated hex -> character vector)
  #   palette_vec <- NULL
  #   if (!is.null(input$palette) &&
  #       nzchar(trimws(input$palette))) {
  #     palette_vec <- strsplit(input$palette, ",")[[1]]
  #     palette_vec <- trimws(palette_vec)
  #   }
  #
  #   p <- plot_ild(
  #     df = plot_data_reactive(),
  #     participant = input$participant,
  #     variables = vars,
  #     expected_days = switch(
  #       input$dataset,
  #       menghini_2023 = 3,
  #       geschwind_2013 = 10,
  #       contreras_2020 = 7
  #     ),
  #     beeps_per_day = switch(
  #       input$dataset,
  #       menghini_2023 = 7,
  #       geschwind_2013 = 10,
  #       contreras_2020 = 10
  #     ),
  #     include_na = NULL,
  #     impute = if (isTRUE(input$impute_toggle)) input$impute_method else "none",
  #     add_trend = input$add_trend,
  #     trend_type = input$trend_type,
  #     theme_choice = input$theme_choice,
  #     palette = if (length(palette_vec) > 0) palette_vec else NULL
  #   )
  #
  #   # convert to plotly, enable range slider and usual zoom/pan tools
  #   plotly::ggplotly(p) %>%
  #     plotly::layout(xaxis = list(rangeslider = list(visible = TRUE)), dragmode = "zoom") %>%
  #     plotly::config(displayModeBar = TRUE)
  #
  # })

  ##### ACTION BUTTONS #####
  observeEvent(input$go_plot, {

    req(input$dataset)

    data <- switch(
      input$dataset,
      menghini_2023 = AssumptionPlotter::menghini_2023,
      geschwind_2013 = AssumptionPlotter::geschwind_2013,
      contreras_2020 = AssumptionPlotter::contreras_2020
    )

    active_data(data)
    active_dataset_name(input$dataset)

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

  observeEvent(input$go_back, {

    updateNavbarPage(
    session,
    "main_page",
    selected = "Data"
    )
  })



  # value_box remove?
  # output$summary_box <- renderUI({
  #
  #   data <- switch(
  #     input$dataset,
  #     menghini_2023 = AssumptionPlotter::menghini_2023,
  #     geschwind_2013 = AssumptionPlotter::geschwind_2013,
  #     contreras_2020 = AssumptionPlotter::contreras_2020
  #   )
  #
  #   n_cols <- ncol(data)
  #   n_rows <- nrow(data)
  #   n_na <- sum(is.na(data))
  #
  #   bslib::value_box(
  #     title = paste0("Dataset summary: ", input$dataset),
  #
  #     value = paste0(n_cols, " cols • ", n_rows, " rows"),
  #
  #     theme = value_box_theme(bg="black", fg="white"),
  #
  #     footer = paste("Total NA values:", n_na)
  #   )
  # })


  ##### DATA PAGE #####

  output$chosenData <- DT::renderDT({

    data <- if (input$data_pick == "builtin") {

      switch(
        input$dataset,
        menghini_2023 = AssumptionPlotter::menghini_2023,
        geschwind_2013 = AssumptionPlotter::geschwind_2013,
        contreras_2020 = AssumptionPlotter::contreras_2020
      )

    } else {

      req(input$file)

      read.csv(input$file$datapath)
    }

    DT::datatable(
      head(data,10),
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  output$data_select <- renderUI({

    if (input$data_pick == "builtin") {

      radioButtons(
        "dataset",
        "Choose your dataset",

        choiceNames = list(

          bslib::card(max_height = 200,
                      full_screen = TRUE,
            bslib::card_header(tags$a("menghini_2023",
                                                href="https://openesmdata.org/datasets/0022_menghini/",
                                                target = "_blank")),
                      p(HTML("<b>Topic</b>: workplace stress
                             <br><b>Participants</b>: 139
                             <br><b>Days</b>: 3
                             <br><b>Beeps</b>: 7
                             <br><b>Variables (16)</b>: well, discontent,
                             <br>state, tense, calm, placid, awake,
                             <br>energyless, rested,
                             <br>too_much, work_fast, multitasking,
                             <br>hard_work,
                             <br>change_task, decide_task, schedule_task
                             "))),
          bslib::card(max_height = 200,
                      full_screen = TRUE,
            bslib::card_header(tags$a("geschwind_2013",
                                                href="https://openesmdata.org/datasets/0010_geschwind/",
                                                target = "_blank")),
                      p(HTML("<b>Topic</b>: depression
                             <br><b>Participants</b>: 129
                             <br><b>Days</b>: 10 (only exam week)
                             <br><b>Beeps</b>: 10
                             <br><b>Variables (6)</b>: cheerful,
                             <br>pleasantness, worried, fearful, sad,
                             <br>relaxed
                             "))),
          bslib::card(max_height = 200,
                      full_screen = TRUE,
            bslib::card_header(tags$a("contreras_2020",
                                                href="https://openesmdata.org/datasets/0028_contreras/",
                                                target = "_blank")),
                      p(HTML("<b>Topic</b>: paranoia
                             <br><b>Participants</b>: 23
                             <br><b>Days</b>: 7
                             <br><b>Beeps</b>: 10
                             <br><b>Variables (8)</b>: sad, useless,
                             <br>manage_well,no_trust, harm, criticism,
                             <br>others
                             ")))
        ),

        choiceValues = c("menghini_2023", "geschwind_2013", "contreras_2020"),
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
          <li>Have the exact same column format with variables of interest having the prescript 'var_'</li>
          <li>The data should include all days and beeps that should have been included (include them as NA's)</li>

          </ol>
          first row = column names)"))
      )

    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)

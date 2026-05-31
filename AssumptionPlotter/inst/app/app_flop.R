#############################################################################
#                            OLD  USER INTERFACE                               #
#############################################################################


# Using page_navbar because it looks nicer
ui <- bslib::page_navbar(
  id = "main_page",
  title = tags$span(
    tags$img(src = "logo.png", height = "30px"), # logo is CC0
    tags$b("AssumptionPlotter")),
  bg = "#b22222",
  fillable = TRUE,

  # Edit font style
  theme = bslib::bs_theme(
    base_font = bslib::font_google("Merriweather")
  ),


  # First tab: Start page
  bslib::nav_panel(title = "Start", # Name of tab

            # Introduction page message
            p(HTML("

              <p> <b>Welcome to AssumptionPlotter!</b></p>

              <p>For now, this package aims to give you an intuition for whether
              a selected set of statistical models can account for what you want
              to observe in your <i>intensive longitudinal data</i>.</p>

              <p>Thus, this package is useful for anyone conducting
              <b style='color:blue;'>EMA/ESM</b> research.</p>

              <p>The package includes the following steps:</p>
              <ol>
                <li>Choose your dataset</li>
                <li>Plot your dataset</li>
                <li>Check model assumptions</li>
              </ol>

              <p>Unfortunately for now, you cannot use your own data.</p>
              "

                   )),

            # Button to easily transport you to the data page
            actionButton(
              inputId= "go_data",
              label= "Choose your dataset"
            )

  ),


  # Second tab: Data page
  bslib::nav_panel(title = "Data",

                   # Choose what data you want to use
                   radioButtons(
                     inputId = "data_pick",
                     label = "Dataset",
                     choices = c(
                       "Datasets from openESM" = "builtin",
                       "Upload your own data" = "upload"
                     ),
                     selected = "builtin"
                   ),

                   # In server, UI will change depending on data_pick choice
                   uiOutput("data_select"),

                   # Button to transport to plot tab
                   actionButton(
                     inputId = "go_plot",
                     label = "Plot your data"),

                   # Show table of chosen dataset
                   DT::DTOutput("chosenData") # Defined in server
            ),


  # Third tab: Plot tab
  bslib::nav_panel(title = "Plot",

                   # Create a layout where there is a sidebar and main content
                   bslib::layout_sidebar(

                     # Edit the sidebar
                     sidebar = bslib::sidebar(
                       HTML("<b>Options</b>"),

                       # Plotting options

                       # ## Participant defined in server
                       # uiOutput("participant_ui"),
                       #
                       # ## Variables defined in server
                       # uiOutput("variable_ui"),
                       #
                       # ### Option to select all variables
                       # actionButton(
                       #   inputId = "all_vars",
                       #   label = "Select all"),
                       #
                       # ### Option to deselect all variables
                       # actionButton(
                       #   inputId = "clear_vars",
                       #   label = "Deselect all"),
                       #
                       # ## Trend line: create input for assumption_plot()
                       # checkboxInput(
                       #   inputId = "add_trend",
                       #   label = "Show trend line",
                       #   value = FALSE), # default

                       # ### If trend line included, what kind
                       # conditionalPanel(
                       #   condition = "input.add_trend == true",
                       #   selectInput(
                       #     inputId = "trend_type",
                       #     label = "Trend line type",
                       #     choices = c("lm", "loess"),
                       #     selected = "lm")),
                       #
                       # ## Only show imputation options if you want to impute
                       # ### (This is made a bit clumsily, might make sense to
                       # ### change this in both the plotting function and here.
                       # ### Currently an extra step needs to be taken in the server.)
                       # checkboxInput(
                       #   inputId = "impute_toggle",
                       #   label = "Impute missing data",
                       #   value = FALSE), # default
                       #
                       # conditionalPanel(
                       #   condition = "input.impute_toggle == true",
                       #
                       #   selectInput(
                       #     inputId = "impute_method",
                       #     label = "Imputation method",
                       #     choices = c("mean", "mode"),
                       #     selected = "mean")),

                       hr(), # add horizontal line

                       # Day label and lines
                       ## Label
                       checkboxInput(
                         inputId = "day_label",
                         label = "Include day labels",
                         value = TRUE), # default

                       ## Lines
                       checkboxInput(
                         inputId = "day_lines",
                         label = "Include day lines",
                         value = TRUE), # default

                       ## Edit colors?
                       checkboxInput(
                         inputId = "edit_palette",
                         label = "Edit plot colors",
                         value = FALSE),

                       conditionalPanel(
                         condition = "input.edit_palette == true",

                         # Choose which theme
                         selectInput(
                           inputId = "palette_option",
                           label = "Choose palette",
                           choices = grDevices::hcl.pals(),
                           selected = "Zissou 1")),

                       ## Choose theme
                       selectInput(
                         inputId = "theme_choice",
                         label = "Theme",
                         choices = c("classic", "minimal", "bw", "void"),
                         selected = "classic" ),

                       # Choose font
                       selectInput(
                         inputId = "text_font",
                         label = "Font family",
                         choices = c("sans", "serif", "mono"),
                         selected = "sans"),

                       # Edit font sizes
                       ## Axis
                       sliderInput(
                         inputId = "axis_size",
                         label = "Axis text size",
                         min = 5,
                         max = 30,
                         value = 12),

                       ## Legend
                       sliderInput(
                         inputId = "legend_size",
                         label = "Legend text size",
                         min = 5,
                         max = 30,
                         value = 12)

                     ), # End of options


                     # Create a card with tabs next to sidebar
                     bslib::navset_card_tab(

                       # Plot tab
                       bslib::nav_panel(title = "Assumption Plot",
                                        # plotOutput("assumption_plot")
                       ),

                       # Summary tab
                       bslib::nav_panel(title = "Summary",
                                        HTML("
                                 <b>Reminders of what to check for in 'Assumption Plot':</b>
                                 <ol>
                                 <li>Do the variables show variability?</li>
                                 <li>Are the measurement points equidistant?</li>
                                 <li>Does the data remain stationary?</li>
                                 </ol>
                                             "),
                                        HTML("
                                             <b>Ratio of Missing Data:</b>
                                             ")
                                      #   ,
                                      #
                                      #   # Choose whether to plot all
                                      #   checkboxInput(
                                      #     inputId = "plot_all",
                                      #     label = "Show missing values of full dataset",
                                      #     value = FALSE),
                                      #
                                      #   # Render Plots
                                      #   bslib::layout_columns(
                                      #     plotOutput("pie_chart"),
                                      #     plotOutput("bar_chart"))
                                      #
                                      )
                     ),

                     # Navigate back to data tab
                     actionButton(
                       inputId = "go_back",
                       label = "Back to data")
                   )
  ),

  # Navigation bar
  bslib::nav_spacer(), # space between tabs and "more" menu

  # Menu bar with aditional sources
  bslib::nav_menu(
    title = "More",
    align = "right",
    bslib::nav_item(
      tags$a("openESM",
             href = "https://openesmdata.org/datasets/",
             target = "_blank") # Creates a new tab when you navigate
    ),
    bslib::nav_item(
      tags$a("Github",
             href = "https://github.com/Programming-The-Next-Step-2026/Assumption-Plotter",
             target = "_blank")
    )
  )
)



#############################################################################
#                          OLD        SERVER                                   #
#############################################################################

server <- function(input, output, session) {

  # To data tab from start tab
  observeEvent(input$go_data, {

    updateNavbarPage(
      session,
      "main_page",
      selected = "Data"
    )
  })

  # Update UI of data tab depending on selection
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
        selected = "menghini_2023",
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

  # Make data reactive to what dataset has been chosen
  plot_data_reactive <- reactive({

    req(input$data_pick)

    df <-
      if (input$data_pick == "builtin") {

        req(input$dataset)
        switch(
          input$dataset,
          menghini_2023 = AssumptionPlotter::menghini_2023,
          geschwind_2013 = AssumptionPlotter::geschwind_2013,
          contreras_2020 = AssumptionPlotter::contreras_2020
        )

      } else {
        req(input$file)

        readr::read_csv(input$file$datapath)
      }

    df

  })


  # Create table
  output$chosenData <- DT::renderDT({

    req(plot_data_reactive())

    df <- plot_data_reactive()

    DT::datatable(
      head(df,nrow(df)),
      options = list(pageLength = 5, scrollX = TRUE)
    )
  })

  # To plot tab from data tab
  observeEvent(input$go_plot, {

    # req(plot_data_reactive())

    updateNavbarPage(
      session,
      "main_page",
      selected = "Plot"
    )

  })


  # Plotting options
  ## Choose participant
  output$participant_ui <- renderUI({

    # req(plot_data_reactive())

    df <- plot_data_reactive()

    selectInput(
      "participant", # selection can be accesses through input$participant
      "Participant",
      choices = unique(df$id), # shows all participant
      selected = unique(df$id)[1]
    )

  })


  # Copilot suggested code for debugging why option sidebar isn't showing up
  # output$participant_ui <- renderUI({
  #     df <- tryCatch(plot_data_reactive(), error = function(e) NULL)
  #     choices <- if (!is.null(df)) unique(df$id) else character(0)
  #     selectInput(
  #         "participant",
  #         "Participant",
  #         choices = choices,
  #         selected = if (length(choices)) choices[[1]] else NULL,
  #         multiple = FALSE
  #       )
    # })

  ## Choose variables
  output$variable_ui <- renderUI({

    df <- plot_data_reactive()

    vars <- names(df)[!names(df) %in% c("id", "day", "beep", "missing")]

    checkboxGroupInput( # Check off the ones you want to see
      "variables",
      "Variables",
      choices = vars,
      selected = vars
    )

  })

  # Copilot suggested code for debugging why option sidebar isn't showing up
  # output$variable_ui <- renderUI({
  #     df <- tryCatch(plot_data_reactive(), error = function(e) NULL)
  #     vars <- if (!is.null(df)) names(df)[!names(df) %in% c("id", "day", "beep", "missing")] else character(0)
  #     checkboxGroupInput(
  #         "variables",
  #         "Variables",
  #         choices = vars,
  #         selected = if (length(vars)) vars else character(0)
  #       )
    # })

  ### Option to deselect all variables
  ### Might cause problems for rendering plot
  observeEvent(input$clear_vars, {
    updateCheckboxGroupInput(
      session,
      "variables",
      selected = character(0)
    )
  })

  ### Option to select all variables
  ### Might cause problems for rendering plot
  observeEvent(input$all_vars, {

    # req(plot_data_reactive())

    df <- plot_data_reactive()

    vars <- names(df)[!names(df) %in% c("id", "day", "beep", "missing")]

    updateCheckboxGroupInput(
      session,
      "variables",
      selected = vars
    )

    # Copilot suggested code for debugging why option sidebar isn't showing up
      # df <- tryCatch(plot_data_reactive(), error = function(e) NULL)
      # vars <- if (!is.null(df)) names(df)[!names(df) %in% c("id", "day", "beep", "missing")] else character(0)
      # if (length(vars)) {
      #     updateCheckboxGroupInput(session, "variables", selected = vars)
      #   } else {
      #       updateCheckboxGroupInput(session, "variables", selected = character(0))
      #     }
  })


  # Create Assumption plot
  # output$assumption_plot <- renderPlot({
  #
  #   # req(plot_data_reactive())
  #   req(input$participant)
  #
  #   df <- plot_data_reactive()
  #
  #
  #   assumption_plot(
  #     df = df,
  #     participant = input$participant,
  #     variables = input$variables,
  #     expected_days = max(df$day),
  #     beeps_per_day = max(df$beep),
  #     include_day = input$day_label,
  #     include_day_line = input$day_lines,
  #     impute = if (isTRUE(input$impute_toggle)) input$impute_method else "none",
  #     add_trend = input$add_trend,
  #     trend_type = input$trend_type,
  #     theme_choice = input$theme_choice,
  #     palette = ifelse(!input$edit_palette, "none","custom"),
  #     palette_option = input$palette_option,
  #     text_font = input$text_font,
  #     axis_text_size = input$axis_size,
  #     legend_text_size = input$legend_size
  #   )
  #
  # })


  # # Create pie chart of missing values
  # output$pie_chart <- renderPlot({
  #
  #   # req(plot_data_reactive())
  #   req(input$participant)
  #
  #   df <- plot_data_reactive()
  #
  #   pie_bar_chart(
  #     df = df,
  #     participant = input$participant,
  #     type = "pie",
  #     plot_all = input$plot_all,
  #     text_font = input$text_font,
  #     axis_text_size = input$axis_size,
  #     legend_text_size = input$legend_size,
  #     theme_choice = input$theme_choice
  #   )
  #
  # })
  #
  #
  # # Create bar chart of missing values
  # output$bar_chart <- renderPlot({
  #
  #   # req(plot_data_reactive())
  #   req(input$participant)
  #
  #   df <- plot_data_reactive()
  #
  #   pie_bar_chart(
  #     df = df,
  #     participant = input$participant,
  #     type = "bar",
  #     plot_all = input$plot_all,
  #     text_font = input$text_font,
  #     axis_text_size = input$axis_size,
  #     legend_text_size = input$legend_size,
  #     theme_choice = input$theme_choice
  #   )
  #
  # })

  # To data from plot tab
  observeEvent(input$go_back, {

    updateNavbarPage(
    session,
    "main_page",
    selected = "Data"
    )
  })

}

# Run the application
shinyApp(ui = ui, server = server)

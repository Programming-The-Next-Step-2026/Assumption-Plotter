#############################################################################
#                              USER INTERFACE                               #
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


  bslib::nav_panel(title = "Start",
                   HTML("
              <p> <b>Welcome to AssumptionPlotter!</b></p>

              <p>For now, this package allows you to visually inspect your
              <u>intensive longitudinal data</u>.</p>

              <p>Thus, this package is useful for anyone conducting
              <b style='color:#b22222;'>EMA/ESM</b> research.</p>

              <p>The package includes the following functions:</p>
              <ol>
                <li>Choose your EMA dataset.</li>
                <li>Plot your EMA dataset per participant.</li>
                <li>See overview of missing data.</li>
              </ol>

              <p>While the package aims to account for some errors in data
              frame formatting, it is still not guaranteed that all data files
              will work.</p>"),

                   tags$p("The package was developed with datasets from",
                          tags$a("openESM",
                                 href = "https://openesmdata.org/datasets/",
                                 target = "_blank"), # Creates a new tab when
                          # you navigate. But when running app in RStudio, it
                          # also opens a blank window. Doesn't happen when ran
                          # from browser.

                          "in mind.")

                        ,
                   # Button to easily transport you to the data page
                   actionButton(
                     inputId= "go_data",
                     label= "Choose your dataset")

                   ), # End start page



  bslib::nav_panel(title = "Data",
                   # Choose what data you want to use
                   radioButtons(
                     inputId = "data_pick",
                     label = "Dataset (note that naviagting between
                                  options will reset filled in information)",
                     choices = c(
                       "Built in datasets from openESM" = "builtin",
                       "Upload your own data" = "upload",
                       "Zenodo link of .tsv file" = "zenodo"
                     ),
                     selected = "builtin",
                     width = "100%"
                   ),

                   # In server, UI will change depending on data_pick choice
                   uiOutput("data_select"),

                   # Button to transport to plot tab
                   actionButton(
                     inputId = "go_plot",
                     label = "Plot your data"),

                   # Show table of chosen dataset
                   DT::DTOutput("chosenData") # Defined in server

                   ), # End data page


  bslib::nav_panel(title = "Plot",
                   bslib::layout_sidebar(
                     sidebar = bslib::sidebar(
                       HTML("Options"),
                       # Plotting options

                       ## Participant defined in server
                       uiOutput("participant_ui"),

                       ## Variables defined in server
                       uiOutput("variable_ui"),

                       ### Option to select all variables
                       actionButton(
                         inputId = "all_vars",
                         label = "Select all"),

                       ### Option to deselect all variables
                       actionButton(
                         inputId = "clear_vars",
                         label = "Deselect all"),

                       ## Trend line: create input for assumption_plot()
                       checkboxInput(
                         inputId = "add_trend",
                         label = "Show trend line",
                         value = FALSE), # default

                       ### If trend line included, what kind
                       conditionalPanel(
                         condition = "input.add_trend == true",
                         selectInput(
                           inputId = "trend_type",
                           label = "Trend line type",
                           choices = c("lm", "loess"),
                           selected = "lm")),

                       ## Only show imputation options if you want to impute
                       ### (This is made a bit clumsily, might make sense to
                       ### change this in both the plotting function and here.
                       ### Currently an extra step needs to be taken in the server.)
                       checkboxInput(
                         inputId = "impute_toggle",
                         label = "Impute missing data",
                         value = FALSE), # default

                       conditionalPanel(
                         condition = "input.impute_toggle == true",

                         selectInput(
                           inputId = "impute_method",
                           label = "Imputation method",
                           choices = c("mean", "mode"),
                           selected = "mean")),

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
                         choices = c("classic", "minimal", "bw", "dark"),
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
                         min = 1,
                         max = 30,
                         value = 14),

                       ## Legend
                       sliderInput(
                         inputId = "legend_size",
                         label = "Legend text size",
                         min = 1,
                         max = 30,
                         value = 14)

                     ), # End of options


                     HTML("<b>Assumption Plot</b>"),
                     plotOutput("assumption_plot")

                   ),
                   # Navigate back to data tab
                   actionButton(
                     inputId = "go_summary",
                     label = "See summary of missing values")

                   ), # End plot page



  bslib::nav_panel(title = "Summary",
                   bslib::layout_sidebar(
                     sidebar = bslib::sidebar(
                       HTML("
                            Options
                            "),
                       uiOutput("participant_ui_summary"),

                       # ## Choose theme
                       # ### Not included for now
                       # uiOutput("theme_ui")

                       ## Choose text font
                       uiOutput("font_ui"),

                       # Edit summary plots font sizes
                       ## Axis
                       sliderInput(
                         inputId = "axis_size_sum",
                         label = "Axis text size",
                         min = 1,
                         max = 30,
                         value = 14),

                       ## Legend
                       sliderInput(
                         inputId = "legend_size_sum",
                         label = "Legend text size",
                         min = 1,
                         max = 30,
                         value = 14)



                     ), # End summary options


                     # Start layout_sidebar content
                     HTML("
                                 <b>Tips of what to look for in 'Assumption Plot':</b>
                                 <ol>
                                 <li>Do the variables show variability?</li>
                                 <li>Are the measurement points equidistant?</li>
                                 <li>Does the data remain stationary?</li>
                                 </ol>
                                             "),
                     p(HTML("<b>Ratio of Missing Data:</b>")),
                       # Choose whether to plot all
                       checkboxInput(
                         inputId = "plot_all",
                         label = "Show missing values of full dataset",
                         value = FALSE),

                       # Render Plots
                       bslib::layout_columns(
                         plotOutput("pie_chart"),
                         plotOutput("bar_chart"))


                   ), # End layout_sidebar

                   # Navigate back to plot tab
                   actionButton(
                     inputId = "go_back",
                     label = "Go back to Assumption Plot")

                   ), # End summary page


  # Navigation bar
  bslib::nav_spacer(), # space between tabs and "more" menu

  # Menu bar with aditional sources
  bslib::nav_menu(
    title = "More",
    align = "right",
    bslib::nav_item(
      tags$a("openESM",
             href = "https://openesmdata.org/datasets/",
             target = "_blank") # Creates a new tab when you navigate but when
                                # running app in RStudio, it also opens a blank
                                # window. Doesn't happen when ran from browser.
    ),
    bslib::nav_item(
      tags$a("Github",
             href = "https://github.com/Programming-The-Next-Step-2026/Assumption-Plotter",
             target = "_blank")
    )
  ) # End navigation bar

)


#############################################################################
#                                  SERVER                                   #
#############################################################################

server <- function(input, output, session){
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

    } else if(input$data_pick == "upload"){

      tagList(

        HTML("
             Please provide the following information first:
             "),

        bslib::layout_columns(

          # ID
          textInput(
            inputId = "upload_id",
            label = "Name of participant ID column",
            value = "id"),

          # Day
          textInput(
            inputId = "upload_day",
            label = "Name of day column",
            value = "day"),

          # Beep
          textInput(
            inputId = "upload_beep",
            label = "Name of beep column",
            value = "beep"),

          # Expected days
          numericInput(
            inputId = "upload_exp_day",
            label = "Expected days",
            value = 14,
            min = 1,
            max = 365
          ),

          # Expected beeps
          numericInput(
            inputId = "upload_exp_beep",
            label = "Expected beeps per day",
            value = 10,
            min = 1,
            max = 20
          )
        ),

        # Variables
        textInput(
          inputId = "upload_vars",
          label = "Name of variables (must match column name) to be plotted",
          placeholder = "cheerful, pleasantness, worried, fearful, sad, relaxed",
          width = "100%"),

        HTML("
             <span style='color:#b22222;'>Note that the function that cleans the
             data currently only supports wide format</span>"),

        fileInput(
          "file",
          "You can only upload a CSV file",
          accept = c(".csv")
        )
      ) # end upload tagList

    } else if(input$data_pick == "zenodo"){

      tagList(

        HTML("
             All information can be found in the datasets dedicated openESM page:
             "),

        bslib::layout_columns(

          # ID
          textInput(
            inputId = "zenodo_id",
            label = "Name of participant ID column",
            value = "id"),

          # Day
          textInput(
            inputId = "zenodo_day",
            label = "Name of day column",
            value = "day"),

          # Beep
          textInput(
            inputId = "zenodo_beep",
            label = "Name of beep column",
            value = "beep"),

          # Expected days
          numericInput(
            inputId = "zenodo_exp_day",
            label = "Expected days",
            value = 14,
            min = 1,
            max = 365
          ),

          # Expected beeps
          numericInput(
            inputId = "zenodo_exp_beep",
            label = "Expected beeps per day",
            value = 10,
            min = 1,
            max = 20
          )
        ),

        # Variables
        textInput(
          inputId = "zenodo_vars",
          label = "Name of variables (must match column name) to be plotted",
          placeholder = "cheerful, pleasantness, worried, fearful, sad, relaxed",
          width = "100%"),

        HTML("
             <span style='color:#b22222;'>Click 'Zenodo DOI', then right click
             the data file, and copy the link address. Do not choose the raw
             data file.</span>"),

        # Zenodo link
        textInput(
          inputId = "zenodo_link",
          label = "Link to .tsv file in Zenodo",
          placeholder = "https://zenodo.org/records/17347538/files/0022_menghini_ts.tsv?download=1",
          width = "100%")

      ) # end zenodo tagList


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

      } else if(input$data_pick == "upload") {
        req(input$file)

        upload <- readr::read_csv(input$file$datapath)

        upload_vars <- trimws(
          strsplit(input$upload_vars, ",")[[1]]
        )

        AssumptionPlotter::clean_df(
          df = upload,
          id_col = input$upload_id,
          day_col = input$upload_day,
          exp_day = input$upload_exp_day,
          beep_col = input$upload_beep,
          exp_beep = input$upload_exp_beep,
          variables = upload_vars
        )
      } else if(input$data_pick == "zenodo"){

        req(input$zenodo_link)

        zenodo <- readr::read_tsv(input$zenodo_link)

        zenodo_vars <- trimws(
          strsplit(input$zenodo_vars, ",")[[1]]
        )

        AssumptionPlotter::clean_df(
          df = zenodo,
          id_col = input$zenodo_id,
          day_col = input$zenodo_day,
          exp_day = input$zenodo_exp_day,
          beep_col = input$zenodo_beep,
          exp_beep = input$zenodo_exp_beep,
          variables = zenodo_vars
        )
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

    updateNavbarPage(
      session,
      "main_page",
      selected = "Plot"
    )

  })


  ## Choose participant
  output$participant_ui <- renderUI({

    req(plot_data_reactive())

    df <- plot_data_reactive()

    selectInput(
      "participant", # selection can be accesses through input$participant
      "Participant",
      choices = unique(df$id), # shows all participant
      selected = unique(df$id)[1]
    )

  })


  ## Choose participant for summary charts
  output$participant_ui_summary <- renderUI({

    req(plot_data_reactive())

    df <- plot_data_reactive()

    selectInput(
      "participant_sum", # selection can be accesses through input$participant
      "Participant",
      choices = unique(df$id), # shows all participant
      selected = input$participant
    )

  })

  ## Choose variables
  output$variable_ui <- renderUI({

    req(plot_data_reactive())
    df <- plot_data_reactive()

    vars <- names(df)[!names(df) %in% c("id", "day", "beep", "missing")]

    checkboxGroupInput( # Check off the ones you want to see
      "variables",
      "Variables",
      choices = vars,
      selected = vars
    )

  })

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

  })

  # Create Assumption plot
  output$assumption_plot <- renderPlot({

    req(plot_data_reactive())
    req(input$participant)
    req(input$variables)

    df <- plot_data_reactive()


    assumption_plot(
      df = df,
      participant = input$participant,
      variables = input$variables,
      expected_days = max(df$day),
      beeps_per_day = max(df$beep),
      include_day = input$day_label,
      include_day_line = input$day_lines,
      impute = if (isTRUE(input$impute_toggle)) input$impute_method else "none",
      add_trend = input$add_trend,
      trend_type = input$trend_type,
      theme_choice = input$theme_choice,
      palette = ifelse(!input$edit_palette, "none","custom"),
      palette_option = input$palette_option,
      text_font = input$text_font,
      axis_text_size = input$axis_size,
      legend_text_size = input$legend_size
    )

  })

  # To summary from plot tab
  observeEvent(input$go_summary, {

    updateNavbarPage(
      session,
      "main_page",
      selected = "Summary"
    )
  })


  # Choose variables for pie and bar charts
  # (using the same ones as for the assumption plot caused failure)

  # ## Theme
  # ### Can be included but for simplicity, I am not, for now.
  #
  # output$theme_ui <- renderUI({
  #   selectInput(
  #     inputId = "theme_choice",
  #     label = "Theme",
  #     choices = c("classic", "minimal", "bw", "dark"),
  #     selected = input$theme_choice)
  # })

  ## Font style
  output$font_ui <- renderUI({
    selectInput(
      inputId = "text_font_sum",
      label = "Font family",
      choices = c("sans", "serif", "mono"),
      selected = input$text_font)
  })




  # Create pie chart of missing values
  output$pie_chart <- renderPlot({

    req(plot_data_reactive())

    df <- plot_data_reactive()

    pie_bar_chart(
      df = df,
      participant = input$participant_sum,
      type = "pie",
      plot_all = input$plot_all,
      text_font = input$text_font_sum,
      axis_text_size = input$axis_size_sum,
      legend_text_size = input$legend_size_sum,
      theme_choice = "classic"
    )

  })

  # Create bar chart of missing values
  output$bar_chart <- renderPlot({

    req(plot_data_reactive())

    df <- plot_data_reactive()

    pie_bar_chart(
      df = df,
      participant = input$participant_sum,
      type = "bar",
      plot_all = input$plot_all,
      text_font = input$text_font_sum,
      axis_text_size = input$axis_size_sum,
      legend_text_size = input$legend_size_sum,
      theme_choice = "classic"
    )

  })

  # To plot from summary tab
  observeEvent(input$go_back, {

    updateNavbarPage(
      session,
      "main_page",
      selected = "Plot"
    )
  })


}


# Run the application
shinyApp(ui = ui, server = server)

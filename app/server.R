server <- function(input, output, session) {
  
  initialize_basemap(output)
  dem_active <- reactiveVal(FALSE)
  shape_active <- reactiveVal(FALSE)
  # Loading powiats   
  updateSelectizeInput(
    session,
    "powiat",
    choices = sort(unique(powiaty_data$Name)),
    server = TRUE
  )
  # Setting the well observers
  setup_input_observers(
    input = input,
    session = session,
    dem_active = dem_active,
    shape_active = shape_active
  )
  console_logs <- reactiveVal(DEFAULT_CONSOLE_MESSAGE)
  # Setting download
  download_path <- reactiveVal(NULL)
  observe({
    req(download_path())
     addResourcePath(prefix = "res_folder", directoryPath = download_path())
  })
  # Pipeline execution observable
  observeEvent(input$run, {
    setting_well_ui()
    clear_pipeline_map()
    shinyjs::runjs("startPipelineSpinner();")
    # Execution environment
    shinyjs::delay(100, {
      inputs_pipeline <- prepare_pipeline_inputs(input, shape_active, dem_active)
      args_pipeline <- c(
        PIPELINE_CLI_SCRIPT,
        format(input$start_date, "%Y-%m-%d"),
        format(input$end_date, "%Y-%m-%d"),
        inputs_pipeline$vect_reference,  
        inputs_pipeline$dem_arg
      )
      
      # Running the Pipeline
      pipeline_results <- tryCatch({
        system2(
          "Rscript",
          args = args_pipeline,
          stdout = TRUE,
          stderr = TRUE
        )
      }, error = function(e) {
        return(e$message)
      })
      # If any error occures in the Pipeline
      if (any(grepl("❌", pipeline_results))) {
        restart_well_ui()
        handle_pipeline_error(
            pipeline_results,
            shape_active,
            dem_active
        )
        req(FALSE)
      }
      # Parse pipeline output
      pipeline_info <- extract_pipeline_output_info(
        pipeline_results = pipeline_results,
        start_date = input$start_date,
        end_date = input$end_date
      )      
      # Store download folder
      download_path( pipeline_info$line_path )
      # Update map
      update_pipeline_map(
        folder_path = pipeline_info$folder_path,
        line_path = pipeline_info$line_path,
        name_poly = pipeline_info$name_poly,
        clean_layer_name = clean_layer_name
      )  
      # Update console logs
      console_logs( paste( pipeline_info$pipeline_logs, collapse = "\n" ))
      # Creating pipeline output files
      output_settings(download_path= download_path())
      # Reseting the well ui
      restart_well_ui()
      shape_active(FALSE)
      dem_active(FALSE)
    })
  })
  output$pipeline_logs <- renderPrint({
    cat(console_logs())
  })
  
}
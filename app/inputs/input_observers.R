setup_input_observers <- function( input, session, dem_active, shape_active ) {

  # Setting the well ui interactions
  observeEvent(input$user_raster, {
    dem_active(TRUE)
    shinyjs::show("reset_dem")
  })
  observeEvent(input$reset_dem, {
    shinyjs::reset("user_raster")
    shinyjs::runjs("$('#user_raster').val('');")
    shinyjs::hide("reset_dem")
    dem_active(FALSE)
  })
  # Setting cross interaction vector app
  observeEvent(input$powiat, {
    if (length(input$powiat) > 0) {
      shinyjs::disable("user_shape")
      shinyjs::hide("reset_file")
      shinyjs::addClass(id = "shape_container", class = "upload-disabled-cursor")
    } else {
      if (is.null(input$user_shape) || (is.data.frame(input$user_shape) && nrow(input$user_shape) == 0)) {
        shinyjs::enable("user_shape")
        shinyjs::removeClass(id = "shape_container", class = "upload-disabled-cursor")
      }
    }
  }, ignoreNULL = FALSE)
  # Setting user vector input
  observeEvent(input$user_shape, {
    req(input$user_shape)     
    if (is.data.frame(input$user_shape) && nrow(input$user_shape) > 0 && input$user_shape$datapath != "") {
      shape_active(TRUE)
      shinyjs::disable("powiat")
      shinyjs::show("reset_file")
      shinyjs::addClass(id = "powiat_container", class = "selectize-disabled-cursor")
    } else {
    shinyjs::removeClass(id = "powiat_container", class = "selectize-disabled-cursor")
    }
  }, ignoreInit = TRUE)
  observeEvent(input$reset_file, {
    shinyjs::reset("user_shape")
    shinyjs::runjs("$('#user_shape').val('');")
    shinyjs::hide("reset_file")
    shape_active(FALSE)
    shinyjs::runjs("$('#powiat')[0].selectize.clear();")
    shinyjs::enable("powiat")
    shinyjs::removeClass(id = "powiat_container", class = "selectize-disabled-cursor")
  })
  # Dates logic offset +5 days
  observeEvent(input$start_date,
    {
      date_offset <- input$start_date + 5
      updateDateInput(
        session,
        "end_date",
        value = date_offset,
        min = date_offset
      )
    },
    ignoreInit = TRUE
  )
  # Run observable logic
  observe({
    dates_ok <- as.numeric(input$end_date - input$start_date) >= 5
    polygon_ok <- length(input$powiat) > 0 || shape_active()
    if (dates_ok && polygon_ok) {
      enable("run")
    } else {
      disable("run")
    }
  })


}
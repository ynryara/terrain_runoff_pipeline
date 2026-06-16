prepare_pipeline_inputs <- function( input, shape_active, dem_active ) {

    if (length(input$powiat) > 0) {
      vect_reference = shQuote(paste(input$powiat, collapse = ","))
    } else if (shape_active()) {
      # Setting the zip file
      gc()
      temp_dir <- file.path(tempdir(), "user_shp")
      if (dir.exists(temp_dir)) unlink(temp_dir, recursive = TRUE, force = TRUE)
      dir.create(temp_dir)
      unzip(input$user_shape$datapath, exdir = temp_dir)
      files_raw <- list.files(temp_dir, pattern = "\\.shp$", full.names = TRUE, recursive = TRUE)
      if (length(files_raw) == 0 || is.na(files_raw[1])) {
        unlink(temp_dir, recursive = TRUE, force = TRUE)
        restart_well_ui()
        shape_active(FALSE)
        dem_active(FALSE)
        shinyjs::runjs('
          $("#pipeline_logs").remove();
          $(".col-console").append("<pre id=\'pipeline_logs\' class=\'shiny-text-output\'>Awaiting execution...</pre>")
        ')        
        shinyjs::runjs("
          Swal.fire({
            title: 'Validation Error',
            text: '❌ Invalid ZIP archive: No .shp file was found inside the uploaded ZIP',
            icon: 'error',
            confirmButtonText: 'Review Shapefile',
            confirmButtonColor: '#d33'
          });
        ")
        req(FALSE)
      }      
      pipeline_files <- normalizePath(files_raw[1], winslash = "/", mustWork = FALSE)
      vect_reference = shQuote(pipeline_files)
    }
    # Setting dem arg
    if (dem_active() && !is.null(input$user_raster)) {
      dem_raw_path <- input$user_raster$datapath
      dem_reference <- normalizePath(dem_raw_path, winslash = "/", mustWork = FALSE)
      dem_arg <- shQuote(dem_reference)
    } else {
      dem_arg <- shQuote("")
    }
  return(list(
    vect_reference = vect_reference,
    dem_arg = dem_arg
  ))
  
}
# Function to restart the well ui
restart_well_ui <- function() {
    shinyjs::runjs("
      $('#reset_file').hide();
      $('#reset_dem').hide();
    ")
    shinyjs::reset("user_shape")   
    shinyjs::reset("user_raster")
    shinyjs::runjs("
      $('#user_shape').val('');
      $('#user_raster').val('');
    ")    
    shinyjs::runjs("$('#powiat')[0].selectize.clear();")
    shinyjs::enable("powiat")
    shinyjs::enable("user_shape")
    shinyjs::enable("user_raster")
    shinyjs::removeClass(id = "powiat_container", class = "selectize-disabled-cursor")
    shinyjs::removeClass(id = "shape_container", class = "upload-disabled-cursor")
 }  

setting_well_ui <- function() {
    shinyjs::reset("user_shape")
    shinyjs::reset("user_raster")
    shinyjs::runjs("
      $('#user_shape').val('');
      $('#user_raster').val('');
    ")
    shinyjs::hide("reset_file")
    shinyjs::hide("reset_dem")
    shinyjs::disable("run")
}
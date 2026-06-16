handle_pipeline_error <- function( pipeline_results, shape_active, dem_active ) {
    error_lineas <- unlist(strsplit(pipeline_results, "\n"))
    error_clean <- error_lineas[grepl("❌", error_lineas)][1]
    error_clean <- gsub(".*❌", "❌", error_clean)
    error_clean <- gsub("'", "\\'", error_clean, fixed = TRUE)
    shape_active(FALSE)
    dem_active(FALSE)        
    shinyjs::runjs('
        $("#pipeline_logs").remove();
        $(".col-console").append("<pre id=\'pipeline_logs\' class=\'shiny-text-output\'>Awaiting execution...</pre>")
    ')
    # Popup error message
    shinyjs::runjs(sprintf("
        Swal.fire({
        title: 'Validation Error',
        text: '%s',
        icon: 'error',
        confirmButtonText: 'Review user inputs',
        confirmButtonColor: '#d33'
        });
    ", error_clean))
}
extract_pipeline_output_info <- function( pipeline_results, start_date, end_date ) {
      # Setting logs
      line_path <- gsub(".*Data is located in: ", "", grep("Data is located in:", pipeline_results, value = TRUE))
      line_path <- trimws(line_path)
      # Setting path parameters
      line_name <- grep("The terrain-based SCSCN Runoff pipeline for", pipeline_results, value = TRUE)
      folder_path <- file.path(
        line_path,
        paste("Terrain_based_Runoff", format(start_date + 5, "%Y%m%d"),
          format(end_date, "%Y%m%d"),
          sep = "_"
        )
      )
      pipeline_results <- pipeline_results[!grepl("Data is located in:", pipeline_results)]
      name_poly <- gsub(" ", "_", gsub(" from .*", "", gsub(".*The terrain-based SCSCN Runoff pipeline for ", "", line_name)))
      # Clean logs
      clean_logs <- pipeline_results[!grepl( "Data is located in:", pipeline_results)]
      return(
        list(
        line_path = line_path,
        folder_path = folder_path,
        name_poly = name_poly,
        pipeline_logs = clean_logs
      )
    )      
}
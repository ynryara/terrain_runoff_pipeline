args <- commandArgs(trailingOnly = TRUE)
# Date range args
start_date <- as.Date(args[1])
end_date <- as.Date(args[2])
# Powiat args
pipeline_polygon <- gsub('"', '', unlist(strsplit(args[3], split = ",")))
# Custom DEM (optional)
if (args[4] != "") {
  user_DEM <- args[4] 
} else {
  user_DEM <- NULL
}
tryCatch(
  {
    # Pipeline modules and functions
    source("pipeline/global.R")
    runoff()
    validation()
  },
  error = function(e) {
    writeLines(paste("\n❌ [CRITICAL PIPELINE ERROR]:", e$message, "\n"), stderr())
    if (grepl("❌", e$message)) {
      stop(e$message, call. = FALSE)
    } else {
      stop("❌ The pipeline execution failed due to an internal system error. Please contact technical support at: yyara@agh.edu.pl", call. = FALSE)
    }
  }
)
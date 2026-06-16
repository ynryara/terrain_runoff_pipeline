# Default map view
DEFAULT_MAP_CENTER_LNG <- 19.145
DEFAULT_MAP_CENTER_LAT <- 51.919
DEFAULT_MAP_ZOOM <- 6

# File settings
MAX_UPLOAD_SIZE_MB <- 40
PIPELINE_OUTPUT_ZIP <- "Terrain_Runoff_Pipeline_OUTPUT.zip"

# Pipeline scripts
PIPELINE_CLI_SCRIPT <- "pipeline/run_pipeline_cli.R"

# Console default message
DEFAULT_CONSOLE_MESSAGE <- "Awaiting execution..."

# Spinner messages
PIPELINE_SPINNER_MESSAGES <- c(
  "Welcome to the Terrain-based SCS-CN Runoff Pipeline for Poland!",
  "Pipeline starts",
  "Loading pipeline sources",
  "DEM",
  "Topographic Wetness Index",
  "Terrain Features module successfully ran!",
  "Land Cover",
  "Hydrological Soil",
  "Soil Constants module successfully ran!",
  "Evapotranspiration",
  "Precipitation",
  "Antecedent Moisture",
  "Hydroclimate Variables module successfully ran!",
  "SCS-CN module successfully ran!",
  "Runoff",
  "Terrain-based Runoff module successfully ran!",
  "Validation",
  "Setting final pipeline outputs... please wait"
)

# Color palette
RUNOFF_PALETTE <- "grDevices::Oslo"

# UI colors
SUCCESS_BUTTON_COLOR <- "#89ec46"
ERROR_BUTTON_COLOR <- "#d33"

# Support
SUPPORT_EMAIL <- "yyara@agh.edu.pl"
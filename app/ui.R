ui <- fluidPage(
  # App iu settings
  useShinyjs(),
  useSweetAlert(),
  theme = shinytheme("flatly"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
    tags$script(src = "js/spinner.js")
  ),
  # Main title
  div(class = "header-container",
    img(src = "logo.svg", class = "header-logo"), 
    div(class = "header-title", 
      h3("Terrain-based SCS-CN Runoff Pipeline for Poland")
    ),
    div(class = "header-actions-column",
      tags$a(href = "https://github.com/ynryara/terrain_runoff_pipeline", target = "_blank", class = "header-btn", title = "GitHub Repository", icon("github")),
      tags$a(href = "mailto:yyara@agh.edu.pl", class = "header-btn", title = "Contact Support", icon("envelope")),
      tags$a(href = "https://wggiis.agh.edu.pl/en/", target = "_blank", class = "header-btn", title = "University Page", icon("university"))
    )
  ),
  # Main app column
  fluidRow(class = "top-row",
    div(class = "col-sidebar",
      wellPanel(
        # Left column 20%
        h5(class="sub-title", "Setting parameters"),
        dateInput("start_date", 
          label = tags$span("Start date", 
            tags$span(class="info-icon", title="Minimum 5 days range required for antecedent climate data", "i")
          ), 
          min = "1960-01-01", max = Sys.Date() - 12, value = as.Date(paste0(format(Sys.Date(), "%Y"), "-01-01"))),
        dateInput("end_date", "End date", min = as.Date(paste0(format(Sys.Date(), "%Y"), "-01-06")), max = Sys.Date() - 7, value = as.Date(paste0(format(Sys.Date(), "%Y"), "-01-06"))),    
        div(id = "powiat_container",
          selectizeInput("powiat", "Select counties", choices = NULL, multiple = TRUE, options = list(placeholder = 'Type to search...', allowEmptyOption = TRUE)),
        ), 
        p(
          "Upload a custom polygon (optional)",
          tags$span(class="info-icon", title="shp compressed in zip archive, EPSG:2180 projection, within Poland territory", "i")
        ),
        div(id = "shape_container",
          fileInput("user_shape", "Shapefile (.zip)", accept = ".zip"),
        ),
        actionButton("reset_file", "Clean file", class = "btn-xs", style = "display: none;"),
        p(
          "Upload a custom DEM (optional)",
          tags$span(class="info-icon", title="GeoTIFF (.tif), EPSG:2180, covering at least 120% of the target vector area", "i")
        ),
        fileInput("user_raster", "GeoTIFF (.tif)", accept = ".tif"),
        actionButton("reset_dem", "Clean file", class = "btn-xs", style = "display: none;"),
        br(),
        br(), 
        disabled(
          actionButton("run", "▷ Run pipeline", class = "btn-primary")
        ),
      )
    ),
    # Right column 80%
    div(class = "col-map",
      leafletOutput("map_results"),
      # Low app side
      div(class = "bottom-row",
        div(class = "col-console",
          verbatimTextOutput("pipeline_logs")
        )
      ),
    ),
  ),
tags$a(id = "download_results_hidden", 
       href = "", 
       download = "Terrain_Runoff_Pipeline_OUTPUT.zip", 
       style = "display: none;")
)
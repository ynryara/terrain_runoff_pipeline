# Function to set layer name
clean_layer_name <- function(x) {
    gsub("_", " ", gsub(".tif", "", basename(x)))
}

# Initialize the default map
initialize_basemap <- function(output) {
  envelope_data <- vect(file.path("pipeline/assets/gis_meta/Envelop.shp"))
  envelope_wgs84 <- project(envelope_data, "EPSG:4326")
  output$map_results <- renderLeaflet({
    leaflet() %>%
    addTiles() %>%
    setView(lng = DEFAULT_MAP_CENTER_LNG, lat = DEFAULT_MAP_CENTER_LAT, zoom = DEFAULT_MAP_ZOOM) %>%
    addPolygons(
      data = envelope_wgs84,
      color = "#087c0a",       
      weight = 3,              
      fill = FALSE,      
      group = "Envelop"
    )
  })
}

# Reset map before a new execution
clear_pipeline_map <- function() {
    leafletProxy("map_results") %>%
      clearImages() %>%
      clearControls() %>%
      clearGroup("runoff_layers") %>%
      clearGroup("poly_layers") %>%
      addLayersControl(
        overlayGroups = character(0), 
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      setView(lng = 19.145, lat = 51.919, zoom = 6)

}

update_pipeline_map <- function(folder_path, line_path, name_poly, clean_layer_name ) {
  paths_rasters <- list.files(folder_path, pattern = "\\.tif$", full.names = TRUE)
  raster_files <- rast(paths_rasters)
  # Setting legend 
  max_value <- max(global(raster_files, fun = c("max"), na.rm = TRUE)$max)
  global_range <- c(0, max_value)
  if (max_value < 1) {
    num_decimals <- 4
  } else if (max_value >= 1 || max_value < 10) {
    num_decimals <- 2
  } else {
    num_decimals <- 1
  }
  pal_raster <- colorNumeric(
    palette = as.character(paletteer_c(RUNOFF_PALETTE, 50)),
    domain = global_range,
    na.color = "transparent"
  )
  # Loading map proxy
  proxy <- leafletProxy("map_results")
  # Adding raster to map
  for (f in as.list(raster_files)) {
    layer_name <- clean_layer_name(sources(f))
    r_web <- terra::project(f, "EPSG:4326")
    r_web[r_web == 0] <- NA
    vals <- as.numeric(terra::values(r_web, mat = FALSE))
    proxy <- proxy %>%
    addRasterImage(r_web,
      colors = pal_raster,
      opacity = 0.8,
      group = layer_name
    )
  }
  # Layer control toggle
  proxy %>%
    addLayersControl(
      overlayGroups = clean_layer_name(paths_rasters),
      options = layersControlOptions(collapsed = FALSE)
    )
  # Adding legend
  proxy %>%
    removeControl("runoff_legend") %>%
    addLegend(
      pal = pal_raster,
      values = global_range,
      title = "Runoff (mm)",
      position = "bottomleft",
      layerId = "runoff_legend",
      opacity = 1,
      labFormat = labelFormat(digits = num_decimals)
    )
  # Zoom runoff rasters
  ext_v <- as.vector(terra::ext(r_web))
  delay(500, {
    leafletProxy("map_results") %>%
    invokeMethod(NULL, "invalidateSize") %>%
    fitBounds(
      lng1 = as.numeric(ext_v["xmin"]),
      lat1 = as.numeric(ext_v["ymin"]),
      lng2 = as.numeric(ext_v["xmax"]),
      lat2 = as.numeric(ext_v["ymax"])
    )
  })
  # Adding pipeline polygon
  v_raw <- terra::vect(file.path(line_path, paste0("SCSCN_Inputs_", name_poly), "GIS_data", paste0(name_poly, ".shp")))
  v_web <- terra::project(v_raw, "EPSG:4326")
  leafletProxy("map_results") %>%
    clearGroup("poly_layers") %>%
    addPolygons(
      data = v_web,
      color = "black",
      weight = 2,
      fillOpacity = 0,
      group = "poly_layers"
    )
  showNotification("All layers loaded into layer control", type = "message")

}
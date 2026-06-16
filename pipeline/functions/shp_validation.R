shp_validation<- function() {

  if (polygon_mode == "powiat") {
    powiat <- powiaty[powiaty$Name %in% pipeline_polygon, ]
  } else {
    if (!file.exists(pipeline_polygon)) {
      stop("❌ The specified Shapefile does not exist in the provided path")
    }
    powiat <- tryCatch({
      vect(pipeline_polygon)
    }, error = function(e) {
      NULL
    })
    if (is.null(powiat) || nrow(powiat) == 0) {
      stop("❌ The Shapefile is corrupted, incomplete, or lacks a valid vector format geometry")
    }
    crs_shp <- crs(powiat, describe = TRUE)
    is_2180 <- isTRUE(!is.null(crs_shp$code) && crs_shp$code == "2180")
    if (!is_2180) {
      if (is.na(crs(powiat)) || crs(powiat) == "" || !grepl("EPSG.*2180|ETRS89 / Poland CS92", crs(powiat))) {
        stop("❌ Invalid Coordinate Reference System. The Shapefile must be projected in EPSG:2180 (ETRS89 / Poland CS92)")
      }
    }
    envelop <- vect("pipeline/assets/gis_meta/Envelop.shp")    
    if (!any(relate(powiat, envelop, "intersects"))) {
      stop("❌ Invalid input geometry: the uploaded Shapefile must be geographically located within Poland")
    }
    message("\n✅ User Shapefile successfully integrated")
  }
  clip_base <- as.polygons(ext(powiat)*1.3)
  crs(clip_base) <- crs(powiat)
  pipeline_vect <<- powiat
  writeVector(powiat, file.path(GIS_path, paste0(polygon_name, ".shp")), overwrite = TRUE)
  writeVector(clip_base, file.path(GIS_path, "clip_base.shp"), overwrite = TRUE)
  gc()

}
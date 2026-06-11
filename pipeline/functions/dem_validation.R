dem_validation <- function() {
  
  if (exists("user_DEM")) {  
    if (!file.exists(user_DEM)) {
      stop("❌ The specified DEM file does not exist in the provided path.")
    }
    dem_raster <- tryCatch({
      rast(user_DEM)
    }, error = function(e) {
      NULL
    })
    if (is.null(dem_raster)) {
      stop("❌ The DEM file is corrupted, incomplete, or not in a valid raster format.")
    }
    crs_dem <- crs(dem_raster, describe = TRUE)
    is_2180 <- !is.null(crs_dem$code) && crs_dem$code == "2180"
    if (!is_2180) {
      if (!grepl("EPSG.*2180|ETRS89 / Poland CS92", crs(dem_raster))) {
        stop("❌ Invalid Coordinate Reference System. The DEM must be projected in EPSG:2180 (ETRS89 / Poland CS92).")
      }
    }
    dem_extent  <- as.polygons(ext(dem_raster))
    polonia_ext <- as.polygons(ext(vect("pipeline/assets/gis_meta/Envelop.shp")))
    if (!is.related(dem_extent, polonia_ext, "within")) {
      stop("❌ The uploaded DEM is located entirely outside the geographical boundaries of Poland (envlop.shp).")
    }
    clip_base_ext_poly <- as.polygons(ext(vect(file.path(GIS_path, "clip_base.shp"))))
    if (!is.related(clip_base_ext_poly, dem_extent, "within")) {
      stop("❌ DEM coverage must be at least 20% larger than the pipeline polygon area.")
    }
    writeRaster(dem_raster, file.path("pipeline/assets/gis_meta/DEM.tif"), overwrite = TRUE)
    message("✅ User DEM successfully integrated.")
    rm(user_DEM, envir = .GlobalEnv)
  }
  
}
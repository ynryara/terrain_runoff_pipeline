topo_wet_index <- function() {
  
  dem_path <- file.path(terrain_path, "DEM.tif")
  dem_filled <- file.path(terrain_path, "DEM_filled.tif")
  wbt_fill_depressions(dem_path, dem_filled)
  flow_acc <- file.path(terrain_path, "flow_acc.tif")
  wbt_d_inf_flow_accumulation(dem_filled, flow_acc, log = FALSE)
  slope <- file.path(terrain_path, "slope.tif")
  wbt_slope(dem_filled, slope)
  twi_path <- file.path(terrain_path, "twi_real.tif")
  wbt_wetness_index(flow_acc, slope, twi_path)
  twi_rast <- rast(twi_path)
  twi_min <- global(twi_rast, "min", na.rm=TRUE)[1,1]
  twi_max <- global(twi_rast, "max", na.rm=TRUE)[1,1]
  T_norm <- (twi_rast - twi_min) / (twi_max - twi_min)
  pipeline_output(T_norm, "TopographicWet_Index", 0, 1, 1)

}
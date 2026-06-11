validation_runoff<- function() {
  
  run_stack <- rast(list.files(file.path(outputs[["Runoff"]]), pattern = "\\.tif$", full.names = TRUE))
  scs_stack <- rast(list.files(file.path(outputs[["Runoff"]], "Runoff_RAW"), pattern = "\\.tif$", full.names = TRUE))
  runoff_gee_stack <- rast(list.files(file.path(outputs[["Validation"]]), pattern = "\\.tif$", full.names = TRUE)) / 100
  results <- data.frame()
  colors_gee <- c("lightgray", "darkgreen")
  colors_ral <- c("red", "green")
  col_to_use <- function(runoff_ras, colors_map) {
    u <- unique(runoff_ras)[, 1]
    if(all(u == 0)) {
      colors_map[1]
    } else if (all(u == 1)){
      colors_map[2]
    } else {
      colors_map
    }
  }
  validation_plot <- function(gee_raster, ral_raster, gee_vect){
    old_mar <- par()$mar
    par(mar = c(4, 2, 2, 2)) 
    plot(gee_raster, col = col_to_use(gee_raster, colors_gee), legend = FALSE,  main= paste("Runoff Presence Comparison ERA5 vs Pipeline", dates_runoff[i]), mar = par("mar"))
    plot(gee_vect, add = TRUE, border = "grey70", col = "transparent", legend = FALSE)
    image(ral_raster, col = adjustcolor(col_to_use(ral_raster, colors_ral), alpha.f = 0.6), add = TRUE, legend = FALSE, useRaster = TRUE, border = NA, interpolate = FALSE)
    plot_labels()
    legend("bottom", inset = c(0, -0.105), legend = c("ERA-5 present", "ERA-5 absent", "Pipeline present", "Pipeline absent"), fill = c("darkgreen", "lightgray", "green", "red"), border = "black", bty = "n", xpd = TRUE, ncol = 4, cex = 0.7)
    par(mar = old_mar)
  }
  stacks_runoff= list(scs_stack, run_stack)
  threshold_bin <- 0.1
  for (i in 1:nlyr(run_stack)) {
    # Binary runoff
    gee_bin <- runoff_gee_stack[[i]] > 0.1
    gee_poly <- as.polygons(gee_bin, dissolve = FALSE)
    temp_res <- list()
    for (j in 1:2) {
      # Model binary
      ral_bin <- stacks_runoff[[j]][[i]] > threshold_bin
      ral_mask <- !is.na(ral_bin)
      # Zonal stats
      runoff_zonal <- zonal(ral_bin, gee_poly, fun = "sum", na.rm = TRUE)
      runoff_edges <- zonal(ral_mask, gee_poly, fun = "sum", na.rm = TRUE)
      runoff_ratio <- na.omit(cbind(values(gee_poly)[[1]], runoff_zonal[[1]], runoff_edges[[1]] ))
      temp_res[[j]] <- validation_statistics(runoff_ratio[,1], runoff_ratio[,2] / runoff_ratio[,3], format(dates_runoff[i], "%Y%m%d"), j)
    }
    row_raw <- cbind(temp_res[[1]], temp_res[[2]])
    results <- rbind(results, row_raw)
    # Ploting
    validation_plot(gee_bin, ral_bin, gee_poly)
    agg_png(filename = file.path(outputs[["Validation"]], paste0("Validation_Runoff_", format(dates_runoff[i], "%Y%m%d"), ".png")), width = 3400, height = 2000, res = 300)
      validation_plot(gee_bin, ral_bin, gee_poly)
    dev.off()   
  }
  mean_acc_terrain= round(mean(results$Accuracy)*100, 2)
  mean_acc_scs= round(mean(results$Accuracy_scscn)*100, 2)
  differential <- round(mean_acc_terrain - mean_acc_scs, 2)
  if (differential > 0) {
    validation_tex <- paste0("+", differential, "% accuracy improvement over classic SCS-CN")
  } else if (differential == 0) {
    validation_tex <- "No accuracy difference compared to classic SCS-CN"
  } else {
    validation_tex <- paste0("-", abs(differential), "% lower accuracy than classic SCS-CN")
  }
  cat("Daily performance metrics for the Terrain-based Runoff Pipeline")
  pander(results[c(1, 5, 6, 7)])
  write.csv(results, file.path(outputs[["Validation"]], "Validacion_runoff_statistics.csv"), row.names = FALSE)
  cat(paste0("🎯 The overall accuracy of the Terrain-based Runoff presence is: ",  mean_acc_terrain, "%"))
  cat(paste0("\n📈 Validation Diagnostic: ", validation_tex, ".\n"))
  cat("\n✅ Validation\n")
  
}
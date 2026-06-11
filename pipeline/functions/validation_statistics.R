validation_statistics <- function(runoff_gee, ratio_pipe, dates_runoff, item) {

  errores <- ratio_pipe - runoff_gee
  rmse <- sqrt(mean(errores^2, na.rm = TRUE))
  mae <- mean(abs(errores), na.rm = TRUE)
  accuracy_cont <- 1 - mae
  bias <- mean(errores, na.rm = TRUE)
  # Output
  if (item == 1) {
    return(data.frame(
      Date = dates_runoff,
      Accuracy_scscn = round(accuracy_cont, 3),
      RMSE_scscn = round(rmse, 3),
      Bias_scscn = round(bias, 3)
    ))
  } else {
    return(data.frame(
      Accuracy = round(accuracy_cont, 3),
      RMSE = round(rmse, 3),
      Bias = round(bias, 3)
    ))
  }
  
}
output_settings <- function(download_path) {   
       
      zip_file_path <- file.path(download_path, PIPELINE_OUTPUT_ZIP)
      filesto_zip <- list.files(download_path, full.names = TRUE)
      zip::zipr(zip_file_path, filesto_zip)
      # Downlading pipeline results
      runjs("
        Swal.fire({
          title: '¡Terrain Runoff Pipeline output data ready!!',
          text: 'Processing is complete. Click the button to download.',
          icon: 'success',
          confirmButtonText: '🡣  Download now',
          confirmButtonColor: '#89ec46'
        }).then((result) => {
          if (result.isConfirmed) {
            window.location.href = 'res_folder/Terrain_Runoff_Pipeline_OUTPUT.zip';
          }
        });
      ")

}
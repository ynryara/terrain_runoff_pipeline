function startPipelineSpinner() {
    var messages = [
        "Welcome to the Terrain-based SCSCN Runoff Pipeline for Poland!",
        "Pipeline starts",
        "Loading Pipeline sources",
        "DEM",
        "TopographicWet Index ",
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
        "Terrain based Runoff module successfully ran!",
        "Validation",
        "Setting final pipeline outputs... please wait "
    ];
    // Inject the initial HTML
    $("#pipeline_logs").html(
        "<div class=\'spinner-container\'>" + 
        "<div class=\'loader\'></div>" + 
        "<span id=\'spinner-text\'>Initializing pipeline...</span>" + 
        "</div>"
    );
    // Function to rotate the message every 3 seconds
    var i = 0;
    var interval = setInterval(function() {
        if (i < messages.length) {
        $("#spinner-text").text(messages[i]);
        i++;
        } else {
        clearInterval(interval);
        }
    }, 3500);
}
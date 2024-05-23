#Programming week 1 pull request functions

#' @title getRocketData
#' @description Get the current data from Launch Library 2 API, which is needed to run the Rocket Launches Shiny App.
#' @param none no parameters needed
#' @return Returns a concise data frame with all  rocket launches in 2024 and additional information about launches.
#' @examples
#' # data_rockets <- getRocketData()
#' @note If Error occurs: "Error in curl::curl_fetch_memory(url, handle = handle) : etc", run getRocketData() again until the data is returned.
#' @export
getRocketData <- function(){
  
  ##get success data
  res_success <- httr::GET("https://lldev.thespacedevs.com/2.2.0/launch/previous/?limit=100&status=3&window_start__gte=2024-01-01T00%3A01%3A00Z")
  
  rawToChar(res_success$content)
  data <- jsonlite::fromJSON(rawToChar(res_success$content))
  data_launch <- data$results
  
  ##get failure data
  res_failure <- httr::GET("https://lldev.thespacedevs.com/2.2.0/launch/previous/?limit=100&status=4&window_start__gte=2024-01-01T00%3A01%3A00Z")
  
  rawToChar(res_failure$content)
  data_fail <- jsonlite::fromJSON(rawToChar(res_failure$content))
  data_launch_fail <- data_fail$results
  
  ##combining fail and success
  data_pns <- dplyr::bind_rows(data_launch, data_launch_fail)
  
  ##making data frame with only useful columns and better names
  data_rockets <- as.data.frame(cbind(data_pns$name, data_pns$status$id, data_pns$status$abbrev, data_pns$window_end, data_pns$failreason, data_pns$launch_service_provider$name, data_pns$launch_service_provider$type, data_pns$mission$description, data_pns$mission$type, data_pns$pad$latitude, data_pns$pad$longitude, data_pns$image))
  names <- c("name","success_id","success_abbrev","time_of_launch","failreason","provider_name","provider_category","mission_description", "mission_purpose","latitude","longitude","image_URL")
  colnames(data_rockets) <- names
  data_rockets$latitude <- as.numeric(data_rockets$latitude)
  data_rockets$longitude <- as.numeric(data_rockets$longitude)
  data_rockets$month <- as.numeric(sapply(strsplit(data_rockets$time_of_launch, "-"), "[[", 2))
  
  return(data_rockets)
}


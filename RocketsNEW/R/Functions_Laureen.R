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


#' @title get_GUI
#' @description Function to Call the Shiny App "Rocket Launches 2024".
#' @param none no parameters needed
#' @return Returns a GUI of a Shiny App that displays rocket launches on a world map. These can be filtered according to success, provider & time frame.
#' @examples
#' # get_GUI()
#' @note If Error occurs: "Error in curl::curl_fetch_memory(url, handle = handle) : etc", run get_GUI() again until the data is returned.
#' @export
get_GUI <- function(){
  
  tempdir(check = TRUE)
  library(dplyr)
  library(bslib)
  
  data_rockets <- getRocketData()
  
  ##shiny app 
  ui <- shiny::fluidPage(
    
    theme = bslib::bs_theme(
      bootswatch = "flatly",
      primary = "#2C3E50"
    ),
    
    tags$style(HTML("
    #map {
      height: calc(100vh - 80px) !important;
    }
    .leaflet-container {
      height: 100% !important;
      width: 100% !important;
    }
  ")),
    
    shiny::titlePanel(title = tags$h1(
      tags$b("Rocket Launches 2024"),
      tags$style(HTML("h1 { text-align: center; }")))),
    
    shiny::sidebarLayout(
      
      sidebarPanel = shiny::sidebarPanel(
        shiny::helpText("You can filter the shown rocket launches according to the following options:"),
        shiny::br(),
        shiny::br(),
        shiny::sliderInput("month", "Months of 2024", min = 1, max = 12, value = c(1,5)),
        shiny::checkboxGroupInput("status", 
                                  label = "Launch Status", 
                                  choices = list("Success" = 3, 
                                                 "Failure" = 4),
                                  selected = c(3, 4)),
        shiny::checkboxGroupInput("category", 
                                  label = "Provider Category", 
                                  choices = unique(data_rockets$provider_category),
                                  selected = unique(data_rockets$provider_category)
        ),
        shiny::helpText("Click on the dots to get more information on the launched objects."),
        
        width = 3
      ),
      
      mainPanel = shiny::mainPanel(
        leaflet::leafletOutput(outputId = "map"),
        width = 9
      )
    )
  )
  
  
  
  server <- function(input, output){
    
    map_df <- shiny::reactive({
      
      data_rockets %>%
        dplyr::filter(month >= input$month[1] & month <= input$month[2]) %>%
        dplyr::filter(success_id %in% input$status) %>%
        dplyr::filter(provider_category %in% input$category)
      
    })
    
    output$map <- leaflet::renderLeaflet({
      
      leaflet::leaflet() %>%
        leaflet::addTiles() %>%
        leaflet::setView(lng = 15, lat = 10, zoom = 1.5) %>%
        leaflet::addCircleMarkers(data = map_df(), 
                                  ~longitude, 
                                  ~latitude, 
                                  radius = 3,
                                  color = ~ifelse(success_id == 3, "green", "red"),
                                  popup = ~paste(
                                    "<strong>Name:</strong>", name, "<br>",
                                    "<strong>Status:</strong>", success_abbrev, "<br>",
                                    "<strong>Time of Launch:</strong>", time_of_launch,"<br>",
                                    "<strong>Provider Type:</strong>", provider_category, "<br>",
                                    "<strong>Provider Name:</strong>", provider_name, "<br>",
                                    "<strong>Purpose:</strong>", mission_purpose,"<br>",
                                    "<strong>Description:</strong>", mission_description,"<br>",
                                    "<img src =", image_URL, "width = '100px'>"
                                  ))
      
    })
    
  }
  
  shiny::shinyApp(ui, server)
  
}
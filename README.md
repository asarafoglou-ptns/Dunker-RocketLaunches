# Dunker-RocketLaunches
R package to display rocket launches in 2024 on a world map. 

Purpose: Getting useful and interesting information on what is being launched into earth orbit and space. Filter the launches of 2024 according to your specific interests.

Individual: Person interested in space exploration, commercial, governmental, and other rocket launches. 

Equipment: Any Computer with R & RShiny. The packages: curl (functionality), dplyr (for data handling), httr (to get current API data), jsonlite(to convert current API data), shiny (to run application), leaflet (to load interactive map), bslib (for application design) & ggplot (to generate statistical plots) are needed.

Scenario: 
1.	User opens program.
2.	The "map" tab is open by default.
3.	A map with all rocket launches from 2024 so far is displayed (default setting is start of 2024 until may, with both successful and failed launches from all provider categories, i.e. commercial, governmental, private). 
4.	The user filters the shown rocket launches (this step can be skipped, then the program will only display the object launches with the default filters).
  a.	They select the timeframe 03/2024-05/2024. Only months can be filtered.
  b.	They select successful launches.
  c.	They don't filter specific provider categories.
5.	The map will refresh and display only successful launches from the chosen months from all provider categories with dots.
6.	Users can zoom in and out of the map with hand motions on their touchpad or with the scaling buttons. 
7.	Users can look at different locations by moving the map with their touchpad.
8.	Users can click the individual rocket launches/dots.
9.	A small pop-up window will open with further information on the launched object, including its name, a picture, the launch service provider type & name, purpose, exact date, success statement and a detailed description of the object and the launch.
10.	The user can close the window by clicking on another rocket launch, by closing the window with a closing button or by simply clicking somewhere outside of the pop-up window. 
11.	The user can additionally click on the "statistics" tab to get graphical plots about the rocket launches in 2024.

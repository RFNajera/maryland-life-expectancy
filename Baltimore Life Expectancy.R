# Mapping Baltimore Life Expectancy
# Data from CDC USALEEP (https://www.cdc.gov/nchs/nvss/usaleep/usaleep.html)

# Libraries
library(rgdal)
library(tidyverse)
library(ggmap)
library(leaflet)
library(leaflet.extras)
library(tigris)

# Bring in the Maryland life expectancy data and Baltimore shapefile

md_leep <- read.csv("data/md_life_expect.csv", stringsAsFactors = FALSE)
baltimore_shp <- readOGR("data/baltimore_census_tracts", "2010_Census_Profile_by_Census_Tracts")
maryland_shp <- readOGR("data/md_census_tracts", "cb_2017_24_tract_500k")

#TRACT2KX in "md_leep" = TRACTCE in "maryland_shp"
#Tract.ID in "md_leep" = GEOID in "maryland_shp"

# Join the data

maryland_shp2 <- geo_join(maryland_shp, md_leep, "GEOID", "Tract.ID", how = "left")

# Palette for colors

pal <- colorNumeric("YlGnBu", domain = maryland_shp2$e.0., na.color = "transparent")

# Map the data

map <- leaflet()%>%
  setView(lat = 39.2894971, lng = -76.6160737, zoom = 12) %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = maryland_shp2,
              color = "black",
              fillColor = ~pal(maryland_shp2$e.0.),
              weight = 1,
              opacity = 1,
              fillOpacity = 1,
              popup = paste("Life Expectancy = ",maryland_shp2$e.0., " years")
              
  ) %>%
  addLegend(data = na.omit(maryland_shp2),
            position = "topright",
            values = maryland_shp2$e.0.,
            pal = pal,
            title = "Life Expectancy",
            labFormat = labelFormat(suffix = " Years"),
            opacity = 1,
            layerId = "layer_legend"
  ) %>%
  addEasyButton(easyButton
                (icon="fa-map-marker",
                  title="Re-Center Map",
                  onClick=JS("function(btn, map){
                             map.setView([39.2894971,-76.6160737],12); 
                             }")
                    )
                  ) #Easybutton centers on Baltimore

map


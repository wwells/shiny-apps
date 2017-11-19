library(xts)
library(shiny)
library(dplyr)
library(leaflet)

all <- readRDS("Data/GunsGeo.rds")

## Behavoir?
#  Radial size by Injured vs Killed
#  Coloring by Threshold for Injured vs Killed?
##     Legend, if gradation?
#  Subset by Year?   Is that important?
#  Initial page serve:   Have all Plotted?  


#https://stackoverflow.com/questions/41021237/animated-marker-moving-and-or-path-trajectory-with-leaflet-and-r
# define ui with slider and animation control for time
ui <- navbarPage("US Gun Violence", id="nav",
        tabPanel("Interactive Map",
            div(class="outer",
                tags$head(
                    # Include our custom CSS
                    includeCSS("Assets/styles.css")
                     ),
                leafletOutput("map", width="100%", height="100%"), 
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                          draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                          width = 330, height = "auto",
                h2("Gun Data Explorer"),
                radioButtons("incidentweight", "Incident Radial Weight:",
                                   c("Killed", "Injured"), selected = "Killed"),
                sliderInput(inputId = "date", label = "Time", min = min(all$Date), 
                            max = max(all$Date),
                            value = min(all$Date),
                            step=86400 * 7 * 4, # set to increment by 60 seconds, adjust appropriately
                            animate=T),
                radioButtons("showall", "Show All Incidents: ",
                             "Show All")
                ),
                tags$div(id="cite",
                         'Data source:  The Gun Violence Archive, 2014-2017.'
                )
            )
        ),
        tabPanel("About",
            fluidRow(
                column(12,
                    h3("Data Source"),
                    div(HTML("<a href='http://www.gunviolencearchive.org/methodology'>The Gun Violence Archive</a>")),
                    p(" The archive provides some data on gun violence via their website. This application maps all available data from  
                      2014-2017 data. There are about ~1200 observations in this aggregated dataset."),
                    h3("What is a Mass Shooting?"),
                    p("GVA uses a purely statistical threshold to define mass shooting based ONLY on the numeric value of 4 or more shot 
                      or killed, not including the shooter. GVA does not parse the definition to remove any subcategory of shooting. To 
                      that end we don’t exclude, set apart, caveat, or differentiate victims based upon the circumstances in which they were shot."),
                    h3("Data Citation"),
                    h4("Gun Violence Archive Mission Statement:"),
                    p("Gun Violence Archive (GVA) is a not for profit corporation formed in 2013 to provide online public access to accurate information
                        about gun-related violence in the United States. GVA will collect and check for accuracy, comprehensive information about gun-related violence in the 
                        U.S. and then post and disseminate it online, primarily if not exclusively on this website and summary ledgers at www.facebook.com/gunviolencearchive. 
                        It is hoped that this information will inform and assist those engaged in discussions and activities concerning gun violence, including analysis of 
                        proposed regulations or legislation relating to gun safety usage. All we ask is to please provide proper credit for use of Gun Violence Archive data and 
                        advise us of its use.
                      
                        GVA is not, by design an advocacy group. The mission of GVA is to document incidents of gun violence and gun crime nationally to provide independent, 
                        verified data to those who need to use it in their research, advocacy or writing.
                      "),
                    h3("Source Code"),
                    div(HTML("<a href='https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example'>MYREPO</a>")),
                    h3("References"),
                    div(HTML("<a href='https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example'>Shiny-R SuperZip Example</a>"))
                ))
        )
)

server <- function(input, output, session) {
    points <- reactive({
        all %>% 
            filter(Date == input$date)
    })
    
    history <- reactive({
        all %>%
            filter(Date <= input$date)
    })
    
    radialweight <- reactive({
        input$incidentweight
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
                     attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>%  # Add default OpenStreetMap map tiles%>%
            addCircles(lng = ~lon,
                       lat = ~lat,
                       weight = ~radialweight(),
                       popup= ~Content,
                       stroke = TRUE, 
                       fillOpacity = 0.8,
                       data = points()) %>%
            addCircles(lng = ~lon,
                       lat = ~lat,
                       weight = ~radialweight(),
                       popup= ~Content,
                       stroke = TRUE, 
                       fillOpacity = 0.8,
                       data = history()) %>%
            setView(lng = -83.7129, lat = 37.0902, zoom = 4)
    })
    
    observe({
        leafletProxy("map", data = points()) %>%
            clearShapes() %>%
            addCircles(lng = ~lon,
                       lat = ~lat,
                       weight = ~radialweight(),
                       popup= ~Content,
                       stroke = TRUE, 
                       fillOpacity = 0.8,
                       data = history()
            )
    })
}

shinyApp(ui, server)
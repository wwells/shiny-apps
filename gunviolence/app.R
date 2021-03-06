library(xts)
library(shiny)
library(dplyr)
library(leaflet)
library(RColorBrewer)

all <- readRDS("Data/GunsGeo.rds")

ui <- navbarPage("US Gun Violence", id="nav",
        tabPanel("Interactive Map",
            div(class="outer",
                tags$head(
                    includeCSS("Assets/styles.css")
                     ),
                leafletOutput("map", width="100%", height="100%"), 
                absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                          draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                          width = 330, height = "auto",
                    h2("US Gun Violence"),
                    h4("2014-2017"),
                    radioButtons("incidentweight", "Incident Factor:",
                                       c("Killed"="Killed", "Injured"="Injured"), selected = "Killed", inline=TRUE),
                    sliderInput(inputId = "date", label = "Animate", min = min(all$Date), 
                                max = max(all$Date),
                                value = max(all$Date),
                                ticks = F,
                                step=365/12, 
                                animate = animationOptions(interval = 1000,
                                                           playButton = icon('play', "fa-3x"),
                                                           pauseButton = icon('pause', "fa-3x"))),
                    textOutput("counts")
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
                    div(HTML("<a href='https://github.com/wwells/shiny-apps/tree/master/gunviolence'>https://github.com/wwells/shiny-apps/tree/master/gunviolence</a>")),
                    h3("References"),
                    div(HTML("<a href='https://github.com/rstudio/shiny-examples/tree/master/063-superzip-example'>Shiny-R SuperZip Example</a>"))
                ))
        )
)

server <- function(input, output, session) {
    history <- reactive({
        all %>%
            filter(Date <= input$date)
    })
    
    color <- reactive({
        if (input$incidentweight == "Killed") {
            col = "OrRd"
        } else {
            col = "YlGn"
        }
    })
    
    sc <- reactiveVal(7000)
    
    observeEvent(input$incidentweight, {
        if (input$incidentweight == "Killed") {
            newValue <- 7000
            sc(newValue)
        } else {
            newValue <- 4000
            sc(newValue)
        }
    })
    
    name <- reactive({
        if (input$incidentweight == "Killed") {
            nam = "Killed"
        } else {
            nam = "Injured"
        }
    })
    
    output$counts <- renderText({
        c <- sum(history()[[input$incidentweight]])
        paste("Total ", name(), ": ", c)
    })
    
    colorpal <- reactive({
        colorNumeric(color(), all[[input$incidentweight]])
    })
    
    output$map <- renderLeaflet({
        leaflet() %>%
            addTiles('http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 
                     attribution='Map tiles by <a href="http://stamen.com">Stamen Design</a>, <a href="http://creativecommons.org/licenses/by/3.0">CC BY 3.0</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>') %>%  # Add default OpenStreetMap map tiles%>%
            addLegend(position = "bottomright",
                      pal = colorpal(), values = all[[input$incidentweight]],
                      title = name()) %>%
            setView(lng = -83.7129, lat = 37.0902, zoom = 4)
    })
    
    observe({
        pal <- colorpal()
        proxy <- leafletProxy("map", data = history()) 
        proxy %>%
            clearShapes() %>%
            addCircles(lng = ~lon,
                       lat = ~lat,
                       radius = ~history()[[input$incidentweight]] * sc(),
                       weight = 1,
                       popup= ~Content,
                       color = "#777777",
                       fillColor = ~pal(history()[[input$incidentweight]]),
                       stroke = F, 
                       fillOpacity = 0.7,
                       data = history()
            ) 
    })
}

shinyApp(ui, server)
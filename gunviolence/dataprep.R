# compile data from gunviolence archive, ping google api to get lat lon
if (!require('plyr')) install.packages('plyr')
if (!require('dplyr')) install.packages('dplyr')
if (!require('ggmap')) install.packages('ggmap')

DataPrep <- function(all) {
    # takes raw data, gets lat lon, then cleans and prepares for viz 
    #
    # Args: 
    #   all:  dataframe representing raw
    #   
    # Returns:
    #   df:   prepared data
    
    all$FullAddress <- paste0(all$Address, ", ", all$City.Or.County, ", ", all$State)
    geo_reply <- geocode(all$FullAddress, override_limit=TRUE)
    all <- cbind(all, geo_reply)
    
    complete <- complete.cases(all)
    completed <- all[complete,]
    incomplete <- all[!complete,]
    
    all <- select(all, Incident.Date, FullAddress, lat, lon, X..Killed, X..Injured)
    names(all) <- c("Date", "Address", "lat", "lon", "Killed", "Injured")
    
    #all$Date <- as.Date(all$Date, format="%d-%B-%y")
    all$Date <- as.Date(all$Date, format = "%B %d, %Y") #new 2017 format
    #all$Date <- as.POSIXct(all$Date, format="%Y-%m-%d") #needed for animation?
    all <- all[order(all$Date), ]
    
    all$Content <- paste0("<b>Date: </b>", all$Date, "<br/>",
                          "<b>Killed: </b>", all$Killed, "<br/>",
                          "<b>Injured: </b>", all$Injured, "<br/>",
                          "<b>Location: </b>", all$Address)
    df <- all
    df
}

## Prep Data

### To cut down on API calls, advance prep data < 2017
if (file.exists("Data/GunsStatic.rds")) {
    print ("2014-2016 Gun Data Already Prepared.")
    GunStatic <- readRDS("Data/GunsStatic.rds") 
} else {
    print ("GeoCoding 2014-2016...")
    staticList <- c("Data/GVA-2014.csv", "Data/GVA-2015.csv", "Data/GVA-2016.csv")
    staticDF <- data.frame()
    for (i in staticList) {
        df <- read.csv(i)
        staticDF <- rbind(staticDF, df)
    }
    
    GunStatic <- DataPrep(staticDF)
    saveRDS(GunStatic, "Data/GunsStatic.rds")
}

### Prep 2017
new <- read.csv("Data/GVA-2017.csv")
new <- DataPrep(new)

newcomplete <- complete.cases(new)
newcomplete <- new[newcomplete,]
newincomplete <- new[!newcomplete,]

all <- rbind(GunStatic, newcomplete)
all <- all[order(all$Date), ]

# return only those finished (remove once api limit reset)
#complete <- complete.cases(all)
#completedf <- all[complete,]

saveRDS(all, "Data/GunsGeo.rds")
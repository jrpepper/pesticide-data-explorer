#global.R

##Propeller Health Scripts

#load libraries
library(ggplot2)
library(maptools)
library(sp)
library(plyr)
library(ggmap)
library(leaflet)
library(magrittr)
library(Hmisc)
library(reshape2)

#if csv files aren't there, download raw data from PUR website
##############

#generate fake data
source("./generateFakeData.R") #creates variable fakeData

#Load PUR Data
allPUR <- read.csv("./data/PUR2012.csv")
PUR <- subset(allPUR, allPUR$base_ln_mer!="") #get subset of pesticides that have values for MTRS
PUR <- subset(PUR, is.na(PUR$outlier)) #remove outliers

#fix MTRS field by adding preceding zeros
PUR$range <- formatC(PUR$range, digits = 1, flag = "0")
PUR$township <- formatC(PUR$township, digits = 1, flag = "0")
PUR$section <- formatC(PUR$section, digits = 1, flag = "0")

#Create MTRS Field
PUR$MTRS <- paste(PUR$base_ln_mer, PUR$township, PUR$tship_dir, PUR$range, PUR$range_dir, PUR$section, sep="") #create MTRS field
#PUR$township[(PUR$township<10),]


##Prepare PUR Data for merging with PLSS data
#filter by counties
#PUR <- subset(PUR, (county_cd=="07"|county_cd=="28"|county_cd=="34"|county_cd=="48"|county_cd=="49"|county_cd=="57"))
PUR <- subset(PUR, (county_cd=="34"|county_cd=="48"|county_cd=="51"|county_cd=="57"))
#PUR <- subset(PUR, (PUR$chem_code=="253" | PUR$chem_code=="573" |PUR$chem_code=="616"))

#filter out most of the columns
PUR <- PUR[,c("use_no","chem_code","lbs_chm_used","acre_treated","MTRS","county_cd")]

###LOAD PLSS DATA
#load PLSS SUBSET files.
PLSS <- read.csv("./data/centroids-2.csv")
PLSS <- subset(PLSS, (COUNTY_CD=="34"|COUNTY_CD=="48"|COUNTY_CD=="51"|COUNTY_CD=="57"))
PLSS <- PLSS[,c("MTRS","long","lat")]

#remove duplicate MTRS values
PLSS <- PLSS[!duplicated(PLSS$MTRS),]

###COMBINE PLSS AND PUR
PUR <- join(PLSS, PUR)

PUR <- PUR[!is.na(PUR$lbs_chm_used),] #remove rows with NA value for lbs chem used
PUR <- PUR[!is.na(PUR$acre_treated),] #remove rows with NA value for lbs chem used

#add chemical names
chemNames <- read.csv("./data/chemNames.csv")
PUR <- merge(PUR,chemNames, all.x=TRUE)

#add county names
countyNames <- read.csv("./data/countyNames.csv")
PUR <- merge(PUR,countyNames, all.x=TRUE)

#make lists for UI
namesList <- (unique(PUR$chem_name)) #get unique list of all chemical names, for chemical input in UI
namesList <- as.vector(namesList[!is.na(namesList)]) #remove NA and turn into vector

countyList <- (unique(PUR$county_name)) #get unique list of all county names, for chemical input in UI
countyList <- as.vector(countyList[!is.na(countyList)]) #remove NA and turn into vector

#melt and cast PUR data into PUR.c
PUR.m <- melt(PUR, id=c("use_no","MTRS","lat","long","chem_code","county_cd","chem_name","county_name"))
PUR.c <- dcast(PUR.m, MTRS + lat + long + county_cd + chem_code + chem_name + county_name ~ variable , sum)
PUR.c <- PUR.c[(!is.na(PUR.c$acre_treated) | !is.na(PUR.c$lbs_chm_used)), ]

#remove chemicals with only one application in a county -- not idea, but better than breaking the App...
PUR.count <- dcast(PUR.m, chem_name + county_name ~ variable, length, fill=0, drop=FALSE)
PUR.count <- subset(PUR.count, PUR.count$county_name %in% countyList)
onlyOneApp <- PUR.count[PUR.count$acre_treated<=1,"chem_name"]
PUR.c <- subset(PUR.c, !(PUR.c$chem_name %in% as.vector(onlyOneApp)))


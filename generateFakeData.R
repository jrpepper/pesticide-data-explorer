numPoints <- 800

fakePesticideData <- data.frame(lat = runif(numPoints, 38.4, 39))
fakePesticideData$long <- runif(numPoints, -122, -121.3)
fakePesticideData$person <- c(rep("Jake",numPoints/4), rep("Seema",numPoints/4), rep("Cesar",numPoints/4), rep("Lisa",numPoints/4))

#generate random date
rand.date=function(start.date,end.date,data){   
  size=dim(data)[1]    
  days=seq.Date(as.Date(start.date),as.Date(end.date),by="day")  
  pick.date=runif(size,1,length(days))  
  date=days[pick.date]  
}

fakePesticideData$date=rand.date("2012-01-01","2013-12-31",fakePesticideData)
fakePesticideData$hour=round(runif(400, 0, 23))
fakePesticideData$minute=round(runif(400,0,59))

fakeData <- fakePesticideData

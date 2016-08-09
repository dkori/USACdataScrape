#install.packages("RSelenium")
#install.packages("RCurl")
#install.packages("readxl")
install.packages("XML")
install.packages("dplyr")

require("dplyr")
require("RSelenium")
require("readxl")
require("RCurl")
require("XML")

# make sure you have the server
checkForServer()
#create download directory

states<-c("AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "GU", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MP", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY")
years<-2010
for(year in years){
  print(year)
  system(paste("mkdir /users/shared/temp/",year,sep=""))
  for(state in states){
    print(state)
    fprof <- makeFirefoxProfile(list(browser.download.dir = paste("/users/shared/temp/",year,sep="")
                                     ,  browser.download.folderList = 2L
                                     , browser.download.manager.showWhenStarting = FALSE
                                     , browser.helperApps.neverAsk.saveToDisk = "text/plain"))
    
    startServer()
    
    remDr <- remoteDriver(extraCapabilities = fprof)
    
    # use default server 
    
    url<-"http://www.slforms.universalservice.org/DRT/Default.aspx"
    #url<-"http://google.com"
    remDr$open(silent = TRUE) #opens a browser
    remDr$navigate(url)
    
    
    var<-c('//*/option[@value = ')
    
    State_Str<-paste(var,"'",state,"'","]",sep="")
    Year_Str<-paste(var,"'",year,"'","]",sep="")
    
    iframe <- remDr$findElement(using='id', value="ctl00_ContentPlaceHolder_ddlFundingYear")
    #remDr$switchToFrame(iframe)
    
    option <- remDr$findElement(using = 'xpath', Year_Str)
    option$clickElement()
    
    
    
    iframe <- remDr$findElement(using='id', value="ctl00_ContentPlaceHolder_ddlState")
    state="AL"
    option <- remDr$findElement(using = 'xpath', State_Str)
    option$clickElement()
    #option <- remDr$findElement(using = 'xpath', "//*/option[@value = state]")
    
    
    
    option$clickElement()
    
    searchID<-'//*[@id="ctl00_ContentPlaceHolder_cbSelectDatapoints"]'
    webElem<-remDr$findElement(value = searchID)
    webElem$clickElement()
    
    
    searchID<-'//*[@id="ctl00_ContentPlaceHolder_cbAll"]'
    webElem<-remDr$findElement(value = searchID)
    webElem$clickElement()
    
    searchID<-'//*[@id="ctl00_ContentPlaceHolder_rblReportFormat_2"]'
    webElem<-remDr$findElement(value = searchID)
    webElem$clickElement()
    
    searchID<-'//*[@id="ctl00_ContentPlaceHolder_bSearch"]'
    webElem<-remDr$findElement(value = searchID)
    webElem$clickElement()
    
    setwd(paste("/users/shared/temp/",year,sep=""))
    
    check_part<-length(list.files(pattern="*.part"))
    while(check_part != 0){
      check_part<-length(list.files(pattern="*.part"))
    }
    system("pkill -f firefox")
  }
}
for(year in years){
  setwd(paste("/users/shared/temp/",year,sep=""))
  list_files<-list.files(pattern = "*.xml")
  
  fullData<-xmlToDataFrame(list_files[1])[1,]
  
  
  for(file in list_files){
    TempData<-xmlToDataFrame(file)
    if(ncol(TempData)!=ncol(fullData)){
      TempData_Cols<-colnames(TempData)
      fullData_Cols<-colnames(fullData)
      diff_cols<-setdiff(fullData_Cols,TempData_Cols)
      for(x in diff_cols){
        
        TempFrame<-as.data.frame(rep("missing",nrow(TempData)))
        colnames(TempFrame)<-x
        TempData=cbind(TempData,TempFrame)
      }
    }
    fullData<-rbind(fullData,TempData)
  }
  #write full data
  #remove(fullData)
}
colnames(TempFrame)
data1<-xmlToDataFrame(list_files[1])

data4<-xmlToDataFrame(list_files[4])

data1_col<-colnames(data1)
data4_col<-colnames(data4)
setdiff(data1_col,data4_col)

data2<-xmlToDataFrame("/users/shared/Inquiry_8_8_2016_13_25_42.xml")

list_files<-list.files()
print(years)

for(state in states){
  for(year in years){
    print(paste(state,year))
  }
}

data.frame(nrows)


#this program requires the Java Developer Kit be installed on the machine running it.  
#install.packages("RSelenium")
#install.packages("RCurl")
#install.packages("readxl")
#install.packages("XML")
#install.packages("dplyr")
#install.packages("xlsx")
#install.packages("rJava")
#install.packages("readr")
#install.packages("sqldf")
require("readr")
require("dplyr")
require("RSelenium")
require("readxl")
require("RCurl")
require("XML")
require("xlsx")
require("rJava")
require("sqldf")

# make sure you have the server
checkForServer()

#list of all states
states<-c("AK", "AL", "AR", "AS", "AZ", "CA", "CO", "CT", "DC", "DE", "FL", "GA", "GU", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MP", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VI", "VT", "WA", "WI", "WV", "WY")
#desired years to retrieve
years<-2009:2015

for(year in years){
  print(year)
  #create download directory
  system(paste("mkdir /users/shared/demo/",year,sep=""))
  for(state in states){
    #if((year!=2013 || state!="PA")&&(year!=2015 || state!="CA")){
      print(state)
      fprof <- makeFirefoxProfile(list(browser.download.dir = paste("/users/shared/demo/",year,sep="")
                                       ,  browser.download.folderList = 2L
                                       , browser.download.manager.showWhenStarting = FALSE
                                       , browser.helperApps.neverAsk.saveToDisk = "application/vnd.ms-excel"))
      
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
      
      searchID<-'//*[@id="ctl00_ContentPlaceHolder_rblReportFormat_1"]'
      webElem<-remDr$findElement(value = searchID)
      webElem$clickElement()
      
      searchID<-'//*[@id="ctl00_ContentPlaceHolder_bSearch"]'
      webElem<-remDr$findElement(value = searchID)
      webElem$clickElement()
      
      setwd(paste("/users/shared/temp/",year,sep=""))
      
      #determines if the download is complete or not by checking if there is a ".part" file in the download directory
      #ends firefox session when download is complete
      check_part<-length(list.files(pattern="*.part"))
      while(check_part != 0){
        check_part<-length(list.files(pattern="*.part"))
      }
      system("pkill -f firefox")
     # }
  }  
}

#combines all state data into one data file for each year
for(year in years){
  print(year)
  setwd(paste("/users/shared/temp/",year,sep=""))
  getwd()
  list_files<-list.files(pattern = "*.tsv")
  
  fullData<-read_tsv(list_files[1])[1,]
  

  for(file in list_files){
    print(file)
    t<-try(read_tsv(file))
    if("try-error" %in% class(t)){
      error_list<-c(paste(error_list,year,file))
    }else
      TempData<-read_tsv(file)
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
  #Make Original Request Numeric
  OrigReq<-as.numeric(gsub('[$,]', '',fullData$`Orig Commitment Request` ))
  fullData$`Orig Commitment Request`<-OrigReq
  #Make Committed Amount Numeric
  Committed<-as.numeric(gsub('[$,]', "",fullData$`Committed Amount`))
  fullData$`Committed Amount`<-Committed
  #write full data
  write.csv(fullData,file=paste('/users/shared/temp/',year,'ALL.csv',sep=""))
  #remove(fullData)
  remove(fullData)
  remove(TempData)
}

#Requested and Committed Funds by Year
for(year in years){
  #read in year data
  year_full<-read_csv(paste('/users/shared/temp/',year,'ALL.csv',sep=""))
  if(year==2009){
    year_sum<-data.frame(dat_year=paste(year))
    
    year_temp<-sqldf('select sum("Orig Commitment Request") as "request",sum("Committed Amount") as "commitment" from year_full')
    
    year_all<-cbind(year_sum,year_temp)
  }else{
    year_temp<-sqldf('select sum("Orig Commitment Request") as "request",sum("Committed Amount") as "commitment" from year_full')
    year_sum<-data.frame(dat_year=paste(year))
    year_sum<-cbind(year_sum,year_temp)
    year_all<-rbind(year_all,year_sum)
  }
}
print(year_all)





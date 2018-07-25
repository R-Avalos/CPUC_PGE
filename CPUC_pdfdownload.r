# PDF Download and save to local directory

library(RCurl)
library(lubridate)
library(dplyr)
library(tidyr)
library(tibble)
library(feather)
library(tm)
# library(httr) #best used for API

######## Create function to download each year-month and store to directory


ftp_url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"# base url
local_directory <- "D:/CPUC_PGE/CPUC_repo/CPUC_PGE" #set directory for storage


### Function specific to this FTP site to download files
# Function will first create the folder in the working directory for the year month
# Once that is created, the function will get a list of PDF files from the FTP directory (removing the excel files) and download the pdfs to the local directory

FTP_downloadandstore_pdf_func <- function(download_url = ftp_url, year_in_digits = 2010, month_as_character = "01") {
        require(RCurl) #load package
        url_long <- paste0(download_url, "/", as.character(year_in_digits), "/",
                           month_as_character, "/") #paste url, with month year_in_digits into a string
        
        # Setup the local directory
        directory_year <- paste0(local_directory, 
                                  "/", 
                                  as.character(year_in_digits), 
                                  "/") #create character of the "local_directory/year/"
        ifelse(!dir.exists(file.path(directory_year)), 
               dir.create(file.path(directory_year)), 
               FALSE) # Create the year directory if it does not extist
        ifelse(!dir.exists(file.path(directory_year, month_as_character)), 
               dir.create(file.path(directory_year, month_as_character)), 
               FALSE) # Create month directory if it does not exist in the year directory
        setwd(file.path(directory_year, month_as_character)) #move to the directory
        print(getwd()) #print the current directory as a check
        
        ###### Get list of files from site and download
        site <- getURL(url = url_long,
                       ftp.use.epsv = FALSE,
                       dirlistonly = TRUE) # Get list of files on site
        site_split <- unlist(strsplit(site, "\\\r")) #split list
        site_split <- gsub("\\\n", "", site_split) #remove headers
        site_split_PDF <- Filter(function(x) !any(grepl(".xls", x)), site_split) #remove xls files
        
        
        # requires downloadtoPDF function 
        downloadPDF <- function(x) {
                curl::curl_download(url = paste0(url_long, x),
                                    destfile = x)
        }
        
        sapply(site_split_PDF, downloadPDF) # download each file in the list and save to local directory (printed in above check)
}



getwd()
setwd("D:/CPUC_PGE/CPUC_repo/CPUC_PGE")

####### break out function for testing
download_url = ftp_url
year_in_digits = 2010
month_as_character = "02"
#
url_long <- paste0(download_url, "/", as.character(year_in_digits), "/",
                   as.character(month_as_character), "/")

url_long
#
directory_year <- paste0(local_directory, 
                         "/", 
                         as.character(year_in_digits), 
                         "/") #create character of the "local_directory/year/"
directory_year
#
ifelse(!dir.exists(file.path(directory_year)), 
       dir.create(file.path(directory_year)), 
       FALSE) # Create the year directory if it does not extist

ifelse(!dir.exists(file.path(directory_year, month_as_character)), 
       dir.create(file.path(directory_year, month_as_character)), 
       FALSE) # Create month directory if it does not exist in the year directory

setwd(file.path(directory_year, month_as_character)) #move to the directory
print(getwd()) #print the current directory as a check
#

# working
ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/2010/02/
ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/2010/2/
#####        

url_long
site <- getURL(url = url_long,
               verbose = TRUE,
               ftp.use.epsv = FALSE,
               dirlistonly = TRUE) # Get list of files on site
site_split <- unlist(strsplit(site, "\\\r")) #split list
site_split <- gsub("\\\n", "", site_split) #remove headers
site_split_PDF <- Filter(function(x) !any(grepl(".xls", x)), site_split) #remove xls files
year_variable = "2010"
month_variable = "02"

downloadPDF <- function(x) {
        curl::curl_download(url = paste0(url_long, x),
                            destfile = x)
}

sapply(site_split_PDF, downloadPDF)



####################################
# Call Function to download files to local storage
FTP_downloadandstore_pdf_func(year_in_digits = 2010, month_as_character = "01")
FTP_downloadandstore_pdf_func(year_in_digits = 2010, month_as_character = "02")


######### Automate Download for each year month cominbation
min(email_index$MasterDate) # firt year monnth = 2010, 01
max(email_index$MasterDate) # last year month = 2014, 09

### Dataframe of year month combinations
monthly_emails <- data.frame(unique(format(as.Date(email_index$MasterDate), "%Y-%m")))
colnames(monthly_emails)[1] <- "YearMonth"
monthly_emails <- monthly_emails %>%
        separate(YearMonth, into = c("Year", "Month"), sep = "-")
str(monthly_emails$Year)
### Apply function for each row of year month combination
apply(monthly_emails[1, c("Year", "Month")], 
                     1, 
                     function(y) FTP_downloadandstore_pdf_func(y['Year'], y['Month'])
      )

# PDF Download and save to local directory

library(RCurl)
library(lubridate)
library(dplyr)
library(feather)
library(tm)
# library(httr) best used for API

## Create function to download each year-month and store to directory
url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"# base url
# Year Month /2010/01/
year2010_1 <- "/2010/01/"

setwd("./PDF_2010")
setwd("..") #back to home

# Create list of 2010 emails
#pdfs2010_1 <- subset(email_index, MasterDate >= ymd("2010/1/1") & MasterDate < ymd("2010/2/1")) 

# Get list from url
#library(httr)
site <- getURL(url = paste0(url, year2010_1), ftp.use.epsv = FALSE, dirlistonly = TRUE)
str(site)

site2 <- unlist(strsplit(site, "\\\r")) # split list
head(site2)
site2 <- gsub("\\\n", "", site2) # remove headers

# we have PDF and XLS files .... keep both, but first make use of PDFs
site2PDF <- Filter(function(x) !any(grepl(".xls", x)), site2) #remove files that are TRUE or mathcing .xls
#y2 <- paste0(url, "/", y) #paste together full string
#head(site2PDF)

sapply(site2PDF, summary)


# Download PDF files
downloadPDF <- function(x) {
        curl_download(url = paste0(url, year2010_1, x), 
                      destfile = x)
}

downloadPDF(site2PDF[3])
curl_download(url = paste0(url, year2010_1, site2PDF[3]), 
              destfile = site2PDF[3])


download.file(url = site2PDF[3], destfile = paste0(getwd(), site2PDF[3]))
site2PDF[3]


# Download PDF files for January 2010
tail(site2PDF)
sapply(site2PDF, downloadPDF) # for each file in list, download and save to current directory


# Download XLS files

# Save into local SQL database
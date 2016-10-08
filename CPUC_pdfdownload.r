# PDF Download and save

library(RCurl)
library(data.table)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggthemes)
library(feather)
library(tm)
library(httr)

## Create function to download each year-month and store to directory
url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"
# Year Month /2010/01/
year2010_1 <- "/2010/01/"

setwd("./PDF_2010")
#setwd("..") #back to home

# Create list of 2010 emails
pdfs2010_1 <- subset(email_index, MasterDate >= ymd("2010/1/1") & MasterDate < ymd("2010/2/1")) 

# Get list from url
site <- getURL(url = paste0(url, year2010_1), ftp.use.epsv = FALSE, dirlistonly = TRUE)
str(site)

site2 <- unlist(strsplit(site, "\\\r")) # split list
head(site2)
site2 <- gsub("\\\n", "", site2) # remove headers

# we have PDF and XLS files .... keep both, but first make use of PDFs
y <- Filter(function(x) !any(grepl(".xls", x)), site2) #remove files that are TRUE or mathcing .xls


# Download PDF files
GET(url = paste0(url, year2010_1, "SB_GT&S_0000001.pdf"), write_disk(path = "SB_GT&S_0000001.pdf", overwrite = FALSE), progress())

# Download XLS files

# Save into local SQL database
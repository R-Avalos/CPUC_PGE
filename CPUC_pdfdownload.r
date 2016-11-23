# PDF Download and save to local directory

library(RCurl)
library(lubridate)
library(dplyr)
library(feather)
library(tm)
# library(httr) best used for API

######## Create function to download each year-month and store to directory
url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"# base url
local_directory <- "D:/CPUC_PGE/CPUC_PGE_ETL" #set directory for storage

# Year Month /2010/01/
# year2010_1 <- "/2010/01/"

#setwd("./PDF_2010")
#setwd("..") #back to home
#getwd() # D:/CPUC_PGE/CPUC_PGE_ETL

# Create list of 2010 emails
#pdfs2010_1 <- subset(email_index, MasterDate >= ymd("2010/1/1") & MasterDate < ymd("2010/2/1")) 


# Download PDF file function
downloadPDF <- function(x) {
        curl_download(url = paste0(url, "/", year, "/", month_in_digits,"/", x),
                      destfile = x)
}

# downloadPDF <- function(x) {
#         curl_download(url = paste0(url, year2010_1, x), 
#                       destfile = x)
# }


## Function specific to this FTP to download files
testfunction_pdf <- function(ftp_url = url, year = 2010, month_in_digits = 01) {
        require(RCurl)
        url_long <- paste0(ftp_url, "/", year, "/", month_in_digits, "/")
        
        # Setup the directory
        directory_year <- paste0(local_directory, 
                                  "/", 
                                  as.character(year), 
                                  "/")
        ifelse(!dir.exists(file.path(directory_year)), 
               dir.create(file.path(directory_year)), 
               FALSE) # Create the year directory if not existent
        ifelse(!dir.exists(file.path(directory_year, month_in_digits)), 
               dir.create(file.path(directory_year, month_in_digits)), 
               FALSE) # Create month direcotry if not existent
        setwd(file.path(directory_year, month_in_digits)) #move to the directory
        print(getwd()) #print the current directory
        
        # Get list of files from site and download
        site <- getURL(url = url_long,
                       ftp.use.epsv = FALSE,
                       dirlistonly = TRUE) # Get list of files on site
        site_split <- unlist(strsplit(site, "\\\r")) #split list
        site_split <- gsun("\\\n", "", site_split) #remove headers
        site_split_PDF <- Filter(function(x) !any(grepl(".xls", x)), site_split) #remove xls files
        # requires downloadtoPDF function 
        sapply(site_split_PDF, downloadPDF) # download each file in the list
}


# Function to download files to local storage
testfunction_pdf(year = 2010, month_in_digits = 02)


################## Convert to text files #############################
# Since the PDFs are saved as text type, instead of image, we can use pdftotext conversion software # Download: http://www.foolabs.com/xpdf/download.html, check out https://gist.github.com/benmarwick/11333467 for reference


dummy <- function(x){
        for(i in x){
        #convert to pdf
        #add to dataframe
                # file name | Text 
        } else
        {
                return(print("Failed"))
        }
}


# Tell R what folder contains your PDFs
dest <- "D:/CPUC_PGE/CPUC_PGE_ETL/PDF_2010"
# Create a list of PDF file names
myfiles <- list.files(path = dest, pattern = "pdf",  full.names = TRUE)
myfiles[1]
lapply(myfiles[2], function(i) system(paste('"C:/Program Files/xpdf/bin64/pdftotext.exe"', paste0('"', i, '"')), wait = FALSE) )


#### Read all text files into data frame, add column removing ".txt" as a key
library(readr)
file_names <- c("SB_GT&S_0000001.txt", "SB_GT&S_0000002.txt")
x <- read_file("PDF_2010/SB_GT&S_0000001.txt")
y <- read_file("PDF_2010/SB_GT&S_0000002.txt")
z <- c(x, y)

# create data frame of all files, from and to
x_df <- data.frame(file_names, z)




# Download XLS files

#### Setup SQL Database

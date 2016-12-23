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

### Function specific to this FTP site to download files
# Function will first creaet the folder in the working directory for the year month
# Once that is created, the function will select the PDF files (removing the excel files) and download the pdfs to the loca directory

FTP_downloadandstore_pdf_func <- function(ftp_url = url, year = 2010, month_in_digits = 01) {
        require(RCurl) #load package
        # require(lubridate)
        #convert month to digits
        # month_variable <- as.month(month_in_digits)
        # month_variable <- as.numeric(month_in_digits)
        url_long <- paste0(ftp_url, "/", year, "/", month_in_digits, "/") #paste url, with month year into a string
        
        # Setup the directory
        directory_year <- paste0(local_directory, 
                                  "/", 
                                  as.character(year), 
                                  "/") #create character of the "local_directory/year/"
        ifelse(!dir.exists(file.path(directory_year)), 
               dir.create(file.path(directory_year)), 
               FALSE) # Create the year directory if it does not extist
        ifelse(!dir.exists(file.path(directory_year, month_in_digits)), 
               dir.create(file.path(directory_year, month_in_digits)), 
               FALSE) # Create month directory if it does not exist in the year directory
        setwd(file.path(directory_year, month_in_digits)) #move to the directory
        print(getwd()) #print the current directory as a check
        
        # Get list of files from site and download
        site <- getURL(url = url_long,
                       ftp.use.epsv = FALSE,
                       dirlistonly = TRUE) # Get list of files on site
        site_split <- unlist(strsplit(site, "\\\r")) #split list
        site_split <- gsun("\\\n", "", site_split) #remove headers
        site_split_PDF <- Filter(function(x) !any(grepl(".xls", x)), site_split) #remove xls files
        
        # requires downloadtoPDF function 
        sapply(site_split_PDF, downloadPDF) # download each file in the list and save to local directory (printed in above check)
}


# Function to download files to local storage
FTP_downloadandstore_pdf_func(year = 2010, month_in_digits = 02)


################## Convert to text files #############################
# Since the PDFs are saved as text type, instead of image, we can use pdftotext conversion software # Download: http://www.foolabs.com/xpdf/download.html, check out https://gist.github.com/benmarwick/11333467 for reference


dummy <- function(file_folder){
        myfiles <- list.files(path = file_folder, pattern = "pdf", full.names = TRUE)
        #convert to pdf
        
        # add text files to dataframe
        mytxtfiles <- list.files(path = file_folder, pattern = "txt", full.names = TRUE)
        for(i in mytxtfilesx){
        #add to dataframe
                # file name | Text 
        } else
        {
                return(print("Conversion Failed"))
        }
        return(data_frame_of_textfiles) # unique name..
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

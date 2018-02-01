# PDF Download and save to local directory

library(RCurl)
library(lubridate)
library(dplyr)
library(tibble)
library(feather)
library(tm)
# library(httr) best used for API

######## Create function to download each year-month and store to directory

# Download PDF file function
downloadPDF <- function(x) {
        curl_download(url = paste0(url, "/", year, "/", month_in_digits,"/", x),
                      destfile = x)
}

url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"# base url
local_directory <- "D:/CPUC_PGE/CPUC_PGE_ETL" #set directory for storage


### Function specific to this FTP site to download files
# Function will first create the folder in the working directory for the year month
# Once that is created, the function will select the PDF files (removing the excel files) and download the pdfs to the local directory

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


# Call Function to download files to local storage
FTP_downloadandstore_pdf_func(year = 2010, month_in_digits = 02)


################## Convert to text files #############################
# Since the PDFs are saved as text type, instead of image, we can use pdftotext conversion software # Download: http://www.foolabs.com/xpdf/download.html, check out https://gist.github.com/benmarwick/11333467 for reference


dummy <- function(file_folder){
        library(readr)
        myfiles <- list.files(path = file_folder, 
                              pattern = "pdf", 
                              full.names = TRUE) # list files
        lapply(myfiles, function(i) system(paste('"C:/Program Files/xpdf/bin64/pdftotext.exe"', paste0('"', i, '"')), wait = FALSE) ) # convert to pdf
        
        # add text files to dataframe
        mytxtfiles <- list.files(path = file_folder, pattern = "txt", full.names = TRUE)
 ##################        
}
dummy


# Tell R what folder contains your PDFs
dest <- "D:/CPUC_PGE/CPUC_PGE_ETL/PDF_2010"
# Create a list of PDF file names
myfiles <- list.files(path = dest, pattern = "pdf",  full.names = TRUE)
myfiles[3]
lapply(myfiles, function(i) system(paste('"C:/Program Files/xpdf/bin64/pdftotext.exe"', paste0('"', i, '"')), wait = FALSE) ) # Make call to convert files from PDF TO Text files


#### Read all text files into data frame, add column removing ".txt" as a key
library(readr) #library to read in files
library(tibble) #library to save as tbl_df, aka tibble
getwd() # "D:/CPUC_PGE/CPUC_PGE_ETL"
setwd("D:/CPUC_PGE/CPUC_PGE_ETL/PDF_2010")

# Function to change individual text file into data frame and remove line breaks
file_convert <- function(file_name) {
        my_string <- read_file(file = file_name) # read file
        my_string <- as.character(my_string)
        my_string <- gsub("\r?\n|\r", " ", my_string) # remove line breaks
        text_name <- file_name # add variable for file anme
        data <- data_frame(text_name, my_string) 
        colnames(data) <- c("File", "Text") 
        return(data) 
}

# Load multiple files from folder into single table. 
# Table key is file name, content is email text
getwd()
setwd("D:/CPUC_PGE/CPUC_PGE_ETL/PDF_2010")# set to appropriate working directory
files = list.files(pattern = "*.txt") # list files
df <- lapply(files, file_convert) %>% bind_rows() #convert to data frame


# Download XLS files

#### Setup SQL Database

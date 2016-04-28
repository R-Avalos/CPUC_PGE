########################################################
##  PG&E and CPUC Email Conversion for Text Analysis ##
######################################################

##############  Overview ########################### 
# Practice ETL (Extract, Transform, LOad) using publicly available dataset


rm(list = ls()) # clear workspace
gc() # garbage collection, clear memory

library(RCurl)
library(data.table)




# Read first pdf #########################
# Base URL as of April 25, 2016
base.url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"

dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character
email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame
########################################################
##  PG&E and CPUC Email Conversion for Text Analysis ##
######################################################

##############  Overview ########################### 
# Practice ETL (Extract, Transform, LOad) using publicly available dataset


rm(list = ls()) # clear workspace
gc() # garbage collection, clear memory

library(RCurl)
library(data.table)
library(lubridate)
library(dplyr)
library(ggplot2)
library(stingr)


# Read first file #########################
# Base URL as of April 25, 2016
base.url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"
dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character

email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame
# save(email_index, file = "email_index.rda") # save file to local
load("email_index.rda")

SanBruno <- ymd("2010-09-09") #San Bruno explosion

# Transform ###############################
email_index$MasterDate <- mdy_hm(email_index$MasterDate) # convet to Date

email_index$YearMonthDay <- format(as.POSIXct(email_index$MasterDate, format="%Y-%m-%d"), format="%Y-%m-%d") #remove hours, minutes, seconds
email_index$YearMonthDay <- ymd(email_index$YearMonthDay) #convert to date

########### quick look at emails per day
# Sum emails by day
email_count <- email_index %>% 
        group_by(YearMonthDay) %>%
        summarise(emails = n())
plot(email_count)

#create plot
plotEmail <- ggplot(email_count, aes(x = YearMonthDay, y = emails)) +
        geom_point(alpha = 0.25) +
        geom_vline(aes(xintercept = as.numeric(SanBruno))) +
        ggtitle("CPUC and PG&E Communication \nEmails by Day")

#call plot
plotEmail

## Lets take apart the sender email into name and email address

x <- strsplit(email_index$Sender, "\\(")
head(x)
x <- matrix(unlist(x), ncol=2, byrow=TRUE)

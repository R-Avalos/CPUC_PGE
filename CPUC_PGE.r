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
library(tidyr)
library(ggplot2)
library(ggthemes)
library(stringr)


# Read first file #########################
# Base URL as of April 25, 2016
base.url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"
dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character

email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame
# save(email_index, file = "email_index.rda") # save file to local
remove(email_index)

load("email_index.rda")
SanBruno <- ymd("2010-09-09") #San Bruno explosion

# Transform ###############################

email_index$Recipient[email_index$Recipient==""] <- "Not Recorded (Not Recorded)" #stand in for missing receipent value
email_index$Sender[email_index$Sender==""] <- "Not Recorded (Not Recorded)"
email_index$Subject[email_index$Subject==""] <- "Not Recorded"
email_index$MasterDate <- as.Date(email_index$MasterDate, format = "%m/%d/%Y") # convet to Date

## Lets take apart the sender email into name and email address
email_index <- email_index %>%
        separate(Sender, into = c("Sender_Name", "Sender_Email"), sep = "\\(") # split sender into name and email
email_index$Sender_Email <- gsub("\\)", "",email_index$Sender_Email) # remove )
email_index$Sender_Email <- as.factor(email_index$Sender_Email) # factor emails

## Break apart ricipient
x <- email_index %>%
        separate_rows(Recipient, sep = ";")

### Remove RE: FW: 
# Split to new row, by "RE:" and "FW:", else place "New"


########### quick look at emails per day
# Sum emails by day
email_count <- email_index %>% 
        group_by(MasterDate) %>%
        summarise(emails = n_distinct(FileName))
plot(email_count)

#create plot
plotEmail <- ggplot(email_count, aes(x = MasterDate, y = emails)) +
        geom_point(alpha = 0.25) +
        geom_rangeframe() +
        geom_vline(aes(xintercept = as.numeric(SanBruno)), color = "red", alpha = 0.75) +
        ggtitle("CPUC and PG&E Communication \nEmails by Day") +
        theme_tufte()

plotEmail #call plot



## Count of not recorded
x <- email_index %>%
        group_by(Recipient=="Not Recorded")
x <- subset(x, `Recipient == "Not Recorded"`==TRUE) # get count of meails not recorded
summary(x) # 42% of the emails do not record recipient or sender


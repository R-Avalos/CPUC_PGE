# Download, transform, and load data


library(dplyr)
library(RCurl)
library(data.table)
library(lubridate)
library(feather)

###### Pull index data from ftp server and transfrom to usable data frame

## Read data from FTP and convert to data frame
base.url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"


#### Index of all Emails ####
# Pull an index of emails to use as reference for downloading
dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character

email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame

remove(dest_file) #clean up


# Transform data frame
email_index$Recipient_Name[email_index$Recipient_Name==""] <- "Not Recorded (Not Recorded)" #stand in for missing receipent name value
email_index$Sender_Name[email_index$Sender_Name==""] <- "Not Recorded (Not Recorded)"
email_index$Subject[email_index$Subject==""] <- "Not an Email"# observations without a subject assumed to be not emails between users
email_index$MasterDate <- as.POSIXct(email_index$MasterDate, format = "%m/%d/%Y %H:%M") # convet to date with time
email_index$Day <- floor_date(email_index$MasterDate, "days") # save date of email in new column
 
## Lets take apart the sender email into name and email address
email_index <- email_index %>%
        separate(Sender, into = c("Sender_Name", "Sender_Email"), sep = "\\(") # split sender into name and email
email_index$Sender_Email <- gsub("\\)", "",email_index$Sender_Email) # remove )

# ## Break apart recipients, long data format
# email_index <- email_index %>%
#         separate_rows(Recipient, sep = ";")
# email_index <- email_index %>%
#         separate(Recipient, into = c("Recipient_Name", "Recipient_Email"), sep = "\\(") #split recipient 
# email_index$Recipient_Email <- gsub("\\)", "", email_index$Recipient_Email) # remove )
# 
# # Remove leading and trailing white space
# email_index$Sender_Name <- trimws(email_index$Sender_Name, which = "both")
# email_index$Sender_Email <- trimws(email_index$Sender_Email, which = "both")
# email_index$Recipient_Name <- trimws(email_index$Recipient_Name, which = "both")
# email_index$Recipient_Email <- trimws(email_index$Sender_Email, which = "both")
# 
# # Factor sender and receivers
# email_index$Sender_Name <- as.factor(email_index$Sender_Name)
# email_index$Sender_Email <- as.factor(email_index$Sender_Email) 
# 
# # Save file name by remove .pdf for referencing
# email_index$email <- gsub(".pdf", "", email_index$FileName)
# 
# # Save transformation locally
save(email_index, file = "email_index_download.rda") # save file to local
write_feather(email_index, "email_index_download.feather") # save file as feater to local
# write_feather(email_index, "email_index.feather")# save this dataframe as a feather file


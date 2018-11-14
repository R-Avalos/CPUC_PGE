##########################################################################
#### Download, transform, and load index of all email communications ####
########################################################################

library(dplyr)
library(tidyr)
library(RCurl)
library(data.table)
library(lubridate)
library(feather) # in memory data format

# Download and convert to data frame
dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character
email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame
remove(dest_file) #clean up

### Transform data frame. Make each observation a unique email between sender and receiver pair
email_index$Recipient[email_index$Recipient==""] <- "Not Recorded (Not Recorded)" #stand in for missing receipent value
email_index$Sender[email_index$Sender==""] <- "Not Recorded (Not Recorded)"
# email_index$Subject[email_index$Subject==""] <- "Not an Email"
email_index$Subject[email_index$Subject==""] <- paste0("Attachement for email sent on ", as.character(email_index$MasterDate))# observations without a subject assumed to be attachement for email
email_index$MasterDate <- as.POSIXct(email_index$MasterDate, format = "%m/%d/%Y %H:%M") # convet to date with time
email_index$Day <- floor_date(email_index$MasterDate, "days") # save date of email in new column

# Break out sender name and email
email_index <- email_index %>%
        separate(Sender, into = c("Sender_Name", "Sender_Email"), sep = "\\(") # split sender into name and email into seperate variables/features
email_index$Sender_Email <- gsub("\\)", "",email_index$Sender_Email) # remove backwards bracket ")"
email_index$Sender_Name[email_index$Sender_Name==""] <- "Not Recorded (Not Recorded)"

# Break out each to many, from one, as seperate observations
email_index <- email_index %>%
        tidyr::separate_rows(Recipient, sep = ";") # split recipients into unique observations, increases obs from 120,746 to 3,863,726 obs. Each email pair is a communication.

# Break out recipient name and email
email_index <- email_index %>%
        separate(Recipient, into = c("Recipient_Name", "Recipient_Email"), sep = "\\(") #split recipient name and email into separate variables
email_index$Recipient_Email <- gsub("\\)", "", email_index$Recipient_Email) # remove )
email_index$Recipient_Name[email_index$Recipient_Name==""] <- "Not Recorded (Not Recorded)" #stand in for missing receipent name value

# Remove leading and trailing white space
email_index$Sender_Name <- trimws(email_index$Sender_Name, which = "both")
email_index$Sender_Email <- trimws(email_index$Sender_Email, which = "both")
email_index$Recipient_Name <- trimws(email_index$Recipient_Name, which = "both")
email_index$Recipient_Email <- trimws(email_index$Sender_Email, which = "both")
 
# Remove PDF extension from file name
email_index$email <- gsub(".pdf", "", email_index$FileName)

# Save index file locally in feather format
# write_feather(email_index, "email_index.feather") # save file as feater to local
# write.csv(email_index, "email_index.csv")


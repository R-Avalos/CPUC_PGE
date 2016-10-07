########################################################
##  PG&E and CPUC Email Conversion for Text Analysis ##
######################################################

##############  Overview ########################### 
# Practice ETL (Extract, Transform, LOad) using publicly available dataset

rm(list = ls()) # clear workspace

library(RCurl)
library(data.table)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggthemes)
library(feather)
library(tm)
# library(stringr)

## Load Transformed data frames
email_index <- read_feather("email_index.feather") # load converted data frame
SanBruno <- ymd("2010-09-09") #San Bruno explosion
SanBruno_hms <- ymd_hms("2010-09-09 18:11:12") #San Bruno explosion exact time


###### Pull data from ftp server and transfrom to usable data frame

## Read data from FTP and convert to data frame
# Base URL as of April 25, 2016
# base.url <- "ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling"
dest_file <- getURL("ftp://ftp2.cpuc.ca.gov/PG&E20150130ResponseToA1312012Ruling/Index/SB_GT&S_Production Metadata.csv") #download file as character
email_index <- fread(dest_file, sep = ",", header = TRUE) #convert to data frame
save(email_index, file = "email_index_download.rda") # save file to local
# write_feather(email_index, "email_index_download.feather") # save file as feater to local

# Transform data frame to long format
email_index$Recipient[email_index$Recipient==""] <- "Not Recorded (Not Recorded)" #stand in for missing receipent value
email_index$Sender[email_index$Sender==""] <- "Not Recorded (Not Recorded)"
email_index$Subject[email_index$Subject==""] <- "Not an Email"
email_index$MasterDate <- as.POSIXct(email_index$MasterDate, format = "%m/%d/%Y %H:%M") # convet to date with time
email_index$Day <- floor_date(email_index$MasterDate, "days") # get floor date

## Lets take apart the sender email into name and email address
email_index <- email_index %>%
        separate(Sender, into = c("Sender_Name", "Sender_Email"), sep = "\\(") # split sender into name and email
email_index$Sender_Email <- gsub("\\)", "",email_index$Sender_Email) # remove )

## Break apart recipients, long data format
email_index <- email_index %>%
        separate_rows(Recipient, sep = ";")
email_index <- email_index %>%
        separate(Recipient, into = c("Recipient_Name", "Recipient_Email"), sep = "\\(") #split recipient 
email_index$Recipient_Email <- gsub("\\)", "", email_index$Recipient_Email) # remove )

# Remove leading and trailing white space
email_index$Sender_Name <- trimws(email_index$Sender_Name, which = "both")
email_index$Sender_Email <- trimws(email_index$Sender_Email, which = "both")
email_index$Recipient_Name <- trimws(email_index$Recipient_Name, which = "both")
email_index$Recipient_Email <- trimws(email_index$Sender_Email, which = "both")

# Factor sender and receivers
email_index$Sender_Name <- as.factor(email_index$Sender_Name)
email_index$Sender_Email <- as.factor(email_index$Sender_Email) 

# Save transformation locally
write_feather(email_index, "email_index.feather")# save this dataframe as a feather file


### Classifty Forward and Reply emails (FW: RE:)



########### quick look at emails per day
# Sum of emails by day
email_count <- email_index %>% 
        group_by(Day) %>%
        summarise(emails = n_distinct(FileName)) 
summary(email_count)
sum(email_count$emails) # however, many of these are non emails. Must remove non-emails.


# Subset by highest count by sender
head(summary(email_index$Sender_Name))

sub_x_email <- subset(email_index, Sender_Name=="Cuaresma, Sally")
sub_email_count <- sub_x_email %>% 
        group_by(Day) %>%
        summarise(emails = n_distinct(FileName)) 

sub_x_email <- subset(email_index, Sender_Name=="Not Recorded") #52807, non-email comms
sub_email_count <- sub_x_email %>% 
        group_by(Day) %>%
        summarise(emails = n_distinct(FileName)) 


plot_x <- ggplot(sub_email_count, aes(x = as.Date(Day), 
                                      y = emails)) +
        geom_point(alpha = 0.25) +
        geom_segment(aes(x = as.Date(SanBruno, format = "%Y-%m-%d"), 
                         yend = max(sub_email_count$emails), 
                         xend = as.Date(SanBruno, format = "%Y-%m-%d")),
                     color = "red")
plot_x

# Plot of Emails by Day
plotEmail <- ggplot(email_count, aes(x = as.Date(Day), y = emails)) +
        geom_point(alpha = 0.25) +
        geom_rangeframe() +
        geom_segment(aes(x = as.Date(SanBruno, format = "%Y-%m-%d"), 
                         yend = max(email_count$emails), 
                         xend = as.Date(SanBruno, format = "%Y-%m-%d")),
                         color = "red") +
        ggtitle("CPUC and PG&E Communication \nEmails by Day") +
        ylab("Count of Emails") +
        xlab("Date") +
        theme_tufte()
plotEmail <- plotEmail + annotate("text", 
                     x = SanBruno, 
                     y = max(email_count$emails), 
                     label = "San Bruno Explosion",
                     color = "red", 
                     hjust = -0.05,
                     vjust = 1) #call plot
plotEmail
ggsave("CPUC_PGE_emailcount.png", width = 8, height = 4)

# simple example network graph
library(igraph)

x <- subset(email_index, Day < SanBruno_hms) #subset data to before 9-9-2010
x_netgraph <- graph.data.frame(x, directed = FALSE)
plot(x_netgraph)

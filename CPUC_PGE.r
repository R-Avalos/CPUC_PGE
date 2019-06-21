########################################################
##  PG&E and CPUC Email Conversion for Text Analysis ##
######################################################

##############  Overview ########################### 
# Practice ETL (Extract, Transform, LOad) using publicly available dataset

rm(list = ls()) # clear workspace
# library(dtplyr)
library(RCurl)
#library(data.table)
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggthemes)
library(feather)
library(tidytext)
#library(tm)

########## Load Transformed data frames ####
#### Recommend using locally saved feather file if already downloaded

# source("CPUC_Index_ETL.r", encoding = "UTF-8") # If not already saved locally, calls FTP and converts to data frame.
email_index <- read_feather("email_index.feather") # local file, faster loading
SanBruno <- ymd("2010-09-09") # San Bruno explosion date
SanBruno_hms <- ymd_hms("2010-09-09 18:11:12") #San Bruno explosion exact time


########### Quick look at emails per day ####
# Sum of emails by day. emails = one to many counts as one. communications count one to many as many.
email_count <- email_index %>% 
        group_by(Day) %>%
        summarise(emails = n_distinct(FileName), communications = n()) 
email_count$ReceiveSend_ratio <- email_count$communications/email_count$emails
summary(email_count) 
sum(email_count$emails) # however, many of these are attachments to emails. 

email_sender <- email_index %>%
  group_by(Day, Sender_Name) %>%
  summarise(emails = n_distinct(FileName), communications = n())

email_sender %>% ggplot(aes(x = Day, y = emails, color = Sender_Name)) +
  geom_point(alpha = 0.5) +
  theme(legend.position = "none")

# Subset by highest count by sender
# head(summary(email_index$Sender_Name))
# 
# sub_x_email <- subset(email_index, Sender_Name=="Cuaresma, Sally")
# sub_email_count <- sub_x_email %>% 
#         group_by(Day) %>%
#         summarise(emails = n_distinct(FileName)) 
# 
# sub_x_email <- subset(email_index, Sender_Name=="Not Recorded") #52807, non-email comms
# sub_email_count <- sub_x_email %>% 
#         group_by(Day) %>%
#         summarise(emails = n_distinct(FileName)) 
# 
# ####
# plot_person <- ggplot(sub_email_count, aes(x = as.Date(Day), 
#                                       y = emails)) +
#         geom_point(alpha = 0.25) +
#         geom_segment(aes(x = as.Date(SanBruno, format = "%Y-%m-%d"), 
#                          yend = max(sub_email_count$emails), 
#                          xend = as.Date(SanBruno, format = "%Y-%m-%d")),
#                      color = "red")
# plot_person

##### Plot of Emails by Day #####
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
        theme_tufte() +
        theme(panel.background = element_rect(fill="transparent", color = NA))
plotEmail <- plotEmail + annotate("text", 
                     x = SanBruno, 
                     y = max(email_count$emails), 
                     label = "San Bruno Explosion",
                     color = "red", 
                     hjust = -0.05,
                     vjust = 1) #call plot
plotEmail
ggsave("CPUC_PGE_emailcount.png", width = 8, height = 4, bg = "transparent")


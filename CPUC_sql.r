## SQL Database setup
library("sqldf")

db <- dbConnect(SQLite(), dbname="Test.sqlite")

#import data frames into database

#Create data table that adds each email
# file name | sender | recipient | cc | subject | content |
#

dbWriteTable(conn = db, name = "Test", value = x_df)
dbWriteTable(conn = db, name = "email_index", value = email_index)
dbRemoveTable(db, "email_index")

# Database layout
#    email_index ---> email_text
#                 '-> email_image
#    person/entity (email, linkedin info, associated send emails, associated receive)

#setwd("./PDF_2010")
#setwd("..") #back to home
#getwd() # D:/CPUC_PGE/CPUC_PGE_ETL
library(readr)
my_string <- read_file(file = "./PDF_2010/SB_GT&S_0000001.txt")
my_string


# Email_text
#  email  text  (add from index) subject sender receiver
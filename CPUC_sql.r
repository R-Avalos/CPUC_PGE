## SQL Database setup
library("sqldf")

db <- dbConnect(SQLite(), dbname="Test.sqlite")

#import data frames into database

#Create data table that adds each email
# file name | sender | recipient | cc | subject | content |
# This is already created (see email_index from CPUC_PGE.r)

dbWriteTable(conn = db, name = "Test", value = x_df)
dbWriteTable(conn = db, name = "email_index", value = email_index)
dbRemoveTable(db, "email_index")

# Database layout
#    email_index ---> email_text
#                 '-> email_image
#    person/entity (email, linkedin info, associated send emails, associated receive)


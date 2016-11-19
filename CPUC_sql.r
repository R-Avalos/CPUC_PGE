## SQL Database setup
library("sqldf")

db <- dbConnect(SQLite(), dbname="Test.sqlite")

#import data frames into database

dbWriteTable(conn = db, name = "Test", value = x_df)
dbWriteTable(conn = db, name = "email_index", value = email_index)
dbRemoveTable(db, "Test")

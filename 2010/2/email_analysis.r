## Email Text Analysis
library(lubridate)
library(dplyr)
library(tidyr)
library(ggplot2)
library(ggthemes)
library(tidytext)
library(stringr)

# Function to change individual text file into data frame and remove line breaks
file_convert <- function(file_name) {
        library(readr) #library to read in files
        library(tibble) #library to save as tbl_df, aka tibble
        my_string <- read_file(file = file_name) # read file
        my_string <- as.character(my_string)
        my_string <- gsub("\r?\n|\r", " ", my_string) # remove line breaks
        text_name <- file_name # add variable for file anme
        data <- data_frame(text_name, my_string) 
        colnames(data) <- c("File", "Text") 
        return(data) 
}


# Load Data
getwd()
setwd("D:/CPUC_PGE/CPUC_PGE_ETL/PDF_2010")# set to appropriate working directory
# setwd("..")
files = list.files(pattern = "*.txt") # list files
df <- lapply(files, file_convert) %>% bind_rows() #convert to data frame
df$File <- as.factor(df$File)
summary(df) # list of txt files


# Tidy Text Data
word_df <- df %>% unnest_tokens(word, Text) #list out each word
# word_df

word_df <- word_df %>%
        anti_join(stop_words)

word_df <- word_df %>%
        filter(str_detect(word, "^[a-z.'//&]+$")) # regex out numbers and formatting

word_count <- word_df %>%
        count(word, sort = TRUE)

word_count %>%
        filter(n > 175) %>%
        mutate(word = reorder(word, n)) %>%
        ggplot(aes(x = word, y = n)) +
        geom_bar(stat = "identity", width = 1) +
        xlab(NULL) +
        coord_flip()
        

# Word frequency by Agency
# Word frequency by agent
# Sentiment Analysis by month
#       http://tidytextmining.com/sentiment.html
#       https://www.youtube.com/watch?v=oP3c1h8v2ZQ ;)
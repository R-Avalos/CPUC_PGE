### Animation
library(ggplot2)
library(gganimate)
library(ggthemes)
library(dplyr)
library(lubridate)
# devtools::install_github("dgrtwo/gganimate")
summary(email_count$Day)
x <- email_count %>% filter(Day < ymd("2011-01-01"))



plottest <- ggplot(x, aes(x = as.Date(Day), y = emails, frame = as.Date(Day), cumulative = TRUE)) +
        geom_point(alpha = 0.5, color = "dodger blue") +
        theme(
                plot.background = element_rect(fill = "black"),
                panel.background = element_blank(),
                panel.grid.major = element_blank(),
                panel.grid.minor = element_blank(),
                panel.border = element_blank()
        )
plottest

gganimate(plottest)
gganimate(plottest, filename = "test.gif", interval = 0.25)


plotEmail <- plotEmail + annotate("text", 
                                  x = SanBruno, 
                                  y = max(email_count$emails), 
                                  label = "San Bruno Explosion",
                                  color = "red", 
                                  hjust = -0.05,
                                  vjust = 1) #call plot
plotEmail

library(dplyr)
library(haven)

#### Load CSV ####

# csv must be in format (id, y1, y0)

df = read.csv("rstudio/local/data.csv", header=TRUE) %>%
  mutate("treatment_effect" = y1 - y0)

#### ATE ####

summarize(.data=df, ate = mean(treatment_effect, na.rm=T))

#### NATE ####

df %>%
  dplyr::summarize(NATE = mean(y1, na.rm=T) - 
                     mean(y0, na.rm=T))

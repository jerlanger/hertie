### Assignment 2 Code Only ###

## Task 0 ##

# Set directory and use function to install packages if missing

setwd("foo/bar")

check.packages <- function(pkg){
  new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE,
                     repos = "https://cran.rstudio.com")
  sapply(pkg, require, character.only = TRUE)
}

check.packages(c("tidyverse",
                 "MatchIt",
                 "broom",
                 "kableExtra",
                 "stargazer"))

## Task 3 ##

# A #

# Read in data csv and declare array of covariate columns

df <- read.csv("local/social_cohesion.csv") %>%
  mutate(block = as.character(block))

list_cov = c("edu",
             "church",
             "income",
             "status1",
             "marital",
             "isis_abuse",
             "birth.year")

# Perform T-Tests on covariates and their relation to the column `treated`
# by iterating through array with summarize_at

df %>%
  dplyr::summarize_at(list_cov,funs(list(broom::tidy(t.test(. ~ treated))))) %>%
  purrr::map(1) %>%
  dplyr::bind_rows(.id="variables") %>%
  dplyr::select(variables, estimate1, estimate2, p.value) %>%
  dplyr::mutate_if(is.numeric, round, 3) %>%
  knitr::kable(col.names = c("Variable",
                             "Control (Treated = 0)",
                             "Treat (Treated = 1)",
                             "P value")) %>% 
  kableExtra::kable_styling(full_width=T, position="left")

# B #

# Do linear regression on preference to treated
# then tidy up results and display only the NATE in output

slm <- lm(own_group_preference ~ treated, data = df)
tidy(slm)[2,"estimate"] %>%
  knitr::kable(col.names = "Naïve Average Treatment Effect") %>%
  kableExtra::kable_styling(full_width=F, position="left")

# C #

# Do linear regression model again but with all covariates
# Since we are only interested in `church` and `treated` effects
# I then filter out all the results except those two and display the effect
# and p-value in output

mrm <- lm(own_group_preference ~ block + 
            player_type + 
            edu + 
            church + 
            income + 
            status1 + 
            marital + 
            isis_abuse + 
            birth.year + 
            treated, data=df)
filter(tidy(mrm), term %in% c("church",
                              "treated")) %>%
  select("term",
         "estimate",
         "std.error",
         "p.value") %>%
  knitr::kable(col.names = c("Indepdent Variable",
                             "Treatment Effect",
                             "Std Error",
                             "P Value")) %>%
  kableExtra::kable_styling(full_width=F, position="left")

# D #

# Perform "exact match" on observations on covariates

exact_match_df <- df %>%
  select(own_group_preference,
         edu,church,
         income,
         status1,
         marital,
         isis_abuse,
         birth.year,
         treated) %>%
  na.omit()

exact_match <- MatchIt::matchit(treated ~ edu + 
                                  church + 
                                  income + 
                                  status1 + 
                                  marital + 
                                  isis_abuse + 
                                  birth.year,
                                method = "exact",
                                data = exact_match_df)

summary(exact_match)

# Perform linear regression on observations with common support

em_df <- MatchIt::match.data(exact_match)

em_model <- lm(own_group_preference ~ treated, data = em_df)
stargazer::stargazer(em_model, type="text")

# F #

# Same as above but with coarsened exact matching (bins)

cem <- MatchIt::matchit(treated ~ edu + 
                          church + 
                          income + 
                          status1 + 
                          marital + 
                          isis_abuse + 
                          birth.year,
                        method = "cem",
                        data = exact_match_df)

summary(cem)

cem_df <- MatchIt::match.data(cem)

cem_model <- lm(own_group_preference ~ treated, data = cem_df)
stargazer::stargazer(cem_model, type="text")

# G #

# Display all the above results in a simple table for comparison
# and rename the columns to be more clear which model is which

stargazer::stargazer(slm, em_model, cem_model, 
                     type="text", 
                     column.labels = c("simple linear",
                                       "exact match",
                                       "coarsened exact match"))

# Extra Work (Cause I was interested), repeat of models above
# Attempting to balance only for covariates that are statistically significant 
# or have outsize diff in means and lower p-value (church, birth.year,status).

em_church <- MatchIt::matchit(treated ~ church + 
                                birth.year + 
                                status1,
                              method = "exact",
                              data = exact_match_df)
cem_church <- MatchIt::matchit(treated ~ church + 
                                 birth.year + 
                                 status1,
                               method = "cem",
                               data = exact_match_df)

em_church_df <- MatchIt::match.data(em_church)
cem_church_df <- MatchIt::match.data(cem_church)

em_church_model <- lm(own_group_preference ~ treated, data = em_church_df)
cem_church_model <- lm(own_group_preference ~ treated, data = cem_church_df)

stargazer::stargazer(slm, em_church_model, cem_church_model, 
                     type="text", 
                     column.labels = c("simple linear",
                                       "reduced_cov (em)",
                                       "reduced_cov (cem)"))
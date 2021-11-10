library(ggplot2)
library(ggrepel)
library(dplyr)
library(cowplot)
library(tidyverse)

#### 1. Load, Build Classifications, and Filter Data ####

# Data sourced from github.com/owid/co2-data

df <- read.csv("emissions_charts/local/owid-co2-data.csv", header=T)

# OECD Member Countries #

oecd_country <- c("AUS","AUT","BEL","CAN","CHL","COL",
                 "CRI","CZE","DNK","EST","FIN","FRA",
                 "DEU","GRC","HUN","ISL","IRL","ISR",
                 "ITA","JPN","KOR","LVA","LTU","LUX",
                 "MEX","NLD","NZL","NOR","POL","PRT",
                 "SVK","SVN","ESP","SWE","CHE","TUR",
                 "GBR","USA")

df <- mutate(df, oecd = iso_code %in% oecd_country)

# HDI Classifications #

df %>%
  dplyr::filter(!(iso_code %in% c("","OWID_WRL","OWID_KOS"))) %>%
  distinct(iso_code,country) %>%
  write.csv("emissions_charts/local/country_iso.csv")

hdi_cats <- read.csv("emissions_charts/local/hdi_country_cats.csv", header=T) %>%
  select(iso_code,hdi_cat,hdi_2019) %>%
  mutate(hdi_2019 = na_if(hdi_2019, -1.000)) 

df <- left_join(df, hdi_cats, by = "iso_code")

# World Bank Classification #

wb_cats <- read.csv("emissions_charts/local/wb_country_cats.csv", header=T)

df <- left_join(df, wb_cats, by = "iso_code")

# Kyoto Protocol #

# Missing Monaco & EU
annex1_country <- c("AUS","AUT","BLR","BEL","BGR","CAN",
                    "HRV","CYP","CZE","DNK","EST","FIN",
                    "FRA","DEU","GRC","HUN","ISL","IRL",
                    "ITA","JPN","LVA","LIE","LTU","LUX",
                    "MLT","NLD","NZL","NOR","POL","PRT",
                    "ROU","RUS","SVK","SVN","ESP","SWE",
                    "CHE","TUR","UKR","GBR","USA")

df <- mutate(df, annex1 = iso_code %in% annex1_country)

# G77 Member Countries #

# After join is just missing Micronesia

g77_countries <- read.csv("emissions_charts/local/g77_country_cats.csv", header=T) %>%
  mutate(g77 = TRUE) %>%
  select("Code","g77")
colnames(g77_countries)[1] <- "iso_code"

df <- left_join(df, g77_countries, by = "iso_code")
df <- df %>% 
  mutate(g77 = ifelse(is.na(g77),FALSE,g77), data=df)

# Build Final Reduced Dataset #

df_r <- df %>%
  dplyr::filter((year >= 1990) & (year < 2020) & !(iso_code %in% c("","OWID_WRL","OWID_KOS"))) %>%
  select(iso_code,
       oecd,
       hdi_cat,
       wb_cat,
       annex1,
       g77,
       country,
       year, 
       co2, 
       co2_per_capita,
       co2_per_gdp,
       cumulative_co2,
       trade_co2, 
       share_global_co2, 
       total_ghg, 
       ghg_per_capita) %>%
  mutate(n_dev_cats = ifelse(!oecd,1,0) + 
           ifelse(!hdi_cat == "Very High",1,0) +
           ifelse(!wb_cat == "High income",1,0) +
           ifelse(!annex1,1,0) +
           ifelse(g77,1,0)) %>%
  mutate(south_oecd = !oecd) %>%
  mutate(south_hdi = !hdi_cat == "Very High") %>%
  mutate(south_wb = !wb_cat == "High income") %>%
  mutate(south_annex1 = !annex1) %>%
  mutate(south_g77 = g77) %>%
  group_by(year) %>%
  dplyr::mutate(year.co2 = sum(co2, na.rm=T)) %>%
  ungroup() %>%
  mutate(share_yr_co2 = co2/year.co2)

newest <- df_r %>%
  group_by(country) %>%
  slice_max(year)

oldest <- df_r %>%
  group_by(country) %>%
  slice_min(year)

df_newold <- union(newest,oldest) %>%
  filter(year != 2002)

# Drop Unnecessary Datasets #

rm(list=c("g77_countries",
          "hdi_cats",
          "newest",
          "oldest",
          "wb_cats",
          "annex1_country",
          "oecd_country"))

#### 2. Distribution of Development Categories ####

df_dist <- df_r %>%
  group_by(n_dev_cats) %>%
  summarize(countries = length(unique(country)))

ggplot2::ggplot(df_dist, aes(y=as.factor(n_dev_cats),
                             x=countries,
                             fill=as.factor(n_dev_cats))) +
  geom_bar(stat="identity") +
  scale_y_discrete(limits=rev) +
  labs(y = "\"Global South\" Categories",
       x = "Countries") +
  theme_minimal() +
  theme(legend.position = "None",
        panel.grid.minor.x = element_blank(),
        axis.title = element_text(size = 20),
        axis.text = element_text(size = 20))

#### 3. Category by Absolute CO2 by Year ####

df_south <- df_r %>%
  pivot_longer(col=c("south_oecd","south_g77","south_hdi","south_wb","south_annex1")) %>%
  filter(value) %>%
  group_by(year,name) %>%
  summarise(share_yr_co2 = sum(share_yr_co2, na.rm=T)) %>%
  ungroup()

ggplot2::ggplot(df_south, aes(x=year, y=share_yr_co2, color=name)) +
  geom_line() +
  geom_point() +
  scale_color_discrete(labels=c("Annex I","G77","HDI","OECD","WB")) +
  labs(
    title = "Growth of Global South's Emissions",
    subtitle = "by \"Global South\" categories",
    x="",
    y="Share of World CO2 Output"
  ) +
  theme_minimal() +
  theme(
    aspect.ratio=
  )

#### 4. Per Capita Distributions ####

# Boxplot 
capita_boxplot <- ggplot2::ggplot(df_newold, 
                aes(x=paste(n_dev_cats,year), y=co2_per_capita)) +
  geom_boxplot(aes(size=co2, color=as.factor(n_dev_cats)),outlier.color = "red") +
labs(title = "Distribution of CO2 Tonnes Per Capita",
     subtitle = "by \"Global South\" categories and year",
     x = "",
     y = "") +
  theme_minimal() +
  theme(legend.position = "none")

# Abs CO2
abs_bar <- ggplot2::ggplot(df_newold, 
                aes(x=paste(n_dev_cats,year), y=(co2/1000))) +
  geom_col(aes(fill=as.factor(n_dev_cats))) +
  labs(title = "CO2 Production (Billion Tonnes)",
       x = "",
       y = "") +
  theme_minimal() +
  theme(legend.position = "none",
        plot.title = element_text(size = 10, margin = margin(-5,0,-15,0)),
        panel.grid.minor.y = element_blank())

plot_grid(capita_boxplot,abs_bar, ncol=1, rel_heights = c(3,1))

#### 5. Scatter Plot with Size = Cumulative ####

scatter_1990 <- ggplot2::ggplot(df_newold %>%
                                  filter(year==1990),
                                aes(x=co2_per_capita, y=share_global_co2, color=as.factor(n_dev_cats))) +
  geom_point(aes(size=cumulative_co2, color=as.factor(n_dev_cats))) +
  scale_size_continuous(limits=c(0,413000)) +
  xlim(NA,42) +
  ylim(NA,30) +
  geom_text_repel(aes(label=country)) +
  theme_minimal() +
  labs(title = "1990",
       x = "CO2 Per Capita",
       y = "Pct Global CO2",
       color = "# Development Categories",
       size = "Cumulative CO2") +
  theme(legend.position = "None",
        plot.title = element_text(hjust = 0.5))

scatter_2019 <- ggplot2::ggplot(df_newold %>%
                                  filter(year==2019),
                                aes(x=co2_per_capita, y=share_global_co2, color=as.factor(n_dev_cats))) +
  geom_point(aes(size=cumulative_co2, color=as.factor(n_dev_cats))) +
  scale_size_continuous(limits=c(0,413000)) +
  xlim(NA,42) +
  ylim(NA,30) +
  geom_text_repel(aes(label=country)) +
  theme_minimal() +
  labs(title = "2019",
       x = "CO2 Per Capita",
       y = "Pct Global CO2",
       color = "# Development Categories",
       size = "Cumulative CO2") +
  theme(
    plot.title = element_text(hjust = 0.5))

plot_grid(scatter_1990,scatter_2019)

#### 6. Misc ####
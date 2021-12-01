library(dplyr)
library(ggplot2)
library(mediation)
library(margins)

df <- read.csv("assignments/assgn6/local/ios_df.csv")

#### Question 3 ####

q3 <- lm(similarity ~ as.factor(MajDonor), data=df)
summary(q3)

# In a simple bivariate model, being a major donor is found to
# be an increase in 20.5% (0.2047) in similarity. This finding
# is statistically significant.
# This means that being a major donor essentially doubles the
# similarity between aid portfolios (ß0 being 0.2105)

#### Question 4 ####

q4 <- lm(similarity ~ as.factor(MajDonor) + as.factor(Organization), data=df)
summary(q4)

# Adding agency to the regression reduced the impact of MajDonor, but only
# slightly. All three agencies have similar amounts of similarity (~0.05)
# attributed to them

#### Question 5 ####

df %>%
  group_by(MajDonor, Organization) %>%
  mutate(avg_sim = mean(similarity)) %>%
  ggplot(aes(x=similarity, fill=as.factor(MajDonor))) +
  geom_density(alpha = 0.5) +
  geom_vline(aes(xintercept = avg_sim), linetype = "longdash") +
  theme_bw() +
  facet_grid(rows=vars(Organization)) +
  scale_fill_manual(name = "",
                    labels = c("Not Major Donor (0)","Major Donor (1)"),
                    values = c("grey","turquoise")) +
  theme(legend.position = "bottom",
        panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank())

ggsave("assignments/assgn6/local/q5_plot.png")

# I do not believe that this is sufficient to indicate that being a "major donor"
# is the predominant factor in similarity across organizations.
# While it is true that the graph shows distribution commonalities across 
# organizations, it doesn't say much about the makeup of the countries themselves
# that comprise the MajDonor=1 pool. For example, a country that 

#### Question 6 ####

q6 <- lm(similarity ~ as.factor(MajDonor) + as.factor(Organization) + logVP, data=df)
summary(q6)

# The size of staff has a large and positive effect on similarity. Moving
# one magnitude in staff size (e.g. 1 to 10) has roughly half the effect of
# being a top ten donor. Additionally the impact of being a major donor has been
# reduced by almost half and the impact of individual organizations has much
# more variety and has been even inverted.

#### Question 7 ####

df <- df %>% 
  mutate(g5 = (if_else(COWCode %in% c("USA","UKG","FRN","GMY","JPN"), 1, 0)))

q7 <- lm(similarity ~ logVP + g5 + logVP*g5 + MajDonor, data=df)
texreg::screenreg(q7)

#### Question 8 ####

q8_marg <- margins::margins(q7, variables= "logVP", at= list(g5= c(0,1)))
summary(q8_marg)

q8_plot <- summary(q8_marg) %>% 
  dplyr::select(g5, AME, lower, upper)

ggplot(q8_plot, aes(x= as.factor(g5),
                    y= AME,
                    color= as.factor(g5))) +
  geom_point(size = 2) +
  geom_segment(aes(x= as.factor(g5), xend= as.factor(g5), y= lower, yend= upper), size= 0.5) + 
  theme_minimal() +
  #scale_y_continuous(limits = c(0,0.5)) +
  scale_x_discrete(label=c("Not G5 (0)","G5 Country (1)")) +
  labs(x = "",
       y = "Staffing Partial Effect", 
       caption = "") +
  theme(legend.position = "None",
        plot.background = element_rect(fill="white"),
        panel.background = element_rect(fill="white"))

ggsave("assignments/assgn6/local/q8_plot.png")

#### Question 9 ####

fit.m = lm(logVP ~ MajDonor + g5 + Organization, data=df)
fit.dv = lm(similarity ~ MajDonor + logVP + g5 + Organization, data=df)

q9 = mediate(model.m = fit.m,
             model.y = fit.dv,
             treat= "MajDonor",
             mediator="logVP",
             robustSE=T)
summary(q9)

png("assignments/assgn6/local/q9.png")
plot(q9, xlim=c(-0.1,0.3))
dev.off()

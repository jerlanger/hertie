library(haven)
library(ggplot2)
library(dplyr)
library(lfe)

df <- haven::read_dta("assignments/assgn4/local/IS2018_dataset_main.dta") %>%
  zap_labels()

fig1 <- ggplot2::ggplot(data=df %>% filter(!year == 2001),
                aes(x=as.factor(year), y=nriot)) +
  geom_col(color="blue",fill="blue", width=0.6) +
  scale_y_continuous(limits=c(0,NA), breaks=c(0,20,40,60,80,100)) +
  geom_hline(yintercept=0, linetype="solid") +
  labs(
    x="",
    y="Number of riots"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=90,
                                   size=15,
                                   margin=margin(-10,0,0,0), 
                                   vjust=0.5),
        axis.text.y = element_text(size=15),
        axis.ticks.length.x = unit(0,"pt"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.y = element_blank(),
        axis.line.y.left = element_line(linetype="solid"),
        plot.background = element_rect(fill="white"))

ggsave("assignments/assgn4/local/fig1.png", plot=fig1)

d2 <- haven::read_dta("assignments/assgn4/local/dataset_robustness.dta") %>%
  zap_labels()

year_single=d2$year
d2 <- data.frame(d2, index=c("dist","year"))
d2 <- d2 %>%
  mutate(L.riot=lag(riot, k=1))%>%
  mutate(L.bjprule=lag(bjprule, k=1)) %>%
  mutate(L.fes=lag(fes, k=1)) %>%
  mutate(year=year_single)

q5 <- felm(ebjpvs ~ L.riot + L.bjprule + muslim + urb + 
       lit + ele + tap + time + tsq |
       district |
       0 |
       district, data=d2)

summary(q5)

q7 <-felm(ebjpvs ~ L.bjprule + muslim + urb + 
            lit + ele + tap + time + tsq |
            district |
            (L.riot ~ L.fes) |
            district, data=d2)

summary(q7)

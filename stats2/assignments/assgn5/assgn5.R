#### Question 4: Replicate Main Results & Figure 4 ####

library(Synth)
library(foreign)
library(png)
library(dplyr)
library(gridExtra)
library(gridGraphics)
library(cowplot)

df_carbontax <- read.dta("assignments/assgn5/local/data/carbontax_data.dta")
Cex.set <- 1

dataprep.out <-
  dataprep(foo = df_carbontax,
           predictors = c("GDP_per_capita" , "gas_cons_capita" , "vehicles_capita" ,
                          "urban_pop") ,
           predictors.op = "mean" ,
           time.predictors.prior = 1980:1989 ,
           special.predictors = list(
             list("CO2_transport_capita" , 1989 , "mean"),
             list("CO2_transport_capita" , 1980 , "mean"),
             list("CO2_transport_capita" , 1970 , "mean")
           ),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:12, 14:15),
           time.optimize.ssr = 1960:1989,
           time.plot = 1960:2005
  )

synth.out <- synth(data.prep.obj = dataprep.out,
                   method = "All")

png("assignments/assgn5/local/q4_fig4.png")
path.plot(synth.res = synth.out,
          dataprep.res = dataprep.out,
          Ylab = expression("Metric tons per capita ("*CO[2]*" from transport)"),
          Xlab = "Year",
          Ylim = c(0,3),
          Legend = c("Sweden","synthetic Sweden"),
          Legend.position = "bottomright"
)
title(main="Figure 4")
abline(v=1990,lty="dotted",lwd=2)
arrows(1987,1.0,1989,1.0,col="black",length=.1)	
text(1981,1.0,"VAT + Carbon tax",cex=Cex.set)
dev.off()

#### Question 8: Figure 6 ####

q8_1980.dataprep.out <-
  dataprep(foo = df_carbontax,
           predictors = c("GDP_per_capita" , "gas_cons_capita" , "vehicles_capita" ,
                          "urban_pop") ,
           predictors.op = "mean" ,
           time.predictors.prior = 1970:1979 ,
           special.predictors = list(
             list("CO2_transport_capita" , 1979 , "mean"),
             list("CO2_transport_capita" , 1970 , "mean"),
             list("CO2_transport_capita" , 1965 , "mean")
           ),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:12,14:15),
           time.optimize.ssr = 1960:1979,
           time.plot = 1960:1990
  )

q8_1980.synth.out <- synth(
  data.prep.obj = q8_1980.dataprep.out,
  method = "BFGS"
)

png("assignments/assgn5/local/q8_1980.png")
path.plot(synth.res = q8_1980.synth.out,
          dataprep.res = q8_1980.dataprep.out,
          Ylab = expression("Metric tons per capita ("*CO[2]*" from transport)"),
          Xlab = "Year",
          Ylim = c(0,3),
          Legend = c("Sweden","synthetic Sweden"),
          Legend.position = "bottomright"
)
abline(v=1980,lty="dotted",lwd=2)
arrows(1977,1.0,1979,1.0,col="black",length=.1)
text(1974,1.0,"Placebo tax",cex=Cex.set)
dev.off()

q8_1970.dataprep.out <-
  dataprep(foo = df_carbontax,
           predictors = c("GDP_per_capita" , "gas_cons_capita" , "vehicles_capita" ,
                          "urban_pop") ,
           predictors.op = "mean" ,
           time.predictors.prior = 1960:1969 ,
           special.predictors = list(
             list("CO2_transport_capita" , 1960:1970 , "mean")
           ),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:9, 11:12, 14:15),
           time.optimize.ssr = 1960:1969,
           time.plot = 1960:1990
  )

q8_1970.synth.out <- synth(
  data.prep.obj = q8_1970.dataprep.out,
  method = "All"
)

png("assignments/assgn5/local/q8_1970.png")
path.plot(synth.res = q8_1970.synth.out,
          dataprep.res = q8_1970.dataprep.out,
          Ylab = expression("Metric tons per capita ("*CO[2]*" from transport)"),
          Xlab = "Year",
          Ylim = c(0,3),
          Legend = c("Sweden","synthetic Sweden"),
          Legend.position = "bottomright"
)
abline(v=1970,lty="dotted",lwd=2)
arrows(1968,2.0,1969.5,2.0,col="black",length=.1)	
text(1965,2.0,"Placebo tax",cex=Cex.set)
dev.off()

q8_2 <- readPNG("assignments/assgn5/local/q8_1970.png")
q8_1 <- readPNG("assignments/assgn5/local/q8_1980.png")
q8_all <- plot_grid(rasterGrob(q8_1),rasterGrob(q8_2), ncol=2)
save_plot("assignments/assgn5/local/q8_fig6.png", q8_all)

#### Question 9: Figure 6 Panel B but with 1975 and no Poland ####

q9_1975.dataprep.out <-
  dataprep(foo = df_carbontax,
           predictors = c("GDP_per_capita" , "gas_cons_capita" , "vehicles_capita" ,
                          "urban_pop") ,
           predictors.op = "mean" ,
           time.predictors.prior = 1965:1974 ,
           special.predictors = list(
             list("CO2_transport_capita" , 1965:1974 , "mean")
           ),
           dependent = "CO2_transport_capita",
           unit.variable = "Countryno",
           unit.names.variable = "country",
           time.variable = "year",
           treatment.identifier = 13,
           controls.identifier = c(1:9, 11:12, 14:15),
           time.optimize.ssr = 1960:1974,
           time.plot = 1960:1990
  )


q9_1975.synth.out <- synth(
  data.prep.obj = q9_1975.dataprep.out,
  method = "All"
)

png("assignments/assgn5/local/q9_fig6_1975.png")
path.plot(synth.res = q9_1975.synth.out,
          dataprep.res = q9_1975.dataprep.out,
          Ylab = expression("Metric tons per capita ("*CO[2]*" from transport)"),
          Xlab = "Year",
          Ylim = c(0,3),
          Legend = c("Sweden","synthetic Sweden"),
          Legend.position = "bottomright"
)
abline(v=1975,lty="dotted",lwd=2)
arrows(1973,2.0,1974.5,2.0,col="black",length=.1)	
text(1971.5,2.0,"Placebo tax",cex=Cex.set)
dev.off()

#### Question 11 ####

df_r <- df_carbontax %>%
  mutate("isSweden" = Countryno == 13) %>%
  mutate("isPost" = year >= 1990)

lm(CO2_transport_capita ~ isSweden + isPost + (isSweden*isPost), data=df_r)

alp = 1.81005
lam = 0.76592
gam = -0.01636
del = -0.21372

((alp+lam+gam+del) - (alp+gam)) - ((alp+lam) - alp)

#### Question 12: Figure 3 Violation of Parallel Trends ####

# As the author mentioned in their paper, the growth rates of Sweden vs OECD sample
# is 2x leading up to the implementation of the tax, so it is not the same trend

df_descript <- read.dta("assignments/assgn5/local/data/descriptive_data.dta")

png("assignments/assgn5/local/q12_fig3.png")
plot(x=df_descript$year[1:46], 
     y=df_descript$CO2_Sweden, 
     type="l", 
     lwd=2, 
     col="black", 
     ylim=c(0,3),
     xlab="Year", 
     ylab=expression("Metric tons per capita ("*CO[2]*" from transport)"), 
     xaxs="i",
     yaxs="i")
title(main="Figure 3")
abline(v=1990,lty="dotted",lwd=2)
legend("bottomright",legend=c("Sweden","OECD sample"),
       lty=c(1:2),col=c("black","black"),lwd=c(2,2),cex=.8)
lines(df_descript$year, df_descript$CO2_OECD, lty="dashed" , lwd=2, col="black")
abline(v=1990,lty="dotted",lwd=2)
arrows(1987,1.0,1989,1.0,col="black",length=.1)
text(1981,1.0,"VAT + Carbon tax",cex=Cex.set)
dev.off()

rm(list=ls())
library(haven)
library(ggplot2)
library(readr)

#setwd("")# set working direction

data <- read_dta("LiK_final_rec.dta") # read in state file
models <- read_csv("models.csv") # read csv file with model effects

# Figure 3 - coef plot of main effects
fig3 <- models[which(models$model=="f3"),] # select the three variables of figure 1

fig<-ggplot(fig3, aes(x=variable, y=coef)) + #x and y info
  geom_point(size=2) + #size of the dots
  ylim(c(-1.5,1.5)) + #scale of the y-axis, similar to your state plot
  geom_errorbar(aes(ymin=lower, ymax=upper, width=0)) + # shape and size of the error bars
  labs(y="Effect on Change in Trust in President", x="") + # names on the axis
  coord_flip() + # flipping the axis so the variables are on Y and effect size on X
  geom_hline(yintercept=0, colour="black", size=.2) + # line at 0, and the size, I can change the color etc. if you want
  theme_minimal() # just a pre-set theme in R, I can change anything you prefer here
ggsave("fig3.png", width=5.75, height=3.75, dpi=900,fig) # save it as a png file

# Figure 4 - interaction with histogram of information
fig4 <- models[which(models$model=="f4"),] # select the three variables of model 3
fig4$perc <- as.numeric(table(data$seekinfo_cat3)/dim(data)[1] *100) # create percentage variable

fig <- ggplot(fig4) + #info on data
  geom_bar(data= fig4, aes(x = variable, y=perc/200),stat="identity", fill= "grey85") + #create histogram of perc of respondents in category
  geom_line(data = fig4, aes(x = variable, y= coef, group = model)) + # line of effect size
  geom_line(data = fig4, aes(x = variable, y= lower, group = model), linetype = "dashed") + # upper bound CI
  geom_line(data = fig4, aes(x = variable, y= upper, group = model), linetype = "dashed") + # lower bound CI
  labs(y="Marginal Effect of Change in Remitted Amount", x="Political Information") + # names on the axis
  geom_hline(yintercept=0, colour="black", size=.2) + 
  theme_minimal() 

fig <- fig + scale_y_continuous(sec.axis = sec_axis(~.*200, name = "Share of Respondents")) # set name of the second Y axis
ggsave("fig4.png", width=5.75, height=3.75, dpi=900,fig) # save it as a png file


# Figure C.1 - interaction with histogram of information via personal networks
figc1 <- models[which(models$model=="c1"),] # select the three variables of figure C.1
figc1$perc <- as.numeric(table(data$familyinfo)/dim(data)[1] *100) # create percentage variable

fig <- ggplot(figc1) + #info on data
  geom_bar(data= figc1, aes(x = variable, y=perc/200),stat="identity", fill= "grey85") + #create histogram of perc of respondents in category
  geom_line(data = figc1, aes(x = variable, y= coef, group = model)) + # line of effect size
  geom_line(data = figc1, aes(x = variable, y= lower, group = model), linetype = "dashed") + # upper bound CI
  geom_line(data = figc1, aes(x = variable, y= upper, group = model), linetype = "dashed") + # lower bound CI
  labs(y="Marginal Effect of Change in Remitted Amount", x="Political Information via Personal Networks") + # names on the axis
  geom_hline(yintercept=0, colour="black", size=.2) + 
  theme_minimal() 

fig <- fig + scale_y_continuous(sec.axis = sec_axis(~.*200, name = "Share of Respondents")) # set name of the second Y axis
ggsave("figc1.png", width=5.75, height=3.75, dpi=900,fig) # save it as a png file



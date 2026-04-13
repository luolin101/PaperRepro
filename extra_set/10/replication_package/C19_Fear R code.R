##############
###Packages###
##############
library(plyr)
library(dplyr)
library(psych)
library(readxl)
library(corrplot)
library(jmv)

####################################################
###Data importing, coding, cleaning and computing###
####################################################
#Import
data <- C_Fear_data
View(data)

#Recode code data from text
#Code the most frequent nationality and location
data$Nationality <- dplyr::recode(data$Nationality, 'British/UK' =1) 
data$CountryResidence <- dplyr::recode(data$CountryResidence, 'UK'= 1)
#Other
data$Gender <- dplyr::recode(data$Gender, 'Female'=1, 'Male'=2, 'Other'=3)
data$EducationLevel <- dplyr::recode(data$EducationLevel, 'Less than an undergraduate degree'=1, 'Undergraduate degree'=2, 'Masters level degree'=3, 'Doctoral level degree'=4)
data$Politics <- dplyr::recode(data$Politics, 'Very Liberal'= -2, 'Somewhat Liberal'= -1, 'Centrist'=0, 'Somewhat Conservative'=1, 'Very Conservative'=2)
data$ReportedRisk <- dplyr::recode(data$ReportedRisk, 'High'= 3, 'Medium'= 2, 'Low'=1)
data <- data %>%
  mutate_at( .vars = vars("FCS1":"FCS7"),
             .funs = funs(recode(., "Strongly Disagree" = 1, "Disagree"=2, "Neither Agree nor Disagree"=3, "Agree"=4, "Strongly Agree"=5)))
data <- data %>%
  mutate_at( .vars = vars("PROMIS_Dep1":"PROMIS_Anx7"),
             .funs = funs(recode(., "Never" =1, "Rarely"=2, "Sometimes"=3, "Often"=4, "Always"=5)))
data <- data %>%
  mutate_at( .vars = vars("MFQ_P1_Q1":"MFQ_P1_Q10"),
             .funs = funs(recode(., "Not at all relevant" =0, "Not very relevant"=1, "Slightly relevant"=2, "Somewhat relevant"=3, "Very relevant"=4, "Extremely relevant"=5)))
data <- data %>%
  mutate_at( .vars = vars("MFQ_P2_Q1":"MFQ_P2_Q10"),
             .funs = funs(recode(., "Strongly disagree" =0, "Moderately disagree"=1, "Slightly disagree"=2, "Slightly agree"=3, "Moderately agree"=4, "Strongly agree"=5)))
data <- data %>%
  mutate_at( .vars = vars("WHOQOL1","WHOQOL15"),
             .funs = funs(recode(., "Very poor" =1, "Poor"=2, "Neither poor nor good"=3, "Good"=4, "Very good"=5)))
data <- data %>%
  mutate_at( .vars = vars("WHOQOL2","WHOQOL16":"WHOQOL25"),
             .funs = funs(recode(., "Very dissatisfied" =1, "Dissatisfied"=2, "Neither satisfied nor dissatisfied"=3, "Satisfied"=4, "Very satisfied"=5)))
data <- data %>%
  mutate_at( .vars = vars("WHOQOL5","WHOQOL6"),
             .funs = funs(recode(., "Not at all" =1, "A little"=2, "A moderate amount"=3, "Very much"=4, "An extreme amount"=5)))
data <- data %>%
  mutate_at( .vars = vars("WHOQOL7":"WHOQOL9"),
             .funs = funs(recode(., "Not at all" =1, "A little"=2, "A moderate amount"=3, "Very much"=4, "Extremely"=5)))
data <- data %>%
  mutate_at( .vars = vars("WHOQOL10":"WHOQOL14"),
             .funs = funs(recode(., "Not at all" =1, "A little"=2, "Moderately"=3, "Mostly"=4, "Completely"=5)))
#Reverse scored
data <- data %>%
  mutate_at( .vars = vars("WHOQOL3","WHOQOL4"),
             .funs = funs(recode(., "Not at all" =5, "A little"=4, "A moderate amount"=3, "Very much"=2, "An extreme amount"=1)))
data$WHOQOL26 <- dplyr::recode(data$WHOQOL26, 'Never'=1, 'Seldom'= 2, 'Quite often'=3, 'Very often'=4, 'Always'=5)
#Recode including NAs as per YGBC responses
data <- data %>%
  mutate_at( .vars = vars("YG_Handwashing":"YG_SocialDistancing"),
             .funs = funs(recode(., "It has changed dramatically" = 4, "It has changed somewhat"=3, "It has only changed a little"=2, "It has not changed at all"=1)))

#Remove intattentive responses
data$FCS.attention <- dplyr::recode(data$FCS.attention, 'Agree'= 1)
data <- subset(data, FCS.attention==1)
data$PROMIS.attention <- dplyr::recode(data$PROMIS.attention, 'Rarely'=1)
data <- subset(data, PROMIS.attention==1)
data$MFQ.attention <- dplyr::recode(data$MFQ.attention, 'Strongly disagree'=1)
data <- subset(data, MFQ.attention==1)
data$WHOQOL.attention <- dplyr::recode(data$WHOQOL.attention, 'Extremely'=1)
data <- subset(data, WHOQOL.attention==1)

#Variable scores - YGBC var and averages
Scoring.list <- list(FCS= c("FCS1","FCS2","FCS3","FCS4","FCS5","FCS6","FCS7"),
                     YGBC= c("YG_Handwashing", "YG_ChangedTravel",	"YG_WFH",	"YG_StockpileFood",	"YG_StockpileMedicine",	"YG_Care",	"YG_SocialDistancing"),
                     PROMIS_Dep= c("PROMIS_Dep1","PROMIS_Dep2","PROMIS_Dep3","PROMIS_Dep4","PROMIS_Dep5","PROMIS_Dep6","PROMIS_Dep7","PROMIS_Dep8"),
                     PROMIS_Anx= c("PROMIS_Anx1","PROMIS_Anx2","PROMIS_Anx3","PROMIS_Anx4","PROMIS_Anx5","PROMIS_Anx6","PROMIS_Anx7"),
                     MFQ_Harm= c("MFQ_P1_Q1","MFQ_P1_Q6","MFQ_P2_Q1","MFQ_P2_Q6"),
                     MFQ_Fair= c("MFQ_P1_Q2","MFQ_P1_Q7","MFQ_P2_Q2","MFQ_P2_Q7"),
                     MFQ_Ingroup= c("MFQ_P1_Q3","MFQ_P1_Q8","MFQ_P2_Q3","MFQ_P2_Q8"),
                     MFQ_Authority= c("MFQ_P1_Q4","MFQ_P1_Q9","MFQ_P2_Q4","MFQ_P2_Q9"),
                     MFQ_Purity= c("MFQ_P1_Q5","MFQ_P1_Q10","MFQ_P2_Q5","MFQ_P2_Q10"),
                     WHOQOL_Physcial= c("WHOQOL3","WHOQOL4","WHOQOL10","WHOQOL15","WHOQOL16","WHOQOL17","WHOQOL18"),
                     WHOQOL_Psychological= c("WHOQOL5","WHOQOL6","WHOQOL7","WHOQOL11","WHOQOL19","WHOQOL26"),
                     WHOQOL_Social= c("WHOQOL20","WHOQOL21","WHOQOL22"),
                     WHOQOL_Environment= c("WHOQOL8","WHOQOL9","WHOQOL12","WHOQOL13","WHOQOL14","WHOQOL23","WHOQOL24","WHOQOL25"))
Scoring <- psych::scoreItems(Scoring.list,data)
Scoring.df <- data.frame(Scoring$scores)
data <- tibble::rowid_to_column(data, "P.id")
Scoring.df <- tibble::rowid_to_column(Scoring.df, "P.id")
data <- left_join(Scoring.df,data, by = "P.id")

#Check
View(data)

##################
###DEscRIPTIVES###
##################
#Participants
nrow(data)
psych::describe(data$Age)
plyr::count(data,'Gender')
plyr::count(data,'Nationality')
plyr::count(data,'CountryResidence')
plyr::count(data,'EducationLevel')

#Variable Descriptives
plyr::count(data, 'ReportedRisk')
psych::describe(data$Politics)
data %>% select(FCS:WHOQOL_Environment) %>% psych::describe(.)
Scoring

##################
###INFERENTIALS###
##################
#Correlations between all vars
#Viz
data %>% select(FCS:WHOQOL_Environment, Politics,ReportedRisk) %>% cor(.) -> CorrMat
corrplot::corrplot(CorrMat, type= "upper", method= "number")

#Test
data %>% 
  select(FCS:WHOQOL_Environment, Politics,ReportedRisk) %>% 
  jmv::corrMatrix(data = .) -> Corrout
Corrout$matrix$asDF -> c.df
c.df %>% select(c(5,6,7,8)) -> c.df2
View(c.df2)

#Test of Behaviour change (YGBC) predicted by Fear of COVID Scale (FCS)
Beh.Fear.Mod <- lm(YGBC ~ FCS, data=data)
summary(Beh.Fear.Mod)

#Test of YGBC predicted by FCS and additional wellbeing measures.
Beh.Fear.Mod.Plus <- lm(YGBC ~ FCS + PROMIS_Dep + PROMIS_Anx, data=data)
summary(Beh.Fear.Mod.Plus)

#>#Model compare
anova(Beh.Fear.Mod,Beh.Fear.Mod.Plus)

#Test of YGBC predicted by moral/political (i.e. non-wellbeing) measures
Beh.Poli.Mod <- lm(YGBC ~ MFQ_Harm + MFQ_Fair + MFQ_Ingroup + MFQ_Authority + MFQ_Purity + Politics, data=data)
summary(Beh.Poli.Mod)

#Test of YGBC predicted by moral/political plus mental health (PROMIS) measues
Beh.Poli.Mod.Plus <- lm(YGBC ~ MFQ_Harm + MFQ_Fair + MFQ_Ingroup + MFQ_Authority + MFQ_Purity + Politics + PROMIS_Anx + PROMIS_Dep + FCS, data=data)
summary(Beh.Poli.Mod.Plus)

#>#Model compare
anova(Beh.Poli.Mod,Beh.Poli.Mod.Plus)

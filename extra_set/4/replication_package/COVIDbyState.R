library(foreign)
setwd("~/Desktop")
COVIDbyState <- read.csv("COVIDbyState.csv")

library(QuantPsyc)

#State Political Ideology Predicting Time Since Stay at Home Order into Effect
summary(lm(DaysSinceStayAtHomeOrderEffective~Density+Pop+March31April10Spread+CasesPerMillionMarch31+ConservativeLiberalDiff,data=COVIDbyState))
lm.beta(lm(DaysSinceStayAtHomeOrderEffective~Density+Pop+March31April10Spread+CasesPerMillionMarch31+ConservativeLiberalDiff,data=COVIDbyState))

plot(DaysSinceStayAtHomeOrderEffective~ConservativeLiberalDiff,data=COVIDbyState)
abline(lm(DaysSinceStayAtHomeOrderEffective~ConservativeLiberalDiff,data=COVIDbyState))

cor.test(COVIDbyState$ConservativeLiberalDiff,COVIDbyState$DaysSinceStayAtHomeOrderEffective, method="pearson")

#State Percent Trump 2016 Vote Predicting Time Since Stay at Home Order into Effect
summary(lm(DaysSinceStayAtHomeOrderEffective~Density+Pop+March31April10Spread+CasesPerMillionMarch31+TrumpVote2016Percent,data=COVIDbyState))
lm.beta(lm(DaysSinceStayAtHomeOrderEffective~Density+Pop+March31April10Spread+CasesPerMillionMarch31+TrumpVote2016Percent,data=COVIDbyState))

plot(DaysSinceStayAtHomeOrderEffective~TrumpVote2016Percent,data=COVIDbyState)
abline(lm(DaysSinceStayAtHomeOrderEffective~TrumpVote2016Percent,data=COVIDbyState))

cor.test(COVIDbyState$TrumpVote2016Percent,COVIDbyState$DaysSinceStayAtHomeOrderEffective, method="pearson")

#State Political Ideology Predicting Spread from March 31 to April 10
summary(lm(March31April10Spread~ConservativeLiberalDiff+Density+Pop+DaysSinceStayAtHomeOrderEffective+CasesPerMillionMarch31,data=COVIDbyState))
lm.beta(lm(March31April10Spread~ConservativeLiberalDiff+Density+Pop+DaysSinceStayAtHomeOrderEffective+CasesPerMillionMarch31,data=COVIDbyState))

#State Percent Trump 2016 Vote Predicting Spread from March 31 to April 10
summary(lm(March31April10Spread~TrumpVote2016Percent+Density+DaysSinceStayAtHomeOrderEffective+CasesPerMillionMarch31,data=COVIDbyState))
lm.beta(lm(March31April10Spread~TrumpVote2016Percent+Density+DaysSinceStayAtHomeOrderEffective+CasesPerMillionMarch31,data=COVIDbyState))

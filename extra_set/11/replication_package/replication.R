library(Design)

# set working directory
setwd("/your/working/directory/here")

dataset <- read.csv("replicationdata.csv", header=T)


m1 <- lrm(fraudchi2_total ~ v.elday.pc + v.elday.pc.2+ numclosedstations + electrified + pce_1000_07 + distkabul + elevation, data=dataset, x=T, y=T)
m1 <- robcov(m1, dataset$regcommand)
m1

m2 <- lrm(fraudchi2_total ~ v.2months.pc + v.2months.pc.2 + numclosedstations + electrified + pce_1000_07+ distkabul + elevation, data=dataset, x=T, y=T)
m2 <- robcov(m2, dataset$regcommand)
m2

m3 <- ols(est_fraud_share ~ v.elday.pc + v.elday.pc.2 + numclosedstations + electrified + pce_1000_07 + distkabul + elevation, data=dataset, x=T, y=T)
m3 <- robcov(m3, dataset$regcommand)
m3

m4 <- ols(est_fraud_share ~ v.2months.pc + v.2months.pc.2 + numclosedstations + electrified + pce_1000_07+ distkabul + elevation, data=dataset, x=T, y=T)
m4 <- robcov(m4, dataset$regcommand)
m4


# spatial displacement
m5 <- lrm(fraudchi2_k ~  v.elday.pc + v.elday.pc.lag + numclosedstations + pce_1000_07 + electrified + distkabul + elevation, data=dataset, x=T, y=T)
m5 <- robcov(m5, dataset$regcommand)
m5

m6 <- lrm(fraudchi2_a ~  v.elday.pc + v.elday.pc.lag + numclosedstations  + pce_1000_07 + electrified + distkabul + elevation, data=dataset, x=T, y=T)
m6 <- robcov(m6, dataset$regcommand)
m6



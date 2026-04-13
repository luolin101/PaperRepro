#
# Gerber, Marlène, André Bächtiger, Susumu Shikano, Simon Reber and Samuel Rohr
# (forthcoming). Deliberative Abilities and Deliberative Influence in a Transnational 
# Deliberative Poll (EuroPolis). British Journal of Political Science.
#
# Code for Plots
#

rm(list=ls(all=TRUE))

library(foreign)
library(lme4)
source("c:/R-Programme/DQI_IR_lmer_latex.r")

setwd("c:/R-Programme/Daten")

habermas <- read.dta("DQI_IR_Idealpoints_Habermas.dta")
habermas.raw <- read.dta("DQI_IR_Idealpoints_Habermas_raw.dta")


discri.h <- read.dta("DQI_IR_Discrimination_Habermas.dta")
diffic.h <- read.dta("DQI_IR_Difficulty_Habermas.dta")



# ---------------------------------------
# Item response functions 
#

diffic.m <- apply(diffic.h  ,2,mean)
discri.m <- apply(discri.h ,2,mean)
#farben <- c("black","red","blue","grey","yellow","green")
farben <- grey(1:6/10)
width <- c(2,3,2,3,2,3)

png("C:/localtexmf/docs/BJPS_DQI_Itemresponsefunction.png",width = 6, height = 6, units = 'in', res = 500)

y.rg <- c(-3,3)

this.func <- function(x) 1/(1+exp(-this.discri*(x-this.diffic)))
this.discri <- discri.m[1]
this.diffic <- diffic.m[1]
curve(this.func,y.rg[1],y.rg[2],ylim=c(0,1),lwd=width[1],col=farben[1],
      xlab="Quality of discourse",
      ylab="Response")
for (i in 2:length(diffic.m)){
  this.discri <- discri.m[i]
  this.diffic <- diffic.m[i]
  curve(this.func,y.rg[1],y.rg[2],ylim=c(0,1),add=T,lty=i,
        col=farben[i],lwd=width[i])
}
legend("topleft",c("Soph.Justification",
                   "Common good",
                   "Respect Group",
                   "Positive interactivity",
                   "Story-telling",
                   "Question"),lty=c(1:6),
       col=farben,lwd=width,bty="n")
dev.off()






#-------------------------------------------------
# Plot of Ideal Points

png("C:/localtexmf/docs/BJPS_DQI_Idealpoints.png",width = 6, height = 7, units = 'in', res = 500)

par(mfrow=c(1,2))

this.data.raw <- habermas.raw
y.rg <- c(-3,3)
this.group <- habermas$group

starts <- c(1,cumsum(table(this.group))+1)
ends <- cumsum(table(this.group))

ltypes <- rep(c(1,2),7)
phs <- rep(c(16,17),7) 

ci.90 <- apply(this.data.raw,2,quantile,pr=c(0.05,0.95))
mean.ideal <- apply(this.data.raw,2,mean)

# Sorting in each group
sort.num <- tapply(mean.ideal,as.factor(this.group),order)
mean.ideal.sort <- NULL
for (i in 1:13){
   mean.ideal.sort <- c(mean.ideal.sort,mean.ideal[this.group==unique(this.group)[i]][unlist(sort.num[i])]  )
}
ci.90.sort <- NULL
for (i in 1:13){
   ci.90.sort <- cbind(ci.90.sort,ci.90[,this.group==unique(this.group)[i]][,unlist(sort.num[i])]  )
}

for (i.fig in 1:2){
    
    if (i.fig==1) {start.end <- range(which(this.group<=16))}
    if (i.fig==2) {start.end <- range(which(this.group>16))}
    
  
    I <- start.end[2] - start.end[1] +1
    plot(mean.ideal[start.end[1]:start.end[2]],start.end[1]:start.end[2],type="n",xlim=y.rg,axes=F,ylim=c(I,1),
                     xlab="Quality of discourse",ylab="",
                     main="")
    axis(1,cex.axis=0.9)
    this.type1="p";  this.type2="l"
    
    for(i in start.end[1]:start.end[2]){
        par(new=T)
        plot(mean.ideal.sort[i],i,type=this.type1,
              xlim=y.rg,axes=F,ylim=c(start.end[2],start.end[1]),ann=F,
              pch=phs[as.numeric(as.factor(this.group))[i]],
              col=1
              )
        par(new=T)
        plot(ci.90.sort[,i],rep(i,2),
              xlim=y.rg,axes=F,ylim=c(start.end[2],start.end[1]),ann=F,lwd=1,
              type=this.type2,
              lty=ltypes[as.numeric(as.factor(this.group))[i]],
              col=1
        )
    }
    text(-3,ends-4,unique(this.group),pos=4)  

}


dev.off()
















#
# Gerber, Marl?ne, Andr? B?chtiger, Susumu Shikano, Simon Reber and Samuel Rohr
# (forthcoming). Deliberative Abilities and Deliberative Influence in a Transnational 
# Deliberative Poll (EuroPolis). British Journal of Political Science.
#
# Code for estimation of an Item-Response Model
#


setwd("c:/R-Programme/Daten")

library(foreign)
rohdaten <- read.dta("Participants_Europolis_27122011_IR_1.dta",convert.factors=F)


# Variablen ausw?hlen

daten <- as.matrix(rohdaten[,c("jlev_max","cgood_max","resp_gr_max",
                     "int1_max","story_d_max","question_max",
                     "UniqueID","small_gr")])

# Cut values geben
daten[,"jlev_max"] <- ifelse(daten[,"jlev_max"]>=3,1,0)
daten[,"resp_gr_max"] <- ifelse(daten[,"resp_gr_max"]>=2,1,0)
daten[,"int1_rc_max"] <- ifelse(daten[,"int1_rc_max"]>=3,1,0)



summary(daten)
daten <- as.data.frame(daten)

iv.daten <- daten[,7:dim(daten)[2]]
daten <- daten[,1:6]
daten <- na.omit(daten)          # Excluding 
omitted <- attributes(daten)$na.action
iv.daten <- iv.daten[-omitted,]


#######################################
# WinBUGS code

library(R2WinBUGS)
irt.model <- function(){
	for(j in 1:J){ #Schleife f?r alle Kriterien
		for(i in 1:I){ #Schleife f?r alle Personen
			y[i,j] ~ dbern(pi[i,j])
			logit(pi[i,j]) <- beta[j,1] *(   x[i]- beta[j,2] )
		}
	}

  for(j in 1:J){
     beta[j,1] ~ dnorm(0,1)%_%I(0,)
     beta[j,2] ~ dnorm(0,1)
     }

  for(i in 1:I){ x[i] ~ dnorm(0,1)}


}

write.model(irt.model, "DQI_Analyse_Participants.bug")


I <- dim(daten)[1]
J <- dim(daten)[2]

winbug.data <- list(y = as.matrix(daten), I=I,J=J)

bug.erg <- bugs(data=winbug.data,
    inits=NULL,
    parameters.to.save = c("beta","x"),
    model.file="DQI_Analyse_Participants.bug",
    n.chains=3, n.iter=700, n.burnin=200,
    n.thin=1,
    codaPkg=F,
    debug=TRUE,
    bugs.directory="c:/Software/WinBUGS14/"
    )

attach.bugs(bug.erg)


ideal.points <- x
diffic <- beta[,,2]
discri <- beta[,,1]

# Mean ideal points
mean.ideal <- apply(ideal.points,2,mean)
tapply(mean.ideal,as.factor(iv.daten$group),mean,na.rm=T)       
tapply(mean.ideal,as.factor(iv.daten$group),sd,na.rm=T)      


#---------------------------------------------------
# Exporting Ideal Points 

daten <- cbind(mean.ideal, iv.daten)
output.matrix <- as.data.frame(daten)
write.dta(output.matrix,"DQI_IR_Idealpoints_Habermas.dta")


daten <- cbind(ideal.points)
write.dta(as.data.frame(ideal.points),"DQI_IR_Idealpoints_Habermas_raw.dta")


#---------------------------------------------------
# Exporting Parameters

write.dta(as.data.frame(diffic),"DQI_IR_Difficulty_Habermas.dta")
write.dta(as.data.frame(discri),"DQI_IR_Discrimination_Habermas.dta")


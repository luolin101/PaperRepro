*This file replicates the results in the appendix of the Fiscal Roots of Underdevelopment using a Stata leader country year panel dataset with global coverage. This dataset is called Leader Year Country Dataset; Note that the l.variablename command tells Stata to use the lagged value of the variable in the regression. The independent variables in the regressions that follow are always lagged using this approach; this file contains the input for hazard models conducted on individual leader survival rates; these models are flagged in footnote 6 of the paper.*
*SECTION 1. HAZARD MODELS ON THE SURVIVAL RATE OF INDIVIDUAL LEADERS; first, open the panel dataset labeled “Leader Year Country Dataset” in Stata; second, I’ve set the data up as an event series to estimate survival models on leaders; thus, I use the leadid leader identifier; I circumscribe the observations to the leader country years for which there is available data on the ICRG_QOG index; I define a failure as the variable Displacement equal to “1”*

stset year if icrg_qog != ., failure(Displacement = 1) id(leadid) exit(time .)

*I then estimated a series of Cox Proportional Hazard Models; to estimate these models, I pooled the data; robust standard errors clustered by country address heteroskedasticity and any intragroup correlation within countries*  

*the first model has only one independent variable, ICRG_QOG; the hmccode is the country identifier in the Albertus Menaldo 2014 dataset*

stcox icrg_qog, r cluster(hmccode)

*in the next model I now control for whether the leader was democratically elected or not using the leader year adjusted binary coding of democracy from Albertus and Menaldo (2014)*

stcox icrg_qog fullregime_dummy_leader_pre1950, r cluster(hmccode)

*next, I graph the survival Function for leaders who rule countries with the lowest level of state capacity compared to those who rule countries with middling levels of state capacity; democracy is held at its mean value by default*

stcurve, survival at1(icrg_qog = 0) at2(icrg_qog = .5) range(1985 2004)

*now, besides controlling for whether the incumbent was elected, I also control for whether the incumbent obtained power irregularly, his/her age at the beginning of his/her term, and the number of times the incumbent has occupied the executive branch previously*

stcox icrg_qog fullregime_dummy_leader_pre1950 irregular_entry age0 prevtimesinoffice, r cluster(hmccode)

*I again graph the hazard rate for rulers by level of state capacity*

stcurve, survival at1(icrg_qog = 0) at2(icrg_qog = .5) range(1985 2004)

*now I demonstrate that leaders who leave power irregularly are much more likely to be punished after leaving office than for those who transfer power regularly; this is accomplished by computing cross-tabulations of the different modalities of punishment by whether the executive was displaced or not follows; the first crosstab compares rulers who are not punished versus those who are punished across the different forms of punishment*

tabulate posttenurefate Displacement if icrg_qog != . &  posttenurefate > -1, cell chi2

*the second crosstab breaks down leader punishments conditional on being punished*

tabulate posttenurefate Displacement if icrg_qog != . &  posttenurefate > 0, cell chi2






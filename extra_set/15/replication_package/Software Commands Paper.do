*This document offers instructions on how to reproduce the analytic results, summary statistics and figure reported and discussed in “The Fiscal Roots of Financial Underdevelopment” using the country year panel dataset with global coverage and Stata 11; while summary statistics are included in Table 1 of the paper, data diagnostics such as the panel unit root tests are reported in the paper. This Stata dataset is called Country Year Dataset. This document also contains commands used to download statistical packages that are not already loaded into Stata 11. Three general notes follow. First, note that the l.variablename command tells Stata to use the lagged value of the variable in the regression or to calculate its summary statistics. The independent variables in the regressions that follow are always lagged using this approach, which is available once the dataset is declared to be a panel dataset; as explained below, I’ve already primed the Country Year Dataset to be treated as a panel dataset. Second, to create the summary statistics documented in Table 1 of the paper, I chose to calculate them based on the observations for each variable that had the greatest coverage. This means the regression sample with the greatest number of observations. For example, the model reported in Table 2, Column 1 of the paper has the greatest number of observations for the variable Directed Credit. Thus, the summary statistics for this variable are calculated following immediately after the output reported for that model. This is repeated for each of the variables that appear in Table 1 of the text. The rest of this document continues as follows. The first section contains the input for panel unit root tests conducted on the dependent variables in the text, Directed Credit and Taxation. The second contains models that show that including a linear time trend in simple dynamic fixed effects models reduces the size of the coefficient of the lagged dependent variable (LDV); this justifies estimating the System GMM Models reported in the paper with a linear time trend. The third section contains the models reported in Table 2, where Directed Credit is the dependent variable and a first round of System GMM models with few controls, but with several different ways of reducing the instrument count, are estimated. The fourth contains the models reported in Table 3, where Directed Credit is again the dependent variable but models that introduce a greater number of controls are estimated. The fifth section contains several models in which the dependent variable is Taxation; these are reported in Table 4.* 

*SECTION 1. Panel Unit Root Tests for Directed Credit and Total_Taxes_GDP; first open the panel dataset labeled “Country Year Dataset” in Stata; the data is already primed for panel data analysis; I’ve previously asked Stata to treat this data in that way by executing the following command: xtset wbcodeMEN year. Next, call up the package for the Augmented Dickey Fuller panel unit root test called xtfisher; do this by typing in the following command in Stata*

findit xtfisher

*next, download this package by clicking on the following link, xtfisher from http://fmwww.bc.edu/RePEc/bocode/x, and then pressing “install”; then call up the package for the dynamic panel GMM regression suite by typing the following command*

findit xtabond2

*next, download this package by clicking on the following link, st0091, and then pressing “install”; then, quietly run the first model in Table 2, where Directed Credit is the dependent variable, so that you can then run Augmented Dickey Fuller tests on the same sample of observations as this model by using the e(sample) command; this model will be explained at greater length in Section 2*

quietly xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, collapse) iv(year) twostep
 
*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Directed Credit on the sample of observations associated with the model that was estimated above; this and all of the unit root tests that follow below are referred to in footnote 12* 

xtfisher credittogovtstateenterp if e(sample), lag(1)

*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Directed Credit and a trend on the sample of observations associated with the model that was estimated above* 

xtfisher credittogovtstateenterp if e(sample), lag(1) trend

*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Directed Credit and drift on the sample of observations associated with the model that was estimated above* 

xtfisher credittogovtstateenterp if e(sample), lag(1) drift

*now we will repeat this battery of Augmented Dickey Fuller tests on Total_Taxes_GDP, since it is the other dependent variable used in the paper; that means that we will quietly run an analog of the first model in Table 4—it is identical, except that it does not include the interaction term between Directed Credi and the IQG index—where Total_Taxes_GDP is the dependent variable; this is so that you can then run Augmented Dickey Fuller tests on the same sample as this model by using the e(sample) command*

quietly xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog, collapse) iv(year) twostep

*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Total_Taxes_GDP on the sample of observations associated with the model that was estimated above* 

xtfisher final_totaltax_gdp_ratio if e(sample), lag(1)

*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Total_Taxes_GDP and a trend on the sample of observations associated with the model that was estimated above* 

xtfisher final_totaltax_gdp_ratio if e(sample), lag(1) trend

*then, run the following command, which is an Augmented Dickey Fuller test with one lag length on Total_Taxes_GDP and drift on the sample of observations associated with the model that was estimated above* 

xtfisher final_totaltax_gdp_ratio if e(sample), lag(1) drift

*SECTION 2. Introducing Linear Trends into Dynamic Fixed Effects Regressions; the command below runs a regular fixed effects model in which Directed Credit is the dependent variable with an LDV; this, and the regular fixed effects model in which Total Taxes GDP is the dependent variable with an LDV, are explained in footnote 13*

xtreg credittogovtstateenterp l.credittogovtstateenterp, fe

*almost the same model is run again, except that it now includes a linear time trend*

xtreg credittogovtstateenterp l.credittogovtstateenterp year, fe

*you should get a result that is almost identical; the difference between the models, as outlined in the text, is that the LDV coefficient shrinks*

*the command below runs a regular fixed effects model with an LDV, the dependent variable is now Total Taxes GDP*

xtreg final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio, fe

*almost the same model is run again, except that it now includes a linear time trend*

xtreg final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio year, fe

*you should get a very similar result; the difference between the models, as outlined in the text, is that the LDV coefficient shrinks*

*SECTION 3. SYSTEM GMM REGRESSIONS REPORTED IN TABLE 2; the model estimated below is reported in Table 2, Column 1; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, collapse) iv(year) twostep

*this command is a post-estimation command that allows me to estimate the beta coefficient and standard error for the long run effect; it uses the Delta Method due to the fact that it’s a ratio; this effect is reported in the text*

nlcom(_b[l.icrg_qog])/(1-(_b[l.credittogovtstateenterp]))

*now I estimate the summary stats reported in Table 1 for Directed Credit, the ICRG_QOG, and private credit, respectively, using the sample of observations provided by the regression estimated above*

sum credittogovtstateenterp l.icrg_qog l.privatecredit if e(sample)

*the model estimated below is reported in Table 2, Column 2; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; lag lengths are constrained to be between 1 and 2 to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues.*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, lag(1 2)) iv(year) twostep

*the model estimated below is reported in Table 2, Column 3; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; lag lengths are constrained to be between 2 and 3 to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues.*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, lag(2 3)) iv(year) twostep

*the model estimated below is reported in Table 2, Column 4; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; lag lengths are constrained to be between 3 and 4 to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues.*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, lag(3 4)) iv(year) twostep

*the model estimated below is reported in Table 2, Column 5; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; lag lengths are constrained to be between 4 and 5 to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues.*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, lag(4 5)) iv(year) twostep

*the model estimated below is reported in Table 2, Column 6; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; a principal components (pca) strategy in which the instruments are reduced using their eigenvalues is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues; first, one needs to tell Stata to estimate the System GMM regression in a way that favors space over speed to exploit the pca approach.*

mata: mata set matafavor speed, perm
xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit) iv(year) twostep pca

*the model estimated below is reported in Table 2, Column 7; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog and lagged private credit; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse approach is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues; moreover, the standard errors are adjusted with Windmeijer’s finite sample correction.*

xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit, collapse) iv(year) twostep robust

*SECTION 4. SYSTEM GMM REGRESSIONS REPORTED IN TABLE 3; the model estimated below is reported in Table 3, Column 1; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, and lagged Oil Rents; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent, collapse) iv(year) twostep
*the summary stats for Oil Rents were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_oilrent if e(sample)

*the model estimated below is reported in Table 3, Column 2; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, and lagged Economic Growth; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr, collapse) iv(year) twostep

*the summary stats for Economic Growth were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_gdpgr if e(sample)

*the model estimated below is reported in Table 3, Column 3; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, lagged Economic Growth, and lagged Government Debt; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_cgovd year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_cgovd, collapse) iv(year) twostep

*the summary stats for Government Debt were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_cgovd if e(sample)

*the model estimated below is reported in Table 3, Column 4; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, lagged Economic Growth, lagged Government Debt, and lagged FDI; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd, collapse) iv(year) twostep

*the summary stats for FDI were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_fdiin if e(sample)

*the model estimated below is reported in Table 3, Column 5; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, lagged Economic Growth, lagged Government Debt, lagged FDI, and lagged Inflation; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex, collapse) iv(year) twostep

*the summary stats for Inflation were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.inflationavgindex if e(sample)

*the model estimated below is reported in Table 3, Column 6; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, lagged Economic Growth, lagged Government Debt, lagged FDI, lagged Inflation, and lagged Federalism; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f, collapse) iv(year) twostep

*the summary stats for Federalism were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.h_f if e(sample)

*the model estimated below is reported in Table 3, Column 7; it is a System GMM regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged private credit, lagged Oil Rents, lagged Economic Growth, lagged Government Debt, lagged FDI, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*this command is a post-estimation command that allows me to estimate the beta coefficient and standard error for the long run effect; it uses the Delta Method due to the fact that it’s a ratio; this effect is reported in the text*

nlcom(_b[l.icrg_qog])/(1-(_b[l.credittogovtstateenterp]))

*the summary stats for Regime Type were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.p_polity2 if e(sample)

*SECTION 5. MODELS IN TABLE 4 OF THE TEXT, TOTAL_TAXES_GDP IS THE DEPENDENT VARIABLE; first, generate an interaction term for the multiplicative relationship of Directed Credit and the ICRG_QOG index*

generate INTERACTION1 = l.credittogovtstateenterp*l.icrg_qog

*the model estimated below is reported in Table 4, Column 1; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit; and the interaction term of these two lagged variables; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1, collapse) iv(year) twostep

*the summary stats for Total Taxes GDP were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum final_totaltax_gdp_ratio if e(sample)

*below, I identify the bevy of commands I used to generate predictions about how the interaction of Directed Credit and ICRG_QOG impacts Total Taxes GDP; these predictions are outlined in the paper, directly following the discussion of Table 4, Column 1; to calculate the predictions I use the nlcom command; it recruits the Delta Method, which is suited to make sense of the multiplicative relationship implied by the interaction term*

*first, we need to calculate very detailed summary statistics for Directed Credit*

sum l.credittogovtstateenterp if e(sample), detail

*because most of the predictions calculated below and discussed in the paper hold the other variables at their means, we must also calculate those variables’ means to be able to hold them constant*

sum l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 year if e(sample)

*first, I calculate a series of predictions that show how helpful it is for countries at the lowest level of state capacity to increase the amount of credit they direct to the state and SOEs*

*at the 25th percentile of Directed Credit, countries with the lowest level of state capacity obtain 17 percent of taxes from GDP; *

nlcom _b[_cons] +  3.34*_b[l.credittogovtstateenterp]+ 0*_b[l.icrg_qog]+(0*3.34)*_b[INTERACTION1]+20.64453*_b[l.final_totaltax_gdp_ratio]+1997.31*_b[year]

*at the 75th percentile, the weakest states obtain 17.8 taxes (% GDP)*

nlcom _b[_cons] +  14.25*_b[l.credittogovtstateenterp]+ 0*_b[l.icrg_qog]+(0*14.25)*_b[INTERACTION1]+20.64453*_b[l.final_totaltax_gdp_ratio]+1997.31*_b[year]

*at the 99th Percentile, they obtain 22% of GDP in Taxes*

nlcom _b[_cons] +  64.125*_b[l.credittogovtstateenterp]+ 0*_b[l.icrg_qog]+(0*64.125)*_b[INTERACTION1]+20.64453*_b[l.final_totaltax_gdp_ratio]+1997.31*_b[year]

*now, I make a prediction for Haiti in 1986; Haiti has total taxation % GDP of 10.18 that year and Directed Credit that is 0.27 % GDP; what if Haiti instead had the 75th percentile level of directed credit that year?*

nlcom _b[_cons] + 14.25*_b[l.credittogovtstateenterp]+.0555556*_b[l.icrg_qog]+(.0555556*14.25)*_b[INTERACTION1]+ 11.7192*_b[l.final_totaltax_gdp_ratio]+1986*_b[year]

*and what if Haiti would have had the 99th percentile of directed credit that year?* 

nlcom _b[_cons] + 64.125*_b[l.credittogovtstateenterp]+.0555556*_b[l.icrg_qog]+(.0555556*64.125)*_b[INTERACTION1]+ 11.7192*_b[l.final_totaltax_gdp_ratio]+1986*_b[year]

*at the 99th Percentile of Directed Credit, states with the lowest state capacity obtain greater tax revenues than states with the highest state capacity* 

*here I calculate the prediction for states with the lowest state capacity at that level of directed credit* 

nlcom _b[_cons] + 64.125*_b[l.credittogovtstateenterp]+0*_b[l.icrg_qog]+(0*64.125)*_b[INTERACTION1]+20.64453*_b[l.final_totaltax_gdp_ratio]+1997.31*_b[year]

*here I calculate the prediction for states with highest state capacity and in the 99th percentile of directed credit*

nlcom _b[_cons] +  64.125*_b[l.credittogovtstateenterp]+ 1*_b[l.icrg_qog]+(1*64.125)*_b[INTERACTION1]+20.64453*_b[l.final_totaltax_gdp_ratio]+1997.31*_b[year]

*the model estimated below is reported in Table 4, Column 2; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, and lagged Oil Rents; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent, collapse) iv(year) twostep

*the model estimated below is reported in Table 4, Column 3; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, lagged Oil Rents, and lagged Economic Growth; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent l.wdi_gdpgr year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_gdpgr l.wdi_oilrent, collapse) iv(year) twostep

*the model estimated below is reported in Table 4, Column 4; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, lagged Oil Rents, lagged Economic Growth, and lagged FDI; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin, collapse) iv(year) twostep

*the model estimated below is reported in Table 4, Column 5; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, lagged Oil Rents, lagged Economic Growth, lagged FDI, lagged Inflation; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.inflationavgindex year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.inflationavgindex, collapse) iv(year) twostep

*the model estimated below is reported in Table 4, Column 6; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, lagged Oil Rents, lagged Economic Growth, lagged FDI, lagged Inflation, and lagged Trade Openness; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.inflationavgindex l.wdi_merchtrade year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.inflationavgindex l.wdi_merchtrade, collapse) iv(year) twostep

*the summary stats for Trade Openness were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_merchtrade if e(sample)

*the model estimated below is reported in Table 4, Column 7; it is a System GMM regression in which Total Taxation GDP is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Directed Credit, the interaction term of these two lagged variables, lagged Oil Rents, lagged Economic Growth, lagged FDI, lagged Inflation, lagged Trade Openness, and lagged Manufacturing; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 final_totaltax_gdp_ratio l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.inflationavgindex l.wdi_merchtrade l.wdi_manvagdp year, gmm(l.final_totaltax_gdp_ratio l.credittogovtstateenterp l.icrg_qog INTERACTION1 l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.inflationavgindex l.wdi_merchtrade l.wdi_manvagdp, collapse) iv(year) twostep

*the summary stats for Manufacturing were estimated after this regression in order to calculate them on the sample with the greatest number of observations; to do so, the following command was used*

sum l.wdi_manvagdp if e(sample)





































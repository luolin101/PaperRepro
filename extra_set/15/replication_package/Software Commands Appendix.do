*This document offers instructions on how to reproduce the analytic results reported and discussed in the supplementary appendix to “The Fiscal Roots of Financial Underdevelopment” using a Stata country year panel dataset with global coverage. This dataset is called Country Year Dataset. This document also contains commands used to download statistical packages that are not already loaded into Stata 11, as well as commands to create new variables such as interaction terms, for models with muliplicative terms that are a combination of variables in the dataset. Two general notes follow. First, note that the l.variablename command tells Stata to use the lagged value of the variable in the regression. The independent variables in the regressions that follow are always lagged using this approach, which is available once the dataset is declared to be a panel dataset; as explained below, I’ve already primed the Country Year Dataset to be treated as a panel dataset. The rest of this document continues as follows. The models estimated test additional empirical implications of the theory. Each of these models is estimated via the System GMM dynamic panel approach. These are flagged in footnote 8 of the paper. The second section contains models that represent robustness tests to the System GMM approach; across these alternative specifications Directed Credit is the dependent variable. These models are flagged in footnote 11 of the paper. The third section includes the commands used to generate a figure that complements the justification for the use of the number of political assassinations that occurred in a country between 1964 and 1976 as an instrument for the ICRG_QOG index in the two stage instrumental variables regressions estimated in the supplementary appendix; these are included among the robustness tests reported and discussed in the supplementary appendix.* 

*SECTION 1. SYSTEM GMM REGRESSIONS REPORTED IN TABLE 1.1; first open the panel dataset labeled “Country Year Dataset” in Stata; the data is already primed for panel data analysis; I’ve previously asked Stata to treat this data in that way by executing the following command: xtset wbcodeMEN year* 

*the model estimated below is reported in Table 1.1, Column 1; it is a System GMM regression in which Net Interest Margin is the dependent variable; the model also includes a lagged dependent variable (LDV), lagged icrg_qog, lagged Economic Growth, lagged Oil Rents, lagged Inflation, lagged Government Debt, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 netinterestmargin l.netinterestmargin l.icrg_qog l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.icrg_qog l.netinterestmargin l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*the model estimated below is reported in Table 1.1, Column 2; it is a System GMM regression in which Return on Bank Assets is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 returnassets l.returnassets l.icrg_qog l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.icrg_qog l.returnassets l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*the model estimated below is reported in Table 1.1, Column 3; it is a System GMM regression in which Bank Overhead Costs is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 overheadcosts l.overheadcosts l.icrg_qog l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.icrg_qog l.overheadcosts l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*the model estimated below is reported in Table 1.1, Column 4; it is a System GMM regression in which Liquidity is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 llgdp l.llgdp l.icrg_qog l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.icrg_qog l.llgdp l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*the model estimated below is reported in Table 1.1, Column 5; it is a System GMM regression in which Private Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, and lagged Regime Type; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

xi: xtabond2 privatecredit l.privatecredit l.icrg_qog l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, gmm(l.icrg_qog l.privatecredit l.wdi_oilrent l.wdi_gdpgr l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2, collapse)iv(year) twostep

*the model estimated below is reported in Table 1.1, Column 6; it is a System GMM regression in which Market Power is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Financial System Barriers, an interaction term of these two lagged variables, lagged Economic Growth, and lagged Oil Rents; each of these independent variables is treated as potentially endogenous and thus instrumented with available lags in differences and levels; the model also includes a linear time trend that is not instrumented; the collapse function is used to reduce the instrument count, and the two step option to produce results robust to non-spherical error issues*

*for the following model, I first estimated an interaction term for the multiplicative relationship of Financial System Entry Barriers and the ICRG_QOG index*

generate INTERACTION2 = l.entrybarriers*l.icrg_qog

xi: xtabond2 marketpower l.marketpower l.entrybarriers l.icrg_qog INTERACTION2 l.wdi_gdpgr l.wdi_oilrent year, gmm(l.marketpower l.entrybarriers l.icrg_qog INTERACTION2 l.wdi_gdpgr l.wdi_oilrent, collapse)iv(year) twostep

*below, I identify the bevy of commands I used to generate predictions about how the interaction of Financial System Entry Barriers and ICRG_QOG impacts banks’ market power; these predictions are outlined in the supplementary appendix, directly following the discussion of Table 1.1, Column 6; to calculate the predictions I use the nlcom command; it recruits the Delta Method, which is suited to make sense of the multiplicative relationship implied by the interaction term*

*because most of the predictions calculated below and discussed in the paper hold the other variables at their means, we must also calculate those variables’ means to be able to hold them constant*

sum l.marketpower l.entrybarriers l.icrg_qog INTERACTION2 l.wdi_gdpgr l.wdi_oilrent year if e(sample)

*first, I calculate a prediction of the level of market power by banks at the highest level of entry barriers and the weakest state capacity*

nlcom _b[_cons] +  0*_b[l.entrybarriers]+ 0*_b[l.icrg_qog]+(0*0)*_b[INTERACTION2]+.2084971*_b[l.marketpower]+ 4.040356*_b[l.wdi_gdpgr]+2.990577*_b[l.wdi_oilrent]+2001.639*_b[year]

*second, I calculate a prediction of the level of market power by banks at the highest level of entry barriers and a middling level of state capacity*

nlcom _b[_cons] +  0*_b[l.entrybarriers]+ 0.5*_b[l.icrg_qog]+(0*0.5)*_b[INTERACTION2]+.2084971*_b[l.marketpower]+ 4.040356*_b[l.wdi_gdpgr]+2.990577*_b[l.wdi_oilrent]+2001.639*_b[year]

*third, I calculate a prediction of the level of market power by banks at the highest level of entry barriers and the highest level of state capacity*

nlcom _b[_cons] +  0*_b[l.entrybarriers]+ 1*_b[l.icrg_qog]+(0*1)*_b[INTERACTION2]+.2084971*_b[l.marketpower]+ 4.040356*_b[l.wdi_gdpgr]+2.990577*_b[l.wdi_oilrent]+2001.639*_b[year]

*SECTION 2. ALTERNATIVE SPECIFICATIONS REPORTED IN TABLE 2.1 AND TABLE 2.2; the model estimated below is reported in Table 2.1, Column 1; it is a pooled Ordinary Least Squares (OLS) regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, and a linear time trend; panel corrected standard errors are estimated, with an AR1 Prais Winsten transformation that varies by panel, to produce results robust to non-spherical error issues; the pairwise option used to address listwise deletion*

xi: xtpcse credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year, corr(psar1) pairwise

*this command is a post-estimation command that allows me to estimate the beta coefficient and standard error for the long run effect; it uses the Delta Method due to the fact that it’s a ratio; this effect is reported in the appendix text*

nlcom(_b[l.icrg_qog])/(1-(_b[l.credittogovtstateenterp]))

*the model estimated below is reported in Table 2.1, Column 2; it is a country fixed effects OLS regression in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, a linear time trend, and country dummy variables; panel corrected standard errors are estimated, with an AR1 Prais Winsten transformation that varies by panel, to produce results robust to non-spherical error issues; the pairwise option used to address listwise deletion*

xi: xtpcse credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year i.wbcodeMEN, corr(psar1) pairwise

*the model estimated below is reported in Table 2.1, Column 3; it is a country fixed effects OLS regression with country specific trends in which Directed Credit is the dependent variable; the model also includes an LDV, lagged icrg_qog, lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, a linear time trend, country dummy variables, and country specific trends, which are the byproduct of the interaction between the country dummies and the linear time trend (this is specified directly in the Stata script for the model, in the following way: i.wbcodeMEN*year); panel corrected standard errors are estimated, with an AR1 Prais Winsten transformation that varies by panel, to produce results robust to non-spherical error issues; the pairwise option used to address listwise deletion; note that before estimating the model one must expand the matsize*

set matsize 800
xi: xtpcse credittogovtstateenterp l.credittogovtstateenterp l.icrg_qog l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f  l.p_polity2 i.wbcodeMEN*year, corr(psar1) pairwise

*this command is a post-estimation command that allows me to estimate the beta coefficient and standard error for the long run effect; it uses the Delta Method due to the fact that it’s a ratio; this effect is reported in the appendix text*

nlcom(_b[l.icrg_qog])/(1-(_b[l.credittogovtstateenterp]))

*now we move on to estimating the instrumental variables two stage (IV-2SLS) models reported in Table 2.2; this means calling up the package for the dynamic panel GMM regression suite by typing the following command*

findit ivreg2

*next, download this package by clicking on the following link, st0030_3, and then pressing “install”* 

*the model estimated below is reported in Table 2.2, Columns 1a and 1b; it is a pooled IV-2SLS regression in which the ICRG_QOG (t-1) is the dependent variable in the first stage model (Column 1a), and the excluded instrument is assassinations_64_76, and Directed Credit is the dependent variable in the second stage model (Column 1b); both stages also include lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, and a linear time trend; Newey West standard errors are estimated to produce results robust to non-spherical error issues; the model is circumscribed to the sample of countries for which there was data on the instrumental variable between 1964 and 1976 via “if NOT_SOVEREIGN_YET5 != 1” in the Stata script, implying that countries that did not yet exist during that time period are not included in the regression*

xi: ivreg2 credittogovtstateenterp l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year (l.icrg_qog = assassinations_64_76) if NOT_SOVEREIGN_YET5 != 1, first bw(2) kernel(bartlett) robust

*the model estimated below is reported in Table 2.2, Columns 2a and 2b; it is a region fixed effects IV-2SLS regression in which the ICRG_QOG (t-1) is the dependent variable in the first stage model (Column 2a), and the excluded instrument is assassinations_64_76, and Directed Credit is the dependent variable in the second stage model (Column 2b); both stages also include lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, a linear time trend, and a set of region dummies; Newey West standard errors are estimated to produce results robust to non-spherical error issues; the model is circumscribed to the sample of countries for which there was data on the instrumental variable between 1964 and 1976 via “if NOT_SOVEREIGN_YET5 != 1” in the Stata script, implying that countries that did not yet exist during that time period are not included in the regression*

xi: ivreg2 credittogovtstateenterp l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year i.ht_region (l.icrg_qog = assassinations_64_76) if NOT_SOVEREIGN_YET5 != 1, first bw(2) kernel(bartlett) robust

*the model estimated below is reported in Table 2.2, Columns 3a and 3b; it is a region fixed effects IV-2SLS regression with region specific time trends in which the ICRG_QOG (t-1) is the dependent variable in the first stage model (Column 3a), and the excluded instrument is assassinations_64_76, and Directed Credit is the dependent variable in the second stage model (Column 3b); both stages also include lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, a linear time trend, and a set of region dummies; the region specific trends are the byproduct of the interaction between the region dummies and the linear time trend (this is specified directly in the Stata script for the model, in the following way: i.ht_region*year); Newey West standard errors are estimated to produce results robust to non-spherical error issues; the model is circumscribed to the sample of countries for which there was data on the instrumental variable between 1964 and 1976 via “if NOT_SOVEREIGN_YET5 != 1” in the Stata script, implying that countries that did not yet exist during that time period are not included in the regression*

xi: ivreg2 credittogovtstateenterp l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 year i.ht_region*year (l.icrg_qog = assassinations_64_76) if NOT_SOVEREIGN_YET5 != 1, first bw(2) kernel(bartlett) robust

*the model estimated below is reported in Table 2.2, Columns 4a and 4b; it is a region fixed effects IV-2SLS regression with region specific time trends in which the ICRG_QOG (t-1) is the dependent variable in the first stage model (Column 4a), and the excluded instrument is assassinations_64_76, and Directed Credit is the dependent variable in the second stage model (Column 4b); both stages also include lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, lagged Political Assassinations, a linear time trend, and a set of region dummies; the region specific trends are the byproduct of the interaction between the region dummies and the linear time trend (this is specified directly in the Stata script for the model, in the following way: i.ht_region*year); Newey West standard errors are estimated to produce results robust to non-spherical error issues; the model is circumscribed to the sample of countries for which there was data on the instrumental variable between 1964 and 1976 via “if NOT_SOVEREIGN_YET5 != 1” in the Stata script, implying that countries that did not yet exist during that time period are not included in the regression*

xi: ivreg2 credittogovtstateenterp l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 l.assassinations year i.ht_region*year (l.icrg_qog = assassinations_64_76) if NOT_SOVEREIGN_YET5 != 1, first bw(2) kernel(bartlett) robust

*the model estimated below is reported in Table 2.2, Columns 5a and 5b; it is a region fixed effects IV-2SLS regression with region specific time trends in which the ICRG_QOG (t-1) is the dependent variable in the first stage model (Column 5a), and the excluded instrument is assassinations_51_63, and Directed Credit is the dependent variable in the second stage model (Column 5b); both stages also include lagged Private Credit, lagged Economic Growth, lagged Oil Rents, lagged Government Debt, lagged Inflation, lagged Federalism, lagged Regime Type, lagged Political Assassinations, a linear time trend, and a set of region dummies; the region specific trends are the byproduct of the interaction between the region dummies and the linear time trend (this is specified directly in the Stata script for the model, in the following way: i.ht_region*year); Newey West standard errors are estimated to produce results robust to non-spherical error issues; the model is circumscribed to the sample of countries for which there was data on the instrumental variable between 1951 and 1963 via “if NOT_SOVEREIGN_YET3 != 1” in the Stata script, implying that countries that did not yet exist during that time period are not included in the regression*

xi: ivreg2 credittogovtstateenterp l.privatecredit l.wdi_gdpgr l.wdi_oilrent l.wdi_fdiin l.wdi_cgovd l.inflationavgindex l.h_f l.p_polity2 l.assassinations year i.ht_region*year (l.icrg_qog = assassinations_51_63) if NOT_SOVEREIGN_YET3 != 1, first bw(2) kernel(bartlett) robust

*SECTION 3. Constructing the figure on political assassinations; first open the panel dataset labeled “Country Year Dataset” in Stata; the data is already primed for panel data analysis; I’ve previously asked Stata to treat this data in that way by executing the following command: xtset wbcodeMEN year* 

*now generate the average political assassinations each year*

egen assassinations_byyear = mean(assassinations), by(year)

*next, create a 3 year moving average*

tssmooth ma assassinationsbyyear_MA3 =  assassinations_byyear, window(3)

*now generate a time series graph of this three year moving average; use the xtline command, which is basically for panel data; but since this is the moving average for an average across countries, you need to graph it for a particular country, even though every country should have the same average each year; thus, graph this moving average for the United States—it’s Correlates of War code is “2”—because it is in the dataset between the years that are graphed, 1950 and 1977*

xtline assassinationsbyyear_MA3 if ccodecow == 2 & year > 1950 & year < 1977



























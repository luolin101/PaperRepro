*Step 2 
*Append all the year files together

*cd*
use "LiK10_data_stata_rec/wave2010.dta", clear

append using "LiK11_data_stata_rec/wave2011.dta"

append using "LiK12_data_stata_rec/wave2012.dta"

append using "LiK13_data_stata_rec/wave2013.dta"

*Firstly, create combined individual identified from mroster
gen idpnew=.
replace idpnew=idpnew10 if year==2010
replace idpnew=idpnew11 if year==2011
replace idpnew=idpnew12 if year==2012
replace idpnew=idpnew13 if year==2013

*Check to see if there are any duplicates in the data
duplicates list idpnew year 
drop if idpnew==.

rename idpnew idpp
xtset idpp year


*Now create panel-specific unique hhid identifier
gen hhid=. 
replace hhid=hhid10 if year==2010
replace hhid=hhid11 if year==2011
replace hhid=hhid12 if year==2012
replace hhid=hhid13 if year==2013

*Keep variables for analysis

keep idpp hhid year livingsat10 hheconsat10 riskaccept10 educ10 employed10  em_sector10 intentmigrate10 econ_concern10 altpres_trust10                        comleader_trust10 faminfo10 nninfo10 radioinfo10 TVinfo10 paperinfo10 internetinfo10 gender10 yob10 ethnicity10 marital10 ta10 hhmembersa10 fa10 hhfemalea10 femalehha10 total_index10 total_income10 hasremittances10 remittances_amount10 remittances_currency10 remfreq_year10 rem_when10 rem_stableamount10 affected_landsl10 agriloss10 oblast10 idpnew10 ///
                    livingsat11 hheconsat11 riskaccept11 educ11 employed11  em_sector11 intentmigrate11 econ_concern11 altpres_trust11                        comleader_trust11 faminfo11 nninfo11 radioinfo11 TVinfo11 paperinfo11 internetinfo11 gender11 yob11 ethnicity11 marital11 ta11 hhmembersa11 fa11 hhfemalea11 femalehha11 total_index11 total_income11 hasremittances11 remittances_amount11 remittances_currency11 remfreq_year11 rem_when11 rem_stableamount11 affected_landsl11 agriloss11 oblast11 idpnew11 ///
		            livingsat12 hheconsat12 riskaccept12 educ12 employed12  em_sector12 intentmigrate12 econ_concern12 altpres_trust12                        comleader_trust12 faminfo12 nninfo12 radioinfo12 TVinfo12 paperinfo12 internetinfo12 gender12 yob12 ethnicity12 marital12 ta12 hhmembersa12 fa12 hhfemalea12 femalehha12 total_index12 total_income12 hasremittances12 remittances_amount12 remittances_currency12 remfreq_year12 rem_when12 rem_stableamount12 affected_landsl12 agriloss12 oblast12 idpnew12 ///
		            livingsat13 hheconsat13 riskaccept13 educ13 employed13  em_sector13 intentmigrate13 econ_concern13                pres_trust13 gov_trust13                  faminfo13 nninfo13 radioinfo13 TVinfo13 paperinfo13 internetinfo13 gender13 yob13 ethnicity13 marital13 ta13 hhmembersa13 fa13 hhfemalea13 femalehha13 total_index13 total_income13 hasremittances13 remittances_amount13 remittances_currency13 remfreq_year13 rem_when13 rem_stableamount13 affected_landsl13 agriloss13 oblast13 idpnew13 satisfied_socsecu13 satisfied_educ13 satisfied_health13 satisfied_housing13 satisfied_transport13 satisfied_services13

save "LiK_final_short.dta", replace
********************************************************************************
********************************************************************************

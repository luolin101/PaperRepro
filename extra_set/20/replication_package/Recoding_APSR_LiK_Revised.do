********************************************************************************
********************************************************************************
**To run the code, have all files in the same location*

use "LiK_final_short.dta"


*STEP 3
*Recode & save variables for analysis 

*Dependent Variables

*Incumbent Trust

egen altpres_trust13 = rowmean(pres_trust13 gov_trust13) if year == 2013
replace altpres_trust13=round(altpres_trust13, 1)

gen altpres_trust = .
replace altpres_trust = altpres_trust10 if year ==2010
replace altpres_trust = altpres_trust11 if year ==2011
replace altpres_trust = altpres_trust12 if year ==2012
replace altpres_trust = altpres_trust13 if year ==2013
xtset idpp year
sort idpp year
gen difftrustaltpres = d.altpres_trust

gen altpres_trust1 = .
replace altpres_trust1 = altpres_trust10 if year ==2010
replace altpres_trust1 = altpres_trust11 if year ==2011
replace altpres_trust1 = altpres_trust12 if year ==2012
replace altpres_trust1 = gov_trust13 if year ==2013
xtset idpp year
sort idpp year
gen difftrustaltpres1 =  d.altpres_trust1

gen altpres_trust2 = .
replace altpres_trust2 = altpres_trust10 if year ==2010
replace altpres_trust2 = altpres_trust11 if year ==2011
replace altpres_trust2 = altpres_trust12 if year ==2012
replace altpres_trust2 = pres_trust13 if year ==2013
xtset idpp year
sort idpp year
gen difftrustaltpres2 = d.altpres_trust2

* Trust in community leaders
gen comleader_trust = .
replace comleader_trust = comleader_trust10 if year ==2010
replace comleader_trust = comleader_trust11 if year ==2011
replace comleader_trust = comleader_trust12 if year ==2012
xtset idpp year
sort idpp year
gen difftrustcom = d.comleader_trust

*Economic Concern
gen econ_concern = .
replace econ_concern = econ_concern10 if year ==2010
replace econ_concern = econ_concern11 if year ==2011
replace econ_concern = econ_concern12 if year ==2012
replace econ_concern = econ_concern13 if year ==2013
xtset idpp year
sort idpp year
gen diffeconconcern = d.econ_concern

********************************************************************************
*Main Independent Variables

*Remittances in Currency Amount

gen remittances_amount = .
replace remittances_amount = remittances_amount10 if year ==2010
replace remittances_amount = remittances_amount11 if year ==2011
replace remittances_amount = remittances_amount12 if year ==2012
replace remittances_amount = remittances_amount13 if year ==2013

gen remittances_currency = .
replace remittances_currency = remittances_currency10 if year ==2010
replace remittances_currency = remittances_currency11 if year ==2011
replace remittances_currency = remittances_currency12 if year ==2012
replace remittances_currency = remittances_currency13 if year ==2013


gen amountconverted = .
*2010
replace amountconverted = remittances_amount*46 if remittances_currency10 == 2 & year == 2010
replace amountconverted = remittances_amount*1.5 if remittances_currency10 == 3 & year == 2010
replace amountconverted = remittances_amount*60 if remittances_currency10 == 4 & year == 2010
replace amountconverted = remittances_amount if remittances_currency10 ==1 & year == 2010

*2011
replace amountconverted = remittances_amount*47 if remittances_currency11 == 2 & year == 2011
replace amountconverted = remittances_amount*1.6 if remittances_currency11 == 3 & year == 2011
replace amountconverted = remittances_amount*64 if remittances_currency11 == 4 & year == 2011
replace amountconverted = remittances_amount if remittances_currency11 ==1 & year == 2011

*2012
replace amountconverted = remittances_amount*47 if remittances_currency12 == 2 & year == 2012
replace amountconverted = remittances_amount*1.5 if remittances_currency12 == 3 & year == 2012
replace amountconverted = remittances_amount*60 if remittances_currency12 == 4 & year == 2012
replace amountconverted = remittances_amount if remittances_currency12 ==1 & year == 2012

*2013
replace amountconverted = remittances_amount*48 if remittances_currency13 == 2 & year == 2013
replace amountconverted = remittances_amount*1.5 if remittances_currency13 == 3 & year == 2013
replace amountconverted = remittances_amount*65 if remittances_currency13 == 4 & year == 2013
replace amountconverted = remittances_amount if remittances_currency13 ==1 & year == 2013

*Rescale Remittances
replace amountconverted = amountconverted/100000
xtset idpp year
sort idpp year
gen diffamountrec = d.amountconverted

*Remittances Frequency 
gen remfreq_year = .
replace remfreq_year = remfreq_year10 if year ==2010
replace remfreq_year = remfreq_year11 if year ==2011
replace remfreq_year = remfreq_year12 if year ==2012
replace remfreq_year = remfreq_year13 if year ==2013

*When Receive
gen rem_when = .
replace rem_when = rem_when10 if year ==2010
replace rem_when = rem_when11 if year ==2011
replace rem_when = rem_when12 if year ==2012
replace rem_when = rem_when13 if year ==2013

*Receive Remittances - Y/N
gen hasremittances = .
replace hasremittances = hasremittances10 if year ==2010
replace hasremittances = hasremittances11 if year ==2011
replace hasremittances = hasremittances12 if year ==2012
replace hasremittances = hasremittances13 if year ==2013

* The Remittance Index
*Amount
gen amount=amountconverted*1000
recode amount (1/766.2363=1) (766.2364/2840=2) (2840/45500=3)

*Stability
recode rem_when (1=3)(2=2)(0=1), gen(stable)
gen remitindex=(amount+stable)
xtset idpp year
sort idpp year
gen diffremitindex = d.remitindex

*Frequency
gen freq_remit=remfreq_year
replace freq_remit=. if hasremittances==0
xtset idpp year
sort idpp year
gen difffremfreq = d.freq_remit

*Remit drop 

gen remit_drop=.
replace remit_drop=1 if diffamountrec < 0 |  difffremfreq < 0
replace remit_drop=1 if diffamountrec < 0 &  difffremfreq == .
replace remit_drop=1 if difffremfreq < 0 &  diffamountrec == .

replace remit_drop=0 if diffamountrec  >= 0 | difffremfreq >= 0
replace remit_drop=0 if diffamountrec >= 0 &  difffremfreq ==.
replace remit_drop=0 if difffremfreq >= 0 &  diffamountrec ==.
replace remit_drop = . if diffamountrec ==. & difffremfreq ==.

********************************************************************************
*Control Variables

*Education 
gen educ = .
replace educ = educ10 if year ==2010
replace educ = educ11 if year ==2011
replace educ = educ12 if year ==2012
replace educ = educ13 if year ==2013

*Use 2012 values for individuals who did not answer in 2013
sort idpp year
bysort idpp: gen lageduc=educ[_n-1]
replace lageduc = . if year~=2013
gen educ1 = educ
replace educ1 = lageduc if educ == . & year == 2013

recode educ1 (1=1) (2 3=2) (4 5 6=3) (7 8=4),into(educ_cat2)
label define educ_cat5 1 "Illiterate" 2 "Primary" 3 "Secondary" 4 "University"
label values educ_cat2 educ_cat5

tabulate educ_cat2, generate(educ_c)

*Marital
gen marital = .
replace marital = marital10 if year ==2010
replace marital = marital11 if year ==2011
replace marital = marital12 if year ==2012
replace marital = marital13 if year ==2013

*Gender
gen gender = .
replace gender = gender10 if year ==2010
replace gender = gender11 if year ==2011
replace gender = gender12 if year ==2012
replace gender = gender13 if year ==2013

*Age
gen age_adult = .
replace age_adult = yob10 if year ==2010
replace age_adult = yob11 if year ==2011
replace age_adult = yob12 if year ==2012
replace age_adult = yob13 if year ==2013

replace age_adult = . if age_adult <18

*Ethnicity 
gen ethnicity =. 
replace ethnicity = ethnicity10 if year ==2010
replace ethnicity = ethnicity11 if year ==2011
replace ethnicity = ethnicity12 if year ==2012
replace ethnicity = ethnicity13 if year ==2013

*Employed
gen employed = .
replace employed = employed10 if year ==2010
replace employed = employed11 if year ==2011
replace employed = employed12 if year ==2012
replace employed = employed13 if year ==2013

*Employment Sector
gen sector = .
replace sector = em_sector10 if year ==2010
replace sector = em_sector11 if year ==2011
replace sector = em_sector12 if year ==2012
replace sector = em_sector13 if year ==2013
tabulate sector, generate(sec)

*Intent to Migrate
gen intentmigrate = .
replace intentmigrate = intentmigrate10 if year ==2010
replace intentmigrate = intentmigrate11 if year ==2011
replace intentmigrate = intentmigrate12 if year ==2012
replace intentmigrate = intentmigrate13 if year ==2013

*Wealth Index
gen total_index= .
replace total_index = total_index10 if year ==2010
replace total_index = total_index11 if year ==2011
replace total_index = total_index12 if year ==2012
replace total_index = total_index13 if year ==2013

gen total_index2=total_index
recode total_index2 (1 2 3 4 5=5) (21/34=21)
gen total_index3=total_index2-4

*Income Received
gen tot_inc = . 
replace tot_inc = total_income10 if year ==2010
replace tot_inc = total_income11 if year ==2011
replace tot_inc = total_income12 if year ==2012
replace tot_inc = total_income13 if year ==2013

gen tot_inc_rec =tot_inc/100

*Life Satisfaction 
gen lifesat = .
replace lifesat = livingsat10 if year ==2010
replace lifesat = livingsat11 if year ==2011
replace lifesat = livingsat12 if year ==2012
replace lifesat = livingsat13 if year ==2013

gen lifesat2 = .
replace lifesat2 = hheconsat10 if year ==2010
replace lifesat2 = hheconsat11 if year ==2011
replace lifesat2 = hheconsat12 if year ==2012
replace lifesat2 = hheconsat13 if year ==2013

*Risk Acceptance
gen riskaccept = .
replace riskaccept = riskaccept10 if year ==2010
replace riskaccept = riskaccept11 if year ==2011
replace riskaccept = riskaccept12 if year ==2012
replace riskaccept = riskaccept13 if year ==2013

*Agricultural Loss
gen agriloss = .
replace agriloss = agriloss10 if year ==2010
replace agriloss = agriloss11 if year ==2011
replace agriloss = agriloss12 if year ==2012
replace agriloss = agriloss13 if year ==2013
label variable agriloss "Agricultural Profit Loss"

*Landslides 
gen affected_landsl = .
replace affected_landsl = affected_landsl10 if year ==2010
replace affected_landsl = affected_landsl11 if year ==2011
replace affected_landsl = affected_landsl12 if year ==2012
replace affected_landsl = affected_landsl13 if year ==2013
label variable affected_landsl "Affected by Landslides"

*Political Sophistication

gen TVinfo = .
replace TVinfo = TVinfo10 if year ==2010
replace TVinfo = TVinfo11 if year ==2011
replace TVinfo = TVinfo12 if year ==2012
replace TVinfo = TVinfo13 if year ==2013
label variable TVinfo "TV Information"

gen radioinfo = .
replace radioinfo = radioinfo10 if year ==2010
replace radioinfo = radioinfo11 if year ==2011
replace radioinfo = radioinfo12 if year ==2012
replace radioinfo = radioinfo13 if year ==2013
label variable radioinfo "Radio Information"

gen faminfo = .
replace faminfo = faminfo10 if year ==2010
replace faminfo = faminfo11 if year ==2011
replace faminfo = faminfo12 if year ==2012
replace faminfo = faminfo13 if year ==2013
label variable faminfo "Family Information"

gen nninfo = .
replace nninfo = nninfo10 if year ==2010
replace nninfo = nninfo11 if year ==2011
replace nninfo = nninfo12 if year ==2012
replace nninfo = nninfo13 if year ==2013
label variable nninfo "Neighbor Information"

gen paperinfo = .
replace paperinfo = paperinfo10 if year ==2010
replace paperinfo = paperinfo11 if year ==2011
replace paperinfo = paperinfo12 if year ==2012
replace paperinfo = paperinfo13 if year ==2013
label variable paperinfo "Paper Information"

gen internetinfo = .
replace internetinfo = internetinfo10 if year ==2010
replace internetinfo = internetinfo11 if year ==2011
replace internetinfo = internetinfo12 if year ==2012
replace internetinfo = internetinfo13 if year ==2013
label variable internetinfo "Internet Information"

gen seekinfo_cat3=faminfo+nninfo+radioinfo+TVinfo+paperinfo
recode seekinfo_cat3 (0 1=1) (4 5 6 7=4)

gen familyinfo=faminfo+nninfo+internetinfo
recode familyinfo (3 =4) (2=3) (1=2) (0=1)

*** Satisfaction with public services
gen satisfied_services=.
replace satisfied_services=satisfied_services13 if year==2013

*** Create identifier for HLM model

gen hhyear=.
replace hhyear=(hhid*100000)+2010 if year==2010
replace hhyear=(hhid*100000)+2011 if year==2011
replace hhyear=(hhid*100000)+2012 if year==2012
replace hhyear=(hhid*100000)+2013 if year==2013

tabulate year, generate(y)

***** Generate annual unemployment change in Russia
gen ru_unem=. 
replace ru_unem =7.2 if year==2010
replace ru_unem =6.1 if year==2011
replace ru_unem =5.1 if year==2012
replace ru_unem =5.6 if year==2013

gen lag_ru_unem=.
replace lag_ru_unem =7.2 if year==2011
replace lag_ru_unem =6.1 if year==2012
replace lag_ru_unem =5.1 if year==2013

gen difunemru=ru_unem-lag_ru_unem

**** Generate females/household 

gen femalehh = .
replace femalehh = femalehha10 if year ==2010
replace femalehh = femalehha11 if year ==2011
replace femalehh = femalehha12 if year ==2012
replace femalehh = femalehha13 if year ==2013

**** Create instrumental variable

**gen fhhunem=difunemru*femalehh
gen fhhunem=difunemru*femalehh

***Create oblast indicator

gen oblasts = .
replace oblasts = oblast10 if year ==2010
replace oblasts = oblast11 if year ==2011
replace oblasts = oblast12 if year ==2012
replace oblasts = oblast13 if year ==2013

/* Regional exports in million USD */
/* Downloaded from the National Statitistical Committee of the */
/* Kyrgyz Republic: http://www.stat.kg/en/opendata/category/31/ */
gen reg_export=. 
replace reg_export= 15.7 if oblasts==5 & year==2010 /*Batken*/
replace reg_export= 32.1 if oblasts==5 & year==2011 
replace reg_export= 34.7 if oblasts==5 & year==2012 
replace reg_export= 41.3 if oblasts==5 & year==2013 

replace reg_export= 55.7 if oblasts==3 & year==2010 /*Jalal-Abat*/
replace reg_export= 61.8 if oblasts==3 & year==2011 
replace reg_export= 137.7 if oblasts==3 & year==2012 
replace reg_export= 88.2 if oblasts==3 & year==2013

replace reg_export= 14.7 if oblasts==2 & year==2010 /*Issyk-Kul*/
replace reg_export= 15.7 if oblasts==2 & year==2011 
replace reg_export= 12.6 if oblasts==2 & year==2012 
replace reg_export= 15.1 if oblasts==2 & year==2013 

replace reg_export= 0.9 if oblasts==4 & year==2010 /*Naryn*/
replace reg_export= 0.6 if oblasts==4 & year==2011 
replace reg_export= 0.4 if oblasts==4 & year==2012 
replace reg_export= 0.4 if oblasts==4 & year==2013 

replace reg_export= 37.1 if oblasts==6 & year==2010 /*Osh oblast*/
replace reg_export= 45.6 if oblasts==6 & year==2011 
replace reg_export= 41.3 if oblasts==6 & year==2012 
replace reg_export= 19.3 if oblasts==6 & year==2013 

replace reg_export= 25.7 if oblasts==7 & year==2010 /*Talas*/
replace reg_export= 40.1 if oblasts==7 & year==2011 
replace reg_export= 33.2 if oblasts==7 & year==2012 
replace reg_export= 56   if oblasts==7 & year==2013 

replace reg_export= 231 if oblasts==8 & year==2010 /*Chui*/
replace reg_export= 100.8 if oblasts==8 & year==2011 
replace reg_export= 125.5 if oblasts==8 & year==2012 
replace reg_export= 117.8 if oblasts==8 & year==2013 

replace reg_export= 1020.8 if oblasts== 11 & year== 2010 /*Bishkek*/
replace reg_export= 1566.2 if oblasts== 11 & year==2011 
replace reg_export= 1163.1 if oblasts== 11 & year==2012 
replace reg_export= 1294.6 if oblasts== 11 & year==2013 

replace reg_export= 18.2 if oblasts== 21 & year== 2010 /*Osh city*/
replace reg_export= 28.6 if oblasts== 21 & year==2011 
replace reg_export= 32.5 if oblasts== 21 & year==2012 
replace reg_export= 56.0 if oblasts== 21 & year==2013 


save "LiK_final_rec.dta", replace

********************************************************************************
*End of recoding
********************************************************************************
********************************************************************************


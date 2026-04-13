**********************************************************************
*****LIFE IN KYRGYZSTAN SURVEYS: YEAR-BY-YEAR RECODING AND MERGING****
**********************************************************************

**********************************************
*The code below creates the 2012 year dataset*
**********************************************
clear
use "LiK12_data_stata/individual/id1.dta"
gen idp12=(hhid+pid/100)*100 
recode i101_3 (90=.), gen (hheconsat12)
recode i101_5 (90=.), gen (livingsat12) 
codebook hheconsat12 livingsat12, tab (50) 

gen riskaccept12=i103 
codebook riskaccept12, tab (50) 
save "LiK12_data_stata_rec/id1.dta", replace


use "LiK12_data_stata/individual/id2.dta"
gen idp12=(hhid+pid/100)*100
gen educ12=i207 
save "LiK12_data_stata_rec/id2.dta", replace


use "LiK12_data_stata/individual/id3.dta"
gen idp12=(hhid+pid/100)*100
recode i301 (1=1) (2=0), gen (work1)
gen employed12=work1
codebook employed12 i301, compact
recode i308 (1=1 "agrfish") (2/3=2 "manufacture") (4/5=3 "construction") (6=4 "trade") (8=5 "transport") (12=6 "education") (13=7 "social work") (7=8 "other") (9=8 "other") (10/11=8 "other") (14/16=8 "other")  (.=0 "not-stated"), gen (em_sector12) 
save "LiK12_data_stata_rec/id3.dta" , replace


use "LiK12_data_stata/individual/id4.dta"
gen idp12=(hhid+pid/100)*100
recode i413 (1=1) (2=0), gen (intentmigrate12)
tab intentmigrate12
codebook i413 intentmigrate12, compact
save "LiK12_data_stata_rec/id4.dta" ,replace


use "LiK12_data_stata/individual/id6.dta"
gen idp12=(hhid+pid/100)*100
gen econ_concern12= i601_1
codebook econ_concern12, tab (50) 
save "LiK12_data_stata_rec/id6.dta", replace
 
 
use "LiK12_data_stata/individual/id8c.dta"
gen idp12=(hhid+pid/100)*100
gen altpres_trust12= i821_4
gen comleader_trust12=i821_5

recode i822_1 (1=1) (2=0), gen (faminfo12) 
recode i822_2 (1=1) (2=0), gen (nninfo12) 
recode i822_4 (1=1) (2=0), gen (radioinfo12) 
recode i822_5 (1=1) (2=0), gen (TVinfo12)
recode i822_6 (1=1) (2=0), gen (paperinfo12) 
recode i822_7 (1=1) (2=0), gen (internetinfo12)  
save "LiK12_data_stata_rec/id8.dta", replace


use "LiK12_data_stata/household/hh1a.dta"
gen idp12=(hhid+pid/100)*100

recode h102 (1=1 "male") (2=0 "female"), gen (gender12)
codebook gender12, tab (50) 

gen yob12=(2012-h103_y)
sum yob12

recode h105 (1=1 "kyrgyz") (2/8=0 "other"), gen (ethnicity12)
codebook ethnicity12, tab (50)

recode h108 (1=1 "married") (2/7=0 "notmarried"), gen (marital12)
codebook marital12, tab (50)

*******CREATES FEMALES/ TOTAL HOUSEHOLD*************************
gen ta12=1 /*to create count of all members*/
gen fa12=1 if h102==2 /*create a count of all female members*/
egen hhmembersa12=sum(ta12), by (hhid) 
egen hhfemalea12=sum(fa12), by (hhid) /*create an indicator of female mm/household*/
gen femalehha12= (hhfemalea12/hhmembersa12) /*share of female household members*/
****************************************************************


save "LiK12_data_stata_rec/hh1a.dta", replace


use "LiK12_data_stata/household/hh2b.dta"
egen total_index12=sum(h213), by(hhid) /*aggregate possessions per household*/
collapse total_index12, by (hhid) /*This keeps one observation per household*/
save "LiK12_data_stata_rec/hh2b.dta", replace


use "LiK12_data_stata/household/hh5.dta"
egen total_income12=sum(h502), by(hhid) /*Aggregate income per household*/
collapse total_income12, by (hhid) /*Keep one observation per household*/
save "LiK12_data_stata_rec/hh5.dta", replace


use "LiK12_data_stata/household/hh6b.dta"
codebook h616, tab(50) 
recode h616 (1=1 "has_remittances") (2=0 "doesn't"), gen (hasremittances12)
codebook hasremittances12, tab (50)

codebook h617_s, tab(50)
sum h617_s
gen remittances_amount12= h617_s
codebook remittances_amount12 h617_s, compact

codebook h617_c, tab (50)
recode h617_c (1=1 "som") (2=2 "usa") (3=3 "rouble") (4=4 "euro"), gen (remittances_currency12)
codebook remittances_currency12 h617_c, compact

codebook h618, tab(50)  
recode h618 (1=1 "once") (2/3=2 "2-3") (4/5=3 "4-5") (6/10=4 "6-10") (11/12=5 "11=12") (13/20=6 "12+"), gen (remfreq_year12)
codebook remfreq_year12 h618, compact

codebook h619, tab(50)
recode h619 (1=1 "yes") (2=0 "no"), gen (rem_when12)

codebook h620, tab(50) 
recode h620 (1=1 "yes") (2=0 "no"), gen (rem_stableamount12)
codebook rem_stableamount12 h620, compact
save "LiK12_data_stata_rec/hh6.dta", replace


use "LiK12_data_stata/household/hh7.dta"
recode h701_6 (1=1) (2=0), gen (affected_landsl12)
recode h701_13 (1=1) (2=0), gen (agriloss12)
codebook affected_landsl12 agriloss12, compact 
save "LiK12_data_stata_rec/hh7.dta", replace


use "LiK12_data_stata/control/cc_hh.dta"
drop hhid10 hhid11
gen hhid=hhid12
********
drop hhid12
********
codebook oblast, tab (50)
gen oblast12=oblast
save "LiK12_data_stata_rec/hhcontrol.dta", replace


use "LiK12_data_stata_rec/id1.dta"
merge 1:1 idp12 using "LiK12_data_stata_rec/id2.dta"
drop _merge
merge 1:1 idp12 using "LiK12_data_stata_rec/id3.dta"
drop _merge
merge 1:1 idp12 using "LiK12_data_stata_rec/id4.dta"
drop _merge
merge 1:1 idp12 using "LiK12_data_stata_rec/id6.dta"
drop _merge
merge 1:1 idp12 using "LiK12_data_stata_rec/id8.dta"
drop _merge
merge 1:1 idp12 using "LiK12_data_stata_rec/hh1a.dta"
drop _merge
merge m:1 hhid using "LiK12_data_stata_rec/hh2b.dta"
drop _merge
merge m:1 hhid using "LiK12_data_stata_rec/hh5.dta"
drop _merge
merge m:1 hhid using "LiK12_data_stata_rec/hh6.dta"
drop _merge
merge m:1 hhid using "LiK12_data_stata_rec/hh7.dta"
drop _merge
merge m:1 hhid using "LiK12_data_stata_rec/hhcontrol.dta"
drop _merge
gen year=2012
quietly run "idpnew12.do" /*assigns obs panel identifier*/ 
***Adding hhid****
gen hhid12=hhid
codebook hhid12 hhid, compact
drop hhid
*****************
save "LiK12_data_stata_rec/wave2012.dta", replace

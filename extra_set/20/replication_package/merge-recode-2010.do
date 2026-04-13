**********************************************************************
*****LIFE IN KYRGYZSTAN SURVEYS: YEAR-BY-YEAR RECODING AND MERGING****
**********************************************************************

**********************************************
*The code below creates the 2010 year dataset*
**********************************************
clear
use "LiK10_data_stata/individual/id1.dta"
gen idp10=(hhid+pid/100)*100 

recode i101_3 (90=.), gen (hheconsat10) 
recode i101_5 (90=.), gen (livingsat10) 
codebook hheconsat10 livingsat10, tab (50) 

gen riskaccept10=i103 
codebook riskaccept10, tab (50) 
save "LiK10_data_stata_rec/id1.dta", replace

use "LiK10_data_stata/individual/id2.dta"
gen idp10=(hhid+pid/100)*100
gen educ10=i207 
codebook educ10, tab (50) 
save "LiK10_data_stata_rec/id2.dta", replace

use "LiK10_data_stata/individual/id3.dta"
gen idp10=(hhid+pid/100)*100
recode i301 (1=1) (2=0), gen (work1) 
gen employed10=work1
codebook employed10, tab (50)

recode i308 (1=1 "agrfish") (2/3=2 "manufacture") (4/5=3 "construction") (6=4 "trade") (8=5 "transport") (12=6 "education") (13=7 "social work") (7=8 "other") (9=8 "other") (10/11=8 "other")(14/15=8 "other") , gen(em_sec10)
recode em_sec10 (.=0 "not_stated"), gen (em_sector10)
save "LiK10_data_stata_rec/id3.dta", replace


use "LiK10_data_stata/individual/id4.dta"
gen idp10=(hhid+pid/100)*100
recode i413 (1=1) (2=0), gen (intentmigrate10)
codebook intentmigrate10, tab (50) 
save "LiK10_data_stata_rec/id4.dta", replace

use "LiK10_data_stata/individual/id6.dta"
gen idp10=(hhid+pid/100)*100
recode i601_1 (90=.), gen (econ_concern10)
codebook econ_concern10, tab (50)
save "LiK10_data_stata_rec/id6.dta", replace
 
use "LiK10_data_stata/individual/id8.dta"
gen idp10=(hhid+pid/100)*100
gen comleader_trust10=i821_5
gen altpres_trust10= i821_4

recode i822_1 (1=1) (2=0), gen (faminfo10) 
recode i822_2 (1=1) (2=0), gen (nninfo10) 
recode i822_4 (1=1) (2=0), gen (radioinfo10) 
recode i822_5 (1=1) (2=0), gen (TVinfo10)
recode i822_6 (1=1) (2=0), gen (paperinfo10) 
recode i822_7 (1=1) (2=0), gen (internetinfo10)  
save "LiK10_data_stata_rec/id8.dta", replace

use "LiK10_data_stata/household/hh1a.dta"
gen idp10=(hhid+pid/100)*100

recode h102 (1=1 "male") (2=0 "female"), gen (gender10)
codebook gender10, tab (50) 

tab h103_y
gen yob10=(2010-h103_y)
codebook yob10, tab (50)

recode h105 (1=1 "kyrgyz") (2/8=0 "other"), gen (ethnicity10)
codebook ethnicity10, tab (50)

recode h108 (1=1 "married") (2/6=0 "notmarried"), gen (marital10)
codebook marital10, tab (50)

*******CREATES FEMALES/ TOTAL HOUSEHOLD*************************
gen ta10=1 /*to create count of all members*/
gen fa10=1 if h102==2 /*create a count of all female members*/
egen hhmembersa10=sum(ta10), by (hhid) 
egen hhfemalea10=sum(fa10), by (hhid) /*create an indicator of female mm/household*/
gen femalehha10= (hhfemalea10/hhmembersa10) /*share of female household members*/
****************************************************************

save "LiK10_data_stata_rec/hh1a.dta", replace

use "LiK10_data_stata/household/hh2b.dta"
egen total_index10=sum(h213), by(hhid) /*aggregate possessions per household*/
collapse total_index10, by (hhid) /*Keep one observation per household*/
save "LiK10_data_stata_rec/hh2b.dta", replace

use "LiK10_data_stata/household/hh5.dta"
egen total_income10=sum(h502), by(hhid) /*Aggregate income per household*/
collapse total_income10, by (hhid) /*Keep one observation per household*/
save "LiK10_data_stata_rec/hh5.dta", replace

use "LiK10_data_stata/household/hh6.dta"
recode h616 (1=1 "has_remittances") (2=0 "doesn't"), gen (hasremittances10)
codebook hasremittances10, tab (50)

gen remittances_amount10= h617s
codebook remittances_amount10, tab (50) 

recode h617c (1=1 "som") (2=2 "usa") (3=3 "rouble") (4=4 "euro"), gen (remittances_currency10)
tab remittances_currency10

recode h618 (1=1 "once") (2=2 "2-3") (3=3 "4-5") ///
(4=4 "6-10") (5=5 "11=12") (6=6 "12+"), gen (remfreq_year10)
codebook remfreq_year10, tab (50) 

recode h619 (1=1 "yes") (2=0 "no") (3=2 "depends"), gen (rem_when10)
codebook rem_when10, tab (50) 

recode h620 (1=1 "yes") (2=0 "no") (3=2 "depends"), gen (rem_stableamount10)
codebook rem_stableamount10, tab (50) 
save "LiK10_data_stata_rec/hh6.dta", replace

use "LiK10_data_stata/household/hh7.dta"
recode h701_6 (1=1) (2=0), gen (affected_landsl10)
recode h701_13 (1=1) (2=0), gen (agriloss10)
codebook affected_landsl10 agriloss10, compact 
save "LiK10_data_stata_rec/hh7.dta", replace

use "LiK10_data_stata/control/hhcontrol.dta"
codebook oblast, tab (50) 
gen oblast10=oblast
save "LiK10_data_stata_rec/hhcontrol.dta", replace

use "LiK10_data_stata_rec/id1.dta"
merge 1:1 idp10 using "LiK10_data_stata_rec/id2.dta"
drop _merge
merge 1:1 idp10 using "LiK10_data_stata_rec/id3.dta"
drop _merge
merge 1:1 idp10 using "LiK10_data_stata_rec/id4.dta"
drop _merge
merge 1:1 idp10 using "LiK10_data_stata_rec/id6.dta"
drop _merge
merge 1:1 idp10 using "LiK10_data_stata_rec/id8.dta"
drop _merge
merge 1:1 idp10 using "LiK10_data_stata_rec/hh1a.dta"
drop _merge
merge m:1 hhid using "LiK10_data_stata_rec/hh2b.dta"
drop _merge
merge m:1 hhid using "LiK10_data_stata_rec/hh5.dta"
drop _merge
merge m:1 hhid using "LiK10_data_stata_rec/hh6.dta"
drop _merge
merge m:1 hhid using "LiK10_data_stata_rec/hh7.dta"
drop _merge
merge m:1 hhid using "LiK10_data_stata_rec/hhcontrol.dta"
drop _merge
gen year=2010
quietly run "idpnew10.do" /*assigns obs panel identifier from mroster*/
***Adding hhid****
gen hhid10=hhid
codebook hhid10 hhid, compact
drop hhid
*****************
save "LiK10_data_stata_rec/wave2010.dta", replace

**********************************************************************
*****LIFE IN KYRGYZSTAN SURVEYS: YEAR-BY-YEAR RECODING AND MERGING****
**********************************************************************

**********************************************
*The code below creates the 2013 year dataset*
**********************************************
clear
use "LiK13_data_stata/individual/id1.dta"
gen idp13=(hhid+pid/100)*100 

recode i101_3 (90=.), gen (hheconsat13)
recode i101_5 (90=.), gen (livingsat13)  
codebook hheconsat13 livingsat13, tab (50)

gen riskaccept13=i106
codebook riskaccept13 i106, compact
save "LiK13_data_stata_rec/id1.dta", replace

use "LiK13_data_stata/individual/id2a.dta"
gen idp13=(hhid+pid/100)*100
gen educ13=i211 
codebook educ13 i211, compact 
save "LiK13_data_stata_rec/id2.dta", replace

use "LiK13_data_stata/individual/id3a.dta"
gen idp13=(hhid+pid/100)*100
recode i301 (1=1) (2=0) (9=.), gen (work1)
codebook work1 i301, compact
gen employed13=work1
codebook employed13 i301, compact
save "LiK13_data_stata_rec/id3.dta", replace

use "LiK13_data_stata/individual/id3b.dta"
gen idp13=(hhid+pid/100)*100
recode i308 (1=1 "agrfish") (2/3=2 "manufacture") (4/5=3 "construction") (6=4 "trade") (8=5 "transport") (12=6 "education") (13=7 "social work") (7=8 "other") (9=8 "other") (10/11=8 "other") (14/16=8 "other")  (.=0 "not-stated"), gen (em_sector13) 
/*This file only has those employed. Those without a value in the em_sector13 category*/
/*should be set to 0, i.e. not stated*/ 
save "LiK13_data_stata_rec/id3b.dta", replace

use "LiK13_data_stata/individual/id4.dta"
gen idp13=(hhid+pid/100)*100
recode i421 (1=1) (2=0), gen (intentmigrate13)
codebook i421 intentmigrate13, compact
save "LiK13_data_stata_rec/id4.dta", replace

use "LiK13_data_stata/individual/id6.dta"
gen idp13=(hhid+pid/100)*100
recode i601_1 (90=.), gen (econ_concern13) 
codebook econ_concern13, tab (50) 
save "LiK13_data_stata_rec/id6.dta", replace
 
use "LiK13_data_stata/individual/id8c.dta"
gen idp13=(hhid+pid/100)*100
recode i821_10 (99=.), gen  (pres_trust13)
recode i821_9  (99=.), gen  (gov_trust13) 
save "LiK13_data_stata_rec/id8.dta", replace

use "LiK13_data_stata/individual/id8d.dta"
gen idp13=(hhid+pid/100)*100
recode i826_1 (1=1) (2=0), gen (faminfo13) 
recode i826_2 (1=1) (2=0), gen (nninfo13)  
recode i826_4 (1=1) (2=0), gen (radioinfo13)
recode i826_5 (1=1) (2=0), gen (TVinfo13)
recode i826_6 (1=1) (2=0), gen (paperinfo13) 
recode i826_7 (1=1) (2=0), gen (internetinfo13)  
save "LiK13_data_stata_rec/id8a.dta", replace

use "LiK13_data_stata/individual/id8f.dta"
gen idp13=(hhid+pid/100)*100
recode i847_1 (90=.) (99=.), gen (satisfied_socsecu13)
recode i847_2 (90=.) (99=.), gen (satisfied_educ13)
recode i847_3 (90=.) (99=.), gen (satisfied_health13)
recode i847_4 (90=.) (99=.), gen (satisfied_housing13)
recode i847_5 (90=.) (99=.), gen (satisfied_transport13)
recode i847_7 (90=.) (99=.), gen (satisfied_services13)
save "LiK13_data_stata_rec/id8e.dta", replace


use "LiK13_data_stata/household/hh1a.dta"
gen idp13=(hhid+pid/100)*100

recode h102 (1=1 "male") (2=0 "female"), gen (gender13)
codebook gender13, tab (50)

gen yob13=(2013-h103_y)
sum yob13

recode h105 (1=1 "kyrgyz") (2/8=0 "other"), gen (ethnicity13)
codebook ethnicity13, tab (50)

recode h108 (1=1 "married") (2/7=0 "notmarried"), gen (marital13)
codebook marital13, tab (50)

*******CREATES FEMALES/ TOTAL HOUSEHOLD*************************
gen ta13=1 /*to create count of all members*/
gen fa13=1 if h102==2 /*create a count of all female members*/
egen hhmembersa13=sum(ta13), by (hhid) 
egen hhfemalea13=sum(fa13), by (hhid) /*create an indicator of female mm/household*/
gen femalehha13= (hhfemalea13/hhmembersa13) /*share of female household members*/
****************************************************************
save "LiK13_data_stata_rec/hh1a.dta", replace

use "LiK13_data_stata/household/hh2b.dta"
egen total_index13=sum(h219), by(hhid) /*aggregate possessions per household*/
collapse total_index13, by (hhid) /*Keep one observation per household*/
save "LiK13_data_stata_rec/hh2b.dta", replace

use "LiK13_data_stata/household/hh5a.dta"
egen total_income13=sum(h502), by(hhid) /*Aggregate income per household*/
collapse total_income13, by (hhid) /*Keep one observation per household*/
save "LiK13_data_stata_rec/hh5.dta", replace

use "LiK13_data_stata/household/hh6b.dta"
recode h616 (1=1 "has_remittances") (2=0 "doesn't"), gen (hasremittances13)
codebook hasremittances13, tab (50)

gen remittances_amount13= h617_s
codebook remittances_amount13 h617_s, compact

recode h617_c (1=1 "som") (2=2 "usa") (3=3 "rouble") (4=4 "euro"), gen (remittances_currency13)
codebook remittances_currency13 h617_c, compact

recode h618 (1=1 "once") (2/3=2 "2-3") (4/5=3 "4-5") (6/10=4 "6-10") (11=5 "11=12") (12=6 "12+") (99=.), gen (remfreq_year13)

recode h619 (1=1 "yes") (2=0 "no"), gen (rem_when13)

recode h620 (1=1 "yes") (2=0 "no"), gen (rem_stableamount13)
save "LiK13_data_stata_rec/hh6.dta", replace

use "LiK13_data_stata/household/hh7.dta"
recode h701_6 (1=1) (2=0), gen (affected_landsl13)
recode h701_13 (1=1) (2=0), gen (agriloss13)
codebook affected_landsl13 agriloss13, compact 
save "LiK13_data_stata_rec/hh7.dta", replace

use "LiK13_data_stata/control/cc_hh.dta"
drop hhid12
gen hhid=hhid13
***************
drop hhid13
***************
sort hhid
quietly by hhid: gen dup = cond(_N==1,0,_n)
codebook oblast, tab (50)
gen oblast13=oblast
save "LiK13_data_stata_rec/hhcontrol.dta", replace


use "LiK13_data_stata_rec/id1.dta"
merge 1:1 idp13 using "LiK13_data_stata_rec/id2.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/id3.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/id3b.dta"
drop _merge
recode em_sector13 (.=0) //To make consistent with previous waves, those who did not respond=0
merge 1:1 idp13 using "LiK13_data_stata_rec/id4.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/id6.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/id8.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/id8a.dta"
drop _merge
merge 1:1 idp13 using  "LiK13_data_stata_rec/id8e.dta"
drop _merge
merge 1:1 idp13 using "LiK13_data_stata_rec/hh1a.dta"
drop _merge
merge m:1 hhid using "LiK13_data_stata_rec/hh2b.dta"
drop _merge
merge m:1 hhid using "LiK13_data_stata_rec/hh5.dta"
drop _merge
merge m:1 hhid using "LiK13_data_stata_rec/hh6.dta"
drop _merge
merge m:1 hhid using "LiK13_data_stata_rec/hh7.dta"
drop _merge
merge m:1 hhid using "LiK13_data_stata_rec/hhcontrol.dta"
drop _merge
gen year=2013
quietly run "idpnew13.do" /*assigns obs panel identifier*/ 
********
gen hhid13=hhid
codebook hhid13 hhid, compact
drop hhid
********
save "LiK13_data_stata_rec/wave2013.dta", replace


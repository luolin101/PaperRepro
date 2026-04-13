**********************************************************************
*****LIFE IN KYRGYZSTAN SURVEYS: YEAR-BY-YEAR RECODING AND MERGING****
**********************************************************************

**********************************************
*The code below creates the 2011 year dataset*
**********************************************
clear
use "LiK11_data_stata/individual/id1.dta"
gen idp11=(hhid+pid/100)*100 

recode i101_3 (90=.), gen (hheconsat11) 
recode i101_5 (90=.), gen (livingsat11) 
codebook hheconsat11 livingsat11, tab (50) 

gen riskaccept11=i103 
codebook riskaccept11, tab (50) 
save "LiK11_data_stata_rec/id1.dta", replace


use "LiK11_data_stata/individual/id2.dta"
gen idp11=(hhid+pid/100)*100
gen educ11=i207 
save "LiK11_data_stata_rec/id2.dta", replace


use "LiK11_data_stata/individual/id3.dta"
gen idp11=(hhid+pid/100)*100
recode i301 (1=1) (2=0) (99=.), gen (work1)
gen employed11=work1
codebook employed11, tab (50)

recode i308 (1=1 "agrfish") (2/3=2 "manufacture") (4/5=3 "construction") (6=4 "trade") (8=5 "transport") (12=6 "education") (13=7 "social work")  (7=8 "other") (9=8 "other") (10/11=8 "other") (14/16=8 "other"), gen (em_sec11) 
recode em_sec11 (.=0), gen (em_sector11)
save "LiK11_data_stata_rec/id3.dta", replace


use "LiK11_data_stata/individual/id4.dta"
gen idp11=(hhid+pid/100)*100
recode i413 (1=1) (2=0), gen (intentmigrate11)
tab intentmigrate11
save "LiK11_data_stata_rec/id4.dta", replace


use "LiK11_data_stata/individual/id6.dta"
gen idp11=(hhid+pid/100)*100
recode i601_1 (90=.), gen (econ_concern11)
codebook econ_concern11, tab (50) 
save "LiK11_data_stata_rec/id6.dta", replace
 
 
use "LiK11_data_stata/individual/id8.dta"
gen idp11=(hhid+pid/100)*100
gen altpres_trust11= i821_4
gen comleader_trust11=i821_5

recode i822_1 (1=1) (2=0), gen (faminfo11) 
recode i822_2 (1=1) (2=0), gen (nninfo11) 
recode i822_4 (1=1) (2=0), gen (radioinfo11) 
recode i822_5 (1=1) (2=0), gen (TVinfo11)
recode i822_6 (1=1) (2=0), gen (paperinfo11) 
recode i822_7 (1=1) (2=0), gen (internetinfo11)  
save "LiK11_data_stata_rec/id8.dta", replace


use "LiK11_data_stata/household/hh1a.dta"
gen idp11=(hhid+pid/100)*100

recode h102 (1=1 "male") (2=0 "female"), gen (gender11)

tab h103_y
gen yob11=(2011-h103_y)

recode h105 (1=1 "kyrgyz") (2/8=0 "other"), gen (ethnicity11)
codebook ethnicity11, tab (50)

recode h108 (1=1 "married") (2/7=0 "notmarried"), gen (marital11)
codebook marital11, tab (50)

*******CREATES FEMALES/ TOTAL HOUSEHOLD*************************
gen ta11=1 /*to create count of all members*/
gen fa11=1 if h102==2 /*create a count of all female members*/
egen hhmembersa11=sum(ta11), by (hhid) 
egen hhfemalea11=sum(fa11), by (hhid) /*create an indicator of female mm/household*/
gen femalehha11= (hhfemalea11/hhmembersa11) /*share of female household members*/
****************************************************************

save "LiK11_data_stata_rec/hh1a.dta", replace


use "LiK11_data_stata/household/hh2b.dta"
egen total_index11=sum(h213), by(hhid) /*aggregate possessions per household*/
collapse total_index11, by (hhid) /*Keep one observation per household*/
save "LiK11_data_stata_rec/hh2b.dta", replace


use "LiK11_data_stata/household/hh5.dta"
egen total_income11=sum(h502), by(hhid) /*Aggregate income per household*/
collapse total_income11, by (hhid) /*Keep one observation per household*/
save "LiK11_data_stata_rec/hh5.dta", replace


use "LiK11_data_stata/household/hh6b.dta"
recode h616 (1=1 "has_remittances") (2=0 "doesn't"), gen (hasremittances11)
codebook hasremittances11, tab (50)

gen remittances_amount11= h617_s
codebook remittances_amount11 h617_s, compact

recode h617_c (1=1 "som") (2=2 "usa") (3=3 "rouble") (4=4 "euro"), gen (remittances_currency11)
tab remittances_currency11

recode h618 (1=1 "once") (2/3=2 "2-3") (4/5=3 "4-5") ///
(6/10=4 "6-10") (11=5 "11") (12=6 "12+"), gen (remfreq_year11)
codebook remfreq_year11 h618, compact

codebook h619, tab(50)
recode h619 (1=1 "yes") (2=0 "no"), gen (rem_when11)
codebook h619 rem_when11, compact

codebook h620, tab(50) 
recode h620 (1=1 "yes") (2=0 "no"), gen (rem_stableamount11)
codebook h620 rem_stableamount11, compact
save "LiK11_data_stata_rec/hh6.dta", replace


use "LiK11_data_stata/household/hh7.dta"
recode h701_6 (1/2=1) (3=0), gen (affected_landsl11)
recode h701_13 (1/2=1) (3=0), gen (agriloss11)
codebook affected_landsl11 agriloss11, compact 
save "LiK11_data_stata_rec/hh7.dta", replace

use "LiK11_data_stata/control/cc_hh.dta", clear
drop ih2010
codebook oblast, tab (50) 
recode oblast (41702=2 "issyk-kul") (41703=3 "jalal-abad") (41704=4 "naryn") ///
(41705=5 "batken") (41706=6 "osh") (41707=7 "talas") (41708=8 "chui") (41711=11 "bishkek") ///
(41721=21 "osh"), gen (oblast11) 
sort hhid
quietly by hhid: gen dup = cond(_N==1,0,_n)
tab dup
drop if dup>1
save "LiK11_data_stata_rec/hhcontrol.dta", replace

use "LiK11_data_stata_rec/id1.dta"
merge 1:1 idp11 using "LiK11_data_stata_rec/id2.dta"
drop _merge
merge 1:1 idp11 using "LiK11_data_stata_rec/id3.dta"
drop _merge
merge 1:1 idp11 using "LiK11_data_stata_rec/id4.dta"
drop _merge
merge 1:1 idp11 using "LiK11_data_stata_rec/id6.dta"
drop _merge
merge 1:1 idp11 using "LiK11_data_stata_rec/id8.dta"
drop _merge
merge 1:1 idp11 using "LiK11_data_stata_rec/hh1a.dta"
drop _merge
merge m:1 hhid using "LiK11_data_stata_rec/hh2b.dta"
drop _merge
merge m:1 hhid using "LiK11_data_stata_rec/hh5.dta"
drop _merge
merge m:1 hhid using "LiK11_data_stata_rec/hh6.dta"
drop _merge
merge m:1 hhid using "LiK11_data_stata_rec/hh7.dta"
drop _merge
merge m:1 hhid using "LiK11_data_stata_rec/hhcontrol.dta"
drop _merge
gen year=2011
quietly run "idpnew11.do" /*assigns obs panel identifier*/ 
***Adding hhid****
gen hhid11=hhid
codebook hhid11 hhid, compact
drop hhid
*****************
save "LiK11_data_stata_rec/wave2011.dta", replace

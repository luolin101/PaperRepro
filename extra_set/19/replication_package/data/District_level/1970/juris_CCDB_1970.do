/* This do file reads in data from the County and City Databook, 1972 (CCDB) and defines variables. The resulting data will 
then be merged with data entered by hand (juris_1970_master) to create the final jurisdiction level 1970s data*/

clear
set mem 20m

/* Start with the list of jurisdiction names by state. Merge with CCDB 1972, and keep only those jurisdictions in the 
sample*/
use juris_names_CCDB70.dta 
/* Create statefip codes for expansion sample*/
replace statefip=6 if state=="CA"
replace statefip=8 if state=="CO"
replace statefip=19 if state=="IA"
replace statefip=17 if state=="IL"
replace statefip=20 if state=="KS"
replace statefip=25 if state=="MA"
replace statefip=26 if state=="MI"
replace statefip=27 if state=="MN"
replace statefip=29 if state=="MO"
replace statefip=44 if state=="RI"
sort name statefip
merge name statefip using /home/nber/lplatt/Suburban/Data/CCDB_data/uscity72.dta
drop if _merge==2
drop _merge

#delimit ;
/* Keep a subset of the variables*/
keep jurcode statefip name place var303 var308 var312 var316 var318 var322-var326 var330 var331 var350 var354-var361 
var363 var364 var367-var369 var372 var374 var375 var411-var415 var418-var428 oldsample;
#delimit cr
/* Keep only total for NYC, not boroughs*/
*drop if name=="NEW YORK CITY" & var411==.

/* Rename variables*/
rename var303 poptot
rename var308 popbl
rename var312 per65
rename var316 perfb
rename var318 perspan
rename var323 meded
rename var324 pered5
rename var325 peredhs
rename var326 peredcol
rename var330 perbl_insch
rename var331 per_priv
rename var350 famtot
rename var354 fam3000
rename var355 fam4999
rename var356 fam6999
rename var357 fam9999
rename var358 fam14999
rename var359 fam24999
rename var360 fam25000 
rename var361 fammedinc
rename var363 famw_medinc
rename var364 famb_medinc
rename var368 perpov
rename var369 perpov_bl
gen perpov125=(var372/famtot)*100
rename var374 perinpov18
rename var375 perinpov65
rename var411 revtot
rename var413 revig
rename var414 revtax
rename var415 revpt
rename var418 expgen 
rename var419 expgen_cepc
rename var420 sheduc
rename var421 shhigh
rename var422 shwelf
rename var423 shpolfire
rename var424 shsewsan
rename var425 gendebt
rename var426 cityemp
rename var427 citywage
rename var428 numpol

/* Percentages --> shares*/
foreach var of varlist per* {
   replace `var'=(`var'/100)
}

sort jurcode
drop var*
save juris_CCDB_1970_aej.dta, replace


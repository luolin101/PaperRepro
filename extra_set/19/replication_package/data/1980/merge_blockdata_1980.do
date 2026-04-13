/* This do file merges data from four sources in 1980:
(1) Block level tier codes entered by hand from Excel template 
(2) 1980 electronic data for these blocks
(3) Jurisdiction data entered from CCDB and supplemented by hand
(4) Desegregation data*/

/* Read in the tier codes from the original template*/
clear
set mem 300m
use tiercodes1980.dta
sort statefip cnty tract block1
/* Merge with electronic Census data cleaned to include only the block-level variables of interest*/
merge statefip cnty tract block1 using census1980_01.dta
/* Drop observations that are ONLY in the electronic block data. There are 11542 blocks in both datasets and an additional 
19403 in only the Census data. These blocks are in the section of the tract that is not adjacent to its neighbor (e.g., 
more than 8 block tiers deep into the tract).*/
tab _merge
keep if _merge==3
drop _merge
save blockdata_1980.dta, replace

/* Merge in jurisdiction data - from CCDB, from desegregation cases, from crime and school district files*/
sort jurcode
merge jurcode using juris_data_1980.dta
tab _merge
rename _merge merge01
sort jurcode
merge jurcode using deseg_master_1980.dta
tab _merge
rename _merge merge02
/* Drop any border in which one or both of the jurisdictions have fewer than 10,000 residents*/
gen test=(totpop<10000)
sort borderno
quietly by borderno: egen maxtest=max(test)
drop if maxtest==1
drop test maxtest
tab merge01
tab merge02
drop merge*

/* For desegregation data*/
gen anycase=(num_cases>=1 & num_cases!=.)
gen anycase01=(anycase==1 | hew=="Y") 
gen anysteps=(number_steps>=1 & number_steps!=.)
label var anycase "=1 if town ever had desegregation court case"
label var anysteps "=1 if town ever had court-ordered remedies"
foreach var of varlist bussing-closing number_steps {
	replace `var'=0 if `var'==.
}

/*
/** Riots data from Bob Margo and Bill Collins -- available upon request from original authors**/
/* Merge in riots data*/
rename smsa metaread
sort metaread
merge metaread using ~/Tract_block/Riots_data/riots_touse.dta
/* Only in riots data*/
drop if _merge==2
/* Moline, IL not in original riots data, so code as not having contributed to riot activity*/
replace index1=0 if _merge==1
drop _merge
*/

save blockdata_1980.dta, replace

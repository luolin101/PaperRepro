log using census1980.log, replace
clear
set mem 600m
set more off
/* This do file reads in block level data for 1980 state-by-state. In each case, I merge the large block file (with around 
50k-200k obs) with the tract request, which indicates the tracts in the border-area sample, and drop the remaining tract/block 
information.*/

/*California*/
/* Read in block level data from Census 1980 STF 1B using dictionary provided by ISSR. Note that file is organized such that 
each observation is on two lines, so the dictionary uses the command '_newline'*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6244178/ICPSR_07975/DS0006/07975-0006-Data.txt)
/* Tract codes are not stored in 6 digit format. Need to create two places in the tens and ones and add suffix, if exists*/
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
/* Keep only if in original border-area sample*/
keep if _merge==3
drop _merge
save census1980.dta, replace

clear
/* Repeat the final steps (block data) for remaining 11 states - note: tried to use the 'foreach file' command but seems to 
mess up the data reading process*/
/* Colorado*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6244178/ICPSR_07975/DS0008/07975-0008-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Illinois*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6244178/ICPSR_07975/DS0017/07975-0017-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Massachusetts*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254306/ICPSR_07975/DS0025/07975-0025-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Michigan*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254306/ICPSR_07975/DS0026/07975-0026-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* New Jersey*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254326/ICPSR_07975/DS0036/07975-0036-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* New York*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254326/ICPSR_07975/DS0034/07975-0034-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Ohio*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254328/ICPSR_07975/DS0039/07975-0039-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Rhode Island*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6254328/ICPSR_07975/DS0044/07975-0044-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear


/* Kansas*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6255303/ICPSR_07975/DS0020/07975-0020-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Minnesota*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6255303/ICPSR_07975/DS0027/07975-0027-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear


/* Missouri*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6255305/ICPSR_07975/DS0029/07975-0029-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Pennsylvania*/
infile using CEN80.SF1.dct, using(/home/nber/lplatt/bulk/block_data/6255305/ICPSR_07975/DS0042/07975-0042-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Arizona*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0004/07975-0004-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Connecticut*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0009/07975-0009-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Indiana*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0018/07975-0018-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Iowa*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0019/07975-0019-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Nevada*/ 
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0032/07975-0032-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Oregon*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0041/07975-0041-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

/* Wisconsin*/
infile using CEN80.SF1.dct, using(~/bulk/block_data/7090202/ICPSR_07975/DS0055/07975-0055-Data.txt)
replace tract01=tract01*100
gen tract=tract01+tractsuff if tractsuff!=.
replace tract=tract01 if tractsuff==.
sort state county tract
merge state county tract using request1980_all.dta
tab _merge
keep if _merge==3
drop _merge
append using census1980.dta
save census1980.dta, replace
clear

log close

/**
** OUTFILE TO CREATE BLOCK-LEVEL TEMPLATE FOR CODING BLOCK TIERS (DISTANCE FROM BORDER)
use census1980.dta
/* Drop all tract-level observations*/
drop if SUMRYLVL=="24"
/* Drop if double observations of same block*/
rename BLOCK block
sort state county tract block
drop if block==block[_n-1]
outfile state county tract block using 1980_template.txt, replace wide noquote
***/

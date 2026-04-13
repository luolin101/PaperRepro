clear
capture log close
log using ELSEGIS_1980.log, replace
set mem 30m
infix using ELSEGIS_1980.dct
sort oenum
/* Merge with data from the Office of Civil Rights by OE number to identify the sample of jurisdictions of interest*/
merge oenum using oenum_merge.dta
/* Once case in which the merge did not work, but the district had changed OE number*/
tab _merge
replace jurcode="comptoca" if oenum==1409600
replace _merge=3 if oenum==1409600
drop if _merge!=3

/* Now, ready to try destringing all of the variables*/
foreach var of varlist revschtax-amratio {
	destring `var', replace
}

label var ceadm "current expenditure, administration"
label var cesalp "current expenditure, professional salaries"
label var cesalnp "current expenditure, non-prof salaries"
label var ceinst "current expenditure, instruction"
label var revschfed1 "Elementary/Secondary School Act"
label var revschfed2 "Fed: School lunch"
label var revschfed3 "Fed: Other distributed by state"
label var revschfed4 "Fed direct 1"
label var revschfed4 "Fed direct 2"
label var revschfed4 "Fed direct 3"


/* Per pupil values (in average daily attendence
Also adjust for inflation. This is the 1979-80 school year, use the same adjustment as for 1980 Census values --> Year 2000 
dollars.*/
foreach var of varlist revschtax revschsta ceadm ceinst revschfed* {
	gen `var'_pup=`var'/ada
	replace `var'_pup=`var'_pup/.43
}
label var revschtax_pup "school revenue from local taxes per pupil (ada)"
label var revschsta_pup "school revenue from state per pupil (ada)"
label var ceadm_pup "current exp on school administration per pupil (ada)"
label var ceinst_pup "current exp on instruction per pupil (ada)"
keep oenum jurcode revschtax_pup-ceinst_pup distname revschfed*

save ELSEGIS_1980.dta, replace

log close

/* This do file reads in data from the Elementary and Secondary General Information System (ELSEGIS) for the 1969-70 school 
year. It then merge the data by OE number (office of education number) with a file from the Office of Civil Rights data that 
identifies districts in the sample. Note that OCR data has 8000 cases, and this file has 5000 cases. While the documentation 
claims to have data for "all public elementary and secondary districts" it appears that the smallest districts (e.g., those in 
Pittsburgh area) are missing. This match is no *worse* than what we can do with the Census of Governments. Note that in 1957, 
C of G collected data on all districts with 300 or more enrolled. In 1967, however, only collected on districts with 3000 
enrolled or more. I can match around 90% of the districts in the sample.

Then, I have to deal with the annoying fact that all variables must be read in as strings, because a few cases have alphabetic 
characters in last digit place. There is no documentation for why this might be. At first, I thought this might be an 
indication that the variables were "estimated" because the survey has a special column for "estimated/not." However, it 
appears that these estimated values were indicated with a 1 or a 0 in the space following the data field. The alphabetic 
characters vary (B, D, E, etc.). From instances where I can estimate what the appropriate value should be (e.g., "totals" 
columns where the parts are known), I can see that these alphabetic characters appear to be mis-punched. Much of the do-file 
deals with correcting these mis-punches.*/

clear
set mem 30m
infix using ELSEGIS_1970.dct
sort oenum
/* Merge with data from the Office of Civil Rights by OE number to identify the sample of jurisdictions of interest*/
merge oenum using oenum_merge.dta
/* Once case in which the merge did not work, but the district had changed OE number*/
replace jurcode="comptoca" if oenum==1409600
replace _merge=3 if oenum==1409600
keep if _merge==3

/* To handle the variables with alphabetic digits...*/
/* In the case of ceoaadm, salp, salnp - the alphabetic digits are for jurisdictions with true zeros*/
#delimit ;
foreach var of varlist ceoaadm ceoasalp ceoasalnp {;
	replace `var'="0" if jurcode!="garyin" & jurcode!="hammonin" & jurcode!="cambrima" & jurcode!="somervma" & 
	jurcode!="bostonma";
};
#delimit cr
/* For ceoainst/tot, the alphabetic digits are for Gary and Hammond IN*/
replace ceoainst="1862994" if jurcode=="garyin"
replace ceoainst="932355" if jurcode=="hammonin"
replace ceoatot="1876446" if jurcode=="garyin"
replace ceoatot="945138" if jurcode=="hammonin"
replace ceoainst="0" if jurcode=="kancitks" | jurcode=="minneamn" | jurcode=="stpaulmn"
replace ceoatot="0" if jurcode=="kancitks" | jurcode=="minneamn" | jurcode=="stpaulmn"
/* For revschfed, there are four jurisdicitons with miscelaneous alphabetic digits in the last digits place. Just change to 
"0"*/
replace revschfed="0000247310" if oenum==1432100
replace revschfed="0000816350" if jurcode=="mtvernny"
replace revschfed="0004005620" if jurcode=="garyin"
replace revschfed="0001440150" if jurcode=="yonkerny"
replace revschfed="211820" if revschfed=="000021182C"
replace revschfed="1316890" if revschfed=="000131689C"
/* For celocinst/celoctot*/
replace celocinst="0007090580" if jurcode=="brooklma"
replace celoctot="0009085920" if jurcode=="brooklma"
replace celocinst="0008921110" if jurcode=="mtvernny"
replace celoctot="0014383550" if jurcode=="mtvernny"
replace celoctot="0078573970" if jurcode=="bostonma"
replace celoctot="0032110520" if jurcode=="yonkerny"
replace celoctot="0068633040" if jurcode=="pittsbpa"
replace celoctot="0037833970" if jurcode=="richmoca"
replace celocinst="0008613500" if oenum==2314460
replace celocinst="0005454150" if oenum==1432100
replace celoctot="0007253020" if oenum==1432100
replace celoctot="0027225690" if oenum==1402640
replace celoctot="0008846810" if oenum==2326880
replace celoctot="0037833970" if jurcode=="elcerrca"
replace ceoatot="0000767490" if ceoatot=="000076749F"
replace ceoatot="0003697010" if ceoatot=="000369701G"
replace ceoatot="0000241700" if ceoatot=="000024170D"
replace ceoatot="0001237600" if ceoatot=="000123760H"
replace ceoatot="0000000000" if ceoatot=="000000000{"
replace ceoatot="0000000000" if ceoatot=="000000000{"
replace ceoainst="0000000000" if ceoainst=="000000000{"
replace ceoainst="0000000000" if ceoainst=="000000000{"
replace ceoainst="0003650830" if ceoainst=="000365083A"
replace ceoainst="0000234630" if ceoainst=="000023463A"
replace ceoainst="0001221020" if ceoainst=="000122102G"
replace celocinst="0004342520" if celocinst=="000434252B"
replace ceoainst="0000020000" if ceoainst=="000002000{"
replace celoctot="0005667210" if celoctot=="000566721I"
replace celoctot="0004968180" if celoctot=="000496818E"
replace celoctot="0002103030" if celoctot=="000210303B"
replace celoctot="0005431090" if celoctot=="000543109C"
replace ceoatot="0000385850" if ceoatot=="000038585H"
replace ceoatot="0000036430" if ceoatot=="000003643B"
replace ceoatot="0000020000" if ceoatot=="000002000{"
replace ceoatot="0000285020" if ceoatot=="000028502B"
replace ceoainst="0000281760" if ceoainst=="000028176G"
replace revschfed="0000256130" if revschfed=="000025613{"

/* Now, ready to try destringing all of the variables*/
foreach var of varlist revschtax-amratio {
	destring `var', replace
}
/* Create totals for current expenditures on administration, salary, etc. by adding local + other agency*/
foreach name in adm salp salnp inst tot {
	gen ce`name'=celoc`name'+ceoa`name'
}
label var ceadm "current expenditure, administration"
label var cesalp "current expenditure, professional salaries"
label var cesalnp "current expenditure, non-prof salaries"
label var ceinst "current expenditure, instruction"
label var cetot "current expenditure, total"
/* Per pupil values (in average daily attendence
Also adjust for inflation. This is the 1969-70 school year, use the same adjustment as for 1970 Census values --> Year 2000 
dollars.*/
foreach var of varlist revschtax revschsta revschfed ceadm ceinst cetot {
	gen `var'_pup=`var'/ada
	replace `var'_pup=`var'_pup/.225
}
label var revschtax_pup "school revenue from local taxes per pupil (ada)"
label var revschsta_pup "school revenue from state per pupil (ada)"
label var revschfed_pup "school revenue from federal per pupil (ada)"
label var ceadm_pup "current exp on school administration per pupil (ada)"
label var ceinst_pup "current exp on instruction per pupil (ada)"
label var cetot_pup "current exp, total, per pupil (ada)"
keep oenum jurcode revschtax_pup-cetot_pup oldsample
/* Expand observations for the two school districts that have multiple jurisdictions and are in the ELSEGIS data*/
expand 2 if jurcode=="richmoca" | jurcode=="longbeca"
sort jurcode
replace jurcode="elcerrca" if jurcode=="richmoca" & jurcode==jurcode[_n-1]
replace jurcode="lakewoca" if jurcode=="longbeca" & jurcode==jurcode[_n-1]
sort jurcode

/** Note that some jurisdictions (e.g., Phoenix) have multiple school districts within them. For now, I will simply average 
the information for all school districts within the city. One could, in theory, attach each border area to the elementary and 
high school that these kids would have attended**/
/* Sum data by jurcode*/
foreach var of varlist revschtax_pup-cetot_pup {
	quietly by jurcode: egen sum`var'=mean(`var')
	replace `var'=sum`var'
}
drop sum*
sort jurcode
/* Keep only one observation per jurisdiction*/
drop if jurcode==jurcode[_n-1]
save ELSEGIS_1970.dta, replace


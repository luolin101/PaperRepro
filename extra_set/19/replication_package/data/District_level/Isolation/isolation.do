/* This do file reads in OCR school-level data with racial composition information in 1970 and 1980 and uses it to calculate 
isolation indices for the average white student by district. The original OCR data comes from Sarah Reber. The OCR files were 
read in to Stata by Matt Baird in July 2008. After calculating the isolation index, I attach 'jurcode' identifiers to the 
school-distrist observations using an oenum/jurcode cross walk*/

clear
set mem 300m
use OCR_school1970.dta
/* Number of white students in school*/
gen numenr_white=numenr_tot-numenr_black
/* Number of white students in district */
sort oenum
by oenum: egen numenr_white_all=sum(numenr_white)
/* Share of white students in district in particular school */
gen white_shtot=numenr_white/numenr_white_all
/* Weight black enrollment share by share of whites in that school */
gen temp=white_shtot*perenr_black
/* Isolation index = weighted sum*/
by oenum: egen isol=sum(temp)
keep oenum isol
gen year=1970
save isolation.dta, replace

/* Conduct same procedure for 1980*/
clear
use OCR_school1980.dta
keep if perenr_black<=1
sort oenum
gen numenr_white=numenr_tot-numenr_black
by oenum: egen numenr_white_all=sum(numenr_white)
gen white_shtot=numenr_white/numenr_white_all
gen temp=white_shtot*perenr_black
by oenum: egen isol=sum(temp)
keep oenum isol
gen year=1980
append using isolation.dta
sort year oenum
drop if oenum==oenum[_n-1]
sort oenum
save isolation.dta, replace

/* Match isolation data to sample districts*/
/* Cross walk was made by looking for all districts whose "city_ocr" variable matches one of the cities or suburbs in the 
sample. In a few cases, there are multiple districts that list a given city (e.g., Detroit), even though upon further 
inspection (looking at "district_name") it is clear that some of these districts are obviously *not* the Detroit city 
district. In one case - Phoenix - there are actually many elementary and HS districts... Here, I get rid of the "extraneous" 
districts before running the cross walk*/

use ~/Tract_block/OCR_school/Matt/oenum_jurcode_xwalk.dta
#delimit ;
drop if oenum==3229460 | oenum==3232280 | oenum==1502910 | oenum==2408760 | oenum==3514340 | oenum==3508250 | oenum==3211640 | 
oenum==3211040 | oenum==3225710;
drop if jurcode=="norlasnv"
sort oenum
merge oenum using isolation.dta
keep if _merge==3
drop _merge
sort year jurcode
save isolation.dta, replace

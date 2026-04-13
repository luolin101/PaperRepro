/* This do file reads in data provided by Sarah Reber from the Office of Civil Rights (1970) Individual School Campus Report 
(CR 102).*/

clear all
set mem 100m
/* Start with large OCR file. Too big to read in to Stata. So, in UNIX, perform following commands:
Use the unix command:  cut -f 7,8,etc 70.full.txt > OCR70_test.txt to cut.
Use the unix command: wc -l OCR70_test.txt to check the number of lines read in.*/
insheet using OCR70_cut.txt, tab
rename v1 oenum
rename v2 district_ocr
rename v3 city_ocr
rename v4 oeschool_ocr
rename v5 school_name_ocr
rename v6 grade12
rename v7 numenr_AI
rename v8 numenr_black
rename v9 numenr_asian
rename v10 numenr_hisp
rename v11 numenr_other
rename v13 state_ocr
drop v12

/* Black share of enrollment - assume that numenr_other = number of students that are not black, hispanic, asian or AI. 
Confirmed this against the enrollment data available in the ELSEGIS.*/
gen numenr_tot=numenr_black+numenr_AI+numenr_asian+numenr_hisp+numenr_other
gen perenr_black=(numenr_black/numenr_tot)

/* Merge with school data from ELSEGIS, which has the street addresses present and identifies schools in my sample.*/
sort oenum oeschool_ocr
merge oenum oeschool_ocr using ELSEGIS_school.dta
/* There are 7 high schools in the sample of 420 that do not match with OCR (now that I've done the ELSEGIS--> OCR crosswalk; 
see ELSEGIS_school.do). Keep only schools in both datasets.*/
keep if _merge==3
keep oenum oeschool oeschool_ocr perenr_black jurcode count schoolname numenr_black numenr_tot
label var perenr_black "% students who are black"
label var oenum "district number, office of ed"
label var oeschool "school number, ELSEGIS"
label var oeschool_ocr "school number, OCR"
/* Sort with ELSEGIS codes to merge with minimum distance data*/
sort oenum oeschool
save OCR_school1970.dta, replace

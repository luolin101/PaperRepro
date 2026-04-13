/* This do file reads in data for the school universe from the ELSEGIS (elementary and secondary general information system). 
This file has street addresses (as of 1970) for the schools.
The protocol follows these steps:
1. Define high schools, junior highs, and elementary schools. I focus on high schools for the geocoding process. 
Can verify that the grade procedure works by checking school names. Note that there are two high schools that are not 
identified as such (Passaic, NJ; Evanston, IL) because does not have grade information, but does list school name as "Passaic 
HS."
2. Double the observations (using 'expand') in districts that serve two jurisdictions, and for which the jurisdictions have 
OTHER borders in the sample. E.g., Berwyn-Cicero share a high school district, so the B-C border is out; but Berwyn also has a 
border with Oak Park, so that border is in.
3. Merge with oenum_merge.dta to keep only those schools in my jurisdiction sample. There is some mis-match between district 
numbers in this ELSEGIS schools data and the district numbers used to create the oenum_merge file (OCR district data). I use 
the "city" and "state" fields to check for schools in towns without a match (e.g., Evanston HS; Dearborn, MI, etc) and add 
the right oenum to the oenum_merge file by hand.
4. Drop all high schools with the words 'vocational,' 'technical,' 'trade,' 'manual,' or 'mechanic' in name. These are 
unlikely to be schools that are assigned based on geographic proximity. Also, drop any that say 'continuation' or 'cont.'
5. To prepare for matching with OCR data: There are 65-70 schools with different 'oeschool' codes in ELSEGIS and OCR data. 
There is one case in which the oenum has changed (Dearborn, MI). Read in a cross-walk .txt file that converts ELSEGIS oeschool 
codes to oeschool_ocr. Use oeschool_ocr to merge the two files.

Data on school name and address is then outputted into an .ascii file to use for geocoding.
Next steps will be:
A. Match these street addresses using geocoding and the 2000 street maps. (occurs outside of Stata)
B. Match this file with the OCR data from Sarah Reber (school level, in this directory).*/

clear 
set mem 50m
infix using ELSEGIS_school.dct
/*CREATE OENUM FROM STATE AND DISTRICT CODES*/
/* OE 7 digit identifier = 2 digit state + 5 digit district*/
replace oestate=oestate*100000
gen oenum=oestate+oesystem
sort oenum
/*DEFINE HIGH SCHOOLS; JHS; AND ELEMENTARY*/
gen hs=(grade12=="X")
replace hs=1 if schoolname=="PASSAIC HS"
replace hs=1 if schoolname=="EVANSTON TWP HS"
gen jhs=(grade1!="X" & grade12!="X" & (grade4=="X" | grade5=="X" | grade6=="X" | grade7=="X" | grade8=="X" | grade9=="X"))
gen elem=(grade1=="X")
label var hs "=1 if school has a grade 12" 
label var jhs "=1 if school has any of grades 4-9, but does not have grade 1 or grade 12" 
label var elem "=1 if school has a grade 1" 
/*KEEP ONLY HS*/
keep if hs==1
sort oenum
save ELSEGIS_school.dta, replace

clear
/* Merge with district level data to get the jurisdiction data*/
use ~/Tract_block/OCR_district/oenum_merge
sort oenum
merge oenum using ELSEGIS_school
/* There are ~10 jurisdictions that DO have school address data in ELSEGIS but that are not picked up in the OCR district 
match. Relabel these now*/
expand 2 if oenum==5323250
sort oenum
replace jurcode="higpartx" if oenum==5323250 & oenum[_n-1]!=5323250
replace jurcode="unipartx" if oenum==5323250 & jurcode==""
replace jurcode="easdetmi" if oenum==3212450
replace jurcode="harwoomi" if oenum==3217760
replace jurcode="louisvky" if oenum==2702970
replace jurcode="louisvky" if oenum==2703600
replace jurcode="porhueca" if oenum==1429250 & oeschool==2909
replace _merge=3 if jurcode=="higpartx" | jurcode=="unipartx" | jurcode=="easdetmi" | jurcode=="louisvky" | jurcode=="harwoomi"
replace _merge=3 if jurcode=="porhueca"
tab _merge
/* Note the 39 "merge=1" which is a district in oenum_merge that does not match with ELSEGIS. These are elementary districts. 
Each of these towns has at least one district that matches with ELSEGIS as well*/
keep if _merge==3
drop _merge hs elem jhs grade*

/* Fix county codes on Berwyn and Cicero (listed as Tazewell, really in Cook)*/
replace counfip=31 if jurcode=="berwynil" | jurcode=="ciceroil"
/* Drop Richmond, El Cerrito, and Skokie, because they are part of two-jurisdiction districts without an additional border*/
drop if jurcode=="richmoca" | jurcode=="elcerrca" | jurcode=="skokieil"
/* Drop other NYC counties (besides bronx and queens)*/
gen temp=(statefip==36 & (counfip==5 | counfip==81 | counfip==119))
drop if statefip==36 & temp==0
drop temp
/* Drop voc/tech and continuation high schools*/
gen str voc="VOC"
gen str tech="TECH"
gen str trade="TRADE"
gen str manual="MANUAL"
gen str mech="MECH"
gen str cont="CONT"
gen str elem="ELEM"
gen str boys="BOYS"
gen str girls="GIRLS"
gen str juv="JUVENILE"
/* This string function identifies any schoolnames with these set of characters*/
gen temp=strpos(schoolname, voc)
gen temp01=strpos(schoolname, tech)
gen temp02=strpos(schoolname, trade)
gen temp03=strpos(schoolname, manual)
gen temp04=strpos(schoolname, mech)
gen temp05=strpos(schoolname, cont)
gen temp06=strpos(schoolname, elem)
gen temp07=strpos(schoolname, boys)
gen temp08=strpos(schoolname, girls)
gen temp10=strpos(schoolname, juv)
gen temp09=(temp>=1 | temp01>=1 | temp02>=1 | temp03>=1 | temp04>=1 | temp05>=1 | temp06>=1 | temp07>=1 | temp08>=1)
replace temp09=1 if temp10>=1
drop if temp09==1
drop temp* voc-girls
/* Indicate which jurisdictions have more than one high school. These are the only ones that need to be geocoded. The others 
we can assume that EVERYONE sent their children to the same HS, so there is no need to figure out which HS is closer*/
sort jurcode
quietly by jurcode: egen count=count(oenum)
label var count "# of high schools in the jurisdiction"

/* A few counties are in both the old and the new sample. For the new geocoding, need to have these counties as well*/
replace oldsample=0 if statefip==8 & (counfip==5 | counfip==31)
replace oldsample=0 if statefip==13 & counfip==121 
replace oldsample=0 if statefip==17 & counfip==31
replace oldsample=0 if statefip==27 & counfip==53
replace oldsample=0 if statefip==29 & counfip==95
replace oldsample=0 if statefip==39 & counfip==49
replace oldsample=0 if statefip==41 & counfip==51
replace oldsample=0 if statefip==44 & counfip==7
replace oldsample=0 if statefip==29 & counfip==95 
replace oldsample=0 if statefip==20 & counfip==209 

/***** Outfiling for GIS geocoding
/*This is for original sample*/
/* Outfile the data into a .txt so that I can split apart the string for addresses*/
#delimit ;
outfile statefip counfip zipcode city jurcode oenum oeschool schoolname address using ELSEGIS_output.txt if count>1, wide 
noquote replace;
#delimit cr
/* For new sample*/
/* Outfile the data into a .txt so that I can split apart the string for addresses*/
#delimit ;
outfile statefip counfip zipcode city jurcode oenum oeschool schoolname address using ELSEGIS_output_newsample_01.txt if 
count>1 & oldsample!=1, wide noquote replace;
#delimit cr
/* Outfiling mistakes*/
sort jurcode
merge jurcode using missing_jurcodes.dta
#delimit ;
outfile statefip counfip zipcode city jurcode oenum oeschool schoolname address using ELSEGIS_output_mistakes.txt if 
count>1 & _merge==3, wide noquote replace;
#delimit cr
drop _merge
*****/

/* Read in ELSEGIS--> OCR crosswalk .txt file and merge with ELSEGIS school. Now the file has OCR school codes to use with the 
merge.*/
replace oenum=3211580 if jurcode=="dearbomi"
sort oenum oeschool
save ELSEGIS_school.dta, replace
clear
insheet using elsegis_ocr_crosswalk.txt, tab
sort oenum oeschool
merge oenum oeschool using ELSEGIS_school.dta
/* The cross-walk file only creates the variable 'oeschool_ocr' for those schools whose codes differ between the two data 
sets. Replace oeschool_ocr = oeschool if the two do not differ*/
replace oeschool_ocr=oeschool if oeschool_ocr==.
drop _merge
/* To merge with OCR_school data*/
sort oenum oeschool_ocr
save ELSEGIS_school.dta, replace


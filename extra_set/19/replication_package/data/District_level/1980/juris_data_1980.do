/* This do file combines jurisdiction-level data from the electronic CCDB file with data collected by hand.

City and County data book in 1983 (electronic) supplemented with data collected by hand
Including:
a. Data that was not available electronically for *any* city (e.g., number of Asian residents)
b. All data for a few jurisdictions small enough not to be included in CCDB but large enough to still be in the sample -- 
between 10,000 and 25,000 residents in 1980. 

Create:
1. Population shares: black, hispanic, foreign born
2. Income variables: ln(median family income), education variables
*/

/* Read in data collected by hand. This data also includes the electronic information in 1980. Started with the CCDB data, 
created a template to use for entry by hand. Now juris_data_1980.txt includes both.*/
clear
set mem 20m
insheet using juris_data_1980.txt, tab
save juris_data_1980.dta, replace

/* Demographic variables: Race & Ethnicity */
gen shblack=blackpop/totpop
gen shhisp=spanpop/totpop
gen shasian=asianpop/totpop
gen shelder=num65up/totpop
label var shblack "% black, jurisdiction"
label var shhisp "% spanish language, jurisdiction"
label var shasian "% asian, jurisdiction"
label var shelder "% 65 years+, jurisdiction"

/* Education*/
gen peredhs=(numhs/num25up) 
gen peredcol=(numcol/num25up) 
label var peredhs "% with HS deg or up, 25 yrs old+"
label var peredcol "% with college deg or up, 25 yrs old+"

/* Income*/
/* Median family income*/
/* CPI: into Y2000 dollars*/
replace medfaminc=medfaminc/.443
gen lnmedinc=ln(medfaminc)
label var lnmedinc "ln(median family income), jurisdiction, $2000"
/* Poverty measures*/
gen perpov=(numfambpov/numfam) 
label var perpov "% families below poverty line"
replace perpov=(numperbpov/numper) if perpov==.

label var name "Name of jurisdiction, string"
label var state_text "State 2-digit abbreviation"
label var state "State FIPS code"
label var jurcode "Jurisdiction code, 6 letters + 2 digit state"
label var totpop "Total # residents"
label var blackpop "# black residents"
label var asianpop "# asian residents"
label var spanpop "# hispanic residents"
label var num65up "# residents, 65 yrs+"
label var num25up "# residents, 25 yrs+"
label var numhs "# residents, 25+ -- high school grads"
label var numcol "# residents, 25+ -- college grads"
label var numhh "# residents, 65 yrs+"
label var medhhinc "Median household income
label var medfaminc "Median family income"
label var numfambpov "# families, below poverty line"
label var numperbpov "# residents, below poverty line"
label var numper "# residents in poverty count"
label var numfam "# families"


save juris_data_1980.dta, replace



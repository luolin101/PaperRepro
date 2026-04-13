/* This do file combines jurisdiction-level data from two sources: 
1. Main file: juris_CCDB_1970.dta, which was taken from the City and County data book in 1972 (electronic) 
2. jurisdata_1970_master.txt was collected by hand to supplement data from the CCDB.

Data was collected by hand for three purposes:
a. Data that was not available electronically for *any* city. These variables are: number of Hispanic residents (measured as 
individuals who speak Spanish); number of 2nd generation residents (with one or both parents born in a foreign country); 
number of families in different income categories (note that the 1972 CCDB does contain *some* categories, but not all that 
are available)
b. All data for a few jurisdictions small enough not to be included in CCDB -- that is, under 25,000 residents in 1970. 
c. Strangly, number of black residents, which is missing for many jurisdictions in CCDB.
*/

/* Read in data collected by hand*/
clear
set mem 40m
insheet using jurisdata_1970_master.txt, tab
gen oldbord=1
rename state state_text
/*Reformat flag variable for presence of electronic data from text to numeric*/
gen noelectronic01=0 if noelectronic=="N"
replace noelectronic01=1 if noelectronic=="Y"
drop noelectronic
rename noelectronic01 noelectronic
save juris_master_1970_aej.dta, replace
clear
/* Read in data collected for new borders. These include the CCDB data*/
insheet using jurisdata_1970_expansion1.txt, tab
drop exp*
gen oldbord=0
append using juris_master_1970_aej.dta
drop if name==""
save juris_master_1970_aej.dta, replace
/* Read in data collected for second expansion (by David Lee, 2008). These include CCDB data*/
clear
insheet using jurisdata_1970_expansion2.txt, tab
drop if name==""
destring poptot, replace
gen oldbord=0
rename state state_text
rename statefip state
append using juris_master_1970_aej.dta
sort jurcode
/* Merge with CCDB data by jurcode.*/
merge jurcode using juris_CCDB_1970.dta, update
tab _merge
drop _merge

/* Drop variables not used, including spending/revenue from CCDB and other entered by hand*/
drop fam1000-fam49999 total_revenue-sew_cap fam2999a-fam50000 exp* proptax-citywage
drop numpol county smsa sh_polfire
drop if jurcode=="floralny"
replace state=42 if state==.
replace state_text="PA" if state_text==""

**DEMORAPHICS FROM CENSUS OF POPULATION
/* Demographic variables: Race & Ethnicity */
gen shblack=popbl/poptot
gen shhisp=pop_spanlan/poptot
replace shhisp=per_span if shhisp==.
rename perfb shfb
replace shfb=(popfb/poptot) if shfb==.
gen sheth=((popfb+pop2g)/poptot) if shfb==.
replace sheth=((pop2g/poptot)+shfb) if shfb!=.
label var shblack "% black, jurisdiction"
label var shhisp "% spanish language, jurisdiction"
label var sheth "% pop born abroad or w/ parent(s) born abroad"
label var shfb "% pop born abroad"
/* Education*/
replace pered5=((num_14yr+num_nosch)/pers_25) if pered5==.
replace peredhs=(num_4hs/pers_25) if peredhs==.
replace peredcol=(num_4col/pers_25) if peredcol==.
/* One mis-entered median education (mckeesrock) for now*/
replace meded=. if meded>20
drop pers_25 num_nosch-num_4col popbl pop_spanlan popfb pop2g perspan
/* Income*/
/* Median family income*/
/* CPI: into Y2000 dollars*/
replace fammedinc=fammedinc/.225
gen lnmedinc=ln(fammedinc)
label var lnmedinc "ln( median family income), jurisdiction, $2000"
/* Poverty measures*/
replace perpov=(fambelowpov/famtot) if perpov==.
label var perpov125 "% families earning 125% or less of poverty line"
/* Note: perpov_bl and famb_medinc available only for 58 jurisdictions.*/
drop fambelowpov per_ed5 per_edhs per_edcol

/* Label variables*/
label var name "Jurisdiction name, from CCDB data"
label var jurcode "6-digit jurisdiction code + 2 digit state code"
label var state "State FIPS code"
label var state_text "2 digit state abbreviation"
label var poptot "# residents in jurisdiction"
label var shfb "Share residents born abroad"
label var meded "Median years of education, residents 25+ yrs"
label var peredhs "Share residents with HS degree (25+ yrs)"
label var peredcol "Share residents with college degree (25+ yrs)"
label var famtot "# families in jurisdiction"
label var fammedinc "Median family income"
label var perpov "Share families below poverty line"
label var oldbord "=1 if in original sample"
label var noelectronic "=1 if no electronic jurisdiction data, 1970"
label var per_span "Share hispanic in jurisdiction"

sort jurcode
save juris_master_1970_aej.dta, replace


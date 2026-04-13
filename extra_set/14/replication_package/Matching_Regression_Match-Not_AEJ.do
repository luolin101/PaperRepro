/* MATCHING REGRESSIONS : Was matched or not

ALLAN COLLARD-WEXLER

April 22 2009 */


clear all
set mem 1g
set more off
use case_data_all_2.dta

cap set scheme lean2
*--------+---------+---------+---------+---------+---------+---------+---------+
* MERGE IN GRID DATA INFORMATION
*--------+---------+---------+---------+---------+---------+---------+---------+

sort mother_name presented_date
 
replace mother_name="Jenyfer" if mother_name=="Jenyfer"
preserve
clear 

use ChoicePanel2.dta
// Do some work in choice panel
gen in_cp=1
replace pap_name="None" if pap_name==""
sort pap_name file_date
by pap_name: gen paped_activity_time=file_date[_N]-file_date
by pap_name: egen pap_activity_time=max(paped_activity_time)

sort bid_on_d pap_name file_date
by bid_on_d pap_name: gen paped_bid_time=file_date[_N]-file_date
replace paped_bid_time=0 if bid_on_d==0
bysort pap_name: egen pap_bid_time=max(paped_bid_time)



bysort mother_name presented_date file_date: egen number_paps_interested_gay=sum(full_gay)
bysort mother_name presented_date file_date: egen number_paps_interested_single=sum(full_single)
bysort mother_name presented_date file_date: egen fincost=max(finalization_cost_domestic)
 
// Drop ambiguous gay and lesbian and single 
/*
drop if sub_single>0 & sub_single<1 & number_paps_interested>0
drop if sub_lesbian>0 & sub_lesbian<1 & sub_single==0 & number_paps_interested>0
drop if sub_gay>0 & sub_gay<1 & sub_single==0 & number_paps_interested>0
drop sub_lesbian sub_gay*/

cap drop _merge


// Fix up Names
replace mother_name=regexr(mother_name,"Two", "")
replace mother_name=regexr(mother_name,"Three", "")
replace mother_name=regexr(mother_name,"Four", "")
// Keep last observation the last day:
sort mother_name presented_date
by mother_name presented_date: gen last=(_n==_N)


keep if last==1 

sort mother_name presented_date

save temp, replace
restore


* Fixing Up Names
cap drop _merge
drop if mother_name=="" 
drop if mother_name=="none"
drop if presented_date==.
gen newyear2=year(presented_date)
drop if newyear2==2003
drop if newyear2==2010
drop newyear2



merge m:1 mother_name presented_date using temp, update

tab _merge
gen newyear2=year(presented_date)

drop if presented_date==.
drop if _merge==2 & number_paps_interested~=0

*--------+---------+---------+---------+---------+---------+---------+---------+
* MERGE IN MISSING CASE FILE DATA
*--------+---------+---------+---------+---------+---------+---------+---------+

preserve
keep if _merge==2 & number_paps_interested==0
keep presented_date mother_name 
save match_no_app, replace


clear
insheet using no_app_case.csv , names

drop if note_applications~=""
drop note_applications


rename presented_date old_presented_date
gen presented_date=date(old_presented_date,"DMY")
drop old_presented_date 
gen in_cp=1
gen add_case_data=1
gen number_paps_interested=0

sort mother_name presented_date
save no_app_case, replace
restore

drop _merge
merge m:1 mother_name presented_date using no_app_case
tab _merge
drop _merge
drop if final_disposition=="not in case file"
replace matched_d=(final_disposition=="matched") if matched_d==. & add_case_data==1
replace matched_d=(final_disposition~="matched") if matched_d==. & add_case_data==1
replace decided_to_parent=(final_disposition=="decided to parent") if decided_to_parent==. & add_case_data==1
replace  decided_to_parent=(final_disposition~="decided to parent") if decided_to_parent==. & add_case_data==1


capture log close
log using Matching_Regression_Match-Not.log, replace
egen mother_id_2=group(mother_name case_file_date presented_date)
drop mother_id
rename mother_id_2 mother_id

sort mother_id number_paps_interested
replace mother_id=_n+10000 if number_paps_interested==0 & mother_id==.

bysort mother_id: egen matched_adoptlink_d=sum(chosen_pap)
save temp, replace

duplicates drop mother_id pap_id, force
drop duptag
bysort mother_id: gen pap_number=_n

local mothervars="mother_name mother_id already_born_d number_paps gender_unknown_d baby_girl_d presented_date due_date born_date race_black race_indian race_white race_asian race_hispanic race_native matched_date  "
local papvars="pap_name gay_couple single_mother subjective_gay subjective_single"

// Some recoding

gen parent_word=strpos(col2,"parent")
replace parent_word=strpos(col3,"parent") if parent_word==0
replace parent_word=strpos(col4,"parent") if parent_word==0

gen lost_word=strpos(col2,"lost")
replace lost_word=strpos(col3,"lost") if lost_word==0
replace lost_word=strpos(col4,"lost") if lost_word==0
replace decided_to_parent=1 if parent_word>0
replace lost_contact=1 if lost_word>0

gen boy_word=strpos(col1,"boy")
replace boy_word=strpos(col2,"boy") if boy_word==0
replace boy_word=strpos(col3,"boy") if boy_word==0
replace baby_boy_d=1 if (boy_word>0) 


gen girl_word=strpos(col1,"girl")
replace girl_word=strpos(col2,"girl") if girl_word==0
replace girl_word=strpos(col3,"girl") if girl_word==0
replace baby_girl_d=1 if girl_word>0 & baby_girl_d==.

gen unknown_word=strpos(col1,"gender unknown")
replace unknown_word=strpos(col2,"gender unknown") if unknown_word==0
replace unknown_word=strpos(col3,"gender unknown") if unknown_word==0
replace gender_unknown_d=1 if unknown_word>0 & gender_unknown_d==.

tab baby_girl_d gender_unknown 
tab baby_girl_d baby_boy_d
tab baby_boy_d gender_unknown 

// Gender Unknown as the residual catagory.
replace gender_unknown_d=1 if baby_girl_d~=1 & baby_boy_d~=1

replace baby_girl_d=0 if baby_boy_d==1
replace baby_girl_d=0 if gender_unknown_d==1
replace baby_boy_d=0 if baby_girl_d==1
replace baby_boy_d=0 if gender_unknown_d==1
replace gender_unknown_d=0 if baby_girl_d==1
replace gender_unknown_d=0 if baby_boy_d==1

tab baby_boy baby_girl
tab baby_girl gender_unknown


keep if pap_number==1 // Keep only the first pap in the data

replace gay_couple=. if number_paps_interested<1
replace single_mother=. if number_paps_interested<1
replace lesbian_couple=. if number_paps_interested<1

rename  time_on_site old_time_on_site
gen time_on_site=case_closed_date-presented_date
replace time_on_site=matched_date-presented_date if time_on_site==.
replace time_on_site=. if time_on_site<1
replace time_on_site=old_time_on_site if add_case_data==1
gen time_presented_birth=due_date-presented_date
replace time_presented_birth=born_date-presented_date if time_presented_birth==.
gen time_end_birth=time_on_site+presented_date-due_date

gen time_presented_birth_unborn=due_date-presented_date if due_date>presented_date
gen time_presented_birth_born=presented_date-due_date if due_date<presented_date



gen white_girl=race_white*baby_girl_d

gen number_pap_early=number_paps_interested*(time_on_site<50)
gen number_pap_late=number_paps_interested*(time_on_site>=50)

gen pap_rate=number_paps_interested/(time_on_site+1)

gen pap_rate_single=number_paps_interested_single/(time_on_site+1)
gen pap_rate_gay=number_paps_interested_gay/(time_on_site+1)

gen cost_domestic=finalization_cost_domestic/10000


gen early_end=(time_on_site<50)
label var cost_domestic "Finalization Cost (in 10 000s of dollars)"
label var fincost "Finalization Cost (in 10 000s of dollars) from Choice Panel"


replace matched_adoptlink_d=1 if matched_adoptlink_d==2

replace single_mother=0 if single_mother==-1
replace gay_couple=0 if gay_couple==-1
replace lesbian_couple=0 if lesbian_couple==-1

label var time_on_site "Time on Site"
label var already_born "Already Born"
label var pap_rate "PAP Arrival Rate Per Day"
label var race_black "African-American"
label var baby_girl_d "Girl"
label var baby_boy_d "Boy"
label var gender_unknown_d "Gender Unknown"

label var finalization_cost_domestic "Finalization Cost"
label var gay_couple "Gay Couple"
label var single_mother "Single Mother"
label var lesbian_couple "Lesbian Couple"
label var matched_d "Matched Child"
label var matched_adoptlink_d "Matched on Site"
label var lost_contact "Lost Contact"
label var case_closed_d "Case Closed"
label var decided_to_parent "Decided to Parent"
label var race_white "White"
label var race_hispanic "Hispanic"
label var no_adoptlink_match "Not Matched on Site"
label var usa_only_d "USA PAPs Only"
gen foreign_ok_d=1-usa_only_d
label var foreign_ok_d "Foreign PAPs Can Adopt"


label var time_presented_birth "Time from Presentation to Birth"
gen month_presented_birth=time_presented_birth/30
label var month_presented_birth "Months from Presentation to Birth"

label var time_end_birth "Time from End on site to Birth"
gen month_end_birth=time_end_birth/30
label var month_end_birth "Months from End on site to Birth"


label var gay_ok "Gay Can Adopt"
label var single_mother_ok "Single Can Adopt"


label var number_paps_interested "Number of Interested PAPs"
label var number_paps_interested_single "Number of Interested PAPs who are single"
label var number_paps_interested_gay "Number of Interested PAPs who are gay"


gen fin_cost=finalization_cost_domestic

// Leeat Comment: Drop pre June 2004
drop if case_closed_date<date("04jun2004","DMY") & add_case_data==.

tab race_black
tab race_black if matched_d==1

replace in_cp=0 if in_cp==.

save temp_case, replace

replace lost_contact=0 if lost_contact==.
cap ssc install sutex 
sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple decided_to_parent lost_contact case_closed_d matched_d matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign  lost_contact decided_to_parent case_closed_d if in_cp==1, labels minmax file(cases_sum.tex) replace

sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple decided_to_parent lost_contact case_closed_d matched_d matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign if in_cp==1 & number_paps_interested==0, labels minmax file(cases_sum_zero_app.tex) replace


sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple decided_to_parent lost_contact case_closed_d matched_d matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign if in_cp==1 & number_paps_interested>=5, labels minmax file(cases_sum_fivemore_app.tex) replace


sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple  matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign if matched_d==1 & in_cp==1, labels minmax file(cases_sum_matched.tex) replace

sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple decided_to_parent lost_contact case_closed_d matched_d matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign if matched_d==0 & in_cp==1, labels minmax file(cases_sum_not_matched.tex) replace



sutex already_born_d number_paps_interested number_paps_interested_gay number_paps_interested_single pap_rate gender_unknown_d baby_girl_d baby_boy_d race_black race_white race_hispanic gay_ok single_mother_ok foreign_ok_d  gay_couple single_mother lesbian_couple  matched_adoptlink_d no_adoptlink_match time_on_site time_presented_birth  time_presented_birth_unborn time_presented_birth_born time_end_birth finalization_cost_foreign if matched_adoptlink_d==1 & in_cp==1, labels minmax file(cases_sum_matched_adoptlonk.tex) replace


// PAP RATE
gen case_gender="girl" if baby_girl==1
replace case_gender="boy" if baby_boy==1
replace case_gender="gender unknown" if gender_unknown==1

gen case_race="black" if race_black>=0.5
replace case_race="hispanic" if race_hispanic>=0.5
replace case_race="white" if race_white>=0.5



tabstat pap_rate if in_cp==1, by(case_gender) stat(mean semean N)

tabstat pap_rate if in_cp==1, by(case_race) stat(mean semean N) 

tabstat pap_rate if in_cp==1, by(already_born) stat(mean semean N) 


//--------+---------+---------+---------+---------+---------+---------+---------+
// PROBIT: MATCHING
//--------+---------+---------+---------+---------+---------+---------+---------+


label var matched_d "Matched"
cap gen year=year(file_date)
label variable year "Year"

* Only up to 2009
drop if year>2009



label var year_2004 "Year 2004"
label var year_2005 "Year 2005"
label var year_2006 "Year 2006"
label var year_2007 "Year 2007"
label var year_2008 "Year 2008"


local spec1="already_born_d race_black baby_girl baby_boy year_*"
local spec2="already_born_d race_black baby_girl baby_boy pap_rate year_* cost_domestic"
local spec3="already_born_d race_black baby_girl baby_boy pap_rate year_* cost_domestic month_presented_birth "
local spec4="already_born_d race_black baby_girl baby_boy year_* cost_domestic month_presented_birth  gay_ok single_mother_ok usa_only_d "
local spec5="already_born_d race_black baby_girl baby_boy year_* pap_rate cost_domestic month_presented_birth  gay_ok single_mother_ok" 
local spec6="already_born_d race_black baby_girl baby_boy year_* cost_domestic month_presented_birth"

local spec11="already_born_d race_black baby_girl baby_boy year_* cost_domestic month_presented_birth pap_rate pap_rate_single pap_rate_gay"

sum `spec5'

// Checks using number of interested paps....
local spec12="already_born_d race_black baby_girl baby_boy number_paps_interested year_*"
local spec13="already_born_d race_black baby_girl baby_boy number_paps_interested time_on_site year_*"


probit matched_adoptlink_d `spec12'
mfx
estimates store match_type_adoptlink

probit matched_d `spec12'
mfx
estimates store match1


probit matched_adoptlink_d `spec13'
mfx
estimates store match_type_adoptlink

probit matched_d `spec13'
mfx
estimates store match1

probit  decided_to_parent `spec13'
mfx
estimates store parent1



//save matching_regession_data, replace

probit matched_adoptlink_d `spec11'
mfx
estimates store match_type_adoptlink
probit matched_d `spec11'
mfx
estimates store match_type_d



probit matched_adoptlink_d `spec1'
mfx
estimates store match_adopt1


probit matched_adoptlink_d `spec2'
mfx
estimates store match_adopt2

probit matched_adoptlink_d `spec3'
mfx
estimates store match_adopt3


probit matched_adoptlink_d `spec4'
mfx
estimates store match_adopt4

probit matched_adoptlink_d `spec5'
mfx
estimates store match_adopt5

probit matched_adoptlink_d `spec6'
mfx
estimates store match_adopt6

*--------+---------+---------+---------+---------+---------+---------+---------+

probit matched_d `spec1'
mfx
estimates store match1

probit matched_d `spec2'
mfx
estimates store match2

probit matched_d `spec3'
mfx
estimates store match3


xi: probit matched_d `spec4'
mfx
estimates store match4

xi: probit matched_d `spec5'
mfx
estimates store match5

xi: probit matched_d `spec6'
mfx
estimates store match6
*--------+---------+---------+---------+---------+---------+---------+---------+
probit  decided_to_parent `spec1'
mfx
estimates store parent1

probit  decided_to_parent `spec2'
mfx
estimates store parent2

probit  decided_to_parent `spec3'
mfx
estimates store parent3


xi: probit  decided_to_parent `spec4'
mfx
estimates store parent4

xi: probit  decided_to_parent `spec5'
mfx
estimates store parent5

xi: probit  decided_to_parent `spec6'
mfx
estimates store parent6


xi: probit  decided_to_parent already_born_d race_black baby_girl baby_boy pap_rate year_* cost_domestic month_presented_birth


probit lost_contact `spec1'
mfx
estimates store lost_contact


probit decided_to_parent `spec1' 
mfx
estimates store decided_to_parent


capture erase probit_match_not.tex
estout  match6 match4 match1 match2 match3 match5 using probit_match_not.tex, style(tex) label cells(b(star fmt(2)) t(par fmt(2))) margin legend stats(Xmfx_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Babies))     varlabels(_cons Constant )

capture erase probit_adoptlinkmatch_not.tex
estout  match_adopt6 match_adopt4 match_adopt1 match_adopt2 match_adopt3 match_adopt5 using probit_adoptlinkmatch_not.tex, style(tex) label cells(b(star fmt(2)) t(par fmt(2))) margin legend stats(Xmfx_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Babies))  varlabels(_cons Constant)

capture erase probit_parent.tex
estout  parent6 parent4 parent1 parent2 parent3 parent5 using probit_parent.tex, style(tex) label cells(b(star fmt(2)) t(par fmt(2))) margin legend stats(Xmfx_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Babies))     varlabels(_cons Constant )

capture erase probit_adoptlink_offsite.tex
estout  match5 match_adopt5 using probit_adoptlink_offsite.tex, style(tex) label cells(b(star fmt(2)) t(par fmt(2))) margin legend stats(Xmfx_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Babies))  varlabels(_cons Constant)



log close


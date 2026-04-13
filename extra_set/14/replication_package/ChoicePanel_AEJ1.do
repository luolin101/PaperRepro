/***************************

ALLAN COLLARD-WEXLER 

first version: March 31 2009
current version: June 2013
Program to Analyze Pap Choice Data
*--------+---------+---------+---------+---------+---------+---------+---------+
rsync -avuz collardwexler@maccomputer1.stern.nyu.edu:~/Dropbox/Adoption_Project/AEJ/AEJ_Revision/stata/ /scratch/acw6/adoption/

****************************/

clear all
set more off
set mem 2g
set maxvar 10000

cap ssc install estout


*--------+---------+---------+---------+---------+---------+---------+---------+
* Detail Email Files
*--------+---------+---------+---------+---------+---------+---------+---------+
use pdf_data_short.dta, clear

cap erase table0_4.tex
sutex born baby_girl baby_boy baby_info_race_w baby_info_race_b baby_info_race_o sum_of_csts, labels minmax file(table0_4.tex) replace

clear

*--------+---------+---------+---------+---------+---------+---------+---------+
* Application Files
*--------+---------+---------+---------+---------+---------+---------+---------+
use ChoicePanel2, clear

// Now we do the gay, lesbian coding right: we are just going to drop the cases where it is ambiguous 

bysort pap_id: egen full_gay=max(subjective_gaymen)
bysort pap_id: egen full_single=max(subjective_single_score)
bysort pap_id: egen full_lesbian=max(subjective_lesbian)

drop subjective_gay_score
drop subjective_single_score
drop subjective_lesbian

gen full_gay=sub_gay==1
gen full_lesbian=full_lesbian==1
gen full_single=full_single==1
gen full_straight=(sub_gay==0 & full_lesbian==0 & full_single==0)

label var sub_gay "Gay PAP (Name)"
label var full_single "Single PAP (Name)"
label var full_lesbian "Lesbian Couple (Name)"
label var full_gay "Unambiguous Gay PAP (Name)"
label var full_single "Unambiguous Single PAP (Name)"
label var full_lesbian "Unambiguous Lesbian Couple (Name)"
label var full_straight "Unambiguous Straight Couple (Name)"


sum  full_straight
sum full_gay full_lesbian full_single


save ChoicePanel2, replace

//use ChoicePanel2  in 1/3000, clear
*/
use ChoicePanel2, clear


//  Fix up Straight
replace full_straight=0 if sub_single>0 & sub_single<1
replace full_straight=0 if sub_gay>0 & sub_gay<1
replace full_straight=0 if sub_lesbian>0 & sub_lesbian<1

// Drop ambiguous gay and lesbian and single 
/*drop if sub_single>0 & sub_single<1

drop if sub_lesbian>0 & sub_lesbian<1 & sub_single==0
drop if sub_gay>0 & sub_gay<1 & sub_single==0

drop sub_lesbian sub_gay*/

// Generate Choice Set Restriced Bid 
replace bid_on_restrict_d=. if ((full_gay==1) | (full_lesbian==1)) & gay_ok_d==0
replace bid_on_restrict_d=. if full_single==1 &  single_mother_ok_d==0
replace bid_on_restrict_d=. if case_closed==1

// Table 0: Relationship with Other Datasets
cap ssc install sutex 
sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign, labels minmax file(table0_1.tex) replace

sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign if first_mother, labels minmax file(table0_2.tex) replace


sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign if first_mother & number_paps_interested>0, labels minmax file(table0_2_appbigg1.tex) replace

sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign if first_mother & number_paps_interested==0, labels minmax file(table0_2_appzero.tex) replace


sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign if first_mother & number_paps_interested>4, labels minmax file(table0_2_appbig5.tex) replace


bysort mother_id pap_id: gen first_mother_pap=_n==1

sutex already_born_d baby_girl_d baby_boy_d race_white race_black race_hispanic race_asian  finalization_cost_foreign if first_mother_pap, labels minmax file(table0_3.tex) replace

// Issue with Janelle: Presented december 30, but file dates are early december 7 or so: make this one missing
replace time_on_site=. if mother_id==394
replace end_days_on_site=. if mother_id==394
replace time_first_last_bid=. if mother_id==394
replace max_time_on_site=. if mother_id==394
replace time_first_last_bid=. if mother_id==394


sort mother_id



// Year Composition of PAP Pool
//gen year=year(file_date)
label variable year "Year"

log using time_trend.txt, text replace 
tabstat full_gay full_lesbian full_single, by(year) format(%9.3g)
log close


// Number of Paps per year
preserve
collapse bid_on_d, by(year pap_id)
log using time_trend.txt, text append
tab year
log close
restore


gen switch=(due_date<last_time)&(presented_date<due_date)
replace switch=. if due_date==.
replace switch=. if last_time==.
replace switch=. if presented_date==.

*--------+---------+---------+---------+---------+---------+---------+---------+
// Summary Stats
* Summary Stats 
* BABY
preserve
gen lfincostd=log(finalization_cost_domestic)
collapse (p50) switch (p50) already_born_d  (max) adoption_closed_d (max) month_to_birth (max) month_to_birth_unborn (max) month_to_birth_born (max) time_on_site (max) end_days_on_site (p50) time_first_last_bid max_time_on_site number_paps_interested  bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian number_children adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd year,by(mother_id)


gen year_2004=year==2004
gen year_2005=year==2005
gen year_2006=year==2006
gen year_2007=year==2007
gen year_2008=year==2008
gen year_2009=year==2009

gen bid_per_day=number_paps/time_on_site
label var bid_per_day "Applications Per Day on Site"

label var adoption_closed_d "Adoption Closed"	
label var lfincostd "Log Domestic Finalization Cost"
label var month_to_birth "Months to Birth"
label var usa_only_d "USA Only"
label var black_girl "African-American Girl"
label var black_boy "African-American Boy"
label var race_hispanic "Hispanic"
label var race_asian "Asian"
label var number_children "Number of Children"
label var adoption_private_ok_d "Private Adoption OK"
label var baby_girl_d "Girl"
label var baby_boy_d "Boy"
label var nonaa_girl "Non-African-American Girl"
label var nonaa_boy "Non-African-American Boy"
label var time_on_site "Time on Site"
label var end_days_on_site "Time from Presentation to Last Presence on Site"
label var single_mother_ok "Single PAP OK"
label var gay_ok_d "Gay PAP OK"
label var already_born_d "Already Born"
label var number_paps "Number of Interested Prospective Adoptive Parents (PAP)" 
label var bad_health_words "Bad Health Words"
label var race_white "Caucasian"
label var race_black "African-American"
label var adoption_agency_ok "Adoption Agency OK"
label var finalization_cost_domestic "Domestic Finalization Cost"
label var finalization_cost_foreign "Foreign Finalization Cost"
label var month_to_birth_unborn "Months to Birth for Unborn"
label var month_to_birth_born "Months to Birth for Born"
label var year_2005 "Year 2005"
label var year_2006 "Year 2006"
label var year_2007 "Year 2007"
label var year_2008 "Year 2008"
label var year_2009 "Year 2009"
label var year_2004 "Year 2004"
label var time_first_last_bid  "Days from First Application to Last Application"

gen month_on_site=max_time_on_site/30
gen month_on_site_born=month_on_site if already_born==1
gen month_on_site_unborn=month_on_site if already_born==0

gen days_on_site_born=max_time_on_site if already_born==1 

gen days_on_site_unborn=max_time_on_site if already_born==0 & switch==0 
gen days_on_site_switch=max_time_on_site if already_born==0 & switch==1



sum already_born_d month_to_birth month_to_birth_unborn month_to_birth_born time_on_site time_first_last_bid number_paps_interested bid_per_day bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian number_children adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd adoption_closed_d

cap ssc install sutex 
sutex already_born_d month_to_birth month_to_birth_unborn month_to_birth_born time_on_site end_days_on_s time_first_last_bid  number_paps_interested bid_per_day bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian number_children adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd adoption_closed_d days_on_site_born days_on_site_unborn days_on_site_switch, labels minmax file(baby_sum.tex) replace

sutex already_born_d month_to_birth month_to_birth_unborn month_to_birth_born time_on_site end_days_on_s time_first_last_bid  number_paps_interested bid_per_day bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian number_children adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd adoption_closed_d days_on_site_born days_on_site_unborn days_on_site_switch if number_paps_interested==0, labels minmax file(application_zero_apps_sum.tex) replace

sutex already_born_d month_to_birth month_to_birth_unborn month_to_birth_born time_on_site end_days_on_s time_first_last_bid  number_paps_interested bid_per_day bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian number_children adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd adoption_closed_d days_on_site_born days_on_site_unborn days_on_site_switch if number_paps_interested>4, labels minmax file(application_morefive_apps_sum.tex) replace



// Now some regressions on restrictions
gen black_unknown=race_black*(1-baby_girl_d-baby_boy_d)
label var black_unknown "African-American Unknown Gender"

save baby_stat, replace
use baby_stat, clear

label var finalization_cost_foreign "Finalization Cost in 10 000's of \$"


gen foreign_ok=1-usa_only_d
label var foreign_ok "Foreign OK"
local spec1=" already_born month_to_birth finalization_cost_domestic black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_20*"  

probit gay_ok_d `spec1'
mfx
estimates store gay

probit foreign_ok `spec1'
mfx
estimates store usa

probit single_mother_ok `spec1'
mfx
estimates store single

capture erase restriction_probit.tex
estout gay usa single using restriction_probit.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)

gen fincost=finalization_cost_domestic/10000
label var fincost "Finalization Cost in 10000's of \$"


local spec2=" already_born month_to_birth fincost black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_20*"  

probit gay_ok_d `spec2'
mfx
estimates store gay

probit foreign_ok `spec2'
mfx
estimates store usa

probit single_mother_ok `spec2'
mfx
estimates store single

capture erase restriction_probit_level.tex
estout gay usa single using restriction_probit_level.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)

// Finalization Cost Regressions
gen fincost_thousand=finalization_cost_domestic/1000

local spec1=" already_born month_to_birth black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic race_asian year_2004 year_2005 year_2006 year_2007 year_2008" 
local spec2=" already_born month_to_birth single_mother_ok_d gay_ok_d  black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic race_asian year_2004 year_2005 year_2006 year_2007 year_2008" 

reg fincost_thousand `spec1'
estimates store a1
reg fincost_thousand `spec2'
estimates store a2

reg fincost_thousand `spec1' if already_born==0
estimates store a3
reg fincost_thousand `spec2' if already_born==0
estimates store a4

reg fincost_thousand `spec1' if already_born==1
estimates store a5
reg fincost_thousand `spec2' if already_born==1
estimates store a6


reg lfincostd `spec1'
estimates store a1l
reg lfincostd `spec2'
estimates store a2l

reg lfincostd `spec1' if already_born==0
estimates store a3l
reg lfincostd `spec2' if already_born==0
estimates store a4l

reg lfincostd `spec1' if already_born==1
estimates store a5l
reg lfincostd `spec2' if already_born==1
estimates store a6l



//cap erase hedonicregression.tex
//estout a1 a2 a3 a4 a5 a6 a1l a2l a3l a4l a5l a6l  using  hedonicregression.tex, style(tex)   legend  label stats(r2 r2_a F N,  fmt(%9.2f %9.2f %9.1f %9.0g) labels($R^2$ Adjusted-$R^2$ F-Stat Babies))   cells(b(star fmt(2)) t(par fmt(2))) varlabels(_cons Constant)

cap erase hedonicregression_level.tex
estout a1 a2 a3 a4 a5 a6 using hedonicregression_level.tex, style(tex)   legend  label stats(r2 r2_a F N,  fmt(%9.2f %9.2f %9.1f %9.0g) labels($R^2$ Adjusted-$R^2$ F-Stat Babies))   cells(b(star fmt(2)) t(par fmt(2))) varlabels(_cons Constant)

cap erase hedonicregression_log.tex
estout a1l a2l a3l a4l a5l a6l using hedonicregression_log.tex, style(tex)   legend  label stats(r2 r2_a F N,  fmt(%9.2f %9.2f %9.1f %9.0g) labels($R^2$ Adjusted-$R^2$ F-Stat Babies))   cells(b(star fmt(2)) t(par fmt(2))) varlabels(_cons Constant)

restore

preserve
gen lfincostd=log(finalization_cost_domestic)
collapse (p50) file_date already_born_d month_to_birth time_on_site number_children number_paps bad_health_words_d  single_mother_ok_d gay_ok_d usa_only_d baby_girl_d  baby_boy_d race_white nonaa_boy nonaa_girl race_black black_girl black_boy race_hispanic race_asian adoption_private_ok_d adoption_agency_ok_d finalization_cost_domestic finalization_cost_foreign lfincostd,by(mother_id year)
label variable year "Year"
label var lfincostd "Log Domestic Finalization Cost"
label var month_to_birth "Months to Birth"
label var usa_only_d "USA Only"
gen foreign_ok=1-usa_only_d
label var foreign_ok "Foreign PAP Can Adopt"
label var black_girl "African-American Girl"
label var black_boy "African-American  Boy"
label var race_hispanic "Hispanic"
label var race_asian "Asian"
label var number_children "Number of Children"
label var adoption_private_ok_d "Private Adoption OK"
label var baby_girl_d "Girl"
label var baby_boy_d "Boy"
label var nonaa_girl "Non-African-American  Girl"
label var nonaa_boy "Non-African-American  Boy"
label var time_on_site "Time on Site"
label var single_mother_ok "Single PAP Can Adopt"
label var gay_ok_d "Same-Sex PAP Can Adopt"
label var already_born_d "Already Born"
label var number_paps "Number of Interested Prospective Adoptive Parents (PAP)" 
label var bad_health_words "Bad Health Words"
label var race_white "White"
label var race_black "African-American "
label var adoption_agency_ok "Adoption Agency OK"
label var finalization_cost_domestic "Domestic Finalization Cost"
label var finalization_cost_foreign "Foreign Finalization Cost"

log using time_trend.txt,  text  append
tabstat gay_ok_d single_mother_ok_d foreign_ok  race_black baby_girl baby_boy finalization_cost_domestic month_to_birth, by(year) stat(mean N) format(%9.3g)
log close

// Work on Kernels
gen cats=0 
replace cats=1 if baby_girl_d==1
replace cats=2 if baby_boy_d==1


tab number_paps_interested cats


//twoway kdensity number_paps_interested if baby_girl || kdensity number_paps_interested if baby_boy ||  kdensity number_paps_interested if baby_boy

restore
*--------+---------+---------+---------+---------+---------+---------+---------+

* PAP
preserve

sort pap_id file_date
cap drop the_*
cap drop total_time_pap
by pap_id:egen the_last_time=max(file_date)
by pap_id:egen the_first_time=min(file_date)
gen total_time_pap=the_last_time-the_first_time+1
cap drop bid_end
bysort pap_id mother_id: egen bid_end=max(bid_on_d)

bysort pap_id mother_id: gen last_option=(_N==_n)


collapse (mean) bid_end (mean) bid_on_d (mean) bid_on_restrict_d (mean) total_time_pap last_bid_time (p50) full_gay full_lesbian full_single full_straight (sum) last_option ,by(pap_id)
label var bid_on_restrict "Bid on Baby (Permitted Choices only)"
label var bid_end "Bid on Baby (at some point in time)"
label var bid_on_d "Bid on Baby"
label var full_gay "Unambiguous Gay PAP (Name)"
label var full_single "Unambiguous Single PAP (Name)"
label var full_lesbian "Unambiguous Lesbian Couple (Name)"
label var full_straight "Unambiguous Straight Couple (Name)"
label var total_time_pap "Total Time PAP on Site"
label var last_bid_time "Time Since Last Bid for a PAP"




save pap_stat, replace
use pap_stat, clear

gen ambiguous=1-full_gay-full_lesbian-full_single-full_straight
label var ambiguous "Ambiguous PAP"
sutex bid_on_d bid_on_restrict_d bid_end total_time_pap last_bid_time full_gay full_lesbian full_single full_straight ambiguous, labels minmax file(pap_sum.tex) replace

restore

// Now for a tabulation of the number of bids, and days on site.
preserve

sort pap_id file_date
cap drop the_*
cap drop total_time_pap
by pap_id:egen the_last_time=max(file_date)
by pap_id:egen the_first_time=min(file_date)
gen total_time_pap=the_last_time-the_first_time+1
cap drop bid_end
bysort pap_id mother_id: egen bid_end=max(bid_on_d)

bysort pap_id mother_id: gen last_option=(_N==_n)
keep if last_option

collapse (sum) bid_end (sum) last_option  (mean) total_time_pap (p50) full_gay full_lesbian full_single full_straight ,by(pap_id)
save pap_stat_additional, replace
gen bid_per_day=bid_end/total_time_pap 

sum bid_per_day 
restore


// Referee Comment: 

preserve
keep if bid_on_d==1 & bid_on_d~=.
collapse (mean) race_* baby_* (p50) full_gay full_lesbian full_single full_straight,by(pap_id)
save pap_stat_bid, replace
sutex race_* baby_* full_*, labels minmax file(pap_sum_bid_on.tex) replace 
restore


preserve
keep if bid_on_d==0 & bid_on_d~=.
collapse (mean) race_* baby_* (p50) full_gay full_lesbian full_single full_straight,by(pap_id)
save pap_stat_no_bid, replace
sutex race_* baby_* full_*, labels minmax file(pap_sum_not_bid_on.tex) replace 
restore



*--------+---------+---------+---------+---------+---------+---------+---------+
// Probits of paps

// Base Category 
//gen straight=full_straight==1
label var straight "Straight Couple"
label var full_gay "Unambiguous Gay PAP (Name)"
label var full_single "Single PAP (Name)"
label var full_lesbian "Unambiguous Lesbian Couple (Name)"
label var fincostforeign "Finalization Cost in 10 000's of \$"
label variable month_after_birth "Month After Birth"

// Problem with months!
label var month_1 "1 Month Before Birth"
label var month_2 "2 Month Before Birth"
label var month_3 "3 Month Before Birth"
label var month_4 "4 Month Before Birth"
label var month_5 "5 Month Before Birth"
label var month_6 "6 Month Before Birth"
label var month_7 "7 Month Before Birth"
label var month_8 "8 Month Before Birth"
label var month_9 "9 Month Before Birth"
label var month_10 "10 Month Before Birth"
label var month_11 "11 Month Before Birth"

label var year_2005 "Year 2005"
label var year_2006 "Year 2006"
label var year_2007 "Year 2007"
label var year_2008 "Year 2008"
label var year_2004 "Year 2004"

// Diagnostics of coding

tab bid_on_d full_gay if gay_ok_d==0
tab bid_on_d full_lesbian if gay_ok_d==0
tab bid_on_d full_single if single_mother_ok_d==0

egen pap_day=group(pap_id file_date) 
sort pap_id file_date
by pap_id: egen first_pap_day=min(file_date)
gen pap_time_on_site_so_far=file_date-first_pap_day 


*--------+---------+---------+---------+---------+---------+---------+---------+
* Update Table 3 *
*--------+---------+---------+---------+---------+---------+---------+---------+



local spec1=" already_born month_to_birth lfinalization_cost_foreign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*"  

local spec10=" already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*"  

local spec11=" already_born month_1-month_8  month_after_birth fincostforeign  black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*" 

local spec10f=" already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic"  


* Test of Equality of coefficients
xi:probit bid_on_restrict_d already_born month_to_birth lfinalization_cost_foreign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200* full_gay full_single full_lesbian, cluster(pap_mother_pair)

test  race_hispanic==black_unknown 
test  black_girl==black_boy 
test  black_girl==black_unknown 
test  nonaa_girl==nonaa_boy 

* Comment: Early versus late in gestation period 
global bidvar="bid_on_restrict_d"
global speclate="already_born fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200* "  
xi:probit $bidvar $speclate full_gay full_single full_lesbian if month_to_birth<5 & already_born==0, cluster(pap_mother_pair)
estimates store late
xi:probit $bidvar $speclate full_gay full_single full_lesbian if month_to_birth>=5 & already_born==0 , cluster(pap_mother_pair)
estimates store early 
xi:probit $bidvar $speclate full_gay full_single full_lesbian if already_born==1 , cluster(pap_mother_pair)
estimates store born

capture erase gestation_period.tex
estout born early late using gestation_period.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels($\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) se(par fmt(3))) margin varlabels(_cons \_cons)

capture erase gestation_period_ci.tex
estout born early late using  gestation_period_ci.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels($\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) ci(par fmt(3))) margin varlabels(_cons \_cons)

* Comment: Early vs Late Bidders
global bidvar="bid_on_restrict_d"
global speclatepap="already_born fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200* "  
xi:probit $bidvar $speclatepap full_gay full_single full_lesbian if time_on_web_pap<30, cluster(pap_mother_pair)
estimates store late_pap
xi:probit $bidvar $speclatepap full_gay full_single full_lesbian if time_on_web_pap>=30, cluster(pap_mother_pair)
estimates store early_pap

capture erase early_late_pap_ci.tex
estout early_pap late_pap using  early_late_pap_ci.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels($\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) ci(par fmt(3))) margin varlabels(_cons \_cons)


capture erase early_late_pap.tex
estout early_pap late_pap using  early_late_pap.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels($\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(3))) margin varlabels(_cons \_cons)

* Run Base-Number of Application
bysort mother_id file_date: gen number_current_applications=sum(bid_on_d)
replace number_current_applications=number_current_applications-1 if bid_on_d==1

global bidvar="bid_on_restrict_d"
global specx="already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200* "  
global filex="BidNumApplication"
xi:probit $bidvar $specx number_current_applications full_gay full_single full_lesbian, cluster(pap_mother_pair)
mfx
estimates store All

xi:probit $bidvar $specx number_current_applications time_on_site full_gay full_single full_lesbian, cluster(pap_mother_pair)
mfx
estimates store All2

capture erase $filex.tex
estout All All2 using $filex.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N N_clust,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)



// Last Observation used for prediction
expand 2 in 1
replace already_born=0 in 1
replace month_to_birth=0 in 1
replace lfinalization_cost_foreign=10.1 in 1
replace fincostforeign=2.6 in 1
replace black_girl=0 in 1
replace black_boy=0 in 1
replace black_unknown=0 in 1
replace nonaa_girl=0 in 1
replace nonaa_boy=0 in 1
replace race_hispanic=0 in 1
replace year_2004=0 in 1
replace year_2005=0 in 1
replace year_2006=0 in 1
replace year_2007=0 in 1 
replace year_2008=0 in 1
replace full_gay=0 in 1
replace full_single=0 in 1
replace full_lesbian=0 in 1
replace month_1=0 in 1
replace month_2=0 in 1
replace month_3=0 in 1
replace month_4=0 in 1
replace month_5=0 in 1
replace month_6=0 in 1
replace month_7=0 in 1
replace month_8=0 in 1
replace month_9=0 in 1
replace month_10=0 in 1
replace month_11=0 in 1
replace month_after_birth=0 in 1
replace full_gay=0 in 1 
replace full_single=0 in 1 
replace full_lesbian=0 in 1 
replace full_gay=0 in 1 
replace full_single=0 in 1 
replace full_lesbian=0 in 1 

cap drop year_2009

// Program to run the estimates in Tables 
cap program drop PAPVersions
program define PAPVersions

xi:probit $bidvar $specx  full_gay full_single full_lesbian, cluster(pap_mother_pair)
mfx
estimates store All
cap drop allbase
predict allbase 

xi:probit $bidvar $specx if full_straight==1, cluster(pap_mother_pair)
mfx
estimates store StraightCouple
cap drop straightbase
predict straightbase 

test race_hispanic=black_unknown
test nonaa_girl-nonaa_boy=black_girl-black_boy


xi:probit $bidvar $specx if full_gay==1 & gay_ok_d==1, cluster(pap_mother_pair)
mfx
estimates store GayMen
cap drop gaybase
predict gaybase 

xi:probit $bidvar $specx if full_single==1 & single_mother_ok_d==1, cluster(pap_mother_pair)
mfx
estimates store Single
cap drop singlebase
predict singlebase 

xi:probit $bidvar $specx if full_lesbian==1 & gay_ok_d==1, cluster(pap_mother_pair)
mfx
estimates store Lesbian
cap drop lesbianbase
predict lesbianbase 


cap log close
log using $filex.txt, text replace

sum allbase straightbase gaybase lesbianbase singlebase in 1
sum allbase straightbase gaybase lesbianbase  singlebase 

log close

capture erase $filex.tex
estout All StraightCouple GayMen Lesbian  Single  using $filex.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N N_clust,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)

* Probits for Cost Normalization
capture erase $filex.csv
estout All StraightCouple GayMen Lesbian  Single  using $filex.csv, style(tab)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(fmt(3)) t(par fmt(2)))  varlabels(_cons \_cons)

capture erase ci_$filex.tex
* Probits with ci's
estout All StraightCouple GayMen Lesbian  Single  using ci_$filex.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N N_clust,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) ci(par fmt(2))) margin varlabels(_cons \_cons)

capture erase ci_beta_$filex.tex
estout All StraightCouple GayMen Lesbian  Single  using ci_beta_$filex.tex, style(tex)   legend  label stats(Xmargins_y chi2 ll N N_clust,  fmt(%9.3f %9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) ci(par fmt(2))) varlabels(_cons \_cons)

end

* Run Base
global bidvar="bid_on_restrict_d"
global specx="already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*"  
global filex="BidBabyLevel90"
PAPVersions

* Run Base with time effects
cap drop bid_on_restrict_10
gen bid_on_restrict_10=bid_on_restrict_d if  last_bid_time<10
global bidvar="bid_on_restrict_10"
global specx=" already_born month_1-month_8  month_after_birth fincostforeign  black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*" 
global filex="BidBabyLevel10_Timing"
PAPVersions


* Run 10 Days 
cap drop bid_on_restrict_10
gen bid_on_restrict_10=bid_on_restrict_d if  last_bid_time<10
global bidvar="bid_on_restrict_10"
global specx="already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*"  
global filex="BidBabyLevel10"
PAPVersions

* End Version
preserve
sort pap_mother_pair file_date
cap drop end_bid
by pap_mother_pair: egen end_bid=max(bid_on_restrict_d)
by pap_mother_pair: keep if _n==1 
expand 2 in 1
replace already_born=0 in 1
replace month_to_birth=0 in 1
replace lfinalization_cost_foreign=10.1 in 1
replace fincostforeign=2.6 in 1
replace black_girl=0 in 1
replace black_boy=0 in 1
replace black_unknown=0 in 1
replace nonaa_girl=0 in 1
replace nonaa_boy=0 in 1
replace race_hispanic=0 in 1
replace year_2004=0 in 1
replace year_2005=0 in 1
replace year_2006=0 in 1
replace year_2007=0 in 1 
replace year_2007=0 in 1
replace year_2008=0 in 1
replace full_gay=0 in 1
replace full_single=0 in 1
replace full_lesbian=0 in 1
replace month_1=0 in 1
replace month_2=0 in 1
replace month_3=0 in 1
replace month_4=0 in 1
replace month_5=0 in 1
replace month_6=0 in 1
replace month_7=0 in 1
replace month_8=0 in 1
replace month_9=0 in 1
replace month_10=0 in 1
replace month_11=0 in 1
replace month_after_birth=0 in 1
replace full_gay=0 in 1 
replace full_single=0 in 1 
replace full_lesbian=0 in 1 

save ChoicePanel_NoTime, replace

global bidvar="end_bid"
global specx="already_born month_to_birth fincostforeign black_girl black_boy black_unknown nonaa_girl nonaa_boy race_hispanic year_200*"  
global filex="BidBabyLevelEnd"
PAPVersions
restore

*--------+---------+---------+---------+---------+---------+---------+---------+

// Conditional logits All PAPs 
logit bid_on_d `spec10' full_gay full_single full_lesbian, cluster(pap_mother_pair)
estimates store All 

logit bid_on_d `spec10' full_gay full_single full_lesbian pap_time_on_site_so_far, cluster(pap_mother_pair)
estimates store All_time  

clogit bid_on_d `spec10f', group(pap_day) 
estimates store All_f 

global filex="conditional_all" 
capture erase $filex.tex
estout All All_f All_time using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) varlabels(_cons \_cons)

// Fix Standard errors 
cap erase clogit_All_f2.dta
bootstrap, reps(200) saving(clogit_All_f2, every(1)) cluster(pap_mother_pair): clogit bid_on_d `spec10f', group(pap_day)


// Straight 
logit bid_on_d `spec10'  if full_straight, cluster(pap_mother_pair)
estimates store Straight 

clogit bid_on_d `spec10f'  if full_straight, group(pap_day) 
estimates store Straight_f 

// To bootstrap this: 
cap erase clogit_straight_f.dta
bootstrap, reps(200) saving(clogit_straight_f, every(1)) cluster(pap_mother_pair): clogit bid_on_d `spec10f'  if full_straight, group(pap_day)



logit bid_on_d `spec10' pap_time_on_site_so_far if full_straight, cluster(pap_mother_pair)
estimates store Straight_time  

//clogit bid_on_d `spec10f' pap_time_on_site_so_far   if full_straight, group(pap_id)
//estimates store Straight_time_fixed  

global filex="conditional_Straight" 
capture erase $filex.tex
estout Straight Straight_f Straight_time using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)


// Single 
logit bid_on_d `spec10'  if full_single & single_mother_ok_d, cluster(pap_mother_pair)
estimates store Single 

clogit bid_on_d `spec10f'  if full_single & single_mother_ok_d, group(pap_day) 
estimates store Single_f 

logit bid_on_d `spec10' pap_time_on_site_so_far if full_single  & single_mother_ok_d, cluster(pap_mother_pair)
estimates store Single_time  

//clogit bid_on_d `spec10f' pap_time_on_site_so_far if full_single  & single_ok_d, group(pap_id)
//estimates store Single_time_fixed  

global filex="conditional_Single" 
capture erase $filex.tex
estout Single Single_f Single_time using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)


// To bootstrap this: 
capture erase clogit_single_f.dta
bootstrap, reps(200) saving(clogit_single_f, every(1)) cluster(pap_mother_pair): clogit bid_on_d `spec10f'  if full_single & single_mother_ok_d, group(pap_day)


// Gay 
logit bid_on_d `spec10'  if full_gay & gay_ok_d==1, cluster(pap_mother_pair)
estimates store Gay 

clogit bid_on_d `spec10f'  if full_gay & gay_ok_d==1, group(pap_day) 
estimates store Gay_f 

logit bid_on_d `spec10' pap_time_on_site_so_far if full_gay & gay_ok_d==1, cluster(pap_mother_pair)
estimates store Gay_time  

//clogit bid_on_d `spec10f' pap_time_on_site_so_far if full_gay & gay_ok_d==1, group(pap_id)
//estimates store Gay_time_fixed  

global filex="conditional_Gay" 
capture erase $filex.tex
estout Gay Gay_f Gay_time using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)


capture erase clogit_gay_f.dta
bootstrap, reps(200) saving(clogit_gay_f, every(1)) cluster(pap_mother_pair): clogit bid_on_d `spec10f'  if full_gay & gay_ok_d==1, group(pap_day)

// Lesbian 
logit bid_on_d `spec10'  if full_lesbian & lesbian_ok_d==1, cluster(pap_mother_pair)
estimates store Lesbian 

clogit bid_on_d `spec10f'  if full_lesbian & lesbian_ok_d==1, group(pap_day) 
estimates store Lesbian_f 

logit bid_on_d `spec10' pap_time_on_site_so_far if full_lesbian & lesbian_ok_d==1, cluster(pap_mother_pair)
estimates store Lesbian_time  

//clogit bid_on_d `spec10f' pap_time_on_site_so_far if full_lesbian & lesbian_ok_d==1, group(pap_id)
//estimates store Lesbian_time_fixed  

global filex="conditional_Lesbian" 
capture erase $filex.tex
estout Lesbian Lesbian_f Lesbian_time using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)

capture erase clogit_lesbian_f.dta
bootstrap, reps(200) saving(clogit_lesbian_f, every(1)) cluster(pap_mother_pair): clogit bid_on_d `spec10f'  if full_lesbian & lesbian_ok_d==1, group(pap_day)


logit bid_on_d `spec1'  if full_straight==1, cluster(pap_mother_pair)
estimates store Straight
logit bid_on_d `spec1'  if full_gay==1 & gay_ok_d==1, cluster(pap_mother_pair)
estimates store Gay  

logit bid_on_d `spec1' if full_lesbian==1 & gay_ok_d==1, cluster(pap_mother_pair)
estimates store Lesbian 

logit bid_on_d `spec1'  if full_single==1 & single_mother_ok_d==1, cluster(pap_mother_pair)
estimates store Single 

// Assemble clogit statistics
bstat using clogit_All_f2.dta
estimates store all

bstat using clogit_lesbian_f.dta
estimates store lesbian

bstat using clogit_gay_f.dta
estimates store gay

bstat using  clogit_single_f.dta
estimates store single

bstat using  clogit_straight_f.dta
estimates store straight


global filex="conditional_table" 
capture erase $filex.tex
estout all straight gay lesbian single  using $filex.tex, style(tex)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(3)) t(par fmt(2))) margin varlabels(_cons \_cons)

capture erase $filex.txt
estout all straight gay lesbian single  using $filex.txt, style(tab)   legend  label stats(chi2 ll N N_clust,  fmt(%9.2f %9.1f %9.0g %9.0g) labels(Baseline $\chi^2$ Log-Likelihood Observations PAP-Babies))   cells(b(star fmt(5)) t(par fmt(2))) margin varlabels(_cons \_cons)









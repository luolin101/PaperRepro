/* MATCHING REGRESSIONS 

ALLAN COLLARD-WEXLER

April 22 2009 
Current September 2011*/

set more off
clear
clear matrix
clear mata
set mem 1g

local RepNum=100
use case_data_all.dta


// Some recoding	
gen baby_boy_d=.
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


*set scheme lean2
*--------+---------+---------+---------+---------+---------+---------+---------+
* MERGE IN GRID DATA INFORMATION
*--------+---------+---------+---------+---------+---------+---------+---------+

sort mother_name presented_date
preserve
clear 

use ChoicePanel2.dta
// Do some work in choice panel
cap drop _merge
// Drop ambiguous gay and lesbian and single 
drop if sub_single>0 & sub_single<1
drop if sub_lesbian>0 & sub_lesbian<1 & sub_single==0
drop if sub_gay>0 & sub_gay<1 & sub_single==0
drop sub_lesbian sub_gay

// Keep last observation the last day:
sort mother_name pap_name presented_date
by mother_name pap_name presented_date: gen last=(_n==_N)


keep if last==1 

sort mother_name pap_name presented_date

save matchinfo, replace
restore


cap drop _merge
sort mother_name pap_name presented_date

merge mother_name pap_name presented_date using matchinfo


tab _merge
drop if _merge==2

drop if presented_date==.

egen mother_id_2=group(mother_name case_file_date presented_date)

drop mother_id
rename mother_id_2 mother_id



bysort mother_id: egen matched_adoptlink_d=sum(chosen_pap)
gen parent=1
replace parent=0 if matched_adoptlink_d>0
replace parent=0 if matched_d>0


duplicates drop mother_id pap_id, force
drop duptag
bysort mother_id: gen pap_number=_n

local mothervars="mother_name mother_id already_born_d number_paps gender_unknown_d baby_girl_d presented_date due_date born_date race_black race_indian race_white race_asian race_hispanic race_native matched_date  "
local papvars="pap_name gay_couple single_mother subjective_gay subjective_single"

gen inside_pap=1
gen outside_pap=0


// Missing Information
#delimit ;

local gaylist "
andrea&urs
inder&ken
manuel&ted
cooper&todd
james&kerry
bobby&steve
hans&ute
colin&jim
joachim&viktor
jaap&roy
anton&peter
edwin&victor 
jan&mario 
johan&wilco
joe&paul
danniek&roger
chad&will
";

local lesbianlist "
fergal&teresa
karen&margit
gail&paula
nora&noreen
kathleen&sharon
stacy&susan
dawn&jan
joanna&michelle
pat&trisha
demi&heatherr
";

local singlelist "
marlene
pamela
rachael
deniseb
africa
jennifer
ys
deniseb
mj
cj
jr
k
js
francinag
kerry
rosemary
im
michellek
ginab.
susang
sheena 
rb
robert
stephanie
barbara
ev
";

local straightlist "
dave&michelle
chuck&michelle
linda&sam
melchior&stephanie
john&pamela
prudence&scott
katherine&paul
angela&kevin
brian&julie
ute&uwe
alexandra&norbert
christi&david
manuel&ted
james&sandra
bettina&klaus
angela&klemens
debbie&harold
patricia&timb
holger&susanne
barbara&johannes
eric&sarah
alan&christy
bianca&jurgen
marcus&tina
linda&steven
sean&tara
bob&tara
holly&jeff
brian&julie
greg&sherri
paul&tanya
sandy&troy
francois&sylvia
judith&peter
patrizia&rolf
andreas&gabi
brigitte&thomas
christian&patricia
claudia&karl
angela&klemens
brigitte&thomas
marcus&tina
cynthia&mark
peter&renee
azita&james
carol&leonardo
aron&maggie
john&nita
bettina&stephan
mikem&naoma
angelika&norbert
angela&thomas
azita&james
libby&luke
cynthia&raymond
athena&eric 
karen&steve
paulr&sandy
martina&oliver
lynn&steve
harry&iris
danielle&russellr
connie&john
abbey&jeff
alex&corina
angelika&douglas
mallindi&tony
martina&oliver 
alanm&christy
miranda&william
alex&corina
david&laura
david&denise
alfredda&freddy
christine&ray
charlie&christine
mike&tonya
cindy&martin
axel&svenja
andrea&daniel
andreas&simone
chris&christine
jennifer&thom
john&mimi
david&susan
melissa&tim
jim&kim
joel&michelle
stef&yvonne
patricia&pierce
chris&elsie
kim&lance
holly&steven
bruce&karen
carol&charlie
joseph&marguerite
missy&sal
antoinette&craig
harris&karen
sally&todd
christie&tima
sam&trish
danny&shavon
bud&julie
dana&mike
greg&lynne
geri&stevewd
danielle&pat
jeff&leah
dan&liz";

#delimit cr 

// Don't know about these guys...
/*
alfons&irmigard
jolanda&sigrid
fergal&teresa
nora&noreen
andrea&daniel
stef&yvonne
inder&ken
perri&sue
alex&lemoy
haven&sean
h&s
jo&john
          a&m 
      
  |                       pat&trisha |
  |                  alfons&irmigard |
  |                   jolanda&sigrid |
  |                       kirsty&lee |
  |                     andrea&kelly |
  |                    andrea&daniel |
  |                              c&d |
  |                        perri&sue |
  |                       timb&trish |
  |                    danniek&roger |
  |                      stef&yvonne |
  |                        kim&lance |
  |                       haven&sean |
  |                    a'shalee&paul |
  |                        jacko&jos |
  |                        perri&sue |
  |                       alex&lemoy |
  |                       haven&sean |
  |                               im |
  |                               rb |
  |                              h&s |
  |                        dave&sham |
  |                     danny&shavon |
  |                        jacko&jos |
  |                           j&ross |
  |                          jo&john |
  |                       alex&lemoy |
  |                               im |
  |                     geri&stevewd |
  |                     danielle&pat |
  |                          dan&liz 

*/

foreach x of local gaylist {
disp "`x'"
replace full_gay=1 if pap_name=="`x'"
replace full_lesbian=0 if pap_name=="`x'"
replace full_straight=0 if pap_name=="`x'"
replace full_single=0 if pap_name=="`x'"
}

foreach x of local lesbianlist {
disp "`x'"
replace full_gay=0 if pap_name=="`x'"
replace full_lesbian=1 if pap_name=="`x'"
replace full_straight=0 if pap_name=="`x'"
replace full_single=0 if pap_name=="`x'"
}


foreach x of local singlelist {
disp "`x'"
replace full_gay=0 if pap_name=="`x'"
replace full_lesbian=0 if pap_name=="`x'"
replace full_straight=0 if pap_name=="`x'"
replace full_single=1 if pap_name=="`x'"
}

foreach x of local straightlist {
disp "`x'"
replace full_gay=0 if pap_name=="`x'"
replace full_lesbian=0 if pap_name=="`x'"
replace full_straight=1 if pap_name=="`x'"
replace full_single=0 if pap_name=="`x'"
}


gen full_same_sex=full_gay+full_lesbian

// Two Messed Up Observations 
drop if pap_id==263 & mother_id==203


save match_file, replace

// Make an Outside PAP 
sort mother_id pap_id 
keep mother_id pap_id
duplicates drop 

gen inside_pap=0
gen outside_pap=1
save outside_pap_file, replace


append using match_file



bysort mother_id pap_id: gen sum_chosen=sum(chosen_pap)

replace chosen_pap=1 if sum_chosen==0 & outside_pap==1
replace chosen_pap=0 if sum_chosen!=0 & outside_pap==1
egen mother_pap_pair=group(mother_id pap_id)
// Which parent gets picked

replace full_single=0 if outside_pap
replace full_gay=0 if outside_pap
replace full_lesbian=0 if outside_pap
replace full_straight=0 if outside_pap

// For the Simulation:
probit chosen_pap full_straight full_single full_gay full_lesbian
estimates store sim_bmo
cap rm sim_bmo.txt
estout   sim_bmo using  sim_bmo.txt, label

probit chosen_pap full_straight full_single full_gay full_lesbian, cluster(mother_id)

clogit chosen_pap full_straight full_single full_gay full_lesbian, group(mother_id)
mfx, predict(pu0) 
estimates store chosen_pap_1

cap rm chosen_pap.tex
cap rm chosen_pap_margins.tex

estout   chosen_pap_1   using  chosen_pap.tex, style(tex) label cells(b(star fmt(2)) t(par fmt(2))) legend stats(chi2 ll N,  fmt(%9.2f %9.1f %9.0g) labels($\chi^2$ Log-Likelihood Babies))     varlabels(_cons Constant )

estout   chosen_pap_1   using  chosen_pap_margins.tex, margin style(tex) label cells(b(star fmt(2)) t(par fmt(2))) legend stats(chi2 ll N,  fmt(%9.2f %9.1f %9.0g) labels($\chi^2$ Log-Likelihood Babies))     varlabels(_cons Constant )

preserve
drop if outside_pap==1

drop sum_chosen
bysort mother_id: egen sum_chosen=total(chosen_pap)
drop if sum_chosen==0

clogit chosen_pap full_same_sex full_single, group(mother_id)
margins, dydx(*) predict(pu0)
estimates store chosen_pap_2
margins, predict(pu0)


clogit chosen_pap full_single full_gay full_lesbian, group(mother_id)
margins, dydx(*) predict(pu0)
estimates store chosen_pap_3
margins, predict(pu0)

cap rm chosen_pap2.tex
estout   chosen_pap_2 chosen_pap_3  using  chosen_pap2.tex, margin style(tex) label cells(b(star fmt(2)) t(par fmt(2))) legend stats(chi2 ll N,  fmt(%9.2f %9.1f %9.0g) labels($\chi^2$ Log-Likelihood Babies))     varlabels(_cons Constant )



save temp, replace


restore


/* 
No Single Mother
COUNTERFACTUAL 
*/
// Drop observations where at least one of the children not picked

drop if pap_name==""
bysort mother_id: gen picked_on_site=sum(chosen_pap)
drop if picked_on_site==0


cap program drop single_counterfactual
program single_counterfactual, rclass
preserve
capture drop single_all sum_single total_applicants all_single
* Compute Probability all single
bysort mother_id: gen sum_single=sum(full_single)
bysort mother_id: gen total_applicant=_N
gen single_all=(total_applicant==sum_single)

capture drop last
by mother_id: gen last=(_N==_n)
keep if last==1

sum single_all 
matrix c1=r(mean) 

sum baby_boy_d if single_all 
matrix c2=r(mean)

sum race_black if single_all
matrix c3=r(mean)

sum race_black 
matrix c4=r(mean)


sum baby_girl_d if single_all
matrix c5=r(mean)


return scalar missingsingle=c1[1,1]
return scalar missing_boy=c2[1,1]
return scalar missing_black=c3[1,1]
return scalar all_black=c4[1,1]
return scalar missing_girl=c5[1,1]

restore
end
single_counterfactual 

bootstrap missingsingle=r(missingsingle), reps(`RepNum'): single_counterfactual
bootstrap missingblack=r(missing_black), reps(`RepNum'): single_counterfactual
bootstrap all_black=r(all_black), reps(`RepNum'): single_counterfactual
bootstrap missingboy=r(missing_boy), reps(`RepNum'): single_counterfactual


/* 
No Same-Sex
COUNTERFACTUAL 
*/

cap program drop gay_counterfactual
program gay_counterfactual, rclass
preserve

* Compute Probability 
cap drop last
cap drop sum_same_sex total_applicant gay_all
bysort mother_id: gen sum_same_sex=sum(full_same_sex)
bysort mother_id: gen total_applicant=_N
gen gay_all=(total_applicant==sum_same_sex)

by mother_id: gen last=(_N==_n)
keep if last==1

sum gay_all 
matrix c1=r(mean) 

sum baby_boy_d if gay_all 
matrix c2=r(mean)

sum race_black if gay_all
matrix c3=r(mean)

sum race_black 
matrix c4=r(mean)

sum baby_girl_d if gay_all
matrix c5=r(mean)

return scalar missinggay=c1[1,1]
return scalar missing_boy=c2[1,1]
return scalar missing_black=c3[1,1]
return scalar all_black=c4[1,1]
return scalar missing_girl=c5[1,1]


restore
end

bootstrap missinggay=r(missinggay), reps(`RepNum'): gay_counterfactual
bootstrap missingboy=r(missing_boy), reps(`RepNum'): gay_counterfactual
bootstrap missingblack=r(missing_black), reps(`RepNum'): gay_counterfactual
bootstrap all_black=r(all_black), reps(`RepNum'): gay_counterfactual
* Summary Stats



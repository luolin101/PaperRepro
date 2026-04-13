log using block_1970_aej.log, replace
set more off
clear 
set mem 50m

/** (1) CENSUS BLOCK-LEVEL DATA**/

/* Read in block-level Census data by state-county-tract pairs. Data collected in two waves and organization of electronic 
block data changed over this period. Use two separate dictionary files.*/
/* Original state-county-tract pairs - collected by Leah in July, 2005*/
infix using ~/Tract_block/1970/Extracts/1970dictionary.dct, using(~/Tract_block/1970/Extracts/1970-blocks-fulllist.dat)
gen added=0
save block_1970_aej.dta, replace
clear
/* Additional tract pairs based on mistakes in initial request to Wendy Thomas for electronic data - August, 2005*/
infix using ~/Tract_block/1970/Extracts/1970dictionary.dct, using(added_blocks_0825.txt)
gen added=1
append using block_1970_aej.dta
save block_1970_aej.dta, replace
clear
/* Additional tract pairs for the borders above. Initially, only collected one full tract pair per border. Mike 
Lattener extended these borders in 1960 and 1970 to include a section of non-full*/
infix using ~/Tract_block/1970/Extracts/1970dictionary.dct, using(nonfull_from1960.txt)
gen added=2
append using block_1970_aej.dta
save block_1970_aej.dta, replace
/* Additional pairs based on borders outside of original SMSAs (33 new SMSAs). Tier codes completed by Mingjie Sun in 2007*/
clear
infix using ~/Tract_block/1970/Extracts/1970dictionary01.dct, using(~/Tract_block/1970/Extracts/FEB2007REQUEST.dat)
gen added=3
append using block_1970_aej.dta
save block_1970_aej.dta, replace
clear
infix using ~/Tract_block/1970/Extracts/1970dictionary01.dct, using(~/Tract_block/1970/Extracts/DEC2007REQUEST.dat)
gen added=4
append using block_1970_aej.dta
save block_1970_aej.dta, replace

/* The dictionary file reads in electronic block data for 1970 for the tracts in the sample and creates variables. */
label var statefip "state FIPS code"
label var cnty "county FIPS code"
label var tractcd "tract code, 1970"
label var tractsuf "tract suffix, if app. 1970"
label var tract1 "total tract code, decimal implied"
label var block1 "block #, 1970"
label variable per_m "total # men on block"
label variable val_agg_4 "total aggregate value, own occ housing (use ct4 as denom)"
label variable rent_agg_5 "total aggregate rent, rental housing (use ct5 as denom)"
label variable per_f "total # women on block"
label variable per_m04 "# men, 0-4 yrs age"
label variable per_f04 "# women, 0-4 yrs age"
label variable ct3_tot "total # houses, occ/not on block"
label variable ct2_occ "total # occ houses"
label variable ct_vacrent "# vacant houses, for rent"
label variable ct_vacsale "# vacant houses, for sale"
label variable ct1_oo "# houses, owner occupied"
label variable ct1_rt "# houses, rental"
label variable singfam_3 "# single family (use ct3 as denom)"
label variable rms_aggoo_1 "agg # rooms, own occ (use ct1 as denom)"
label variable nokitch_3 "# lacking kitchen (use ct3 as denom)"
label variable val5000_4 "# own occ val <5,000 (use ct4 as denom)"
label variable rt40_5 "# rental, rent<40 (use ct5 as denom)"
label variable ct4_ooval "# own occ, tabulated value"
label variable ct5_rtval "# rental, tabulated rent"
label variable ct_vacrtsh "# vacant, for rent, <2 mo"
label variable ct_vacsalesh "# vacant, for sale, <6 mo"
label variable fam_hw "# units, occ by husband/wife fam (use ct2 as denom)"
label variable fam_male "# units, occ by male head (use ct2 as denom)"
label variable fam_fem "# units, occ by female head (use ct2 as denom)"
label variable allplumb_3 "# units, all plumbing fac (use ct3 as denom)"

/* Missing and suppressed data*/
/* Drop blocks where data is supressed because of size concerns. These have negative values for the counts data*/
drop if nokitch_3<0
/* Replace missing value/rental data with '.'*/
foreach var of varlist val_agg_4 rent_agg_5 val_agg_bl_4 rent_agg_bl_5 ct4_ooval ct5_rtval ct4_ooval_bl ct5_rtval_bl {
replace `var'=. if `var'<0
}
	
/* Dependent variable: Values (owner-occupied housing) and rents (rental units)
Note that aggregate owner occupied value must be multiplied by 250 to get true value. Value and rents given in totals. Need to 
divide by number of units by tenure status for which there is non-missing value/rent information (count 4, count5)*/
/* All occupants*/
gen av_value=((val_agg_4*250)/ct4_ooval)
gen av_rent=rent_agg_5/ct5_rtval
/* Adjust for inflation. CPI: in year 2000 dollars*/
foreach var of varlist av_value av_rent {
	replace `var'=`var'/.225
}
label var av_value "av value, owner occupied (x250)"
label var av_rent "av rent, rental"

/* Now: Mean number of rooms for each type: divide total number of rooms by number of houses in each tenure category. Note 
that data records separate numbers for rooms by tenure if there are enough units of both types of tenure. When there are 0-4 
rental houses only, rms_aggoo_1 = -1 (missing) because no separate data kept by type.*/
/* All occupants*/
gen av_rooms_oo=rms_aggoo_1/ct1_oo if rms_aggoo_1>0 
count if av_rooms_oo!=.
replace av_rooms_oo=rms_occ/ct2_occ if rms_aggoo_1<0 & ct1_oo>4
gen av_rooms_rt=rms_aggrt_1/ct1_rt if rms_aggrt_1>0  
count if av_rooms_rt!=.
replace av_rooms_rt=rms_occ/ct2_occ if rms_aggrt_1<0 & ct1_rt>4
/* Outliers*/
replace av_rooms_oo=av_rooms_oo/10 if av_rooms_oo>10 & av_rooms_oo!=.
replace av_rooms_rt=av_rooms_rt/10 if av_rooms_rt>10 & av_rooms_rt!=.
label var av_rooms_oo "Mean # of rooms, owner-occupied stock"
label var av_rooms_rt "Mean # of rooms, rental stock"

/* Other dependent variables: Percent of the population made up of school age kids, and by age */
#delimit ;
gen numchild=(per_m04+per_m5+per_m6+per_m79+per_m1013+per_m14+per_m15+per_m16+per_m17+per_f04+per_f5+per_f6+per_f79+per_f1013+
per_f14+per_f15+per_f16+per_f17);
gen perund18=(numchild/(per_m+per_f));
gen per04=((per_m04+per_f04)/(per_m+per_f));
gen per59=((per_m5+ per_m6+per_m79+per_f5+ per_f6+per_f79)/(per_m+per_f));
gen per1013=((per_m1013+per_f1013)/(per_m+per_f));
gen per1417=((per_m14+ per_m15+per_m16+per_m17+per_f14+per_f15+ per_f16+per_f17)/(per_m+per_f));
#delimit cr
label variable perund18 "% persons on block 0-17 yrs age"
label variable per04 "% persons on block 0-4 yrs age"
label variable per59 "% persons on block 5-9 yrs age"
label variable per1013 "% persons on block 10-13 yrs age"
label variable per1417 "% persons on block 14-17 yrs age"
drop numchild

/* Neighborhood characteristics */
gen peroo=ct1_oo/ct2_occ
gen pervac=((ct3_tot-ct2_occ)/ct3_tot)
gen pervacrent=(ct_vacrent/ct3_tot)
gen pervacrent01=(ct_vacrent/ct1_rt)
gen pervacsale=(ct_vacsale/ct3_tot)
gen pervacsale01=(ct_vacsale/ct1_oo)
gen persingfam=singfam_3/ct3_tot
gen pernokitch=nokitch_3/ct3_tot
gen pernoplumb=lackplumb_3/ct3_tot
gen perblack=((ct1_rtbl+ct1_oobl)/(ct1_oo+ct1_rt))
gen perblack1=((per_bl_m+per_bl_f)/(per_m+per_f))
gen pop_tot_block=(per_m+per_f)
/* Note: housing counts used for weights are not total number of houses on the block, but are total number of units that 
provided rent or value data*/
rename ct4_ooval house_ownocc 
rename ct5_rtval house_rent
label variable peroo "% occupied units that are owned"
label variable pervac "% all units that are vacant"
label variable pervacrent "% all units that are vacant and for rent"
label variable pervacrent01 "% rental units that are vacant and for rent"
label variable pervacsale "% all units that are vacant and for sale"
label variable pervacsale01 "% sale units that are vacant and for sale"
label variable persingfam "% all units that are single family"
label variable pernokitch "% of all units w/o range, sink or fridge"
label variable pernoplumb "% of all units w/o hot water, flush toilet, bathtub or shower"
label variable perblack "% occupied units w/ black HH head"
label variable perblack1 "% residents on the block who are black"
label var pop_tot_block "# people on block"
/* Tract level summary - % black*/
gen temp=perblack1 if block1==.
sort statefip cnty tract1
quietly by statefip cnty tract1: egen tractperblack1=max(temp)
drop temp
label var tractperblack1 "% residents black, in whole tract"

/* Keep block level data only*/
drop if block1==.
/* Keep unit counts, values/rents, population composition, geographic identifiers*/
keep ct1_oo ct1_rt ct3_tot ct2_occ statefip tract* cnty block1 ct4_ooval ct5_rtval perund18-pop_tot_block av* added house*


/** (2) TIER CODES (ENTERED BY HAND)**/

/* For the pilot sample, collected in April, 2005, I entered the jurisdiction codes and border numbers directly into the 
dataset (below). Thereafter, I entered these variables into the template files used to code the blocks according to distance 
('tiers') from the border.*/
/* Metropolitan area */
gen smsa=4480 if statefip==6
replace smsa=1600 if statefip==17
replace smsa=1120 if statefip==25
replace smsa=2160 if statefip==26
/* Create jurisdiction and border level identifiers */
/* Jurisdiction level: Use tract codes for 1970 and SMSA codes, in case of overlap*/
gen str8 jurcode="bostonma" if tract1==5 & smsa==1120
replace jurcode="brooklma" if tract1==4004 & smsa==1120
replace jurcode="cambrima" if (tract1==3536 | tract1==3537 | tract1==3529 | tract1==3527) & smsa==1120
replace jurcode="somervma" if tract1==3512 & smsa==1120
replace jurcode="oakparil" if (tract1==8121 | tract1==8131) & smsa==1600
replace jurcode="evanstil" if (tract1==8090 | tract1==8102) & smsa==1600
replace jurcode="ciceroil" if (tract1==8135) & smsa==1600
replace jurcode="chicagil" if (tract1==201 | tract1==102 | tract1==2504 | tract1==2506 | tract1==2513) & smsa==1600
replace jurcode="skokieil" if (tract1==8067 | tract1==8071 | tract1==8091 | tract1==8092 | tract1==8096) & smsa==1600
replace jurcode="dearbomi" if (tract1==835) & smsa==2160
replace jurcode="alhambca" if (tract1==480801 | tract1==480802) & smsa==4480
replace jurcode="bellflca" if (tract1==5533 | tract1==554401 | tract1==554402 | tract1==5543) & smsa==4480
replace jurcode="burbanca" if (tract1==3107 | tract1==3114) & smsa==4480
replace jurcode="comptoca" if (tract1==5422) & smsa==4480
replace jurcode="downeyca" if (tract1==5504 | tract1==5518) & smsa==4480
replace jurcode="glendaca" if (tract1==3015 | tract1==3016 | tract1==302101 | tract1==302102) & smsa==4480
replace jurcode="inglewca" if (tract1==600801 | tract1==600802) & smsa==4480
replace jurcode="lakewoca" if (tract1==570001 | tract1==570002 | tract1==5708) & smsa==4480
replace jurcode="pasadeca" if (tract1==4638) & smsa==4480
replace jurcode="redondca" if (tract1==620601 | tract1==620602) & smsa==4480
replace jurcode="santamca" if (tract1==7021) & smsa==4480
replace jurcode="torranca" if (tract1==650901 | tract1==650902 | tract1==6506) & smsa==4480
replace jurcode="norwalca" if (tract1==5503) & smsa==4480
replace jurcode="longbeca" if (tract1==570201 | tract1==570202 | tract1==5704 | tract1==5712) & smsa==4480
#delimit ;
replace jurcode="detroimi" if (tract1==20401 | tract1==20402 | tract1==70702 | tract1==70703 | tract1==30701 | tract1==571 | 
tract1==61201 | tract1==608 | tract1==607) & smsa==2160;
replace jurcode="losangca" if (tract1==1813 | tract1==1861 | tract1==1256 | tract1==1811 | tract1==2011 | tract1==201501 | 
tract1==201502 | tract1==235201 | tract1==235202 | tract1==2379 | tract1==2381 | tract1==293201 | tract1==293202 | 
tract1==2732 | tract1==2733 | tract1==2734) & smsa==4480;
#delimit cr
/* Border number */
/* First code all jurisdictions that are only part of one border contrast*/
gen borderno=9 if jurcode=="alhambca"
replace borderno=3 if jurcode=="bostonma" | jurcode=="brooklma"
replace borderno=4 if jurcode=="cambrima" | jurcode=="somervma"
replace borderno=7 if jurcode=="ciceroil" 
replace borderno=76 if jurcode=="comptoca" 
replace borderno=5 if jurcode=="dearbomi" 
replace borderno=12 if jurcode=="inglewca" 
replace borderno=21 if jurcode=="norwalca" 
replace borderno=14 if jurcode=="pasadeca" 
replace borderno=13 if jurcode=="redondca" 
replace borderno=15 if jurcode=="santamca" 
replace borderno=6 if jurcode=="skokieil" 
/* Then, code jurisdictions that are part of multiple contrasts. Need to specify tract #*/
replace borderno=17 if jurcode=="bellflca" & (tract1==5543) 
replace borderno=19 if jurcode=="bellflca" & (tract1==554401 | tract1==554402)
replace borderno=20 if jurcode=="bellflca" & tract1==5533
replace borderno=8 if jurcode=="burbanca" & tract1==3107
replace borderno=10 if jurcode=="burbanca" & tract1==3114
replace borderno=1 if jurcode=="chicagil" & (tract1==201 | tract1==102)
replace borderno=2 if jurcode=="chicagil" & (tract1==2504 | tract1==2506 | tract1==2513)
replace borderno=1 if jurcode=="evanstil" & (tract1==8102)
replace borderno=6 if jurcode=="evanstil" & (tract1==8090)
replace borderno=20 if jurcode=="downeyca" & (tract1==5518)
replace borderno=21 if jurcode=="downeyca" & (tract1==5504)
replace borderno=5 if jurcode=="detroimi" & (tract1==20401 | tract1==20402)
replace borderno=8 if jurcode=="glendaca" & (tract1==3015 | tract1==3016)
replace borderno=11 if jurcode=="glendaca" & (tract1==302102 | tract1==302101)
replace borderno=19 if jurcode=="lakewoca" & (tract1==570001 | tract1==570002)
replace borderno=18 if jurcode=="lakewoca" & (tract1==5708)
replace borderno=17 if jurcode=="longbeca" & (tract1==570201 | tract1==570202)
replace borderno=76 if jurcode=="longbeca" & tract1==5704
replace borderno=18 if jurcode=="longbeca" & (tract1==5712)
replace borderno=13 if jurcode=="torranca" & (tract1==6505)
replace borderno=16 if jurcode=="torranca" & (tract1==650901 | tract1==650902)
replace borderno=2 if jurcode=="oakparil" & (tract1==8121)
replace borderno=7 if jurcode=="oakparil" & (tract1==8131)
replace borderno=9 if jurcode=="losangca" & (tract1==201501 | tract1==201502 | tract1==2011)
replace borderno=10 if jurcode=="losangca" & (tract1==1256)
replace borderno=11 if jurcode=="losangca" & (tract1==1861 | tract1==1831)
replace borderno=12 if jurcode=="losangca" & (tract1==235201 | tract1==235202 | tract1==2379 | tract1==2381)
replace borderno=14 if jurcode=="losangca" & (tract1==1811)
replace borderno=15 if jurcode=="losangca" & (tract1==2732 | tract1==2733 | tract1==2734)
replace borderno=16 if jurcode=="losangca" & (tract1==293201 | tract1==293202)
sort jurcode tract1 block1
save block_1970_aej.dta, replace

/* APPEND TIER CODES FROM VARIOUS SAMPLES. For the pilot sample, the tiercode file can be merged by jurisdiction codes, which 
I entered directly into the block dataset (above). All other tiercode files must be merged by tract and block.*/
#delimit ;
clear;
insheet using ~/Tract_block/1970/Tier_codes/block_1970_tier01.txt, tab;
gen dataset=1;
sort jurcode tract1 block1;
merge jurcode tract1 block1 using block_1970_aej.dta;
destring tierno, replace;
tab _merge;
drop _merge;
/* Also, there are 10 tracts that are part of two (or, in one case, three) borders. So, these tracts need to 
be expanded, so that the sort will be unique. Also, need to create a variable = 1, 2, 3 indicating the 
pairing represented by each observation. Most tracts will have variable = 1. 10 will have 2 or 3*/
expand 2 if ((statefip==6 & cnty==85 & tract1==5094) | (statefip==17 & cnty==31 & (tract1==8131 | 
tract1==8146 | tract1==8135)) | (statefip==34 & cnty==13 & (tract1==24 | tract1==25)) | (statefip==42 & 
cnty==3 & (tract1==5155 | tract1==5161 | tract1==5605)));
/* To merge with the later tier numbers, need to rename county and sort by state, county, tract and block.*/
rename cnty county;
sort statefip county tract1 block1;
/* Generate the variable 'pairno' that indicates when a tract is part of two borders. If so, tracts receive a code of 1 for 
the first border and 2 for the second border*/
gen pairno=2 if block1==block1[_n-1] & tract1==tract1[_n-1];
replace pairno=1 if pairno==.;
label var pairno "=1 if tract in single border; =2 if involved in multiple borders, for merging";
sort statefip county tract1 block1 pairno;
save block_1970_aej.dta, replace;

/* APPEND TIER CODES (PART 2). For the rest of the sample, I create a separate file called "1970tiers.dta." Only block/tract 
combinations that are in this file will be kept in the sample*/
/* Now append the tiers that Mike and Danika entered in July, 2005. Mikes' are block_1970_tier02.txt and 
Danikas' are block_1970_tier03.txt*/
clear;
insheet using ~/Tract_block/1970/Tier_codes/block_1970_tier_02.txt, tab;
gen dataset=2;
rename tract tract1;
rename block block1;
save 1970tiers.dta,replace;
clear;
insheet using ~/Tract_block/1970/Tier_codes/block_1970_tier_03.txt, tab;
gen dataset=3;
rename tract tract1;
rename block block1;
rename tier tierno;
drop v*;
append using 1970tiers.dta;
save 1970tiers.dta, replace;
clear;
insheet using ~/Tract_block/1970/Tier_codes/nonfulls_1970_tier_04.txt, tab;
/* Fix mistaken borderno for cambridge, boston and brookline in the non-full dataset*/
replace border=4 if jurcode=="cambrima";
replace border=3 if jurcode=="bostonma";
replace border=3 if jurcode=="brooklma";
gen dataset=4;
rename tract tract1;
rename block block1;
rename tier tierno;
rename border borderno;
append using 1970tiers.dta;
save 1970tiers.dta, replace;
/* Append borders collected by Mingjie*/
clear;
insheet using ~/Tract_block/1970/Tier_codes/1970_tiers_newborders.txt, tab;
gen dataset=6;
rename tract tract1;
rename block block1;
gen pairno=1;
append using 1970tiers.dta;
save 1970tiers.dta, replace;
/* Append tiers by Angelina*/
clear;
insheet using ~/Tract_block/1970/Tier_codes/1970_tiers_newborders_01.txt, tab;
gen dataset=7;
rename countyfip county;
rename tract tract1;
rename block block1;
gen pairno=1;
append using 1970tiers.dta;
save 1970tiers.dta, replace;

/** (3) MERGE TIERCODES WITH ELECTRONIC CENSUS BLOCK DATA**/

sort statefip county tract1 block1 pairno;
merge statefip county tract1 block1 pairno using block_1970_aej.dta;
tab _merge;
drop _merge;
#delimit cr
/* Keep only observations with jurisdiction codes - these are part of the data set*/
keep if jurcode!="" 
/* Drop observations in the Detroit borders not in the panel sample*/
drop if borderno==.
/* Append data from the few places that were *not* available electronically - these include, most importantly, Cleveland, 
Cincinnati and Dayton (basically, OH), and a few random places in LA & Denver, oddly enough*/
save block_1970_aej.dta, replace
clear
insheet using block_1970_addendum_data_01.txt, tab
gen dataset=5
/* This data has not been adjusted for CPI yet*/
replace av_value=av_value/.225 if dataset==5
replace av_rent=av_rent/.225 if dataset==5
drop tracks
append using block_1970_aej.dta
/* Create indicator for each wave of data entry*/
label define setname 1 "Leah" 2 "Mike" 3 "Danika" 4 "nonfull" 5 "byhand" 6 "Mingjie" 7 "Angelina"
label values dataset setname
label var dataset "Identifies who entered data (Leah or various RAs)"

/* Fix some county information that is missing or wrong*/
replace county=061 if jurcode=="cincinoh" | jurcode=="wyominoh"
replace county=113 if jurcode=="daytonoh" | jurcode=="ketteroh"
replace county=5 if statefip==8 & (tract1==72 | tract1==73)
/* Convert SMSAs into numerical form*/
gen metaread=4480 if (borderno>=8 & borderno<=21 | borderno==76)
replace metaread=1120 if borderno==3 | borderno==4
replace metaread=1600 if borderno==1 | borderno==2 | borderno==6 | borderno==7
replace metaread=2160 if borderno==5
replace metaread=1120 if smsa=="Boston"
replace metaread=1600 if smsa=="Chicago"
replace metaread=2160 if smsa=="Detroit"
replace metaread=4480 if smsa=="Los Angeles"
replace metaread=1640 if smsa=="Cincinnati"
replace metaread=1680 if smsa=="Cleveland"
replace metaread=2000 if smsa=="Dayton"
replace metaread=2080 if smsa=="Denver"
replace metaread=3760 if smsa=="Kansas City"
replace metaread=5120 if smsa=="Minneapolis-St. Paul"
replace metaread=5600 if smsa=="New York City"
replace metaread=6280 if smsa=="Pittsburgh"
replace metaread=6480 if smsa=="Providence"
replace metaread=1960 if smsa=="Rock Island-Davenport-Moline"
replace metaread=7360 if smsa=="San Francisco"
replace metaread=7400 if smsa=="San Jose"

/* Label extra variables*/
label var tierno "Distance from border"
label var pairno "Tract pair number (>1 if in more than one pair)"
label var pop_tot_block "# residents on block"
label var perund18 "% residents under 18 yrs"
label var pernoplumb "% units with no indoor plumbing"
label var persingfam "% units, detached single family"
label var peroo "% units, owner occupied"
label var ct4_ooval "# units, owner occupied, with value info"
label variable perblack "% occupied units w/ black HH head"
label var av_rooms_oo "Mean # rooms, owner occupied units"
label var av_value "Mean value, owner occupied units"
label var av_rooms_rt "Mean # rooms, rental units"
label var av_rent "Mean rent, rental units"
label var ct2_occ "# units, occupied"
/* A few other variables to fix*/
replace house_ownocc=ct4_ooval if house_ownocc==.
replace house_rent=ct5_rtval if house_rent==.
replace tract1=tract if tract1==. 
replace block1=block if block1==.
/* Drop unnecessary variables*/
drop oddshape flaggq valprm lnvalprm rentprm lnrentprm tracks note v10-v14 gq added


/** (4) MERGE WITH JURISDICTION-LEVEL DATA**/
sort jurcode
merge jurcode using ~/Tract_block/Juris_data/1970/juris_master_1970_new.dta
tab _merge
tab jurcode if _merge==2
/* Replace shblack in North Arlington, NJ with 0.00001 so ln(shblack) will exist*/
replace shblack=.000001 if jurcode=="norarlnj"
/* Drop 7 jurisdictions for which jurisdiction data was collected, but the block-level data was never added 
(e.g., Gary and Hammond, IN, because border quality)*/
drop if _merge==2
drop _merge
drop exp_educ_pc-cetot_pup pered5
/* Label jurisdiction variables*/
label var poptot "# residents in jurisdiction"
label var shfb "% foreign born in jurisdiction"
label var meded "Median yrs education in jurisdiction"
label var peredhs "% residents HS grad in jurisdiction"
label var peredcol "% residents college grad in jurisdiction"
label var famtot "# families in jurisdiction"
label var fammedinc "Median family income in jurisdiction"
label var perpov "% below poverty line in jurisdiction"
label var shblack "% black in jurisdiction"
label var shhisp "% Hispanic in jurisdiction"
label var sheth "% foreign-born or 2nd generation (one/two parents born abroad) in jurisdiction"
label var lnmedinc"ln(median family income), jurisdiction"
/* Generate year variable for merging with 1980 data*/
gen year=1970
sort jurcode
save block_1970_aej.dta, replace
log close

/* This do file prepares the electronic block-level data compiled state-by-state in census1980.do to be used in the analysis. 
The variables in the electronic data have strange names that refer to their table number and line number in the published 
Census volumes. The first step is to rename these variables and then refashion them to be useful*/

capture log close
log using census1980_01.log, replace
set more off
clear
set mem 100m
version 8.0

use census1980.dta

*
*Rename the variable names in census data from table # to variable name
*

gen sumrylvl=SUMRYLVL 
gen statefip=state 
gen tractcd=tract01 
gen tractsuf=tractsuff 
gen cnty=county 
gen tract1=tractcd+tractsuf
gen block1=BLOCK
gen val_agg_4=T40_1
gen val_agg_fs_4=T40_2
gen rent_agg_5=T45_1
gen rent_agg_fr_5=T45_2
gen per_m=T6_1
gen per_f=T6_2
gen per_wh=T7_1
gen per_bl=T7_2
gen per_jap=T7_6
gen per_chi=T7_7
gen per_fil=T7_8
gen per_kor=T7_9
gen per_asind=T7_10
gen per_vie=T7_11
gen per_mex=T8_2
gen per_pue=T8_3
gen per_cub=T8_4
gen per_othspa=T8_5
gen per_m0=T10_1
gen per_m12=T10_2
gen per_m34=T10_3
gen per_m5=T10_4
gen per_m6=T10_5
gen per_m79=T10_6
gen per_m1013=T10_7
gen per_m14=T10_8
gen per_m15=T10_9
gen per_m16=T10_10
gen per_m17=T10_11
gen per_f0=T10_27
gen per_f12=T10_28
gen per_f34=T10_29
gen per_f5=T10_30
gen per_f6=T10_31
gen per_f79=T10_32
gen per_f1013=T10_33
gen per_f14=T10_34
gen per_f15=T10_35
gen per_f16=T10_36
gen per_f17=T10_37
gen per_und5=T12_1
gen per_517=T12_2
gen per_whund5=T12_5
gen per_wh517=T12_6
gen per_blund5=T12_9
gen per_bl517=T12_10
gen ct3_tot=T5_1
gen ct2_occ=T5_2
gen ct_vacrent=T25_2
gen ct_vacsale=T25_1
gen ct_vacother=T25_4
gen ct1_all=T26_1
gen ct1_allwh=T27_1
gen ct1_allbl=T27_2
gen ct1_rt=T26_2
gen ct1_rtwh=T27_6
gen ct1_rtbl=T27_7
gen med_rooms=T31_1
gen rms_agg_ct3=T32_1
gen rms_aggrt_ct1=T32_2
gen val10000_4=T38_1
gen val14999_4=T38_2
gen val19999_4=T38_3
gen val24999_4=T38_4
gen val29999_4=T38_5
gen val34999_4=T38_6
gen val39999_4=T38_7
gen val49999_4=T38_8
gen val79999_4=T38_9
gen val99999_4=T38_10
gen val149999_4=T38_11
gen val199999_4=T38_12
gen val200000_4=T38_13
gen ct4_ooval=T41_1
gen ct4_fsval=T41_2
gen med_value=T39_1
gen rt50_5=T43_1
gen rt99_5=T43_2
gen rt119_5=T43_3
gen rt139_5=T43_4
gen rt149_5=T43_5
gen rt159_5=T43_6
gen rt169_5=T43_7
gen rt199_5=T43_8
gen rt249_5=T43_9
gen rt299_5=T43_10
gen rt399_5=T43_11
gen rt499_5=T43_12
gen rt500_5=T43_13
gen rtnorent_5=T43_14
gen ct5_rtval=T46_1
gen ct5_frval=T46_2
gen med_rent=T44_1
gen allplumb_occ2=T47_3
gen lackplumb_occ2=T47_4
gen allplumb_rt1=T47_5
gen lackplumb_rt1=T47_6
gen singfam_3=T55_1
gen multfam_2to9_3=T55_2
gen multfam_10up_3=T55_3
gen mobhome_3=T55_4
gen ct_vacrtsh=T53_1
gen ct_vacsalesh=T54_1

#delimit;
keep tract sumrylvl statefip tractcd tractsuf
     cnty tract1 block1 val_agg_4 val_agg_fs_4 rent_agg_5 rent_agg_fr_5
     per_m per_f per_wh per_bl per_jap per_chi per_fil per_kor per_asind per_vie per_mex per_pue
     per_cub per_othspa per_m0 per_m12 per_m34 per_m5 per_m6 per_m79 per_m1013 per_m14 per_m15
     per_m16 per_m17 per_f0 per_f12 per_f34 per_f5 per_f6 per_f79 per_f1013 per_f14 per_f15 per_f16
     per_f17 per_und5 per_517 per_whund5 per_wh517 per_blund5 per_bl517 ct3_tot ct2_occ ct_vacrent
     ct_vacsale ct_vacother ct1_all ct1_allwh ct1_allbl ct1_rt ct1_rtwh ct1_rtbl med_rooms rms_agg_ct3
     rms_aggrt_ct1 val10000_4 val14999_4 val19999_4 val24999_4 val29999_4 val34999_4 val39999_4
     val49999_4 val79999_4 val99999_4 val149999_4 val199999_4 val200000_4 ct4_ooval ct4_fsval med_value
     rt50_5 rt99_5 rt119_5 rt139_5 rt149_5 rt159_5 rt169_5 rt199_5 rt249_5 rt299_5 rt399_5 rt499_5
     rt500_5 rtnorent_5 ct5_rtval ct5_frval med_rent allplumb_occ2 lackplumb_occ2 allplumb_rt1
     lackplumb_rt1 singfam_3 multfam_2to9_3 multfam_10up_3 mobhome_3 ct_vacrtsh ct_vacsalesh;
#delimit cr


/* Label variables from electronic block file*/
label var statefip "state FIPS code"
label var cnty "county FIPS code"
label var tractcd "tract code, 1980"
label var tractsuf "tract suffix, if app. 1980"
label var tract1 "total tract code, decimal implied"
label var block1 "block #, 1980"
label variable val_agg_4 "total aggregate value, own occ housing (use ct4 as denom)"
label variable val_agg_fs_4 "total aggregate value, vacant for sale only (use ct4 as denom)"
label variable rent_agg_5 "total aggregate rent, rental housing (use ct5 as denom)"
label variable rent_agg_fr_5 "total aggregate rent, vacant for rent (use ct5 as denom)"
label variable per_m "total # men on block"
label variable per_f "total # women on block"
label variable per_wh "total # white on block"
label variable per_bl "total # black on block"
label variable per_jap "total # japanese on block"
label variable per_chi "total # chinese on block"
label variable per_fil "total # filipino on block"
label variable per_kor "total # korean on block"
label variable per_asind "total # asian idian on block"
label variable per_vie "total # vietnamese on block"
label variable per_mex "total # mexican on block"
label variable per_pue "total # puerto rican on block"
label variable per_cub "total # cuban on block"
label variable per_othspa "total # other spanish on block"
label variable per_m0 "# men, under 1yr age"
label variable per_m12 "# men, 1-2 yrs age"
label variable per_m34 "# men, 3-4 yrs age"
label variable per_m5 "# men, 5 yrs age"
label variable per_m6 "# men, 6 yrs age"
label variable per_m79 "# men, 7-9 yrs age"
label variable per_m1013 "# men, 10-13 yrs age"
label variable per_m14 "# men, 14 yrs age"
label variable per_m15 "# men, 15 yrs age"
label variable per_m16 "# men, 16 yrs age"
label variable per_m17 "# men, 17 yrs age"
label variable per_f0 "# women, under 1yr age"
label variable per_f12 "# women, 1-2 yrs age"
label variable per_f34 "# women, 3-4 yrs age"
label variable per_f5 "# women, 5 yrs age"
label variable per_f6 "# women, 6 yrs age"
label variable per_f79 "# women, 7-9 yrs age"
label variable per_f1013 "# women, 10-13 yrs age"
label variable per_f14 "# women, 14 yrs age"
label variable per_f15 "# women, 15 yrs age"
label variable per_f16 "# women, 16 yrs age"
label variable per_f17 "# women, 17 yrs age"
label variable per_und5 "total # person, under 5 yrs age"
label variable per_517 "total # person, 5-17 yrs age"
label variable per_whund5 "# white, under 5 yrs age"
label variable per_wh517 "# white, 5-17 yrs age"
label variable per_blund5 "# black, under 5 yrs age"
label variable per_bl517 "# black, 5-17 yrs age"
label variable ct3_tot "total # houses, occ/not on block"
label variable ct2_occ "total # occ houses"
label variable ct_vacrent "# vacant houses, for rent"
label variable ct_vacsale "# vacant houses, for sale"
label variable ct_vacother "# vacant houses, other vacants"
label variable ct1_all "# houses, all"
label variable ct1_allwh "# houses, all by white"
label variable ct1_allbl "# houses, all by black"
label variable ct1_rt "# houses, rental"
label variable ct1_rtwh "# houses, rental by white"
label variable ct1_rtbl "# houses, rental by black"
label variable med_rooms "median rooms"
label variable rms_agg_ct3 "total aggregate rooms, all(use ct3 as denom)"
label variable rms_aggrt_ct1 "total aggregate rooms, rental (use ct1 as denom)"
label variable val10000_4 "# own occ val <10,000 (use ct4 as denom)"
label variable val14999_4 "# own occ val 10,000-14,999 (use ct4 as denom)"
label variable val19999_4 "# own occ val 15,000-19,999 (use ct4 as denom)"
label variable val24999_4 "# own occ val 20,000-24,999 (use ct4 as denom)"
label variable val29999_4 "# own occ val 25,000-29,999 (use ct4 as denom)"
label variable val34999_4 "# own occ val 30,000-34,999 (use ct4 as denom)"
label variable val39999_4 "# own occ val 35,000-39,999 (use ct4 as denom)"
label variable val49999_4 "# own occ val 40,000-49,999 (use ct4 as denom)"
label variable val79999_4 "# own occ val 50,000-79,999 (use ct4 as denom)"
label variable val99999_4 "# own occ val 80,000-99,999 (use ct4 as denom)"
label variable val149999_4 "# own occ val 100,000-149,999 (use ct4 as denom)"
label variable val199999_4 "# own occ val 150,000-199,999 (use ct4 as denom)"
label variable val200000_4 "# own occ val >=200,000 (use ct4 as denom)"
label variable ct4_ooval "# own occ, tabulated value"
label variable ct4_fsval "# for sale only, tabulated value"
label variable rt50_5 "# rental, rent<50 (use ct5 as denom)"
label variable rt99_5 "# rental, rent 50-99 (use ct5 as denom)"
label variable rt119_5 "# rental, rent 100-119 (use ct5 as denom)"
label variable rt139_5 "# rental, rent 120-139 (use ct5 as denom)"
label variable rt149_5 "# rental, rent 140-149 (use ct5 as denom)"
label variable rt159_5 "# rental, rent 150-159 (use ct5 as denom)"
label variable rt169_5 "# rental, rent 160-169 (use ct5 as denom)"
label variable rt199_5 "# rental, rent 170-199 (use ct5 as denom)"
label variable rt249_5 "# rental, rent 200-249 (use ct5 as denom)"
label variable rt299_5 "# rental, rent 250-299 (use ct5 as denom)"
label variable rt399_5 "# rental, rent 300-399 (use ct5 as denom)"
label variable rt499_5 "# rental, rent 400-499 (use ct5 as denom)"
label variable rt500_5 "# rental, rent>=500 (use ct5 as denom)"
label variable rtnorent_5 "# rental, no cash rent (use ct5 as denom)"
label variable ct5_rtval "# rental, tabulated rent"
label variable ct5_frval "# rental - vacant for rent, tabulated rent"
label variable med_rent "Meidan rent"
label variable allplumb_occ2 "# occ units, all plumbing fac"
label variable lackplumb_occ2 "# occ units, lack plumbing fac"
label variable allplumb_rt1 "# rental units, all plumbing fac"
label variable lackplumb_rt1 "# rental units, lack plumbing fac"
label variable singfam_3 "# single family (use ct3 as denom)"
label variable multfam_2to9_3 "# units, 2-9 (use ct3 as denom)"
label variable multfam_10up_3 "# units, >=10 (use ct3 as denom)"
label variable mobhome_3 "# mobile home or trailer (use ct3 as denom)"
label variable ct_vacrtsh "# vacant, for rent, >2 mo"
label variable ct_vacsalesh "# vacant, for sale, >6 mo"

/* Dependent Variable = LN(MEAN VALUES/RENT) 
Note that aggregate owner-occupied value must be multiplied by 250 to get true value. Value and rents recorded in aggregate.
Need to divide by number of units for which there is non-missing value/rent information for relevant tenure status (count 4, 
count5) for per-unit figures.*/
gen av_value=((val_agg_4*250)/ct4_ooval)
gen av_rent=rent_agg_5/ct5_rtval
/* CPI: in year 2000 dollars.*/
foreach var of varlist av_value av_rent med_value {
	replace `var'=`var'/.433
}
gen lnav_value=ln(av_value)
gen lnav_rent=ln(av_rent)
replace med_value=. if ct4_ooval<5
gen lnmed_value=ln(med_value)
label var av_value "av value, owner occupied (x250)"
label var av_rent "av rent, rental"
label var lnav_value "ln(av_value) in $2000"
label var lnmed_value "ln(median_value) in $2000"
label var lnav_rent "ln(av_rent) in $2000"

/* Mean number of rooms for each type: divide total number of rooms by number of houses in each tenure category. 
Unlike in 1970, no information for 'owner occupied.' Instead, have aggregate room counts for ALL houses on the block,
regardless of tenure, and then a separate count for RENTAL-OCCUPIED (assuming >=5 rental-occ units).
Two measures:
1. Av_rooms for all units on the block, regardless of occupancy or tenure status. Defined unless fewer than 5 total unist 
(in which case, suppressed).
2. Av_rooms_oth = average rooms for non-rental units. Could be vacant or owner-occupied. Only defined for 6277 blocks 
because must have at least 5 rental units (so can subtract # rooms, otherwise suppressed).
*/ 
gen ct3_oth=(ct3_tot-ct1_rt)
gen av_rooms=rms_agg_ct3/ct3_tot if ct3_tot>=5
gen av_rooms_oth=(rms_agg_ct3-rms_aggrt_ct1)/ct3_oth if ct1_rt>=5 & ct3_oth>=5 & rms_aggrt_ct1!=0
replace med_rooms=. if ct3_tot<5
label var ct3_oth "# of units, non rental occupied (most are owner-occupied)"
label var av_rooms "mean # rooms, all units"
label var av_rooms_oth "mean # rooms, non-rental occupied units"
	
/* Other dependent variables: Percent of the population made up of school age kids, and by age */
gen perund18=(per_und5+per_517/(per_m+per_f))
gen per04=(per_und5/(per_m+per_f))
gen per59=((per_m5+ per_m6+per_m79+per_f5+ per_f6+per_f79)/(per_m+per_f))
gen per1013=((per_m1013+per_f1013)/(per_m+per_f))
gen per1417=((per_m14+ per_m15+per_m16+per_m17+per_f14+per_f15+ per_f16+per_f17)/(per_m+per_f))
label variable perund18 "% persons on block 0-17 yrs age"
label variable per04 "% persons on block 0-4 yrs age"
label variable per59 "% persons on block 5-9 yrs age"
label variable per1013 "% persons on block 10-13 yrs age"
label variable per1417 "% persons on block 14-17 yrs age"
/* Separately - by race*/
gen per04w=per_whund5/per_wh
gen per517w=per_wh517/per_wh
gen per04b=per_blund5/per_bl
gen per517b=per_bl517/per_bl
label var per04w "% whites on block, 0-4 yrs"
label var per517w "% whites on block, 5-17 yrs"
label var per04b "% blacks on block, 0-4 yrs"
label var per517b "% blacks on block, 5-17 yrs"

/* Neighborhood characteristics */
gen peroo=(ct1_all-ct1_rt)/ct1_all
gen perlackplumb=lackplumb_occ2/ct2_occ
label variable peroo "% occupied units that are owned"
label variable perlackplumb "% of all units w/o hot water, flush toilet, bathtub or shower"
gen pervac=((ct3_tot-ct2_occ)/ct3_tot)
gen pervacrent=(ct_vacrent/ct3_tot)
gen pervacrent01=(ct_vacrent/ct1_rt)
gen pervacsale=(ct_vacsale/ct3_tot)
gen pervacsale01=(ct_vacsale/(ct1_all-ct1_rt))
gen persingfam=singfam_3/ct3_tot
gen perblack1=(per_bl/(per_m+per_f))
gen perasian1=((per_jap+per_chi+per_fil+per_kor+per_asind+per_vie)/(per_m+per_f))
gen perhisp1=((per_mex+per_pue+per_cub+per_othspa)/(per_m+per_f))
gen pop_tot_block=(per_m+per_f)
gen denblock=pop_tot_block/ct2_occ
label variable pervac "% all units that are vacant"
label variable pervacrent "% all units that are vacant and for rent"
label variable pervacsale "% all units that are vacant and for sale"
label variable pervacrent01 "% rental units that are vacant and for rent"
label variable pervacsale01 "% all owner units that are vacant and for sale"
label variable persingfam "% all units that are single family"
label variable perblack1 "% residents on the block who are black"
label variable perasian1 "% residents on the block who are asian"
label variable perhisp1 "% residents on the block who are hispanic"
label var pop_tot_block "# people on block"
label var denblock "# of people on block/# occupied houses"

/* Attach tract summary of % black to each block. Note block1==. if observation refers to tract rather than block.*/
gen temp=perblack1 if block1==.
sort statefip cnty tract1
quietly by statefip cnty tract1: egen tractperblack1=max(temp)
label var tractperblack1 "% residents black, in whole tract"
/*Drop tract summaries. Only want block level data*/
drop if block1==.
drop temp
/* Note: housing counts used for weights need to be total number of units that provide rent or value data (not total number 
of houses on the block*/
rename ct4_ooval house_ownocc 
rename ct5_rtval house_rent
sort statefip cnty tract block
* Eventually also keep the distribution data (rents and values)
keep av_value-tractperblack1 med_value med_rooms ct3_tot ct2_occ tract statefip-block1 house_* per_wh517 per_bl517 
save census1980_01.dta, replace

log close


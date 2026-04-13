*****************************************************************************************
* Replication Materials for ÒPrecolonial Legacies and Institutional Congruence in Public Goods Delivery: Evidence from Decentralized West Africa" 
* Author: Martha Wilfahrt
* Journal: World Politics 70(2)
* Version Date: 6 January 2018
*****************************************************************************************

cd "/Users/Martha/Box Sync/Papers/Precolonial Legacies and Institutional Congruence in Public Goods Delivery_WP/WP_Submission/Final Submission/Wilfahrt_WP_2018/Data/"

use VillageData.dta, clear

*****************************************************************************************
*********************************** Table 3 *********************************************
*****************************************************************************************

* Panel A - elections
* M1
logit New_Schools_T1 Congruence_20km_T1 c.Gap_parties2002##c.LnPop2011 Pop_Dens_3km D_School_02_sqrt Perc_CR_Mouride_T1  Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or
* M2
logit New_Schools_T2 Congruence_20km_T2 c.Gap_parties2009##c.LnPop2011 D_School_09_sqrt Perc_CR_Mouride_T2 Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
* M3
logit New_Clinic_T2 Congruence_20km_T2 c.Gap_parties2009##c.LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or

* Panel B - Ethnicity 
* M4
logit New_Schools_T1 Congruence_20km_T1 ELF_Arr_02 LnPop2011 Pop_Dens_3km D_School_02_sqrt Perc_CR_Mouride_T1 Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1  ,robust cluster(CR_2002_num) or
* M5
logit New_Schools_T2 Congruence_20km_T2 ELF_Arr_09 LnPop2011 D_School_09_sqrt Perc_CR_Mouride_T2 Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
* M6
logit New_Clinic_T2 Congruence_20km_T2 ELF_Arr_09 LnPop2011 D_Clinic_09_sqrt  Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 

* Panel C - Murdock Data
* M7
logit New_Schools_T1 Congruence_20km_T1 Murdock_Score LnPop2011 Pop_Dens_3km D_School_02_sqrt Perc_CR_Mouride_T1 Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1  ,robust cluster(CR_2002_num) or
* M8
logit New_Schools_T2 Congruence_20km_T2 Murdock_Score LnPop2011 D_School_09_sqrt Perc_CR_Mouride_T2 Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
* M9
logit New_Clinic_T2 Congruence_20km_T2 Murdock_Score LnPop2011 D_Clinic_09_sqrt  Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 

* Panel D - Regional
* M10
logit New_Schools_T1 Congruence_20km_T1 Ch_Teacher_Student_Ratio_T1 Perc_CR_Mouride_T1 LnPop2011 Pop_Dens_3km D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth Congruence_20km_Regavg_T1 if UrbanCommune_02 ==0 & Touba != 1  ,robust cluster(CR_2002_num) or
* M11
logit New_Schools_T2 Congruence_20km_T2 Avg_CG_Transfers Perc_CR_Mouride_T2 LnPop2011 D_School_09_sqrt  Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth Congruence_20km_Regavg_T2 if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
* M12
logit New_Schools_T2 Congruence_20km_T2 Ch_Teacher_Student_Ratio_T2 Perc_CR_Mouride_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth Congruence_20km_Regavg_T2 if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
* M13
logit New_Clinic_T2 Congruence_20km_T2 Avg_CG_Transfers LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth Congruence_20km_Regavg_T2 if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
 

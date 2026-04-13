*****************************************************************************************
* Replication Materials for ÒPrecolonial Legacies and Institutional Congruence in Public Goods Delivery: Evidence from Decentralized West Africa" 
* Author: Martha Wilfahrt
* Journal: World Politics 70(2)
* Version Date: 6 January 2018
*****************************************************************************************

cd "/Users/Martha/Box Sync/Papers/Precolonial Legacies and Institutional Congruence in Public Goods Delivery_WP/WP_Submission/Final Submission/Wilfahrt_WP_2018/Data/"

use VillageData.dta, clear

************************************************************************************************
*********************************** Table 1 *********************************************
************************************************************************************************

* M1
logit New_Schools_T1 Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km PercVillages_Schools_CR02 if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
* M2
logit New_Schools_T1 Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km  Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
* M3
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
* M4
clogit New_Schools_T1 Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km  c.Latitude##c.Longitude Village_Elevation LnD_waterway if UrbanCommune_02 ==0 & Touba != 1 , group(CR_2002_num) vce(cluster CR_2002_num) or

* M5
logit New_Schools_T2 Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km PercVillages_Schools_CR09 if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
* M6
logit New_Schools_T2 Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
* M7
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
* M8
clogit New_Schools_T2 Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km  c.Latitude##c.Longitude Village_Elevation LnD_waterway if UrbanCommune_09 ==0 & Touba != 1 , group(CR_2009_num) vce(cluster CR_2009_num) or

* M9
logit New_Clinic_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
* M10
logit New_Clinic_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
* M11
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
* M12
clogit New_Clinic_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  c.Latitude##c.Longitude Village_Elevation LnD_waterway if UrbanCommune_09 ==0 & Touba != 1 , group(CR_2009_num) vce(cluster CR_2009_num) or








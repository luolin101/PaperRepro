*****************************************************************************************
* Replication Materials for ÒPrecolonial Legacies and Institutional Congruence in Public Goods Delivery: Evidence from Decentralized West Africa" 
* Author: Martha Wilfahrt
* Journal: World Politics 70(2)
* Version Date: 6 January 2018
*****************************************************************************************

cd "/Users/Martha/Box Sync/Papers/Precolonial Legacies and Institutional Congruence in Public Goods Delivery_WP/WP_Submission/Final Submission/Wilfahrt_WP_2018/Data/"

use VillageData.dta, clear

************************************************************************************************
* TABLE A1. Table 1 Replication; Hierarchical Models
************************************************************************************************

xtmelogit New_Schools_T1 Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km PercVillages_Schools_CR02 Congruence_20km_CRavg_T1 if UrbanCommune_02 ==0 & Touba != 1 || CR_2002_num:, or
xtmelogit New_Schools_T1 Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km  Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth Congruence_20km_CRavg_T1 if UrbanCommune_02 ==0 & Touba != 1 || CR_2002_num:, or
xtmelogit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth Congruence_20km_CRavg_T1 if UrbanCommune_02 ==0 & Touba != 1|| CR_2002_num:, or

xtmelogit New_Schools_T2 Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km PercVillages_Schools_CR09 Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0 & Touba != 1 || CR_2009_num:, or
xtmelogit New_Schools_T2 Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0 & Touba != 1|| CR_2009_num:, or
xtmelogit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0 & Touba != 1 || CR_2009_num:, or

xtmelogit New_Clinic_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0 || CR_2009_num:, or
xtmelogit New_Clinic_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0|| CR_2009_num:, or
xtmelogit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth Congruence_20km_CRavg_T2 if UrbanCommune_09 ==0 || CR_2009_num:, or


************************************************************************************************
* TABLE A2: Table 1 Replication; Alternative Centralization Measures 
************************************************************************************************

* CR_Congruence
logit New_Schools_T1 Congruence_20km_CRavg_T1 Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or 
logit New_Schools_T2 Congruence_20km_CRavg_T2 Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
logit New_Clinic_T2 Congruence_20km_CRavg_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(CR_2009_num) or 

* Dummy
logit New_Schools_T1 Congruent_Dummy_2002 Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or 
logit New_Schools_T2 Congruent_Dummy_2009 Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
logit New_Clinic_T2 Congruent_Dummy_2009 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(CR_2009_num) or 

* index
logit New_Schools_T1 Congruence_Index_20km Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or 
logit New_Schools_T2 Congruence_Index_20km Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
logit New_Clinic_T2 Congruence_Index_20km c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(CR_2009_num) or 

* ANC
logit New_Schools_T1 Centr_DiscountRate_20km Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or 
logit New_Schools_T2 Centr_DiscountRate_20km Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 
logit New_Clinic_T2 Centr_DiscountRate_20km c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(CR_2009_num) or 

* historical founding
logit New_Schools_T1 Perc_CR_1900_T1 Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(Department_02) or 
logit New_Schools_T2 Perc_CR_1900_T2 Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(Department_09) or 
logit New_Clinic_T2 Perc_CR_1900_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(Department_09) or 

logit New_Schools_T1 Perc_CR_1958_T1 Perc_CR_Mouride_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(Department_02) or 
logit New_Schools_T2 Perc_CR_1958_T2 Perc_CR_Mouride_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(Department_09) or 
logit New_Clinic_T2 Perc_CR_1958_T2 PopDens_1900 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 ,robust cluster(Department_09) or 


**************************************************************************************************
* TABLE A3. Table 1 Replication; Increased Buffer Size 
**************************************************************************************************

* Panel A
logit New_Schools_T1 Congruence_25km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1 Congruence_30km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or

logit New_Schools_T2 Congruence_25km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Schools_T2 Congruence_30km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or

logit New_Clinic_T2 Congruence_25km_T1 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_30km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or

* Panel B
logit New_Schools_T1 Congruence_Index_25km LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1 Congruence_Index_30km LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or

logit New_Schools_T2 Congruence_Index_25km LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Schools_T2 Congruence_Index_30km LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or

logit New_Clinic_T2 Congruence_Index_25km LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_Index_30km LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or

* Panel C
logit New_Schools_T1 Congruent_25_Dummy_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1 Congruent_30_Dummy_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or

logit New_Schools_T2 Congruent_25_Dummy_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Schools_T2 Congruent_30_Dummy_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or

logit New_Clinic_T2 Congruent_25_Dummy_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruent_30_Dummy_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) or

****************************************************************************************************
* TABLE A4. Table 1 Replication; Region by Region Deletion 
****************************************************************************************************

* no diourbel
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "diourbel", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "diourbel" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "diourbel" , robust cluster(CR_2009_num) or
* no fatick
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "fatick", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "fatick" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "fatick" , robust cluster(CR_2009_num) or
* no kaffrine
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "kaffrine" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "kaffrine" , robust cluster(CR_2009_num) or
* no kaolack
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "kaolack", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "kaolack" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "kaolack" , robust cluster(CR_2009_num) or
* no kedougou
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "kedougou" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "kedougou" , robust cluster(CR_2009_num) or
* no Kolda
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "kolda", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "kolda" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "kolda" , robust cluster(CR_2009_num) or
* no louga
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "louga", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "louga" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "louga" , robust cluster(CR_2009_num) or
* no matam
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "matam", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "matam" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "matam" , robust cluster(CR_2009_num) or
* no stlouis
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "saint-louis", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "saint-louis" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "saint-louis" , robust cluster(CR_2009_num) or
* no sedhiou
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "sedhiou" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "sedhiou" , robust cluster(CR_2009_num) or
* no tamba
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "tambacounda", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "tambacounda" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "tambacounda" , robust cluster(CR_2009_num) or
* no thies
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "thies", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "thies" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "thies" , robust cluster(CR_2009_num) or
* no zig
logit New_Schools_T1 Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 & Region_02 != "ziguinchor", robust cluster(CR_2002_num) or
logit New_Schools_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km  Perc_CR_Mouride_T2 Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "ziguinchor" , robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt N_New_Clinics_CR_T2 Pop_Dens_5km  PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Region_09 != "ziguinchor" , robust cluster(CR_2009_num) or


****************************************************************************************************
* TABLE A5. Table 3 Replication; Alternative Electoral Variables 
****************************************************************************************************

logit New_Schools_T1 Congruence_20km_T1 c.WinningPercentVotes_02##c.LnPop2011 Pop_Dens_3km D_School_02_sqrt Perc_CR_Mouride_T1  Perc_CR_Mouride_T1 Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or
logit New_Schools_T1 Congruence_20km_T1 Natl_Coalition_CR02 LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1 D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 ,robust cluster(CR_2002_num) or

logit New_Schools_T2 Congruence_20km_T2 c.WinningPercentVotes_09##c.LnPop2011 D_School_09_sqrt  Perc_CR_Mouride_T2 Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
logit New_Schools_T2 Congruence_20km_T2 Natl_Coalition_CR09 LnPop2011 D_School_09_sqrt  Perc_CR_Mouride_T2 Pop_Dens_3km Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 

logit New_Clinic_T2 Congruence_20km_T2 c.WinningPercentVotes_09##c.LnPop2011 D_Clinic_09_sqrt  Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or
logit New_Clinic_T2 Congruence_20km_T2 Natl_Coalition_CR09 LnPop2011 D_Clinic_09_sqrt  Pop_Dens_5km PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1 ,robust cluster(CR_2009_num) or 


****************************************************************************************************
* TABLE A6. Table 1 Replication; Any New Social Service Access (Health & Primary Combined), 2009-12
****************************************************************************************************

logit New_SocService_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt D_School_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 PercVillages_Schools_CR09 if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_SocService_T2 Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt D_School_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_SocServ_Built PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
logit New_SocService_T2 Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt D_School_09_sqrt Pop_Dens_5km  N_SocServ_Built PercVillages_Schools_CR09 PercVillages_Clinics_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
clogit New_SocService_T2 Congruence_20km_T2 Pop_Dens_5km LnPop2011 D_School_09_sqrt D_Clinic_09_sqrt  c.Latitude##c.Longitude Village_Elevation LnD_waterway if UrbanCommune_09 ==0, group(CR_2009_num) vce(cluster CR_2009_num) or

****************************************************************************************************
* TABLE A7. Table 1 Replication; Reduced Radius of 'Access' Definition 
****************************************************************************************************

*2km
logit New_Schools_T1_2km Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1_2km Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1_2km Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1, robust cluster(CR_2002_num) or

logit New_Schools_T2_2km Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km  if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Schools_T2_2km Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
logit New_Schools_T2_2km Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or

*1km
logit New_Schools_T1_1km Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1_1km Congruence_20km_T1 LnPop2011 D_School_02_sqrt Pop_Dens_3km Perc_CR_Mouride_T1  Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) or
logit New_Schools_T1_1km Congruence_20km_T1 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 Pop_Dens_3km Perc_CR_Mouride_T1  D_School_02_sqrt Student_Attendance_02_CR N_New_Schools_CR_T1 PercVillages_Schools_CR02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1, robust cluster(CR_2002_num) or

logit New_Schools_T2_1km Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km  if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Schools_T2_1km Congruence_20km_T2 LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
logit New_Schools_T2_1km Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_School_09_sqrt Pop_Dens_3km Perc_CR_Mouride_T2  Student_Attendance_09_CR N_New_Schools_CR_T2 PercVillages_Schools_CR09 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or

*3km
logit New_Clinic_T2_3k Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Clinic_T2_3k Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
logit New_Clinic_T2_3k Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or

logit New_Clinic_T2_1k Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km PercVillages_Clinics_CR09 if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num) or
logit New_Clinic_T2_1k Congruence_20km_T2 LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or
logit New_Clinic_T2_1k Congruence_20km_T2 c.Latitude##c.Longitude Village_Elevation LnD_waterway LL_Rainforest_grassland Sahel_Grassland_Bush LnPop2011 D_Clinic_09_sqrt Pop_Dens_5km  PercVillages_Clinics_CR09 N_New_Clinics_CR_T2 Regional_Wealth if UrbanCommune_09 ==0 & Touba != 1, robust cluster(CR_2009_num) or

****************************************************************************************************
* TABLE A8. Table 1 Replication; New Classroom Construction 
****************************************************************************************************

nbreg New_Classrooms_T1 Congruence_20km_T1 LnPop2011 Pop_Dens_3km Student_Class_02 if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) irr
nbreg New_Classrooms_T1 Congruence_20km_T1 LnPop2011 Pop_Dens_3km  Student_Attendance_02_CR Perc_CR_Mouride_T1 Student_Class_02 Regional_Wealth if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num) irr
nbreg New_Classrooms_T1 Congruence_20km_T2 LnPop2011 Student_Class_02 Pop_Dens_3km  i. CR_2002_num if UrbanCommune_02 == 0 & Touba != 1 , robust cluster(CR_2002_num) irr

nbreg New_Classrooms_T2 Congruence_20km_T2 LnPop2011 Student_Class_09 Pop_Dens_3km if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) irr
nbreg New_Classrooms_T2 Congruence_20km_T2 LnPop2011 Student_Class_09 Pop_Dens_3km  Student_Attendance_09_CR Regional_Wealth if UrbanCommune_09 ==0 , robust cluster(CR_2009_num) irr
nbreg New_Classrooms_T2 Congruence_20km_T2 LnPop2011 Student_Class_09 Pop_Dens_3km  i. CR_2009_num if UrbanCommune_09 == 0 & Touba != 1 , robust cluster(CR_2009_num) irr

****************************************************************************************************
* TABLE A9. Assessment of bias in estimated effect of institutional congruence from unobservables; Oster's coeffecient stability approach
****************************************************************************************************
findit psacalc

reg New_Schools_T1 Congruence_20km_T1 D_School_02_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_02 ==0 & Touba != 1, robust cluster(CR_2002_num)
psacalc beta Congruence_20km_T1, rmax(.237) 
psacalc beta Congruence_20km_T1, rmax(1) 

reg New_Schools_T1 Congruence_20km_T1 N_New_Schools_CR_T1 Pop_Dens_3km LnPop2011 D_School_02_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_02 ==0 & Touba != 1 , robust cluster(CR_2002_num)
psacalc beta Congruence_20km_T1, rmax(.334)
psacalc beta Congruence_20km_T1, rmax(1) 

reg New_Schools_T2 Congruence_20km_T2 D_School_09_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num)
psacalc beta Congruence_20km_T2, rmax(.166) 
psacalc beta Congruence_20km_T2, rmax(1) 

reg New_Schools_T2 Congruence_20km_T2 N_New_Schools_CR_T2 Pop_Dens_3km LnPop2011 D_School_09_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_09 ==0 & Touba != 1 , robust cluster(CR_2009_num)
psacalc beta Congruence_20km_T2, rmax(.247) 
psacalc beta Congruence_20km_T2, rmax(1) 

reg New_Clinic_T2 Congruence_20km_T2 D_Clinic_09_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_09 ==0 , robust cluster(CR_2009_num)
psacalc beta Congruence_20km_T2, rmax(.152) 
psacalc beta Congruence_20km_T2, rmax(1) 

reg New_Clinic_T2 Congruence_20km_T2 N_New_Clinics_CR_T2 Pop_Dens_5km LnPop2011 D_Clinic_09_sqrt c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush if UrbanCommune_09 ==0, robust cluster(CR_2009_num)
psacalc beta Congruence_20km_T2, rmax(0.351) 
psacalc beta Congruence_20km_T2, rmax(1) 

****************************************************************************************************
* TABLE A10. Placebo Test: Central State Provided Services 
****************************************************************************************************

use PlaceboTests.dta, clear

logit New_HighSchool Congruence_20km_T1 LnPop2011 Pop_Dens_5km if Pop2011_Communes > 1000 & UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or
logit New_HighSchool Congruence_20km_T1 Perc_CR_Mouride_T1 LnPop2011 Pop_Dens_5km Perc_VillSchools_09_02_Dept Student_Attendance_02_CR N_New_Schools_CR_T1 Regional_Wealth if Pop2011_Communes > 1000 & UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or

logit New_Electricity Congruence_20km_T1 Electricity_00 ElectricGrid_5km_00 LnPop2011 if UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or
logit New_Electricity Congruence_20km_T1 Electricity_00 ElectricGrid_5km_00 LnPop2011 Regional_Wealth if UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or

logit New_Improved_Road Congruence_20km_T1 Improved_Road_00 LnPop2011 if UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or
logit New_Improved_Road Congruence_20km_T1 Improved_Road_00 LnPop2011 Regional_Wealth Dept_RoadDensity_00 if UrbanCommune_02 != 1 , robust cluster(CR_2002_num) or

****************************************************************************************************
* TABLE A11. Table 2 Replication; Location-Allocation Modeling, Alternative Explanations 
****************************************************************************************************

use LocAllocT1.dta, clear

reg PopDIFF_MaxCov_T1 GapParties_CR02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 , robust cluster(Region_02_Num)
reg PopDIFF_MaxAttd_T1 GapParties_CR02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 , robust cluster(Region_02_Num)

reg PopDIFF_MaxCov_T1 Natl_Coalition_CR02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1, robust cluster(Region_02_Num)
reg PopDIFF_MaxAttd_T1 Natl_Coalition_CR02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1, robust cluster(Region_02_Num)

reg PopDIFF_MaxCov_T1 ELF_Arr_02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 , robust cluster(Region_02_Num)
reg PopDIFF_MaxAttd_T1 ELF_Arr_02 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1, robust cluster(Region_02_Num)


use LocAllocT2.dta, clear

* education
reg PopDIFF_MaxCov_T2 GapParties_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)
reg PopDIFF_MaxAttd_T2 GapParties_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)

reg PopDIFF_MaxCov_T2 Natl_Coalition_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)
reg PopDIFF_MaxAttd_T2 Natl_Coalition_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)

reg PopDIFF_MaxCov_T2 ELF_Arr_09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)
reg PopDIFF_MaxAttd_T2 ELF_Arr_09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)

reg PopDIFF_MaxCov_T2 Avg_CG_Transfers Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)
reg PopDIFF_MaxAttd_T2 Avg_CG_Transfers Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2, robust cluster(Reg_09_num)


* health
reg PopDIFF_Health_MaxCov_T2 GapParties_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)
reg PopDIFF_Health_MaxAttd_T2 GapParties_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)

reg PopDIFF_Health_MaxCov_T2 Natl_Coalition_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)
reg PopDIFF_Health_MaxAttd_T2 Natl_Coalition_CR09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)

reg PopDIFF_Health_MaxCov_T2 Avg_CG_Transfers Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)
reg PopDIFF_Health_MaxAttd_T2 Avg_CG_Transfers Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)

reg PopDIFF_Health_MaxCov_T2 ELF_Arr_09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 LnPop2011_CR09 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)
reg PopDIFF_Health_MaxAttd_T2 ELF_Arr_09 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 , robust cluster(Reg_09_num)

****************************************************************************************************
* TABLE A12. Table 3 Replication; Location-Allocation Modeling, Coefficient Stability Test 
****************************************************************************************************

use LocAllocT1.dta, clear

reg PopDIFF_MaxCov_T1 Congruence_20km_CRavg_T1 N_New_Schools_CR_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T1, rmax(.262) 
psacalc beta Congruence_20km_CRavg_T1, rmax(1) 
reg PopDIFF_MaxAttd_T1 Congruence_20km_CRavg_T1 N_New_Schools_CR_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T1, rmax(.145) 
psacalc beta Congruence_20km_CRavg_T1, rmax(1) 

reg PopDIFF_MaxCov_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T1, rmax(.411) 
psacalc beta Congruence_20km_CRavg_T1, rmax(1) 
reg PopDIFF_MaxAttd_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone 
psacalc beta Congruence_20km_CRavg_T1, rmax(.321) 
psacalc beta Congruence_20km_CRavg_T1, rmax(1) 


use LocAllocT2.dta, clear

* education
reg PopDIFF_MaxCov_T2 Congruence_20km_CRavg_T2 N_New_Schools_CR_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T2, rmax(.121) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 
reg PopDIFF_MaxAttd_T2 Congruence_20km_CRavg_T2 N_New_Schools_CR_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T2, rmax(.717) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 

reg PopDIFF_MaxCov_T2 Congruence_20km_CRavg_T2 LnPop2011_CR09 N_New_Schools_CR_T2 Perc_CR_Mouride_T2 PercVillages_Schools_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T2, rmax(.233) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 
reg PopDIFF_MaxAttd_T2 Congruence_20km_CRavg_T2 LnPop2011_CR09 N_New_Schools_CR_T2 Perc_CR_Mouride_T2 PercVillages_Schools_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone 
psacalc beta Congruence_20km_CRavg_T2, rmax(.87) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 

* health
reg PopDIFF_Health_MaxCov_T2 Congruence_20km_CRavg_T2 N_New_Clinics_CR_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone 
psacalc beta Congruence_20km_CRavg_T2, rmax(.183) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 
reg PopDIFF_Health_MaxAttd_T2 Congruence_20km_CRavg_T2 N_New_Clinics_CR_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone 
psacalc beta Congruence_20km_CRavg_T2, rmax(.389) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 

reg PopDIFF_Health_MaxCov_T2 Congruence_20km_CRavg_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone 
psacalc beta Congruence_20km_CRavg_T2, rmax(.354) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 
reg PopDIFF_Health_MaxAttd_T2 Congruence_20km_CRavg_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone
psacalc beta Congruence_20km_CRavg_T2, rmax(.528) 
psacalc beta Congruence_20km_CRavg_T2, rmax(1) 


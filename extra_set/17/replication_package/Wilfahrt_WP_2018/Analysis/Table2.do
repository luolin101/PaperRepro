*****************************************************************************************
* Replication Materials for ÒPrecolonial Legacies and Institutional Congruence in Public Goods Delivery: Evidence from Decentralized West Africa" 
* Author: Martha Wilfahrt
* Journal: World Politics 70(2)
* Version Date: 6 January 2018
*****************************************************************************************

cd "/Users/Martha/Box Sync/Papers/Precolonial Legacies and Institutional Congruence in Public Goods Delivery_WP/WP_Submission/Final Submission/Wilfahrt_WP_2018/Data/"

****************************************************************************************************
*********** TABLE 2. Effect of Institutional Congruence on Location-Allocation Choice **************
****************************************************************************************************

* Panel A - Maximize Attendance Models

use LocAllocT1.dta, clear
* M1
reg PopDIFF_MaxAttd_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 , robust cluster(Region_02_Num)
* M2
reg PopDIFF_MaxAttd_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone , robust cluster(Region_02_Num)

use LocAllocT2.dta, clear
* M3
reg PopDIFF_MaxAttd_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09  N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2 , robust cluster(Reg_09_num)
* M4
reg PopDIFF_MaxAttd_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09  N_New_Schools_CR_T2 PercVillages_Schools_CR09 Perc_CR_Mouride_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone , robust cluster(Reg_09_num)
* M5
reg PopDIFF_Health_MaxAttd_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09, robust cluster(Reg_09_num)
* M6
reg PopDIFF_Health_MaxAttd_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone, robust cluster(Reg_09_num)


* Panel B - Maximize Coverage Models

use LocAllocT1.dta
* M7
reg PopDIFF_MaxCov_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 , robust cluster(Region_02_Num)
* M8
reg PopDIFF_MaxCov_T1 Congruence_20km_CRavg_T1 LnPop2011_CR02 CR_PopDensity_T1 N_New_Schools_CR_T1 PercVillages_Schools_CR02 Perc_CR_Mouride_T1 Avg_lnD_waterway Avg_Elevation Ferlo_Zone , robust cluster(Region_02_Num)

use LocAllocT2.dta, clear
* M9
reg PopDIFF_MaxCov_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09  N_New_Schools_CR_T2 PercVillages_Schools_CR09  Perc_CR_Mouride_T2 , robust cluster(Reg_09_num)
* M10
reg PopDIFF_MaxCov_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09  N_New_Schools_CR_T2 PercVillages_Schools_CR09  Perc_CR_Mouride_T2 Avg_lnD_waterway Avg_Elevation Ferlo_Zone , robust cluster(Reg_09_num)
* M11
reg PopDIFF_Health_MaxCov_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09, robust cluster(Reg_09_num)
* M12
reg PopDIFF_Health_MaxCov_T2 Congruence_20km_CRavg_T2 CR_PopDensity_T2 LnPop2011_CR09 N_New_Clinics_CR_T2 PercVillages_Clinics_CR09 Avg_lnD_waterway Avg_Elevation Ferlo_Zone, robust cluster(Reg_09_num)

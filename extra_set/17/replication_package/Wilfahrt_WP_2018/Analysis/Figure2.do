*****************************************************************************************
* Replication Materials for ÒPrecolonial Legacies and Institutional Congruence in Public Goods Delivery: Evidence from Decentralized West Africa" 
* Author: Martha Wilfahrt
* Journal: World Politics 70(2)
* Version Date: 6 January 2018
*****************************************************************************************

cd "/Users/Martha/Box Sync/Papers/Precolonial Legacies and Institutional Congruence in Public Goods Delivery_WP/WP_Submission/Final Submission/Wilfahrt_WP_2018/Data/"

use VillageData.dta, clear

******************************************************************************************
**************************************** Figure 2 ****************************************
******************************************************************************************

tabulate Region_09, gen(Region_09_)

gen Std_Congruence_20km = Congruence_20km/.4402202

logit New_SocService_1912 Std_Congruence_20km LnD_SocService_1902_km c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_1902 ==0 & Touba != 1 & Village_1900 == 1 & Region_02 != "dakar", vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans

logit New_SocService_1932 Std_Congruence_20km LnD_SocService_1912_km LnPop_1958 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush  Perc_CR_Mouride_T1 Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_1932 ==0 & Touba != 1 & Village_1958 == 1 & Region_02 != "dakar", vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans

logit New_SocService_1952 Std_Congruence_20km LnD_SocService_1932_km LnPop_1958 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush  Perc_CR_Mouride_T1 Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_1952 ==0 & Touba != 1 & Village_1958 == 1 & Region_02 != "dakar", vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans

logit New_SocService_1972 Std_Congruence_20km LnD_SocService_1952_km LnPop_1958 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush  Perc_CR_Mouride_T1 Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_1972 ==0 & Touba != 1 & Region_02 != "dakar",vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans

logit New_SocService_2002 Std_Congruence_20km LnD_SocService_1972_km LnPop2011 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush  Perc_CR_Mouride_T1 Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_09 ==0 & Touba != 1 & Region_02 != "dakar", vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans

logit New_SocService_2012 Std_Congruence_20km LnD_SocService_2002_km LnPop2011 c.Latitude##c.Longitude Village_Elevation LnD_waterway Mangrove LL_Rainforest_grassland Sahel_Grassland_Bush Perc_CR_Mouride_T2 Region_09_1 Region_09_2 Region_09_3 Region_09_4 Region_09_5 Region_09_6 Region_09_7 Region_09_8 Region_09_9 Region_09_10 Region_09_11 Region_09_12 Region_09_13 Region_09_14 if UrbanCommune_09 ==0 & Touba != 1 & Region_09 != "dakar", vce(cluster Region_09) or
margins, dydx(Std_Congruence_20km) atmeans


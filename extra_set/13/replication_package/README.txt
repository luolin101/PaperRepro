#####################################################################################################################################################
#####################################################################################################################################################
###################	Replication Instructions For: 										#####################
###################	MAKING BUREAUCRACY WORK: PATRONAGE NETWORKS, PERFORMANCE INCENTIVES, AND ECONOMIC DEVELOPMENT IN CHINA. #####################
###################	AMERICAN JOURNAL OF POLITICAL SCIENCE 									#####################
#####################################################################################################################################################
#####################################################################################################################################################

For questions and information, please contact Junyan Jiang <junyanjiang@cuhk.edu.hk> 
Last Updated: July 18, 2018

###########################
###### IMPORTANT NOTE #####
###########################
# Please download all data IN their ORIGINAL FORMATS for replication codes to work. 
# The analysis is performed under Stata 14.2 SE and R 3.4.4. The operating system is Windows 10 Home 64-bit x86_64. 
# Variable names and their sources are described in the codebook (pdf file).



########################################################################################
########### REPLICATING ALL RESULTS IN MAIN TEXT AND ONLINE APPENDIX  ##################
########################################################################################

1) Run "DO14_main_analyses.do" to replicate all regression results except for Figure 2 and Tables A.1, A.2, and A.18. 
2) Run "DO14_validation.do" to replicate Tables A.1 and A.2.
3) Run "DO14_performance_and_promotion.do" to replicate Table A.18.
4) Run "(RCODE)_visualization.R" to replicate Figure 2 and Figure A.3. 



##############################################################################################################
#### ADDITIONAL INTRSUCTIONS ON HOW TO RECONSTRUCT ANALYSIS DATASETS FROM THE ORIGINAL CPED DATABASE #########
##############################################################################################################

## For those who have a working knowledge about Chinese politics and are interested in learning more about the CPED database, the following procedures will enable you to reconstruct the analysis datasets from the original CPED database. 
## To run the following code, you need to have simplified Chinese langugage installed in your computer system

A) To construct the city-panel dataset used in the main analysis, users need to run "(RCODE)_produce_citypanel_base.R". The script will produce "citypanel_base.dta", which contains information about city and provincial leaders, organized in a city-panel format. "citypanel_base.dta" is the dataset used in "DO14_main_analyses.do".

B) To construct the person-year dataset used in the validation analysis, users need to run "(RCODE)_produce_validation_data.R". This script will produce "validation_data.dta", which contains observations oganized in person-year format. "validation_data.dta" is the main dataset used in "DO14_validation.do".

C) To construct the dataset used in the performance-promotion analysis, users need to run "(RCODE)_performance_to_promotion.R". This script will produce "performance_and_promotion.dta", which contains cumulative performance for city leaders that appeared in the city panel. "performance_and_promotion.dta" is the main dataset used in "DO14_performance_and_promotion.do".

# NOTE: The above procedures make extensive use of two files exported from the CPED: "fullbio1106.csv" and "base1106.csv". "fullbio1106" is the file that contains officials' full career biographies up to June 2015. "base1106.csv" is the file that contains officials' key demographic information, such as gender, ethnicity, date of birth, etc, as well as details of the disciplinary sanctions they receive (if any). Both files are encoded in GB2312.



############################################################################
########################### LIST OF FILES ##################################
############################################################################

---- MAIN ANALYSIS DATASETS (IN STATA FORMAT) ---
<citypanel_base.dta>			City-year panel data containing information about city leaders
<econ_panel.dta>			Data containing economic covariates, to be merged with citypanel_base.dta
<validation_data.dta>			Data for conducting the validation tests
<performance_and_promotion.dta>		Data for conducting the analysis on performance-promotion link


---- CSV Files ----
<base1106.csv>				CPED data for officials' demographic attributes
<fullbio1106.csv>			CPED data for officials' career biographies
<cityyear_structure.csv> 		City-year panel in which leader information is filled
<para2_overall.csv>			Estimates for producing Figure 2 (GDP)
<para2_2nd.csv>				Estimates for producing Figure 2 (manufacturing GDP)
<pvmat.csv>				A dataset that provides provincial-level information


---- DO Files ----
<DO14_main_analyses.do>			Do file for the main analysis	
<DO14_process_before_main.do>		Do file that needs to be run before running the main analysis	
<DO14_validation.do>			Do file for validation analyses	
<DO14_performance_and_promotion.do>	Do file for performance-promotion analysis

---- R CODES ----
<(RCODE)_produce_citypanel_base.R>	R code for producing citypanel_base.csv
<(RCODE)_produce_validation_data.R>	R code for producing validation_data.csv
<(RCODE)_performance_to_promotion.R>	R code for producing performance_and_promotion.csv
<(RCODE)_visualization.R>		R code for visualizing data (Figure 2 and Figure A.3)
<(FUN) cleanup.R>			R functions for cleaning up CPED
<(FUN) corefunctions.R>  		R functions for detecting promotion-based and overlap-based connection 
<(FUN)_datatool.R>			R functions for data preprocessing

---- Others ----
<Codebook.pdf>				Codebook
<expmat.ado>				.ado file for exporting regression/margin estimates in csv format
<GWR_topic_keywords.xlsx>		Top keywords for LDA Topics from Government Work Report
<(WKSPACE) data_for_validation.RData>	R workspace output from running (RCODE)_produce_validation_data.R
<README.txt>				Readme
<citypanel_forR.dta>			Data for calculating cumulative performance for performance-promotion analysis. Extracted from the main panel dataset
<distribution.dta>			Data on distribution of city secretaries' and mayors' connections over time


 
  
 
 

  
  
  
  
  
 
  




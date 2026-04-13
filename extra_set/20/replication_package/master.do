*Replication Code for "When the Money Stops Revision"

********************************************************************************
********************************************************************************

*Download the LiK Data - Currently under restricted access* 
*https://datasets.iza.org//dataset/124/life-in-kyrgyzstan-panel-study-2013

*In "data201" rename file individial "individual"* 
*Set the directory, and extract each the individual datafiles described in the 
* merge-recode-20YY.do files. 

* In order to run the replication code make that the xtivreg2 package is installed in STATA
* If not, run "ssc install xtivreg2"
********************************************************************************
********************************************************************************

*STEP 1
*Recode all the raw data files

*cd ""*

clear
quietly run merge-recode-2010.do
quietly run merge-recode-2011.do
quietly run merge-recode-2012.do
quietly run merge-recode-2013.do

********************************************************************************
********************************************************************************
*STEP 2
*Append all the year files together

clear
quietly run Merging.do

********************************************************************************
********************************************************************************

********************************************************************************
********************************************************************************
*STEP 3
*Recode the data and prepare for analysis 

clear
quietly run Recoding_APSR_LiK_Revised.do

********************************************************************************
********************************************************************************
*STEP 4
*Run the analysis  

clear
run ReplicationCode_APSR_LiK_Revised.do


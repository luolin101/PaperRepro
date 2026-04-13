  *************************************************************************
  *  NAME: 	LaFaveThomas.do												  *
  *																		  *  
  *  GOAL:	Table replication files for Farms, Families, and Markets 	  *
  *				New Evidence on the Completeness of Markets in 			  *
  *				Agricultural Settings by LaFave and Thomas				  *
  *																		  *
  *  NOTES: Requires the following add-on or updated commands:			  *
  *				1. reghdfe 											      *
  *				2. outreg2 												  *
  *				3. ranktest 											  *  
  *				4. ivreg2 												  *
  *			Steps to install these through the Boston College Statistical *
  *				Software Components Archive (SSC) are included in the     *
  *				preamble as "ssc install ..." Note that these require an  *
  *				internet connection to access SSC.						  *
  *  																	  *
  ************************************************************************* 
  *  STEPS																  *
  *		1. Local list of household composition and control variables	  *
  *  																	  *
  *		2. Open data 													  *
  *  																	  *
  *		3. Table 2 - primary regressions, columns 1 through 10			  *
  *  		A. Pooled Cross-Sections									  *
  *			B. Include Farm-Household Fixed Effects						  *
  *			C. Labor Demand By Farm Task								  *
  *  																	  *
  *		4. Table 3 - stratifications, columns 1 through 8				  *
  *			A. Years of Education 										  *
  *			B. Position in PCE Distribution								  *
  *  																	  *
  ************************************************************************* 
 
  *************************************************************************
   *--- Preamble ---*;
  #delimit ;
  clear all ;
  set more off ;
  set linesize 110;
  set matsize 10000 ;
  version 14.0 ;
  
  *install add-on programs if needed ;
  ssc install reghdfe ;
  ssc install outreg2 ;
  ssc install ranktest ;
  ssc install ivreg2 ;
	
************************************************************************** ;
   *--- Tempfiles ---*;
	tempfile strat;
	
************************************************************************** ;
* ----------------------------------------------- * ;
* 1.	Local list of variables to include on RHS
* ----------------------------------------------- * ;
	* Household comp - preferred linear model and Deaton shares model;
	local hhcomp 	m0014 m1519 m2034 m3549 m5064 mge65 
					f0014 f1519 f2034 f3549 f5064 fge65; 
	
	local hhshares hhsize_log		 sm1519	sm2034 sm3549 sm5064 smge65
							  sf0014 sf1519 sf2034 sf3549 sf5064 sfge65 ;

	* RHS control variables - all models include community-time FE (farmhhcommtime)
	*		Panel models also include household-farm FE (farmhhid) ;
	local rhs 		i.farmass_q i.hhass_q 	
					m_age 	m_educ 	  m_exist 	  
					f_age 	f_educ 	  f_exist 	i.ivwmth  	;	   

* --------------------------------------------------------- * ;
*	2. Select Data and sample
* --------------------------------------------------------- * ;
	* data ;
	use LaFaveThomas.dta ;
		
	* properly xtset for farm-household FE;
	xtset farmhhid ;
			
* -------------------------------------------------------------- * ;
*	3. Table 2 regressions - 
*		estimates regressions and joint tests of demographics ;
* -------------------------------------------------------------- * ;
		* -------------------------------------------------------------------- * ;
		*	A. Pooled Cross-Sections
		* -------------------------------------------------------------------- * ;
			*T2-1. Col 1 - linear age-gender bins specification ;
			 qui reghdfe labor_d_log `hhcomp' `rhs', absorb(farmhhcommtime) vce(cluster farmhhid)  ;

				test `hhcomp' ; 	 					   local F   = r(F) ; local pv   = r(p) ;
				test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m = r(F) ; local pv_m = r(p) ;
				test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f = r(F) ; local pv_f = r(p) ;
				test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat( 
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, _N) ctitle(n. hh mem) dec(2) noaster noobs nor2 replace ;

			*T2-2. Column 2 - Deaton/Benj shares specification ;
			qui reghdfe labor_d_log `hhshares' `rhs', absorb(farmhhcommtime) vce(cluster farmhhid)  ;


				test `hhshares' ; 	 							 local F   = r(F) ; local pv   = r(p) ;
				test 		sm1519 sm2034 sm3549 sm5064 smge65 ; local F_m = r(F) ; local pv_m = r(p) ;
				test sf0014 sf1519 sf2034 sf3549 sf5064 sfge65 ; local F_f = r(F) ; local pv_f = r(p) ;
				test sm1519 sm2034 sm3549 sf1519 sf2034 sf3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhshares	') addstat( 
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, _N) ctitle(hhs size + shares) dec(2)  noaster noobs nor2 ;

		* -------------------------------------------------------------------- * ;
		*	B. Including farm-household fixed effects
		* -------------------------------------------------------------------- * ;
			*T2-3. Column 3 - baseline panel model with farm-household fixed effects ;
			qui reghdfe labor_d_log `hhcomp' `rhs', absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;

				test `hhcomp' ; 	 					   local F   = r(F) ; local pv   = r(p) ;
				test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m = r(F) ; local pv_m = r(p) ;
				test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f = r(F) ; local pv_f = r(p) ;
				test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat(
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, _N) ctitle(n. hh mem) dec(2) noaster noobs nor2   ;
				
			*T2-4. Col 4 - Aging only sample ;

			*Redefine demographic specification to include reference groups (birth-14). Total number of males 
			*	and total n. of females is constant over time and picked up by hhFE ;			
			count if agingonly ; local nobs = r(N) ;
			
			local hhcomp  m1519 m2034 m3549 m5064 mge65 
						  f1519 f2034 f3549 f5064 fge65;

				qui reghdfe labor_d_log `hhcomp' `rhs' if agingonly == 1, absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;			
					test `hhcomp' ; 	 					   local F   = r(F) ; local pv   = r(p) ;
					test m1519 m2034 m3549 m5064 mge65 ; 	   local F_m = r(F) ; local pv_m = r(p) ;
					test f1519 f2034 f3549 f5064 fge65 ; 	   local F_f = r(F) ; local pv_f = r(p) ;
					test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat(
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, `nobs') ctitle(aging only) dec(2) noaster noobs nor2   ;
			
			*T2-5. Col 5 - Prior period composition ;
			count if m0014_l1 ~= . ; local nobs = r(N) ;
			
			local hhcomp m0014_l1 m1519_l1 m2034_l1 m3549_l1 m5064_l1 mge65_l1 
						 f0014_l1 f1519_l1 f2034_l1 f3549_l1 f5064_l1 fge65_l1;

				qui reghdfe labor_d_log `hhcomp' `rhs', absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;			

					test `hhcomp' ; 	 					   local F   = r(F) ; local pv   = r(p) ;
					test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m = r(F) ; local pv_m = r(p) ;
					test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f = r(F) ; local pv_f = r(p) ;
					test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat(
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, `nobs') ctitle(prior period) dec(2) noaster noobs nor2   ;

			
			*T2-6. Col 6 - Next period composition; 		
			count if m0014_f1 ~= . ; local nobs = r(N) ;
			
			local hhcomp m0014_f1 m1519_f1 m2034_f1 m3549_f1 m5064_f1 mge65_f1 
						 f0014_f1 f1519_f1 f2034_f1 f3549_f1 f5064_f1 fge65_f1;

				qui reghdfe labor_d_log `hhcomp' `rhs', absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;			

					test `hhcomp' ;  						   local F   = r(F) ; local pv   = r(p) ;
					test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m = r(F) ; local pv_m = r(p) ;
					test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f = r(F) ; local pv_f = r(p) ;
					test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat(
												F-dems, `F',   pval, 	`pv', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', nobs, `nobs') ctitle(next period) dec(2)  noaster noobs nor2  ;
					
			*T2-7. Col 7 - IV w/1-3 period lags and test exogeneity of 1&2 period lags conditional on 3 period ;
			count if m0014_l3 ~= . ; local nobs = r(N) ; 
			
			local hhcomp  m0014 m1519 m2034 m3549 m5064 mge65 
						  f0014 f1519 f2034 f3549 f5064 fge65;

			local ivs m0014_l1 m1519_l1 m2034_l1 m3549_l1 m5064_l1 mge65_l1 f0014_l1 f1519_l1 f2034_l1 f3549_l1 f5064_l1 fge65_l1 
					  m0014_l2 m1519_l2 m2034_l2 m3549_l2 m5064_l2 mge65_l2 f0014_l2 f1519_l2 f2034_l2 f3549_l2 f5064_l2 fge65_l2 
					  m0014_l3 m1519_l3 m2034_l3 m3549_l3 m5064_l3 mge65_l3 f0014_l3 f1519_l3 f2034_l3 f3549_l3 f5064_l3 fge65_l3 ;

			local testivs m0014_l1 m1519_l1 m2034_l1 m3549_l1 m5064_l1 mge65_l1 f0014_l1 f1519_l1 f2034_l1 f3549_l1 f5064_l1 fge65_l1
						  m0014_l2 m1519_l2 m2034_l2 m3549_l2 m5064_l2 mge65_l2 f0014_l2 f1519_l2 f2034_l2 f3549_l2 f5064_l2 fge65_l2 ;

				qui reghdfe labor_d_log `rhs' (`hhcomp' = `ivs'), absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;
					local cstat e(j) ; 
					local pv_c e(jp) ; 

					test `hhcomp' ;							   local F_all = r(F) ;	local pv_all = r(p) ;
					test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m   = r(F) ;	local pv_m   = r(p) ;
					test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f   = r(F) ;	local pv_f   = r(p) ;
					test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p   = r(F) ;	local pv_p   = r(p) ; 

					outreg2 using tab2.xls, dec(2) ctitle(iv lags) keep(`hhcomp') addstat( 
												F-dems, `F_all',   pval, 	`pv_all', F_m, `F_m', pv-m, `pv_m', F_f, `F_f', pv_f, `pv_f', 
												F_page, `F_p', pv-page, `pv_p', Cstat, `cstat', pv_c, `pv_c', nobs, `nobs') noaster noobs nor2    ;	

		* -------------------------------------------------------------------- * ;
		*	C. Labor demand by farm task
		* -------------------------------------------------------------------- * ;
			*T2-8-10. Cols 8-10 - Loop over labor demand by task in 3 groups:
			* (land prep/livestock/drying, selling, milling), (weeding/planting/fertilizing), harvesting ;
			
			foreach Y in llvd wpf h { ;
				count if labor_d_`Y'_log ~= . ; local nobs = r(N) ;
				
				qui reghdfe labor_d_`Y'_log `hhcomp' `rhs', absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;

					test `hhcomp' ; 						   local F   = r(F) ; local pv   = r(p) ;
					test m0014 m1519 m2034 m3549 m5064 mge65 ; local F_m = r(F) ; local pv_m = r(p) ;
					test f0014 f1519 f2034 f3549 f5064 fge65 ; local F_f = r(F) ; local pv_f = r(p) ;
					test m1519 m2034 m3549 f1519 f2034 f3549 ; local F_p = r(F) ; local pv_p = r(p) ; 

					outreg2 using tab2.xls, keep(`hhcomp') addstat(F-dems, `F',   pval, `pv', F_m, `F_m', pv-m, `pv_m', 
													F_f, `F_f', pv_f, `pv_f', F_page, `F_p', pv-page, `pv_p', nobs, `nobs') 
													ctitle(type`Y') dec(2) noaster noobs nor2 ;
				
			} ;

* --------------------------------------------- * ;
*	4. Table 3 Sample stratifications
* --------------------------------------------- * ;
	*Create a temp file that is the whole data set and then select the sample
	*	that want to use for each of the 8 stratifications ;	
	save `strat', replace ;
	
		forvalues S = 1(1)8 { ;
			*Define stratifications - columns 1 through 3 are based on years of education of
			*	the household head. Columns 4 through 8 are based on the household's place in 
			*	the real per capita expenditure distribution ;
			
			if `S' <= 3 { ; keep if edyrs_strat == `S' ; } ; 
			if `S' == 4 { ; keep if bottom50 	== 1   ; } ;
			if `S' == 5 { ; keep if top50    	== 1   ; } ;
			if `S' == 6 { ; keep if bottom15 	== 1   ; } ;
			if `S' == 7 { ; keep if mid70    	== 1   ; } ;
			if `S' == 8 { ; keep if top15	 	== 1   ; } ;

			*Regressions ;
			qui reghdfe labor_d_log `hhcomp' `rhs', absorb(farmhhid farmhhcommtime) vce(cluster farmhhid) ;			
					
				test `hhcomp' ;  
				local F   = r(F) ; 
				local pv   = r(p) ;
				
					outreg2 using tab3.xls, addstat(F-dems, `F',   pval, 	`pv', n_obs, _N) 
											ctitle(strat`S') dec(2) keep(`hhcomp') noobs nor2 noaster ;

				if `S' == 1 { ; outreg2 using tab3.xls, addstat(F-dems, `F',   pval, 	`pv', n_obs, _N) 
								ctitle(ed`S') dec(2) keep(`hhcomp') noobs replace nor2 noaster ; } ;

			*Reload full sample for next stratification ;
			use `strat', clear ;
		} ; 
		exit ;


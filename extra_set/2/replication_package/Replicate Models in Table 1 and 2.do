*** TABLE 1 ***
* use "DQI_IR_Idealpoints_Habermas.dta"

* Model 1
xtmixed mean_ideal sex1 education workingclass age i.region salience knowledge_V2 interest || small_gr:, reml

* Model 2
xtmixed mean_ideal sex1 education workingclass age i.region salience knowledge_V2 interest i.region##workingclass || small_gr:, reml

*Models for Appendix (include translated speech)
xtmixed mean_ideal sex1 education workingclass age i.region salience knowledge_V2 interest translated || small_gr:, reml
xtmixed mean_ideal sex1 education workingclass age i.region salience knowledge_V2 interest i.region##workingclass translated || small_gr:, reml



*** TABLE 2 ***
* use "SANDERS_Replication.dta"

* TABLE 2 - Model 1 (determinants of opinion at wave 3; for full model see Table A11 Appendix)
xtmixed w3pro w2pro female age education workingclass catholic protestant religios leftrigh leftrigh2 v3q65_2 v3q65_3 v3q65_4 v3q65_5 know_change pressure_above_w2_pro pressure_below_w2_pro leftparty2 rightparty2 DQ_jlev || small_gr:, reml
* DQ_jlev = group level variable (justification rationality)

* TABLE 2 - Model 2
* logarithm of the absolute opinion change; for full model see Table A11 Appendix 
xtmixed change_w3w2_log female age education workingclass catholic protestant religios leftrigh leftrigh2 v3q65_2 v3q65_3 v3q65_4 v3q65_5 know_change pressure_above_w2_pro pressure_below_w2_pro leftparty2 rightparty2 DQ_jlev || small_gr:, reml


* Table A12 (Appendix): INFLUENCE OF HIGHLY SKILLED - Immigration attitudes (Table 3 - modification of Model 1, Table 2)
xtmixed w3pro w2pro female age education workingclass catholic protestant religios leftrigh leftrigh2 v3q65_2 v3q65_3 v3q65_4 v3q65_5 know_change pressure_above_w2_pro pressure_below_w2_pro leftparty2 rightparty2 w2pro_90diff_morepro w2pro_90diff_lesspro || small_gr:, reml


# This is the makefile for "Child Adoption Matching"

stata-mp -b do ChoicePanel_AEJ1.do  

stata-mp -b do Matching_Regression_Match-Not_AEJ.do

stata-mp -b do Matching_Regression_AEJ_2.do

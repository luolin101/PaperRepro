This Readme file is an explanation of all of the documents that explain how to replicate the results contained in the "Fiscal Roots of Financial Underdevelopment,"
as well its supplementary appendix. Three documents are explained herein. The first outlines the Analysis Datasets and is called "Explanation of Analyses Datasets." 
The second contains the softward commands used and is called "Software Commands." The last is called "Information to Reconstruct Analyses Datasets" and explains how 
to go about recreating said datasets.

1. Explanation of Analyses Datasets

There are 3 datasets that were employed to construct the tables and figures in the paper and the supplementary appendix, as well as to run some analyses discussed
but not reported in both documents. The first is a country year panel dataset with global coverage. The second is a leader country year dataset with global coverage.
The last is a time series dataset of Mexico. Each of the analyses datasets is in Stata format. The Stata Version used to construct each of them and to run all of the 
analyses is Stata SE 11, 64-bit. Each file has a .dta ending.  

Each of these datasets is connected to a codebook. Each dataset also contains a codebook with the same name, but with a PDF ending, that outlines each of the variables 
that appear in the respective dataset.

The names of the analyses dataset are named, respectively:

Country Year Dataset
Leader Year Country Dataset
Mexico Year Data

The appending codebooks that describe the variables contained in each dataset are named as follows:

Country Year Dataset Codebook
Leader Country Year Dataset Codebook
Mexico Year Dataset Codebook

2. Software Commands

There are four Stata (11) do files that contain software commands. The first one, labeled Software Commands Paper, is to reproduce the regression results in the paper, 
which are derived from the country year dataset with global coverage. This also includes how to calculate summary statistics (Table 1 of the text) and data diagnostics; 
e.g., the panel unit root tests reported in the text. The second, labeled Software Commands Appendix, is to reproduce the regression results in the supplementary 
appendix that correspond to the country year dataset. The third, labeled Software Commands Appendix Leader correspond to descriptive statistics, regressions, and 
figures from  the leader country year dataset. The fourth, Softward Commands Mexico correspond to those commands needed to reproduce Figure 1 in the paper. It is 
important to note that these files also contain commands used to download statistical model packages that are not already loaded into that version of Stata as well 
as commands to create new variables such as interaction terms, for models with muliplicative terms that are a combination of variables in the dataset, as well as moving 
averages of variables that appear in some time series graphs. 

3. Information to Reconstruct Datasets

The last document of the replication file contains and explains five sections. The first is how to merge the dataset that contains the main dependent variable used in 
the text, as well as the dependent variables in the appendix. The second is how to merge the dataset that contains another dependent variable in the text, as well as 
how that variable was constructed from several sources. The third is how to merge the dataset that contains the main independent variable and several of the control 
variables. The fourth is how to construct the leader year dataset, which implies merging an extant leader year dataset and a country year dataset. The fifth and final 
section are instructions on how to construct the Mexico time-series dataset, which includes two variables.

The original datasets, which are explained in the text file called "Information to Reconstruct Data Analyses" are named:

masterpaneluse
FinanceStr
TaxesPanel
TaxationMaster
QOGData
FinancialRef
Banks
AssaLegacy
AlbertusMenaldo
MexicoCase
MexicoTaxes
MexicoFinance


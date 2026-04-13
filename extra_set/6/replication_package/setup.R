# This file is used to load relevant packages and prepare functions. 

# Load packages
if (!require("tidyverse")) install.packages("tidyverse") #For data management and graphing
if (!require("extrafont")) install.packages("extrafont") #For using additional fonts in graphs
if (!require("psych")) install.packages("psych") #For computing summary statistics
if (!require("xtable")) install.packages("xtable") #For correlation tables
if (!require("Hmisc")) install.packages("Hmisc") #For correlation tables
if (!require("ggeffects")) install.packages("ggeffects") #For ploting results of regression model
if (!require("Cairo")) install.packages("Cairo") #For saving plots with anti-aliasing in text and lines
if (!require("kableExtra")) install.packages("kableExtra") #For tables in RMD reports
if (!require("broom")) install.packages("broom") #For cleanly displaying statistical output
if (!require("zeligverse")) install.packages("zeligverse") #For conducting rare events logit model (King & Zeng, 2001)
if (!require("printr")) install.packages("printr") #For cleanly printing tables and dataframes as HTML tables
library(papaja)
select <- dplyr::select #Ensuring that the default for "select" is from dplyr
summarize <- dplyr::summarize #Ensuring that the default for "summarize" is from dplyr
rename <- dplyr::rename #Ensuring that the default for "rename" is from dplyr

# Set up plot theme
## (Thanks to John Sakaluk for this particular setup: 
## https://sakaluk.wordpress.com/2015/08/27/6-make-it-pretty-plotting-2-way-interactions-with-ggplot2/#APA)
apatheme <- theme_bw() +
  theme(panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line())

# Logistic Regression Display Function
## This function is useful for rounding estimates and displaying CIs alongside other output.
display.glm <- function(model) {
  df <- summary(model) %>% with(df)
  display.obj <- tidy(model) %>% bind_cols(confint_tidy(model)) %>% 
    as.data.frame() %>% mutate(p.value.char = ifelse(p.value < .001, "< .001", p.value),
                               p.value.3 = round(p.value, 3),
                               ` ` = ifelse(p.value < .001, "***", 
                                            ifelse(p.value < .01, "**", 
                                                   ifelse(p.value < .05, "*", 
                                                          ifelse(p.value < .10, ".", " "))))) %>%
    mutate(p.value = as.character(ifelse(p.value < .001, "< .001", p.value.3)),
           df = df[2]) %>%
    select(term, B = estimate, SE = std.error, Z = statistic, df, p.value, conf.low, conf.high, ` `) %>%
    mutate_if(is.numeric, round, 2)
  return(display.obj)
}

## Additional steps for formatting kable
kable.lm <- function(display.obj) {
  kable(display.obj, align = c("l", rep('c', ncol(display.obj) - 1))) %>%
    kable_styling(bootstrap_options = c("hover", "condensed", "responsive"), 
                  full_width = F, position = "center")
}

# Regression Display Function
## This function is useful for rounding estimates and displaying CIs alongside other output.
display.lm <- function(model) {
  df <- summary(model) %>% with(df)
  display.obj <- tidy(model) %>% bind_cols(confint_tidy(model)) %>% 
    as.data.frame() %>% mutate(p.value.char = ifelse(p.value < .001, "< .001", p.value),
                               p.value.3 = round(p.value, 3),
                               ` ` = ifelse(p.value < .001, "***", 
                                            ifelse(p.value < .01, "**", 
                                                   ifelse(p.value < .05, "*", 
                                                          ifelse(p.value < .10, ".", " "))))) %>%
    mutate(p.value = as.character(ifelse(p.value < .001, "< .001", p.value.3)),
           df = df[2]) %>%
    select(term, B = estimate, SE = std.error, t = statistic, df, p.value, conf.low, conf.high, ` `) %>%
    mutate_if(is.numeric, round, 2)
  return(display.obj)
}

#### CORSTARS FUNCTION ####
corstars <-function(x, method=c("pearson", "spearman"), removeTriangle=c("upper", "lower"),
                    result=c("none", "html", "latex")){
  #Compute correlation matrix
  x <- as.matrix(x)
  correlation_matrix<-rcorr(x, type=method[1])
  R <- correlation_matrix$r # Matrix of correlation coeficients
  p <- correlation_matrix$P # Matrix of p-value 
  
  ## Define notions for significance levels; spacing is important.
  mystars <- ifelse(p < .001, "***", ifelse(p < .01, "** ", ifelse(p < .05, "*  ", ifelse(p < .10, "+   ", "    "))))
  
  ## trunctuate the correlation matrix to two decimal
  R <- format(round(cbind(rep(-1.11, ncol(x)), R), 2))[,-1]
  
  ## build a new matrix that includes the correlations with their apropriate stars
  Rnew <- matrix(paste(R, mystars, sep=""), ncol=ncol(x))
  diag(Rnew) <- paste(diag(R), " ", sep="")
  rownames(Rnew) <- colnames(x)
  colnames(Rnew) <- paste(colnames(x), "", sep="")
  
  ## remove upper triangle of correlation matrix
  if(removeTriangle[1]=="upper"){
    Rnew <- as.matrix(Rnew)
    Rnew[upper.tri(Rnew, diag = TRUE)] <- ""
    Rnew <- as.data.frame(Rnew)
  }
  
  ## remove lower triangle of correlation matrix
  else if(removeTriangle[1]=="lower"){
    Rnew <- as.matrix(Rnew)
    Rnew[lower.tri(Rnew, diag = TRUE)] <- ""
    Rnew <- as.data.frame(Rnew)
  }
  
  ## remove last column and return the correlation matrix
  Rnew <- cbind(Rnew[1:length(Rnew)-1])
  if (result[1]=="none") return(Rnew)
  else{
    if(result[1]=="html") print(xtable(Rnew), type="html")
    else print(xtable(Rnew), type="latex") 
  }
} 

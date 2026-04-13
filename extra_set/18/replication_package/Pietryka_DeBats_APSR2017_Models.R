# ==============================================================================
# CREATED BY: PIETRYKA
# DATE:       November 07, 2016
# PURPOSE:    THIS FILE RUNS THE MODELS PRESENTED IN TABLES 1 AND 2 OF PIETRYKA
#             AND DEBATS' 2017 APSR ARTICLE
# DATA INPUT: 'Alexandria_Data.tsv', 'Newport_Data.tsv'
# R VERSION:  FILE WAS CREATED WHILE USING R VERSION 3.3.1 (2016-06-21)
# QUESTIONS:  mpietryka@fsu.edu
# ==============================================================================


#===============================================================================
#   1. PRELIMINARIES ####
#===============================================================================

# LOAD PACKAGES
library(readr)   # readr_1.0.0: READ IN DATA WITH 'read_tsv()'
library(dplyr)   # dplyr_0.5.0: HELPER FUNCTIONS, e.g., '%>%'
library(texreg)  # texreg_1.36.7: PRINT SUMMARIES OF DATA WITH 'screenreg()'

# LOAD DATA
alexandria_data <- read_tsv("Alexandria_Data.tsv")
newport_data <- read_tsv("Newport_Data.tsv")



#===============================================================================
#   2. IDENTIFY CONTROL VARIABLES ####
#===============================================================================
alexandria_controls <- c(
  "hhwealth",    # Household wealth (thousands of dollars)"
  "hhwealthlog", # ln(Household wealth)
  "midstatus",   # Mid-status occupation
  "highstatus",  # High-status occupation
  "owner",       # Owns home?
  "age",         # Age (years)
  "agelog",      # ln(Age)
  "church",      # Is church member?
  "usborn"       # Is U.S. born?
) %>%
  paste(collapse = " + ")

newport_controls <- c(
  "hhwealth",    # Household wealth (thousands of dollars)"
  "hhwealthlog", # ln(Household wealth)
  "midstatus",   # Mid-status occupation
  "highstatus",  # High-status occupation
  "owner",       # Owns home?
  "age",         # Age (years)
  "agelog",      # ln(Age)
  "black",       # Is African American?"
  "usborn"       # Is U.S. born?
)  %>%
  paste(collapse = " + ")



#===============================================================================
#   3. RUN TURNOUT MODELS (TABLE 1) ####
#===============================================================================

# ------- ALEXANDRIA  ---------------- #
# TABLE 1, MODEL 1
alexandria_turnout_1 <- paste("turnout ~ ",
                              alexandria_controls)  %>%
  formula()  %>%
  glm(data = alexandria_data,
      family = binomial(link = "logit"))
summary(alexandria_turnout_1)

# TABLE 1, MODEL 2
alexandria_turnout_2 <- paste("turnout ~ ",
                              alexandria_controls,
                              "+ z1ev")  %>%
  formula()  %>%
  glm(data = alexandria_data,
      family = binomial(link = "logit"))
summary(alexandria_turnout_2)

# TABLE 1, MODEL 3
alexandria_turnout_3 <- paste("turnout ~ ",
                              alexandria_controls,
                              "+ z1ev + z1elite_avgprox")  %>%
  formula()  %>%
  glm(data = alexandria_data,
      family = binomial(link = "logit"))
summary(alexandria_turnout_3)

# ------- NEWPORT  ---------------- #

# TABLE 1, MODEL 4
newport_turnout_1 <- paste("turnout ~ ",
                           newport_controls)  %>%
  formula()  %>%
  glm(data = newport_data,
      family = binomial(link = "logit"))
summary(newport_turnout_1)

# TABLE 1, MODEL 5
newport_turnout_2 <- paste("turnout ~ ",
                           newport_controls,
                           "+ z1ev")  %>%
  formula()  %>%
  glm(data = newport_data,
      family = binomial(link = "logit"))
summary(newport_turnout_2)

# TABLE 1, MODEL 6
newport_turnout_3 <- paste("turnout ~ ",
                           newport_controls,
                           "+ z1ev + z1elite_avgprox")  %>%
  formula()  %>%
  glm(data = newport_data,
      family = binomial(link = "logit"))
summary(newport_turnout_3)

# ------- ANOVAS  ---------------- #
anova(alexandria_turnout_1, alexandria_turnout_3, test = "Chisq")
anova(newport_turnout_1, newport_turnout_3, test = "Chisq")

#===============================================================================
#   4. VOTE CHOICE MODELS (TABLE 2) ####
#===============================================================================

# ------- ALEXANDRIA  ---------------- #

# TABLE 2, MODEL 1
alexandria_votechoice_1 <- paste("opp ~ ",
                                 alexandria_controls)  %>%
  formula()  %>%
  lm(data = filter(alexandria_data, turnout == 1))
summary(alexandria_votechoice_1)

# TABLE 2, MODEL 2
alexandria_votechoice_2 <- paste("opp ~ ",
                                 alexandria_controls,
                                 "+ z1ev")  %>%
  formula()  %>%
  lm(data = filter(alexandria_data, turnout == 1))
summary(alexandria_votechoice_2)

# TABLE 2, MODEL 3
alexandria_votechoice_3 <- paste("opp ~ ",
                                 alexandria_controls,
                                 "+ z1ev + z1maj_avgprox + z1min_avgprox")  %>%
  formula()  %>%
  lm(data = filter(alexandria_data, turnout == 1))
summary(alexandria_votechoice_3)


# ------- NEWPORT  ---------------- #

# TABLE 2, MODEL 4
newport_votechoice_1 <- paste("dem ~ ",
                                 newport_controls)  %>%
  formula()  %>%
  lm(data = filter(newport_data, turnout == 1))
summary(newport_votechoice_1)

# TABLE 2, MODEL 5
newport_votechoice_2 <- paste("dem ~ ",
                                 newport_controls,
                                 "+ z1ev")  %>%
  formula()  %>%
  lm(data = filter(newport_data, turnout == 1))
summary(newport_votechoice_2)

# TABLE 2, MODEL 6
newport_votechoice_3 <- paste("dem ~ ",
                                 newport_controls,
                                 "+ z1ev + z1maj_avgprox + z1min_avgprox")  %>%
  formula()  %>%
  lm(data = filter(newport_data, turnout == 1))
summary(newport_votechoice_3)

# ------- ANOVAS  ---------------- #
anova(alexandria_votechoice_1, alexandria_votechoice_3)
anova(newport_votechoice_1, newport_votechoice_3)


#===============================================================================
#   5. DISPLAY RESULTS ####
#===============================================================================
# TABLE 1
list(
  alexandria_turnout_1,
  alexandria_turnout_2,
  alexandria_turnout_3,
  newport_turnout_1,
  newport_turnout_2,
  newport_turnout_3
)  %>%
  screenreg(digits = 3,
            stars = .05)

# TABLE 2
list(
  alexandria_votechoice_1,
  alexandria_votechoice_2,
  alexandria_votechoice_3,
  newport_votechoice_1,
  newport_votechoice_2,
  newport_votechoice_3
)  %>%
  screenreg(digits = 3,
            stars = .05)


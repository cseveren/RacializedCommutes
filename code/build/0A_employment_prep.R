
# ******************
# 0) Setup
# 1) Employment Data
# ******************

# ========
# 0) Setup
# ========

wd <- "C:\\Dropbox\\Dropbox (Phil Research)\\RacialCommutingGap"
setwd(wd)

pacman::p_load(tidyverse)


# ==================
# 1) Employment Data
# ==================

emp_1994 <- read_csv(".\\empirics\\input\\cbp\\zbp94totals.csv")
emp_2000 <- read_csv(".\\empirics\\input\\cbp\\zbp00totals.csv")
emp_2010 <- read_csv(".\\empirics\\input\\cbp\\zbp10totals.csv")
emp_2018 <- read_csv(".\\empirics\\input\\cbp\\zbp18totals.csv")
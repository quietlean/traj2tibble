library(tidyverse)
library(lubridate)
library(readr)
library(sf)

source("read-trajectories.R")

traj_path <- "hysplit-trajectories/"

time_intervall <- "-1 hours"

traj_df <- traj_read(traj_path, time_intervall)

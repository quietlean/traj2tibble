library(tidyverse)
library(lubridate)
library(readr)
library(sf)

source("read-trajectories.R")

traj_path <- "hysplit-trajectories/"

time_intervall <- "-1 hours"

traj_df <- traj_read(traj_path, time_intervall)

# Die Funktion muss noch so umgebaut werden, dass sie auch mit anderen zeitintervallen klar kommt z.B. alle 5 stunden eine trajektorie

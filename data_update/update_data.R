#A script which runs all existing scripts which query indicator data for the CPOP,
# as well as the script which combines these datasets into a masterdata file, 
# in the correct order.

source("data_update/API_scripts/run_first/child_and_working_age_populations.R")
source("data_update/API_scripts/run_second/child_poverty.R")
source("data_update/API_scripts/run_second/crime_rate.R")
source("data_update/API_scripts/run_second/educational_attainment.R")
source("data_update/API_scripts/run_second/employment_rate.R")
source("data_update/API_scripts/run_second/healthy_birthweight.R")
source("data_update/API_scripts/run_second/median_pay.R")
source("data_update/API_scripts/run_second/out_of_work_benefits.R")
source("data_update/API_scripts/run_second/primary_1_body_mass_index.R")
source("data_update/API_scripts/run_second/wellbeing.R")
source("data_update/API_scripts/run_third/master_data.R")
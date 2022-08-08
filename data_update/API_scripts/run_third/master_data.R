bweight_dta <- read.csv("data_update/data/healthy_birthweight_cpp.csv")
childpov_dta <- read.csv("data_update/data/child_poverty_cpp.csv")
attnment_dta <- read.csv("data_update/data/educational_attainment_cpp.csv")
employment_dta <- read.csv("data_update/data/employment_rate_cpp.csv")
oowb_dta <- read.csv("data_update/data/out_of_work_benefits_cpp.csv")
p1_bmi_dta <- read.csv("data_update/data/p1_body_mass_index_cpp.csv")
wellbeing_dta <- read.csv("data_update/data/wellbeing_cpp.csv")
crime_dta <- read.csv("data_update/data/crime_rate_cpp.csv")
wellbeing_dta <- read.csv("data_update/data/wellbeing_cpp.csv")
median_pay_dta <- read.csv("data_update/data/median_pay_cpp.csv")

masterdata <- rbind(bweight_dta, childpov_dta, attnment_dta, 
                    employment_dta, oowb_dta, p1_bmi_dta, wellbeing_dta,
                    crime_dta, median_pay_dta)

#rename alternative CPP names so that they are consistent
masterdata$CPP[masterdata$CPP == "City of Edinburgh"] <- "Edinburgh, City of"
masterdata$CPP[masterdata$CPP == "Na h-Eileanan Siar"] <- "Eilean Siar"


currentDate <- format(Sys.Date(), "%d_%m_%y")
write.csv(masterdata, file = paste0("cpop_data/masterdata_",currentDate,".csv"), row.names = FALSE)

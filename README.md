# dummy_CPOP
pared back CPOP dashboard for purposes of demonstrating the usability/readability of data generated from API queries

# Dashboard Structure ---------------------

The dashboard is composed with the three standard shiny scripts (global.R, server.R and ui.R), the global script reads in data from the folder 'dashboard_data/' in the form of one master data which has time series data for six indicators which can be obtained from APIs
  (Healthy Birthweight, Primary 1 Body Mass Index, Child Poverty, Attainment, Employment Rate, Out of Work Benefits). For sake of simplicity this data only CPP (local authority) level data has been used.

This dashboard is supposed to mirror the content of the CPP over time tab of the original CPP dashboard.

# DATA UPDATE: file structure -----------------------------------------

The 'data_update/' folder contains almost all scripts and files necessary to update this dashboard on an annual basis. Data obtained from statxplore will involve one manual step per dataset(see below).

The 'data_update/API_scripts/' folder contains seven scripts; one for each indicator and one which generates population data for use as denominator in rate calculations for out of work benefits and child poverty
('data_update/API_scripts/mye_populations.R')
This must be run first, so that the csv output it writes to 'data_update/data/' is available to be read in as required to other scripts. After that, scripts within 'data_update/API_scripts/' can be run in any particular order. Every time these are run, they overwrite pre-existing csv in 'data_update/data/' with the latest data.

Once all API scripts have been run, generating csv data in 'data_update/data/', the file 'data_update/master_data.R' can be run which combines the individuals csvs for each indicator into one csv which is written to dashboard_data/ Where it can be read in to the global.R script.
Every time the master_data.R script is run it creates a csv, which incorporates the day it is run within it's file name. In practice this means that, we can keep an archive of masterdata.csv files, but does mean that the filename in the global script has to be manually updated. This is also a protective measure to prevent the update being implemented before checking that nothing unexpected has been returned. 

There is also a look_ups folder available which contains csv files which can be used to match geography codes to names where this is not done by the API. Codes are also used for combining datasets with population data, since, at IZ and DZ level, names are not distinct identifiers.

# API Script Requirements ------------------
Three custom packages have been used in the API scripts. Find guidance regarding import on respective github links.
  1. nomisr (https://github.com/ropensci/nomisr) 
      NOTE: this package is only used to query the metadata of the dataset       to identify necessary parameter codes, otherwise response is too          large. This process has been kept in the script for the sake of           clarity/reproducibility, but can be removed ultimately if this            package proves problematic. 
  2. statxplorer (https://github.com/houseofcommonslibrary/statxplorer) 
    It is necessary to use this package at this stage since the response      using a simple GET request is very difficult to parse.
  3. phsopendata (https://github.com/Public-Health-Scotland/phsopendata)
    Used to query public health scotland open data  
    
For the most part the API scripts should be self-sufficient since, where possible, they query the latest data, and (in the case of statxplore) an api key is available in a text file (see 'data_update/txt/statxpl_apikey.txt'). However, for the two scripts which query the statxplore API (Child Poverty, Out of Work Benefits) a json file is required. This can be generated using the statxplore table generator interface (detailed guide below) but dates must be chosen from those available. This means a new json file must be created for every update to reflect new years available, which then must be saved within 'data_update/json/' ensuring 'mm_yy' is included in file name. The Child Poverty and OOWB scripts will have to be manually updated to reflect this. A folder (data_update/json/historic_json/' has been created to store the outdated queries).

#get statxplore json files: out of work benefits
1. Visit this page (https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml) and log-in/sign up.
2. Under Datasets, under Benefit Combinations click Benefit Combinations - Data from February 2019, and click the blue 'New Table' button above.
3. Under Geography, click 'National_Regional_LA_OAs', then 'Great Britain'. Click on the small arrow to the RIGHT of 'Scotland and select 'Local Authority'. This should select all Scottish LAs. Click the 'Row' button above to add to table.
4. Click on Quarter and select checkboxes for all 'May' quarters available. Click the 'Column' button above to add to table.
5. Under 'Benefit Groups' click on 'Benefit Combinations (Out of Work)'. Click the button to the RIGHT of this and select again 'Benefit Combinations (Out of Work)'. This will check all benefit categories. IT IS IMPORTANT TO DESELECT/UNCHECK THE BOX NEXT TO 'not on out of work benefits'. Then click the 'Column' button from the top again to add to table. Should you be warned about entering large table mode, select okay.
6. In the top right corner there is a select drop down menu, select 'Open Data API Query (.json)' then press go. This will download a json file.
7. Rename this file 'oowb_08_22.json' (with the relevant month/day) and move/save to 'data_update/json/' file. Moving older json to historic_json after.
(The above steps can be repeated to obtain oowb_historic data by clicking on 'Benefit Combinations - Data to November 2018' at step 2).

#get statxplore json files: child poverty
1. Visit this page (https://stat-xplore.dwp.gov.uk/webapi/jsf/login.xhtml) and log-in/sign up.
2. Under Datasets, under 'Children in Low Income Families' click 'Relative Low Income', and click the blue 'New Table' button above.
3. Under Geography, click 'National_Regional_LA_OAs', then 'Great Britain'. Click on the small arrow to the RIGHT of 'Scotland and select 'Local Authority'. This should select all Scottish LAs. Click the 'Row' button above to add to table.
4. Click on Year and then the little arrow to the RIGHT and select Year again which checks all available years. Click on the 'Column' button in the panel above to add to table.
5. Under 'Age of child (years and bands)', check the 0-4, 5-10, and 11-15 boxes. Click on the 'Column' button in the panel above to add to table.
6. In the top right corner there is a select drop down menu, select 'Open Data API Query (.json)' then press go. This will download a json file.
7. Rename this file 'child_poverty_08_22.json' (with the relevant month/day) and move/save to 'data_update/json/' file. Moving related older json files to historic_json.
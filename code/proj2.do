/// Proj 2

/// This project focuses on creating 2 synthetic economic and finance data.
/// Merge them and provide some intricate analysis. 
/// Cleaning the data to help provide analysis.


/// Generate 2 separate data sets

*** Gen data set 1: Economic Indicators

set seed 12345

set obs 50

gen cntry = "" /// empty country sets

replace cntry = "CntryA" in 1/25 /// replace the first 25 with Country A

replace cntry = "CntryB" in 26/50 /// replace the second set 25 with Country B

gen inflation = rnormal(2, 05) /// inflation number randomly

gen gpd_growth = rnormal(3, 1) /// gdp growth synthetic data

gen unemployment = rnormal(6, 1) /// unemployment synthetic data



*** Gen data set 2: finance data
set obs 50 

gen cntry = ""

replace cntry = "cntryA" in 1/25

replace cntry = "cntryB" in 26/50

gen yr = 2000 +  mod(_n-1, 25)

gen stck_return = rnormal(8, 3)

gen mkt_cap = rnormal(500, 100)

save "synthc_stock_mkt.dta", replace


** Merge Datasets


use "synth_economic_data.dta", clear 

merge 1:1 cntry yr using "synth_stock_mtk.dta" 


*** check for merged issues

list if _merge !=3

** keep only merged data 
drop if _merge !=3

drop _merge 

save "merged_data.dta", replace 



**** debugging the unmatched 

merge 1:1 cntry yr using "synth_stock_mkt.dta"

    Result                      Number of obs
    -----------------------------------------
    Not matched                           100
        from master                        50  (_merge==1)
        from using                         50  (_merge==2)

    Matched                                 0  (_merge==3)
    -----------------------------------------


**** List key variables

list cntry yr

use "synthetic_econ_indicators.dta", clear


gen new_cntry1 = lower(substr(cntry, 1,1)) + substr(cntry, 2, .)

gen new_cntry2 = lower(substr(cntry, 1, 1)) + substr(cntry, 2, .)


rename new_cntry1 cntry

drop new_cntry3

list if _merge !=3

drop if _merge != 3

drop _merge 


**** After problem solved

save "merged_data_new.dta", replace

count

describe 

/// ensure the rows are equal to the earlier generated one (obs 50)


//// analysis 


*** Clean and Preprocess Data 

/// Handling missing data values

misstable sum 


*** Dropping obs with missing values 

drop if missing(gdp_grwth, inflation, unemployment, stck_return, mkt_cap)

/// Generating additional variables 

gen log_mkt_cap = log(mkt_cap)



*** Summary statistics 

summarize 
asdoc asdoc, save("results/summary_stats.doc")


**** regression analysis 

reg stck_return gdp_grwth inflation unemployment log_mkt_cap


*** Plots of the graphs

/// Line plot for GDP growth over time by country

twoway (line gdp_grwth yr if cntry == "cntryA", lcolor(red))
       (line gdp_grwth yr if cntry == "cntryB", lcolor(red)),
       legend(label(1 "cntryA") label(2 "cntryB"))
       title("GDP Growth Over Time")
       xtitle("Year") 
	   ytitle("GDP Growth (%)")
	   
	   graph export "results/gdp_growth_by_country.png", replace
	   
	   
	
scatter stck_return gdp_grwth, by(cntry)
        title("Stock Returns vs. GDP Growth") 
        xtitle("GDP Growth (%)") ytitle("Stock Return (%)")

		graph export "results/stck_return_gdp_growth.png", replace

collapse (mean) stck_return, by(cntry)

// Bar plot for average stock returns by country
graph bar (mean) stck_return, over(cntry)
       title("Average Stock Returns by Country")
       ytitle("Average Stock Return (%)")
	  
	  
	  graph export "results/avg_stock_return.png", replace
	  
	  
// Histogram of inflation rates
histogram inflation, by(cntry)
           title("Distribution of Inflation Rates")
           xtitle("Inflation Rate (%)")
	  
	  graph export "results/inflation_rates.png", replace
	  
	 
	  
**** Panel data analysis 

xtset cntry yr

/// xtset cntry yr
/// string variables not allowed in varlist;
/// cntry is a string variable

sort cntry yr

egen cntry_id1 = group(cntry)


**** Declare the panel data structure

xtset cntry_id1 yr


*** Fixed Effects Model 

xtreg stck_return gdp_grwth inflation unemployment log_mkt_cap, fe


*** Random Effects Model 

xtreg stck_return gdp_grwth inflation unemployment log_mkt_cap, re 


**** Hausman test
/// To determine which of the models is best

xtreg stck_return gdp_grwth inflation unemployment log_mkt_cap, fe

estimates store fixed 

xtreg stck_return gdp_grwth inflation unemployment log_mkt_cap, re 

estimates store random 

/// then finally 

hausman fixed random 




 




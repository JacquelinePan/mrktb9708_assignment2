*set working directory 
cd "/Users/jp4096/Documents/RMCodingAssignments/mrktb9708_assignment2"

*read in CSV file 
import delimited "/Users/jp4096/Documents/RMCodingAssignments/mrktb9708_assignment2/vaping-ban-panel.csv"

*install diff
ssc install diff 

*Rename vapingban to did (interaction between time and treatmentdummy)
rename vapingban did 

*Rename lunghospitalizations 
rename lunghospitalizations outcome 

* Create dummy variable to indicate time when treatment started (2021)
gen time = (year>=2021) & !missing(year)
lab def time_lab 0 "pre" 1 "post"
lab val time time_lab

* Create dummy variable to stratify control group from treatment group
gen treatmentdummy = (stateid<=23)

*Relabel the variable descriptions 
label variable stateid "State ID"
label variable did "Vaping Ban"
label variable time "Policy Implementation Time Dummy"
label variable treatmentdummy "Treatment Group Dummy"
label variable outcome "Hospitalizations"

* 2. Checking if the parallel trends requirement is fulfilled through regression 
* preserve data
preserve 
* drop "after policy" observations 
drop if year >= 2021
*create interaction variable between year and treatmentdummy 
gen year_evertreated=year*treatmentdummy 
*label the year_evertreated variable
label variable year_evertreated "Year Treatment Interaction"
* run the regression on just the "pre-data"
reg outcome treatmentdummy year year_evertreated, r 
*store regression
eststo Model1

* restore previous dataset
restore 

* 3. Create the DnD line graph to check if the parallel trends requirement is fulfilled 
ssc install lgraph, replace 
lgraph outcome year, by(treatmentdummy) stat(mean) xline(2021) ylab(, nogrid) scheme(s2mono)


* 4. Run DnD regression to estimate the treatment effect of the lawsm with time and state fixed effects
reg outcome time treatmentdummy did i.stateid i.year

* Store regression
eststo Model2

*export to LaTeX
esttab Model1 Model2 using Assignment2.tex, $tableoptions keep(time treatmentdummy year year_evertreated did _cons) star(* 0.10 ** 0.05 *** 0.01) collabels(none) stats(r2 N, fmt(%9.4f %9.0f %9.0fc) labels("R-squared" "Number of observations")) plain noabbrev nonumbers lines parentheses fragment









  

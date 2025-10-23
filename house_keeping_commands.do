// NUMERIC VARIABLES
// – This command helps to pick anything that is non-numeric in a numeric variable
gen non_numeric = regexm(height_cm, "[^0-9.]") 
tab non_numeric

// Extract unique strings of a variable
levelsof source, local(unique_vals)
display "`unique_vals'" 

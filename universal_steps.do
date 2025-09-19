// Step 1 (Remove the unnecessary bit)
=SUBSTITUTE(SUBSTITUTE(B6,"MOH 731 Tested_15-19(F) HV01-05 ","")," ","")

// Step 2 (Append the necessary tail)
=D6&"_tested"

// Step 3 (Rename accordingly)
="rename "&A6&"  "&E6


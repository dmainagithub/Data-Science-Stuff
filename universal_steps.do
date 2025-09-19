// Step 1 (Remove the unnecessary bit)
=SUBSTITUTE(SUBSTITUTE(B6,"MOH 731 Tested_15-19(F) HV01-05 ","")," ","")

// Step 2 (Append the necessary tail)
=D6&"_tested"

// Step 3 (Rename accordingly)
="rename "&A6&"  "&E6



// # Go to your project folder
// cd D:\APHRC\GoogleDrive_ii\data_science\data_science_gitstuff
//
// # Initialize git
// git init
//
// # Add all files
// git add .
//
// # Commit them
// git commit -m "Initial commit"
//
// # Rename default branch to main
// git branch -M main
//
// # Link to GitHub repo (replace with your repo URL)
// git remote add origin https://github.com/dmainagithub/Data-Science-Stuff.git
//
// # Push to GitHub
// git push -u origin main



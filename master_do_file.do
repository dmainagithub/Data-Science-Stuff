/********************************************************************
 Master Do-File for Tiko Data Processing
 This script sets global paths & filenames and runs individual scripts
********************************************************************/

clear all
set more off

*-------------------------------------------------
* 1. Set shared path and filename (edit here once)
*-------------------------------------------------
global mypath "D:\GoogleDrive\Personal\Consultancies\Tiko\data\datasets\new_csv\"
global myfile "MOH 731 Tested_Linked_HTS_Positive_15-19_F_july2021_june2023"

*-------------------------------------------------
* 2. Change directory
*-------------------------------------------------
cd "$mypath"

*-------------------------------------------------
* 3. Run do-files in correct order
*-------------------------------------------------
do "01_import.do"
do "02_save.do"

*-------------------------------------------------
* 4. End message
*-------------------------------------------------
display as text "✅ Master script completed successfully!"


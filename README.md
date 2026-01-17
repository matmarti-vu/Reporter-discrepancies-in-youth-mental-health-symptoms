# Reporter-discrepancies-in-youth-mental-health-symptoms
This repository contains Stata code to reproduce the main analyses for a paper on multi-informant (youth, caregiver, teacher) discrepancies in youth mental health symptoms during the transition to adolescence, using the Adolescent Brain Cognitive Development (ABCD) Study data (Release 5.1).

**Repository contents**

1 - Masterdatabase 5_1.do
Imports ABCD Release 5.1 tabulated files (multiple domains), merges them by participant and event, and saves an analytic dataset: NAME_DATABASE.dta.

2 - Analyses.do
Loads NAME_DATABASE.dta, constructs symptom domains and discrepancy variables, and outputs the paper’s main tables and figures.

**Requirements**

Stata (the scripts use commands like mi impute chained, mixed, and margins/marginsplot; Stata 15+ is a safe baseline)

User-written Stata command:

outreg2 (used to export regression tables to .xls)

Install outreg2 once:

cap which outreg2
if _rc ssc install outreg2, replace

**Data access and folder structure (ABCD Release 5.1)**

These scripts assume you have access to ABCD Release 5.1 tabulated data and that your local folder contains the ABCD subfolders and filenames used in the code (e.g., mental-health, abcd-general, culture-environment, etc.).

Important: The master do-file imports many separate tabulated files. If any expected file is missing, Stata will stop and tell you which path could not be found. The simplest approach is to place the relevant ABCD Release 5.1 tabulated exports in a single root directory and preserve the subfolder structure used in the do-file paths.

Step 1 — Build the analytic dataset (NAME_DATABASE.dta)

i. Open 1 - Masterdatabase 5_1.do.
ii. Edit the first line to point to your local ABCD Release 5.1 root folder:
     global data5p1 "PATH TO ABCD DATA, RELEASE 5.1"
     Example (Windows): global data5p1 "C:\ABCD\release_5_1"
iii. Run the do-file: do "...\1 - Masterdatabase 5_1.do"
iv. Expected output: the do-file saves the analytic dataset here:

save "$data5p1\NAME_DATABASE.dta", replace

Step 2 — Run analyses and produce tables/figures

i. Open 2 - Analyses.do.
ii. Edit the globals at the top:
     global data    "PATH TO THE DATA"
     global results "PATH TO WHERE THE RESULTS WILL BE STORED"
     data should point to the folder containing NAME_DATABASE.dta (by default, the same data5p1 folder you used above).
     results should point to any folder where you want outputs written.
     Example:
     global data    "C:\ABCD\release_5_1"
     global results "C:\ABCD\outputs_discrepancies"
iii. Run the do-file: do "...\2 - Analyses.do"


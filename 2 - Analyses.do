

global data 	"PATH TO THE DATA CREATED IN 1 - Masterdatabase 5_1.do: NAME_DATABASE"
global results 	"PATH TO WHERE THE RESULTS WILL BE STORED"

clear
clear matrix
clear mata
set maxvar 15000


********************************************************************************
********************************************************************************
*************** Loading and preparing the data *********************************
********************************************************************************
********************************************************************************

**************************************
**** Baseline

** Loading the data
use "$data\NAME_DATABASE.dta", clear 		/* Version 5.1 */	

*** Dropping site 22
drop if site_id_l=="site22"

*** Family variables
egen family_rel = max(rel_relationship), by(src_subject_id)
egen weights = max(acs_raked_propensity_score), by(src_subject_id)
egen rel_family_idp = max(rel_family_id), by(src_subject_id)

*keep if family_rel==0
gen 	sibling = 0 if family_rel==0
replace sibling = 1 if family_rel>0

gen 	period = 1 if eventname=="baseline_year_1_arm_1"
replace period = 2 if eventname=="1_year_follow_up_y_arm_1"
replace period = 3 if eventname=="2_year_follow_up_y_arm_1"
replace period = 4 if eventname=="3_year_follow_up_y_arm_1"
keep if period !=.


********************************************************************************
** Mental health, Brief Problem Monitor

foreach v in cbcl_q01_p cbcl_q03_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q21_p cbcl_q22_p cbcl_q23_p cbcl_q35_p cbcl_q41_p cbcl_q50_p cbcl_q52_p cbcl_q71_p cbcl_q78_p cbcl_q86_p cbcl_q95_p cbcl_q97_p cbcl_q103_p cbcl_q112_p ///
              bpmt_q1 bpmt_q2 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q6 bpmt_q7 bpmt_q8 bpmt_q9 bpmt_q10 bpmt_q11 bpmt_q12 bpmt_q13 bpmt_q14 bpmt_q15 bpmt_q16 bpmt_q17 bpmt_q18 {
    tab `v' if `v'==777 | `v'==999
}

********************
*** BPM, teachers

egen ans_t_anx = rownonmiss(bpmt_q10 bpmt_q12 bpmt_q18)
egen bpm_t_anx = rowtotal(bpmt_q10 bpmt_q12 bpmt_q18) if ans_t_anx==3

egen ans_t_dep = rownonmiss(bpmt_q8 bpmt_q11 bpmt_q17)
egen bpm_t_dep = rowtotal(bpmt_q8 bpmt_q11 bpmt_q17) if ans_t_dep==3

egen ans_t_adhd = rownonmiss(bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13)
egen bpm_t_adhd = rowtotal(bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13) if ans_t_adhd==5

egen ans_ty_odd = rownonmiss(bpmt_q2 bpmt_q7 bpmt_q14 bpmt_q15)
egen bpm_ty_odd = rowtotal(bpmt_q2 bpmt_q7 bpmt_q14 bpmt_q15) if ans_ty_odd==4

egen ans_t_int = rownonmiss(bpmt_q10 bpmt_q12 bpmt_q18 bpmt_q8 bpmt_q11 bpmt_q17)
egen bpm_t_int = rowtotal(bpmt_q10 bpmt_q12 bpmt_q18 bpmt_q8 bpmt_q11 bpmt_q17) if ans_t_int==6

egen ans_t_att = rownonmiss(bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13)
egen bpm_t_att = rowtotal(bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13) if ans_t_att==6

egen ans_t_ext = rownonmiss(bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16)
egen bpm_t_ext = rowtotal(bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16) if ans_t_ext==6


*********************
*** BPM, youth
* bpm_y_scr_external_r includes items 6 and 7: Parents and school

foreach v of varlist bpm_1_y-bpm_19_y{
	replace `v' = . if `v'==777 | `v'==999
}

egen ans_y_anx = rownonmiss(bpm_11_y bpm_13_y bpm_19_y)
egen bpm_y_anx = rowtotal(bpm_11_y bpm_13_y bpm_19_y) if ans_y_anx==3

egen ans_y_dep = rownonmiss(bpm_9_y bpm_12_y bpm_18_y)
egen bpm_y_dep = rowtotal(bpm_9_y bpm_12_y bpm_18_y) if ans_y_dep==3

egen ans_y_adhd = rownonmiss(bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y)
egen bpm_y_adhd = rowtotal(bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y) if ans_y_adhd==5

egen ans_yt_odd = rownonmiss(bpm_2_y bpm_8_y bpm_15_y bpm_16_y)
egen bpm_yt_odd = rowtotal(bpm_2_y bpm_8_y bpm_15_y bpm_16_y) if ans_yt_odd==4

egen ans_yc_odd = rownonmiss(bpm_2_y bpm_7_y bpm_15_y bpm_16_y)
egen bpm_yc_odd = rowtotal(bpm_2_y bpm_7_y bpm_15_y bpm_16_y) if ans_yc_odd==4

egen ans_yt_ext = rownonmiss(bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y)
egen bpm_yt_ext = rowtotal(bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y) if ans_yt_ext==6

egen ans_yc_ext = rownonmiss(bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y)
egen bpm_yc_ext = rowtotal(bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y) if ans_yc_ext==6

egen ans_y_int = rownonmiss(bpm_11_y bpm_13_y bpm_19_y bpm_9_y bpm_12_y bpm_18_y)
egen bpm_y_int = rowtotal(bpm_11_y bpm_13_y bpm_19_y bpm_9_y bpm_12_y bpm_18_y) if ans_y_int==6

egen ans_y_att = rownonmiss(bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y)
egen bpm_y_att = rowtotal(bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y) if ans_y_att==6


**************************
*** BPM, caregivers

egen ans_c_anx = rownonmiss(cbcl_q50_p cbcl_q71_p cbcl_q112_p)
egen bpm_c_anx = rowtotal(cbcl_q50_p cbcl_q71_p cbcl_q112_p) if ans_c_anx==3

egen ans_c_dep = rownonmiss(cbcl_q35_p cbcl_q52_p cbcl_q103_p)
egen bpm_c_dep = rowtotal(cbcl_q35_p cbcl_q52_p cbcl_q103_p) if ans_c_dep==3

egen ans_c_adhd = rownonmiss(cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p)
egen bpm_c_adhd = rowtotal(cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p) if ans_c_adhd==5

egen ans_ct_odd = rownonmiss(cbcl_q03_p cbcl_q23_p cbcl_q86_p cbcl_q95_p)
egen bpm_ct_odd = rowtotal(cbcl_q03_p cbcl_q23_p cbcl_q86_p cbcl_q95_p) if ans_ct_odd==4

egen ans_cy_odd = rownonmiss(cbcl_q03_p cbcl_q22_p cbcl_q86_p cbcl_q95_p)
egen bpm_cy_odd = rowtotal(cbcl_q03_p cbcl_q22_p cbcl_q86_p cbcl_q95_p) if ans_cy_odd==4

egen ans_ct_ext = rownonmiss(cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p)
egen bpm_ct_ext = rowtotal(cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p) if ans_ct_ext==6

egen ans_cy_ext = rownonmiss(cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p)
egen bpm_cy_ext = rowtotal(cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p) if ans_cy_ext==6

egen ans_c_int = rownonmiss(cbcl_q50_p cbcl_q71_p cbcl_q112_p cbcl_q35_p cbcl_q52_p cbcl_q103_p)
egen bpm_c_int = rowtotal(cbcl_q50_p cbcl_q71_p cbcl_q112_p cbcl_q35_p cbcl_q52_p cbcl_q103_p) if ans_c_int==6

egen ans_c_att = rownonmiss(cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p)
egen bpm_c_att = rowtotal(cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p) if ans_c_att==6


********************************************************************************
***** Youth's characteristics

gen 	girl_x_y = 1 if demo_sex_v2==2
replace girl_x_y = 0 if demo_sex_v2==1 | demo_sex_v2==3
egen 	girl_y = max(girl_x_y), by(src_subject_id)

gen 	age_y = interview_age/12

tab 	race_ethnicity if wave1==1, gen(race_eth)
egen 	white_y = max(race_eth1), by(src_subject_id)
recode 	white_y (1 = 0) (0 = 1), gen(nonwhite_y)

egen 	immigrant_y = max(foreign_y), by(src_subject_id)

gen 	depre_x_y = cbcl_scr_dsm5_depress_r if wave1==1
egen 	depre_y = mean(depre_x_y), by(src_subject_id)

gen 	puberty_x = puberty_v if wave1==1
egen 	puberty_y = mean(puberty_x), by(src_subject_id) 
egen 	puberty_sdx = std(puberty_x) if wave1==1
egen 	puberty_sd_y = mean(puberty_sdx), by(src_subject_id)

gen 	puberty_px = puberty_pv if wave1==1
egen 	puberty_py = mean(puberty_px), by(src_subject_id) 
egen 	puberty_sdpx = std(puberty_px) if wave1==1
egen 	puberty_sd_py = mean(puberty_sdpx), by(src_subject_id)


********************************************************************************
***** Caregiver's characteristics

*demo_prnt_gender_id_v2 demo_prnt_gender_id_v2_l

gen 	woman_x_p = 1 if demo_prnt_gender_id_v2==2
replace woman_x_p = 0 if demo_prnt_gender_id_v2==1 | (demo_prnt_gender_id_v2>=3 & demo_prnt_gender_id_v2<=6)
egen 	woman_p = max(woman_x_p), by(src_subject_id)

gen 	depre_x_p = asr_scr_depress_r if wave1==1
egen 	depre_p = mean(depre_x_p), by(src_subject_id)
egen 	depre_sdx_p = std(depre_x_p) if wave1==1
egen 	depre_sd_p = mean(depre_sdx_p), by(src_subject_id)

egen 	immigrant_p = max(foreign_p), by(src_subject_id)

gen 	age_prnt = demo_prnt_age_v2 	if period==1
replace age_prnt = demo_prnt_age_v2_l	if period>1 & period<.
replace age_prnt = 42 					if demo_prnt_age_v2_l==1978
replace age_prnt = 23 					if demo_prnt_age_v2_l<18					/* Replacing caregivers' age for the minimum for those whose data show them as underaged (< 18 years old) */

gen 	age_x_p = age_prnt if wave1==1
egen 	age_p = mean(age_x_p), by(src_subject_id)

egen 	white_x_p = max(demo_race_a_p___10), by(src_subject_id)
egen 	white_p = max(white_x_p), by(src_subject_id)
recode 	white_p (1 = 0) (0 = 1), gen(nonwhite_p)

gen 	educ_lev_x = educ_lev if wave1==1
egen 	educ_lev_p = max(educ_lev_x), by(src_subject_id)

tab educ_lev_p, gen(educ_lev_p)


********************************************************************************
***** Social environments

* Not available at the 2y follow up
gen 	pwarmth_x = crpbi_y_ss_parent if wave1==1
egen 	pwarmth_s = mean(pwarmth_x), by(src_subject_id)
egen 	pwarmth_sdx = std(pwarmth_x) if wave1==1
egen 	pwarmth_sd = mean(pwarmth_sdx), by(src_subject_id)

gen 	school_positive_x = school_positive if wave1==1 
egen 	school_positive_s = mean(school_positive_x), by(src_subject_id)
egen 	school_positive_sdx = std(school_positive_x) if wave1==1
egen 	school_positive_sd = mean(school_positive_sdx), by(src_subject_id)

gen 	family_conf_x = fam_confav if wave1==1
egen 	family_conf_s = mean(family_conf_x), by(src_subject_id)
egen 	family_conf_sdx = std(family_conf_x) if wave1==1
egen 	family_conf_sd = mean(family_conf_sdx), by(src_subject_id)

* Only reflective of baseline
gen 	neighborhood_x = reshist_addr1_adi_wsum if wave1==1
egen 	neighborhood_s = mean(neighborhood_x), by(src_subject_id)
egen 	neighborhood_sdx = std(neighborhood_x) if wave1==1
egen 	neighborhood_sd = mean(neighborhood_sdx), by(src_subject_id)


replace neighborhood_s = neighborhood_s/100


********************************************************************************
***** Time-varying standardization

summ asr_scr_depress_r if wave1==1
scalar m_cdp = r(mean)
scalar s_cdp = r(sd)

gen pcdep_z = (asr_scr_depress_r - m_cdp) / s_cdp

summ crpbi_y_ss_parent if wave1==1
scalar m_wrm = r(mean)
scalar s_wrm = r(sd)

gen pwarm_z = (crpbi_y_ss_parent - m_wrm) / s_wrm

summ school_positive if wave1==1
scalar m_sch = r(mean)
scalar s_sch = r(sd)

gen pschool_z = (school_positive - m_sch) / s_sch

summ fam_confav if wave1==1
scalar m_famc = r(mean)
scalar s_famc = r(sd)

gen famconf_z = (fam_confav - m_famc) / s_famc

summ reshist_addr1_adi_wsum if wave1==1
scalar m_nei = r(mean)
scalar s_nei = r(sd)

gen neighborh_z = (reshist_addr1_adi_wsum - m_nei) / s_nei

summ puberty_v if wave1==1
scalar m_pub = r(mean)
scalar s_pub = r(sd)

gen puberty_z = (puberty_y - m_pub) / s_pub


********************************************************************************
***** Linearly interpolating time-varying variables

	sort src_subject_id period
	by src_subject_id: ipolate pcdep_z period, gen(ipcdep_z)
	by src_subject_id: ipolate asr_scr_depress_r period, gen(iasr_depress)
	by src_subject_id: replace iasr_depress = iasr_depress[_n-1] if period==4 & period[_n-1]==3
	by src_subject_id: ipolate pwarm_z period, gen(ipwarm_z)

********************************************************************************
***** Characteristics of the sample

encode site_id_l, gen(rsite_n)
encode site_id_l, gen(site_cat)
egen rel_family_id1 = max(rel_family_id), by(src_subject_id)


********************************************************************************
***** Reporter discrepancies

********************************************************************************	
* Internalzing symptoms

local BPM_T		"bpmt_q10 bpmt_q12 bpmt_q18 bpmt_q8 bpmt_q11 bpmt_q17"
local BPM_Y 	"bpm_11_y bpm_13_y bpm_19_y bpm_9_y bpm_12_y bpm_18_y"
local BPM_C 	"cbcl_q50_p cbcl_q71_p cbcl_q112_p cbcl_q35_p cbcl_q52_p cbcl_q103_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4


	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
						
						* Exact mismatch
						
						gen emm_yc_int`i' = (`y'!=`c') if ans_y_int==6 & ans_c_int==6 
						gen emm_yt_int`i' = (`y'!=`t') if ans_y_int==6 & ans_t_int==6 
						gen emm_ct_int`i' = (`c'!=`t') if ans_c_int==6 & ans_t_int==6 
						
							gen emm_yc_int`i'a = (`y'!=`c' & `y'>`c') if ans_y_int==6 & ans_c_int==6 
							gen emm_yc_int`i'b = (`y'!=`c' & `y'<`c') if ans_y_int==6 & ans_c_int==6 
							
							gen emm_yt_int`i'a = (`y'!=`t' & `y'>`t') if ans_y_int==6 & ans_t_int==6 
							gen emm_yt_int`i'b = (`y'!=`t' & `y'<`t') if ans_y_int==6 & ans_t_int==6 
							
							gen emm_ct_int`i'a = (`c'!=`t' & `c'>`t') if ans_c_int==6 & ans_t_int==6 
							gen emm_ct_int`i'b = (`c'!=`t' & `c'<`t') if ans_c_int==6 & ans_t_int==6 
							
						
						    * Yes vs. No mismatch (youth vs caregiver)
							gen tmm_yc_int`i'  = (((`y'==1 | `y'==2) & `c'==0) | ///
												  (`y'==0 & (`c'==1 | `c'==2))) if ans_y_int==6 & ans_c_int==6 
							gen tmm_yt_int`i'  = (((`y'==1 | `y'==2) & `t'==0) | ///
												  (`y'==0 & (`t'==1 | `t'==2))) if ans_y_int==6 & ans_t_int==6 
							gen tmm_ct_int`i'  = (((`c'==1 | `c'==2) & `t'==0) | ///
												  (`c'==0 & (`t'==1 | `t'==2))) if ans_c_int==6 & ans_t_int==6 

							* Decompose Yes/No mismatch into over- vs under-report
							* youth > caregiver / teacher / caregiver > teacher
							gen tmm_yc_int`i'a = ((`y'==1 | `y'==2) & `c'==0)                        ///
												 if ans_y_int==6 & ans_c_int==6 
							gen tmm_yc_int`i'b = (`y'==0 & (`c'==1 | `c'==2))                        ///
												 if ans_y_int==6 & ans_c_int==6 

							gen tmm_yt_int`i'a = ((`y'==1 | `y'==2) & `t'==0)                        ///
												 if ans_y_int==6 & ans_t_int==6 
							gen tmm_yt_int`i'b = (`y'==0 & (`t'==1 | `t'==2))                        ///
												 if ans_y_int==6 & ans_t_int==6 

							gen tmm_ct_int`i'a = ((`c'==1 | `c'==2) & `t'==0)                        ///
												 if ans_c_int==6 & ans_t_int==6 
							gen tmm_ct_int`i'b = (`c'==0 & (`t'==1 | `t'==2))                        ///
												 if ans_c_int==6 & ans_t_int==6 

							
						* Raw difference in symptoms
						gen rd_yc_int`i' = (`y' - `c') if ans_y_int==6 & ans_c_int==6 
						gen rd_yt_int`i' = (`y' - `t') if ans_y_int==6 & ans_t_int==6 
						gen rd_ct_int`i' = (`c' - `t') if ans_c_int==6 & ans_t_int==6 
						
						* Absolute difference in symptoms
						gen ad_yc_int`i' = abs(`y' - `c') if ans_y_int==6 & ans_c_int==6 
						gen ad_yt_int`i' = abs(`y' - `t') if ans_y_int==6 & ans_t_int==6 
						gen ad_ct_int`i' = abs(`c' - `t') if ans_c_int==6 & ans_t_int==6 
						

				local i = `i' + 1 
				}
	
	***********************
	*** Youth - Caregiver
	* Exact mismatch
		egen emm_yc_int_n = rowtotal(emm_yc_int1 emm_yc_int2 emm_yc_int3 emm_yc_int4 emm_yc_int5 emm_yc_int6) if ans_y_int==6 & ans_c_int==6
			label var emm_yc_int_n "N INT Exact MM, yc"
		gen emm_yc_int_p = emm_yc_int_n/6
			label var emm_yc_int_p "% INT Exact MM, yc"
			
		egen emm_yc_intx_n = rowtotal(emm_yc_int1 emm_yc_int2 emm_yc_int3) if ans_y_int==6 & ans_c_int==6
			label var emm_yc_intx_n "N ANX Exact MM, yc"
		gen emm_yc_intx_p = emm_yc_intx_n/3
			label var emm_yc_intx_p "% ANX Exact MM, yc"		
			
		egen emm_yc_intd_n = rowtotal(emm_yc_int4 emm_yc_int5 emm_yc_int6) if ans_y_int==6 & ans_c_int==6
			label var emm_yc_intd_n "N DEP Exact MM, yc"
		gen emm_yc_intd_p = emm_yc_intd_n/3
			label var emm_yc_intd_p "% DEP Exact MM, yc"
		
	foreach G in a b{
		egen emm_yc_int_n`G' = rowtotal(emm_yc_int1`G' emm_yc_int2`G' emm_yc_int3`G' emm_yc_int4`G' emm_yc_int5`G' emm_yc_int6`G') if ans_y_int==6 & ans_c_int==6
			label var emm_yc_int_n`G' "N INT (`G') Exact MM, yc"
		gen emm_yc_int_p`G' = emm_yc_int_n`G'/6
			label var emm_yc_int_p`G' "% INT (`G') Exact MM, yc"
			
		egen emm_yc_intx_n`G' = rowtotal(emm_yc_int1`G' emm_yc_int2`G' emm_yc_int3`G') if ans_y_int==6 & ans_c_int==6
			label var emm_yc_intx_n`G' "N ANX (`G') Exact MM, yc"
		gen emm_yc_intx_p`G' = emm_yc_intx_n`G'/3
			label var emm_yc_intx_p`G' "% ANX Exact (`G') MM, yc"		
			
		egen emm_yc_intd_n`G' = rowtotal(emm_yc_int4`G' emm_yc_int5`G' emm_yc_int6`G') if ans_y_int==6 & ans_c_int==6
			label var emm_yc_intd_n`G' "N DEP Exact (`G') MM, yc"
		gen emm_yc_intd_p`G' = emm_yc_intd_n`G'/3
			label var emm_yc_intd_p`G' "% DEP Exact (`G') MM, yc"		
		
	}	
		
	* Yes/No mismatch	
	egen tmm_yc_int_n = rowtotal(tmm_yc_int1 tmm_yc_int2 tmm_yc_int3 tmm_yc_int4 tmm_yc_int5 tmm_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_int_n "N INT Yes-No MM, yc"
	gen tmm_yc_int_p = tmm_yc_int_n/6
		label var tmm_yc_int_p "% INT Yes-No MM, yc"

	egen tmm_yc_intx_n = rowtotal(tmm_yc_int1 tmm_yc_int2 tmm_yc_int3) if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_intx_n "N ANX Yes-No MM, yc"
	gen tmm_yc_intx_p = tmm_yc_intx_n/3
		label var tmm_yc_intx_p "% ANX Yes-No MM, yc"

	egen tmm_yc_intd_n = rowtotal(tmm_yc_int4 tmm_yc_int5 tmm_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_intd_n "N DEP Yes-No MM, yc"
	gen tmm_yc_intd_p = tmm_yc_intd_n/3
		label var tmm_yc_intd_p "% DEP Yes-No MM, yc"
		
	foreach G in a b{
		
	egen tmm_yc_int_n`G' = rowtotal(tmm_yc_int1`G' tmm_yc_int2`G' tmm_yc_int3`G' tmm_yc_int4`G' tmm_yc_int5`G' tmm_yc_int6`G') if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_int_n`G' "N INT Yes-No MM, yc"
	gen tmm_yc_int_p`G' = tmm_yc_int_n`G'/6
		label var tmm_yc_int_p`G' "% INT Yes-No MM, yc"

	egen tmm_yc_intx_n`G' = rowtotal(tmm_yc_int1`G' tmm_yc_int2`G' tmm_yc_int3`G') if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_intx_n`G' "N ANX Yes-No MM, yc"
	gen tmm_yc_intx_p`G' = tmm_yc_intx_n`G'/3
		label var tmm_yc_intx_p`G' "% ANX Yes-No MM, yc"

	egen tmm_yc_intd_n`G' = rowtotal(tmm_yc_int4`G' tmm_yc_int5`G' tmm_yc_int6`G') if ans_y_int==6 & ans_c_int==6
		label var tmm_yc_intd_n`G' "N DEP Yes-No MM, yc"
	gen tmm_yc_intd_p`G' = tmm_yc_intd_n`G'/3
		label var tmm_yc_intd_p`G' "% DEP Yes-No MM, yc"		
	}		
	
	* Raw differences
	egen rd_yc_int = rowtotal(rd_yc_int1 rd_yc_int2 rd_yc_int3 rd_yc_int4 rd_yc_int5 rd_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var rd_yc_int "Raw difference INT, yc"
		
	egen rd_yc_intx = rowtotal(rd_yc_int1 rd_yc_int2 rd_yc_int3) if ans_y_int==6 & ans_c_int==6
		label var rd_yc_intx "Raw difference ANX, yc"

	egen rd_yc_intd = rowtotal(rd_yc_int4 rd_yc_int5 rd_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var rd_yc_intd "Raw difference DEP, yc"
		
		
	* Absolute differences
	egen ad_yc_int = rowtotal(ad_yc_int1 ad_yc_int2 ad_yc_int3 ad_yc_int4 ad_yc_int5 ad_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var ad_yc_int "Absolute difference INT, yc"
		
	egen ad_yc_intx = rowtotal(ad_yc_int1 ad_yc_int2 ad_yc_int3) if ans_y_int==6 & ans_c_int==6
		label var ad_yc_intx "Absolute difference ANX, yc"

	egen ad_yc_intd = rowtotal(ad_yc_int4 ad_yc_int5 ad_yc_int6) if ans_y_int==6 & ans_c_int==6
		label var ad_yc_intd "Absolute difference DEP, yc"		
		
		

	*** Saving the results		
	* Exact mismatch
	tabstat emm_yc_int_p emm_yc_intx_p emm_yc_int1 emm_yc_int2 emm_yc_int3 emm_yc_intd_p emm_yc_int4 emm_yc_int5 emm_yc_int6 if ans_y_int==6 & ans_c_int==6, save
		matrix IE_yc = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat emm_yc_int_p emm_yc_intx_p emm_yc_int1 emm_yc_int2 emm_yc_int3 emm_yc_intd_p emm_yc_int4 emm_yc_int5 emm_yc_int6 if ans_y_int==6 & ans_c_int==6 & period==`P', save
			matrix IEMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix IEMMp_yc = IE_yc, IEMMp_yc2, IEMMp_yc3, IEMMp_yc4

	tabstat emm_yc_int_na emm_yc_int_pa emm_yc_intx_pa emm_yc_int1a emm_yc_int2a emm_yc_int3a emm_yc_intd_pa emm_yc_int4a emm_yc_int5a emm_yc_int6a if ans_y_int==6 & ans_c_int==6, save
		matrix IEa_yc = r(StatTotal)'
	tabstat emm_yc_int_nb emm_yc_int_pb emm_yc_intx_pb emm_yc_int1b emm_yc_int2b emm_yc_int3b emm_yc_intd_pb emm_yc_int4b emm_yc_int5b emm_yc_int6b if ans_y_int==6 & ans_c_int==6, save
		matrix IEb_yc = r(StatTotal)'		
	
	* Yes-No mismatch
	tabstat tmm_yc_int_p tmm_yc_intx_p tmm_yc_int1 tmm_yc_int2 tmm_yc_int3 tmm_yc_intd_p tmm_yc_int4 tmm_yc_int5 tmm_yc_int6 if ans_y_int==6 & ans_c_int==6, save
		matrix IT_yc = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat tmm_yc_int_p tmm_yc_intx_p tmm_yc_int1 tmm_yc_int2 tmm_yc_int3 tmm_yc_intd_p tmm_yc_int4 tmm_yc_int5 tmm_yc_int6 if ans_y_int==6 & ans_c_int==6 & period==`P', save
			matrix ITMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix ITMMp_yc = IT_yc, ITMMp_yc2, ITMMp_yc3, ITMMp_yc4
	
	tabstat tmm_yc_int_na tmm_yc_int_pa tmm_yc_intx_pa tmm_yc_int1a tmm_yc_int2a tmm_yc_int3a tmm_yc_intd_pa tmm_yc_int4a tmm_yc_int5a tmm_yc_int6a, save
		matrix ITa_yc = r(StatTotal)'
	tabstat tmm_yc_int_nb tmm_yc_int_pb tmm_yc_intx_pb tmm_yc_int1b tmm_yc_int2b tmm_yc_int3b tmm_yc_intd_pb tmm_yc_int4b tmm_yc_int5b tmm_yc_int6b, save
		matrix ITb_yc = r(StatTotal)'
		
	* Raw difference	
	tabstat rd_yc_int rd_yc_intx rd_yc_int1 rd_yc_int2 rd_yc_int3 rd_yc_intd rd_yc_int4 rd_yc_int5 rd_yc_int6, save
		matrix ID_yc = r(StatTotal)'

		forvalues P=2/4{
		tabstat rd_yc_int rd_yc_intx rd_yc_int1 rd_yc_int2 rd_yc_int3 rd_yc_intd rd_yc_int4 rd_yc_int5 rd_yc_int6 if ans_y_int==6 & ans_c_int==6 & period==`P', save
			matrix IDp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix IDp_yc = IDp_yc2, IDp_yc3, IDp_yc4
	
	*** By reporter and period
	tabstat bpm_y_int bpm_y_anx bpm_11_y bpm_13_y bpm_19_y bpm_y_dep bpm_9_y bpm_12_y bpm_18_y if ans_y_int==6 & ans_c_int==6, save
		matrix IS_yc1 = r(StatTotal)'
	tabstat bpm_c_int bpm_c_anx cbcl_q50_p cbcl_q71_p cbcl_q112_p bpm_c_dep cbcl_q35_p cbcl_q52_p cbcl_q103_p if ans_y_int==6 & ans_c_int==6, save
		matrix IS_yc2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_y_int bpm_y_anx bpm_11_y bpm_13_y bpm_19_y bpm_y_dep bpm_9_y bpm_12_y bpm_18_y if ans_y_int==6 & ans_c_int==6 & period==`P', save
			matrix IS_yc`P'1 = r(StatTotal)'
		tabstat bpm_c_int bpm_c_anx cbcl_q50_p cbcl_q71_p cbcl_q112_p bpm_c_dep cbcl_q35_p cbcl_q52_p cbcl_q103_p if ans_y_int==6 & ans_c_int==6 & period==`P', save
			matrix IS_yc`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youht-caregiver
	matrix ID_yc = IS_yc1, IS_yc2, ID_yc, IDp_yc
	
	
	**********************
	*** Youth - Teacher
	* Exact mismatch
	egen emm_yt_int_n = rowtotal(emm_yt_int1 emm_yt_int2 emm_yt_int3 emm_yt_int4 emm_yt_int5 emm_yt_int6) if ans_y_int==6 & ans_t_int==6
		label var emm_yt_int_n "N INT Exact MM, yt"
	gen emm_yt_int_p = emm_yt_int_n/6
		label var emm_yt_int_p "% INT Exact MM, yt"
		
	egen emm_yt_intx_n = rowtotal(emm_yt_int1 emm_yt_int2 emm_yt_int3) if ans_y_int==6 & ans_t_int==6
		label var emm_yt_intx_n "N ANX Exact MM, yt"
	gen emm_yt_intx_p = emm_yt_intx_n/3
		label var emm_yt_intx_p "% ANX Exact MM, yt"		
			
	egen emm_yt_intd_n = rowtotal(emm_yt_int4 emm_yt_int5 emm_yt_int6) if ans_y_int==6 & ans_t_int==6
		label var emm_yt_intd_n "N DEP Exact MM, yt"
	gen emm_yt_intd_p = emm_yt_intd_n/3
		label var emm_yt_intd_p "% DEP Exact MM, yt"
		
	* Yes/No mismatch
	egen tmm_yt_int_n = rowtotal(tmm_yt_int1 tmm_yt_int2 tmm_yt_int3 tmm_yt_int4 tmm_yt_int5 tmm_yt_int6) if ans_y_int==6 & ans_t_int==6
		label var tmm_yt_int_n "N INT Yes-No MM, yt"
	gen tmm_yt_int_p = tmm_yt_int_n/6
		label var tmm_yt_int_p "% INT Yes-No MM, yt"
		
	egen tmm_yt_intx_n = rowtotal(tmm_yt_int1 tmm_yt_int2 tmm_yt_int3) if ans_y_int==6 & ans_t_int==6
		label var tmm_yt_intx_n "N ANX Yes-No MM, yt"
	gen tmm_yt_intx_p = tmm_yt_intx_n/3
		label var tmm_yt_intx_p "% ANX Yes-No MM, yt"
		
	egen tmm_yt_intd_n = rowtotal(tmm_yt_int4 tmm_yt_int5 tmm_yt_int6) if ans_y_int==6 & ans_t_int==6
		label var tmm_yt_intd_n "N INT Yes-No MM, yt"
	gen tmm_yt_intd_p = tmm_yt_intd_n/3
		label var tmm_yt_intd_p "% INT Yes-No MM, yt"		
	
	* Raw difference
	egen rd_yt_int = rowtotal(rd_yt_int1 rd_yt_int2 rd_yt_int3 rd_yt_int4 rd_yt_int5 rd_yt_int6) if ans_y_int==6 & ans_t_int==6
			label var rd_yt_int "Raw difference INT, yt"
			
	egen rd_yt_intx = rowtotal(rd_yt_int1 rd_yt_int2 rd_yt_int3) if ans_y_int==6 & ans_t_int==6
			label var rd_yt_intx "Raw difference ANX, yt"			

	egen rd_yt_intd = rowtotal(rd_yt_int4 rd_yt_int5 rd_yt_int6) if ans_y_int==6 & ans_t_int==6
			label var rd_yt_intd "Raw difference DEP, yt"
			
	* Absolute difference
	egen ad_yt_int = rowtotal(ad_yt_int1 ad_yt_int2 ad_yt_int3 ad_yt_int4 ad_yt_int5 ad_yt_int6) if ans_y_int==6 & ans_t_int==6
			label var ad_yt_int "Absolute difference INT, yt"
			
	egen ad_yt_intx = rowtotal(ad_yt_int1 ad_yt_int2 ad_yt_int3) if ans_y_int==6 & ans_t_int==6
			label var ad_yt_intx "Absolute difference ANX, yt"			

	egen ad_yt_intd = rowtotal(ad_yt_int4 ad_yt_int5 ad_yt_int6) if ans_y_int==6 & ans_t_int==6
			label var ad_yt_intd "Absolute difference DEP, yt"
			
			
	*** Saving the results
	* Exact mismatch
	tabstat emm_yt_int_p emm_yt_intx_p emm_yt_int1 emm_yt_int2 emm_yt_int3 emm_yt_intd_p emm_yt_int4 emm_yt_int5 emm_yt_int6 if ans_y_int==6 & ans_t_int==6 & period!=1, save
		matrix IE_yt = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat emm_yt_int_p emm_yt_intx_p emm_yt_int1 emm_yt_int2 emm_yt_int3 emm_yt_intd_p emm_yt_int4 emm_yt_int5 emm_yt_int6 if ans_y_int==6 & ans_t_int==6 & period==`P', save
			matrix IEMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix IEMMp_yt = IE_yt, IEMMp_yt2, IEMMp_yt3, IEMMp_yt4
	
	* Yes/No mismatch
	tabstat tmm_yt_int_p tmm_yt_intx_p tmm_yt_int1 tmm_yt_int2 tmm_yt_int3 tmm_yt_intd_p tmm_yt_int4 tmm_yt_int5 tmm_yt_int6 if ans_y_int==6 & ans_t_int==6 & period!=1, save
		matrix IT_yt = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat tmm_yt_int_p tmm_yt_intx_p tmm_yt_int1 tmm_yt_int2 tmm_yt_int3 tmm_yt_intd_p tmm_yt_int4 tmm_yt_int5 tmm_yt_int6 if ans_y_int==6 & ans_t_int==6 & period==`P', save
			matrix ITMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix ITMMp_yt = IT_yt, ITMMp_yt2, ITMMp_yt3, ITMMp_yt4
	
	* Raw differences
	tabstat rd_yt_int rd_yt_intx rd_yt_int1 rd_yt_int2 rd_yt_int3 rd_yt_intd rd_yt_int4 rd_yt_int5 rd_yt_int6 if ans_y_int==6 & ans_t_int==6 & period!=1, save
		matrix ID_yt = r(StatTotal)'

		forvalues P=2/4{
		tabstat rd_yt_int rd_yt_intx rd_yt_int1 rd_yt_int2 rd_yt_int3 rd_yt_intd rd_yt_int4 rd_yt_int5 rd_yt_int6 if ans_y_int==6 & ans_t_int==6 & period==`P', save
			matrix IDp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix IDp_yt = IDp_yt2, IDp_yt3, IDp_yt4	
	
	*** By reporter and period
	tabstat bpm_y_int bpm_y_anx bpm_11_y bpm_13_y bpm_19_y bpm_y_dep bpm_9_y bpm_12_y bpm_18_y if ans_y_int==6 & ans_t_int==6 & period!=1, save
		matrix IS_yt1 = r(StatTotal)'
	tabstat bpm_t_int bpm_t_anx bpmt_q10 bpmt_q12 bpmt_q18 bpm_t_dep bpmt_q8 bpmt_q11 bpmt_q17 if ans_y_int==6 & ans_t_int==6 & period!=1, save
		matrix IS_yt2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_y_int bpm_y_anx bpm_11_y bpm_13_y bpm_19_y bpm_y_dep bpm_9_y bpm_12_y bpm_18_y if ans_y_int==6 & ans_t_int==6 & period==`P', save
			matrix IS_yt`P'1 = r(StatTotal)'
		tabstat bpm_t_int bpm_t_anx bpmt_q10 bpmt_q12 bpmt_q18 bpm_t_dep bpmt_q8 bpmt_q11 bpmt_q17 if ans_y_int==6 & ans_t_int==6 & period==`P', save
			matrix IS_yt`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-teacher
	matrix ID_yt = IS_yt1, IS_yt2, ID_yt, IDp_yt
	
	
	
	******************************
	*** Caregiver - Teacher
	* Exact mismatch
	egen emm_ct_int_n = rowtotal(emm_ct_int1 emm_ct_int2 emm_ct_int3 emm_ct_int4 emm_ct_int5 emm_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var emm_ct_int_n "N INT Exact MM, ct"
	gen emm_ct_int_p = emm_ct_int_n/6
		label var emm_ct_int_p "% INT Exact MM, ct"
		
	egen emm_ct_intx_n = rowtotal(emm_ct_int1 emm_ct_int2 emm_ct_int3) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var emm_ct_intx_n "N ANX Exact MM, ct"
	gen emm_ct_intx_p = emm_ct_intx_n/3
		label var emm_ct_intx_p "% ANX Exact MM, ct"		

	egen emm_ct_intd_n = rowtotal(emm_ct_int4 emm_ct_int5 emm_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var emm_ct_intd_n "N DEP Exact MM, ct"
	gen emm_ct_intd_p = emm_ct_intd_n/3
		label var emm_ct_intd_p "% DEP Exact MM, ct"		
		
	* Yes/No mismatch	
	egen tmm_ct_int_n = rowtotal(tmm_ct_int1 tmm_ct_int2 tmm_ct_int3 tmm_ct_int4 tmm_ct_int5 tmm_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var tmm_ct_int_n "N INT Yes-No MM, ct"
	gen tmm_ct_int_p = tmm_ct_int_n/6
		label var tmm_ct_int_p "% INT Yes-No MM, ct"

	egen tmm_ct_intx_n = rowtotal(tmm_ct_int1 tmm_ct_int2 tmm_ct_int3) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var tmm_ct_intx_n "N INT Yes-No MM, ct"
	gen tmm_ct_intx_p = tmm_ct_intx_n/3
		label var tmm_ct_intx_p "% INT Yes-No MM, ct"

	egen tmm_ct_intd_n = rowtotal(tmm_ct_int4 tmm_ct_int5 tmm_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var tmm_ct_intd_n "N INT Yes-No MM, ct"
	gen tmm_ct_intd_p = tmm_ct_intd_n/3
		label var tmm_ct_intd_p "% INT Yes-No MM, ct"
		
	* Raw difference
	egen rd_ct_int = rowtotal(rd_ct_int1 rd_ct_int2 rd_ct_int3 rd_ct_int4 rd_ct_int5 rd_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var rd_ct_int "Raw difference INT, ct"	
		
	egen rd_ct_intx = rowtotal(rd_ct_int1 rd_ct_int2 rd_ct_int3) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var rd_ct_intx "Raw difference INT, ct"	
		
	egen rd_ct_intd = rowtotal(rd_ct_int4 rd_ct_int5 rd_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var rd_ct_intd "Raw difference INT, ct"
		
	* Absolute difference
	egen ad_ct_int = rowtotal(ad_ct_int1 ad_ct_int2 ad_ct_int3 ad_ct_int4 ad_ct_int5 ad_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var ad_ct_int "Absolute difference INT, ct"	
		
	egen ad_ct_intx = rowtotal(ad_ct_int1 ad_ct_int2 ad_ct_int3) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var ad_ct_intx "Absolute difference INT, ct"	
		
	egen ad_ct_intd = rowtotal(ad_ct_int4 ad_ct_int5 ad_ct_int6) if ans_c_int==6 & ans_t_int==6 & period!=1
		label var ad_ct_intd "Absolute difference INT, ct"		
		
			
	*** Saving the results
	* Exact mismatch
	tabstat emm_ct_int_p emm_ct_intx_p emm_ct_int1 emm_ct_int2 emm_ct_int3 emm_ct_intd_p emm_ct_int4 emm_ct_int5 emm_ct_int6 if ans_c_int==6 & ans_t_int==6 & period!=1, save
		matrix IE_ct = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat emm_ct_int_p emm_ct_intx_p emm_ct_int1 emm_ct_int2 emm_ct_int3 emm_ct_intd_p emm_ct_int4 emm_ct_int5 emm_ct_int6 if ans_c_int==6 & ans_t_int==6 & period==`P', save
			matrix IEMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix IEMMp_ct = IE_ct, IEMMp_ct2, IEMMp_ct3, IEMMp_ct4
	
	* Yes/No mismatch
	tabstat tmm_ct_int_p tmm_ct_intx_p tmm_ct_int1 tmm_ct_int2 tmm_ct_int3 tmm_ct_intd_p tmm_ct_int4 tmm_ct_int5 tmm_ct_int6 if ans_c_int==6 & ans_t_int==6 & period!=1, save
		matrix IT_ct = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat tmm_ct_int_p tmm_ct_intx_p tmm_ct_int1 tmm_ct_int2 tmm_ct_int3 tmm_ct_intd_p tmm_ct_int4 tmm_ct_int5 tmm_ct_int6 if ans_c_int==6 & ans_t_int==6 & period==`P', save
			matrix ITMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix ITMMp_ct = IT_ct, ITMMp_ct2, ITMMp_ct3, ITMMp_ct4
	
	* Raw differences
	tabstat rd_ct_int rd_ct_intx rd_ct_int1 rd_ct_int2 rd_ct_int3 rd_ct_intd rd_ct_int4 rd_ct_int5 rd_ct_int6 if ans_c_int==6 & ans_t_int==6 & period!=1, save
		matrix ID_ct = r(StatTotal)'

		forvalues P=2/4{
		tabstat rd_ct_int rd_ct_intx rd_ct_int1 rd_ct_int2 rd_ct_int3 rd_ct_intd rd_ct_int4 rd_ct_int5 rd_ct_int6 if ans_c_int==6 & ans_t_int==6 & period==`P', save
			matrix IDp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix IDp_ct = IDp_ct2, IDp_ct3, IDp_ct4	
	
	*** By reporter and period
	tabstat bpm_c_int bpm_c_anx cbcl_q50_p cbcl_q71_p cbcl_q112_p bpm_c_dep cbcl_q35_p cbcl_q52_p cbcl_q103_p if ans_c_int==6 & ans_t_int==6 & period!=1, save
		matrix IS_ct1 = r(StatTotal)'
	tabstat bpm_t_int bpm_t_anx bpmt_q10 bpmt_q12 bpmt_q18 bpm_t_dep bpmt_q8 bpmt_q11 bpmt_q17 if ans_c_int==6 & ans_t_int==6 & period!=1, save
		matrix IS_ct2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_c_int bpm_c_anx cbcl_q50_p cbcl_q71_p cbcl_q112_p bpm_c_dep cbcl_q35_p cbcl_q52_p cbcl_q103_p if ans_c_int==6 & ans_t_int==6 & period==`P', save
			matrix IS_ct`P'1 = r(StatTotal)'
		tabstat bpm_t_int bpm_t_anx bpmt_q10 bpmt_q12 bpmt_q18 bpm_t_dep bpmt_q8 bpmt_q11 bpmt_q17 if ans_c_int==6 & ans_t_int==6 & period==`P', save
			matrix IS_ct`P'2 = r(StatTotal)'
				
	}	
		
	** Difference caregiver-teacher
	matrix ID_ct = IS_ct1, IS_ct2, ID_ct, IDp_ct
		
		
		
	*****************************************************
	*** Exporting results for internalizing symptoms
	
	* Exact Mismatch
	matrix IEM = IEMMp_yc \ IEMMp_yt \ IEMMp_ct
		matrix IMM = IE_yc, IT_yc, IE_yt, IT_yt, IE_ct, IT_ct
	
	* Yes-No Mismatch
	matrix ITM = ITMMp_yc \ ITMMp_yt \ ITMMp_ct
	
	* Raw differences
	matrix ID = ID_yc \ ID_yt \ ID_ct
	
	
********************************************************************************
********************************************************************************
*** t-tests
		
matrix Ittyc = J(9,12,.)
matrix Ittyt = J(9,12,.)
matrix Ittct = J(9,12,.)

matrix IttycSD = J(9,12,.)
matrix IttytSD = J(9,12,.)
matrix IttctSD = J(9,12,.)

matrix IttycG = J(9,24,.)
matrix IttytG = J(9,24,.)
matrix IttctG = J(9,24,.)

local BPM_T		"bpm_t_int bpm_t_anx bpmt_q10 bpmt_q12 bpmt_q18 bpm_t_dep bpmt_q8 bpmt_q11 bpmt_q17"
local BPM_Y 	"bpm_y_int bpm_y_anx bpm_11_y bpm_13_y bpm_19_y bpm_y_dep bpm_9_y bpm_12_y bpm_18_y"
local BPM_C 	"bpm_c_int bpm_c_anx cbcl_q50_p cbcl_q71_p cbcl_q112_p bpm_c_dep cbcl_q35_p cbcl_q52_p cbcl_q103_p"

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
					
						** Youth-caregiver
						ttest `c' == `y' if ans_y_int==6 & ans_c_int==6
							matrix Ittyc[`i',1] = r(N_1)
							matrix Ittyc[`i',2] = r(mu_2) - r(mu_1)
							matrix Ittyc[`i',3] = r(p)
							
							matrix IttycSD[`i',1] = -1 * r(mu_diff)
							matrix IttycSD[`i',2] = r(sd_diff)
							matrix IttycSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix IttycG[`i',1] = r(N_1)
							matrix IttycG[`i',2] = r(mu_2)
							matrix IttycG[`i',3] = r(mu_1)
							matrix IttycG[`i',4] = r(mu_2) - r(mu_1)
							matrix IttycG[`i',5] = r(se)
							matrix IttycG[`i',6] = r(p)
						
						
						ttest `c' == `y' if ans_y_int==6 & ans_c_int==6 & period==2
							matrix Ittyc[`i',4] = r(N_1)
							matrix Ittyc[`i',5] = r(mu_2) - r(mu_1)
							matrix Ittyc[`i',6] = r(p)
							
							matrix IttycSD[`i',4] = -1 * r(mu_diff)
							matrix IttycSD[`i',5] = r(sd_diff)
							matrix IttycSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix IttycG[`i',7] = r(N_1)
							matrix IttycG[`i',8] = r(mu_2)
							matrix IttycG[`i',9] = r(mu_1)
							matrix IttycG[`i',10] = r(mu_2) - r(mu_1)
							matrix IttycG[`i',11] = r(se)
							matrix IttycG[`i',12] = r(p)
						
						ttest `c' == `y' if ans_y_int==6 & ans_c_int==6 & period==3
							matrix Ittyc[`i',7] = r(N_1)
							matrix Ittyc[`i',8] = r(mu_2) - r(mu_1)
							matrix Ittyc[`i',9] = r(p)
							
							matrix IttycSD[`i',7] = -1 * r(mu_diff)
							matrix IttycSD[`i',8] = r(sd_diff)
							matrix IttycSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix IttycG[`i',13] = r(N_1)
							matrix IttycG[`i',14] = r(mu_2)
							matrix IttycG[`i',15] = r(mu_1)
							matrix IttycG[`i',16] = r(mu_2) - r(mu_1)
							matrix IttycG[`i',17] = r(se)
							matrix IttycG[`i',18] = r(p)
							
						
						ttest `c' == `y' if ans_y_int==6 & ans_c_int==6 & period==4
							matrix Ittyc[`i',10] = r(N_1)
							matrix Ittyc[`i',11] = r(mu_2) - r(mu_1)
							matrix Ittyc[`i',12] = r(p)
							
							matrix IttycSD[`i',10] = -1 * r(mu_diff)
							matrix IttycSD[`i',11] = r(sd_diff)
							matrix IttycSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix IttycG[`i',19] = r(N_1)
							matrix IttycG[`i',20] = r(mu_2)
							matrix IttycG[`i',21] = r(mu_1)
							matrix IttycG[`i',22] = r(mu_2) - r(mu_1)
							matrix IttycG[`i',23] = r(se)
							matrix IttycG[`i',24] = r(p)							
							
						** Youth-teacher
						ttest `t' == `y' if ans_y_int==6 & ans_t_int==6
							matrix Ittyt[`i',1] = r(N_1)
							matrix Ittyt[`i',2] = r(mu_2) - r(mu_1)
							matrix Ittyt[`i',3] = r(p)

							matrix IttytSD[`i',1] = -1 * r(mu_diff)
							matrix IttytSD[`i',2] = r(sd_diff)
							matrix IttytSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix IttytG[`i',1] = r(N_1)
							matrix IttytG[`i',2] = r(mu_2)
							matrix IttytG[`i',3] = r(mu_1)
							matrix IttytG[`i',4] = r(mu_2) - r(mu_1)
							matrix IttytG[`i',5] = r(se)
							matrix IttytG[`i',6] = r(p)
							
						ttest `t' == `y' if ans_y_int==6 & ans_t_int==6 & period==2
							matrix Ittyt[`i',4] = r(N_1)
							matrix Ittyt[`i',5] = r(mu_2) - r(mu_1)
							matrix Ittyt[`i',6] = r(p)
							
							matrix IttytSD[`i',4] = -1 * r(mu_diff)
							matrix IttytSD[`i',5] = r(sd_diff)
							matrix IttytSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix IttytG[`i',7] = r(N_1)
							matrix IttytG[`i',8] = r(mu_2)
							matrix IttytG[`i',9] = r(mu_1)
							matrix IttytG[`i',10] = r(mu_2) - r(mu_1)
							matrix IttytG[`i',11] = r(se)
							matrix IttytG[`i',12] = r(p)

							
						ttest `t' == `y' if ans_y_int==6 & ans_t_int==6 & period==3
							matrix Ittyt[`i',7] = r(N_1)
							matrix Ittyt[`i',8] = r(mu_2) - r(mu_1)
							matrix Ittyt[`i',9] = r(p)

							matrix IttytSD[`i',7] = -1 * r(mu_diff)
							matrix IttytSD[`i',8] = r(sd_diff)
							matrix IttytSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix IttytG[`i',13] = r(N_1)
							matrix IttytG[`i',14] = r(mu_2)
							matrix IttytG[`i',15] = r(mu_1)
							matrix IttytG[`i',16] = r(mu_2) - r(mu_1)
							matrix IttytG[`i',17] = r(se)
							matrix IttytG[`i',18] = r(p)

							
						ttest `t' == `y' if ans_y_int==6 & ans_t_int==6 & period==4
							matrix Ittyt[`i',10] = r(N_1)
							matrix Ittyt[`i',11] = r(mu_2) - r(mu_1)
							matrix Ittyt[`i',12] = r(p)	
							
							matrix IttytSD[`i',10] = -1 * r(mu_diff)
							matrix IttytSD[`i',11] = r(sd_diff)
							matrix IttytSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix IttytG[`i',19] = r(N_1)
							matrix IttytG[`i',20] = r(mu_2)
							matrix IttytG[`i',21] = r(mu_1)
							matrix IttytG[`i',22] = r(mu_2) - r(mu_1)
							matrix IttytG[`i',23] = r(se)
							matrix IttytG[`i',24] = r(p)
							
							
						** Caregiver-teacher
						ttest `t' == `c' if ans_c_int==6 & ans_t_int==6 & period!=1
							matrix Ittct[`i',1] = r(N_1)
							matrix Ittct[`i',2] = r(mu_2) - r(mu_1)
							matrix Ittct[`i',3] = r(p)
							
							matrix IttctSD[`i',1] = -1 * r(mu_diff)
							matrix IttctSD[`i',2] = r(sd_diff)
							matrix IttctSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)							

							matrix IttctG[`i',1] = r(N_1)
							matrix IttctG[`i',2] = r(mu_2)
							matrix IttctG[`i',3] = r(mu_1)
							matrix IttctG[`i',4] = r(mu_2) - r(mu_1)
							matrix IttctG[`i',5] = r(se)
							matrix IttctG[`i',6] = r(p)

							
						ttest `t' == `c' if ans_c_int==6 & ans_t_int==6 & period==2
							matrix Ittct[`i',4] = r(N_1)
							matrix Ittct[`i',5] = r(mu_2) - r(mu_1)
							matrix Ittct[`i',6] = r(p)

							matrix IttctSD[`i',4] = -1 * r(mu_diff)
							matrix IttctSD[`i',5] = r(sd_diff)
							matrix IttctSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)		
							
							matrix IttctG[`i',7] = r(N_1)
							matrix IttctG[`i',8] = r(mu_2)
							matrix IttctG[`i',9] = r(mu_1)
							matrix IttctG[`i',10] = r(mu_2) - r(mu_1)
							matrix IttctG[`i',11] = r(se)
							matrix IttctG[`i',12] = r(p)

							
						ttest `t' == `c' if ans_c_int==6 & ans_t_int==6 & period==3
							matrix Ittct[`i',7] = r(N_1)
							matrix Ittct[`i',8] = r(mu_2) - r(mu_1)
							matrix Ittct[`i',9] = r(p)
							
							matrix IttctSD[`i',7] = -1 * r(mu_diff)
							matrix IttctSD[`i',8] = r(sd_diff)
							matrix IttctSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)									
							
							matrix IttctG[`i',13] = r(N_1)
							matrix IttctG[`i',14] = r(mu_2)
							matrix IttctG[`i',15] = r(mu_1)
							matrix IttctG[`i',16] = r(mu_2) - r(mu_1)
							matrix IttctG[`i',17] = r(se)
							matrix IttctG[`i',18] = r(p)
							
							
						ttest `t' == `c' if ans_c_int==6 & ans_t_int==6 & period==4
							matrix Ittct[`i',10] = r(N_1)
							matrix Ittct[`i',11] = r(mu_2) - r(mu_1)
							matrix Ittct[`i',12] = r(p)	
							
							matrix IttctSD[`i',10] = -1 * r(mu_diff)
							matrix IttctSD[`i',11] = r(sd_diff)
							matrix IttctSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)									
							
							matrix IttctG[`i',19] = r(N_1)
							matrix IttctG[`i',20] = r(mu_2)
							matrix IttctG[`i',21] = r(mu_1)
							matrix IttctG[`i',22] = r(mu_2) - r(mu_1)
							matrix IttctG[`i',23] = r(se)
							matrix IttctG[`i',24] = r(p)
						
					
					local i = `i' + 1 
				}
				
				
********************************************************************************	
********************************************************************************	
********************************************************************************	
* Inattention symptoms


local BPM_T		"bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13"
local BPM_Y 	"bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y"
local BPM_C 	"cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
						
						* Exact mismatch
						
						gen emm_yc_att`i' = (`y'!=`c') if ans_y_att==6 & ans_c_att==6 
						gen emm_yt_att`i' = (`y'!=`t') if ans_y_att==6 & ans_t_att==6 
						gen emm_ct_att`i' = (`c'!=`t') if ans_c_att==6 & ans_t_att==6 
						
						* Yes vs. No mismatch
						gen tmm_yc_att`i' = (((`y'==1 | `y'==2) & `c'==0) | (`y'==0 & (`c'==1 | `c'==2))) if ans_y_att==6 & ans_c_att==6 
						gen tmm_yt_att`i' = (((`y'==1 | `y'==2) & `t'==0) | (`y'==0 & (`t'==1 | `t'==2))) if ans_y_att==6 & ans_t_att==6 
						gen tmm_ct_att`i' = (((`c'==1 | `c'==2) & `t'==0) | (`c'==0 & (`t'==1 | `t'==2))) if ans_c_att==6 & ans_t_att==6 
						
						 * Decompose Yes/No mismatch into over- vs under-report
						* youth > caregiver / teacher / caregiver > teacher
						gen tmm_yc_att`i'a = ((`y'==1 | `y'==2) & `c'==0)                        ///
											 if ans_y_att==6 & ans_c_att==6 
						gen tmm_yc_att`i'b = (`y'==0 & (`c'==1 | `c'==2))                        ///
											 if ans_y_att==6 & ans_c_att==6 

						gen tmm_yt_att`i'a = ((`y'==1 | `y'==2) & `t'==0)                        ///
											 if ans_y_att==6 & ans_t_att==6 
						gen tmm_yt_att`i'b = (`y'==0 & (`t'==1 | `t'==2))                        ///
											 if ans_y_att==6 & ans_t_att==6 

						gen tmm_ct_att`i'a = ((`c'==1 | `c'==2) & `t'==0)                        ///
											 if ans_c_att==6 & ans_t_att==6 
						gen tmm_ct_att`i'b = (`c'==0 & (`t'==1 | `t'==2))                        ///
											 if ans_c_att==6 & ans_t_att==6 
						
						* Raw difference in symptoms
						gen rd_yc_att`i' = (`y' - `c') if ans_y_att==6 & ans_c_att==6 
						gen rd_yt_att`i' = (`y' - `t') if ans_y_att==6 & ans_t_att==6 
						gen rd_ct_att`i' = (`c' - `t') if ans_c_att==6 & ans_t_att==6 
						
						* Absolute difference in symptoms
						gen ad_yc_att`i' = abs(`y' - `c') if ans_y_att==6 & ans_c_att==6 
						gen ad_yt_att`i' = abs(`y' - `t') if ans_y_att==6 & ans_t_att==6 
						gen ad_ct_att`i' = abs(`c' - `t') if ans_c_att==6 & ans_t_att==6 
						
				local i = `i' + 1 
				}
				
	**************************	
	*** Youth - Caregiver
	egen emm_yc_att_n = rowtotal(emm_yc_att1 emm_yc_att2 emm_yc_att3 emm_yc_att4 emm_yc_att5 emm_yc_att6) if ans_y_att==6 & ans_c_att==6
		label var emm_yc_att_n "N att Exact MM, yc"
	gen emm_yc_att_p = emm_yc_att_n/6
		label var emm_yc_att_p "% att Exact MM, yc"
		
	egen tmm_yc_att_n = rowtotal(tmm_yc_att1 tmm_yc_att2 tmm_yc_att3 tmm_yc_att4 tmm_yc_att5 tmm_yc_att6) if ans_y_att==6 & ans_c_att==6
		label var tmm_yc_att_n "N att Yes-No MM, yc"
	gen tmm_yc_att_p = tmm_yc_att_n/6
		label var tmm_yc_att_p "% att Yes-No MM, yc"
				
	egen rd_yc_att = rowtotal(rd_yc_att1 rd_yc_att2 rd_yc_att3 rd_yc_att4 rd_yc_att5 rd_yc_att6) if ans_y_att==6 & ans_c_att==6
		label var rd_yc_att "Raw difference ATT, yc"	
		
	egen ad_yc_att = rowtotal(ad_yc_att1 ad_yc_att2 ad_yc_att3 ad_yc_att4 ad_yc_att5 ad_yc_att6) if ans_y_att==6 & ans_c_att==6
		label var ad_yc_att "Absolute difference ATT, yc"			
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_yc_att_p emm_yc_att1 emm_yc_att2 emm_yc_att3 emm_yc_att4 emm_yc_att5 emm_yc_att6 if ans_y_att==6 & ans_c_att==6, save
		matrix AE_yc = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_yc_att_p emm_yc_att1 emm_yc_att2 emm_yc_att3 emm_yc_att4 emm_yc_att5 emm_yc_att6 if ans_y_att==6 & ans_c_att==6 & period==`P', save
			matrix AEMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix AEMMp_yc = AE_yc, AEMMp_yc2, AEMMp_yc3, AEMMp_yc4		
		
	* Yes/No mismatch
	tabstat tmm_yc_att_p tmm_yc_att1 tmm_yc_att2 tmm_yc_att3 tmm_yc_att4 tmm_yc_att5 tmm_yc_att6 if ans_y_att==6 & ans_c_att==6, save
		matrix AT_yc = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_yc_att_p tmm_yc_att1 tmm_yc_att2 tmm_yc_att3 tmm_yc_att4 tmm_yc_att5 tmm_yc_att6 if ans_y_att==6 & ans_c_att==6 & period==`P', save
			matrix ATMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix ATMMp_yc = AT_yc, ATMMp_yc2, ATMMp_yc3, ATMMp_yc4
			
		
	* Raw differences		
	tabstat rd_yc_att rd_yc_att1 rd_yc_att2 rd_yc_att3 rd_yc_att4 rd_yc_att5 rd_yc_att6 if ans_y_att==6 & ans_c_att==6, save
		matrix AD_yc = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_yc_att rd_yc_att1 rd_yc_att2 rd_yc_att3 rd_yc_att4 rd_yc_att5 rd_yc_att6 if ans_y_att==6 & ans_c_att==6 & period==`P', save
			matrix ADp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix ADp_yc = ADp_yc2, ADp_yc3, ADp_yc4	

	*** By reporter and period
	tabstat bpm_y_att bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y if ans_y_att==6 & ans_c_att==6, save
		matrix AS_yc1 = r(StatTotal)'
	tabstat bpm_c_att cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p if ans_y_att==6 & ans_c_att==6, save
		matrix AS_yc2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_y_att bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y if ans_y_att==6 & ans_c_att==6 & period==`P', save
			matrix AS_yc`P'1 = r(StatTotal)'
		tabstat bpm_c_att cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p if ans_y_att==6 & ans_c_att==6 & period==`P', save
			matrix AS_yc`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-caregiver
	matrix AD_yc = AS_yc1, AS_yc2, AD_yc, ADp_yc	
		
		
	************************	
	*** Youth - Teacher
	egen emm_yt_att_n = rowtotal(emm_yt_att1 emm_yt_att2 emm_yt_att3 emm_yt_att4 emm_yt_att5 emm_yt_att6) if ans_y_att==6 & ans_t_att==6
		label var emm_yt_att_n "N att Exact MM, yt"
	gen emm_yt_att_p = emm_yt_att_n/6
		label var emm_yt_att_p "% att Exact MM, yt"
		
	egen tmm_yt_att_n = rowtotal(tmm_yt_att1 tmm_yt_att2 tmm_yt_att3 tmm_yt_att4 tmm_yt_att5 tmm_yt_att6) if ans_y_att==6 & ans_t_att==6
		label var tmm_yt_att_n "N att Yes-No MM, yt"
	gen tmm_yt_att_p = tmm_yt_att_n/6
		label var tmm_yt_att_p "% att Yes-No MM, yt"
				
	egen rd_yt_att = rowtotal(rd_yt_att1 rd_yt_att2 rd_yt_att3 rd_yt_att4 rd_yt_att5 rd_yt_att6) if ans_y_att==6 & ans_t_att==6
		label var rd_yt_att "Raw difference ATT, yt"	
		
	egen ad_yt_att = rowtotal(ad_yt_att1 ad_yt_att2 ad_yt_att3 ad_yt_att4 ad_yt_att5 ad_yt_att6) if ans_y_att==6 & ans_t_att==6
		label var ad_yt_att "Absolute difference ATT, yt"			
				
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_yt_att_p emm_yt_att1 emm_yt_att2 emm_yt_att3 emm_yt_att4 emm_yt_att5 emm_yt_att6 if ans_y_att==6 & ans_t_att==6, save
		matrix AE_yt = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_yt_att_p emm_yt_att1 emm_yt_att2 emm_yt_att3 emm_yt_att4 emm_yt_att5 emm_yt_att6 if ans_y_att==6 & ans_t_att==6 & period==`P', save
			matrix AEMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix AEMMp_yt = AE_yt, AEMMp_yt2, AEMMp_yt3, AEMMp_yt4		
		
	* Yes/No mismatch
	tabstat tmm_yt_att_p tmm_yt_att1 tmm_yt_att2 tmm_yt_att3 tmm_yt_att4 tmm_yt_att5 tmm_yt_att6 if ans_y_att==6 & ans_t_att==6, save
		matrix AT_yt = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_yt_att_p tmm_yt_att1 tmm_yt_att2 tmm_yt_att3 tmm_yt_att4 tmm_yt_att5 tmm_yt_att6 if ans_y_att==6 & ans_t_att==6 & period==`P', save
			matrix ATMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix ATMMp_yt = AT_yt, ATMMp_yt2, ATMMp_yt3, ATMMp_yt4
			
		
	* Raw differences		
	tabstat rd_yt_att rd_yt_att1 rd_yt_att2 rd_yt_att3 rd_yt_att4 rd_yt_att5 rd_yt_att6 if ans_y_att==6 & ans_t_att==6, save
		matrix AD_yt = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_yt_att rd_yt_att1 rd_yt_att2 rd_yt_att3 rd_yt_att4 rd_yt_att5 rd_yt_att6 if ans_y_att==6 & ans_t_att==6 & period==`P', save
			matrix ADp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix ADp_yt = ADp_yt2, ADp_yt3, ADp_yt4	

	*** By reporter and period
	tabstat bpm_y_att bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y if ans_y_att==6 & ans_t_att==6, save
		matrix AS_yt1 = r(StatTotal)'
	tabstat bpm_t_att bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13 if ans_y_att==6 & ans_t_att==6, save
		matrix AS_yt2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_y_att bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y if ans_y_att==6 & ans_t_att==6 & period==`P', save
			matrix AS_yt`P'1 = r(StatTotal)'
		tabstat bpm_t_att bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13 if ans_y_att==6 & ans_t_att==6 & period==`P', save
			matrix AS_yt`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-teacher
	matrix AD_yt = AS_yt1, AS_yt2, AD_yt, ADp_yt
	
	
	************************	
	*** Caregiver - Teacher
	egen emm_ct_att_n = rowtotal(emm_ct_att1 emm_ct_att2 emm_ct_att3 emm_ct_att4 emm_ct_att5 emm_ct_att6) if ans_c_att==6 & ans_t_att==6 & period!=1
		label var emm_ct_att_n "N att Exact MM, ct"
	gen emm_ct_att_p = emm_ct_att_n/6
		label var emm_ct_att_p "% att Exact MM, ct"
		
	egen tmm_ct_att_n = rowtotal(tmm_ct_att1 tmm_ct_att2 tmm_ct_att3 tmm_ct_att4 tmm_ct_att5 tmm_ct_att6) if ans_c_att==6 & ans_t_att==6 & period!=1
		label var tmm_ct_att_n "N att Yes-No MM, ct"
	gen tmm_ct_att_p = tmm_ct_att_n/6
		label var tmm_ct_att_p "% att Yes-No MM, ct"
	
	egen rd_ct_att = rowtotal(rd_ct_att1 rd_ct_att2 rd_ct_att3 rd_ct_att4 rd_ct_att5 rd_ct_att6) if ans_c_att==6 & ans_t_att==6 & period!=1
		label var rd_ct_att "Raw difference ATT, ct"	
		
	egen ad_ct_att = rowtotal(ad_ct_att1 ad_ct_att2 ad_ct_att3 ad_ct_att4 ad_ct_att5 ad_ct_att6) if ans_c_att==6 & ans_t_att==6 & period!=1
		label var ad_ct_att "Absolute difference ATT, ct"			
				
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_ct_att_p emm_ct_att1 emm_ct_att2 emm_ct_att3 emm_ct_att4 emm_ct_att5 emm_ct_att6 if ans_c_att==6 & ans_t_att==6 & period!=1, save
		matrix AE_ct = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_ct_att_p emm_ct_att1 emm_ct_att2 emm_ct_att3 emm_ct_att4 emm_ct_att5 emm_ct_att6 if ans_c_att==6 & ans_t_att==6 & period==`P', save
			matrix AEMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix AEMMp_ct = AE_ct, AEMMp_ct2, AEMMp_ct3, AEMMp_ct4		
		
	* Yes/No mismatch
	tabstat tmm_ct_att_p tmm_ct_att1 tmm_ct_att2 tmm_ct_att3 tmm_ct_att4 tmm_ct_att5 tmm_ct_att6 if ans_c_att==6 & ans_t_att==6 & period!=1, save
		matrix AT_ct = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_ct_att_p tmm_ct_att1 tmm_ct_att2 tmm_ct_att3 tmm_ct_att4 tmm_ct_att5 tmm_ct_att6 if ans_c_att==6 & ans_t_att==6 & period==`P', save
			matrix ATMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix ATMMp_ct = AT_ct, ATMMp_ct2, ATMMp_ct3, ATMMp_ct4
			
		
	* Raw differences		
	tabstat rd_ct_att rd_ct_att1 rd_ct_att2 rd_ct_att3 rd_ct_att4 rd_ct_att5 rd_ct_att6 if ans_c_att==6 & ans_t_att==6 & period!=1, save
		matrix AD_ct = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_ct_att rd_ct_att1 rd_ct_att2 rd_ct_att3 rd_ct_att4 rd_ct_att5 rd_ct_att6 if ans_c_att==6 & ans_t_att==6 & period==`P', save
			matrix ADp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix ADp_ct = ADp_ct2, ADp_ct3, ADp_ct4	

	*** By reporter and period
	tabstat bpm_c_att cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p if ans_c_att==6 & ans_t_att==6 & period!=1, save
		matrix AS_ct1 = r(StatTotal)'
	tabstat bpm_t_att bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13 if ans_c_att==6 & ans_t_att==6 & period!=1, save
		matrix AS_ct2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_c_att cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p if ans_c_att==6 & ans_t_att==6 & period==`P', save
			matrix AS_ct`P'1 = r(StatTotal)'
		tabstat bpm_t_att bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13 if ans_c_att==6 & ans_t_att==6 & period==`P', save
			matrix AS_ct`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-caregiver
	matrix AD_ct = AS_ct1, AS_ct2, AD_ct, ADp_ct	
		
		
	*****************************************************
	*** Exporting results for attention symptoms
	
	* Exact Mismatch
	matrix AEM = AEMMp_yc \ AEMMp_yt \ AEMMp_ct
		matrix IMM = IE_yc, IT_yc, IE_yt, IT_yt, IE_ct, IT_ct
	
	* Yes-No Mismatch
	matrix ATM = ATMMp_yc \ ATMMp_yt \ ATMMp_ct
	
	* Raw differences
	matrix AD = AD_yc \ AD_yt \ AD_ct
			
	matrix AMM = AE_yc, AT_yc, AE_yt, AT_yt, AE_ct, AT_ct		


********************************************************************************
********************************************************************************
*** t-tests
		
matrix Attyc = J(7,12,.)
matrix Attyt = J(7,12,.)
matrix Attct = J(7,12,.)

matrix AttycSD = J(7,12,.)
matrix AttytSD = J(7,12,.)
matrix AttctSD = J(7,12,.)

matrix AttycG = J(7,24,.)
matrix AttytG = J(7,24,.)
matrix AttctG = J(7,24,.)

local BPM_T		"bpm_t_att bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13"
local BPM_Y 	"bpm_y_att bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y"
local BPM_C 	"bpm_c_att cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p"

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
					
						** Youth-caregiver
						ttest `c' == `y' if ans_y_att==6 & ans_c_att==6
							matrix Attyc[`i',1] = r(N_1)
							matrix Attyc[`i',2] = r(mu_2) - r(mu_1)
							matrix Attyc[`i',3] = r(p)
							
							matrix AttycSD[`i',1] = -1 * r(mu_diff)
							matrix AttycSD[`i',2] = r(sd_diff)
							matrix AttycSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix AttycG[`i',1] = r(N_1)
							matrix AttycG[`i',2] = r(mu_2)
							matrix AttycG[`i',3] = r(mu_1)
							matrix AttycG[`i',4] = r(mu_2) - r(mu_1)
							matrix AttycG[`i',5] = r(se)
							matrix AttycG[`i',6] = r(p)
							
						ttest `c' == `y' if ans_y_att==6 & ans_c_att==6 & period==2
							matrix Attyc[`i',4] = r(N_1)
							matrix Attyc[`i',5] = r(mu_2) - r(mu_1)
							matrix Attyc[`i',6] = r(p)	

							matrix AttycSD[`i',4] = -1 * r(mu_diff)
							matrix AttycSD[`i',5] = r(sd_diff)
							matrix AttycSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttycG[`i',7] = r(N_1)
							matrix AttycG[`i',8] = r(mu_2)
							matrix AttycG[`i',9] = r(mu_1)
							matrix AttycG[`i',10] = r(mu_2) - r(mu_1)
							matrix AttycG[`i',11] = r(se)
							matrix AttycG[`i',12] = r(p)
						
						ttest `c' == `y' if ans_y_att==6 & ans_c_att==6 & period==3
							matrix Attyc[`i',7] = r(N_1)
							matrix Attyc[`i',8] = r(mu_2) - r(mu_1)
							matrix Attyc[`i',9] = r(p)

							matrix AttycSD[`i',7] = -1 * r(mu_diff)
							matrix AttycSD[`i',8] = r(sd_diff)
							matrix AttycSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttycG[`i',13] = r(N_1)
							matrix AttycG[`i',14] = r(mu_2)
							matrix AttycG[`i',15] = r(mu_1)
							matrix AttycG[`i',16] = r(mu_2) - r(mu_1)
							matrix AttycG[`i',17] = r(se)
							matrix AttycG[`i',18] = r(p)
						
						ttest `c' == `y' if ans_y_att==6 & ans_c_att==6 & period==4
							matrix Attyc[`i',10] = r(N_1)
							matrix Attyc[`i',11] = r(mu_2) - r(mu_1)
							matrix Attyc[`i',12] = r(p)	
							
							matrix AttycSD[`i',10] = -1 * r(mu_diff)
							matrix AttycSD[`i',11] = r(sd_diff)
							matrix AttycSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttycG[`i',19] = r(N_1)
							matrix AttycG[`i',20] = r(mu_2)
							matrix AttycG[`i',21] = r(mu_1)
							matrix AttycG[`i',22] = r(mu_2) - r(mu_1)
							matrix AttycG[`i',23] = r(se)
							matrix AttycG[`i',24] = r(p)
							
						** Youth-teacher
						ttest `t' == `y' if ans_y_att==6 & ans_t_att==6
							matrix Attyt[`i',1] = r(N_1)
							matrix Attyt[`i',2] = r(mu_2) - r(mu_1)
							matrix Attyt[`i',3] = r(p)
							
							matrix AttytSD[`i',1] = -1 * r(mu_diff)
							matrix AttytSD[`i',2] = r(sd_diff)
							matrix AttytSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttytG[`i',1] = r(N_1)
							matrix AttytG[`i',2] = r(mu_2)
							matrix AttytG[`i',3] = r(mu_1)
							matrix AttytG[`i',4] = r(mu_2) - r(mu_1)
							matrix AttytG[`i',5] = r(se)
							matrix AttytG[`i',6] = r(p)
							
						ttest `t' == `y' if ans_y_att==6 & ans_t_att==6 & period==2
							matrix Attyt[`i',4] = r(N_1)
							matrix Attyt[`i',5] = r(mu_2) - r(mu_1)
							matrix Attyt[`i',6] = r(p)
							
							matrix AttytSD[`i',4] = -1 * r(mu_diff)
							matrix AttytSD[`i',5] = r(sd_diff)
							matrix AttytSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix AttytG[`i',7] = r(N_1)
							matrix AttytG[`i',8] = r(mu_2)
							matrix AttytG[`i',9] = r(mu_1)
							matrix AttytG[`i',10] = r(mu_2) - r(mu_1)
							matrix AttytG[`i',11] = r(se)
							matrix AttytG[`i',12] = r(p)							
							
						ttest `t' == `y' if ans_y_att==6 & ans_t_att==6 & period==3
							matrix Attyt[`i',7] = r(N_1)
							matrix Attyt[`i',8] = r(mu_2) - r(mu_1)
							matrix Attyt[`i',9] = r(p)

							matrix AttytSD[`i',7] = -1 * r(mu_diff)
							matrix AttytSD[`i',8] = r(sd_diff)
							matrix AttytSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttytG[`i',13] = r(N_1)
							matrix AttytG[`i',14] = r(mu_2)
							matrix AttytG[`i',15] = r(mu_1)
							matrix AttytG[`i',16] = r(mu_2) - r(mu_1)
							matrix AttytG[`i',17] = r(se)
							matrix AttytG[`i',18] = r(p)
							
						ttest `t' == `y' if ans_y_att==6 & ans_t_att==6 & period==4
							matrix Attyt[`i',10] = r(N_1)
							matrix Attyt[`i',11] = r(mu_2) - r(mu_1)
							matrix Attyt[`i',12] = r(p)
							
							matrix AttytSD[`i',10] = -1 * r(mu_diff)
							matrix AttytSD[`i',11] = r(sd_diff)
							matrix AttytSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttytG[`i',19] = r(N_1)
							matrix AttytG[`i',20] = r(mu_2)
							matrix AttytG[`i',21] = r(mu_1)
							matrix AttytG[`i',22] = r(mu_2) - r(mu_1)
							matrix AttytG[`i',23] = r(se)
							matrix AttytG[`i',24] = r(p)
							
							
						** Caregiver-teacher
						ttest `t' == `c' if ans_c_att==6 & ans_t_att==6 & period!=1
							matrix Attct[`i',1] = r(N_1)
							matrix Attct[`i',2] = r(mu_2) - r(mu_1)
							matrix Attct[`i',3] = r(p)
							
							matrix AttctSD[`i',1] = -1 * r(mu_diff)
							matrix AttctSD[`i',2] = r(sd_diff)
							matrix AttctSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix AttctG[`i',1] = r(N_1)
							matrix AttctG[`i',2] = r(mu_2)
							matrix AttctG[`i',3] = r(mu_1)
							matrix AttctG[`i',4] = r(mu_2) - r(mu_1)
							matrix AttctG[`i',5] = r(se)
							matrix AttctG[`i',6] = r(p)
							
						ttest `t' == `c' if ans_c_att==6 & ans_t_att==6 & period==2
							matrix Attct[`i',4] = r(N_1)
							matrix Attct[`i',5] = r(mu_2) - r(mu_1)
							matrix Attct[`i',6] = r(p)

							matrix AttctSD[`i',4] = -1 * r(mu_diff)
							matrix AttctSD[`i',5] = r(sd_diff)
							matrix AttctSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix AttctG[`i',7] = r(N_1)
							matrix AttctG[`i',8] = r(mu_2)
							matrix AttctG[`i',9] = r(mu_1)
							matrix AttctG[`i',10] = r(mu_2) - r(mu_1)
							matrix AttctG[`i',11] = r(se)
							matrix AttctG[`i',12] = r(p)
							
							
						ttest `t' == `c' if ans_c_att==6 & ans_t_att==6 & period==3
							matrix Attct[`i',7] = r(N_1)
							matrix Attct[`i',8] = r(mu_2) - r(mu_1)
							matrix Attct[`i',9] = r(p)
							
							matrix AttctSD[`i',7] = -1 * r(mu_diff)
							matrix AttctSD[`i',8] = r(sd_diff)
							matrix AttctSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							

							matrix AttctG[`i',13] = r(N_1)
							matrix AttctG[`i',14] = r(mu_2)
							matrix AttctG[`i',15] = r(mu_1)
							matrix AttctG[`i',16] = r(mu_2) - r(mu_1)
							matrix AttctG[`i',17] = r(se)
							matrix AttctG[`i',18] = r(p)
							
						ttest `t' == `c' if ans_c_att==6 & ans_t_att==6 & period==4
							matrix Attct[`i',10] = r(N_1)
							matrix Attct[`i',11] = r(mu_2) - r(mu_1)
							matrix Attct[`i',12] = r(p)	
							
							matrix AttctSD[`i',10] = -1 * r(mu_diff)
							matrix AttctSD[`i',11] = r(sd_diff)
							matrix AttctSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix AttctG[`i',19] = r(N_1)
							matrix AttctG[`i',20] = r(mu_2)
							matrix AttctG[`i',21] = r(mu_1)
							matrix AttctG[`i',22] = r(mu_2) - r(mu_1)
							matrix AttctG[`i',23] = r(se)
							matrix AttctG[`i',24] = r(p)
						
					
					local i = `i' + 1 
				}				
	
	
********************************************************************************	
* Externalizing symptoms, youth - caregiver

local BPM_Y 	"bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y"
local BPM_C 	"cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

	local i = 1
	local r : word count `BPM_Y'
				while `i' <= `r' {
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
						
						* Exact mismatch
						gen emm_yc_ext`i' = (`y'!=`c') if ans_yc_ext==6 & ans_cy_ext==6 
						
						* Yes vs. No mismatch
						gen tmm_yc_ext`i' = (((`y'==1 | `y'==2) & `c'==0) | (`y'==0 & (`c'==1 | `c'==2))) if ans_yc_ext==6 & ans_cy_ext==6 
						
						 * Decompose Yes/No mismatch into over- vs under-report
						* youth > caregiver / teacher / caregiver > teacher
						gen tmm_yc_ext`i'a = ((`y'==1 | `y'==2) & `c'==0)                        ///
											 if ans_yc_ext==6 & ans_cy_ext==6 
						gen tmm_yc_ext`i'b = (`y'==0 & (`c'==1 | `c'==2))                        ///
											 if ans_yc_ext==6 & ans_cy_ext==6 
						
						* Raw difference in symptoms
						gen rd_yc_ext`i' = (`y' - `c') if ans_yc_ext==6 & ans_cy_ext==6 
						
						* Absolute difference in symptoms
						gen ad_yc_ext`i' = abs(`y' - `c') if ans_yc_ext==6 & ans_cy_ext==6  

				local i = `i' + 1 
				}
				
	* Youth - Caregiver
	egen emm_yc_ext_n = rowtotal(emm_yc_ext1 emm_yc_ext2 emm_yc_ext3 emm_yc_ext4 emm_yc_ext5 emm_yc_ext6) if ans_yc_ext==6 & ans_cy_ext==6 
		label var emm_yc_ext_n "N EXT Exact MM, yc"
	gen emm_yc_ext_p = emm_yc_ext_n/6
		label var emm_yc_ext_p "% EXT Exact MM, yc"
	egen tmm_yc_ext_n = rowtotal(tmm_yc_ext1 tmm_yc_ext2 tmm_yc_ext3 tmm_yc_ext4 tmm_yc_ext5 tmm_yc_ext6) if ans_yc_ext==6 & ans_cy_ext==6 
		label var emm_yc_ext_n "N EXT Yes-No MM, yc"
	gen tmm_yc_ext_p = tmm_yc_ext_n/6
		label var tmm_yc_ext_p "% EXT Yes-No MM, yc"
	
	egen rd_yc_ext = rowtotal(rd_yc_ext1 rd_yc_ext2 rd_yc_ext3 rd_yc_ext4 rd_yc_ext5 rd_yc_ext6) if ans_yc_ext==6 & ans_cy_ext==6
		label var rd_yc_ext "Raw difference EXT, yc"	
		
	egen ad_yc_ext = rowtotal(ad_yc_ext1 ad_yc_ext2 ad_yc_ext3 ad_yc_ext4 ad_yc_ext5 ad_yc_ext6) if ans_yc_ext==6 & ans_cy_ext==6
		label var ad_yc_ext "Absolute difference EXT, yc"			
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_yc_ext_p emm_yc_ext1 emm_yc_ext2 emm_yc_ext3 emm_yc_ext4 emm_yc_ext5 emm_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6, save
		matrix EE_yc = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_yc_ext_p emm_yc_ext1 emm_yc_ext2 emm_yc_ext3 emm_yc_ext4 emm_yc_ext5 emm_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6 & period==`P', save
			matrix EEMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix EEMMp_yc = EE_yc, EEMMp_yc2, EEMMp_yc3, EEMMp_yc4		
		
	* Yes/No mismatch
	tabstat tmm_yc_ext_p tmm_yc_ext1 tmm_yc_ext2 tmm_yc_ext3 tmm_yc_ext4 tmm_yc_ext5 tmm_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6, save
		matrix ET_yc = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_yc_ext_p tmm_yc_ext1 tmm_yc_ext2 tmm_yc_ext3 tmm_yc_ext4 tmm_yc_ext5 tmm_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6 & period==`P', save
			matrix ETMMp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix ETMMp_yc = ET_yc, ETMMp_yc2, ETMMp_yc3, ETMMp_yc4
			
		
	* Raw differences		
	tabstat rd_yc_ext rd_yc_ext1 rd_yc_ext2 rd_yc_ext3 rd_yc_ext4 rd_yc_ext5 rd_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6, save
		matrix ED_yc = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_yc_ext rd_yc_ext1 rd_yc_ext2 rd_yc_ext3 rd_yc_ext4 rd_yc_ext5 rd_yc_ext6 if ans_yc_ext==6 & ans_cy_ext==6 & period==`P', save
			matrix EDp_yc`P' = r(StatTotal)'
		
	}	
	
	matrix EDp_yc = EDp_yc2, EDp_yc3, EDp_yc4	

	*** By reporter and period
	tabstat bpm_yc_ext bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y if ans_yc_ext==6 & ans_cy_ext==6, save
		matrix ES_yc1 = r(StatTotal)'
	tabstat bpm_cy_ext cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p if ans_yc_ext==6 & ans_cy_ext==6, save
		matrix ES_yc2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_yc_ext bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y if ans_yc_ext==6 & ans_cy_ext==6 & period==`P', save
			matrix ES_yc`P'1 = r(StatTotal)'
		tabstat bpm_cy_ext cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p if ans_yc_ext==6 & ans_cy_ext==6 & period==`P', save
			matrix ES_yc`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-caregiver
	matrix ED_yc = ES_yc1, ES_yc2, ED_yc, EDp_yc


		
********************************************************************************	
* Externalizing symptoms, youth - teacher

egen ans_ty_ext = rownonmiss(bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16)

local BPM_T		"bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16"
local BPM_Y 	"bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'
						
						* Exact mismatch
						gen emm_yt_ext`i' = (`y'!=`t') if ans_yt_ext==6 & ans_ty_ext==6
						
						* Yes vs. No mismatch
						gen tmm_yt_ext`i' = (((`y'==1 | `y'==2) & `t'==0) | (`y'==0 & (`t'==1 | `t'==2))) if ans_yt_ext==6 & ans_ty_ext==6 
						
						* Decompose Yes/No mismatch into over- vs under-report
						* youth > caregiver / teacher / caregiver > teacher
						gen tmm_yt_ext`i'a = ((`y'==1 | `y'==2) & `t'==0)                        ///
											 if ans_yt_ext==6 & ans_ty_ext==6 
						gen tmm_yt_ext`i'b = (`y'==0 & (`t'==1 | `t'==2))                        ///
											 if ans_yt_ext==6 & ans_ty_ext==6 
											 
						* Raw difference in symptoms
						gen rd_yt_ext`i' = (`y' - `t') if ans_yt_ext==6 & ans_ty_ext==6 
						
						* Absolute difference in symptoms
						gen ad_yt_ext`i' = abs(`y' - `t') if ans_yt_ext==6 & ans_ty_ext==6  
						

				local i = `i' + 1 
				}
				
		
	* Youth - Teacher
	egen emm_yt_ext_n = rowtotal(emm_yt_ext1 emm_yt_ext2 emm_yt_ext3 emm_yt_ext4 emm_yt_ext5 emm_yt_ext6) if ans_yt_ext==6 & ans_ty_ext==6
		label var emm_yt_ext_n "N EXT Exact MM, yt"
	gen emm_yt_ext_p = emm_yt_ext_n/6
		label var emm_yt_ext_p "% EXT Exact MM, yt"
	egen tmm_yt_ext_n = rowtotal(tmm_yt_ext1 tmm_yt_ext2 tmm_yt_ext3 tmm_yt_ext4 tmm_yt_ext5 tmm_yt_ext6) if ans_yt_ext==6 & ans_ty_ext==6
		label var tmm_yt_ext_n "N EXT Yes-No MM, yt"
	gen tmm_yt_ext_p = tmm_yt_ext_n/6
		label var tmm_yt_ext_p "% EXT Yes-No MM, yt"
				
	egen rd_yt_ext = rowtotal(rd_yt_ext1 rd_yt_ext2 rd_yt_ext3 rd_yt_ext4 rd_yt_ext5 rd_yt_ext6) if ans_yt_ext==6 & ans_ty_ext==6
		label var rd_yt_ext "Raw difference EXT, yt"	
		
	egen ad_yt_ext = rowtotal(ad_yt_ext1 ad_yt_ext2 ad_yt_ext3 ad_yt_ext4 ad_yt_ext5 ad_yt_ext6) if ans_yt_ext==6 & ans_ty_ext==6
		label var ad_yt_ext "Absolute difference EXT, yt"			
				
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_yt_ext_p emm_yt_ext1 emm_yt_ext2 emm_yt_ext3 emm_yt_ext4 emm_yt_ext5 emm_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6, save
		matrix EE_yt = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_yt_ext_p emm_yt_ext1 emm_yt_ext2 emm_yt_ext3 emm_yt_ext4 emm_yt_ext5 emm_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6 & period==`P', save
			matrix EEMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix EEMMp_yt = EE_yt, EEMMp_yt2, EEMMp_yt3, EEMMp_yt4		
		
	* Yes/No mismatch
	tabstat tmm_yt_ext_p tmm_yt_ext1 tmm_yt_ext2 tmm_yt_ext3 tmm_yt_ext4 tmm_yt_ext5 tmm_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6, save
		matrix ET_yt = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_yt_ext_p tmm_yt_ext1 tmm_yt_ext2 tmm_yt_ext3 tmm_yt_ext4 tmm_yt_ext5 tmm_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6 & period==`P', save
			matrix ETMMp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix ETMMp_yt = ET_yt, ETMMp_yt2, ETMMp_yt3, ETMMp_yt4
			
		
	* Raw differences		
	tabstat rd_yt_ext rd_yt_ext1 rd_yt_ext2 rd_yt_ext3 rd_yt_ext4 rd_yt_ext5 rd_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6, save
		matrix ED_yt = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_yt_ext rd_yt_ext1 rd_yt_ext2 rd_yt_ext3 rd_yt_ext4 rd_yt_ext5 rd_yt_ext6 if ans_yt_ext==6 & ans_ty_ext==6 & period==`P', save
			matrix EDp_yt`P' = r(StatTotal)'
		
	}	
	
	matrix EDp_yt = EDp_yt2, EDp_yt3, EDp_yt4	

	*** By reporter and period
	tabstat bpm_yt_ext bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y if ans_yt_ext==6 & ans_ty_ext==6, save
		matrix ES_yt1 = r(StatTotal)'
	tabstat bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16 if ans_yt_ext==6 & ans_ty_ext==6, save
		matrix ES_yt2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_yt_ext bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y if ans_yt_ext==6 & ans_ty_ext==6 & period==`P', save
			matrix ES_yt`P'1 = r(StatTotal)'
		tabstat bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16 if ans_yt_ext==6 & ans_ty_ext==6 & period==`P', save
			matrix ES_yt`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-caregiver
	matrix ED_yt = ES_yt1, ES_yt2, ED_yt, EDp_yt
	

********************************************************************************	
* Externalizing symptoms, caregiver - teacher

egen ans_tc_ext = rownonmiss(bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16)
*egen ans_ct_ext = rownonmiss(cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p)
*
local BPM_T		"bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16"
local BPM_C 	"cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local t : word `i' of `BPM_T'
					local y : word `i' of `BPM_Y'	
					local c : word `i' of `BPM_C'	
						
						* Exact mismatch
						gen emm_ct_ext`i' = (`c'!=`t') if ans_ct_ext==6 & ans_tc_ext==6 
						
						* Yes vs. No mismatch
						gen tmm_ct_ext`i' = (((`c'==1 | `c'==2) & `t'==0) | (`c'==0 & (`t'==1 | `t'==2))) if ans_ct_ext==6 & ans_tc_ext==6 
						
						* Decompose Yes/No mismatch into over- vs under-report
						* youth > caregiver / teacher / caregiver > teacher
						gen tmm_ct_ext`i'a = ((`c'==1 | `c'==2) & `t'==0)                        ///
											 if ans_ct_ext==6 & ans_tc_ext==6 
						gen tmm_ct_ext`i'b = (`c'==0 & (`t'==1 | `t'==2))                        ///
											 if ans_ct_ext==6 & ans_tc_ext==6 
						
						* Raw difference in symptoms
						gen rd_ct_ext`i' = (`c' - `t') if ans_ct_ext==6 & ans_tc_ext==6 
						
						* Absolute difference in symptoms
						gen ad_ct_ext`i' = abs(`c' - `t') if ans_ct_ext==6 & ans_tc_ext==6 
						
				local i = `i' + 1 
				}

	* Caregiver - Teacher
	egen emm_ct_ext_n = rowtotal(emm_ct_ext1 emm_ct_ext2 emm_ct_ext3 emm_ct_ext4 emm_ct_ext5 emm_ct_ext6) if ans_ct_ext==6 & ans_tc_ext==6 & period!=1
		label var emm_ct_ext_n "N EXT Exact MM, ct"
	gen emm_ct_ext_p = emm_ct_ext_n/6
		label var emm_ct_ext_p "% EXT Exact MM, ct"
	egen tmm_ct_ext_n = rowtotal(tmm_ct_ext1 tmm_ct_ext2 tmm_ct_ext3 tmm_ct_ext4 tmm_ct_ext5 tmm_ct_ext6) if ans_ct_ext==6 & ans_tc_ext==6 & period!=1
		label var tmm_ct_ext_n "N EXT Yes-No MM, ct"
	gen tmm_ct_ext_p = tmm_ct_ext_n/6
		label var tmm_ct_ext_p "% EXT Yes-No MM, ct"
				
	egen rd_ct_ext = rowtotal(rd_ct_ext1 rd_ct_ext2 rd_ct_ext3 rd_ct_ext4 rd_ct_ext5 rd_ct_ext6) if ans_ct_ext==6 & ans_tc_ext==6 & period!=1
		label var rd_ct_ext "Raw difference EXT, ct"	
		
	egen ad_ct_ext = rowtotal(ad_ct_ext1 ad_ct_ext2 ad_ct_ext3 ad_ct_ext4 ad_ct_ext5 ad_ct_ext6) if ans_ct_ext==6 & ans_tc_ext==6 & period!=1
		label var ad_ct_ext "Absolute difference EXT, ct"
				
				
	*** Saving the results
	* Exact mismatch				
	tabstat emm_ct_ext_p emm_ct_ext1 emm_ct_ext2 emm_ct_ext3 emm_ct_ext4 emm_ct_ext5 emm_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period!=1, save
		matrix EE_ct = r(StatTotal)'
	forvalues P=2/4{
		tabstat emm_ct_ext_p emm_ct_ext1 emm_ct_ext2 emm_ct_ext3 emm_ct_ext4 emm_ct_ext5 emm_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period==`P', save
			matrix EEMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix EEMMp_ct = EE_ct, EEMMp_ct2, EEMMp_ct3, EEMMp_ct4		
		
	* Yes/No mismatch
	tabstat tmm_ct_ext_p tmm_ct_ext1 tmm_ct_ext2 tmm_ct_ext3 tmm_ct_ext4 tmm_ct_ext5 tmm_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period!=1, save
		matrix ET_ct = r(StatTotal)'

	forvalues P=2/4{
		tabstat tmm_ct_ext_p tmm_ct_ext1 tmm_ct_ext2 tmm_ct_ext3 tmm_ct_ext4 tmm_ct_ext5 tmm_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period==`P', save
			matrix ETMMp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix ETMMp_ct = ET_ct, ETMMp_ct2, ETMMp_ct3, ETMMp_ct4
			
		
	* Raw differences		
	tabstat rd_ct_ext rd_ct_ext1 rd_ct_ext2 rd_ct_ext3 rd_ct_ext4 rd_ct_ext5 rd_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period!=1, save
		matrix ED_ct = r(StatTotal)'
	
	forvalues P=2/4{
		tabstat rd_ct_ext rd_ct_ext1 rd_ct_ext2 rd_ct_ext3 rd_ct_ext4 rd_ct_ext5 rd_ct_ext6 if ans_ct_ext==6 & ans_tc_ext==6 & period==`P', save
			matrix EDp_ct`P' = r(StatTotal)'
		
	}	
	
	matrix EDp_ct = EDp_ct2, EDp_ct3, EDp_ct4	

	*** By reporter and period
	tabstat bpm_ct_ext cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p if ans_ct_ext==6 & ans_tc_ext==6 & period!=1, save
		matrix ES_ct1 = r(StatTotal)'
	tabstat bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16 if ans_ct_ext==6 & ans_tc_ext==6 & period!=1, save
		matrix ES_ct2 = r(StatTotal)'
		
	forvalues P=2/4{
		tabstat bpm_ct_ext cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p if ans_ct_ext==6 & ans_tc_ext==6 & period==`P', save
			matrix ES_ct`P'1 = r(StatTotal)'
		tabstat bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16 if ans_ct_ext==6 & ans_tc_ext==6 & period==`P', save
			matrix ES_ct`P'2 = r(StatTotal)'
				
	}	
		
	** Difference youth-caregiver
	matrix ED_ct = ES_ct1, ES_ct2, ED_ct, EDp_ct
		
		
	*****************************************************
	*** Exporting results for externalizing symptoms
	
	* Exact Mismatch
	matrix EEM = EEMMp_yc \ EEMMp_yt \ EEMMp_ct
		matrix IMM = IE_yc, IT_yc, IE_yt, IT_yt, IE_ct, IT_ct
	
	* Yes-No Mismatch
	matrix ETM = ETMMp_yc \ ETMMp_yt \ ETMMp_ct
	
	* Raw differences
	matrix ED = ED_yc \ ED_yt \ ED_ct


********************************************************************************
********************************************************************************
*** t-tests
		
matrix Ettyc = J(7,12,.)
matrix Ettyt = J(7,12,.)
matrix Ettct = J(7,12,.)

matrix EttycSD = J(7,12,.)
matrix EttytSD = J(7,12,.)
matrix EttctSD = J(7,12,.)

matrix EttycG = J(7,24,.)
matrix EttytG = J(7,24,.)
matrix EttctG = J(7,24,.)

local BPM_YC 	"bpm_yc_ext bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y"
local BPM_CY 	"bpm_cy_ext cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"
local BPM_T		"bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16"
local BPM_CT 	"bpm_ct_ext cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"
local BPM_YT 	"bpm_yt_ext bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y"

	local i = 1
	local r : word count `BPM_T'
				while `i' <= `r' {
					local yc : word `i' of `BPM_YC'	
					local cy : word `i' of `BPM_CY'	
					local t : word `i' of `BPM_T'
					local yt : word `i' of `BPM_YT'	
					local ct : word `i' of `BPM_CT'	
					
						** Youth-caregiver
						ttest `cy' == `yc' if ans_yc_ext==6 & ans_cy_ext==6 
							matrix Ettyc[`i',1] = r(N_1)
							matrix Ettyc[`i',2] = r(mu_2) - r(mu_1)
							matrix Ettyc[`i',3] = r(p)
							
							matrix EttycSD[`i',1] = -1 * r(mu_diff)
							matrix EttycSD[`i',2] = r(sd_diff)
							matrix EttycSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttycG[`i',1] = r(N_1)
							matrix EttycG[`i',2] = r(mu_2)
							matrix EttycG[`i',3] = r(mu_1)
							matrix EttycG[`i',4] = r(mu_2) - r(mu_1)
							matrix EttycG[`i',5] = r(se)
							matrix EttycG[`i',6] = r(p)
							
							
						ttest `cy' == `yc' if ans_yc_ext==6 & ans_cy_ext==6 & period==2
							matrix Ettyc[`i',4] = r(N_1)
							matrix Ettyc[`i',5] = r(mu_2) - r(mu_1)
							matrix Ettyc[`i',6] = r(p)
							
							matrix EttycSD[`i',4] = -1 * r(mu_diff)
							matrix EttycSD[`i',5] = r(sd_diff)
							matrix EttycSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttycG[`i',7] = r(N_1)
							matrix EttycG[`i',8] = r(mu_2)
							matrix EttycG[`i',9] = r(mu_1)
							matrix EttycG[`i',10] = r(mu_2) - r(mu_1)
							matrix EttycG[`i',11] = r(se)
							matrix EttycG[`i',12] = r(p)
							
						
						ttest `cy' == `yc' if ans_yc_ext==6 & ans_cy_ext==6 & period==3
							matrix Ettyc[`i',7] = r(N_1)
							matrix Ettyc[`i',8] = r(mu_2) - r(mu_1)
							matrix Ettyc[`i',9] = r(p)	
							
							matrix EttycSD[`i',7] = -1 * r(mu_diff)
							matrix EttycSD[`i',8] = r(sd_diff)
							matrix EttycSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttycG[`i',13] = r(N_1)
							matrix EttycG[`i',14] = r(mu_2)
							matrix EttycG[`i',15] = r(mu_1)
							matrix EttycG[`i',16] = r(mu_2) - r(mu_1)
							matrix EttycG[`i',17] = r(se)
							matrix EttycG[`i',18] = r(p)
							
						
						ttest `cy' == `yc' if ans_yc_ext==6 & ans_cy_ext==6 & period==4
							matrix Ettyc[`i',10] = r(N_1)
							matrix Ettyc[`i',11] = r(mu_2) - r(mu_1)
							matrix Ettyc[`i',12] = r(p)	

							matrix EttycSD[`i',10] = -1 * r(mu_diff)
							matrix EttycSD[`i',11] = r(sd_diff)
							matrix EttycSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttycG[`i',19] = r(N_1)
							matrix EttycG[`i',20] = r(mu_2)
							matrix EttycG[`i',21] = r(mu_1)
							matrix EttycG[`i',22] = r(mu_2) - r(mu_1)
							matrix EttycG[`i',23] = r(se)
							matrix EttycG[`i',24] = r(p)
							
						** Youth-teacher
						ttest `t' == `yt' if ans_yt_ext==6 & ans_ty_ext==6
							matrix Ettyt[`i',1] = r(N_1)
							matrix Ettyt[`i',2] = r(mu_2) - r(mu_1)
							matrix Ettyt[`i',3] = r(p)
							
							matrix EttytSD[`i',1] = -1 * r(mu_diff)
							matrix EttytSD[`i',2] = r(sd_diff)
							matrix EttytSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttytG[`i',1] = r(N_1)
							matrix EttytG[`i',2] = r(mu_2)
							matrix EttytG[`i',3] = r(mu_1)
							matrix EttytG[`i',4] = r(mu_2) - r(mu_1)
							matrix EttytG[`i',5] = r(se)
							matrix EttytG[`i',6] = r(p)							
							
						ttest `t' == `yt' if ans_yt_ext==6 & ans_ty_ext==6 & period==2
							matrix Ettyt[`i',4] = r(N_1)
							matrix Ettyt[`i',5] = r(mu_2) - r(mu_1)
							matrix Ettyt[`i',6] = r(p)

							matrix EttytSD[`i',4] = -1 * r(mu_diff)
							matrix EttytSD[`i',5] = r(sd_diff)
							matrix EttytSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix EttytG[`i',7] = r(N_1)
							matrix EttytG[`i',8] = r(mu_2)
							matrix EttytG[`i',9] = r(mu_1)
							matrix EttytG[`i',10] = r(mu_2) - r(mu_1)
							matrix EttytG[`i',11] = r(se)
							matrix EttytG[`i',12] = r(p)								
							
						ttest `t' == `yt' if ans_yt_ext==6 & ans_ty_ext==6 & period==3
							matrix Ettyt[`i',7] = r(N_1)
							matrix Ettyt[`i',8] = r(mu_2) - r(mu_1)
							matrix Ettyt[`i',9] = r(p)

							matrix EttytSD[`i',7] = -1 * r(mu_diff)
							matrix EttytSD[`i',8] = r(sd_diff)
							matrix EttytSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix EttytG[`i',13] = r(N_1)
							matrix EttytG[`i',14] = r(mu_2)
							matrix EttytG[`i',15] = r(mu_1)
							matrix EttytG[`i',16] = r(mu_2) - r(mu_1)
							matrix EttytG[`i',17] = r(se)
							matrix EttytG[`i',18] = r(p)								
						
						
						ttest `t' == `yt' if ans_yt_ext==6 & ans_ty_ext==6 & period==4
							matrix Ettyt[`i',10] = r(N_1)
							matrix Ettyt[`i',11] = r(mu_2) - r(mu_1)
							matrix Ettyt[`i',12] = r(p)	
							
							matrix EttytSD[`i',10] = -1 * r(mu_diff)
							matrix EttytSD[`i',11] = r(sd_diff)
							matrix EttytSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix EttytG[`i',19] = r(N_1)
							matrix EttytG[`i',20] = r(mu_2)
							matrix EttytG[`i',21] = r(mu_1)
							matrix EttytG[`i',22] = r(mu_2) - r(mu_1)
							matrix EttytG[`i',23] = r(se)
							matrix EttytG[`i',24] = r(p)								

							
						** Caregiver-teacher
						ttest `t' == `ct' if ans_ct_ext==6 & ans_tc_ext==6 & period!=1
							matrix Ettct[`i',1] = r(N_1)
							matrix Ettct[`i',2] = r(mu_2) - r(mu_1)
							matrix Ettct[`i',3] = r(p)
							
							matrix EttctSD[`i',1] = -1 * r(mu_diff)
							matrix EttctSD[`i',2] = r(sd_diff)
							matrix EttctSD[`i',3] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttctG[`i',1] = r(N_1)
							matrix EttctG[`i',2] = r(mu_2)
							matrix EttctG[`i',3] = r(mu_1)
							matrix EttctG[`i',4] = r(mu_2) - r(mu_1)
							matrix EttctG[`i',5] = r(se)
							matrix EttctG[`i',6] = r(p)
							
						ttest `t' == `ct' if ans_ct_ext==6 & ans_tc_ext==6 & period==2
							matrix Ettct[`i',4] = r(N_1)
							matrix Ettct[`i',5] = r(mu_2) - r(mu_1)
							matrix Ettct[`i',6] = r(p)
							
							matrix EttctSD[`i',4] = -1 * r(mu_diff)
							matrix EttctSD[`i',5] = r(sd_diff)
							matrix EttctSD[`i',6] = -1 * r(mu_diff) / r(sd_diff)
							
							matrix EttctG[`i',7] = r(N_1)
							matrix EttctG[`i',8] = r(mu_2)
							matrix EttctG[`i',9] = r(mu_1)
							matrix EttctG[`i',10] = r(mu_2) - r(mu_1)
							matrix EttctG[`i',11] = r(se)
							matrix EttctG[`i',12] = r(p)
							
							
						ttest `t' == `ct' if ans_ct_ext==6 & ans_tc_ext==6 & period==3
							matrix Ettct[`i',7] = r(N_1)
							matrix Ettct[`i',8] = r(mu_2) - r(mu_1)
							matrix Ettct[`i',9] = r(p)

							matrix EttctSD[`i',7] = -1 * r(mu_diff)
							matrix EttctSD[`i',8] = r(sd_diff)
							matrix EttctSD[`i',9] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix EttctG[`i',13] = r(N_1)
							matrix EttctG[`i',14] = r(mu_2)
							matrix EttctG[`i',15] = r(mu_1)
							matrix EttctG[`i',16] = r(mu_2) - r(mu_1)
							matrix EttctG[`i',17] = r(se)
							matrix EttctG[`i',18] = r(p)
							
							
						ttest `t' == `ct' if ans_ct_ext==6 & ans_tc_ext==6 & period==4
							matrix Ettct[`i',10] = r(N_1)
							matrix Ettct[`i',11] = r(mu_2) - r(mu_1)
							matrix Ettct[`i',12] = r(p)	
							
							matrix EttctSD[`i',10] = -1 * r(mu_diff)
							matrix EttctSD[`i',11] = r(sd_diff)
							matrix EttctSD[`i',12] = -1 * r(mu_diff) / r(sd_diff)							
							
							matrix EttctG[`i',19] = r(N_1)
							matrix EttctG[`i',20] = r(mu_2)
							matrix EttctG[`i',21] = r(mu_1)
							matrix EttctG[`i',22] = r(mu_2) - r(mu_1)
							matrix EttctG[`i',23] = r(se)
							matrix EttctG[`i',24] = r(p)
							
						
					local i = `i' + 1 
				}				
	

********************************************************************************
*************************** Descriptive Statistics *****************************
********************************************************************************

preserve

	matrix T = J(29,5,.)

	local n = 1
	foreach v of varlist bpm_y_int bpm_c_int bpm_t_int bpm_y_att bpm_c_att bpm_t_att bpm_yc_ext bpm_cy_ext bpm_yt_ext bpm_t_ext age_y girl_y nonwhite_y puberty_y immigrant_y age_p woman_p nonwhite_p immigrant_p depre_p educ_lev_p1 educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5 pwarmth_s school_positive_s family_conf_s neighborhood_s {
		sum `v' if wave1!=1
			matrix T[`n',1] = r(min)
			matrix T[`n',2] = r(max)
			matrix T[`n',3] = r(N)
			matrix T[`n',4] = r(mean)
			matrix T[`n',5] = r(sd)
				
		local n = `n'+1
	}

	matrix list T
restore

preserve
	svmat T
	keep if T2!=.
	keep T1 T2 T3 T4 T5

	export excel using "$results/Table1_Descriptive.xlsx", replace firstr(var)
restore


*/


********************************************************************************
********************************************************************************
******************************* RESEARCH AIMS **********************************
********************************************************************************
********************************************************************************

/*
	I. 		DESCRIPTIVE DIFFERENCES IN DISCREPANCIES
	II. 	STUDY PREDICTORS OF DISCREPANCIES
	III.	DOCUMENT DISCREPANCIES OVER TIME

*/


********************************************************************************
********************************************************************************
************* RESEARCH AIM I: DESCRIPTIVE DISCREPANCIES ************************
********************************************************************************
********************************************************************************	
	
**********************************************************	
***** Youth - Caregivers
	
** Diff in Sx, Youth - Caregivers, raw
	matrix D_yc = ID_yc\AD_yc\ED_yc
	matrix Dx_yc = D_yc[1, 3] \ D_yc[10, 3] \ D_yc[17, 3]

** Diff in Sx, Youth - Caregivers, standardized
	matrix ttycSD = IttycSD\AttycSD\EttycSD
	matrix ttxycSD = ttycSD[1, 3] \ ttycSD[10, 3] \ ttycSD[17, 3]
	
** Number of observations and ttest p-values Diff in Sx, Youth - Caregivers
	matrix ttyc = Ittyc\Attyc\Ettyc
	matrix ttxyc = ttyc[1, 1..3] \ ttyc[10, 1..3] \ ttyc[17, 1..3]
	
**********************************************************	
***** Youth - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix D_yt = ID_yt\AD_yt\ED_yt
	matrix Dx_yt = D_yt[1, 3] \ D_yt[10, 3] \ D_yt[17, 3]
	
** Diff in Sx, Youth - Teachers, standardized
	matrix ttytSD = IttytSD\AttytSD\EttytSD
	matrix ttxytSD = ttytSD[1, 3] \ ttytSD[10, 3] \ ttytSD[17, 3]
	
** Number of observations and ttest p-values Diff in Sx, Youth - Teachers
	matrix ttyt = Ittyt\Attyt\Ettyt
	matrix ttxyt = ttyt[1, 1..3] \ ttyt[10, 1..3] \ ttyt[17, 1..3]
	
**********************************************************	
***** Caregivers - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix D_ct = ID_ct\AD_ct\ED_ct
	matrix Dx_ct = D_ct[1, 3] \ D_ct[10, 3] \ D_ct[17, 3]
	
** Diff in Sx, Youth - Teachers, standardized
	matrix ttctSD = IttctSD\AttctSD\EttctSD
	matrix ttxctSD = ttctSD[1, 3] \ ttctSD[10, 3] \ ttctSD[17, 3]
	
** Number of observations and ttest p-values Diff in Sx, Youth - Teachers
	matrix ttct = Ittct\Attct\Ettct
	matrix ttxct = ttct[1, 1..3] \ ttct[10, 1..3] \ ttct[17, 1..3]


**********************************************************	
***** Table 2 - Mean discrepancies
	
	matrix T2 = Dx_yc, ttxycSD, Dx_yt, ttxytSD, Dx_ct, ttxctSD
	xml_tab T2, save("$results\Table2_MeanDifferences.xml") t(Sx Differences Youth vs Teachers) replace
	
	matrix T2_pv = ttxyc, ttxyt, ttxct
	xml_tab T2_pv, save("$results\Table2_MeanDifferences_pvalues.xml") t(Sx Differences Youth vs Teachers) replace
		


*********************************************************************************
***** Figure 1 - Mean discrepancies by reporters and mental health domains

preserve	
	** Descriptive Plots
	
	matrix ttycG = IttycG\AttycG\EttycG\IttytG\AttytG\EttytG\IttctG\AttctG\EttctG

	svmat2 ttycG
	keep ttycG*
	drop if ttycG1==.

	rename ttycG1 Nobs
	rename ttycG2 Youth_mean
	rename ttycG3 Care_mean
	rename ttycG4 effect 
	rename ttycG5 st_e
	rename ttycG6 Diff_pv

	gen 	comparedg = .
	replace comparedg = 1 in 1/23
	replace comparedg = 2 in 24/46
	replace comparedg = 3 in 47/69

	label define comparedg 1 "Youth-Caregiver" 2 "Youth-Teacher" 3 "Caregiver-Teacher"
	label values comparedg comparedg
	
	gen 	symptomsg = .
	foreach V in 1 24 47{
	replace symptomsg = 1 in `V'
	replace symptomsg = 2 in `=`V'+1'
	replace symptomsg = 2 in `=`V'+5'
	replace symptomsg = 3 in `=`V'+2'/`=`V'+4'
	replace symptomsg = 3 in `=`V'+6'/`=`V'+8'
	
	replace symptomsg = 1 in `=`V'+9'
	replace symptomsg = 4 in `=`V'+10'/`=`V'+15'
	
	replace symptomsg = 1 in `=`V'+16'
	replace symptomsg = 5 in `=`V'+17'/`=`V'+22'
	}

	label define symptomsg 1 "Three-domains" 2 "Anxious vs depressive" 3 "Internalizing" 4 "Inattention" 5 "Externalizing"
	label values symptomsg symptomsg
	
	gen 	coeflbl = ""
	foreach V in 1 24 47{
		* Internalizing
		replace coeflbl = "Internalizing" 							in `V'
		replace coeflbl = "Anxiety" 								in `=`V'+1'
		replace coeflbl = "Too fearful or anxious" 					in `=`V'+2'
		replace coeflbl = "Easily embarrased" 						in `=`V'+3'
		replace coeflbl = "Worries" 								in `=`V'+4'
		replace coeflbl = "Depressive" 								in `=`V'+5'
		replace coeflbl = "Feels worthless" 						in `=`V'+6'
		replace coeflbl = "Feels too guilty" 						in `=`V'+7'
		replace coeflbl = "Unhappy, sad, or depressed" 				in `=`V'+8'
		* Inattention
		replace coeflbl = "Inattention" 							in `=`V'+9'
		replace coeflbl = "Acts too young for age" 					in `=`V'+10'
		replace coeflbl = "Fails to finish things they start" 		in `=`V'+11'
		replace coeflbl = "Can't concentrate for long" 				in `=`V'+12'
		replace coeflbl = "Restless or hyperactive" 				in `=`V'+13'
		replace coeflbl = "Impulsive" 								in `=`V'+14'
		replace coeflbl = "Inattentive or easily distracted" 		in `=`V'+15'
		* Externalizing
		replace coeflbl = "Externalizing" 							in `=`V'+16'
		replace coeflbl = "Argues a lot" 							in `=`V'+17'
		replace coeflbl = "Destroys property" 						in `=`V'+18'
		replace coeflbl = "Disobedient ǂ" 							in `=`V'+19'
		replace coeflbl = "Stubborn, sullen, or irritable" 			in `=`V'+20'
		replace coeflbl = "Temper, tantrums, or hot temper" 		in `=`V'+21'
		replace coeflbl = "Threatens people" 						in `=`V'+22'
	}
	
	meta set effect st_e, studylabel(coeflbl)
	meta summarize
	meta forestplot
	
	* Differences between reporters (A)
	meta forestplot _id _plot _esci if symptomsg==1, subgroup(comparedg) 		///
	xline(0, lstyle(grid) lpattern(dash) lwidth(thick)) nooverall nonotes 		///
	noohetstats noghetstats noohomtest nogbhomtests nogwhomtests 				///
	columnopts(_id, supertitle("")) columnopts(_id, 							///
	title("")) plotregion(lcolor(white)) plotregion(ilcolor(white)) 			///
	xscale(range(-1.5 1.5)) xlabel(-1.5(0.5)1.5) 								///
	ciopts(lwidth(.75)) markeropts(msize(3))									///
	columnopts(_esci, title("")) columnopts(_esci, supertitle(""))				///	
	saving("$results\Figure1_MeanDifferences_Reporters.gph", replace)
	
restore	

	
	
********************************************************************************
***** Dropping variables from research aim 1

drop emm_yc_int1 emm_yt_int1 emm_ct_int1 emm_yc_int1a emm_yc_int1b emm_yt_int1a emm_yt_int1b emm_ct_int1a emm_ct_int1b tmm_yc_int1 tmm_yt_int1 tmm_ct_int1 tmm_yc_int1a tmm_yc_int1b tmm_yt_int1a tmm_yt_int1b tmm_ct_int1a tmm_ct_int1b emm_yc_int2 emm_yt_int2 emm_ct_int2 emm_yc_int2a emm_yc_int2b emm_yt_int2a emm_yt_int2b emm_ct_int2a emm_ct_int2b tmm_yc_int2 tmm_yt_int2 tmm_ct_int2 tmm_yc_int2a tmm_yc_int2b tmm_yt_int2a tmm_yt_int2b tmm_ct_int2a tmm_ct_int2b emm_yc_int3 emm_yt_int3 emm_ct_int3 emm_yc_int3a emm_yc_int3b emm_yt_int3a emm_yt_int3b emm_ct_int3a emm_ct_int3b tmm_yc_int3 tmm_yt_int3 tmm_ct_int3 tmm_yc_int3a tmm_yc_int3b tmm_yt_int3a tmm_yt_int3b tmm_ct_int3a tmm_ct_int3b emm_yc_int4 emm_yt_int4 emm_ct_int4 emm_yc_int4a emm_yc_int4b emm_yt_int4a emm_yt_int4b emm_ct_int4a emm_ct_int4b tmm_yc_int4 tmm_yt_int4 tmm_ct_int4 tmm_yc_int4a tmm_yc_int4b tmm_yt_int4a tmm_yt_int4b tmm_ct_int4a tmm_ct_int4b emm_yc_int5 emm_yt_int5 emm_ct_int5 emm_yc_int5a emm_yc_int5b emm_yt_int5a emm_yt_int5b emm_ct_int5a emm_ct_int5b tmm_yc_int5 tmm_yt_int5 tmm_ct_int5 tmm_yc_int5a tmm_yc_int5b tmm_yt_int5a tmm_yt_int5b tmm_ct_int5a tmm_ct_int5b emm_yc_int6 emm_yt_int6 emm_ct_int6 emm_yc_int6a emm_yc_int6b emm_yt_int6a emm_yt_int6b emm_ct_int6a emm_ct_int6b tmm_yc_int6 tmm_yt_int6 tmm_ct_int6 tmm_yc_int6a tmm_yc_int6b tmm_yt_int6a tmm_yt_int6b tmm_ct_int6a tmm_ct_int6b emm_yc_att1 emm_yt_att1 emm_ct_att1 tmm_yc_att1 tmm_yt_att1 tmm_ct_att1 emm_yc_att2 emm_yt_att2 emm_ct_att2 tmm_yc_att2 tmm_yt_att2 tmm_ct_att2 emm_yc_att3 emm_yt_att3 emm_ct_att3 tmm_yc_att3 tmm_yt_att3 tmm_ct_att3 emm_yc_att4 emm_yt_att4 emm_ct_att4 tmm_yc_att4 tmm_yt_att4 tmm_ct_att4 emm_yc_att5 emm_yt_att5 emm_ct_att5 tmm_yc_att5 tmm_yt_att5 tmm_ct_att5 emm_yc_att6 emm_yt_att6 emm_ct_att6 tmm_yc_att6 tmm_yt_att6 tmm_ct_att6 emm_yc_ext1 tmm_yc_ext1 emm_yc_ext2 tmm_yc_ext2 emm_yc_ext3 tmm_yc_ext3 emm_yc_ext4 tmm_yc_ext4 emm_yc_ext5 tmm_yc_ext5 emm_yc_ext6 tmm_yc_ext6 emm_yt_ext1 tmm_yt_ext1 emm_yt_ext2 tmm_yt_ext2 emm_yt_ext3 tmm_yt_ext3 emm_yt_ext4 tmm_yt_ext4 emm_yt_ext5 tmm_yt_ext5 emm_yt_ext6 tmm_yt_ext6 emm_ct_ext1 tmm_ct_ext1 emm_ct_ext2 tmm_ct_ext2 emm_ct_ext3 tmm_ct_ext3 emm_ct_ext4 tmm_ct_ext4 emm_ct_ext5 tmm_ct_ext5 emm_ct_ext6 tmm_ct_ext6




********************************************************************************
********************************************************************************
************ RESEARCH AIM II: PREDICTORS OF DISCREPANCIES **********************
********************************************************************************
********************************************************************************


**********************************************************
***** Main-level discrepancies 

** Covariates
global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"


foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
	matrix MM`Y' = J(18,5,.)
}

** Internalizing, inattention, and externalizing symptoms

	cap erase "${results}/Table3_PredictorsDiscrepancies.xls"
	cap erase "${results}/Table3_PredictorsDiscrepancies.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
			 
	mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1
		
		local i = 1
		foreach X in $X1 $X2 $X3{	
			matrix MM`Y'[`i',1] = _b[`X']
			matrix MM`Y'[`i',2] = _se[`X']
			
		local i = `i'+1	
		}
		
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/Table3_PredictorsDiscrepancies.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}



********************************************************************************
********************************************************************************
************* RESEARCH AIM III: DISCREPANCIES OVER TIME ************************
********************************************************************************
********************************************************************************

********************************************************************************
*** Reshaping data at the dimension level ***********************************

** Internalizing
global BPM_I		"bpm_y_int bpm_c_int bpm_t_int"

** Inattention
global BPM_A		"bpm_y_att bpm_c_att bpm_t_att"

** Externalizing
global BPM_E_YT 	"bpm_yt_ext bpm_ct_ext bpm_t_ext"
global BPM_E_TC 	"bpm_yc_ext bpm_cy_ext bpm_t_ext"


preserve

	* Internalizing
	local i = 1
	foreach V in $BPM_I {
		
		gen I`i' = `V'
		
	local i = `i'+1	
	}

	* Attention
	local i = 1
	foreach V in $BPM_A {
		
		gen A`i' = `V'
		
	local i = `i'+1	
	}

	* Externalizing
	local i = 1
	foreach V in $BPM_E_YT {
		
		gen E`i' = `V'
		
	local i = `i'+1	
	}
		
	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"	

	keep src_subject_id rsite_n site_id_l period rel_family_id1 site_cat I1-E3 $X1 $X2 $X3
	
	reshape long I A E, i(src_subject_id period) j(reporter)
	
	rename I S1
	rename A S2
	rename E S3
	
	reshape long S, i(src_subject_id period reporter) j(dimension)
	
	tempfile dimension_db
	save `dimension_db'

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	
************************************************************************************************************************
************************************************************************************************************************
	
	/* Notes: Here we create Table S6, which provides details of the results used to create Figure 2 and 
				is presented in supplemental section 4
	*/
	cap erase "${results}/TableS6_ResearchAimIII.xls"
	cap erase "${results}/TableS6_ResearchAimIII.txt"
	
	
******************************************
***************************************	
***** Differences by youth's age

** Internalizing symptoms
mixed S i.reporter##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if dimension==1 & period!=1
	quietly summ S if e(sample)==1
	local Ym = r(mean)
	quietly summ age_y if e(sample)==1
	local Xm = r(mean)		
	local NF = e(N_g)[1,2]
	quietly tab reporter if e(sample)==1
	outreg2 using "${results}/TableS6_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
	
	margins, at(age_y=(9 10 11 12 13 14 15) 		///
	reporter=(1 2 3)) 
	
	marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
	ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
	ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
	ytitle("Internalizing symptoms", size(medlarge)) xtitle("Youth's age", size(medlarge))								///
	title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(1)4)												///
	legend(cols(1) rows(1) ring(0) position(12) region(lstyle(none)) size(medlarge))									///
	plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
	plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
	plot(, label("Youth" "Caregiver"  																					///
	"Teacher", labsize(medlarge))) plotopts(msymbol(i)) saving("${results}/Figure2a_Internalizing.gph", replace)															

graph export "${results}/Figure2a_Internalizing.png", as(jpg) name("Graph") quality(90) replace


** Inattention symptoms
mixed S i.reporter##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if dimension==2 & period!=1
	quietly summ S if e(sample)==1
	local Ym = r(mean)
	quietly summ age_y if e(sample)==1
	local Xm = r(mean)		
	local NF = e(N_g)[1,2]
	outreg2 using "${results}/TableS6_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
	
	margins, at(age_y=(9 10 11 12 13 14 15) 		///
	reporter=(1 2 3)) 
	
	marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
	ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
	ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
	ytitle("Inattention symptoms", size(medlarge)) xtitle("Youth's age", size(medlarge))								///
	title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(1)4)												///
	legend(off)																										///
	plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
	plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
	plot(, label("Youth" "Caregiver"  																					///
	"Teacher", labsize(medlarge))) plotopts(msymbol(i)) saving("${results}/Figure2b_Inattention.gph", replace)															

graph export "${results}/Figure2b_Inattention.png", as(jpg) name("Graph") quality(90) replace


** Externalizing symptoms
mixed S i.reporter##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if dimension==3 & period!=1
	quietly summ S if e(sample)==1
	local Ym = r(mean)
	quietly summ age_y if e(sample)==1
	local Xm = r(mean)		
	local NF = e(N_g)[1,2]
	outreg2 using "${results}/TableS6_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
	
	margins, at(age_y=(9 10 11 12 13 14 15) 		///
	reporter=(1 2 3)) 
	
	marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
	ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
	ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
	ytitle("Externalizing symptoms", size(medlarge)) xtitle("Youth's age", size(medlarge))								///
	title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(1)4)												///
	legend(off)																										///
	plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
	plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
	plot(, label("Youth" "Caregiver"  																					///
	"Teacher", labsize(medlarge))) plotopts(msymbol(i)) saving("${results}/Figure2c_Externalizing.gph", replace)															

graph export "${results}/Figure2c_Externalizing.png", as(jpg) name("Graph") quality(90) replace

	
** All symptoms
mixed S i.reporter##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1
	quietly summ S if e(sample)==1
	local Ym = r(mean)
	quietly summ age_y if e(sample)==1
	local Xm = r(mean)		
	local NF = e(N_g)[1,2]
	outreg2 using "${results}/TableS6_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
			
	margins, at(age_y=(9 10 11 12 13 14 15) 		///
	reporter=(1 2 3)) 
	
	marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
	ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
	ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
	ytitle("All symptoms", size(medlarge)) xtitle("Youth's age", size(medlarge))										///
	title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(1)4)												///
	legend(off)																										///
	plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
	plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
	plot(, label("Youth" "Caregiver"  																					///
	"Teacher", labsize(medlarge))) plotopts(msymbol(i)) saving("${results}/Figure2d_ThreeMHDomains.gph", replace)															

graph export "${results}/Figure2d_ThreeMHDomains.png", as(jpg) name("Graph") quality(90) replace	

restore


graph combine 	"${results}/Figure2a_Internalizing.gph" "${results}/Figure2b_Inattention.gph" 	///
				"${results}/Figure2c_Externalizing.gph" "${results}/Figure2d_ThreeMHDomains.gph", 	///
				cols(2) ycommon saving("${results}/Figure2.gph", replace)



********************************************************************************
********************************************************************************
********************* SUPPLEMENTARY SECTIONS ***********************************
********************************************************************************
********************************************************************************

/*
	Supplemental Sections (SS)
	
	SS 1: MORE DETAILS ABOUT THE MEASURES AND DESCRIPTIVE STATISTICS AT BASELINE
	SS 2: ALTERNATIVE DEFINITIONS OF DISCREPANCIES
	SS 3: MULTIPLE IMPUTATION
	SS 4: MULTIPLE TESTING
	SS 5: ALTERNATIVE SPECIFICATIONS FOR PREDICTORS MODEL
	SS 6: USING PERIODS RATHER THAN YOUTH'S AGE
	SS 7: MAIN RESULTS REPORTED USING STANDARDIZED COEFFICIENTS
	SS 8: DISCREPANCIES ARE CLINICALLY MEANINGFUL
	SS 9: SYMPTOM BY SYMPTOM ANALYSIS

*/


********************************************************************************
********************************************************************************
***** Supplemental Section (SS) 1 

* Internalzing symptoms

local BPM_T		"bpmt_q10 bpmt_q12 bpmt_q18 bpmt_q8 bpmt_q11 bpmt_q17"
local BPM_Y 	"bpm_11_y bpm_13_y bpm_19_y bpm_9_y bpm_12_y bpm_18_y"
local BPM_C 	"cbcl_q50_p cbcl_q71_p cbcl_q112_p cbcl_q35_p cbcl_q52_p cbcl_q103_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

* Inattention symptoms

local BPM_T		"bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13"
local BPM_Y 	"bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y"
local BPM_C 	"cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

* Externalizing symptoms, youth - caregiver

local BPM_Y 	"bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y"
local BPM_C 	"cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_C' if period==2
alpha `BPM_C' if period==3
alpha `BPM_C' if period==4

* Externalizing symptoms, youth - teacher

local BPM_T		"bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16"
local BPM_Y 	"bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y"

alpha `BPM_Y' if period==2
alpha `BPM_Y' if period==3
alpha `BPM_Y' if period==4

alpha `BPM_T' if period==2
alpha `BPM_T' if period==3
alpha `BPM_T' if period==4


preserve

	matrix T = J(22,5,.)

	local n = 1
	foreach v of varlist bpm_c_int bpm_c_att bpm_cy_ext age_y girl_y nonwhite_y puberty_y immigrant_y age_p woman_p nonwhite_p immigrant_p depre_p educ_lev_p1 educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5 pwarmth_s school_positive_s family_conf_s neighborhood_s {
		sum `v' if wave1==1
			matrix T[`n',1] = r(min)
			matrix T[`n',2] = r(max)
			matrix T[`n',3] = r(N)
			matrix T[`n',4] = r(mean)
			matrix T[`n',5] = r(sd)
				
		local n = `n'+1
	}

	matrix list T
restore

preserve
	svmat T
	keep if T2!=.
	keep T1 T2 T3 T4 T5

	export excel using "$results/TableS1_Descriptive_Baseline.xlsx", replace firstr(var)
restore



****************************************************************************************************
****************************************************************************************************
***** Supplemental Section (SS) 2: Statistically significant vs. meaningful findings			

**********************************************************
***** Prevalence table		

* SETUP

local sample "if period!=1"  

* Thresholds to evaluate
local threshlist 3 4 5 6 7 8 9 10 11 12

* Domain score variables (Y, C, T)
local INT_vars "bpm_y_int bpm_c_int bpm_t_int"
local INA_vars "bpm_y_att bpm_c_att bpm_t_att"
local EXT_vars "bpm_yc_ext bpm_cy_ext bpm_ct_ext"

local ALL_vars "`INT_vars' `INA_vars' `EXT_vars'"

* Initialize matrix: rows = #thresholds, cols = 9 (3 domains x 3 reporters)
local n_thresh : word count `threshlist'
matrix Mprev = J(`n_thresh', 9, .)

*****************************************************
* LOOP OVER THRESHOLDS, FILL PREVALENCE MATRIX

local r = 0
foreach th of local threshlist {
    local ++r

    * Loop over the 9 variables in ALL_vars
    forvalues c = 1/9 {
        local v : word `c' of `ALL_vars'
        tempvar tmp
        quietly gen byte `tmp' = (`v' >= `th') `sample' & `v'!=. & `th'!=.
        quietly summarize `tmp'
        matrix Mprev[`r', `c'] = r(mean)
        drop `tmp'
    }
}

*****************************************************
* ADD THRESHOLD COLUMN AND EXPORT AS CSV

* Make a column vector with the threshold values
matrix Th = (3 \ 4 \ 5 \ 6 \ 7 \ 8 \ 9 \ 10 \ 11 \ 12)

* Combine thresholds + prevalence matrix into one matrix
matrix Mprev_full = Th, Mprev

preserve
    clear
    svmat2 double Mprev_full

    * Rename columns to match your table structure
    rename Mprev_full1 threshold
    rename Mprev_full2 INT_Youth
    rename Mprev_full3 INT_Caregiver
    rename Mprev_full4 INT_Teacher
    rename Mprev_full5 INA_Youth
    rename Mprev_full6 INA_Caregiver
    rename Mprev_full7 INA_Teacher
    rename Mprev_full8 EXT_Youth
    rename Mprev_full9 EXT_Caregiver
    rename Mprev_full10 EXT_Teacher

    * Export to CSV (edit path if needed)
    export delimited using "${results}/TableS2_Threshold_prevalence.csv", ///
        replace
restore



**********************************************************
***** Mismatch table: % diagnosis disagreements

*****************************************************
* MISMATCH TABLE: Y–C, Y–T, C–T FOR EACH DOMAIN
*****************************************************

* Domain score variables again, grouped by domain
local INT_vars "bpm_y_int bpm_c_int bpm_t_int"
local INA_vars "bpm_y_att bpm_c_att bpm_t_att"
local EXT_vars "bpm_yc_ext bpm_cy_ext bpm_ct_ext"

* Matrix for mismatches: rows = thresholds, cols = 9:
*   INT_YC INT_YT INT_CT  INA_YC INA_YT INA_CT  EXT_YC EXT_YT EXT_CT
local n_thresh : word count `threshlist'
matrix Mmism = J(`n_thresh', 9, .)

local r = 0
foreach th of local threshlist {
    local ++r

    *************************************************
    * INTERNALIZING: bpm_y_int, bpm_c_int, bpm_t_int
    *************************************************
    local v1_int : word 1 of `INT_vars'   // youth
    local v2_int : word 2 of `INT_vars'   // caregiver
    local v3_int : word 3 of `INT_vars'   // teacher

    * Y–C mismatch (INT)
    tempvar a b mis
    quietly gen byte `a' = (`v1_int' >= `th') `sample' & `v1_int'!=. & `th'!=.
    quietly gen byte `b' = (`v2_int' >= `th') `sample' & `v2_int'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',1] = r(mean)
    drop `a' `b' `mis'

    * Y–T mismatch (INT)
    tempvar a b mis
    quietly gen byte `a' = (`v1_int' >= `th') `sample' & `v1_int'!=. & `th'!=.
    quietly gen byte `b' = (`v3_int' >= `th') `sample' & `v3_int'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',2] = r(mean)
    drop `a' `b' `mis'

    * C–T mismatch (INT)
    tempvar a b mis
    quietly gen byte `a' = (`v2_int' >= `th') `sample' & `v2_int'!=. & `th'!=.
    quietly gen byte `b' = (`v3_int' >= `th') `sample' & `v3_int'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',3] = r(mean)
    drop `a' `b' `mis'

    *************************************************
    * INATTENTION: bpm_y_att, bpm_c_att, bpm_t_att
    *************************************************
    local v1_ina : word 1 of `INA_vars'
    local v2_ina : word 2 of `INA_vars'
    local v3_ina : word 3 of `INA_vars'

    * Y–C mismatch (INA)
    tempvar a b mis
    quietly gen byte `a' = (`v1_ina' >= `th') `sample' & `v1_ina'!=. & `th'!=.
    quietly gen byte `b' = (`v2_ina' >= `th') `sample' & `v2_ina'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',4] = r(mean)
    drop `a' `b' `mis'

    * Y–T mismatch (INA)
    tempvar a b mis
    quietly gen byte `a' = (`v1_ina' >= `th') `sample' & `v1_ina'!=. & `th'!=.
    quietly gen byte `b' = (`v3_ina' >= `th') `sample' & `v3_ina'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',5] = r(mean)
    drop `a' `b' `mis'

    * C–T mismatch (INA)
    tempvar a b mis
    quietly gen byte `a' = (`v2_ina' >= `th') `sample' & `v2_ina'!=. & `th'!=.
    quietly gen byte `b' = (`v3_ina' >= `th') `sample' & `v3_ina'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',6] = r(mean)
    drop `a' `b' `mis'

    *************************************************
    * EXTERNALIZING: bpm_y_ext, bpm_c_ext, bpm_t_ext
    *************************************************
    local v1_ext : word 1 of `EXT_vars'
    local v2_ext : word 2 of `EXT_vars'
    local v3_ext : word 3 of `EXT_vars'

    * Y–C mismatch (EXT)
    tempvar a b mis
    quietly gen byte `a' = (`v1_ext' >= `th') `sample' & `v1_ext'!=. & `th'!=.
    quietly gen byte `b' = (`v2_ext' >= `th') `sample' & `v2_ext'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',7] = r(mean)
    drop `a' `b' `mis'

    * Y–T mismatch (EXT)
    tempvar a b mis
    quietly gen byte `a' = (`v1_ext' >= `th') `sample' & `v1_ext'!=. & `th'!=.
    quietly gen byte `b' = (`v3_ext' >= `th') `sample' & `v3_ext'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',8] = r(mean)
    drop `a' `b' `mis'

    * C–T mismatch (EXT)
    tempvar a b mis
    quietly gen byte `a' = (`v2_ext' >= `th') `sample' & `v2_ext'!=. & `th'!=.
    quietly gen byte `b' = (`v3_ext' >= `th') `sample' & `v3_ext'!=. & `th'!=.
    quietly gen byte `mis' = (`a' != `b') if `a' < . & `b' < .
    quietly summarize `mis'
    matrix Mmism[`r',9] = r(mean)
    drop `a' `b' `mis'
}

*****************************************************
* ADD THRESHOLD COLUMN AND EXPORT MISMATCH TABLE
*****************************************************

matrix Th = (3 \ 4 \ 5 \ 6 \ 7 \ 8 \ 9 \ 10 \ 11 \ 12)
matrix Mmism_full = Th, Mmism

preserve
    clear
    svmat double Mmism_full

    rename Mmism_full1 threshold
    rename Mmism_full2 INT_YC
    rename Mmism_full3 INT_YT
    rename Mmism_full4 INT_CT
    rename Mmism_full5 INA_YC
    rename Mmism_full6 INA_YT
    rename Mmism_full7 INA_CT
    rename Mmism_full8 EXT_YC
    rename Mmism_full9 EXT_YT
    rename Mmism_full10 EXT_CT

    export delimited using "${results}/TableS3_Threshold_Mismatch.csv", ///
        replace
restore


********************************************************************************
***** Reliability of different reporters/ground truth

*** Diagnosis mismatches

* Internalizing diagnoses
* Y–C mismatch: 1 if youth and caregiver differ (and both observed)
	gen dxm_dep_yc = DEP_dgnss_t != DEP_dgnss_p if !missing(DEP_dgnss_t, DEP_dgnss_p) & period==3
	gen dxm_anx_yc = ANX_cdgnss_t != ANX_cdgnss_p if !missing(ANX_cdgnss_t, ANX_cdgnss_p) & period==3
	gen dxm_int_yc = INT_cdgnss_t != INT_cdgnss_p if !missing(INT_cdgnss_t, INT_cdgnss_p) & period==3

* Externalizing diagnoses
gen dxm_ext_yc = EXT_cdgnss_t != EXT_cdgnss_p if !missing(EXT_cdgnss_t, EXT_cdgnss_p) & period==3
*gen dxm_ext_yt = dx_ext_y != dx_ext_t if !missing(dx_ext_y, dx_ext_t)
*gen dxm_ext_ct = dx_ext_c != dx_ext_t if !missing(dx_ext_c, dx_ext_t)

tab dxm_int_yc
*tab dxm_inatt_yc
tab dxm_ext_yc


*** Symptoms mismatches (Absolute discrepancies for interpreting mismatch risk) 

* Internalizing
gen abs_rd_yc_dep = abs(rd_yc_intd)
gen abs_rd_yc_anx = abs(rd_yc_intx)

gen abs_rd_yc_int = abs(rd_yc_int)
gen abs_rd_yt_int = abs(rd_yt_int)
gen abs_rd_ct_int = abs(rd_ct_int)

* Inattention
gen abs_rd_yc_inatt = abs(rd_yc_att)
gen abs_rd_yt_inatt = abs(rd_yt_att)
gen abs_rd_ct_inatt = abs(rd_ct_att)

* Externalizing
gen abs_rd_yc_ext = abs(rd_yc_ext)
gen abs_rd_yt_ext = abs(rd_yt_ext)
gen abs_rd_ct_ext = abs(rd_ct_ext)


*** Linear probability model: Dx mismatch ~ Sx discrepancy (abs)

	cap erase "${results}/TableS4_Dx_Sx_Mismatches.xls"
	cap erase "${results}/TableS4_Dx_Sx_Mismatches.txt"
			
* Depression
	regress dxm_dep_yc c.abs_rd_yc_dep if period==3, vce(cluster rel_family_id1)
		quietly summ dxm_dep_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_dep if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
	* Marginal effect (here the coefficient itself is in probability units)
	* e.g., b = 0.08 means +8 percentage points per 1-unit discrepancy

* Anxiety
	regress dxm_anx_yc c.abs_rd_yc_anx if period==3, vce(cluster rel_family_id1)
		quietly summ dxm_anx_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_anx if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

* Internalizing
	regress dxm_int_yc c.abs_rd_yc_int if period==3, vce(cluster rel_family_id1)
		quietly summ dxm_int_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_int if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

* Externalizing
	regress dxm_ext_yc c.abs_rd_yc_ext   if period==3, vce(cluster rel_family_id1)
		quietly summ dxm_ext_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_int if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

	
*** Logit model: Dx mismatch ~ Sx discrepancy (abs)

* Depression - * Marginal effect of a 1-unit increase in abs discrepancy
	logit dxm_dep_yc c.abs_rd_yc_dep if period==3, vce(cluster rel_family_id1)
		margins, dydx(abs_rd_yc_dep) post
		quietly summ dxm_dep_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_dep if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append	

* Anxiety- * Marginal effect of a 1-unit increase in abs discrepancy	
	logit dxm_anx_yc c.abs_rd_yc_anx if period==3, vce(cluster rel_family_id1)
		margins, dydx(abs_rd_yc_anx) post
		quietly summ dxm_anx_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_anx if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
	
* Internalizing - * Marginal effect of a 1-unit increase in abs discrepancy	
	logit dxm_int_yc c.abs_rd_yc_int if period==3, vce(cluster rel_family_id1)
		margins, dydx(abs_rd_yc_int) post
		quietly summ dxm_int_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_int if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append	
		
* Externalizing - * Marginal effect of a 1-unit increase in abs discrepancy	
	logit dxm_ext_yc c.abs_rd_yc_ext if period==3, vce(cluster rel_family_id1)
		margins, dydx(abs_rd_yc_ext) post
		quietly summ dxm_ext_yc if e(sample)==1
		local Ym = r(mean)
		quietly summ abs_rd_yc_ext if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_clust)	
	outreg2 using "${results}/TableS4_Dx_Sx_Mismatches.xls", addstat(YMean, `Ym', XMean, `Xm') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append	

				
****************************************************************************************************
****************************************************************************************************
***** Supplemental Section (SS) 3:  Symptom by symptom analysis

** Youth - Caregivers
	
	** Raw diff
	matrix D_yc = ID_yc\AD_yc\ED_yc	
	matrix Dall_yc = D_yc[1..., 3] 
	
	** Standardized diff
	matrix ttycSD = IttycSD\AttycSD\EttycSD
	matrix ttallycSD = ttycSD[1..., 3] 
	
	** Number of observations and pvalues
	matrix ttyc = Ittyc\Attyc\Ettyc
	matrix ttxallyc = ttyc[1..., 3] 
	
** Youth - Teachers
	
	** Raw diff	
	matrix D_yt = ID_yt\AD_yt\ED_yt
	matrix Dall_yt = D_yt[1..., 3] 
	
	** Standardized diff
	matrix ttytSD = IttytSD\AttytSD\EttytSD
	matrix ttallytSD = ttytSD[1..., 3] 
	
	** Number of observations and pvalues
	matrix ttyt = Ittyt\Attyt\Ettyt
	matrix ttxallyt = ttyt[1..., 3] 
		
** Caregivers - Teachers
	
	** Raw diff	
	matrix D_ct = ID_ct\AD_ct\ED_ct
	matrix Dall_ct = D_ct[1..., 3] 
	
	** Standardized diff
	matrix ttctSD = IttctSD\AttctSD\EttctSD
	matrix ttallctSD = ttctSD[1..., 3] 
	
	** Number of observations and pvalues
	matrix ttct = Ittct\Attct\Ettct
	matrix ttxallct = ttct[1..., 3] 
		

**********************************************************	
***** Table S24 - Sx by Sx mean discrepancies
	
	matrix TS24 = Dall_yc, ttallycSD, Dall_yt, ttallytSD, Dall_ct, ttallctSD
	xml_tab TS24, save("$results\TableS5_T2_MeanDifferencesSx.xml") t(Sx by Sx Discrepancies) replace
	
	matrix TS24_pv = ttxallyc, ttxallyt, ttxallct
	xml_tab TS24_pv, save("$results\TableS5_T2_MeanDifferencesSx_pvalues.xml") t(Sx by Sx Discrepancies, pvalues) replace



******************************************************************
***** Exporting data to create Figure S1 - Radar plots in Excel

*0. Create the variables to plot

*----------------------------------------------------------------------
* 1. INTERNALIZING DOMAIN
*    1  Too fearful or anxious
*    2  Easily embarrassed
*    3  Worries
*    4  Feels worthless
*    5  Feels too guilty
*    6  Unhappy, sad, or depressed
*----------------------------------------------------------------------

* Symptom-level internalizing discrepancies

	* Too fearful or anxious
	gen rd_yc_fear = bpm_11_y   - cbcl_q50_p
	gen rd_yt_fear = bpm_11_y   - bpmt_q10
	gen rd_ct_fear = cbcl_q50_p - bpmt_q10

	* Easily embarrassed
	gen rd_yc_emb  = bpm_13_y   - cbcl_q71_p
	gen rd_yt_emb  = bpm_13_y   - bpmt_q12
	gen rd_ct_emb  = cbcl_q71_p - bpmt_q12

	* Worries
	gen rd_yc_worr = bpm_19_y    - cbcl_q112_p
	gen rd_yt_worr = bpm_19_y    - bpmt_q18
	gen rd_ct_worr = cbcl_q112_p - bpmt_q18

	* Feels worthless
	gen rd_yc_worth = bpm_9_y   - cbcl_q35_p
	gen rd_yt_worth = bpm_9_y   - bpmt_q8
	gen rd_ct_worth = cbcl_q35_p - bpmt_q8

	* Feels too guilty
	gen rd_yc_guilt = bpm_12_y   - cbcl_q52_p
	gen rd_yt_guilt = bpm_12_y   - bpmt_q11
	gen rd_ct_guilt = cbcl_q52_p - bpmt_q11

	* Unhappy, sad, or depressed
	gen rd_yc_unhap = bpm_18_y   - cbcl_q103_p
	gen rd_yt_unhap = bpm_18_y   - bpmt_q17
	gen rd_ct_unhap = cbcl_q103_p - bpmt_q17


*----------------------------------------------------------------------
* 2. INATTENTION DOMAIN

*    7 Acts too young for age
*    8 Fails to finish things they start
*    9 Can't concentrate for long
*    10 Restless or hyperactive
*    11 Impulsive
*    12 Inattentive or easily distracted
*----------------------------------------------------------------------

* 2b. Symptom-level inattention discrepancies

	* Acts too young for age
	gen rd_yc_young = bpm_1_y    - cbcl_q01_p
	gen rd_yt_young = bpm_1_y    - bpmt_q1
	gen rd_ct_young = cbcl_q01_p - bpmt_q1

	* Fails to finish things they start
	gen rd_yc_finish = bpm_3_y    - cbcl_q04_p
	gen rd_yt_finish = bpm_3_y    - bpmt_q3
	gen rd_ct_finish = cbcl_q04_p - bpmt_q3

	* Can't concentrate for long
	gen rd_yc_conc = bpm_4_y    - cbcl_q08_p
	gen rd_yt_conc = bpm_4_y    - bpmt_q4
	gen rd_ct_conc = cbcl_q08_p - bpmt_q4

	* Restless or hyperactive
	gen rd_yc_rest = bpm_5_y    - cbcl_q10_p
	gen rd_yt_rest = bpm_5_y    - bpmt_q5
	gen rd_ct_rest = cbcl_q10_p - bpmt_q5

	* Impulsive
	gen rd_yc_imp = bpm_10_y    - cbcl_q41_p
	gen rd_yt_imp = bpm_10_y    - bpmt_q9
	gen rd_ct_imp = cbcl_q41_p  - bpmt_q9

	* Inattentive or easily distracted
	gen rd_yc_distr = bpm_14_y    - cbcl_q78_p
	gen rd_yt_distr = bpm_14_y    - bpmt_q13
	gen rd_ct_distr = cbcl_q78_p  - bpmt_q13


*----------------------------------------------------------------------
* 3. EXTERNALIZING DOMAIN
*    13 Argues a lot
*    14 Destroys property
*    15 Disobedient to caregivers
*    16 Stubborn, sullen, or irritable
*    17 Temper, tantrums, or hot temper
*    18 Threatens people
*----------------------------------------------------------------------

* Symptom-level externalizing discrepancies

	* Argues a lot
	gen rd_yc_arg = bpm_2_y    - cbcl_q03_p
	gen rd_yt_arg = bpm_2_y    - bpmt_q2
	gen rd_ct_arg = cbcl_q03_p - bpmt_q2

	* Destroys property
	gen rd_yc_destr = bpm_6_y    - cbcl_q21_p
	gen rd_yt_destr = bpm_6_y    - bpmt_q6
	gen rd_ct_destr = cbcl_q21_p - bpmt_q6

	* Disobedient (at home / at school)
	* - YC: youth "disobedient to caregivers" vs CBCL "disobedient at home" (q22)
	* - YT: youth "disobedient at school" vs teacher "disobedient at school" (q14)
	* - CT: caregiver "disobedient at school" vs teacher "disobedient at school"
	gen rd_yc_disob = bpm_17_y   - cbcl_q22_p
	gen rd_yt_disob = bpm_8_y    - bpmt_q14
	gen rd_ct_disob = cbcl_q23_p - bpmt_q14

	* Stubborn, sullen, or irritable
	gen rd_yc_irrit = bpm_7_y    - cbcl_q86_p
	gen rd_yt_irrit = bpm_7_y    - bpmt_q7
	gen rd_ct_irrit = cbcl_q86_p - bpmt_q7

	* Temper, tantrums, or hot temper
	gen rd_yc_tantr = bpm_15_y   - cbcl_q95_p
	gen rd_yt_tantr = bpm_15_y   - bpmt_q15
	gen rd_ct_tantr = cbcl_q95_p - bpmt_q15

	* Threatens people
	gen rd_yc_threat = bpm_16_y   - cbcl_q97_p
	gen rd_yt_threat = bpm_16_y   - bpmt_q16
	gen rd_ct_threat = cbcl_q97_p - bpmt_q16


*** 1. Helper program to create radar-ready Excel sheets

*---------------------------------------------------------------*
* Program: make_radar_sheet
*   Inputs:
*     1: local with item varlist
*     2: Excel sheet name
*---------------------------------------------------------------*
capture program drop make_radar_sheet
program define make_radar_sheet
    syntax varlist(numeric), Sheetname(string) File(string)

    preserve
        * Collapse to means by period
        *collapse (mean) ``varlist_macro'' , by(period)
		collapse (mean) `varlist' if period>=2 , by(period)

        * Optional: label period nicely
        label var period "Wave/Period"

        * Export to Excel, one sheet per call
        export excel using "`file'", sheet("`sheetname'") ///
            firstrow(varlabels) sheetreplace
    restore
end

*** 2. Call the program for each domain × reporter pair
* 		Pick a single Excel file to collect all sheets (e.g., "${results}/radar_discrepancies.xlsx")

* Define output Excel file
local radarfile "${results}/radar_discrepancies.xlsx"

* INTERNALIZING items (fear, embar, worries, worthless, guilty, unhappy)
local int_items_yc "rd_yc_fear rd_yc_emb rd_yc_worr rd_yc_worth rd_yc_guilt rd_yc_unhap"
local int_items_yt "rd_yt_fear rd_yt_emb rd_yt_worr rd_yt_worth rd_yt_guilt rd_yt_unhap"
local int_items_ct "rd_ct_fear rd_ct_emb rd_ct_worr rd_ct_worth rd_ct_guilt rd_ct_unhap"

* INATTENTION items (inattentive, young, fails to finish, can't concentrate, restless, impulsive, distracted)
local ina_items_yc "rd_yc_young rd_yc_finish rd_yc_conc rd_yc_rest rd_yc_imp rd_yc_distr"
local ina_items_yt "rd_yt_young rd_yt_finish rd_yt_conc rd_yt_rest rd_yt_imp rd_yt_distr"
local ina_items_ct "rd_ct_young rd_ct_finish rd_ct_conc rd_ct_rest rd_ct_imp rd_ct_distr"

* EXTERNALIZING items (argues, destroys, disobedient, irritable, tantrums, threatens)
local ext_items_yc "rd_yc_arg rd_yc_destr rd_yc_disob rd_yc_irrit rd_yc_tantr rd_yc_threat"
local ext_items_yt "rd_yt_arg rd_yt_destr rd_yt_disob rd_yt_irrit rd_yt_tantr rd_yt_threat"
local ext_items_ct "rd_ct_arg rd_ct_destr rd_ct_disob rd_ct_irrit rd_ct_tantr rd_ct_threat"


* INTERNALIZING
make_radar_sheet `int_items_yc', sheetname("INT_YC") file("`radarfile'")
make_radar_sheet `int_items_yt ', sheetname("INT_YT") file("`radarfile'")
make_radar_sheet `int_items_ct ', sheetname("INT_CT") file("`radarfile'")

* INATTENTION
make_radar_sheet `ina_items_yc', sheetname("INA_YC") file("`radarfile'")
make_radar_sheet `ina_items_yt', sheetname("INA_YT") file("`radarfile'")
make_radar_sheet `ina_items_ct', sheetname("INA_CT") file("`radarfile'")

* EXTERNALIZING
make_radar_sheet `ext_items_yc', sheetname("EXT_YC") file("`radarfile'")
make_radar_sheet `ext_items_yt', sheetname("EXT_YT") file("`radarfile'")
make_radar_sheet `ext_items_ct', sheetname("EXT_CT") file("`radarfile'")



*** SYMPTOMS 

* Define output Excel file
local radarfile_Sx "${results}/radar_symptoms.xlsx"

* Internalizing
local BPM_T		"bpmt_q10 bpmt_q12 bpmt_q18 bpmt_q8 bpmt_q11 bpmt_q17"
local BPM_Y 	"bpm_11_y bpm_13_y bpm_19_y bpm_9_y bpm_12_y bpm_18_y"
local BPM_C 	"cbcl_q50_p cbcl_q71_p cbcl_q112_p cbcl_q35_p cbcl_q52_p cbcl_q103_p"

make_radar_sheet `BPM_Y', sheetname("INT_Y") file("`radarfile_Sx'")
make_radar_sheet `BPM_C', sheetname("INT_C") file("`radarfile_Sx'")
make_radar_sheet `BPM_T', sheetname("INT_T") file("`radarfile_Sx'")

* Innatention
local BPM_T		"bpmt_q1 bpmt_q3 bpmt_q4 bpmt_q5 bpmt_q9 bpmt_q13"
local BPM_Y 	"bpm_1_y bpm_3_y bpm_4_y bpm_5_y bpm_10_y bpm_14_y"
local BPM_C 	"cbcl_q01_p cbcl_q04_p cbcl_q08_p cbcl_q10_p cbcl_q41_p cbcl_q78_p"

make_radar_sheet `BPM_Y', sheetname("INA_Y") file("`radarfile_Sx'")
make_radar_sheet `BPM_C', sheetname("INA_C") file("`radarfile_Sx'")
make_radar_sheet `BPM_T', sheetname("INA_T") file("`radarfile_Sx'")

*** Externalizing
local BPM_YC 	"bpm_yc_ext bpm_2_y bpm_6_y bpm_7_y bpm_15_y bpm_16_y bpm_17_y"
local BPM_CY 	"bpm_cy_ext cbcl_q03_p cbcl_q21_p cbcl_q22_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"
local BPM_T		"bpm_t_ext bpmt_q2 bpmt_q6 bpmt_q7 bpmt_q14 bpmt_q15 bpmt_q16"
local BPM_CT 	"bpm_ct_ext cbcl_q03_p cbcl_q21_p cbcl_q23_p cbcl_q86_p cbcl_q95_p cbcl_q97_p"
local BPM_YT 	"bpm_yt_ext bpm_2_y bpm_6_y bpm_8_y bpm_15_y bpm_16_y bpm_17_y"

* 18(20) Sx to show
make_radar_sheet `BPM_YC', sheetname("EXT_YC") file("`radarfile_Sx'")
make_radar_sheet `BPM_CY', sheetname("EXT_CY") file("`radarfile_Sx'")
make_radar_sheet `BPM_T', sheetname("EXT_T") file("`radarfile_Sx'")

* Alternative Sx (we could show)
make_radar_sheet `BPM_CT', sheetname("EXT_CT") file("`radarfile_Sx'")
make_radar_sheet `BPM_YT', sheetname("EXT_YT") file("`radarfile_Sx'")



****************************************************************************************************
****************************************************************************************************
***** Supplemental Section (SS) 4:  Estimates from model testing discrepancies over time

/*
	Estimated above when creating Figure 2; See Note in line 2,494-2,496
*/

***********************************************************************************************
***********************************************************************************************
***** Supplemental Section (SS) 5: Alternative definitions for reporters' discrepancies


***********************************************************************
********** (a) Exact mismatches

***************************	
***** AIM I 

***** Youth - Caregivers
	
** Diff in Sx, Youth - Caregivers, raw
	matrix EM_yc = IEMMp_yc\AEMMp_yc\EEMMp_yc
	matrix EMx_yc = EM_yc[1, 3] \ EM_yc[10, 3] \ EM_yc[17, 3]
	
***** Youth - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix EM_yt = IEMMp_yt\AEMMp_yt\EEMMp_yt
	matrix EMx_yt = EM_yt[1, 3] \ EM_yt[10, 3] \ EM_yt[17, 3]
	
***** Caregivers - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix EM_ct = IEMMp_ct\AEMMp_ct\EEMMp_ct
	matrix EMx_ct = EM_ct[1, 3] \ EM_ct[10, 3] \ EM_ct[17, 3]

***** Table S2 - Exact mismatches
	
	matrix TS2 = EMx_yc, EMx_yt, EMx_ct
	xml_tab TS2, save("$results\TableS7_ExactMismatches.xml") t(Sx Exact Mismatches) replace
	
	
***************************	
***** AIM II

** Covariates
global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"


foreach Y in emm_yc_int_p emm_yc_att_p emm_yc_ext_p emm_yt_int_p emm_yt_att_p emm_yt_ext_p emm_ct_int_p emm_ct_att_p emm_ct_ext_p {
	matrix MM`Y' = J(18,5,.)
}

** Internalizing, inattention, and externalizing symptoms

	cap erase "${results}/TableS8_PredictorsExactMismatches.xls"
	cap erase "${results}/TableS8_PredictorsExactMismatches.txt"
	
foreach Y in emm_yc_int_p emm_yc_att_p emm_yc_ext_p emm_yt_int_p emm_yt_att_p emm_yt_ext_p emm_ct_int_p emm_ct_att_p emm_ct_ext_p {
			 
	mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1
		
		local i = 1
		foreach X in $X1 $X2 $X3{	
			matrix MM`Y'[`i',1] = _b[`X']
			matrix MM`Y'[`i',2] = _se[`X']
			
		local i = `i'+1	
		}
		
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS8_PredictorsExactMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}


****************************************
***** AIM III

** Internalizing
global EMM_I		"emm_yc_int_p emm_yt_int_p emm_ct_int_p"

** Inattention
global EMM_A		"emm_yc_att_p emm_yt_att_p emm_ct_att_p"

** Externalizing
global EMM_E		"emm_yc_ext_p emm_yt_ext_p emm_ct_ext_p"



preserve

	* Internalizing, EMM
	local i = 1
	foreach V in $EMM_I {
		
		gen IEMM`i' = `V'
		
	local i = `i'+1	
	}

	* Attention, EMM
	local i = 1
	foreach V in $EMM_A {
		
		gen AEMM`i' = `V'
		
	local i = `i'+1	
	}

	* Externalizing, EMM
	local i = 1
	foreach V in $EMM_E {
		
		gen EEMM`i' = `V'
		
	local i = `i'+1	
	}
	
	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"	

	keep src_subject_id rsite_n site_id_l period rel_family_id1 site_cat IEMM1-EEMM3 $X1 $X2 $X3
	
	reshape long IEMM AEMM EEMM, i(src_subject_id period) j(reporters)
	
	rename IEMM EMM1
	rename AEMM EMM2
	rename EEMM EMM3
	
	reshape long EMM, i(src_subject_id period reporters) j(dimension)

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p"
	global X3 			"pwarmth_s school_positive_s family_conf_s neighborhood_s"
	
	
	cap erase "${results}/TableS9_ResearchAim3_ExactMismatches.xls"
	cap erase "${results}/TableS9_ResearchAim3_ExactMismatches.txt"
	

	mixed EMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==1
		quietly summ EMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS9_ResearchAim3_ExactMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("Exact mismatches, internalizing", size(medsmall)) xtitle("Youth's age", size(medlarge))						///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(cols(1) rows(1) ring(0) position(12) region(lstyle(none)) size(medlarge))									///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Y - C" "Y - T" "C - T", labsize(medlarge))) plotopts(msymbol(i)) 										///
		saving("${results}/FigureS2a_Internalizing.gph", replace)															

	graph export "${results}/FigureS2a_Internalizing.png", as(jpg) name("Graph") quality(90) replace	

	mixed EMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==2
		quietly summ EMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS9_ResearchAim3_ExactMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("Exact mismatches, inattention", size(medsmall)) xtitle("Youth's age", size(medlarge))						///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Y - C" "Y - T" "C - T", labsize(medlarge))) plotopts(msymbol(i)) 										///
		saving("${results}/FigureS2b_Inattention.gph", replace)															
*		legend(cols(1) rows(1) position(6) region(lstyle(none)) size(medlarge))												///

	graph export "${results}/FigureS2b_Inattention.png", as(jpg) name("Graph") quality(90) replace	
		
	mixed EMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==3
		quietly summ EMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS9_ResearchAim3_ExactMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("Exact mismatches, externalizing", size(medsmall)) xtitle("Youth's age", size(medlarge))						///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Y - C" "Y - T" "C - T", labsize(medlarge))) plotopts(msymbol(i)) 										///
		saving("${results}/FigureS2c_Externalizing.gph", replace)															

	graph export "${results}/FigureS2c_Externalizing.png", as(jpg) name("Graph") quality(90) replace	
			
		
	mixed EMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1
		quietly summ EMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS9_ResearchAim3_ExactMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("Exact mismatches, all domains", size(medsmall)) xtitle("Youth's age", size(medlarge))						///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Y - C" "Y - T" "C - T", labsize(medlarge))) plotopts(msymbol(i)) 										///
		saving("${results}/FigureS2d_ThreeDomains.gph", replace)															

	graph export "${results}/FigureS2d_ThreeDomains.png", as(jpg) name("Graph") quality(90) replace	
	
restore	

graph combine 	"${results}/FigureS2a_Internalizing.gph" "${results}/FigureS2b_Inattention.gph" 	///
				"${results}/FigureS2c_Externalizing.gph" "${results}/FigureS2d_ThreeDomains.gph", 	///
				cols(2) ycommon 															///
				note("Y: Youth, C: Caregiver, T: Teacher")									///
				saving("${results}/FigureS2.gph", replace)

				

***********************************************************************
********** (b) Presence vs absence mismatches
				
***************************	
***** AIM I 
		
***** Youth - Caregivers
	
** Diff in Sx, Youth - Caregivers, raw
	matrix TM_yc = ITMMp_yc\ATMMp_yc\ETMMp_yc
	matrix TMx_yc = TM_yc[1, 3] \ TM_yc[10, 3] \ TM_yc[17, 3]
	
***** Youth - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix TM_yt = ITMMp_yt\ATMMp_yt\ETMMp_yt
	matrix TMx_yt = TM_yt[1, 3] \ TM_yt[10, 3] \ TM_yt[17, 3]
	
***** Caregivers - Teachers
	
** Diff in Sx, Youth - Teachers, raw
	matrix TM_ct = ITMMp_ct\ATMMp_ct\ETMMp_ct
	matrix TMx_ct = TM_ct[1, 3] \ TM_ct[10, 3] \ TM_ct[17, 3]

***** Table S5 - Presence vs absence mismatches
	
	matrix TS5 = TMx_yc, TMx_yt, TMx_ct
	xml_tab TS5, save("$results\TableS10_PresenceAbsenceMismatches.xml") t(Sx Exact Mismatches) replace
				
	
***************************	
***** AIM II

** Covariates
global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"


foreach Y in tmm_yc_int_p tmm_yc_att_p tmm_yc_ext_p tmm_yt_int_p tmm_yt_att_p tmm_yt_ext_p tmm_ct_int_p tmm_ct_att_p tmm_ct_ext_p{
	matrix MM`Y' = J(18,5,.)
}

** Internalizing, inattention, and externalizing symptoms

	cap erase "${results}/TableS11_PredictorsPresenceAbsenceMismatches.xls"
	cap erase "${results}/TableS11_PredictorsPresenceAbsenceMismatches.txt"

foreach Y in tmm_yc_int_p tmm_yc_att_p tmm_yc_ext_p tmm_yt_int_p tmm_yt_att_p tmm_yt_ext_p tmm_ct_int_p tmm_ct_att_p tmm_ct_ext_p{
			 
	mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1
		
		local i = 1
		foreach X in $X1 $X2 $X3{	
			matrix MM`Y'[`i',1] = _b[`X']
			matrix MM`Y'[`i',2] = _se[`X']
			
		local i = `i'+1	
		}
		
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS11_PredictorsPresenceAbsenceMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}


***************************	
***** AIM III

** Internalizing
global TMM_I		"tmm_yc_int_p tmm_yt_int_p tmm_ct_int_p"

** Inattention
global TMM_A		"tmm_yc_att_p tmm_yt_att_p tmm_ct_att_p"

** Externalizing
global TMM_E		"tmm_yc_ext_p tmm_yt_ext_p tmm_ct_ext_p"


preserve

	* Internalizing, TMM
	local i = 1
	foreach V in $TMM_I {
		
		gen ITMM`i' = `V'
		
	local i = `i'+1	
	}

	* Attention, TMM
	local i = 1
	foreach V in $TMM_A {
		
		gen ATMM`i' = `V'
		
	local i = `i'+1	
	}

	* Externalizing, TMM
	local i = 1
	foreach V in $TMM_E {
		
		gen ETMM`i' = `V'
		
	local i = `i'+1	
	}
	
	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"	

	keep src_subject_id rsite_n site_id_l period rel_family_id1 site_cat ITMM1-ETMM3 $X1 $X2 $X3
	
	reshape long ITMM ATMM ETMM, i(src_subject_id period) j(reporters)
	
	rename ITMM TMM1
	rename ATMM TMM2
	rename ETMM TMM3
	
	reshape long TMM, i(src_subject_id period reporters) j(dimension)

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p"
	global X3 			"pwarmth_s school_positive_s family_conf_s neighborhood_s"
	
	
	cap erase "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.xls"
	cap erase "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.txt"
	
	mixed TMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==1
		quietly summ TMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("PvA mismatches, internalizing", size(medium)) xtitle("Youth's age", size(medlarge))		///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(cols(1) rows(1) ring(0) position(12) region(lstyle(none)) size(medlarge))									///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Y - C" "Y - T" "C - T", labsize(medsmall))) plotopts(msymbol(i)) 		///
		saving("${results}/FigureS3a_Internalizing.gph", replace)															

	graph export "${results}/FigureS3a_Internalizing.png", as(jpg) name("Graph") quality(90) replace	

	mixed TMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==2
		quietly summ TMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("PvA mismatches, inattention", size(medsmall)) xtitle("Youth's age", size(medlarge))			///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Youth-Caregiver" "Youth-Teacher" "Caregiver-Teacher", labsize(medlarge))) plotopts(msymbol(i)) 		///
		saving("${results}/FigureS3b_Inattention.gph", replace)															

	graph export "${results}/FigureS3b_Inattention.png", as(jpg) name("Graph") quality(90) replace	
		
	mixed TMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1 & dimension==3
		quietly summ TMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("PvA mismatches, externalizing", size(medsmall)) xtitle("Youth's age", size(medlarge))		///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Youth-Caregiver" "Youth-Teacher" "Caregiver-Teacher", labsize(medlarge))) plotopts(msymbol(i)) 		///
		saving("${results}/FigureS3c_Externalizing.gph", replace)															

	graph export "${results}/FigureS3c_Externalizing.png", as(jpg) name("Graph") quality(90) replace	
			
		
	mixed TMM i.reporters##c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y $X2 $X3 || site_cat: || rel_family_id1: if period!=1
		quietly summ TMM if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS12_ResearchAim3_PresenceAbsenceMismatches.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		margins, at(age_y=(9 10 11 12 13 14 15) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(age_y) graphregion(color(white)) recastci(rarea) 													///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25))			///
		ci3opts(lcolor(gs16) color(dkgreen%25)) 																			///
		ytitle("PvA mismatches, all domains", size(medsmall)) xtitle("Youth's age", size(medlarge))			///
		title("") xlabel(9 10 11 12 13 14 15, labsize(medlarge)) ylabel(0(.1).6)											///
		legend(off)																											///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick))		///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) 															///
		plot(, label("Youth-Caregiver" "Youth-Teacher" "Caregiver-Teacher", labsize(medlarge))) plotopts(msymbol(i)) 		///
		saving("${results}/FigureS3d_ThreeDomains.gph", replace)															

	graph export "${results}/FigureS3d_ThreeDomains.png", as(jpg) name("Graph") quality(90) replace	
	
	
restore	

graph combine 	"${results}/FigureS3a_Internalizing.gph" "${results}/FigureS3b_Inattention.gph" 	///
				"${results}/FigureS3c_Externalizing.gph" "${results}/FigureS3d_ThreeDomains.gph", 	///
				cols(2) ycommon 															///
				note("Y: Youth, C: Caregiver, T: Teacher, PvA: Presence vs. Absence")		///
				saving("${results}/FigureS3.gph", replace)



***********************************************************************
********** (c) Presence vs absence mismatches (only research aim 2)

**********************************************************
***** Absolute discrepancies

** Covariates
global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"


foreach Y in ad_yc_int ad_yc_att ad_yc_ext ad_yt_int ad_yt_att ad_yt_ext ad_ct_int ad_ct_att ad_ct_ext{
	matrix MM`Y' = J(18,5,.)
}

** Internalizing, inattention, and externalizing symptoms

	cap erase "${results}/TableS13_PredictorsAbsoluteDiscrepancies.xls"
	cap erase "${results}/TableS13_PredictorsAbsoluteDiscrepancies.txt"

foreach Y in ad_yc_int ad_yc_att ad_yc_ext ad_yt_int ad_yt_att ad_yt_ext ad_ct_int ad_ct_att ad_ct_ext{
			 
	mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1
		
		local i = 1
		foreach X in $X1 $X2 $X3{	
			matrix MM`Y'[`i',1] = _b[`X']
			matrix MM`Y'[`i',2] = _se[`X']
			
		local i = `i'+1	
		}
		
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS13_PredictorsAbsoluteDiscrepancies.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}



***********************************************************************************************
***********************************************************************************************
***** Supplemental Section (SS) 6: Multiple Imputation


***********************************************************************
********** (a1) Assessing missingness patterns

preserve
	drop if period==1
	
	* N_total analytic kids
    egen tag = tag(src_subject_id)
    summarize tag if tag
    scalar N_total = r(N)

    * Ns per wave (just for information in the table)
    egen tag_p2 = tag(src_subject_id) if period==2
    egen tag_p3 = tag(src_subject_id) if period==3
    egen tag_p4 = tag(src_subject_id) if period==4

    summarize tag_p2 if tag_p2
    scalar N_p2 = r(N)

    summarize tag_p3 if tag_p3
    scalar N_p3 = r(N)

    summarize tag_p4 if tag_p4
    scalar N_p4 = r(N)
	
	scalar N_cells_total = N_total * 3   // 3 follow-ups
	
	fillin src_subject_id period

    local yc_diff "rd_yc_int rd_yc_att rd_yc_ext"
    local yt_diff "rd_yt_int rd_yt_att rd_yt_ext"
    local ct_diff "rd_ct_int rd_ct_att rd_ct_ext"
    local all_diff "`yc_diff' `yt_diff' `ct_diff'"

    local base_covars ///
        age_y girl_y nonwhite_y puberty_sd_y immigrant_y ///
        age_p woman_p nonwhite_p immigrant_p depre_sd_p ///
        educ_lev_p1 educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5 ///
        pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd 

    local all_vars "`all_diff' `base_covars'"
	
	gen period2 = (period==2)	
	gen period3 = (period==3)
	gen period4 = (period==4)	
	gen all = 1
	
	matrix T = J(28,6,.)

	local p = 1
	foreach P in period2 period3 period4 all{
		local v = 1
		foreach V of varlist `all_vars' {
			sum `V' if `P'==1
				matrix T[`v',`p'] = r(N)
				matrix T[`v',5] = 11522
				matrix T[`v',6] = 34566
					
			local v = `v'+1
		}
	local p = `p'+1	
	}
	
	matrix list T
	mata:
		// Pull the Stata matrix "T" into Mata
		T = st_matrix("T")
		
		// Create new columns by dividing col 1 by col 2
		newcol1 = 1 :- (T[.,1] :/ T[.,5])
		newcol2 = 1 :- (T[.,2] :/ T[.,5])
		newcol3 = 1 :- (T[.,3] :/ T[.,5])
		newcol4 = 1 :- (T[.,4] :/ T[.,6])
		
		// Append the new column to the matrix
		T = T, newcol1, newcol2, newcol3, newcol4 
		
		// Send the updated matrix back to Stata (overwriting A or creating A_new)
		st_matrix("T", T)
	end

	matrix list T

restore

preserve
	svmat T
	
	keep if T2!=.
	keep T1 T2 T3 T4 T5 T6 T7 T8 T9 T10

    gen varname = ""
    local i = 1
    foreach V of local all_vars {
        replace varname = "`V'" in `i'
        local ++i
    }

    order varname

    rename T1 N_obs_p2
    rename T2 N_obs_p3
    rename T3 N_obs_p4
    rename T4 N_obs_total
    rename T5 N_total
    rename T6 N_cells_total
    rename T7 prop_missing_p2
    rename T8 prop_missing_p3
    rename T9 prop_missing_p4
    rename T10 prop_missing_overall

    * Add Ns per wave (same for all rows, but handy)
    gen N_p2 = N_p2   // scalar copied into a variable
    replace N_p2 = scalar(N_p2)

    gen N_p3 = N_p3
    replace N_p3 = scalar(N_p3)

    gen N_p4 = N_p4
    replace N_p4 = scalar(N_p4)


	export excel using "$results/TableS14_Missingness_by_Periods.xlsx", replace firstr(var)
restore



**************************************************************************
********** (a2) Missingness patterns

***** Analytic sample (kids with ≥1 wave 2–4)

preserve
    keep if inrange(period, 2, 4)
    egen tag = tag(src_subject_id)
    keep if tag
    keep src_subject_id
    tempfile analytic_ids
    save `analytic_ids', replace
restore


***** Baseline covariates for analytic IDs

preserve
    * restrict to baseline
    keep if period == 1

    * keep only analytic kids
	merge 1:1 src_subject_id using `analytic_ids'
	drop if _merge==1
	drop _merge

    keep src_subject_id ///
        age_y girl_y nonwhite_y puberty_sd_y immigrant_y ///
        age_p woman_p nonwhite_p immigrant_p depre_sd_p ///
        educ_lev_p1 educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5 ///
        pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd rsite_n

    tempfile base
    save `base', replace
restore

*****. Subject-level mean discrepancies (across periods 2–4)
preserve
    drop if period == 1
    keep if inrange(period, 2, 4)
	fillin src_subject_id period

    merge m:1 src_subject_id using `analytic_ids'
	tab _merge
	
    foreach v in rd_yc_int rd_yc_att rd_yc_ext ///
                rd_yt_int rd_yt_att rd_yt_ext ///
                rd_ct_int rd_ct_att rd_ct_ext {
					egen mean_`v' = mean(`v'), by(src_subject_id)
    }
	
	tab period

    keep src_subject_id period ///
        mean_rd_yc_int mean_rd_yc_att mean_rd_yc_ext ///
        mean_rd_yt_int mean_rd_yt_att mean_rd_yt_ext ///
        mean_rd_ct_int mean_rd_ct_att mean_rd_ct_ext

    bysort src_subject_id: keep if _n == 1
	count 
	
    tempfile means
    save `means', replace
restore

***** Subject-level missing-any flags for each dyad
preserve
    drop if period == 1

    * Fill panel to treat absent waves as missing
    fillin src_subject_id period

    foreach v in rd_yc_int rd_yc_att rd_yc_ext ///
                rd_yt_int rd_yt_att rd_yt_ext ///
                rd_ct_int rd_ct_att rd_ct_ext {
        gen miss_`v' = missing(`v')
    }
	
	sum miss_rd_yc_int miss_rd_yc_att miss_rd_yc_ext
	
    egen miss_any_yc_x = ///
        rowmax(miss_rd_yc_int miss_rd_yc_att miss_rd_yc_ext)
    egen miss_any_yt_x = ///
        rowmax(miss_rd_yt_int miss_rd_yt_att miss_rd_yt_ext)
    egen miss_any_ct_x = ///
        rowmax(miss_rd_ct_int miss_rd_ct_att miss_rd_ct_ext)
		
    egen miss_any_yc = ///
        mean(miss_any_yc_x), by(src_subject_id)
    egen miss_any_yt = ///
        mean(miss_any_yt_x), by(src_subject_id)
    egen miss_any_ct = ///
        mean(miss_any_ct_x), by(src_subject_id)
		
    keep src_subject_id miss_any_yc miss_any_yt miss_any_ct
    bysort src_subject_id: keep if _n == 1
	
	sum miss_any_yc miss_any_yt miss_any_ct
	sum miss_any_yc,d
	
    tempfile missflags
    save `missflags', replace
restore


***** Merge baseline covars + mean discrepancies + missing flags
preserve
	use `base', clear
	merge 1:1 src_subject_id using `missflags'
	drop _merge 
	merge 1:1 src_subject_id using `means'
	drop _merge
	
	
	*******************************************************
	*** Baseline covariates predicting missingness
	*******************************************************

	cap erase "${results}/TableS15_Missingness.xls"
	cap erase "${results}/TableS15_Missingness.txt"

	* Baseline predictors
	local X ///
		c.age_y girl_y nonwhite_y  ///
		c.age_p woman_p nonwhite_p ///
		educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5

	foreach pair in yc yt ct {
		regress miss_any_`pair' `X', vce(cluster rsite_n)
			summ  miss_any_`pair' if e(sample)==1
			local Ym = r(mean)
		outreg2 using "${results}/TableS15_Missingness.xls", ///
			addstat(YMean, `Ym') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) ///
			symbol(***,**,*,t) append
	}
		
restore 


**************************************************************************
********** (b) Multiple imputation for research aims I and II

preserve
	drop if period==1
		
	cap erase "${results}/TableS16_AimI_MI.xls"
	cap erase "${results}/TableS16_AimI_MI.txt"

	cap erase "${results}/TableS17_AimII_MI.xls"
	cap erase "${results}/TableS17_AimII_MI.txt"

	foreach IMPUTED in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {

	* 1. Declare MI structure
	mi set wide
		
	* 2. Register variables
	* Imputed: reporter scales + incomplete covariates
	mi register imputed ///
		`IMPUTED' ///
		age_y age_p depre_sd_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		woman_p nonwhite_p immigrant_p educ_lev_p 

	* Regular: IDs, time, clearly complete covariates
	mi register regular ///
		rsite_n site_cat rel_family_id1 period 
		

	* 4. Impute using chained equations
	mi impute chained ///
		(regress) `IMPUTED'  ///
				  age_y age_p depre_sd_p ///
				  pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		  girl_y nonwhite_y puberty_sd_y immigrant_y ///
		  woman_p nonwhite_p immigrant_p (ologit) educ_lev_p, ///
		add(10) rseed(12345)
		

	* List of ALL discrepancy variables used in Table 2
	local difflist ///
		`IMPUTED'

	* Store SDs in scalars sd_<var>
	foreach v of local difflist {
		quietly summarize `v' if period!=1
		scalar sd_`v' = r(sd)
	}
		
	***************************************************
	***** Research aim I: Mean-level discrepancies
	
		mi estimate, errorok noisily post: regress `IMPUTED' if period!=1 & rel_family_id1!=.
			matrix b = e(b)
			matrix V = e(V)
			
			local mean = b[1,1]
			scalar se   = sqrt(V[1,1])
			
			* Approximate p-value using MI df
			scalar df   = e(df_mi)[1,1]
			scalar tstat = `mean' / se
			local p    = 2*ttail(df, abs(tstat))
			
			* Standardized mean difference: divide by pre-computed SD
			scalar sd   = scalar(sd_`IMPUTED')
			local smd  = `mean' / sd	
		
		outreg2 using "${results}/TableS16_AimI_MI.xls", addstat(Mean, `mean', SMD, `smd', Pvalue, `p') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append


	***************************************************
	***** Research aim II: Predictors of discrepancies

	* Common predictor list (same for all 9 models)
	local preds ///
		c.age_y girl_y nonwhite_y puberty_sd_y immigrant_y ///          // youth
		age_p woman_p nonwhite_p immigrant_p depre_sd_p ///          // caregiver
		i.educ_lev_p ///                                              // caregiver education dummies
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd // social env.
		
	*	i.period                                                       // wave dummies

	* Outcomes in the order of Table 3 columns
	local outcomes `IMPUTED'

	* Clear any old stored estimates if you are using eststo/esttab
	capture which eststo
	if _rc==0 {
		eststo clear
	}

			
	local col = 1
	foreach yvar of local outcomes {
		
		di as txt "Running MI mixed model for column `col' (outcome: `yvar')"

		mi estimate, errorok post: ///
			mixed `yvar' `preds' ///
			|| site_cat: || rel_family_id1: if period != 1

			quietly summ `yvar' if period!=1 & rel_family_id1!=.
			local Ym = r(mean)
			quietly summ age_y if period!=1 & rel_family_id1!=.
			local Xm = r(mean)		
			local NF = e(N_g_mi)[1,2]
			outreg2 using "${results}/TableS17_AimII_MI.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
			
		* Store model for table export
		capture which eststo
		if _rc==0 {
			eststo m`col'
		}

		local ++col
	}

	* Unegister variables
	mi unregister ///
		`IMPUTED' ///
		age_y age_p depre_sd_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd

	* Regular: IDs, time, clearly complete covariates
	mi unregister ///
		src_subject_id rsite_n site_id_l site_cat rel_family_id1 period ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		woman_p nonwhite_p immigrant_p educ_lev_p

	mi unset
	*src_subject_id rsite_n site_id_l site_cat rel_family_id1 period 
	}
	
restore


***************************************************
***** Research aim III: Discrepancies over time

	** Internalizing
	global BPM_I		"bpm_y_int bpm_c_int bpm_t_int"

	** Inattention
	global BPM_A		"bpm_y_att bpm_c_att bpm_t_att"

	** Externalizing
	global BPM_E_YT 	"bpm_yt_ext bpm_ct_ext bpm_t_ext"
	global BPM_E_TC 	"bpm_yc_ext bpm_cy_ext bpm_t_ext"

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	global Xz 			"pcdep_z pwarm_z pschool_z famconf_z neighborh_z puberty_z "

preserve
	
	* 1. Generating/reformatting variables to set up data reshaping 

		gen I1 = bpm_y_int
		gen I2 = bpm_c_int
		gen I3 = bpm_t_int

		gen A1 = bpm_y_att
		gen A2 = bpm_c_att
		gen A3 = bpm_t_att

		gen E1 = bpm_yt_ext
		gen E2 = bpm_ct_ext
		gen E3 = bpm_t_ext

	* 2. (Optionally) drop extra stuff if you want to slim down
		keep src_subject_id rsite_n site_id_l period rel_family_id1 site_cat I1-E3 $X1 $X2 $X3 $Xz

	* 3. MI-safe reshape to long by reporter
		reshape long I A E, i(src_subject_id period) j(reporter)

	* 4. Turn I/A/E into S1–S3 and reshape to S
		rename I S1
		rename A S2
		rename E S3

		reshape long S, i(src_subject_id period reporter) j(dimension)

	* 5. Label reporter and dimension
		label define rep 1 "Youth" 2 "Caregiver" 3 "Teacher"
		label values reporter rep

		label define dim 1 "Internalizing" 2 "Inattention" 3 "Externalizing"
		label values dimension dim
	
	*tempfile dimension_db
	*save `dimension_db'

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"
	

	
***************************************************	
***** Conducting Multiple Imputation

	* 1. Declare MI structure
	mi set wide
		
	* 2. Register variables
	* Imputed: reporter scales + incomplete covariates
	mi register imputed ///
		S ///
		age_y age_p depre_sd_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		woman_p nonwhite_p immigrant_p educ_lev_p 

	* Regular: IDs, time, clearly complete covariates
	mi register regular ///
		rsite_n site_cat rel_family_id1 period 
		

	* 4. Impute using chained equations
	mi impute chained ///
		(regress) age_y age_p depre_sd_p ///
				  pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		  girl_y nonwhite_y puberty_sd_y immigrant_y ///
		  woman_p nonwhite_p immigrant_p (ologit) S educ_lev_p, ///
		add(10) rseed(12345)

		
***************************************************	
***** Interactions with age

cap erase "${results}/TableS18_AimIII_MI.xls"
cap erase "${results}/TableS18_AimIII_MI.txt"
	
	****************************************
	***** DIMENSION 1 = INTERNALIZING 
	
	* Fitting original model	
	mixed S i.reporter##c.age_y ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		|| site_cat: || rel_family_id1: ///
		if dimension==1 & period!=1			
		
	* Fit the same model, MI-pooled
	mi estimate, errorok post: mixed S i.reporter##c.age_y ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		|| site_cat: || rel_family_id1: ///
		if dimension==1 & period!=1

		summ S if dimension==1 & rel_family_id1!=.
		local Ym = r(mean)
		summ period if dimension==1 & rel_family_id1!=.
		local Xm = r(mean)
		local NF = e(N_g_mi)[1,2]
		outreg2 using "${results}/TableS18_AimIII_MI.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
	* Marginal predictions by reporter over age 9–15 (or use your observed range)
	mimrgns reporter, at(age_y = (9(1)15)) cmdmargins

	marginsplot, xdimension(age_y) ///
		graphregion(color(white)) recastci(rarea) ///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ///
		ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25)) ///
		ci3opts(lcolor(gs16) color(dkgreen%25)) ///
		ytitle("Internalizing symptoms", size(medlarge)) ///
		xtitle("Youth's age", size(medlarge)) ///
		title("") xlabel(9(1)15, labsize(medlarge)) ylabel(0(1)4) ///
		legend(cols(1) rows(1) ring(0) position(12) region(lstyle(none)) size(medlarge)) ///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) ///
		plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick)) ///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) ///
		plot(, label("Youth" "Caregiver" "Teacher" , labsize(medlarge))) ///
		plotopts(msymbol(i)) ///
		saving("${results}/FigureS4a_MI.gph", replace)
	
	
	****************************************
	***** DIMENSION 2 = INATTENTION
			
	* Fit the same model, MI-pooled
	mi estimate, errorok post: mixed S i.reporter##c.age_y ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		|| site_cat: || rel_family_id1: ///
		if dimension==2 & period!=1

		summ S if dimension==2 & rel_family_id1!=.
		local Ym = r(mean)
		summ period if dimension==2 & rel_family_id1!=.
		local Xm = r(mean)
		local NF = e(N_g_mi)[1,2]
		outreg2 using "${results}/TableS18_AimIII_MI.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
	* Marginal predictions by reporter over age 9–15 (or use your observed range)
	mimrgns reporter, at(age_y = (9(1)15)) cmdmargins

	marginsplot, xdimension(age_y) ///
		graphregion(color(white)) recastci(rarea) ///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ///
		ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25)) ///
		ci3opts(lcolor(gs16) color(dkgreen%25)) ///
		ytitle("Inattention symptoms", size(medlarge)) ///
		xtitle("Youth's age", size(medlarge)) ///
		title("") xlabel(9(1)15, labsize(medlarge)) ylabel(0(1)4) ///
		legend(off)	///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) ///
		plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick)) ///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) ///
		plot(, label("Youth" "Caregiver" "Teacher" , labsize(medlarge))) ///
		plotopts(msymbol(i)) ///
		saving("${results}/FigureS4b_MI.gph", replace)	
	
	****************************************
	***** DIMENSION 3 = EXTERNALIZING
			
	* Fit the same model, MI-pooled
	mi estimate, errorok post: mixed S i.reporter##c.age_y ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		|| site_cat: || rel_family_id1: ///
		if dimension==3 & period!=1

		summ S if dimension==3 & rel_family_id1!=.
		local Ym = r(mean)
		summ period if dimension==3 & rel_family_id1!=.
		local Xm = r(mean)
		local NF = e(N_g_mi)[1,2]
		outreg2 using "${results}/TableS18_AimIII_MI.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
	* Marginal predictions by reporter over age 9–15 (or use your observed range)
	mimrgns reporter, at(age_y = (9(1)15)) cmdmargins

	marginsplot, xdimension(age_y) ///
		graphregion(color(white)) recastci(rarea) ///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ///
		ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25)) ///
		ci3opts(lcolor(gs16) color(dkgreen%25)) ///
		ytitle("Externalizing symptoms", size(medlarge)) ///
		xtitle("Youth's age", size(medlarge)) ///
		title("") xlabel(9(1)15, labsize(medlarge)) ylabel(0(1)4) ///
		legend(off)	///		
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) ///
		plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick)) ///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) ///
		plot(, label("Youth" "Caregiver" "Teacher" , labsize(medlarge))) ///
		plotopts(msymbol(i)) ///
		saving("${results}/FigureS4c_MI.gph", replace)
		
		
	****************************************
	***** ALL DIMENSIONS TOGETHER
			
	* Fit the same model, MI-pooled
	mi estimate, errorok post: mixed S i.reporter##c.age_y ///
		girl_y nonwhite_y puberty_sd_y immigrant_y ///
		age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p ///
		pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd ///
		|| site_cat: || rel_family_id1: ///
		if period!=1

		summ S if rel_family_id1!=.
		local Ym = r(mean)
		summ period if rel_family_id1!=.
		local Xm = r(mean)
		local NF = e(N_g_mi)[1,2]
		outreg2 using "${results}/TableS18_AimIII_MI.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
	* Marginal predictions by reporter over age 9–15 (or use your observed range)
	mimrgns reporter, at(age_y = (9(1)15)) cmdmargins

	marginsplot, xdimension(age_y) ///
		graphregion(color(white)) recastci(rarea) ///
		ci1opts(lcolor(gs16) lpattern("#") color(navy%25)) ///
		ci2opts(lcolor(gs16) lpattern("#") color(cranberry%25)) ///
		ci3opts(lcolor(gs16) color(dkgreen%25)) ///
		ytitle("All domains", size(medlarge)) ///
		title("") xtitle("Youth's age", size(medlarge)) ///
		legend(off)	///
		xlabel(9(1)15, labsize(medlarge)) ylabel(0(1)4) ///
		plot1opts(lcolor(navy) lpattern("l") lwidth(thick)) ///
		plot2opts(lcolor(cranberry) lpattern("l") lwidth(thick)) ///
		plot3opts(lcolor(dkgreen%50) lpattern("-") lwidth(thick)) ///
		plot(, label("Youth" "Caregiver" "Teacher" , labsize(medlarge))) ///
		plotopts(msymbol(i)) ///
		saving("${results}/FigureS4d_MI.gph", replace)	
		
restore	
	
graph combine 	"${results}/FigureS4a_MI.gph" "${results}/FigureS4b_MI.gph" 	///
				"${results}/FigureS4c_MI.gph" "${results}/FigureS4d_MI.gph", 	///
				cols(2) ycommon saving("${results}/FigureS4.gph", replace)	


***********************************************************************************************
***********************************************************************************************
***** Supplemental Section (SS) 7: Correction for multiple testing
				
**********************************************************	
***** Table 2 - Multiple testing correction

** Benjamini–Hochberg correction

	local i = 1
	foreach M in ttxyc ttxyt ttxct{
	preserve
		svmat2 `M'
		rename `M'3 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		gsort pv_raw
		g rank = _n
		count
		local m = r(N)
		gen bh_critical = (rank / `m') *0.05

		gen is_significant = (pv_raw <= bh_critical)
		
		mkmat pv_raw rank bh_critical is_significant, matrix(BHC`i')
		
	local i = `i' + 1
	restore
	}

	matrix BHC = BHC1\BHC2\BHC3
	xml_tab BHC, save("$results\TableS19_T2_MeanDifferences_Benjamini–Hochberg-Correction.xml") t(BHC Table 2) replace		
	
** Bonferroni correction
	
	local i = 1
	foreach M in ttxyc ttxyt ttxct{
	preserve
		svmat2 `M'
		rename `M'3 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		count
		local m = r(N)
		g p_bonfc = pv_raw * `m'
		replace p_bonfc = 1 if p_bonfc > 1
		
		mkmat pv_raw p_bonfc, matrix(BON`i')
		
	local i = `i' + 1
	restore
	}

	matrix BON = BON1\BON2\BON3
	xml_tab BON, save("$results\TableS19_T2_MeanDifferences_Bonferroni-Correction.xml") t(BON Table 2) replace


**********************************************************	
***** Table 3 - Multiple testing correction

** Covariates
global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

* Matrices to capture results
foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
	matrix MM`Y' = J(18,5,.)
	matrix PV`Y' = J(18,1,.)
}

	cap erase "${results}/TableS20a_MultipleTestingCorrection.xls"
	cap erase "${results}/TableS20a_MultipleTestingCorrection.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
			 
	mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1
		
		local i = 1
		foreach X in $X1 $X2 $X3{	
			matrix MM`Y'[`i',1] = _b[`X']
			matrix MM`Y'[`i',2] = _se[`X']
			
			* Approximate p-value using MI df		
			local df   = e(N) - e(df_m)
			local tstat = _b[`X'] / _se[`X']
			local p    = 2*ttail(`df', abs(`tstat'))
			
			matrix PV`Y'[`i',1] = `p'
			
		local i = `i'+1	
		}
		
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS20a_MultipleTestingCorrection.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}

** Multiple testing correction

matrix PV = PVrd_yc_int, PVrd_yc_att, PVrd_yc_ext, PVrd_yt_int, PVrd_yt_att, PVrd_yt_ext, PVrd_ct_int, PVrd_ct_att, PVrd_ct_ext
matrix PVt = PV'
matrix PVt1 = PVt[1...,2]


** Benjamini–Hochberg correction
	
	local i = 1
	forvalues M = 1/18{
	preserve
		matrix MPV = PVt[1...,`M']
		svmat2 MPV
		rename MPV1 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		gsort pv_raw
		g rank = _n
		count
		local m = r(N)
		gen bh_critical = (rank / `m') *0.05

		gen is_sign = (pv_raw <= bh_critical)
		
		mkmat pv_raw rank bh_critical is_sign, matrix(BHC`M')
		
	local i = `M' + 1
	restore
	}

	matrix BHC = BHC1\BHC2\BHC3\BHC4\BHC5\BHC6\BHC7\BHC8\BHC9\BHC10\BHC11\BHC12\BHC13\BHC14\BHC15\BHC16\BHC17\BHC18
	xml_tab BHC, save("$results\TableS20b_T3_Benjamini–Hochberg-Correction.xml") t(BHC Table 2) replace	


** Bonferroni correction
	
	local i = 1
	forvalues M = 1/18{
	preserve
		matrix MPV = PVt[1...,`M']
		svmat2 MPV
		rename MPV1 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		count
		local m = r(N)
		g p_bonfc = pv_raw * `m'
		replace p_bonfc = 1 if p_bonfc > 1
		
		mkmat pv_raw p_bonfc, matrix(BON`i')
		
	local i = `i' + 1
	restore
	}

	matrix BON = BON1\BON2\BON3\BON4\BON5\BON6\BON7\BON8\BON9\BON10\BON11\BON12\BON13\BON14\BON15\BON16\BON17\BON18
	xml_tab BON, save("$results\TableS20b_T3_Bonferroni-Correction.xml") t(BON Table 2) replace


				
*****************************************************************************************************
*****************************************************************************************************
***** Supplemental Section (SS) 8: Alternative specifications for the predictors' model (aim II)
				

**********************************************************	
***** (a) Standardized effects in Table 3

local outcomes ///
    rd_yc_int rd_yc_att rd_yc_ext ///
	rd_yt_int rd_yt_att rd_yt_ext ///
	rd_ct_int rd_ct_att rd_ct_ext

* For each outcome, compute mean/SD in m = 0 and then create z-score
foreach v of local outcomes {

    * Get mean and SD from m=0 (original data) on the analysis sample
    quietly summarize `v' if period != 1
    
    scalar mu_`v' = r(mean)
    scalar sd_`v' = r(sd)
    
    * Create z-score in all imputations:
    generate z_`v' = (`v' - mu_`v') / sd_`v'
}

	cap erase "${results}/TableS21_T3_StandardizedEffects.xls"
	cap erase "${results}/TableS21_T3_StandardizedEffects.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
			 
	mixed z_`Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if wave1!=1	
		quietly summ z_`Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS21_T3_StandardizedEffects.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}
				
				
**********************************************************	
***** (b) Using time-varying covariates in Table 3

global Xz 			"pcdep_z pwarm_z pschool_z famconf_z neighborh_z puberty_z"

global X1z 			"age_y girl_y nonwhite_y puberty_z immigrant_y"
global X2z 			"age_prnt woman_p nonwhite_p immigrant_p iasr_depress educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
global X3z 			"ipwarm_z pschool_z famconf_z neighborhood_sd"

tabstat pcdep_z pwarm_z pschool_z famconf_z neighborh_z puberty_z, by(period)
tabstat $X1z $X2z $X3z, by(period)

	cap erase "${results}/TableS22_T3_TimeVarying.xls"
	cap erase "${results}/TableS22_T3_TimeVarying.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
			 
	mixed `Y' $X1z $X2z $X3z || site_cat: || rel_family_id1: if wave1!=1	
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS22_T3_TimeVarying.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}


***************************************************************
***** (c) Using pubertal reports from caregivers in Table 3
	
	sum puberty_y puberty_py puberty_sd_y puberty_sd_py 
	corr puberty_y puberty_py puberty_sd_y puberty_sd_py 
	
	** Covariates
	global X1p 			"age_y girl_y nonwhite_y puberty_sd_py immigrant_y"
	global X2p 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
	global X3p 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	cap erase "${results}/TableS23_T3_ParentalReportPubertalDev.xls"
	cap erase "${results}/TableS23_T3_ParentalReportPubertalDev.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
			 
	mixed `Y' $X1p $X2p $X3p || site_cat: || rel_family_id1: if wave1!=1	
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS23_T3_ParentalReportPubertalDev.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}

******************************************************************************
***** (d) Table 3 separately using the 1-, 2-, and 3-year follow-up data 

	** Covariates
	global X1 			"age_y girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	
	cap erase "${results}/TableS24_T3_1-y-follow-up.xls"
	cap erase "${results}/TableS24_T3_1-y-follow-up.txt"
	
	foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
				 
		mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if period==2
			quietly summ `Y' if e(sample)==1
			local Ym = r(mean)
			quietly summ age_y if e(sample)==1
			local Xm = r(mean)		
			local NF = e(N_g)[1,2]
			outreg2 using "${results}/TableS24_T3_1-y-follow-up.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
			
}

	cap erase "${results}/TableS25_T3_2-y-follow-up.xls"
	cap erase "${results}/TableS25_T3_2-y-follow-up.txt"
	
	foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
				 
		mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if period==3
			quietly summ `Y' if e(sample)==1
			local Ym = r(mean)
			quietly summ age_y if e(sample)==1
			local Xm = r(mean)		
			local NF = e(N_g)[1,2]
			outreg2 using "${results}/TableS25_T3_2-y-follow-up.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
			
}

	cap erase "${results}/TableS26_T3_3-y-follow-up.xls"
	cap erase "${results}/TableS26_T3_3-y-follow-up.txt"
	
	foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
				 
		mixed `Y' $X1 $X2 $X3 || site_cat: || rel_family_id1: if period==4
			quietly summ `Y' if e(sample)==1
			local Ym = r(mean)
			quietly summ age_y if e(sample)==1
			local Xm = r(mean)		
			local NF = e(N_g)[1,2]
			outreg2 using "${results}/TableS26_T3_3-y-follow-up.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
			
}


****************************************************************************************************
****************************************************************************************************
***** Supplemental Section (SS) 9: Alternative specification for the model estimating discrepancies 
*****								over time (aim III) - using periods instead of youth's age

********************************************************************************
*** Reshaping data at the dimension level

** Internalizing
global BPM_I		"bpm_y_int bpm_c_int bpm_t_int"

** Inattention
global BPM_A		"bpm_y_att bpm_c_att bpm_t_att"

** Externalizing
global BPM_E_YT 	"bpm_yt_ext bpm_ct_ext bpm_t_ext"
global BPM_E_TC 	"bpm_yc_ext bpm_cy_ext bpm_t_ext"


preserve

	* Internalizing
	local i = 1
	foreach V in $BPM_I {
		
		gen I`i' = `V'
		
	local i = `i'+1	
	}

	* Attention
	local i = 1
	foreach V in $BPM_A {
		
		gen A`i' = `V'
		
	local i = `i'+1	
	}

	* Externalizing
	local i = 1
	foreach V in $BPM_E_YT {
		
		gen E`i' = `V'
		
	local i = `i'+1	
	}
		
	** Covariates
	global X1 			"girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"	

	keep src_subject_id rsite_n site_id_l period rel_family_id1 site_cat I1-E3 $X1 $X2 $X3
	
	reshape long I A E, i(src_subject_id period) j(reporter)
	
	rename I S1
	rename A S2
	rename E S3
	
	reshape long S, i(src_subject_id period reporter) j(dimension)
	
	tempfile dimension_db
	save `dimension_db'

	** Covariates
	global X1 			"girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2 			"age_p woman_p nonwhite_p immigrant_p depre_sd_p i.educ_lev_p"
	global X3 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	
	************************************************************************************************************************
	
		cap erase "${results}/TableS27_ResearchAimIII.xls"
		cap erase "${results}/TableS27_ResearchAimIII.txt"
		
	***************************************	
	***** Differences by period	
		
	** Internalizing symptoms
	mixed S i.reporter##i.period $X1 $X2 $X3 || site_cat: || rel_family_id1: if dimension==1 & period!=1
		quietly summ S if e(sample)==1
		local Ym = r(mean)
		quietly summ period if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS27_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

		margins, at(period=(2 3 4) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(period) graphregion(color(white)) recast(scatter) recastci(rcap)									///
		ytitle("Internalizing symptoms", size(medlarge)) xtitle("Time point", size(medlarge))							///
		title("") xlabel(1.75 " " 2 "1-year" 3 "2-year" 4 "3-year" 4.25 " ", labsize(medlarge) noticks)					///
		xticks(2 3 4) ylabel(1(1)4)																						///
		legend(cols(1) rows(1) ring(0) position(12) region(lstyle(none)) size(medlarge))								///
		ci1opts(lcolor(navy%75)) ci2opts(lcolor(cranberry%75))	ci3opts(lcolor(dkgreen%25)) 							///
		plot1opts(mcolor(navy) msymbol(o)) plot2opts(mcolor(cranberry) msymbol(d)) 										///
		plot3opts(mcolor(dkgreen%50) msymbol(s)) plot(, label("Youth" "Caregiver" "Teacher", labsize(medlarge))) 		///
		plotopts(mfcolor(white) msize(small)) saving("${results}/FigureS5a.gph", replace)															

	graph export "${results}/FigureS5a.png", as(jpg) name("Graph") quality(90) replace


	** Inattention symptoms
	mixed S i.reporter##i.period $X1 $X2 $X3 || site_cat: || rel_family_id1: if dimension==2 & period!=1
		quietly summ S if e(sample)==1
		local Ym = r(mean)
		quietly summ period if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS27_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

		margins, at(period=(2 3 4) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(period) graphregion(color(white)) recast(scatter) recastci(rcap)									///
		ytitle("Inattention symptoms", size(medlarge)) xtitle("Time point", size(medlarge))								///
		title("") xlabel(1.75 " " 2 "1-year" 3 "2-year" 4 "3-year" 4.25 " ", labsize(medlarge) noticks)					///
		xticks(2 3 4) ylabel(1(1)4)																						///
		legend(off)																										///
		ci1opts(lcolor(navy%75)) ci2opts(lcolor(cranberry%75))	ci3opts(lcolor(dkgreen%25)) 							///
		plot1opts(mcolor(navy) msymbol(o)) plot2opts(mcolor(cranberry) msymbol(d)) 										///
		plot3opts(mcolor(dkgreen%50) msymbol(s)) plot(, label("Youth" "Caregiver" "Teacher", labsize(medlarge))) 		///
		plotopts(mfcolor(white) msize(small)) saving("${results}/FigureS5b.gph", replace)															

	graph export "${results}/FigureS5b.png", as(jpg) name("Graph") quality(90) replace																


	** Externalizing symptoms
	mixed S i.reporter##i.period $X1 $X2 $X3 || site_cat: || rel_family_id1: if dimension==3 & period!=1
		quietly summ S if e(sample)==1
		local Ym = r(mean)
		quietly summ period if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS27_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append

		margins, at(period=(2 3 4) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(period) graphregion(color(white)) recast(scatter) recastci(rcap)									///
		ytitle("Externalizing symptoms", size(medlarge)) xtitle("Time point", size(medlarge))							///
		title("") xlabel(1.75 " " 2 "1-year" 3 "2-year" 4 "3-year" 4.25 " ", labsize(medlarge) noticks)					///
		xticks(2 3 4) ylabel(1(1)4)																						///
		legend(off)																										///
		ci1opts(lcolor(navy%75)) ci2opts(lcolor(cranberry%75))	ci3opts(lcolor(dkgreen%25)) 							///
		plot1opts(mcolor(navy) msymbol(o)) plot2opts(mcolor(cranberry) msymbol(d)) 										///
		plot3opts(mcolor(dkgreen%50) msymbol(s)) plot(, label("Youth" "Caregiver" "Teacher", labsize(medlarge))) 		///
		plotopts(mfcolor(white) msize(small)) saving("${results}/FigureS5c.gph", replace)															

	graph export "${results}/FigureS5c.png", as(jpg) name("Graph") quality(90) replace																
		
		
	** All symptoms
	mixed S i.reporter##i.period $X1 $X2 $X3 || site_cat: || rel_family_id1: if period!=1
		quietly summ S if e(sample)==1
		local Ym = r(mean)
		quietly summ period if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableS27_ResearchAimIII.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
		margins, at(period=(2 3 4) 		///
		reporter=(1 2 3)) 
		
		marginsplot, x(period) graphregion(color(white)) recast(scatter) recastci(rcap)									///
		ytitle("All symptoms", size(medlarge)) xtitle("Time point", size(medlarge))										///
		title("") xlabel(1.75 " " 2 "1-year" 3 "2-year" 4 "3-year" 4.25 " ", labsize(medlarge) noticks)					///
		xticks(2 3 4) ylabel(1(1)4)																						///
		legend(off)																										///
		ci1opts(lcolor(navy%75)) ci2opts(lcolor(cranberry%75))	ci3opts(lcolor(dkgreen%25)) 							///
		plot1opts(mcolor(navy) msymbol(o)) plot2opts(mcolor(cranberry) msymbol(d)) 										///
		plot3opts(mcolor(dkgreen%50) msymbol(s)) plot(, label("Youth" "Caregiver" "Teacher", labsize(medlarge))) 		///
		plotopts(mfcolor(white) msize(small)) saving("${results}/FigureS5d.gph", replace)															

	graph export "${results}/FigureS5d.png", as(jpg) name("Graph") quality(90) replace	
	
restore

graph combine 	"${results}/FigureS5a.gph" "${results}/FigureS5b.gph" 	///
				"${results}/FigureS5c.gph" "${results}/FigureS5d.gph", 	///
				cols(2) ycommon saving("${results}/FigureS5.gph", replace)


				
				
				
********************************************************************************
********************************************************************************
********* ADDITIONAL EXERCISES IN THE RESPONSE TO REVIEWERS ONLY ***************
********************************************************************************
********************************************************************************

/*
	Additional materials to complement responses to reviewers:
	
	R1: Multiple test correction: Mean-level differences by symptoms
	R2: Teacher reports
	R3: Predictors of mean-level discrepancies, by reporters and domains (excluding immigrant covariates)
	R4: Analysis focused on changes in discrepancies (data on wide format) 
	R5: Predictors of changes in mean-level discrepancies (data on long format)

*/


********************************************************************************
********************************************************************************
***** Exercise R1: Multiple tests correction for mean differences by symptoms

** Benjamini–Hochberg correction
*
	matrix ttyc = Ittyc\Attyc\Ettyc
	matrix ttyt = Ittyt\Attyt\Ettyt
	matrix ttct = Ittct\Attct\Ettct
	
	local i = 1
	foreach M in ttyc ttyt ttct{
	preserve
		svmat2 `M'
		rename `M'3 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		gsort pv_raw
		g rank = _n
		count
		local m = r(N)
		gen bh_critical = (rank / `m') *0.05

		gen is_sign = (pv_raw <= bh_critical)
		
		mkmat pv_raw rank bh_critical is_sign, matrix(BHC`i')
		
	local i = `i' + 1
	restore
	}

	matrix BHC = BHC1\BHC2\BHC3
	xml_tab BHC, save("$results\TableR1_S5_T2_Benjamini–Hochberg-Correction.xml") t(BHC Table R1) replace	

** Bonferroni correction
	
	local i = 1
	foreach M in ttyc ttyt ttct{
	preserve
		svmat2 `M'
		rename `M'3 pv_raw
		keep if pv_raw !=. 
		keep pv_raw
		count
		local m = r(N)
		g p_bonfc = pv_raw * `m'
		replace p_bonfc = 1 if p_bonfc > 1
		
		mkmat pv_raw p_bonfc, matrix(BON`i')
		
	local i = `i' + 1
	restore
	}

	matrix BON = BON1\BON2\BON3
	xml_tab BON, save("$results\TableR1_S5_T2_Bonferroni-Correction.xml") t(BON Table R1) replace
	
				
				
********************************************************************************
********************************************************************************
***** Exercise R2: Teacher reports			
				
*******************************************************
* Teacher-report availability: 0, 1, 2, 3 waves per youth
* Assumes:
*   - long format with variable "period"
*   - teacher scale scores: bpm_t_int bpm_t_att bpm_t_ext
*   - child-level ID: replace "child_id" with your ID var
*******************************************************

preserve

	* Keep only follow-ups (teacher reports are 1-, 2-, 3-year follow-ups)
	keep if period != 1

	* Flag whether a teacher report is available in each wave
	* (any of the three teacher BPM scales present)
	egen teacher_nonmiss = rownonmiss(bpm_t_int bpm_t_att bpm_t_ext)
	gen  teacher_any     = teacher_nonmiss > 0

	* Count number of teacher-report waves per youth
	bysort src_subject_id: egen n_teacher_waves = total(teacher_any)

	* Reduce to one record per youth
	bysort src_subject_id: keep if _n == 1

	* Tabulate exact counts: 0, 1, 2, 3 teacher waves
	tab n_teacher_waves

	* Get counts and percentages
	contract n_teacher_waves
	gen pct = 100 * _freq / sum(_freq)
	sort n_teacher_waves
	list n_teacher_waves _freq pct, noobs

	* Also compute "at least 1 / 2 / 3 teacher reports" percentages
restore

preserve

	keep if period != 1
	tab period
	egen teacher_nonmiss = rownonmiss(bpm_t_int bpm_t_att bpm_t_ext)
	tab teacher_nonmiss
	gen  teacher_any     = teacher_nonmiss > 0
	ta teacher_any
	bysort src_subject_id: egen n_teacher_waves = total(teacher_any)
	bysort src_subject_id: keep if _n == 1

	gen at_least1 = n_teacher_waves >= 1
	gen at_least2 = n_teacher_waves >= 2
	gen all3      = n_teacher_waves >= 3
	
	tab n_teacher_waves
	tabulate n_teacher_waves, matcell(R2)
	xml_tab R2, save("$results\TableR2_TeacherReports.xml") t(Table R2, teacher reports) replace
	
	summarize at_least1 at_least2 all3
	tabstat at_least1 at_least2 all3, stats(N mean)

	display "Pct with ≥1 teacher report: "  100 * r(mean1)
	display "Pct with ≥2 teacher reports: " 100 * r(mean2)
	display "Pct with 3 teacher reports: "  100 * r(mean3)

restore

				
********************************************************************************
********************************************************************************
***** Exercise R3: Predictors of mean-level discrepancies, by reporters and 
*					domains (excluding immigrant covariates)

	** Covariates
	global X1i 			"age_y girl_y nonwhite_y puberty_sd_y"
	global X2i 			"age_p woman_p nonwhite_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
	global X3i 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	cap erase "${results}/TableR3_T3_NoImmigrantVars.xls"
	cap erase "${results}/TableR3_T3_NoImmigrantVars.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext {
			 
	mixed `Y' $X1i $X2i $X3i || site_cat: || rel_family_id1: if wave1!=1	
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableR3_T3_NoImmigrantVars.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}
								
							
********************************************************************************
********************************************************************************
***** Exercise R4: Predictors of changes in mean-level discrepancies 
*		(data on wide format) 

preserve

	* Reshaping the data

	global X1r 			"girl_y nonwhite_y puberty_sd_y immigrant_y"
	global X2r 			"woman_p nonwhite_p immigrant_p depre_sd_p educ_lev_p2 educ_lev_p3 educ_lev_p4 educ_lev_p5"
	global X3r 			"pwarmth_sd school_positive_sd family_conf_sd neighborhood_sd"

	replace age_y = . if period!=1
	egen age_yb = mean(age_y), by(src_subject_id)
	replace age_p = . if period!=1
	egen age_pb = mean(age_p), by(src_subject_id)
	replace site_cat = . if period!=1
	egen site_catb = mean(site_cat), by(src_subject_id)


	keep if inlist(period, 2, 4)
	keep rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext src_subject_id period site_catb rel_family_id1 age_yb age_pb $X1r $X2r $X3r
	reshape wide rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext, i(src_subject_id) j(period)

	foreach D in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
		gen d_`D' = `D'4 - `D'2
	}

		cap erase "${results}/TableR4_PredictorsOfChangeWide.xls"
		cap erase "${results}/TableR4_PredictorsOfChangeWide.txt"
		
		foreach Y in d_rd_yc_int d_rd_yc_att d_rd_yc_ext d_rd_yt_int d_rd_yt_att d_rd_yt_ext d_rd_ct_int d_rd_ct_att d_rd_ct_ext{
					 
			mixed `Y' age_yb $X1r age_pb $X2r $X3r || site_cat: || rel_family_id1: 
				quietly summ `Y' if e(sample)==1
				local Ym = r(mean)
				quietly summ age_yb if e(sample)==1
				local Xm = r(mean)		
				local NF = e(N_g)[1,2]
				outreg2 using "${results}/TableR4_PredictorsOfChangeWide.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
				
		}
				
restore	
				
				
********************************************************************************
********************************************************************************
***** Exercise R5: Predictors of changes in mean-level discrepancies 
*		(data on wide format) 				
				
	cap erase "${results}/TableR5_PredictorsOfChangeLong.xls"
	cap erase "${results}/TableR5_PredictorsOfChangeLong.txt"

foreach Y in rd_yc_int rd_yc_att rd_yc_ext rd_yt_int rd_yt_att rd_yt_ext rd_ct_int rd_ct_att rd_ct_ext{
			 
	mixed `Y' c.age_y##(i.girl_y i.nonwhite_y c.puberty_sd_y i.immigrant_y woman_p ///
						i.nonwhite_p i.immigrant_p c.depre_sd_p i.educ_lev_p2 i.educ_lev_p3 i.educ_lev_p4 i.educ_lev_p5 ///
						c.pwarmth_sd c.school_positive_sd c.family_conf_sd c.neighborhood_sd) ///
						|| site_cat: || rel_family_id1: if wave1!=1	
		quietly summ `Y' if e(sample)==1
		local Ym = r(mean)
		quietly summ age_y if e(sample)==1
		local Xm = r(mean)		
		local NF = e(N_g)[1,2]
		outreg2 using "${results}/TableR5_PredictorsOfChangeLong.xls", addstat(YMean, `Ym', XMean, `Xm', NFamilies, `NF') dec(3) label nocons alpha(0.001, 0.01, 0.05, 0.1) symbol(***,**,*,t) append
		
}
			
				
				
				
*****************************************************************************************************************************
*****************************************************************************************************************************
***************************************************** END *******************************************************************
*****************************************************************************************************************************
*****************************************************************************************************************************

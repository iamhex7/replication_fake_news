cls
clear all
set more off

import delimited `"data/replication_data.csv"', clear

** delete unused and duplicated vars
rename participant* *
drop playerpayoff
rename player* *
rename _* *

drop label is_bot max_page_index current_app_name visited id_in_group previous_your_answer ///
num_before_score earnings given_to_dem given_to_gop donate_to_dem donate_to_gop groupid_in_subsession ///
win_bonus sessionlabel sessionexperimenter_name sessionmturk_hitid sessionmturk_hitgroupid ///
sessioncomment sessionis_demo

duplicates drop

drop if current_page != "Results" | index_in_pages != 183
rename subsessionround_number round_number

replace avg_score_to_compare = . if round_number != 13 // the round relative performance is calculated

** five people started the study twice; their second observations are deleted
drop if code == "dts2kfmy" | code == "2f0bv9gg" | code == "a39fobsy" | code == "yfitbvty" | code == "6khpcatr"

replace dem_news = 0 if dem_news == .
replace rep_news = 0 if rep_news == .

**** Demographic dummies ****

gen democrat_temp = (party == "Democrat")
gen republican_temp = (party == "Republican")
gen independent_temp = (party == "Independent")
bysort code: egen democrat = max(democrat_temp)
bysort code: egen republican = max(republican_temp)
bysort code: egen independent = max(independent_temp)

rename ideology ideology_temp
gen ideology_n_temp = .
replace ideology_n_temp = -3 if ideology_temp == "Extremely liberal"
replace ideology_n_temp = -2 if ideology_temp == "Liberal"
replace ideology_n_temp = -1 if ideology_temp == "Slightly liberal"
replace ideology_n_temp = 0 if ideology_temp == "Moderate"
replace ideology_n_temp = 1 if ideology_temp == "Slightly conservative"
replace ideology_n_temp = 2 if ideology_temp == "Conservative"
replace ideology_n_temp = 3 if ideology_temp == "Extremely conservative"
bysort code: egen ideology = max(ideology_n_temp)

rename opinion_* opinion_*_temp
bysort code: egen opinion_trump = max(opinion_trump_temp)
bysort code: egen opinion1 = max(opinion_climate_temp)
bysort code: egen opinion4 = max(opinion_gun_laws_temp)
bysort code: egen opinion3 = max(opinion_obama_crime_temp)
bysort code: egen opinion5 = max(opinion_gender_temp)
bysort code: egen opinion7 = max(opinion_mobility_temp)
bysort code: egen opinion6 = max(opinion_race_temp)
bysort code: egen opinion2 = max(opinion_refugees_temp)
bysort code: egen opinion8 = max(opinion_media_temp)

gen female_temp = (gender == "Female")
gen male_temp = (gender == "Male")
bysort code: egen female = max(female_temp)
bysort code: egen male = max(male_temp)

gen white_temp = (race == "White")
gen black_temp = (race == "Black or African American")
gen asian_temp = (race == "Asian")
gen latino_temp = (race == "Hispanic or Latino")
bysort code: egen white = max(white_temp)
bysort code: egen black = max(black_temp)
bysort code: egen asian = max(asian_temp)
bysort code: egen latino = max(latino_temp)
gen other_race = 1 - white - black - asian - latino

rename age age_temp
bysort code: egen age = max(age_temp)
gen age_low = (age < 40)
gen age_mid = (age >= 40 & age < 60)
gen age_high = (age >= 60)

gen religious_group_temp = 0
replace religious_group_temp = 1 if religion != "" & religion != "Unaffiliated" & religion != "Agnostic" & religion != "Atheist"
bysort code: egen religious_group = max(religious_group_temp)

gen edu_temp = .
replace edu_temp = 11 if education == "Did not graduate high school"
replace edu_temp = 12 if education == "High school graduate or GED"
replace edu_temp = 13 if education == "Began college, no degree"
replace edu_temp = 14 if education == "Associate's degree"
replace edu_temp = 16 if education == "Bachelor's degree"
replace edu_temp = 18 if education == "Postgraduate or professional degree"
bysort code: egen edu = max(edu_temp)
drop education

gen inc_temp = .
replace inc_temp = 10000 if income == "Less than $20,000"
replace inc_temp = 25000 if income == "$20,000 to $29,999"
replace inc_temp = 35000 if income == "$30,000 to $39,999"
replace inc_temp = 45000 if income == "$40,000 to $49,999"
replace inc_temp = 60000 if income == "$50,000 to $69,999"
replace inc_temp = 85000 if income == "$70,000 to $99,999"
replace inc_temp = 125000 if income == "$100,000 to $149,999"
replace inc_temp = 200000 if income == "$150,000 or more"

bysort code: egen inc = max(inc_temp)
drop income
gen log_inc = log(inc)

** red_state: won by Trump in 2016
gen red_state_temp = (region == "Alabama" | region == "Alaska" | region == "Arizona" | region == "Arkansas" | ///
region == "Florida" | region == "Georgia" | region == "Idaho" | region == "Indiana" | ///
region == "Iowa" | region == "Kansas" | region == "Kentucky" | region == "Louisiana" | ///
region == "Michigan" | region == "Mississippi" | region == "Missouri" | region == "Montana" | ///
region == "Nebraska" | region == "North Carolina" | region == "North Dakota" | region == "Ohio" | ///
region == "Oklahoma" | region == "Pennsylvania" | region == "South Carolina" | region == "South Dakota" ///
| region == "Tennessee" | region == "Texas" | region == "Utah" | region == "West Virginia" ///
| region == "Wisconsin" | region == "Wyoming")
bysort code: egen red_state = max(red_state_temp)

bysort code: egen avg_guess_points = mean(guess_points)
bysort code: egen avg_lower_bound_points = mean(lower_bound_points)
bysort code: egen avg_upper_bound_points = mean(upper_bound_points)

replace news_points = (news_points + wtp_points) if wtp_points != .
bysort code: egen avg_news_points = mean(news_points)
replace reguess_points = 100 if substr(treatment, 1, 1) == "S" & reguess_points == .
bysort code: egen avg_reguess_points = mean(reguess_points)

/* Treatments: 
	S = second-guess treatment (all subjects)
	Y = given prior of P(True) = 0.5 (all subjects)
	A = subjects who never receive treatment
	M = subjects who receive treatment starting in round 4
	untreated = subjects who have not received treatment: this is the replication group
*/
gen treatment_s = (substr(treatment, 1, 1) == "S")
gen treatment_y = (substr(treatment, 2, 1) == "Y")
gen treatment_m = (substr(treatment, 3, 1) == "M")
gen treatment_a = (substr(treatment, 3, 1) == "A")

gen untreated = (round_number < 4 | treatment_a)

replace prob_true = prob_true / 10

********** TOPICS **********

gen issue_id = topic_id
replace issue_id = 2 if topic_id == 16
replace issue_id = 3 if topic_id == 17
replace issue_id = 4 if topic_id == 18
replace issue_id = 5 if topic_id == 19
replace issue_id = 6 if topic_id == 20
replace issue_id = 10 if topic_id == 21
replace issue_id = 14 if topic_id == 15

/* 	
	issue_id		Topic						Category			Rounds
	1				Global Warming				Politicized			1-12
	2				Refugees and Crime			Politicized			1-12
	3				Crime Under Obama			Politicized			1-12
	4				Gun Laws					Politicized			1-12
	5				Racial Discrimination		Politicized			1-12
	6				Gender and Math Grades		Politicized			1-12
	7				Upward Mobility				Politicized			1-12
	8				Media Bias					Politicized			1-12
	9				Cancer in Children			Non-political		1-12
	10				Wage Growth					Politicized			1-12
	11				Healthcare					Politicized			1-12
	12				Current Year				Attention Check		2-12
	13				Your Score					Ego					13
	14				Reps' / Dems' Score			Politicized			14
*/

disp "N (total)"
count if round_number == 1

gen true_news = (veracity == "True")
gen fake_news = (veracity == "Fake")
gen message_greater = (message == "greater than")
gen message_less = (message == "less than")

gen politicized_news = (issue_id <= 8 | issue_id == 10 | issue_id == 11 | issue_id == 14)
gen ego_news = (topic_id == 13)

rename gop_thermometer rep_thermometer
replace rep_thermometer = rep_thermometer / 100
replace dem_thermometer = dem_thermometer / 100

gen net_party_temp = rep_thermometer - dem_thermometer
bysort code: egen net_party = max(net_party_temp)

gen pro_rep = (net_party > 0)
gen pro_dem = (net_party < 0)
gen good_news = (net_party < 0 & dem_news) | (net_party > 0 & rep_news) | (message_greater & topic_id == 13)
gen bad_news = (net_party > 0 & dem_news) | (net_party < 0 & rep_news) | (message_less & topic_id == 13)

gen abs_net_party = abs(net_party)
gen partisan = (abs_net_party >= .5)
gen moderate = (abs_net_party < .5)
gen partisan_rep = (net_party >= .5)
gen partisan_dem = (net_party <= -.5)
gen moderate_rep = (net_party > 0 & net_party < .5)
gen moderate_dem = (net_party < 0 & net_party > -.5)

gen good_news_strength = good_news * abs_net_party

gen net_good_news = good_news - bad_news
bysort code (round_number): gen count_prev_net = sum(net_good_news)
replace count_prev_net = count_prev_net - net_good_news
sort code round_number

gen politicized_true = (true_news & politicized_news)


forval i = 1/15 {
	gen topic`i'_dummy = (topic_id == `i')
	if `i' <= 14 {
		gen round`i'_dummy = (round_number == `i')
	}
}
gen topic1415_dummy = (topic_id == 14 | topic_id == 15)

forval i = 1/15 {
	gen good_topic`i' = topic`i'_dummy * good_news
}
gen good_topic1415 = topic1415_dummy * good_news

forval i = 1/15 {
	gen rep_topic`i' = topic`i'_dummy * rep_news
	gen dem_topic`i' = topic`i'_dummy * dem_news
}

forval i = 1/15 {
	gen rep_good_topic`i' = good_topic`i' * rep_news
	gen dem_good_topic`i' = good_topic`i' * dem_news
}
gen rep_good_topic1415 = good_topic1415 * rep_news
gen dem_good_topic1415 = good_topic1415 * dem_news

forval i = 1/15 {
	gen rep_high_topic`i' = 0
	replace rep_high_topic`i' = 1 if topic`i'_dummy & ((message_greater & pro_rep) | (message_less & pro_dem))
}

forval i = 1/14 {
	gen good_round`i' = round`i'_dummy * good_news
}

gen your_answer_in_bounds = 1/2 + ((your_upper_bound - your_answer) - (your_answer - your_lower_bound)) / (2 * (your_upper_bound - your_lower_bound)) if your_upper_bound > your_lower_bound
gen unskewed_prior = ((your_upper_bound - your_answer) == (your_answer - your_lower_bound)) if your_upper_bound > your_lower_bound

gen change_guess_message = .
replace change_guess_message = 1 if (your_answer < your_reguess & message_greater & ///
your_answer != . & your_reguess != .) | (your_answer > your_reguess & ///
message_less & your_answer != . & your_reguess != .)
replace change_guess_message = 0 if (your_answer == your_reguess & message_greater & ///
your_answer != . & your_reguess != .) | (your_answer == your_reguess & ///
message_less & your_answer != . & your_reguess != .)
replace change_guess_message = -1 if (your_answer > your_reguess & message_greater & ///
your_answer != . & your_reguess != .) | (your_answer < your_reguess & ///
message_less & your_answer != . & your_reguess != .)

gen performance = solution if topic_id == 13
gen confidence = your_answer if topic_id == 13
gen overconfidence = confidence - performance
bysort code: egen overconfidence_all = max(overconfidence)

gen logit_prob = log(prob_true) - log(1-prob_true) if prob_true > 0 & prob_true < 1 ///
& (message_greater | message_less)
replace logit_prob = log(.05) - log(.95) if prob_true == 0 & (message_greater | message_less)
replace logit_prob = log(.95) - log(.05) if prob_true == 1 & (message_greater | message_less)

bysort code: egen mean_prob = mean(prob_true) if message_greater + message_less == 1
bysort code: egen mean_logit_prob = mean(logit_prob) if message_greater + message_less == 1

gen your_range = your_upper_bound - your_lower_bound
winsor2 your_range, cuts (5 95) by(topic_id)

gen overprecision = .
replace overprecision = 1/2 if solution < your_lower_bound | solution > your_upper_bound
replace overprecision = -1/2 if solution >= your_lower_bound & solution <= your_upper_bound
gen overprecise = overprecision + 1/2
gen underprecise = 1-overprecise

gen pro_party = good_news & politicized_news
gen anti_party = bad_news & politicized_news
gen pro_performance = good_news & ego_news
gen anti_performance = bad_news & ego_news

gen pro_party_str = pro_party * abs_net_party

bysort code: egen prob_true_mean = mean(prob_true) if message_greater + message_less & politicized_news
gen prob_true_demeaned = prob_true - prob_true_mean

bysort topic_id: egen mean_answer = mean(your_answer)
gen polarizing = (your_answer > mean_answer & message_greater) | (your_answer < mean_answer & message_less)

** z scores for variables
winsor2 your_answer, cuts(5 95) by(topic_id)

bysort topic_id: egen guess_mean = mean(your_answer_w)
bysort topic_id: egen guess_sd = sd(your_answer_w)
bysort topic_id: gen guess_z = (your_answer_w - guess_mean) / guess_sd
gen guess_z_party = guess_z if direction == "R"
replace guess_z_party = -guess_z if direction == "L"
gen rep_high = (direction == "R")
gen dem_high = (direction == "L")


bysort code: egen mean_guess_z_party = mean(guess_z_party)

bysort code: egen mean_prob_rep_temp = mean(prob_true) if rep_news
bysort code: egen mean_prob_rep = max(mean_prob_rep_temp)
bysort code: egen mean_prob_dem_temp = mean(prob_true) if dem_news
bysort code: egen mean_prob_dem = max(mean_prob_dem_temp)
gen mean_prob_net = mean_prob_rep - mean_prob_dem

egen mean_prob_net_mean = mean(mean_prob_net)
egen mean_prob_net_sd = sd(mean_prob_net)
gen mean_prob_net_z = (mean_prob_net - mean_prob_net_mean) / mean_prob_net_sd

												   
** failed_check if subjects do not score perfectly on the attention check question
gen failed_check_temp = (guess_points + news_points < 200 & topic_id == 12)
bysort code: egen failed_check_new = max(failed_check_temp)

** out_of_range if subjects give answers that are out of a reasonable range
gen out_of_range_q = 0
replace out_of_range_q = 1 if (your_lower < 0 | your_reguess < 0) & topic_id != 10
replace out_of_range_q = 1 if topic_id == 1 & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 2 | topic_id == 16) & (your_upper > 1000000 | (your_reguess > 1000000 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 3 | topic_id == 17) & (your_upper > 100000 | (your_reguess > 100000 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 5 | topic_id == 19) & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 6 | topic_id == 20) & (your_upper > 4 | (your_reguess > 4 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 7) & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 8 & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 9 & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 11 & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 12 & (your_upper != 2019 | your_lower != 2019 | (your_reguess != 2019 & your_reguess != .))
replace out_of_range_q = 1 if topic_id == 13 & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
replace out_of_range_q = 1 if (topic_id == 14 | topic_id == 15) & (your_upper > 100 | (your_reguess > 100 & your_reguess != .))
bysort code: egen out_of_range = sum(out_of_range_q)

** drop subjects who fail checks
drop if failed_check_new | out_of_range != 0 

disp "N (passed attention check)"
count if round_number == 1

keep if untreated // drop all treated subjects


export delimited "data/cleaned_replication_data.csv", replace

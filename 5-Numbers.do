cls
clear all
set more off

import delimited "data/cleaned_data.csv", clear

***********************
*** Numbers in Text ***
***********************

*** Section 3.4: Experiment Details ***

preserve
import delimited "data/cleaned_data_withfailedcheck.csv", clear
count if round_number == 1  // # subjects including those who don't pass checks
restore

count if round_number == 1  // # subjects who pass checks
tab pro_dem pro_rep if round_number == 1  // subjects by party

// note that we ignore the comprehension check below (when topic_id == 12)
count if pro_dem + pro_rep == 1 & topic_id != 12  // # questions for non-neutrals
count if message_greater + message_less == 1 & pro_dem + pro_rep == 1 ///
& topic_id != 12  // # news assessments for non-neutrals
count if guess_points == 100 & pro_dem + pro_rep == 1 & topic_id != 12  // # correct guesses
count if message_greater + message_less == 1 & pro_dem + pro_rep == 1 ///
& politicized_news == 1  // # news assessments for politicized topics
count if message_greater + message_less == 1 & pro_dem + pro_rep == 1 ///
& ego_news == 1  // # news assessments for performance topic
count if message_greater + message_less == 1 & pro_dem + pro_rep == 1 ///
& neutral_news == 1  // # news assessments for neutral topics


*** Appendix Table 4: Prior beliefs ***
* Displays the values used in Appendix Table 4 (but not the formatting)

/* 	
Politicized topics:
	Topic_id		Topic						Category			Rounds
	1				Global Warming				Politicized			1-12
	2				Refugees and Crime			Politicized			1-12
	3				Crime Under Obama			Politicized			1-12
	4				Gun Laws					Politicized			1-12
	5				Racial Discrimination		Politicized			1-12
	6				Gender and Math Grades		Politicized			1-12
	7				Upward Mobility				Politicized			1-12
	8				Media Bias					Politicized			1-12
	14				Republicans' Score			Politicized			14
	15				Democrats' Score			Politicized			14
*/

* Average guesses: Pro-Rep
reg your_answer_w ibn.topic_id if pro_rep == 1 & topic_id != 12, cluster(code) noconst

* Average guesses: Pro-Dem
reg your_answer_w ibn.topic_id if pro_dem == 1 & topic_id != 12, cluster(code) noconst

* Differences between parties
reg your_answer_w ibn.topic_id#1.pro_rep ibn.topic_id if pro_rep + pro_dem == 1 & topic_id != 12, cluster(code) noconst

* Solutions
reg solution ibn.topic_id if dem_news + rep_news == 1, noconst

* Counts
count if pro_rep == 1 & (topic_id <= 8 | topic_id == 14 | topic_id == 15)
count if pro_dem == 1 & (topic_id <= 8 | topic_id == 14 | topic_id == 15)


*** Appendix Table 5: Balance table ***
* Displays the values used in Appendix Table 5 (but not the formatting)
foreach demo in abs_net_party net_party male age edu log_inc white black latino ///
religious_group red_state treatment_p treatment_y {
	mean `demo' if anti_party
	mean `demo' if pro_party
	reg `demo' anti_party if pro_party + anti_party
}


*** Raw Data: Section 4.1 ***

* Average assessment by condition
mean prob_true if pro_party, cluster(code)
mean prob_true if neutral_news & net_party != 0 & message_greater + message_less, cluster(code)
mean prob_true if anti_party, cluster(code)

* Differences between pro_party and anti_party assessments,
* and diff between each and neutral
reg prob_true pro_party if pro_party + anti_party == 1, cluster(code)
reg prob_true pro_party if pro_party | (neutral_news & message_greater + message_less), cluster(code)
reg prob_true anti_party if anti_party | (neutral_news & message_greater + message_less), cluster(code)

* Differences between True News and Fake News assessments
reg prob_true true_news if politicized_news == 1, cluster(code)


*** Section 4.4: Robustness ***

* Section 4.4.1: Share of subjects with unskewed priors
mean unskewed_prior if topic_id != 12  

* Section 4.4.4: Scores by round
mean news_points if round_number == 1 & net_party != 0 & message_greater + message_less == 1
mean news_points if round_number != 1 & round_number <= 12 & net_party != 0 & message_greater + message_less == 1

reg news_points 1.round_number if round_number <= 12 & net_party != 0 & message_greater + message_less == 1, cluster(code)

mean guess_points if round_number == 1 & net_party != 0 & topic_id != 12
mean guess_points if round_number != 1 & round_number <= 12 & net_party != 0 & topic_id != 12

reg guess_points 1.round_number if round_number <= 12 & net_party != 0 & topic_id != 12

mean news_points if round_number != 1 & round_number <= 12 & net_party != 0 & message_greater + message_less == 1

*** Section 4.6: R-squared ***
reg mean_guess_z_party age male white edu log_inc religious_group red_state if politicized_news == 1, cluster(code)
reg mean_guess_z_party mean_prob_net_z if politicized_news == 1, cluster(code)

*** Section 4.6: Overprecision ***
* note: overprecise = 1 if conf interval doesn't contain answer and 0 if it does. underprecise = 1-overprecise

mean underprecise if politicized_news == 1, cluster(code)
ttest underprecise = 0.5 if politicized_news == 1

mean underprecise if politicized_news == 1 & partisan == 1, cluster(code)
ttest underprecise = 0.5 if politicized_news == 1 & partisan == 1

mean underprecise if politicized_news == 1 & moderate == 1, cluster(code)

mean underprecise if ego_news == 1, cluster(code)
ttest underprecise = 0.5 if ego_news == 1

mean underprecise if topic_id == 9, cluster(code) // random number topic

reg prob_true overprecise if true_news == 0 & politicized_news, cluster(code)
reg prob_true overprecise if true_news == 1 & politicized_news, cluster(code)

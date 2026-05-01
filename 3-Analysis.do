cls
clear all
set more off

import delimited "data/cleaned_data.csv"

*****************************
********** FIGURES **********
*****************************

*** Figure 1: CDF of Good News / Bad News ***
* Make cdfplot of assessments (prob_true) when news is "good/bad" and politicized
cdfplot prob_true if good_news+bad_news & pro_party+anti_party, by(good_news) ///
	opt1( lc(purple green) ) opt2( lp(dot dot) ) graphregion(fcolor(white)) ///
	legend(order(2 "Pro-Party News" 1 "Anti-Party News" )) xtitle("Belief About P(True News)") ytitle("Share of responses")

graph export "figures/figure1.png", replace


*** Figure 2: Motivated reasoning by partisanship ***
/* Make bar graph of mean assessments (prob_true) by condition/partisanship:
	1. anti_party among partisans
	2. anti_party among moderates
	3. neutral topics
	4. pro_party among moderates
	5. pro_party among partisans
*/

preserve

keep if net_party != 0 & pro_party + neutral_news + anti_party & message_greater + message_less

gen party_group = .
replace party_group = 1 if anti_party & partisan 
replace party_group = 2 if anti_party & moderate 
replace party_group = 3 if neutral_news
replace party_group = 4 if pro_party & moderate
replace party_group = 5 if pro_party & partisan

collapse (mean) pt_mean = prob_true_demeaned (sd) pt_sd = prob_true_demeaned (count) pt_n = prob_true_demeaned, by(party_group)

gen hi = pt_mean + invttail(pt_n-1,0.025)*(pt_sd / sqrt(pt_n))
gen low = pt_mean - invttail(pt_n-1,0.025)*(pt_sd / sqrt(pt_n))

gen plot_axis = .
replace plot_axis = 1 if party_group == 1
replace plot_axis = 2 if party_group == 2
replace plot_axis = 3 if party_group == 3
replace plot_axis = 4 if party_group == 4
replace plot_axis = 5 if party_group == 5

graph twoway ///
	(bar pt_mean plot_axis if plot_axis == 1, color("80 20 80") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 2, color("140 80 140") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 3, color("120 120 120") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 4, color("60 140 80") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 5, color("0 80 20") barwidth(.75)) ///
	(rcap hi low plot_axis, lcolor(black)), ///
	graphregion(fcolor(white)) ///
	xlabel(1 `" "Anti-Party," "Partisans" " " "n = 2,026" "' 2 `" "Anti-Party," "Moderates" " " "n = 1,935" "' ///
	3 `" "Neutral," "All Subjects" " " "n = 2,650" "' 4 ///
	`" "Pro-Party," "Moderates" " " "n = 1,945" "' 5 `" "Pro-Party," "Partisans" " " "n = 1,996" "', labsize(small)) ///
 	yscale(r(-.1 .1)) ///
	ylabel(-.1 (.05) .1) ///
 	xtitle("") ///
	ytitle("P(True), Demeaned") ///
 	legend(off)
	
	graph export "figures/figure2.png", replace
	
restore


*** Figure 3: Motivated reasoning by news veracity ***
/* Make bar graph of mean assessments (prob_true) by condition:
	1. anti_party and fake_news
	2. anti_party and true_news
	3. neutral topics and fake_news
	4. neutral topics and true_news
	4. pro_party and fake_news
	5. pro_party and true_news
*/
mean prob_true_demeaned if anti_party & fake_news & net_party != 0, cluster(code)
mean prob_true_demeaned if anti_party & true_news & net_party != 0, cluster(code)
mean prob_true_demeaned if neutral_news & fake_news & net_party != 0, cluster(code)
mean prob_true_demeaned if neutral_news & true_news & net_party != 0, cluster(code)
mean prob_true_demeaned if pro_party & fake_news & net_party != 0, cluster(code)
mean prob_true_demeaned if pro_party & true_news & net_party != 0, cluster(code)

preserve

drop if ego_news | net_party == 0 | message_greater + message_less == 0

gen party_group = .
replace party_group = 1 if anti_party & fake_news
replace party_group = 2 if anti_party & true_news
replace party_group = 3 if neutral_news & fake_news
replace party_group = 4 if neutral_news & true_news
replace party_group = 5 if pro_party & fake_news
replace party_group = 6 if pro_party & true_news

collapse (mean) pt_mean = prob_true_demeaned (sd) pt_sd = prob_true_demeaned (count) pt_n = prob_true_demeaned, by(party_group)

gen hi = pt_mean + invttail(pt_n-1,0.025)*(pt_sd / sqrt(pt_n))
gen low = pt_mean - invttail(pt_n-1,0.025)*(pt_sd / sqrt(pt_n))

gen plot_axis = .
replace plot_axis = 1 if party_group == 1
replace plot_axis = 1.75 if party_group == 2
replace plot_axis = 2.75 if party_group == 3
replace plot_axis = 3.5 if party_group == 4
replace plot_axis = 4.5 if party_group == 5
replace plot_axis = 5.25 if party_group == 6

graph twoway ///
	(bar pt_mean plot_axis if plot_axis == 1, color("80 20 80") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 1.75, color("140 80 140") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 2.75, color("100 100 100") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 3.5, color("140 140 140") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 4.5, color("60 140 80") barwidth(.75)) ///
	(bar pt_mean plot_axis if plot_axis == 5.25, color("0 80 20") barwidth(.75)) ///
	(rcap hi low plot_axis, lcolor(black)), ///
	graphregion(fcolor(white)) ///
	xlabel(1 `" "Anti-Party," "Fake News" " " "n = 1,337" "' 1.75 `" "Anti-Party," "True News" " " "n = 2,624""' ///
	2.75 `" "Neutral," "Fake News" " " "n = 1,310""' 3.5 `" "Neutral," "True News" " " "n = 1,340""' ///
	4.5 `" "Pro-Party," "Fake News" " " "n = 1,349""' 5.25 `" "Pro-Party," "True News" " " "n = 2,592""', labsize(small)) ///
	xscale(r(.6 5.65)) ///	
 	yscale(r(-.1 .1)) ///
	ylabel(-.1 (.05) .1) ///
 	xtitle("") ///
	ytitle("P(True), Demeaned") ///
 	legend(off)
	
	graph export "figures/figure3.png", replace
	
restore


*** Figure 4: Motivated reasoning by topic ***
/* Plot coefs from regression of prob_true on good_news * topic dummies
(sorted by coefs)
*/
label var good_topic1 "Pro-Party x Climate"
label var good_topic2 "Pro-Party x Refugees"
label var good_topic3 "Pro-Party x Obama crime"
label var good_topic4 "Pro-Party x Gun laws"
label var good_topic5 "Pro-Party x Race"
label var good_topic6 "Pro-Party x Gender"
label var good_topic7 "Pro-Party x Mobility"
label var good_topic8 "Pro-Party x Media"
label var good_topic1415 "Pro-Party x Party score" // good news on Reps score = bad news on Dems score
label var good_topic13 "Pro-Performance"

reghdfe prob_true good_topic1 good_topic5 good_topic7 good_topic2 good_topic3 ///
good_topic6 good_topic4 good_topic8 good_topic1415 good_topic13 if net_party != 0, ///
absorb(round_number topic_id code) cluster(code)

eststo topics

coefplot ///
(topics, keep(good_topic1) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic7) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic5) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic2) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic3) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic6) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic4) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic8) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic1415) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(topics, keep(good_topic13) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, legend(off) offset(0) drop(*round* *_dummy *topic_id* _Icode* _cons) xline(0) ///
xscale(r(-.2 .2)) xlabel(-.2 (.05) .2) /// 
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Pro-Party/Performance News on P(True) by Topic") ///
graphregion(fcolor(white))

graph export "figures/figure4.png", replace


*** Figure 5: Heterogeneity in partisan direction ***
* Plot coefs from regression of prob_true on rep_news * heterogeneity dummies
gen older = (age>32)  // median age level
gen college = (edu>13)  // median edu level
gen richer = (inc >= 50000)  // median inc level

foreach demo in pro_rep older male white college richer red_state religious_group {
	gen rep_x_`demo' = rep_news * `demo'
}

reghdfe prob_true rep_x_pro_rep rep_x_older rep_x_male rep_x_white rep_x_college ///
rep_x_richer rep_x_red_state rep_x_religious_group rep_news if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo het_horserace

lab var rep_x_pro_rep "Rep News x Pro-Rep"
lab var rep_x_older "Rep News x Older"
lab var rep_x_male "Rep News x Male"
lab var rep_x_white "Rep News x White"
lab var rep_x_college "Rep News x College"
lab var rep_x_richer "Rep News x High Income"
lab var rep_x_red_state "Rep News x Red State"
lab var rep_x_religious_group "Rep News x Religious Group"

coefplot ///
(het_horserace, keep(rep_x_pro_rep) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_older) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_male) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_white) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_college) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_richer) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_red_state) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(rep_x_religious_group) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, offset(0) drop(rep_news *round* *_dummy *topic_id* _Icode* _cons) xline(0) ///
xscale(r(-.2 .2)) xlabel(-.2 (.05) .2) /// 
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Rep/Dem News on P(True)") ///
legend(off) ///
graphregion(fcolor(white))

graph export "figures/figure5.png", replace


*** Appendix Fig 6: CDF of Performance News *****
* Make cdfplot of prob_true when news is "good/bad" and about ones performance
cdfplot prob_true if good_news+bad_news & topic_id == 13, by(good_news) ///
	opt1( lc(purple green) ) opt2( lp(dot dot) ) graphregion(fcolor(white)) ///
	legend(order(2 "Pro-Performance News" 1 "Anti-Performance News" )) xtitle("Belief About P(True News)") ytitle("Share of responses")

graph export "figures_appendix/figure6.png", replace


*** Appendix Fig 7: CDF of True News / Fake News *****
* Make cdfplot of prob_true when news is true/fake and about politics/performance
cdfplot prob_true if good_news+bad_news, by(true_news) ///
	opt1( lc(purple green) ) opt2( lp(dot dot) ) graphregion(fcolor(white)) ///
	legend(order(1 "Fake News" 2 "True News" )) xtitle("Belief About P(True News)") ytitle("Share of responses")

graph export "figures_appendix/figure7.png", replace


*** Online Appendix Fig 8: Heterogeneity in magnitude ***
* Plot coefs from regression of prob_true on good_news * heterogeneity dummies
foreach demo in pro_rep older male white college richer red_state religious_group {
	gen good_x_`demo' = good_news * `demo'
}

reghdfe prob_true good_news good_news_strength ///
good_x_older good_x_male good_x_white good_x_college ///
good_x_richer good_x_red_state good_x_religious_group if good_news + bad_news == 1 & net_party != 0, ///
absorb(topic_id round_number code) cluster(code)
eststo het_horserace

lab var good_news "Good News"
lab var good_news_strength "Good News x Partisanship"
lab var good_x_older "Good News x Older"
lab var good_x_male "Good News x Male"
lab var good_x_white "Good News x White"
lab var good_x_college "Good News x College"
lab var good_x_richer "Good News x High Income"
lab var good_x_red_state "Good News x Red State"
lab var good_x_religious_group "Good News x Religious Group"

coefplot ///
(het_horserace, keep(good_x_partisan) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_news_strength) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_older) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_male) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_white) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_college) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_richer) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_red_state) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(het_horserace, keep(good_x_religious_group) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, offset(0) drop(rep_news *round* *_dummy *topic_id* _icode* _cons) xline(0) ///
xscale(r(-.2 .2)) xlabel(-.2 (.05) .2) /// 
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Good/Bad News on P(True)") ///
legend(off) ///
graphregion(fcolor(white))

graph export "figures_appendix/figure8.png", replace


*** Online Appendix Fig 9: Motivated reasoning by round ***
* Plot coefs from regression of prob_true on good_news * round # dummies
forval i = 1/14 {
	lab var good_round`i' "Pro-Party x Round `i'"
}
lab var good_round13 "Pro-Performance x Round 13"

reghdfe prob_true good_round1 good_round2 good_round3 good_round4 good_round5 ///
good_round6 good_round7 good_round8 good_round9 good_round10 good_round11 /// 
good_round12 good_round13 good_round14 if good_news + bad_news, absorb(round_number topic_id code) cluster(code)
eststo rounds

coefplot ///
(rounds, keep(good_round1) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round2) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round3) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round4) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round5) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round6) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round7) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round8) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round9) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round10) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round11) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round12) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round13) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
(rounds, keep(good_round14) mcolor("0 0 0") ciopts(color("0 0 0"))) ///
, legend(off) offset(0) drop(*round_number* *_dummy *topic_id* _Icode* _cons) xline(0) ///
xscale(r(-.2 .2)) xlabel(-.2 (.05) .2) /// 
mlabposition(6) mlabsize(3) mlabcolor("0 0 0") xtitle("Effect of Good/Bad News on P(True)") ///
graphregion(fcolor(white))

graph export "figures_appendix/figure9.png", replace


****************************
********** TABLES **********
****************************

*** Table 2: Motivated reasoning and news assessments ***
/* 
	Effects of various treatments on prob_true
	spec1: compare pro_party to anti_party, use individual controls
	spec2: compare pro_party to anti_party, use individual FE (main spec)
	spec3: interact with partisanship
	spec4: compare pro_party to neutral_news and anti_party to neutral_news
	spec5: compare true_news to fake_news
	spec6: compare pro_party to anti_party and true_news to fake_news
*/ 

eststo clear

gen anti_party_drop = anti_party  // used to flag that that spec4 includes neutral_news in the sample
label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables/table2.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear


*** Table 3: Motivated reasoning and changing guesses ***
/* 
Effects of various treatments on change_guess_message
	change_guess message = 1 if change median belief in direction of message 
	change_guess message = 0 if don't change median belief
	change_guess message = -1 if change median belief in opposite direction to message 
spec1: compare pro_party to anti_party
spec2: compare polarizing news to anti-polarizing news (news away/toward mean belief in expt)
spec3: compare pro_party to anti_party and polarizing news to anti-polarizing news
spec 4-6: same as spec 1-3 but controlling for prob_true
*/ 

eststo clear

label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"
label var polarizing "Polarizing News \hspace{9mm}"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe change_guess_message pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec1
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe change_guess_message polarizing if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe change_guess_message pro_party polarizing if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe change_guess_message pro_party prob_true if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec4
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe change_guess_message polarizing prob_true if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe change_guess_message pro_party polarizing prob_true if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum change_guess_message if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables/table3.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)')

estfe, restore
eststo clear


*** Appendix Table 6: Robustness: Unskewed priors ***
* Test whether "unskewed prior beliefs" has an effect on the main specs in Table 2

eststo clear

gen good_unskewed = unskewed_prior * good_news
gen bad_unskewed = unskewed_prior * bad_news
gen good_str_unskewed = unskewed_prior * good_news_strength
gen true_unskewed = unskewed_prior * true_news

label var unskewed_prior "Unskewed"
label var good_unskewed "Unskewed x Pro-Party"
label var bad_unskewed "Unskewed x Anti-Party"
label var good_str_unskewed "Unskewed x Partisanship x Pro-Party"
label var true_unskewed "Unskewed x True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

gen bad_unskewed_drop = bad_unskewed  // used to flag that that spec3 includes neutral_news in the sample
gen unskewed_weighted = good_unskewed

reghdfe prob_true unskewed_prior pro_party good_unskewed if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true unskewed_prior pro_party good_unskewed pro_party_str good_str_unskewed c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true unskewed_prior pro_party good_unskewed anti_party bad_unskewed bad_unskewed_drop ///
if net_party != 0 & politicized_news + neutral_news == 1 & message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true unskewed_prior pro_party good_unskewed true_news true_unskewed if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table6.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "_cons") ///
	varwidth(35) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Neutral News = bad_unskewed_drop")

estfe, restore
eststo clear


*** Appendix Table 7: Robustness: Previous news type ***
/*
	Test whether "unskewed prior beliefs" has an effect on the main specs in Table 2
*/
eststo clear

label var count_prev_net "Previous Pro-Party"

reghdfe prob_true count_prev_net pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true count_prev_net pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true count_prev_net pro_party anti_party anti_party_drop if net_party != 0 & ///
politicized_news + neutral_news == 1 & message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true count_prev_net pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table7.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "_cons") ///
	varwidth(35) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Neutral News = anti_party_drop")

estfe, restore
eststo clear


*** Online Appendix Table 11: Table 2 for second-guess group ***
* Mimic table 2 but restrict sample to case where treatment_s (second-guess) == 1
preserve 

keep if treatment_s == 1

eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table11.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

restore


*** Online Appendix Table 12: Table 2 for WTP group ***
* Mimic table 2 but restrict sample to case where treatment_p (WTP group) == 1
preserve 

keep if treatment_p == 1

eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table12.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

restore


*** Online Appendix Table 13: Table 2 for given 50-50 prior group ***
* Mimic table 2 but restrict sample to case where treatment_y (given prior) == 1
preserve 

keep if treatment_y == 1

eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table13.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

restore


*** Online Appendix Table 14: Table 2 for not given prior group ***
* Mimic table 2 but restrict sample to case where treatment_n (not given prior) == 1
preserve 

keep if treatment_n == 1

eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table14.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

restore


*** Online Appendix Table 15: Table 2 including subjects who failed comprehension ***
* Mimic table 2 using data that incldues subjects who failed comprehension checks
preserve

import delimited "data/cleaned_data_withfailedcheck.csv", clear

eststo clear

gen anti_party_drop = anti_party
label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe prob_true pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum prob_true if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe prob_true true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table15.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

restore

*** Online Appendix Table 16: Table 2 using logit veracity assessments ***
* Mimic table 2 but use logit(prob_true) instead of prob_true
* Note: logit_prob = logit(0.05) if prob_true = 0 and logit(0.95) if prob_true = 1
eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

local controls "white black asian latino age male edu red_state religious_group log_inc"

reghdfe logit_prob pro_party net_party `controls' if pro_party + anti_party == 1, absorb(round_number topic_id) cluster(code)
eststo spec1
qui sum logit_prob if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe logit_prob pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum logit_prob if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe logit_prob pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum logit_prob if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe logit_prob pro_party anti_party anti_party_drop if net_party != 0 & politicized_news + neutral_news == 1 & ///
message_greater + message_less == 1, absorb(round_number code) cluster(code)
eststo spec4
qui sum logit_prob if pro_party + anti_party + neutral_news
estadd scalar Mean = `r(mean)'

reghdfe logit_prob true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec5
qui sum logit_prob if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe logit_prob pro_party true_news if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec6
qui sum logit_prob if pro_party + anti_party
estadd scalar Mean = `r(mean)'

estfe spec*, labels(topic_id "Question FE" round_number "Round FE" code "Subject FE")

esttab spec* using "tables_appendix/table16.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "net_party" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)' "Subject controls = `controls'" "Neutral News = anti_party_drop")

estfe, restore
eststo clear

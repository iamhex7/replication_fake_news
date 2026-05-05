cls
clear all
set more off

import delimited "data/cleaned_replication_data.csv", clear

****************************
********** TABLES **********
****************************

*** Online Appendix Table 8: Replication of Table 2 ***
* spec2, spec3, spec5, spec6 the same as those in table 2 (as preregistered)
* Note: no neutral topics here, so spec4 removed
eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

reghdfe prob_true pro_party if pro_party + anti_party == 1, absorb(round_number topic_id code) cluster(code)
eststo spec2
qui sum prob_true if pro_party + anti_party
estadd scalar Mean = `r(mean)'

reghdfe prob_true pro_party pro_party_str c.abs_net_party#i.round_number c.abs_net_party#i.topic_id if pro_party + anti_party == 1, ///
absorb(round_number topic_id code) cluster(code)
eststo spec3
qui sum prob_true if pro_party + anti_party
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

esttab spec* using "tables_appendix/table8.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) drop("*round*" "*topic_id*" "_cons") ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)')

estfe, restore
eststo clear


*** Online Appendix Table 9: Replication of Table 3 ***
* specs the same as those in Table 3
eststo clear

label var prob_true "P(True)"
label var pro_party_str "Partisanship x Pro-Party"
label var true_news "True News"
label var polarizing "Polarizing News \hspace{9mm}"

label var pro_party "Pro-Party News"
label var anti_party "Anti-Party News"

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

esttab spec* using "tables_appendix/table9.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) ///
	varwidth(20) wrap compress nomtitles nogap replace ///
	indicate(`r(indicate_fe)')

estfe, restore
eststo clear


*** Online Appendix Table 10: Replication of overprecision ***
* Overprecision table was removed from main study, but preregistered
* Test whether overprecision inc in partisanship
lab var abs_net_party "Partisanship \hspace{28mm}"
local controls "white black asian latino age male edu red_state religious_group log_inc"

reg overprecision abs_net_party if abs_net_party != 0 & dem_news + rep_news == 1, cluster(code)
eststo spec1
qui sum overprecision if abs_net_party != 0 & dem_news + rep_news == 1
estadd scalar Mean = `r(mean)'

reg overprecision abs_net_party `controls' if abs_net_party != 0 & dem_news + rep_news == 1, cluster(code)
eststo spec2
qui sum overprecision if abs_net_party != 0 & dem_news + rep_news == 1
estadd scalar Mean = `r(mean)'

esttab spec* using "tables_appendix/table10.tex", ///
	se lab b(3) r2(2) noconstant nostar ///
	scalars(Mean) ///
	varwidth(35) wrap compress nomtitles nogap replace ///
	indicate("Subject controls = `controls'")

estfe, restore
eststo clear


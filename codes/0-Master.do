******************************
*****  0. Master Do-File *****
******************************

** Change the username and root folder here to your Stata username and the 
* directory in which you placed the folder.  
* Stata will automatically set the global

global fake_news_effect ""

if "`c(username)'"=="" {  	//Change username here
	global fake_news_effect "" 	//Change folder here
}
if "`c(username)'"=="zcahmth" {
	cd "/Users/zcahmth/Dropbox/fake-news-effect_code"
}

disp `fake_news_effect'
cd `fake_news_effect'

* Install packages
do config_stata.do

* Clean data
* Input: raw_data.csv. Output: cleaned_data.csv.
do 1-Cleaning.do
* Input: replication_data.csv. Output: cleaned_replication_data.csv.
do 2-CleanReplication.do

* Create figures + tables
* Input: cleaned_data.csv. Output: figures + tables from main experiment.
do 3-Analysis.do
* Input: cleaned_replication_data.csv. Output: tables from replication experiment.
do 4-AnalysisReplication.do

* Display numbers used in text
do 5-Numbers.do


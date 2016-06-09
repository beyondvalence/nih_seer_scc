***************************
*** SEER UVR SCC        ***
*** Format datasets     ***
*** Created 20160609THU ***
***************************
*set memory 1g
*set more off
****************************************************************
** ALL States and Counties except Alaska and Hawaii
** DB18_HL_HIV_IA
** HL codes for Iowa, which does not ever exclude HIV cases
****************************************************************

import delimited "C:\REB\SEER_SCC\Data\scc_county_counts.csv", delimiter(comma) rowrange(1) clear 
save "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", replace

* if files too large or extra pages, use below append:
* append using "E:\NCI REB\UV and HL\Data\Stata\DB18_HL_HIV_IA_H" 
* append using "E:\NCI REB\UV and HL\Data\Stata\DB18_HL_HIV_IA_B" 

* rename variable names
rename v1 county
rename v2 year_dx
rename v3 sex
rename v4 age_dx
rename v5 race

save "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", replace
describe

* tabstat all_scc pop, stat(sum)
* drop fips state registry SEER9 SEER11 SEER13 SEER17 SEER18 

gen fips = regexs(0) if(regexm(county, "[0-9][0-9][0-9][0-9][0-9]"))

*Drop cumulative registry totals so no overlap in cases
tab county if fips==""
drop if fips =="" 

*Drop unknowns
tab county if fips =="09999" | fips =="49999" | fips =="35999" | fips =="34999"   
tabstat all_scc resp_scc oral_scc pop, stat(sum)
drop if fips =="09999" | fips =="49999" | fips =="35999" | fips =="34999"    
tabstat all_scc resp_scc oral_scc pop, stat(sum)

*Make state variable
generate splitcounty = strpos(county,":")
tab county if splitcounty == 0
generate str1 state = ""
replace state = substr(county,1,splitcounty - 1)
tab state
drop splitcounty
replace state=trim(state)
tab state, missing

gen racen=1 if race=="nhw" /* non Hispanic white */
replace racen=2 if race=="hw" /*  Hispanic white */
replace racen=3 if race=="b" /* black */
tab race racen

save "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", replace
tabstat all_scc resp_scc oral_scc pop, stat(sum)
*tab fips
display r(r)

*tabstat all_scc , stat(sum) by(fips)

* all SCC: 344115    resp SCC: 155012     oral SCC: 92189
********************************************************************************





********************************************************************************
* 1. All registries except Iowa (HIV free) *************************************
********************************************************************************

use "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", clear
sort state fips racen sex age_dx year_dx

*Make registry variable
generate registry=0
replace registry = 1 if state == "WA"
replace registry = 2 if state == "MI" 
replace registry = 3 if state == "CT" 
replace registry = 4 if state == "IA"
replace registry = 5 if state == "NJ"
replace registry = 6 if state == "KY"
replace registry = 8 if state == "UT"
replace registry = 14 if state == "LA"
replace registry = 16 if state == "NM"

*Atlanta (Metropolitan) Registry;
replace registry = 9 if inlist(fips,"13063","13067","13089","13121","13135")
*Rural Georgia Registry;
replace registry = 12 if inlist(fips,"13125","13133","13141","13159","13163")
replace registry = 12 if inlist(fips,"13211","13237","13265","13301","13303")
*Greater Georgia Registry;
replace registry = 13 if state=="GA" & registry != 9 & registry != 12
*San Francisco-Oakland SMSA Registry;
replace registry = 7 if inlist(fips,"06001","06013","06041","06075","06081") 
*San Jose-Monterey Registry;
replace registry = 11 if inlist(fips,"06053","06069","06085","06087")
*Los Angeles Registry (06037);
replace registry = 15 if inlist(fips,"06037") 
*California excluding SF/SJM/LA Registry;
replace registry = 10 if state=="CA" & registry != 7 & registry != 11 & registry != 15

tab registry
drop if registry==0

*Labels
label define registryl 1 "WA" 2 "MI" 3 "CT" 4 "IA" 5 "NJ" 6 "KY" 7 "SanFrancisco-Oakland" 8 "UT" 9 "Atlanta" 10 "GreaterCA" 11 "SanJose-Monterey" 12 "RuralGA" 13 "GreaterGA" 14"LA" 15 "Los Angeles" 16 "NM"
label values registry registryl

label define racel 1 "White" 2 "Hispanic" 3 "Black"
label values racen racel


* SEER9  registries are Atlanta, Connecticut, Detroit, Hawaii, Iowa, New Mexico, San Francisco-Oakland, Seattle-Puget Sound, and Utah. 
generate SEER9=0
replace SEER9=1 if registry==9 | registry==3 | registry==2 | registry==4 | registry==16 | registry==7 | registry==1| registry==8

* SEER11 registries consist of the SEER9 + Los Angeles and San Jose-Monterey
generate SEER11=0
replace SEER11=1 if SEER9==1 | registry==15 | registry==11

* SEER13 registries consist of the SEER11 + Rural Georgia and the Alaska Native Tumor Registry
generate SEER13=0
replace SEER13=1 if SEER11==1 | registry==12

* SEER 7 registries consist of the SEER13 + Greater California, Kentucky, Louisiana, and New Jersey
generate SEER17=0
replace SEER17=1 if SEER13==1 | registry==10 | registry==6 | registry==14 | registry==5

* SEER18 registries consist of the SEER17 + Greater Georgia
generate SEER18=0
replace SEER18=1 if SEER17==1 | registry==13

save "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", replace
tabstat all_scc resp_scc oral_scc pop, stat(sum)

*************************************
** Link in ZARIA and weather data ***
*************************************

use "C:\REB\SEER_SCC\Data\nci_uv-county.dta", clear
sort fips
save Zaria, replace

use "C:\REB\SEER_SCC\Data\scc_county_counts1.dta", clear
sort fips
save SEER, replace

compress all_scc all_non resp_scc resp_non oral_scc oral_non pop racen registry SEER9 SEER11 SEER13 SEER17 SEER18
describe

merge m:1 fips using Zaria
tab STATE_ABR if _merge==2
drop if _merge==2 
drop _merge statename STATE_ABR county
tab state 

replace sex = substr(sex, indexnot(sex, " "), .) 
generate male=0
replace male=1 if sex=="male"
tab sex male
 
tab age_dx
generate agecat=0
replace agecat=1 if age_dx=="0-44"
replace agecat=2 if age_dx=="45-64"
replace agecat=3 if age_dx=="65+"

label define agecatl 1 "0-44" 2 "45-64" 3 "65+"
label values agecat agecatl

tab age_dx agecat


generate year305 = uvr
xtile qyear305 = uvr, nq(5) 

sum uvr if qyear305==1
sum uvr if qyear305==2
sum uvr if qyear305==3
sum uvr if qyear305==4
sum uvr if qyear305==5

mean uvr if  qyear305==1
mean uvr if  qyear305==2
mean uvr if  qyear305==3
mean uvr if  qyear305==4
mean uvr if  qyear305==5

save "C:\REB\SEER_SCC\Data\scc_county_counts1_uvr.dta", replace

*drop objectid Join_Count TARGET_FID Join_Count_1 FIPS_OLD 
*drop Jan305 Feb305 Mar305 Apr305 May305 Jun305 Jul305 Aug305 Sep305 Oct305 Nov305 Dec305 
*drop Jan310 Feb310 Mar310 Apr310 May310 Jun310 Jul310 Aug310 Sep310 Oct310 Nov310 Dec310 
*drop Jan325 Feb325 Mar325 Apr325 May325 Jun325 Jul325 Aug325 Sep325 Oct325 Nov325 Dec325 
*drop Jan380 Feb380 Mar380 Apr380 May380 Jun380 Jul380 Aug380 Sep380 Oct380 Nov380 Dec380 
*drop FIPS_char latitide longitude Airport STATE_wthr STATION_NA elev 
*drop JANRain FEBRain MARRain APRRain MAYRain JUNRain JULRain AUGRain SEPRain OCTRain NOVRain DECRain ANNRain 
*drop JANMEANTem FEBMEANTem MARMEANTem APRMEANTem MAYMEANTem JUNMEANTem JULMEANTem AUGMEANTem SEPMEANTem OCTMEANTem NOVMEANTem DECMEANTem ANNMEANTem 
*drop JANMINTemp FEBMINTemp MARMINTemp APRMINTemp MAYMINTemp JUNMINTemp JULMINTemp AUGMINTemp SEPMINTemp OCTMINTemp NOVMINTemp DECMINTemp ANNMINTemp 
*drop JANMAXTemp FEBMAXTemp MARMAXTemp APRMAXTemp MAYMAXTemp JUNMAXTemp JULMAXTemp AUGMAXTemp SEPMAXTemp OCTMAXTemp NOVMAXTemp DECMAXTemp ANNMAXTemp 
*drop OrderID lat_wthr lon_wthr  _merge 
*drop wint305 sprg305 summ305 fall305 qwint305 qsprg305 qsumm305 qfall305


*Collapse data by UV quintiles (based on county), maintaining registry, race, sex, age group, and year of dx 

use "C:\REB\SEER_SCC\Data\scc_county_counts1_uvr.dta", clear
tabstat all_scc all_non, stat(sum)
sort  registry racen male agecat year_dx qyear305

collapse (sum) all_scc all_non resp_scc resp_non oral_scc oral_non pop (mean) year305, by(registry racen male agecat year_dx qyear305)
gen lnpop=ln(pop)

save "C:\REB\SEER_SCC\Data\scc_county_counts1_uvr.dta", replace

tab registry qyear305
tabstat all_scc all_non, stat(sum)
sort qyear305 registry racen male agecat year_dx
by qyear305:tabstat year305, stat(mean)
by qyear305:tabstat all_scc resp_scc oral_scc, stat(sum)

/*************************************************************************
* 2. All registries except Iowa (HIV free) + Iowa ***********************
*************************************************************************

***** Combine 2 HIVfree and IA datasets *****
use DB18_HL_HIVFree_NoIA, clear
sort fips race agecat dxyr5 sex
tabstat counthl pophl, stat(sum)

save DB18_HL_HIVFree_NoIA,replace

use DB18_HL_HIV_IA,replace
sort fips race agecat dxyr5 sex
tabstat counthl pophl, stat(sum)

append using DB18_HL_HIVFree_NoIA

save DB18_HL_HIVFree_withIA, replace
tabstat counthl pophl, stat(sum)


*Collapse data by fips to link in UV
use DB18_HL_HIVFree_withIA, clear

sort state fips racen sex agecat dxyr5

collapse (sum) counthl pophl countchl popchl countchlns popchlns countchllr popchllr countchlmcld popchlmcld countchlnos popchlnos countnlphl popnlphl, by(state fips racen sex agecat dxyr5) 
tabstat counthl pophl, stat(sum)
*Make registry variable
generate registry=0

replace registry = 1 if state == "WA"
replace registry = 2 if state == "MI" 
replace registry = 3 if state == "CT" 
replace registry = 4 if state == "IA"
replace registry = 5 if state == "NJ"
replace registry = 6 if state == "KY"

replace registry = 8 if state == "UT"

replace registry = 14 if state == "LA"

replace registry = 16 if state == "NM"

*Atlanta (Metropolitan) Registry;
replace registry = 9 if inlist(fips,"13063","13067","13089","13121","13135")
*Rural Georgia Registry;
replace registry = 12 if inlist(fips,"13125","13133","13141","13159","13163")
replace registry = 12 if inlist(fips,"13211","13237","13265","13301","13303")
*Greater Georgia Registry;
replace registry = 13 if state=="GA" & registry != 9 & registry != 12

*San Francisco-Oakland SMSA Registry;
replace registry = 7 if inlist(fips,"06001","06013","06041","06075","06081") 
*San Jose-Monterey Registry;
replace registry = 11 if inlist(fips,"06053","06069","06085","06087")
*Los Angeles Registry (06037);
replace registry = 15 if inlist(fips,"06037") 
*California excluding SF/SJM/LA Registry;
replace registry = 10 if state=="CA" & registry != 7 & registry != 11 & registry != 15

tab registry
drop if registry==0
tab registry

*Labels
label define registry 1 "WA" 2 "MI" 3 "CT" 4 "IA" 5 "NJ" 6 "KY" 7 "SanFrancisco-Oakland" 8 "UT" 9 "Atlanta" 10 "GreaterCA" 11 "SanJose-Monterey" 12 "RuralGA" 13 "GreaterGA" 14"LA" 15 "Los Angeles" 16 "NM"
label values registry registry

label define race 1 "WHB"  2 "White" 3 "Hispanic" 4 "Black"
label values racen race

* SEER9  registries are Atlanta, Connecticut, Detroit, Hawaii, Iowa, New Mexico, San Francisco-Oakland, Seattle-Puget Sound, and Utah. 
generate SEER9=0
replace SEER9=1 if registry==9 | registry==3 | registry==2 | registry==4 | registry==16 | registry==7 | registry==1| registry==8

* SEER11 registries consist of the SEER9 + Los Angeles and San Jose-Monterey
generate SEER11=0
replace SEER11=1 if SEER9==1 | registry==15 | registry==11

* SEER13 registries consist of the SEER11 + Rural Georgia and the Alaska Native Tumor Registry
generate SEER13=0
replace SEER13=1 if SEER11==1 | registry==12

* SEER 7 registries consist of the SEER13 + Greater California, Kentucky, Louisiana, and New Jersey
generate SEER17=0
replace SEER17=1 if SEER13==1 | registry==10 | registry==6 | registry==14 | registry==5

* SEER18 registries consist of the SEER17 + Greater Georgia
generate SEER18=0
replace SEER18=1 if SEER17==1 | registry==13

save DB18_HL_HIVFree_withIA, replace


*************************************
** Link in Zaria and weather data ***
*************************************

use "E:\NCI REB\UV and HL\Data\Stata\nci_uv-county.dta", clear
sort fips
save Zaria, replace

use DB18_HL_HIVFree_withIA, clear
sort fips
save SEER, replace

compress counthl pophl countchl popchl countchlns popchlns countchllr popchllr countchlmcld popchlmcld countchlnos popchlnos countnlphl popnlphl

merge m:1 fips using Zaria
tab STATE_ABR if _merge==2
drop if _merge==2
tab state 

replace sex = substr(sex, indexnot(sex, " "), .) 
generate male=0
replace male=1 if sex=="Male"
tab sex male
 
tab agecat
generate agecatn=0
replace agecatn=1 if agecat=="0-14 years"
replace agecatn=2 if agecat=="15-24 years"
replace agecatn=3 if agecat=="25-44 years"
replace agecatn=4 if agecat=="45-64 years"
replace agecatn=5 if agecat=="65-84 years"
tab agecat agecatn


generate year305=uvr
xtile qyear305 = year305, nq(5) 

sum year305 if qyear305==1
sum year305 if qyear305==2
sum year305 if qyear305==3
sum year305 if qyear305==4
sum year305 if qyear305==5

mean year305 if  qyear305==1
mean year305 if  qyear305==2
mean year305 if  qyear305==3
mean year305 if  qyear305==4
mean year305 if  qyear305==5

gen pop= pophl

save DB18_HL_HIVFree_withIA_UVR_Zaria, replace

*drop objectid Join_Count TARGET_FID Join_Count_1 FIPS_OLD 
*drop Jan305 Feb305 Mar305 Apr305 May305 Jun305 Jul305 Aug305 Sep305 Oct305 Nov305 Dec305 
*drop Jan310 Feb310 Mar310 Apr310 May310 Jun310 Jul310 Aug310 Sep310 Oct310 Nov310 Dec310 
*drop Jan325 Feb325 Mar325 Apr325 May325 Jun325 Jul325 Aug325 Sep325 Oct325 Nov325 Dec325 
*drop Jan380 Feb380 Mar380 Apr380 May380 Jun380 Jul380 Aug380 Sep380 Oct380 Nov380 Dec380 
*drop FIPS_char latitide longitude Airport STATE_wthr STATION_NA elev 
*drop JANRain FEBRain MARRain APRRain MAYRain JUNRain JULRain AUGRain SEPRain OCTRain NOVRain DECRain ANNRain 
*drop JANMEANTem FEBMEANTem MARMEANTem APRMEANTem MAYMEANTem JUNMEANTem JULMEANTem AUGMEANTem SEPMEANTem OCTMEANTem NOVMEANTem DECMEANTem ANNMEANTem 
*drop JANMINTemp FEBMINTemp MARMINTemp APRMINTemp MAYMINTemp JUNMINTemp JULMINTemp AUGMINTemp SEPMINTemp OCTMINTemp NOVMINTemp DECMINTemp ANNMINTemp 
*drop JANMAXTemp FEBMAXTemp MARMAXTemp APRMAXTemp MAYMAXTemp JUNMAXTemp JULMAXTemp AUGMAXTemp SEPMAXTemp OCTMAXTemp NOVMAXTemp DECMAXTemp ANNMAXTemp 
*drop OrderID lat_wthr lon_wthr  _merge 
*drop wint305 sprg305 summ305 fall305 qwint305 qsprg305 qsumm305 qfall305


*Collapse data by UV quintiles (based on county), maintaining registry, race, sex, age group, and year of dx 

use DB18_HL_HIVFree_withIA_UVR_Zaria, clear

sort  registry racen male agecat dxyr5 qyear305

collapse (sum) counthl pophl countchl countchlns countchllr countchlmcld countchlnos countnlphl (mean) year305, by(registry racen male agecat dxyr5 qyear305)
gen lnpop=ln(pop)

tabstat counthl pophl, stat(sum)

sort registry qyear305 
by registry qyear305: sum year305

by registry: tabstat counthl pophl, stat(sum)
*20021 total cases

save DB18_HL_HIVFree_withIA_UVRc_Zaria, replace
save "E:\NCI REB\UV and HL\Data\Stata\DB18_HL_HIVFree_withIA_UVRc_Zaria.dta", replace


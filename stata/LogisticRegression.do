clear
capture log close
cd "D:/OneDrive/OneDrive - Objectvision/VU/Projects/202011-Ruimtebeslag Werken"
log using temp/LogisticRegression.txt, text replace

import delimited "C:\GeoDMS\LocalData\rslight2021_ontwikkel_3\Results\casus\BaseData_Geschiktheden_Werken_Export_Regressie_20220413.csv", clear 
save RuimtebeslagData_raw.dta, replace

use RuimtebeslagData_raw.dta, clear

local bag_sectoren "bijeenkomst cel gezondheidszorg industrie kantoor logies onderwijs overige_gebruiks sport winkel woon logistiek utiliteit_combi"
foreach bs of local bag_sectoren{
	g `bs'Change = fp_2022_`bs' - fp_2012_`bs'
}

g landbouwChange = 0
g nijverheidChange = industrieChange + utiliteit_combiChange
g detailhandelChange = winkelChange
g ov_consumentendienstenChange = bijeenkomstChange + sportChange
g zak_dienstverleningChange = kantoorChange
g overheid_kw_dienstenChange = celChange + gezondheidszorgChange + onderwijsChange
g recreatieChange = logiesChange

g Threshold = 100

rename fp_20121 fp_2012
rename fp_20221 fp_2022
g fp_change = fp_2022 - fp_2012


drop landscape_quality distto_groenehart_2004kilom groenehart_2004
drop bijeenkomstChange celChange gezondheidszorgChange industrieChange kantoorChange logiesChange onderwijsChange overige_gebruiksChange sportChange winkelChange woonChange utiliteit_combiChange landbouwChange recreatieChange
drop fp_2012*
drop fp_2022*

rename v79 avgshr_LU12_ngh_1000r_otherbu

drop lu_share_greenhouses_2012 lu_share_agriculture_2012 lu_share_urbangreen_2012 avg_shr_lutype_2012_neigh_100r_g avg_shr_lutype_2012_neigh_100r_a avg_shr_lutype_2012_neigh_100r_c avg_shr_lutype_2012_neigh_100r_i avg_shr_lutype_2012_neigh_100r_f avg_shr_lutype_2012_neigh_100r_o v68 avg_shr_lutype_2012_neigh_100r_r avg_shr_lutype_2012_neigh_100r_u avg_shr_lutype_2012_neigh_100r_w avg_shr_lutype_2012_neigh_100r_d avg_shr_lutype_2012_neigh_1000r_ v74 v75 v76 v77 v78 v80 v81 v82 v83

g max_change = max(logistiekChange, nijverheidChange, detailhandelChange, ov_consumentendienstenChange, zak_dienstverleningChange, overheid_kw_dienstenChange)

g IslogistiekMax = logistiekChange == max_change
g IsnijverheidMax = nijverheidChange == max_change
g IsdetailhandelMax = detailhandelChange == max_change
g Isov_consumentendienstenMax = ov_consumentendienstenChange == max_change
g Iszak_dienstverleningMax = zak_dienstverleningChange == max_change
g Isoverheid_kw_dienstenMax = overheid_kw_dienstenChange == max_change

local txl_sectoren "nijverheid logistiek detailhandel ov_consumentendiensten zak_dienstverlening overheid_kw_diensten"
foreach ts of local txl_sectoren{
	g Has`ts'Growth = (`ts'Change > Threshold) * Is`ts'Max
}


rename distto_cargoair distto_cargoair_km 
rename distto_airports_2019 dist_airport_km_2019  
rename distto_highway_acces_exit_2018 dist_highway_km_2018 
rename distto_zeehavens_2019 dist_seaport_km_2019 
rename distto_urban_contour_2000 dist_urbancontour_km_2000 
rename distto_trainstations_2019 dist_train_km_2019  
rename hedonic_landprice_2007europerm landprice_2007

g ln_tt_100kinhab_min_2017 = ln(tt_100kinhab_min_2017)

label var distto_cargoair_km "Distance to cargo airports (km)"
label var dist_airport_km_2019 "Distance to top 5 airport in 2019 (km)"
label var dist_highway_km_2018 "Distance to high-way exits in 2018 (km)"
label var dist_seaport_km_2019 "Distance to seaports in 2019 (km)"
label var dist_train_km_2019 "Distance to trainstations in 2019 (km)"
label var dist_urbancontour_km_2000 "Distance to urban contour of 2000 (km)"
label var tt_100kinhab_min_2017 "Travel time to reach 100,000 inhabitants in 2017 (min)"
label var ln_tt_100kinhab_min_2017 "Ln of Travel time to reach 100,000 inhabitants in 2017 (min)"
label var uai_2018 "Urban Attractivity Index in 2018"
label var landprice_2007 "Hedonic land price in 2007 in euro per m2"
label var vinex "Is located in residential development plan (VINEX)"
label var natura2000 "Is located in Natura 2000 area"
label var bundelingsgebieden "Is located in bundelingsgebied"
label var bufferzones_2005 "Is located in a bufferzone"
label var ehs_1990 "Is located in the Ecologische Hoofdstructuur"
label var lu_simpson_diversity_index_2012 "Simpson diversity index of land use in 2012"

g lu_share_nature_2012 = lu_share_forest_2012 + lu_share_othernature_2012
g lu_share_unavailable_2012 = lu_share_infrastructure_2012 + lu_share_water_2012
    
drop lu_share_forest_2012 lu_share_othernature_2012 lu_share_infrastructure_2012 lu_share_water_2012 lu_simpson_diversity_index_2012 lu_share_otherbuiltup_2012

g lndistto_cargoair_km = ln(distto_cargoair_km)
g lndist_highway_km_2018 = ln(dist_highway_km_2018)
g lndist_seaport_km_2019 = ln(dist_seaport_km_2019)
g lndist_train_km_2019 = ln(dist_train_km_2019)
g lndist_urbancontour_km_2000 = ln(dist_urbancontour_km_2000)


encode prov_name, generate(prov)

drop if prov == 1

g devtype_name = ""
replace devtype_name = "Nijverheid" if HasnijverheidGrowth == 1
replace devtype_name = "Logistiek" if HaslogistiekGrowth == 1
replace devtype_name = "Detailhandel" if HasdetailhandelGrowth == 1
replace devtype_name = "Ov consumentendiensten" if Hasov_consumentendienstenGrowth == 1
replace devtype_name = "Zak dienstverlening" if Haszak_dienstverleningGrowth == 1
replace devtype_name = "Overheid kw diensten" if Hasoverheid_kw_dienstenGrowth == 1
replace devtype_name = "Onveranderd" if devtype_name == ""
encode devtype_name, generate(devtype)

drop IslogistiekMax IsnijverheidMax IsdetailhandelMax Isov_consumentendienstenMax Iszak_dienstverleningMax Isoverheid_kw_dienstenMax overheid_kw_dienstenChange zak_dienstverleningChange ov_consumentendienstenChange detailhandelChange nijverheidChange logistiekChange

g lnlandprice = ln(landprice)

g HasLargeTotalFPChange = fp_change > 500
g HasSmallTotalFPChange = fp_change > 100

g devtype_wLargeChange = devtype
replace devtype_wLargeChange = 4 if HasLargeTotalFPChange == 1
g devtype_wSmallChange = devtype
replace devtype_wSmallChange = 4 if HasSmallTotalFPChange == 1

save RuimtebeslagData.dta, replace

use RuimtebeslagData.dta, clear

//////MLOGIT ANALYSIS//////
///////////////////////////
	
	mlogit devtype lndistto_cargoair_km 	lndist_highway_km_2018 	lndist_seaport_km_2019 	lndist_train_km_2019 	lndist_urbancontour_km_2000 	ln_tt_100kinhab_min_2017 	uai_2018 lnland 	vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990  	lu_share_construction_2012 avgshr_LU12_ngh_1000r_otherbu lu_share_nature_2012 lu_share_residential_2012 lu_share_unavailable_2012 b6.prov
	parmest, saving(Temp/mlogit_devtype_20220401, replace) 
	use Temp/mlogit_devtype_20220401.dta, clear
	export delimited using logitcoeff_mlogit_devtype_20220401.csv, delimiter(";") replace
	

	
predict pr_nijverheid, outcome(Nijverheid)	
predict pr_logistiek, outcome(Logistiek)	
predict pr_detailhandel, outcome(Detailhandel)
predict pr_ov_consumentendiensten, outcome(Ov_consumentendiensten)	
predict pr_zak_dienstverlening, outcome(Zak_dienstverlening)	
predict pr_overheid_kw_diensten, outcome(Overheid_kw_diensten)	
predict pr_onveranderd, outcome(Onveranderd)	

//////PROBABILITIES
//Make raw
local txl_sectoren "Nijverheid Logistiek Detailhandel Ov_consumentendiensten Zak_dienstverlening Overheid_kw_diensten"
foreach ts of local txl_sectoren{
	g calc_pr_`ts'_r = _b[`ts': _cons] + lndistto_cargoair_km * _b[`ts': lndistto_cargoair_km] + lndist_highway_km_2018 * _b[`ts': lndist_highway_km_2018] +lndist_seaport_km_2019 * _b[`ts': lndist_seaport_km_2019] + lndist_train_km_2019 * _b[`ts': lndist_train_km_2019] + ln_tt_100kinhab_min_2017 * _b[`ts': ln_tt_100kinhab_min_2017] + lnlandprice * _b[`ts': lnlandprice] + lndist_urbancontour_km_2000 * _b[`ts': lndist_urbancontour_km_2000] + uai_2018 * _b[`ts': uai_2018] + vinex *  _b[`ts': vinex] + natura2000 * _b[`ts': natura2000] + bundelingsgebieden * _b[`ts': bundelingsgebieden] + bufferzones_2005 * _b[`ts': bufferzones_2005] + ehs_1990 * _b[`ts': ehs] + lu_share_unavailable_2012 * _b[`ts': lu_share_unavailable_2012] + lu_share_construction_2012 *  _b[`ts': lu_share_construction_2012] + lu_share_nature_2012 * _b[`ts': lu_share_nature_2012] + lu_share_residential_2012 *  _b[`ts': lu_share_residential_2012] + avgshr_LU12_ngh_1000r_otherbu *  _b[`ts': avgshr_LU12_ngh_1000r_otherbu]
}

g noemer = 1 + exp(calc_pr_Nijverheid_r) + exp(calc_pr_Logistiek_r) + exp(calc_pr_Detailhandel_r) + exp(calc_pr_Ov_consumentendiensten_r) + exp(calc_pr_Zak_dienstverlening_r) + exp(calc_pr_Overheid_kw_diensten_r)

local txl_sectoren "Nijverheid Logistiek Detailhandel Ov_consumentendiensten Zak_dienstverlening Overheid_kw_diensten"
foreach ts of local txl_sectoren{
	g calc_pr_`ts' = exp(calc_pr_`ts'_r) / noemer 	
}
	
sum 	
	
	
	
///ALLEEN LOCATIES MET FYSIEKE FP VERANDERING
	mlogit devtype_wLargeChange lndistto_cargoair_km 	lndist_highway_km_2018 	lndist_seaport_km_2019 	lndist_train_km_2019 	lndist_urbancontour_km_2000 	ln_tt_100kinhab_min_2017 	uai_2018 lnland 	vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990  	lu_share_construction_2012 avgshr_LU12_ngh_1000r_otherbu lu_share_nature_2012 lu_share_residential_2012 lu_share_unavailable_2012 b6.prov 
	parmest, saving(Temp/mlogit_devtype_20220413, replace) 
	use Temp/mlogit_devtype_20220413.dta, clear
	export delimited using logitcoeff_mlogit_devtype_20220413.csv, delimiter(";") replace

	
	
sum devtype lndistto_cargoair_km 	lndist_highway_km_2018 	lndist_seaport_km_2019 	lndist_train_km_2019 	lndist_urbancontour_km_2000 	ln_tt_100kinhab_min_2017 	uai_2018 lnland 	vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990  	lu_share_construction_2012 avgshr_LU12_ngh_1000r_otherbu lu_share_nature_2012 lu_share_residential_2012 lu_share_unavailable_2012, separator(0)

sum devtype distto_cargoair_km dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000  tt_100kinhab_min_201760s uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 lu_share_construction_2012 avgshr_LU12_ngh_1000r_otherbu lu_share_nature_2012 lu_share_residential_2012  lu_share_unavailable_2012, separator(0)
	
//500m fp 
sum distto_cargoair_km dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000  tt_100kinhab_min_201760s uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 lu_share_construction_2012 avgshr_LU12_ngh_1000r_otherbu lu_share_nature_2012 lu_share_residential_2012  lu_share_unavailable_2012 if HasLargeTotalFPChange == 1, separator(0)

	
	
sum i.prov, separator(0)

	
	
	
	
	
	


local txl_sectoren "nijverheid logistiek detailhandel ov_consumentendiensten zak_dienstverlening overheid_kw_diensten recreatie bijeenkomst"
foreach ts of local txl_sectoren{
	logit Has`ts'Growth distto_cargoair_km dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000 ln_tt_100kinhab_min_2017 uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 groenehart_2004 lu_share_agriculture_2000 lu_share_construction_2000 lu_share_infrastructure_2000 lu_share_nature_2000 lu_share_otherbuiltup_2000 lu_share_residential_2000 lu_share_urbangreen_2000 lu_share_water_2000 lu_simpson_diversity_index_2000
	outreg2 using result_logit, word label dec(3) addstat(Pseudo R2, e(r2_p)) replace
}






//export coefficients
local txl_sectoren "nijverheid logistiek detailhandel ov_consumentendiensten zak_dienstverlening overheid_kw_diensten recreatie bijeenkomst"
foreach ts of local txl_sectoren{
	use RuimtebeslagData.dta, clear
	logit Has`ts'Growth dist_airport_km_2019 dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000 			ln_tt_100kinhab_min_2017 uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 groenehart_2004 			lu_share_agriculture_2000 lu_share_construction_2000 lu_share_infrastructure_2000 lu_share_nature_2000 lu_share_otherbuiltup_2000 			lu_share_residential_2000 lu_share_urbangreen_2000 lu_share_water_2000 lu_simpson_diversity_index_2000 if `ts'Change >= 0
	parmest, saving(Temp/logit_Has`ts'_15sept21, replace) 
	use Temp/logit_Has`ts'_15sept21.dta, clear
	export delimited using logitcoeff_Has`ts'_15sept21.csv, delimiter(";") replace
}





logit HasIndustryGrowth dist_airport_km_2019 dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000 tt_100kinhab_min_2017 uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 groenehart_2004 lu_share_agriculture_2000 lu_share_construction_2000 lu_share_infrastructure_2000 lu_share_nature_2000 lu_share_otherbuiltup_2000 lu_share_residential_2000 lu_share_urbangreen_2000 lu_share_water_2000 lu_simpson_diversity_index_2000 if IndustryChange >= 0
parmest, saving(logit_HasIndustry_15sept21, replace) 
use "logit_HasIndustry_15sept21.dta", clear
export delimited using logitcoeff_HasIndustry_15sept21.csv, delimiter(";") replace






	outreg2 [lndist lndist_ob1000r lndist_ob1000r_unav lndist_re lndist_re_ob1000r lndist_re_ob1000r_unav] using logistiekresult, word label dec(3) addstat(Pseudo R2, e(r2_p)) replace







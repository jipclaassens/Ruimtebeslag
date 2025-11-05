clear
capture log close
cd "D:/OneDrive/OneDrive - Objectvision/VU/Projects/202011-Ruimtebeslag Werken"
log using temp/LogisticRegression.txt, text replace

import delimited "C:\GeoDMS\LocalData\Ruimtebeslag\Results\ruimtebeslag\Analyse_Export_Regressie_20210915.csv", clear
save RuimtebeslagData_raw.dta, replace

use RuimtebeslagData_raw.dta, clear

local bag_sectoren "bijeenkomst cel gezondheidszorg industrie kantoor logies onderwijs overige_gebruiks sport winkel woon"
foreach bs of local bag_sectoren{
	g `bs'Change = fp_2018_`bs' - fp_2012_`bs'
}

g landbouwChange = 0
g nijverheidChange = industrieChange
g logistiekChange = industrieChange
g detailhandelChange = winkelChange
g ov_consumentendienstenChange = bijeenkomstChange + sportChange
g zak_dienstverleningChange = kantoorChange
g overheid_kw_dienstenChange = celChange + gezondheidszorgChange + onderwijsChange
g recreatieChange = logiesChange

g Threshold = 100

local txl_sectoren "landbouw nijverheid logistiek detailhandel ov_consumentendiensten zak_dienstverlening overheid_kw_diensten recreatie bijeenkomst"
foreach ts of local txl_sectoren{
	g Has`ts'Growth = `ts'Change > Threshold
}

rename distto_airports_2019 dist_airport_km_2019  
rename distto_highway_acces_exit_2018 dist_highway_km_2018 
rename distto_zeehavens_2019 dist_seaport_km_2019 
rename distto_urban_contour_2000 dist_urbancontour_km_2000 
rename distto_trainstations_2019 dist_train_km_2019  
rename hedonic_landprice_2007europermet landprice_2007

g ln_tt_100kinhab_min_2017 = ln(tt_100kinhab_min_2017)

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
label var groenehart_2004 "Is located in the Green Heart"
label var lu_simpson_diversity_index_2000 "Simpson diversity index of land use in 2000"

save RuimtebeslagData.dta, replace


local txl_sectoren "nijverheid logistiek detailhandel ov_consumentendiensten zak_dienstverlening overheid_kw_diensten recreatie bijeenkomst"
foreach ts of local txl_sectoren{
	logit Has`ts'Growth dist_airport_km_2019 dist_highway_km_2018 dist_seaport_km_2019 dist_train_km_2019 dist_urbancontour_km_2000 			ln_tt_100kinhab_min_2017 uai_2018 landprice_2007 vinex natura2000 bundelingsgebieden bufferzones_2005 ehs_1990 groenehart_2004 		lu_share_agriculture_2000 lu_share_construction_2000 lu_share_infrastructure_2000 lu_share_nature_2000 lu_share_otherbuiltup_2000 			lu_share_residential_2000 lu_share_urbangreen_2000 lu_share_water_2000 lu_simpson_diversity_index_2000 if `ts'Change >= 0
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













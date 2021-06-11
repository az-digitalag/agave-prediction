!#/bin/bash
# requires nco NetCDF Operators
# note that only one historical solar radiation (srad) file is used for all scenarios
#   because these are not expected to change

# Historical Data
cp data/raw_data/TerraClimate19812010_ppt.nc data/derived_data/TerraClimate19812010.nc
ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate19812010.nc
ncks -A data/raw_data/TerraClimate19812010_tmin.nc data/derived_data/TerraClimate19812010.nc


# 2C Scenario
#cp ../raw_data/TerraClimate2C_ppt.nc TerraClimate2C.nc
#ncks -A ../raw_data/TerraClimate19812010_srad.nc TerraClimate2C.nc
#ncks -A ../raw_data/TerraClimate2C_tmin.nc TerraClimate2C.nc

# 4C Scenario
cp data/raw_data/TerraClimate4C_ppt.nc data/derived_data/TerraClimate4C.nc
ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate4C.nc
ncks -A data/raw_data/TerraClimate4C_tmin.nc data/derived_data/TerraClimate4C.nc

# AZ subset
# cd data/derived_data
ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate4C.nc TerraClimateAZ4C.nc
ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate19812010AZ.nc TerraClimateAZ19812010.nc

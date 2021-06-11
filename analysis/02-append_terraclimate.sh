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

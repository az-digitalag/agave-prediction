#!/usr/bin/bash

# requires nco NetCDF Operators
# note that only one historical solar radiation (srad) file is used for all scenarios
#   because these are not expected to change

# cp data/raw_data/TerraClimate19812010_ppt.nc data/derived_data/TerraClimate19812010.nc
# ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate19812010.nc
# ncks -A data/raw_data/TerraClimate19812010_tmin.nc data/derived_data/TerraClimate19812010.nc
#
#
# # 2C Scenario
# # cp ../raw_data/TerraClimate2C_ppt.nc TerraClimate2C.nc
# # ncks -A ../raw_data/TerraClimate19812010_srad.nc TerraClimate2C.nc
# # ncks -A ../raw_data/TerraClimate2C_tmin.nc TerraClimate2C.nc
#
# # 4C Scenario
# cp data/raw_data/TerraClimate4C_ppt.nc data/derived_data/TerraClimate4C.nc
# ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate4C.nc
# ncks -A data/raw_data/TerraClimate4C_tmin.nc data/derived_data/TerraClimate4C.nc

for climate in 19812010 2C 4C ; do

  cp data/raw_data/TerraClimate${climate}_ppt.nc data/derived_data/TerraClimate${climate}.nc
  ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate${climate}.nc
  ncks -A data/raw_data/TerraClimate${climate}_tmin.nc data/derived_data/TerraClimate${climate}.nc

  # Compute PAR
  # submitted ncap2 -O -s "par=5.6925*srad" data/derived_data/TerraClimate${climate}.nc data/derived_data/par${climate}.nc

  ncap2 -O -s "par=srad * 110 / 1000 * 18" data/derived_data/TerraClimate${climate}.nc data/derived_data/par${climate}.nc


  # Compute Absolute Minimum Annual Temperature (absmin)
  # Compute min Tmin over year
  ncwa -O -v tmin -y min -a time data/derived_data/TerraClimate${climate}.nc data/derived_data/mintmin${climate}.nc
  ncks -A data/raw_data/coldestadj_tmin.nc data/derived_data/mintmin${climate}.nc
  ncks -A data/raw_data/coldest_month_climo_adj.nc data/derived_data/mintmin${climate}.nc

  ncap2 -O -s "absmin=tmin-adjustC-cadj" data/derived_data/mintmin${climate}.nc data/derived_data/absmin${climate}.nc

  # add absmin tp
  ncks -A --no_tmp_fl -v absmin data/derived_data/absmin${climate}.nc data/derived_data/par${climate}.nc

done


## Can be used for testing
# AZ subset
# cd data/derived_data
# ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate4C.nc TerraClimateAZ4C.nc
# ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate19812010AZ.nc TerraClimateAZ19812010.nc

#!/usr/bin/bash

# requires nco NetCDF Operators
# note that only one historical solar radiation (srad) file is used for all scenarios
#   because these are not expected to change

for climate in 19812010 2C 4C ; do

  cp data/raw_data/TerraClimate${climate}_ppt.nc data/derived_data/TerraClimate${climate}.nc
  ncks -A data/raw_data/TerraClimate19812010_srad.nc data/derived_data/TerraClimate${climate}.nc
  ncks -A data/raw_data/TerraClimate${climate}_tmin.nc data/derived_data/TerraClimate${climate}.nc

  # Compute PAR
  # submitted ncap2 -O -s "par=5.6925*srad" data/derived_data/TerraClimate${climate}.nc data/derived_data/TerraClimate${climate}.nc

  ncap2 -O -s "par=2.875 * srad * 110 / 1000 * 18" data/derived_data/TerraClimate${climate}.nc data/derived_data/TerraClimate${climate}.nc

  ncatted \
    -a description,par,m,c,"photosynthetically active radiation" \
    -a units,par,m,c,"umol m-2 s-1" \
    -a standard_name,par,m,c,'surface_downwelling_photosynthetic_photon_flux_in_air' \
    -a long_name,par,m,c,'Photosynthetically Active Radiation (PAR)' \
    data/derived_data/TerraClimate${climate}.nc
  ######################################################
  # Compute Absolute Minimum Annual Temperature (absmin)
  ######################################################
  # Compute min Tmin over year
  ncwa -O -v tmin -y min -a time data/derived_data/TerraClimate${climate}.nc data/derived_data/mintmin${climate}.nc
  ncks -A data/raw_data/coldestadj_tmin.nc data/derived_data/mintmin${climate}.nc
  ncks -A data/raw_data/coldest_month_climo_adj.nc data/derived_data/mintmin${climate}.nc

  ncap2 -O -s "absmin=tmin-adjustC-cadj" data/derived_data/mintmin${climate}.nc data/derived_data/absmin${climate}.nc

  # add absmin to TerraClimate${climate}.nc file
  ncks -A --no_tmp_fl -v absmin data/derived_data/absmin${climate}.nc data/derived_data/TerraClimate${climate}.nc

  ######################################################
  # Compute annual precip (annual_ppt)
  ######################################################
  # ncap2 -O -s "
  # annual_ppt = ppt.total($time)
  # " data/derived_data/TerraClimate${climate}.nc data/derived_data/TerraClimate${climate}.nc
  ncwa -O -v ppt -y ttl -a time data/derived_data/TerraClimate${climate}.nc tmp${climate}.nc
  ncrename -v ppt,annual_ppt tmp${climate}.nc
  ncks -A -v annual_ppt tmp${climate}.nc data/derived_data/TerraClimate${climate}.nc

done


## Can be used for testing
# AZ subset
#
# for var in tmin ppt srad; do
#   ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 data/raw_data/TerraClimate19812010_${var}.nc data/raw_data/TerraClimateAZ_${var}.nc
# done
# cd data/derived_data
# ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate4C.nc TerraClimateAZ4C.nc
# ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 TerraClimate19812010AZ.nc TerraClimateAZ19812010.nc

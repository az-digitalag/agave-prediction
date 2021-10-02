# http://nco.sourceforge.net/nco.html#ncatted-netCDF-Attribute-Editor

## Files with coefficients: coefs19812010.nc and coefs4C.nc
for climate in 19812010 2C 4C ; do
  ncatted \
    -a description,alpha,m,c,"alpha (light limitation) coefficient from environmental productivity index model" \
    -a description,beta,m,c,"beta (water limitation) coefficient from environmental productivity index model" \
    -a description,beta3,m,c,"beta (water limitation) coefficient with precipitation multiplied by 1.83 to approximate effect of rock mulching from environmental productivity index model" \
    -a description,gamma,m,c,"gamma (effect of monthly minimum temperature) coefficient from environmental productivity index model; based on monthly averages; set to 0 where absolute min temp is < -10C" \
    -a units,alpha,m,c,"" \
    -a units,beta*,m,c,"" \
    -a units,gamma,m,c,"" \
    -a standard_name,alpha,m,c,'light_coefficient' \
    -a standard_name,beta,m,c,'water_coefficient' \
    -a standard_name,beta3,m,c,'water_coefficient_rock_mulch' \
    -a standard_name,gamma,m,c,'min_temperature_coefficient' \
    -a long_name,alpha,m,c,'Light coefficient' \
    -a long_name,beta,m,c,'Water coefficient' \
    -a long_name,beta3,m,c,'Water coefficient with rock mulch' \
    -a long_name,gamma,m,c,'Minimum temperature coefficient' \
    -a valid_min,alpha,c,f,0.0 \
    -a valid_min,beta*,c,f,0.0 \
    -a valid_min,gamma,c,f,0.0 \
    -a valid_max,alpha,c,f,1.0 \
    -a valid_max,beta*,c,f,1.0 \
    -a valid_max,gamma,c,f,1.0 \
    coefs${climate}.nc

  ## delete extra variables
  ncks -O -x -v par,ppt,srad,tmin coefs${climate}.nc coefs${climate}.nc

  # # generate average coefs
  # ncap2 -O  -v -s '
  # alpha_mean=alpha.avg($time);
  # beta_mean=beta.avg($time);
  # gamma_mean=gamma.avg($time)' coefs${climate}.nc mean_coefs${climate}.nc
done


## All Biomass Files allbiomass.nc
ncatted \
  -a standard_name,biomass*,d,, \
  -a units,biomass*,m,c,"Mg ha-1 y-1" \
  -a long_name,biomass,m,c,biomass \
  -a description,biomass,m,c,"annual biomass production of Agave americana: rainfed under historical climate (1981-2010)" \
  -a long_name,biomass_irrig,m,c,biomass_irrig \
  -a description,biomass_irrig,m,c,"annual biomass production of Agave americana: irrigated under historical climate (1981-2010)" \
  -a long_name,biomass_rockmulch,m,c,biomass_rockmulch \
  -a description,biomass_rockmulch,m,c,"annual biomass production of Agave americana, rainfed with rock mulch under historical climate (1981-2010)" \
  -a long_name,biomass4C,m,c,biomass4C \
  -a description,biomass4C,m,c,"annual biomass production of Agave americana: rainfed under 4C warming scenario" \
  -a long_name,biomass4C_irrig,m,c,biomass4C_irrig \
  -a description,biomass4C_irrig,m,c,"annual biomass production of Agave americana: irrigated under 4C warming scenario" \
  -a long_name,biomass4C_rockmulch,m,c,biomass4C_rockmulch \
  -a description,biomass4C_rockmulch,m,c,"annual biomass production of Agave americana: rainfed with rock mulch under 4C warming scenario" \
  -a long_name,biomass_rockmulch_arid,m,c,biomass_rockmulch_arid \
  -a description,biomass_rockmulch_arid,m,c,"annual biomass production of Agave americana: rainfed with rock mulch under  historical climate (1981-2010) for arid regions (<400mm/y precip)" \
  -a long_name,biomass4C_rockmulch_arid,m,c,biomass4C_rockmulch_arid \
  -a description,biomass4C_rockmulch_arid,m,c,"annual biomass production of Agave americana: rainfed with rock mulch under  historical climate (1981-2010) for arid regions (<400mm/y precip)" \
   allbiomass.nc



## Biomass Difference Files biomassdiff.nc
ncatted \
  -a standard_name,biomass*,d,, \
  -a units,biomass*,m,c,"Mg ha-1 y-1" \
  -a long_name,biomassdiff,m,c,change_in_biomass_under_4C \
  -a description,biomassdiff,m,c,"Change in rainfed annual biomass production of Agave americana under 4C warming scenario" \
  -a long_name,biomassdiffirrig,m,c,change_in_irrigated_biomass_under_4C \
  -a description,biomassdiffirrig,m,c,"Change in irrigated annual biomass production of Agave americana under 4C warming scenario" \
   biomassdiff.nc

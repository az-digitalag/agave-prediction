#!/usr/bin/env bash

#cd data/derived_data

## for profiling https://stackoverflow.com/a/5015179/199217
## PS4='+ $(date "+%Y-%m-%d %H:%M:%S")\011 '
exec 3>&2 2>03-compute_biomass.$$.log
set -x

for climate in 19812010 4C ; do
  echo "starting calculations for" ${climate} "climate"

  # Compute coeficients with min/max
  #  beta  = rainfed
  #  beta2 = irrigation: no water limitation, fixed to 1
  #  beta3 = rainfed + rock mulch; multiply precipitation by 1.83 to simulate
  #          a 83% increase in effective available water
  #          only use rock mulch where ppt < 400; otherwise use rainfed eqn
  ncap2 -A -s '
  alpha=-7e-07*par^2+0.0016*par-0.001;
  beta=0.0279*ppt-0.2851;
  beta2=1;
  beta3=1.83*0.0279*ppt-0.2851;
  gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;
  where(alpha<0)alpha=0;
  where(alpha>1)alpha=1;
  where(beta<0)beta=0;
  where(beta>1)beta=1;
  where(beta3<0)beta3=0;
  where(beta3>1)beta3=1;
  where(absmin<-10)gamma=0;
  where(gamma<0)gamma=0;
  where(gamma>1)gamma=1;
  ' TerraClimate${climate}.nc coefs${climate}.nc

  # compute monthly epi
  ncap2 -O -v -s '
  epi=alpha*beta*gamma;
  epi2=alpha*beta2*gamma;
  epi3=alpha*beta3*gamma;
  ' coefs${climate}.nc epi${climate}.nc &&

  # sum epi over all months compute total epi and min(tmin)
  ncap2 -O  -v -s '
  episum=epi.total($time);
  episum2=epi2.total($time);
  episum3=epi3.total($time)
  ' epi${climate}.nc episum${climate}.nc &&

  # compute biomass; set to 0 if biomass<0 or absmin<-10
  #     this is now done above where gamma = 0 when absmin < -10
  #     but could be done here with `where(absmin< -10.0)biomass=0.0;`
  # equation for five years: biomass=5 * episum * 1.7607 - 14.774
  ncap2 -v -s '
  biomass=episum*1.7607-2.9548;
  biomass2=episum2*1.7607-2.9548;
  biomass3=episum3*1.7607-2.9548;
  where(biomass<0.0)biomass=0.0;
  where(biomass2<0.0)biomass2=0.0;
  where(biomass3<0.0)biomass3=0.0;
  ' episum${climate}.nc biomass${climate}.nc

done

#############################
## Baseline Mean coefficients
## for visualization, but not used downstream
# ncap2 -O -v -s '
#   mean_alpha  = alpha.avg($time);
#   mean_beta   = beta.avg($time);
#   mean_gamma  = gamma.avg($time)' coefs19812010.nc  meancoefs19812010.nc

#######################################
##Amount of Irrigation Required      ##
#######################################

# assuming 552.7 mm/y is enough water
# equivalent to 46.061mm/mo
# as above, assume rockmulch increases effective ppt by 83%

for climate in 19812010 4C ; do

  # combine ppt and coefs in tmp file
  ncks -A -v ppt TerraClimate${climate}.nc  tmp${climate}.nc
  ncks -A -v absmin,alpha,gamma coefs${climate}.nc tmp${climate}.nc
  ncks -A -v annual_ppt TerraClimate${climate}.nc tmp${climate}.nc

  # compute required irrigation
  ncap2 -O -s '
  irrig_mo=46.06093-ppt;
  where(alpha<0)irrig_mo=0;
  where(gamma<0)irrig_mo=0;
  where(absmin<-10)irrig_mo=0;
  irrig_y=irrig_mo.total($time);
  irrig_mo_rockmulch=46.06093-1.83*ppt;
  where(alpha<0)irrig_mo_rockmulch=0;
  where(gamma<0)irrig_mo_rockmulch=0;
  where(absmin<-10)irrig_mo_rockmulch=0;
  irrig_y_rockmulch=irrig_mo_rockmulch.total($time);
  irrig_y_rockmulch_arid=irrig_y_rockmulch;
  where(annual_ppt>400)irrig_y_rockmulch_arid=0;
  where(annual_ppt>400)irrig_y_rockmulch=irrig_y;
  ' tmp${climate}.nc irrig${climate}.nc
  rm tmp${climate}.nc


done

##########################
##Combine Biomass Files ##
##########################

## Rename variables
### biomass
#ncrename -v biomass,biomass2C biomass2C.nc
ncrename -v biomass,biomass4C            biomass4C.nc
ncrename -v biomass2,biomass4C_irrig     biomass4C.nc
ncrename -v biomass2,biomass_irrig       biomass19812010.nc
ncrename -v biomass3,biomass4C_rockmulch biomass4C.nc
ncrename -v biomass3,biomass_rockmulch   biomass19812010.nc

# compute required irrigation
## db: difference b/w rockmulck and non-irrigated;
##     set to 0 when ppt<400 or db <0.1
ncap2 -O -s '
db                       = biomass_rockmulch - biomass;
db4C                     = biomass4C_rockmulch - biomass4C;
biomass_rockmulch_arid   = biomass;
biomass4C_rockmulch_arid = biomass4C;
where(db < 0.1)           biomass_rockmulch_arid   = 0;
where(annual_ppt > 400)   biomass_rockmulch_arid   = 0;
where(db4C < 0.1)         biomass4C_rockmulch_arid = 0;
where(annual_ppt4C > 400) biomass4C_rockmulch_arid   = 0;
' tmp.nc out.nc
ncks -A -v biomass_rockmulch_arid,biomass4C_rockmulch_arid out.nc allbiomass.nc

rm tmp.nc out.nc

## end profiling
set +x
exec 2>&3 3>&-

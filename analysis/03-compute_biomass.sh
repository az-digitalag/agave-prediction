#!/usr/bin/env bash

#for climate in 19812010 2C 4C ; do
for climate in 19812010 4C; do
  echo "starting calculations for ${climate} climate"

#  rm TerraClimate${climate}.nc
#  cp ../raw_data/TerraClimate${climate}_ppt.nc TerraClimate${climate}.nc
#  ncks -A ../raw_data/TerraClimate19812010_srad.nc TerraClimate${climate}.nc
#  ncks -A ../raw_data/TerraClimate${climate}_tmin.nc TerraClimate${climate}.nc

  # Compute PAR
#  ncap2 -O -s "par=5.6925*srad" TerraClimate${climate}.nc par${climate}.nc


  # Compute min Tmin over year
#  ncwa -O -v tmin -y min -a time TerraClimate${climate}.nc mintmin${climate}.nc

  # Compute absmin

#  ncks -A ../raw_data/coldestadj_tmin.nc mintmin${climate}.nc
#  ncap2 -O -s "absmin=tmin-adjustC" mintmin${climate}.nc absmin${climate}.nc

  # add absmin tp
  ncks -A --no_tmp_fl -v absmin absmin${climate}.nc par${climate}.nc

  # Compute coeficients with min/max
  ncap2 -O -s "
  alpha=-7e-07*par^2+0.0016*par-0.001;
  where(alpha<0)alpha=0;
  where(alpha>1)alpha=1;
  beta=0.0279*ppt-0.2851;
  beta2=1;
  beta3=1.83*0.0279*ppt-0.2851;
  where(beta<0)beta=0;
  where(beta>1)beta=1;
  where(beta3<0)beta3=0;
  where(beta3>1)beta3=1;
  gamma=-2.2533e-07*absmin^5+1.3437e-05*absmin^4+-1.6899e-04*absmin^3+-3.8746e-3*absmin^2+0.10527*absmin+0.35194;
  where(gamma<0)gamma=0;
  where(gamma>1)gamma=1;" par${climate}.nc coefs${climate}.nc

  # compute monthly epi
  ncap2 -O -v -s "
  epi=alpha*beta*gamma;
  epi2=alpha*beta2*gamma;
  epi3=alpha*beta3*gamma" coefs${climate}.nc epi${climate}.nc

  # compute total epi and min(tmin)
  ncap2 -O  -v -s '
  episum=epi.total($time);
  episum2=epi2.total($time);
  episum3=epi3.total($time)' epi${climate}.nc episum${climate}.nc #31s


  # sum epi over all months
  ncks -A -v absmin absmin${climate}.nc episum${climate}.nc #21s

  # compute biomass; set to 0 if biomass<0 or absmin<-10
  # equation for five years: biomass=5 * episum * 1.7607 - 14.774
  ncap2 -v -s "
  biomass=episum * 1.7607 - 2.9548 ;where(biomass<0.0)biomass=0.0; where(absmin< -10.0)biomass=0.0;
  biomass2=episum2 * 1.7607 - 2.9548 ;where(biomass2<0.0)biomass2=0.0; where(absmin< -10.0)biomass2=0.0;
  biomass3=episum3 * 1.7607 - 2.9548 ;where(biomass3<0.0)biomass3=0.0; where(absmin< -10.0)biomass3=0.0" episum${climate}.nc biomass${climate}.nc

done

#############################
##Irrigation Required      ##
#############################

# scenario 1: irrigated assuming 553mm is replete
# scenario 2 (irrig2): with rock mulch


# assuming rocks increase water availability by 83%

for climate in 19812010 4C ; do
  # sum precip over year
  ncwa -O -v ppt -y ttl -a time TerraClimate${climate}.nc annualprecip${climate}.nc
  # find irrigation amount
  ncap2 -v -s "irrig=553-ppt;where(irrig<0.0)irrig=0.0;irrig2=553-1.83*ppt;where(irrig2<0.0)irrig2=0.0" annualprecip${climate}.nc irrig${climate}.nc
done

#############################
##Fix Variables & Metadata ##
#############################


#########################
##Subset US Southwest  ##
#########################

ncks -O -d lat,32.5,35.0 -d lon,-120.0,-110.0 par${climate}.nc par_az${climate}.nc

##########################
##Combine Biomass Files ##
##########################

## Rename variables
### biomass
#ncrename -v biomass,biomass2C biomass2C.nc
ncrename -v biomass,biomass4C biomass4C.nc
ncrename -v biomass2,biomass4Cirrig biomass4C.nc
ncrename -v biomass2,biomass_irrig biomass19802010.nc

## update metadata http://nco.sourceforge.net/nco.html#ncatted-netCDF-Attribute-Editor


ncks -O -v biomass biomass19802010.nc allbiomass.nc
#ncks -A -v biomass2c biomass2C.nc allbiomass.nc
ncks -A -v biomass4C biomass4C.nc allbiomass.nc
ncks -A -v biomass4Cirrig biomass4C.nc allbiomass.nc
ncks -A -v biomass_irrig biomass19802010.nc allbiomass.nc

ncap2 -O -v -s 'biomassdiff=biomass4C-biomass' allbiomass.nc biomassdiff.nc

ncap2 -A -v -s 'biomassdiffirrig=biomass4Cirrig-biomass_irrig' allbiomass.nc biomassdiff.nc

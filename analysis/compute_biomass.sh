
# Compute PAR
cd data/derived_data/
ncap2 -s "par=5.6925*srad" TerraClimate19812010.nc par19812010.nc

# Compute min Tmin over year
ncap2 -O -v -s "tmin=tmin.min($time)" par19812010.nc mintmin19812010.nc

# Compute coeficients with min/max
ncap2 -v -s "alpha=-7e-07*par^2+0.0016*par-0.001;beta=0.0279*ppt-0.2851;gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;where(alpha<0)alpha=0;where(beta<0)beta=0;where(gamma<0)gamma=0;where(alpha>1)alpha=1;where(beta>1)beta=1;where(gamma>1)gamma=1;" par19812010.nc coefs19812010.nc


# add tmin to epi
ncks -v tmin par19812010.nc epi19812010.nc

ncap2 -v -s "epi=alpha*beta*gamma" coefs19812010.nc epi19812010.nc

# add tmin to epi
ncks -A -v tmin par19812010.nc epi19812010.nc

# compute total epi and min(tmin)
ncap2 -v -s 'episum=epi.total($time);mintmin=tmin.min($time)' epi19812010.nc episum19812010.nc


# compute biomass; set to 0 if biomass<0 or min(Tmin)<-10
ncap2 -v -s 'biomass=5 * episum * 1.7607 - 14.774;where(biomass<0)biomass=0; where(mintmin<-10)biomass=0' episum19812010.nc biomass19812010.nc

############
##---4C---##
############


ncap2 -s "par=5.6925*srad" TerraClimate4C.nc par4C.nc

# Compute min Tmin over year
ncap2 -O -v -s "tmin=tmin.min($time)" par4C.nc mintmin4C.nc


# obsolete? Compute coeficients
#ncap2 -v -s "alpha=-7e-07*par^2+0.0016*par-0.001;beta=0.0279*ppt-0.2851;gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;" par4C.nc coefs4C.nc


# Compute coeficients with min/max
ncap2 -v -s "alpha=-7e-07*par^2+0.0016*par-0.001;beta=0.0279*ppt-0.2851;gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;where(alpha<0)alpha=0;where(beta<0)beta=0;where(gamma<0)gamma=0;where(alpha>1)alpha=1;where(beta>1)beta=1;where(gamma>1)gamma=1;" par4C.nc coefs4C.nc


# add tmin to epi
ncks -v tmin par4C.nc epi4C.nc

ncap2 -O -v -s "epi=alpha*beta*gamma" coefs4C.nc epi4C.nc

# add tmin to epi
ncks -A -v tmin par4C.nc epi4C.nc

# compute total epi and min(tmin)
ncap2 -v -s 'episum=epi.total($time);mintmin=tmin.min($time)' epi4C.nc episum4C.nc


# compute biomass; set to 0 if biomass<0 or min(Tmin)<-10
ncap2 -v -s 'biomass=5 * episum * 1.7607 - 14.774;where(biomass<0)biomass=0; where(mintmin<-10)biomass=0' episum4C.nc biomass4C.nc


##########
##--2C--##
##########


ncap2 -s "par=5.6925*srad" TerraClimate2C.nc par2C.nc

# Compute min Tmin over year
ncap2 -O -v -s "tmin=tmin.min($time)" par2C.nc mintmin2C.nc


# obsolete? Compute coeficients
#ncap2 -v -s "alpha=-7e-07*par^2+0.0016*par-0.001;beta=0.0279*ppt-0.2851;gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;" par2C.nc coefs2C.nc


# Compute coeficients with min/max
ncap2 -v -s "alpha=-7e-07*par^2+0.0016*par-0.001;beta=0.0279*ppt-0.2851;gamma=-2.2533e-07*tmin^5+1.3437e-05*tmin^4+-1.6899e-04*tmin^3+-3.8746e-3*tmin^2+0.10527*tmin+0.35194;where(alpha<0)alpha=0;where(beta<0)beta=0;where(gamma<0)gamma=0;where(alpha>1)alpha=1;where(beta>1)beta=1;where(gamma>1)gamma=1;" par2C.nc coefs2C.nc


# add tmin to epi
ncks -v tmin par2C.nc epi2C.nc

ncap2 -v -s "epi=alpha*beta*gamma" coefs2C.nc epi2C.nc

# add tmin to epi
ncks -A -v tmin par2C.nc epi2C.nc

# compute total epi and min(tmin)
ncap2 -O -v -s 'episum=epi.total($time);mintmin=tmin.min($time)' epi2C.nc episum2C.nc


# compute biomass; set to 0 if biomass<0 or min(Tmin)<-10
ncap2 -v -s 'biomass=5 * episum * 1.7607 - 14.774;where(biomass<0)biomass=0; where(mintmin<-10)biomass=0' episum2C.nc biomass2C.nc


##########################
##Combine Biomass Files ##
##########################

ncrename -v biomass,biomass2C biomass2C.nc
ncrename -v biomass,biomass4C biomass4C.nc

ncks -A -v biomass biomass19802010.nc allbiomass.nc
ncks -A -v biomass2c biomass2C.nc allbiomass.nc
ncks -A -v biomass4c biomass4C.nc allbiomass.nc

ncap2 -v -s 'biomassdiff=biomass4c-biomass' allbiomass.nc biomassdiff.nc


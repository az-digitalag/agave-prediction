# for the terraclimate dataset, subset points that are on land
library(ncdf4)
library(sf)
library(spData)

nc <- nc_open("data/raw_data/TerraClimate19611990_ppt.nc")
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")
latlon <- expand.grid(lat, lon)
colnames(latlon) <- c('lat', 'lon')

readr::write_csv(latlon, 'data/derived_data/land_latlon.csv')
#pts <- st_as_sf(latlon, coords=1:2, crs=4326)

#ii <- !is.na(as.numeric(st_intersects(pts, world)))
#land <- latlon[ii,]
#readr::write_csv(land, 'data/derived_data/land_latlon.csv')

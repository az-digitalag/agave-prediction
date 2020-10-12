library(tidync)
library(ncdf4)
library(lubridate)
library(dplyr)
library(RSQLite)

## Setup
climate_nc <- nc_open("data/derived_data/TerraClimate19812010.nc")
lons <- ncvar_get(climate_nc, "lon")
lats <- ncvar_get(climate_nc, "lat")
times <- ncvar_get(climate_nc, "time")
months <- rank(times)


# dims <- climate_nc$dim
# dims$time <- NULL
# dims$month <- ncdim_def(name = 'month',
#                         longname = 'Month of year',
#                         units = 'calendar month',
#                         vals = 1:12,
#                         unlim = FALSE)

epivar <- ncvar_def('epi', 'none', dim = nc$dim, longname = 'Environmental Productivity Index')

epi <- nc_create('data/derived_data/epi19812020.nc', vars = epivar)

for(lat in lats){
  for(lon in lons){
    ppt <- ncvar_get(climate_nc, varid = 'ppt', start = c(1, 1, 1), count = c(1, 1, 12))

    ncvar_get()
  }
}

climate_sqlite <- dbConnect(RSQLite::SQLite(), dbname = 'data/derived_data/climate_tables.sqlite3')

lats <- unique(latlon$lat)
lons <- unique(latlon$lon)

# Move climate variables from .nc to .sqlite3
## Minimum Temperature
tmin <- tidync::tidync('data/raw_data/TerraClimate19812010_tmin.nc')

tminsubset <- tmin %>%
  hyper_filter(lat = lat %in% lats, lon = lon %in% lons) %>%
  hyper_tibble() %>%
  collect() %>%
  dplyr::mutate(month = month(ymd('1901-01-01') + days(time)))

dbWriteTable(climate_sqlite, 'tmin', tminsubset, overwrite = TRUE)

rm(tmin, tminsubset)

## Precipitation
ppt <-  tidync::tidync("data/raw_data/TerraClimate19812010_ppt.nc")

pptsubset <- ppt %>%
  hyper_filter(lat = lat %in% lats , lon = lon %in% lons) %>%
  hyper_tibble() %>%
  collect() %>%
  dplyr::mutate(month = month(ymd('1901-01-01') + days(time)))

dbWriteTable(climate_sqlite, 'ppt', pptsubset, overwrite = TRUE)
# readr::write_csv(pptsubset, 'data/derived_data/ppt.csv')
rm(ppt, pptsubset)

## Solar Radiation
srad <- tidync::tidync('data/raw_data/TerraClimate19812010_srad.nc')

sradsubset <- srad %>%
  hyper_filter(lat = lat %in% lats, lon = lon %in% lons) %>%
  hyper_tibble() %>%
  collect() %>%
  dplyr::mutate(month = month(ymd('1901-01-01') + days(time)))

dbWriteTable(climate_sqlite, 'srad', sradsubset, overwrite = TRUE)
#readr::write_csv(sradsubset, 'data/derived_data/srad.csv')
rm(srad, sradsubset)

#---Index, Create Climate Table

# index_join.sql
#ppt <- readr::read_csv('data/derived_data/ppt.csv')
#srad <- readr::read_csv('data/derived_data/srad.csv')
#tmin <- readr::read_csv('data/derived_data/tmin.csv')

ppt <- dplyr::tbl(climate_sqlite, "ppt")
srad <- dplyr::tbl(climate_sqlite, "srad")
tmin <- dplyr::tbl(climate_sqlite, "tmin")

climate <- ppt %>%
  inner_join(srad, by = c('lat', 'lon', 'time')) %>%
  inner_join(tmin, by = c('lat', 'lon', 'time'))

#readr::write_csv(climate, 'data/derived_data/climate.csv')

dbWriteTable(climate_sqlite, 'climate', climate, overwrite = TRUE)

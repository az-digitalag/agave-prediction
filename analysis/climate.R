library(tidync)
library(ncdf4)
library(lubridate)
library(dplyr)
library(RSQLite)


nc <- nc_open("data/raw_data/TerraClimate19611990_ppt.nc")
lon <- ncvar_get(nc, "lon")
lat <- ncvar_get(nc, "lat")
latlon <- expand.grid(lat, lon)
colnames(latlon) <- c('lat', 'lon')

latlon %<>%
  filter(lat > 30 & lat < 35) %>%
  filter(lon < -110 & lon > -115)

lats <- unique(latlon$lat)
lons <- unique(latlon$lon)

tmin <- tidync::tidync('data/raw_data/TerraClimate19611990_tmin.nc')

tminsubset <- tmin %>%
  hyper_filter(lat = lat %in% lats, lon = lon %in% lons) %>%
  hyper_tibble()
readr::write_csv(tminsubset, 'data/derived_data/tmin.csv')

## summarize by month and subset locations where min monthly temperature is -10C


ppt <-  tidync::tidync("data/raw_data/TerraClimate19611990_ppt.nc")

pptsubset <- ppt %>%
  hyper_filter(lat = lat %in% lats , lon = lon %in% lons) %>%
  hyper_tibble()

readr::write_csv(pptsubset, 'data/derived_data/ppt.csv')

srad <- tidync::tidync('data/raw_data/TerraClimate19812010_srad.nc')

sradsubset <- srad %>%
  hyper_filter(lat = lat %in% lats, lon = lon %in% lons) %>%
  hyper_tibble()

readr::write_csv(sradsubset, 'data/derived_data/srad.csv')

ppt <- readr::read_csv('data/derived_data/ppt.csv')
srad <- readr::read_csv('data/derived_data/srad.csv')
tmin <- readr::read_csv('data/derived_data/tmin.csv')
climate <- ppt %>%
  inner_join(srad, by = c('lat', 'lon', 'time')) %>%
  inner_join(tmin, by = c('lat', 'lon', 'time')) %>%
  dplyr::mutate(month = month(ymd('1901-01-01') + days(time)))

readr::write_csv(climate, 'data/derived_data/climate.csv')

db <- dbConnect(RSQLite::SQLite(), dbname = 'data/derived_data/climate.sqlite3')
dbWriteTable(db, 'climate', climate, overwrite = TRUE)

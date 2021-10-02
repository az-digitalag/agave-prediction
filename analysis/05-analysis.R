library(raster)
library(sf)
library(exactextractr)
library(fasterize)
library(ggplot2)
library(ggspatial)

# https://datacarpentry.org/r-raster-vector-geospatial/11-vector-raster-integration/index.html

not_suitable_polygons <- st_read('data/derived_data/not_suitable.gpkg')

all_biomass_file <-'data/derived_data/allbiomass.nc'


vars <- c('biomass',
          'biomass4C',
          'biomass_irrig',
          'biomass4C_irrig',
          'biomass_rockmulch',
          'biomass4C_rockmulch',
          'biomass_rockmulch_arid',
          'biomass4C_rockmulch_arid')



rasters <- lapply(vars, function(x) raster(all_biomass_file, varname = x))

not_suitable_raster <- fasterize(not_suitable_polygons, rasters[[1]])

mymask <- function(raster){
  varname <- names(raster)
  raster[raster == 0] <- NA
  r <- mask(raster, not_suitable_raster,
            inverse = TRUE,
            filename = paste0('data/derived_data/masked_',varname,'.nc'),
            format = 'CDF',
            overwrite = TRUE)

}

masked_rasters <- lapply(rasters, mymask)

lapply(masked_rasters, function(x) cellStats(x, 'max'))


get_area <- function(x){
  cellStats(area(x, na.rm = TRUE), 'sum')
}

library(udunits2)

get_biomass <- function(x){
  # calculate area and convert x 100 ha / km2: udunits2::ud.convert(1, 'km2', 'ha')
  area_ha <- area(x, na.rm = TRUE) * 100
  # multiply biomass production rate (Mg/ha/y) by area (km2)
  biomass_per_year <- x * area_ha
  cellStats(biomass_per_year, 'sum')
}

area_biomass_summary <- lapply(
  masked_rasters,
  function(x) {
    x3 <- reclassify(x, cbind(0, 3, NA))
    x10 <- reclassify(x, cbind(0, 10, NA))
    list(growing_area = get_area(x),
         growing_area_gt3 = get_area(x3),
         growing_area_gt10 = get_area(x10),
         biomass = get_biomass(x),
         biomass_gt3 = get_biomass(x3),
         biomass_gt10 = get_biomass(x10))
  })

readr::write_csv(cbind(scenario = vars, dplyr::bind_rows(area_biomass_summary)),
                 file = 'data/derived_data/area_biomass_summary.csv')

masked_dfs <- lapply(masked_rasters, function(x){
  x_small <- aggregate(x, 4)
  x_df <- as.data.frame(as(x_small, "SpatialPixelsDataFrame"))
  return(x_df)
})
library(ggmap)
library(rnaturalearth)
world <- ne_countries(scale = "medium", returnclass = "sf")

r <- aggregate(masked_rasters[[1]], fact = 4)
system.time(
  ggplot() + layer_spatial(r)
)
coastlines <- rnaturalearth::ne_coastline(scale = "large", returnclass = "sf")

ggplot(data = coastlines) +
  geom_sf() +
  theme_bw() +
  geom_tile(data = masked_dfs[[1]], mapping = aes(x = x, y = y, fill = biomass)) +
  scale_color_viridis_c()

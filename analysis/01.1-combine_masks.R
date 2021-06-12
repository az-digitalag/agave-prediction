library(sf)
library(dplyr)
library(rnaturalearth)
#library(ggplot2)
setwd('../')
### World land surface

# https://github.com/ropensci/rnaturalearth

#devtools::install_github('ropensci/rnaturalearthhires')
# coastlines <- ne_coastline(scale = "large", returnclass = "sf")

urban_areas <- ne_download(scale = 'large', type = 'urban_areas', returnclass = 'sf')

### WDPA Protected Areas
# wdpa_protected_areas <- list.files('analysis/data/raw_data/WDPA_WDOECM_Apr2021/',
#                                    full.names = TRUE,
#                                    recursive = TRUE,
#                                    pattern = 'shp$')
# protected_areas_list <- lapply(wdpa_protected_areas, st_read)
# protected_areas <- do.call(what = sf:::rbind.sf, args = protected_areas_list)
# protected_areas <- st_union(protected_areas)
#
#
# st_write(protected_areas, 'analysis/data/derived_data/wpda.gpkg')

protected_areas <- st_read('analysis/data/derived_data/wpda.gpkg')

attributes(protected_areas)
# st_write(protected_areas, 'analysis/data/derived_data/wpda.geojson')

# ### Ecoregions
#
# udvardy <- st_read('analysis/data/raw_data/udvardy_ecoregions/udvardy.shp')
# st_write(udvardy, 'analysis/data/derived_data/udvardy.gpkg')
#
# unsuitable_biomes <- udvardy %>%
#   filter(BIOMENAME %in% c("Tundra communities",
#                           "Temperate broad-leaf forests",
#                           "Temperate needle-leaf forests / Woodlands",
#                           "Lake systems",
#                           "Mixed mountain systems",
#                           "Sub-tropical / Temperate rain forests / Woodlands",
#                           #"Temperate grasslands",
#                           "Cold-winter deserts",
#                           #"Evergreen Sclerophyllous forests",
#                           #"Mixed island systems",
#                           #"Warm deserts / semi-deserts",
#                           "Tropical dry forests / Woodlands",
#                           "Tropical humid forests"#,
#                           #"Tropical grasslands / Savannas"
#                           ))

## Combine into non-growing regions

urban_areas <- st_union(urban_areas)
not_suitable <- st_union(protected_areas, urban_areas)
st_write(not_suitable, 'analysis/data/derived_data/not_suitable.gpkg')


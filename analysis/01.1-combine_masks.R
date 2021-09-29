library(sf)
library(dplyr)
library(rnaturalearth)
library(rnaturalearthhires)

### World land surface

urban_areas <- ne_download(scale = 'large', type = 'urban_areas', returnclass = 'sf')

### WDPA Protected Areas

wdpa_protected_areas <- list.files('analysis/data/raw_data/WDPA_WDOECM_Apr2021/',
                                   full.names = TRUE,
                                   recursive = TRUE,
                                   pattern = 'shp$')
protected_areas_list <- lapply(wdpa_protected_areas, st_read)
protected_areas <- do.call(what = sf:::rbind.sf, args = protected_areas_list)
protected_areas <- st_union(protected_areas)

#### Write out

## code to write out / read in
# st_write(protected_areas, 'analysis/data/derived_data/wpda.gpkg')
# protected_areas <- st_read('analysis/data/derived_data/wpda.gpkg')

urban_areas <- st_union(urban_areas)
not_suitable <- st_union(protected_areas, urban_areas)
st_write(not_suitable, 'analysis/data/derived_data/not_suitable.gpkg')


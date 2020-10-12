# Potential crop biomass from Agave americana predicted for each grid cell
# using the EPI model developed by Niechayev et al. (2018)
# with parameters specified according to monthly climate variables
# (radiation, temperature, and precipitation) for the respective location.
# Each environmental index that is required to estimate the total EPI over
# the life of the crop was calculated on a monthly time step.

# The light index (α) was calculated as
library(dplyr)
library(dbplyr)
library(RSQLite)

db <- DBI::dbConnect(RSQLite::SQLite(), dbname = 'data/derived_data/climate_tables.sqlite3')
climate <- dplyr::tbl(db, "climate")

bound <- function(x, a = 0, b = 1) max(a, min(b, x))


irrigation <- 0#500

epi <- climate %>%
  group_by(lat, lon, month) %>%
  mutate(par =  2.875 * srad * 110 / 1000 * 18) %>%
  mutate(
    alpha =
       -7e-07 * par^2 +
        0.0016 * par -
        0.001,
    beta  =
        0.0279 * ppt -
        0.2851,
    gamma =
       -2.2533e-07 * tmin^5 +
        1.3437e-05 * tmin^4 +
       -1.6899e-04 * tmin^3 +
       -3.8746e-3  * tmin^2 +
        0.10527    * tmin   +
        0.35194) %>%
  filter(alpha > 0 & alpha <= 1 & beta > 0 & beta <= 1 & gamma > 0 & gamma <= 1) %>%
  mutate(epi = alpha * beta * gamma)


annual <- epi %>%
  group_by(lat, lon) %>%
  summarise(episum = sum(epi),
            ppt = sum(ppt),
            tmin = min(tmin),
            par = mean(par))

biomass <- annual %>%
  mutate(biomass = 5 * episum * 1.7607 - 14.774) %>%
  select(lat, lon, biomass) %>%
  filter(biomass > 0)

b <- biomass %>%
  select(lat, lon, biomass) %>%
  collect()

# biomass_sqlite <- dbConnect(RSQLite::SQLite(), dbname = 'data/derived_data/biomass.sqlite3')
# dplyr::copy_to(biomass_sqlite,
#                df = b,
#                name = 'biomass',
#                temporary = FALSE,
#                indexes = list("lat", "lon"),
#                overwrite = TRUE)


readr::write_csv(b, 'data/derived_data/biomass.csv')
#
# summary(f)
# range(e$epi)
#
# library(maps)
# library(ggplot2)
# map <- map_data("state") %>%
#   filter(region == 'arizona')
#
# counties <- map_data("county") %>%
#   subset(region == "arizona")
#
# ggplot() +
#   geom_polygon(data = counties, color = 'darkgrey', fill = 'white', aes(x = long, y = lat, group = group)) +
#   #geom_polygon(data = map, color = 'black', fill = 'white', aes(x = long, y = lat, group = region)) +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = biomass), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7)), limits = c(0, 50)) +
#   labs(fill = 'Biomass (Mg/ha-1)') +
#   theme_bw()
#
# ggplot() +
#   stat_density2d_filled(data = f, aes(x = lon, y = lat, fill = biomass), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7)), limits = c(0, 50)) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group)) +
#   labs(fill = 'Biomass (Mg/ha-1)')
#
# theme_set(theme_bw())
# ggplot(data = e) +
#   geom_point(aes(x = par, y = alpha)) +
#   ylim(0,1)
#
# ggplot(data = e) +
#   geom_point(aes(x = ppt, y = beta)) +
#   ylim(0,1)
#
# ggplot(data = e) +
#   geom_point(aes(x = tmin, y = gamma)) +
#   ylim(0,1)
#
# ggplot() +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = biomass), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7))) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))
#
# ggplot() +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = par), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7))) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))
#
# ggplot() +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = ppt), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7))) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))
#
# ggplot() +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = tmin), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7))) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))
#
# ggplot() +
#   geom_tile(data = f, aes(x = lon, y = lat, fill = epi), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7))) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))
#
# e <- climate %>%
#   collect() %>%
#   dplyr::rowwise() %>%
#   mutate(epi = epi_month(srad, ppt, tmin))
#
# biomass <- e %>%
#   group_by(lat, lon) %>%
#   summarise(z = sum(epi)*5*1.7607-14.774)
#
# range(biomass$z)
#
# ##--- check indices
# ggplot() +
#   geom_tile(data = mean_indices, aes(x = lon, y = lat, fill = alpha), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7)), limits = c(0, 1)) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group)) +
#   labs(fill = 'mean alpha')
#
#
# ggplot() +
#   geom_tile(data = mean_indices, aes(x = lon, y = lat, fill = beta), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7)), limits = c(0, 1)) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))+
#   labs(fill = 'mean beta')
#
# ggplot() +
#   geom_tile(data = mean_indices, aes(x = lon, y = lat, fill = gamma), alpha = 0.5) +
#   scale_fill_gradientn(colours = rev(rainbow(7)), limits = c(0, 1)) +
#   geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))+
#   labs(fill = 'mean gamma')
#
# ggplot(data = e %>% filter(lat == 34.97917 && lon == -114.9792)) +
#   geom_point(aes(x = month, y = tmin)) +
#   ylim(0,1)

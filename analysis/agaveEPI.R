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

db <- DBI::dbConnect(RSQLite::SQLite(), dbname = 'data/derived_data/climate.sqlite3')
climate <- dplyr::tbl(db, "climate")

epi_month <- function(srad, ppt, tmin){
  par <- srad * 110 / 1000 * 18
  # srad downward_shortwave_flux (W/m2)
  # par in umol m-2 s-1

  # par   <- 0.473 * srad
  # Papaioannou, Papanikolaou, and Retalis
  # Papaioannou, G., Papanikolaou, N. & Retalis, D.
  # Relationships of photosynthetically active radiation and shortwave irradiance.
  # Theor Appl Climatol 48, 23–27 (1993). https://doi.org/10.1007/BF00864910
  alpha <- -7e-07 * par^2 + 0.0016 * par - 0.0001
  beta  <- 0.0279 * min(600, ppt) - 0.2851
  gamma <- -0.2 * 1e-07 * tmin ^ 5
  # par is monthly average in umol m-2 s-1
  # ppt vector of monthly total precipitation (mm/month)
  # tmin is vector of mean daily min temp degrees C
  epi_month <- alpha * beta * gamma
  epi_month <- max(0, epi_month)
  return(epi_month)
}

biomass <- function(epi_month){
  biomass <- 5 * 1.7607 * sum(epi_month) - 14.774
  return(max(0, biomass))
}

bound <- function(x, a = 0, b = 1) max(a, min(b, x))

e <- climate %>%
  collect() %>%
  rowwise() %>%
  mutate(par = 1.98 * srad,
         alpha = -7e-07 * par^2 + 0.0016 * par - 0.001,
         beta  = 0.0279 * ppt - 0.2851,
         gamma = -0.2e-07 * tmin^5 +
           0.13e-4 * tmin^4 +
           -1.66e-4 * tmin^3 +
           -3.878e-3 * tmin^2 +
           0.1052 * tmin +
           0.352,
         epi = bound(alpha) * bound(beta) * bound(gamma))


f <- e %>%
  group_by(lat, lon) %>%
  summarise(biomass = bound(x = 5 * sum(epi) * 1.7607 - 14.774, a = 0, b = Inf),
            ppt = sum(ppt),
            tmin = min(tmin),
            par = mean(par),
            epi = sum(epi))

summary(f)
range(e$epi)

library(maps)
map <- map_data("state") %>%
  filter(region == 'arizona')

counties <- map_data("county") %>%
  subset(region == "arizona")

ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = biomass), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

theme_set(theme_bw())
ggplot(data = e) +
  geom_point(aes(x = par, y = alpha)) +
  ylim(0,1)

ggplot(data = e) +
  geom_point(aes(x = ppt, y = beta)) +
  ylim(0,1)

ggplot(data = e) +
  geom_point(aes(x = tmin, y = gamma)) +
  ylim(0,1)


ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = biomass), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = par), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = ppt), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = tmin), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

ggplot() +
  geom_tile(data = f, aes(x = lon, y = lat, fill = epi), alpha = 0.5) +
  scale_fill_gradientn(colours = rev(rainbow(7))) +
  geom_polygon(data = counties, color = 'white', fill = NA, aes(x = long, y = lat, group = group))

e <- climate %>%
  collect() %>%
  dplyr::rowwise() %>%
  mutate(epi = epi_month(srad, ppt, tmin))

biomass <- e %>%
  group_by(lat, lon) %>%
  summarise(z = sum(epi)*5*1.7607-14.774)

range(biomass$z)

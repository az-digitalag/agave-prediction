vars <- c('tmin','ppt', 'srad')
climates <- c('19812010', '2C', '4C')
URL <- "http://thredds.northwestknowledge.net:8080/thredds/fileServer/TERRACLIMATE_ALL/summaries/"
for(var in vars){
  for(climate in climates){
    filename <- paste0('TerraClimate', climate, '_',var,'.nc')
    varurl <- paste0(URL, filename)
    destfile <- file.path('data/raw_data/', filename)

    if(!(var == 'srad' & climate %in% c('2C', '4C'))){
       # srad doesn't change w/ climate
      if(!file.exists(destfile)){
        download.file(varurl,
                      destfile = destfile)
      }

    }
  }

}

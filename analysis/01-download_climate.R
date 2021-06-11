vars <- c('tmin','ppt', 'srad')
URL <- "http://thredds.northwestknowledge.net:8080/thredds/fileServer/TERRACLIMATE_ALL/summaries/TerraClimate19611990_VAR.nc"
for(var in vars){
  varurl <- gsub('VAR', var, URL)
  destfile <- paste0('data/raw_data/TerraClimate19812010_',var,'.nc')
#  if(!file.exists(destfile)){
    download.file(varurl,
                  destfile = destfile)
#  }
}

# Agave Prediction

This repository contains data and code for our paper:

Davis, ..., LeBauer: Expanded potential growing region for Agave americana with future climate

## Contents

The **[:file\_folder:analysis](/analysis)** directory contains:
   - [:page_facing_up:download_climate.R](/analysis/download_climate.R): Code to download data from TERRACLIMATE into `/analysis/data/raw_data`
   - [:page_facing_up:append_terraclimate.sh](/analysis/append_terraclimate.sh): Code to combine TERRACLIMATE layers and put into `/analysis/data/derived_data`
   - [:page_facing_up:compute_biomass.sh](/analysis/compute_biomass.sh): NCO code containing the Agave biomass model 
   - [:file\_folder:download_climate.R](/analysis/download_climate.R): Code to download data from TERRACLIMATE into /analysis/data/raw_data 
   - [:file\_folder:
    old_r_scripts](/analysis/old_r_scripts): Code from unsuccessful attempt to do the analysis in R / SQLite
  - [:file\_folder: data](/analysis/data): Data used in the analysis. This is empty but is populated by above scripts.
  - [:file\_folder: figures](/analysis/figures): Plots and other illustrations
    
Pardon the mess - this is the most I've used nco, and that was only after trying to import all the data into SQLite (which was about 100x slower until it broke). nco code is pretty rough and still contains files and variables with the wrong names.

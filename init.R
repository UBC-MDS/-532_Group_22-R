# File adapted from Heroku/Dashr demonstration repo by Joel Ostblom (https://github.com/UBC-MDS/dashr-heroku-deployment-demo)
#
# R script to run author supplied code, typically used to install additional R packages
# contains placeholders which are inserted by the compile script
# NOTE: this script is executed in the chroot context; check paths!

r <- getOption('repos')
r['CRAN'] <- 'http://cloud.r-project.org'
options(repos=r)

# ======================================================================

# packages go here
install.packages(c('dash', 'tidyverse', 'ggplot2', 'cowplot', 'here', 'ggthemes', 'remotes', 'spdplyr', 'leaflet'))
remotes::install_github('facultyai/dash-bootstrap-components@r-release')
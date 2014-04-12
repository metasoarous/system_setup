#!/usr/bin/env Rscript

packages <- c(
  'ggplot2',
  'argparse',
  'plyr',
  'dplyr',
  'ape',
  'devtools')

install.packages(packages)
library(devtools)

github.packages <- c('')
for (p in github.packages) {
  install_github(p)
}


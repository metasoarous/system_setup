#!/usr/bin/env Rscript

packages <- c(
  'ggplot2',
  'argparse',
  'optparse',
  'plyr',
  'dplyr',
  'reshape2',
  'ape',
  'devtools')

install.packages(packages)
suppressMessages(library(devtools))

github.packages <- c()
for (p in github.packages) {
  install_github(p)
}


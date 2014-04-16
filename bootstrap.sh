#!/usr/bin/env bash

sudo apt-get install git python scons

git clone https://github.com/metasoarous/system_setup.git
cd system_setup
scons

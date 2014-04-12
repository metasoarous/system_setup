#!/usr/bin/env bash

# If needed, install RVM
if [[ ! -d $HOME/.rvm ]]; then
  echo "Downloading and installing RVM"
  curl -L https://get.rvm.io | bash -s stable
  source $HOME/.rvm/scripts/rvm
  rvm autolibs enable
  rvm pkg install readline iconv curl openssl zlib autoconf ncurses pkgconfig gettext glib mono llvm libxml2 libxslt libyaml
fi

# Wether or not RVM has already been installed, make sure 1.9 and 2.1 are
source $HOME/.rvm/scripts/rvm
rvm install 1.9
rvm install 2.1

# Set default to 2.1
rvm use --default 2.1

# Here lie gems...
echo Now installing gems
gem install bundler \
  rails \
  cloudapp \
  rake


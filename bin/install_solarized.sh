#!/usr/bin/env bash

encap=/usr/local/encap
mkdir -p $encap
cd $encap

git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
git checkout d9fcb57

echo "XXXX - Make sure to enter 'yes' after selecting profile; there seems to be an scons bug here"
echo "But first enter 1 or 2"
./install.sh

cd $encap
ln -s ../encap/gnome-terminal-colors-solarized/set_dark.sh ../bin
ln -s ../encap/gnome-terminal-colors-solarized/set_light.sh ../bin
ln -s ../encap/gnome-terminal-colors-solarized/solarize ../bin


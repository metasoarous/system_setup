#!/usr/bin/env bash

encap=/usr/local/encap
mkdir -p $encap
cd $encap

git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./install.sh

cd $encap
ln -s ../encap/gnome_terminal_solarized/set_dark.sh -t ../bin
ln -s ../encap/gnome_terminal_solarized/set_light.sh -t ../bin
ln -s ../encap/gnome_terminal_solarized/solarize -t ../bin


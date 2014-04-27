#!/usr/bin/env bash

echo $HOME on the range
mkdir -p $HOME/encap
cd $HOME/encap
git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
cd gnome-terminal-colors-solarized
./install.sh
cd $HOME/encap
ln -s ../encap/gnome_terminal_solarized/set_dark.sh -t ../bin
ln -s ../encap/gnome_terminal_solarized/set_light.sh -t ../bin
ln -s ../encap/gnome_terminal_solarized/solarize -t ../bin


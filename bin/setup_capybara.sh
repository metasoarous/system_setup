#!/usr/bin/env bash

echo "Installing chromedriver for Capybara"
cd $HOME/src
wget http://chromedriver.googlecode.com/files/chromedriver_linux64_21.0.1180.4.zip
unzip chromedriver_linux64_21.0.1180.4.zip
sudo mv chromedriver /usr/local/bin


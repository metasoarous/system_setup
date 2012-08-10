
echo "Installing required packages using apt-get (you will be prompted for your password)"
sudo apt-get install `tr '\n' ' ' < package_list`

echo "Downloading and installing RVM"
if [[ ! -d $HOME/.rvm ]]; then
  curl -L https://get.rvm.io | bash -s stable
  source /home/cts/.rvm/scripts/rvm
  rvm pkg install readline iconv curl openssl zlib autoconf ncurses pkgconfig gettext glib mono llvm libxml2 libxslt libyaml
  rvm install 1.9.2
  rvm use --default 1.9.2
fi

echo "Setting up janus"
curl -Lo- https://bit.ly/janus-bootstrap | bash

echo "Setting up python goodness"
if [[ ! -d $HOME/bin ]]; then
  mkdir $HOME/bin
fi
cd $HOME/bin
curl -O https://raw.github.com/pypa/virtualenv/master/virtualenv.py
python virtualenv.py mainpy
. mainpy/bin/activate

echo "Installing csvkit and other goodies"
pip install csvkit

install_biosuite () {
  cd $HOME/lib
  git clone git://github.com/nhoffman/bioscons.git
  cd bioscons
  python setup.py install
  cd $HOME
  pip install nestly
}

echo "Installing biosuite"
install_biosuite

echo "Installing chromedriver for Capybara"
cd $HOME/src
wget http://chromedriver.googlecode.com/files/chromedriver_linux64_21.0.1180.4.zip
unzip chromedriver_linux64_21.0.1180.4.zip
sudo mv chromedriver /usr/local/bin


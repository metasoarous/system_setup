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

echo "Setting up pathogen and prefered packages"
# This should be updated whenever the gist in question is - a little hackish. Should probably clean this bit up...
curl -Lo- https://gist.github.com/metasoarous/4171118/raw/479a76d099ee1ef0fcd20d34e44b3fe16a2b1f1a/install_pathogen.sh | bash

echo "Installing chromedriver for Capybara"
cd $HOME/src
wget http://chromedriver.googlecode.com/files/chromedriver_linux64_21.0.1180.4.zip
unzip chromedriver_linux64_21.0.1180.4.zip
sudo mv chromedriver /usr/local/bin

echo "This stuff is probably broken - need to fix"

echo "Installing csvkit and other goodies"
pip install csvkit

echo "Installing biosuite"
cd $HOME/lib
git clone git://github.com/nhoffman/bioscons.git
cd bioscons
python setup.py install
cd $HOME
pip install nestly



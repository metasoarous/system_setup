
echo "Installing required packages using apt-get (you will be prompted for your password)"
sudo apt-get install `tr '\n' ' ' < package_list`

echo "Setting up janus"
curl -Lo- https://bit.ly/janus-bootstrap | bash

#echo "Installing gems"
#gem install `tr '\n' ' ' < gem_list`

echo "Downloading and installing RVM"
curl -L https://get.rvm.io | bash -s stable --rails
rvm use --default 1.9.2

echo "Setting up python goodness"
if [[ ! -d $HOME/bin ]] { mkdir $HOME/bin }
cd $HOME/bin
curl -O https://raw.github.com/pypa/virtualenv/master/virtualenv.py
python virtualenv.py pyenv

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

#echo "Do you want the bio suite?"
#select yn in "yes" "no"; do
  #case $yn in
    #yes ) install_biosuite;;
    #no ) exit;;
  #esac
#done

install_biosuite


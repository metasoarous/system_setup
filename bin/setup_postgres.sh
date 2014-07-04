
#From here - https://help.ubuntu.com/community/PostgreSQL

echo "About to run psql - you will have to enter \\password postgres and set password"
sudo -u postgres psql postgres

echo "Adding csmall-dev user for developing; You'll have to do the password trick again"
sudo -u postgres createuser dev -d
sudo -u postgres psql

echo "OK - now set up as many tablenames as you like running the following:"
echo "sudo -u postgres createdb -O dev tablename"
echo "Here are some for starters"

sudo -u postgres createdb -O dev metasoarous


#!/usr/bin/env bash

tmpdir=`mktemp -d`
cd $tmpdir
for d in http://archive.ubuntu.com/ubuntu/pool/main/l/launchpad-integration/liblaunchpad-integration-common_0.1.56.1_all.deb \
    http://archive.ubuntu.com/ubuntu/pool/universe/l/launchpad-integration/liblaunchpad-integration-3.0-1_0.1.56.2_amd64.deb \
    http://archive.ubuntu.com/ubuntu/pool/main/l/launchpad-integration/gir1.2-launchpad-integration-3.0_0.1.56_amd64.deb;
do
  curl $d > the.deb
  dpkg -i the.deb
done

cd /
rm -r $tmpdir

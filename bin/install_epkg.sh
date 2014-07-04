#!/usr/bin/env bash


epkg_link="ftp://ftp.encap.org/pub/encap/epkg/epkg-2.3.9.tar.gz"
TARGET=/usr/local/encap/epkg-2.3.9

mkdir -p /usr/local/encap
mkdir -p /usr/local/src
cd /usr/local/src
curl $epkg_link > epkg-2.3.9.tar.gz
zcat epkg-2.3.9.tar.gz | tar xvvpf -
cd epkg-2.3.9
./configure --prefix=$TARGET
make && make install && cd $TARGET/..

epkg-2.3.9/bin/epkg epkg


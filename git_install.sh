#!/bin/sh

yum -y remove git
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel

cd ~
wget https://www.kernel.org/pub/software/scm/git/git-2.2.0.tar.gz
tar zxf git-2.2.0.tar.gz
cd git-2.2.0
make prefix=/usr/local all
make prefix=/usr/local install

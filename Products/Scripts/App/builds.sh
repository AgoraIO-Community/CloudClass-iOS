#!/bin/sh

cd ../SDK

./buildFrameworks.sh

cd ../App

rm -fr ../../App

sh ./build.sh CertificateA
sh ./build.sh CertificateB
sh ./build.sh CertificateC
sh ./build.sh CertificateD
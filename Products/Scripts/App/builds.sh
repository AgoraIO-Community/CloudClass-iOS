#!/bin/sh
Certificate=$1

cd ../SDK

./buildFrameworks.sh

cd ../App

rm -fr ../../App

let "cer=$Certificate & 1"

if [ $cer -gt 0 ]
then
    echo ">>:CertificateA"

    sh ./build.sh CertificateA
fi

let "cer=$Certificate & 2"

if [ $cer -gt 0 ]
then
    echo ">>:CertificateB"

    sh ./build.sh CertificateB
fi

let "cer=$Certificate & 4"

if [ $cer -gt 0 ]
then
    echo ">>:CertificateC"

    sh ./build.sh CertificateC
fi

let "cer=$Certificate & 8"

if [ $cer -gt 0 ]
then
    echo ">>:CertificateD"

    sh ./build.sh CertificateD
fi

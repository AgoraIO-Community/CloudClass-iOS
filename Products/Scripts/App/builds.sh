#!/bin/sh
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

../SDK/buildFrameworks.sh

Array=(QARelease
       QATestRelease
       QATestNewRelease)

for Mode in ${Array[*]}
do
    ./build.sh ${Mode}
done
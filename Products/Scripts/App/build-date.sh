#!/bin/sh

time=$(date "+%Y.%m.%d")

filePath="../../../App/AgoraEducation/Main/Beans/BaseLoginObject.swift"

content="version_time:"

publishLine=`grep -n $content $filePath | cut -d ":" -f 1`

echo $publishLine

contentLine=$(($publishLine+1))

echo "contentLine: $contentLine"

sed -i '' "$contentLine s/return \".*\"/return \"$time\"/g" $filePath
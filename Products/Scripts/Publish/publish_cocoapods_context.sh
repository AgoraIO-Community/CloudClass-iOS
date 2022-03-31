#!/bin/sh
SDK_Version=$1

if [ ${#SDK_Version} -le 0 ]; then
    echo "parameter nil"
    exit -1
fi

SDK_Name="AgoraEduContext"

./publish_cocoapods.sh ${SDK_Name} ${SDK_Version}

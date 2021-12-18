#!/bin/sh
SDK_Version=$1

if [ ${#SDK_Version} -le 0 ]; then
    echo "parameter nil"
    exit -1
fi

SDK_Name="AgoraExtApps"
SDK_Path="../../../../open-apaas-extapp-ios/ExtApps/"

./publish_cocoapods.sh ${SDK_Name} ${SDK_Path} ${SDK_Version}

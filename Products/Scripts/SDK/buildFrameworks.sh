#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

# 下载大重构 SDK
#../../../../common-scene-sdk/iOS/ReRtc/download_libs.sh

Products_Path="../../Libs"
SDKs_Path="../../../SDKs"
dSYMs_iPhone="../../Libs/dSYMs_iPhone"
dSYMs_Simulator="../../Libs/dSYMs_Simulator"
Root_Path=`pwd`

rm -rf ${Products_Path}
mkdir ${Products_Path}

rm -rf ${dSYMs_iPhone}
mkdir ${dSYMs_iPhone}

rm -rf ${dSYMs_Simulator}
mkdir ${dSYMs_Simulator}

errorExit() {
    SDK_Name=$1
    Build_Result=$2

    if [ $Build_Result != 0 ]; then
        echo "SDK_Name: ${SDK_Name}"
        exit 1
    fi
    echo "build result: $Build_Result"
    echo "${SDK_Name} build success"
}

buildItem() {
    SDK_Name=$1
    
    echo "${Color} ======${SDK_Name} Start======== ${Res}"
    ./buildFramework.sh ${SDKs_Path}/AgoraBuilder ${SDK_Name} Release

    errorExit ${SDK_Name} $?
}

SDK_Name="AgoraClassroomSDK_iOS"

buildItem ${SDK_Name}

Files=$(ls ${Products_Path})

for FileName in $Files
do
    if [[ ! ${FileName} =~ "framework" ]]
    then
        continue
    elif [[ ! ${FileName} =~ "Agora" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "AgoraClassroomSDK" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "AgoraEduUI" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "AgoraEduContext" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "AgoraWidgets" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "AgoraLog" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    elif [[ ${FileName} =~ "Pods" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    fi
done

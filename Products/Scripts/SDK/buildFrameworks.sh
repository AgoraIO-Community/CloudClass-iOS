#!/bin/sh
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

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
    elif [[ ${FileName} =~ "Pods" ]]
    then
        rm -fr ${Products_Path}/${FileName}
    fi
done

iPhone_Path=${SDKs_Path}/AgoraBuilder/Build/product/derived_data/Build/Products/Release-iphoneos

cp -r ${iPhone_Path}/AgoraEduUI/AgoraEduUI.bundle ${Products_Path}
cp -r ${iPhone_Path}/AgoraWidgets/AgoraWidgets.bundle ${Products_Path}

# mkdir ${Products_Path}/EduUIResources
# mkdir ${Products_Path}/WidgetsResources

# cp -r ${SDKs_Path}/AgoraEduUI/AgoraEduUI/Assets/* ${Products_Path}/EduUIResources
# cp -r ../../../../open-apaas-extapp-ios/AgoraWidgets/AgoraResources/* ${Products_Path}/WidgetsResources
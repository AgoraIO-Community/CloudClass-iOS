#!/bin/bash
COLOR='\033[1;36m'
RES='\033[0m'

rm -rf Frameworks
mkdir Frameworks

Root_Path=`pwd`

cd Modules/BuildShell

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
    
    echo "${COLOR} ======${SDK_Name} Start======== ${RES}"
    ./build.sh ../${SDK_Name} ${SDK_Name} Release

    errorExit ${SDK_Name} $?
}

 buildItem "AgoraLog"
 buildItem "AgoraExtApp"
 buildItem "AgoraEduContext"
 buildItem "AgoraReport"

 buildItem "AgoraWhiteBoard"

 # 中班课
 buildItem "AgoraHandsUp"
 buildItem "AgoraActionProcess"
 
 buildItem "AgoraWidget"

 buildItem "AgoraUIBaseViews"
 buildItem "AgoraUIEduBaseViews"
 buildItem "AgoraUIEduAppViews"

 buildItem "EduSDK"
 buildItem "AgoraEduSDK"

# copy special bundle to frameworks folder
cd $Root_Path
cp -r  Modules/AgoraEduSDK/Build/product/derived_data/Build/Products/Release-iphoneos/AgoraEduSDK.bundle Frameworks

# 运行项目 demo


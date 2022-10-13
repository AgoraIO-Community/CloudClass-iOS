#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

SDK_Name=$1

SDKs_Path="../../../SDKs"
Products_Root_Path="../../Libs"
Products_Path="$Products_Root_Path/$SDK_Name"

if [ ! -d $Products_Root_Path ];then
    mkdir $Products_Root_Path
fi

rm -rf ${Products_Path}
mkdir ${Products_Path}

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

echo "${Color} ======${SDK_Name} Start======== ${Res}"

# current path is under Products/Scripts/SDK
./buildExecution.sh ${SDKs_Path}/AgoraBuilder ${SDK_Name} Release

errorExit ${SDK_Name} $?

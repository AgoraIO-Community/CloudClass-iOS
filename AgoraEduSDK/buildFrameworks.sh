#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

rm -rf Frameworks
mkdir Frameworks

Root_Path=`pwd`

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
    ./buildFramework.sh Modules/${SDK_Name} ${SDK_Name} Release

    errorExit ${SDK_Name} $?
}

buildItem "AgoraEduSDK"

# copy special bundle to frameworks folder
cd $Root_Path
cp -r  Modules/AgoraEduSDK/Build/product/derived_data/Build/Products/Release-iphoneos/AgoraEduSDK.bundle Frameworks

Frameworks_Folder="Frameworks"

Files=$(ls $Frameworks_Folder)

for FileName in $Files
do
    if [[ $FileName == "EduSDK.framework" ]]
    then
        continue
    elif [[ ! $FileName =~ "Agora" ]]
    then
        rm -fr $Frameworks_Folder/$FileName
    elif [[ $FileName =~ "Pods" ]]
    then
        rm -fr $Frameworks_Folder/$FileName
    fi
done

rm -rf dSYMs
mkdir dSYMs


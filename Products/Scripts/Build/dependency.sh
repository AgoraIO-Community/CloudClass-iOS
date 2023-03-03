#!/bin/bash

# Difference
# Dependency libs
# Widgets
# EduCore
# UIBaseViews
# Widget
Dep_Array_URL=("https://artifactory-api.bj2.agoralab.co/artifactory/AD_repo/Widgets_iOS/cavan/20230303/ios/AgoraWidgets_2.8.20_12.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/Edu_Core_iOS/cavan/20230302/ios/AgoraEduCore_2.8.20_9.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraUIBaseViews_2.8.0_82.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraWidget_2.8.0_82.zip")

Dep_Array=(AgoraWidgets 
           AgoraEduCore
           AgoraUIBaseViews 
           AgoraWidget)

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# parameters
Repo_Name=$1

startPrint "${Repo_Name} Download Dependency Libs"

parameterCheckPrint ${Repo_Name}

# path
Root_Path="../../.."

for SDK_URL in ${Dep_Array_URL[*]} 
do
    echo ${SDK_URL}
    python3 ${WORKSPACE}/artifactory_utils.py --action=download_file --file=${SDK_URL}
done

errorPrint $? "${Repo_Name} Download Dependency Libs"

echo Dependency Libs

ls

for SDK in ${Dep_Array[*]}
do
    Zip_File=${SDK}*.zip

    # move
    mv -f ./${Zip_File}  ${Root_Path}/

    # unzip
    ${Root_Path}/../apaas-cicd-ios/Products/Scripts/SDK/Build/v1/unzip.sh ${SDK} ${Repo_Name}
done

endPrint $? "${Repo_Name} Download Dependency Libs"
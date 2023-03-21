#!/bin/bash

# Difference
# Dependency libs
# Widgets
# EduCore
# UIBaseViews
# Widget
Dep_Array_URL=("https://artifactory-api.bj2.agoralab.co/artifactory/AD_repo/Widgets_iOS/cavan/20230303/ios/AgoraWidgets_2.8.20_12.zip"
               "https://artifactory-api.bj2.agoralab.co/artifactory/AD_repo/aPaaS/iOS/AgoraEduCore/Flex/dev/AgoraEduCore_2.8.30.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraUIBaseViews_2.8.0_82.zip"
               "https://artifactory.agoralab.co/artifactory/AD_repo/apaas_common_libs_ios/cavan/20230302/ios/AgoraWidget_2.8.0_82.zip")

Dep_Array=(AgoraWidgets 
           AgoraEduCore
           AgoraUIBaseViews 
           AgoraWidget)

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# parameters
Repo_Name=$1

# path
CICD_Repo_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Repo_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

${CICD_Scripts_Path}/SDK/Build/v1/dependency.sh "${Dep_Array_URL[*]}" "${Dep_Array[*]}" ${Repo_Name}
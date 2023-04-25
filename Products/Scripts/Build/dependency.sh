#!/bin/sh

# Difference
# Dependency libs
# Widgets
# EduCore
# UIBaseViews
# Widget
Artifactory_iOS_URL="https://artifactory.agoralab.co/artifactory/AD_repo/aPaaS/iOS"

AgoraWidgets_URL="${Artifactory_iOS_URL}/AgoraWidgets/Flex/dev/AgoraWidgets_2.8.30.zip"
AgoraEduCore_URL="${Artifactory_iOS_URL}/AgoraEduCore/Flex/dev/AgoraEduCore_2.8.30.zip"
AgoraUIBaseViews_URL="${Artifactory_iOS_URL}/AgoraUIBaseViews/Flex/dev/AgoraUIBaseViews_2.8.0.zip"
AgoraWidget_URL="${Artifactory_iOS_URL}/AgoraWidget/Flex/dev/AgoraWidget_2.8.0.zip"

Dep_Array_URL=("${AgoraWidgets_URL}"
               "${AgoraEduCore_URL}"
               "${AgoraUIBaseViews_URL}"
               "${AgoraWidget_URL}")

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
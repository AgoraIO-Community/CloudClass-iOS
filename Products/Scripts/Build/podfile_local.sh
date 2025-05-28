#!/bin/bash

# difference
# parameters
SDK_Name="AgoraClassroomSDK_Local"
Repo_Name="open-cloudclass-ios"

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# path
CICD_Root_Path="../../../../apaas-cicd-ios"
CICD_Products_Path="${CICD_Root_Path}/Products"
CICD_Scripts_Path="${CICD_Products_Path}/Scripts"

# Copy AgoraBuilder Xcode Project
./copy_agora_builder.sh

# build
${CICD_Scripts_Path}/SDK/Build/v1/podfile.sh ${SDK_Name} ${Repo_Name}
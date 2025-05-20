#!/bin/sh

# difference
SDK_Name="AgoraClassroomSDK_iOS"
Repo_Name="open-cloudclass-ios"

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# add originGithub
if git remote -v | grep -q 'originGithub'; then
    echo "originGithub exist"
else
    Git_Hub="git@github.com:AgoraIO-Community/CloudClass-iOS.git"

    git remote add originGithub ${Git_Hub}
fi

# path
CICD_Root_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Root_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

# publish
${CICD_Scripts_Path}/SDK/Publish/v1/publish_source_cocoapods.sh ${SDK_Name} ${Repo_Name}

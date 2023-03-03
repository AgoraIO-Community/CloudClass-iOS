#!/bin/bash
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# parameters
SDK_Name=$1
Repo_Name=$2

parameterCheckPrint ${SDK_Name}
parameterCheckPrint ${Repo_Name}

# path
CICD_Root_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Root_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

# build
${CICD_Scripts_Path}/SDK/Build/v1/build.sh ${SDK_Name} ${Repo_Name}
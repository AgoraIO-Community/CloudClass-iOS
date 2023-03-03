#!/bin/sh
# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# parameters
SDK_Name=$1
Repo_Name=$2
Build_Number=$3

startPrint "$SDK_Name Package Artificatory"

parameterCheckPrint ${SDK_Name}
parameterCheckPrint ${Repo_Name}

# path
CICD_Root_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Root_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

# pack
${CICD_Scripts_Path}/SDK/Pack/v1/package.sh ${SDK_Name} ${Repo_Name} ${Build_Number}

# upload
cd ../../../Package

python3 ${WORKSPACE}/artifactory_utils.py --action=upload_file --file=${SDK_Name}*.zip --project

endPrint $? "$SDK_Name Package Artificatory"

# remove
rm ${SDK_Name}*.zip
# difference
Repo_Name="open-cloudclass-ios"

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# import 
. ../../../../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# pramater
SDK_Name=$1
SDK_Version=$2

parameterCheckPrint ${SDK_Name}
parameterCheckPrint ${SDK_Version}

# path
CICD_Root_Path=../../../../apaas-cicd-ios
CICD_Products_Path=${CICD_Root_Path}/Products
CICD_Scripts_Path=${CICD_Products_Path}/Scripts

# publish
${CICD_Scripts_Path}/SDK/Publish/v1/delete_published_tag.sh ${SDK_Name} ${SDK_Version} ${Repo_Name}
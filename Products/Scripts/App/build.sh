#!/bin/sh
Mode=$1
Envi=$2
Project_Path="../../../App"
Local_Path=`pwd`

python cloud_pod.py 1 1
cd ${Project_Path}

Product_Path="../Products/App"
Plist_Path="../Products/Plists/exportPlist.plist"

if [ ! -d ${Product_Path} ];then
    mkdir ${Product_Path}
fi

xcodebuild -quiet clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration ${Mode}
xcodebuild -quiet archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration ${Mode} -archivePath ${Product_Path}/AgoraEducation_${Mode}.xcarchive
xcodebuild -quiet -exportArchive -exportOptionsPlist ${Plist_Path} -archivePath ${Product_Path}/AgoraEducation_${Mode}.xcarchive -exportPath ${Product_Path} || exit 1

mv ${Product_Path}/AgoraCloudClass.ipa ${Product_Path}/AgoraCloudClass_${Mode}.ipa

cp -r ${Product_Path}/AgoraEducation_${Mode}.xcarchive/dSYMs ${Product_Path}
mv ${Product_Path}/dSYMs ${Product_Path}/${Mode}_dSYMs

rm ${Product_Path}/Packaging.log
rm ${Product_Path}/ExportOptions.plist
rm ${Product_Path}/DistributionSummary.plist
rm -rf ${Product_Path}/AgoraEducation_${Mode}.xcarchive

#!/bin/sh
Mode=Release
Project_Path="../../../App"
Local_Path=`pwd`

cd ${Project_Path}

Product_Path="../Products/App"
Plist_Path="../Products/Plists/exportStorePlist.plist"

if [ ! -d ${Product_Path} ];then
    mkdir ${Product_Path}
fi

xcodebuild -quiet clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration ${Mode}
xcodebuild -quiet archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration ${Mode} -archivePath ${Product_Path}/AgoraEducation_${Mode}.xcarchive
xcodebuild -quiet -exportArchive -exportOptionsPlist ${Plist_Path} -archivePath ${Product_Path}/AgoraEducation_${Mode}.xcarchive -exportPath ${Product_Path}

mv ${Product_Path}/AgoraCloudClass.ipa ${Product_Path}/AgoraCloudClass_${Mode}.ipa
mv ${Product_Path}/AgoraCloudClass_${Mode}.ipa ${Product_Path}/AgoraEducation_${Mode}.xcarchive

rm ${Product_Path}/Packaging.log
rm ${Product_Path}/ExportOptions.plist
rm ${Product_Path}/DistributionSummary.plist

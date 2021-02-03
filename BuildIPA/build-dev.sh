#!/bin/sh
ArchivePath=AgoraEducationDev.xcarchive
IPAName="IPADEV"
Path="../"
PlistPath="BuildIPA/exportPlist.plist"

cd $Path

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration DevRelease
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration DevRelease -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist ${PlistPath} -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraCloudClass.ipa AgoraEducationDev.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F "file=@AgoraEducationDev.ipa" \
-F "updateDescription=$3"

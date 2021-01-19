#!/bin/sh
ArchivePathQA=AgoraEducationQATest.xcarchive
IPANameQA="IPAQATEST"
Path="../"
PlistPath="BuildIPA/exportPlist.plist"

cd $Path

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QATestRelease
xcodebuild -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QATestRelease -archivePath ${ArchivePathQA} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist ${PlistPath} -archivePath ${ArchivePathQA} -exportPath ${IPANameQA} -quiet || exit
cp ${IPANameQA}/AgoraCloudClass.ipa AgoraEducationQATest.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F  "file=@AgoraEducationQATest.ipa"

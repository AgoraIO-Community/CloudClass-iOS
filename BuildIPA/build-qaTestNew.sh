#!/bin/sh
ArchivePathQA=AgoraEducationQATestNew.xcarchive
IPANameQA="IPAQATESTNEW"
Path="../"
PlistPath="BuildIPA/exportPlist.plist"

cd $Path

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QATestNewRelease
xcodebuild -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration QATestNewRelease -archivePath ${ArchivePathQA} archive -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist ${PlistPath} -archivePath ${ArchivePathQA} -exportPath ${IPANameQA} -quiet || exit
cp ${IPANameQA}/AgoraCloudClass.ipa AgoraEducationQATestNew.ipa

curl -X POST \
https://upload.pgyer.com/apiv1/app/upload \
-H 'content-type: multipart/form-data' \
-F "uKey=$1" \
-F "_api_key=$2" \
-F "file=@AgoraEducationQATestNew.ipa" \
-F "updateDescription=$3"

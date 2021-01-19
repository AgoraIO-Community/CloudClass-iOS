#!/bin/sh
ArchivePath=AgoraEducation.xcarchive
IPAName="IPA"
Path="../"
PlistPath="BuildIPA/exportStorePlist.plist"

cd $Path

xcodebuild clean -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation" -configuration Release
xcodebuild archive -workspace "AgoraEducation.xcworkspace" -scheme "AgoraEducation"  -configuration Release -archivePath ${ArchivePath} -quiet || exit
xcodebuild -exportArchive -exportOptionsPlist ${PlistPath} -archivePath ${ArchivePath} -exportPath ${IPAName} -quiet || exit
cp ${IPAName}/AgoraCloudClass.ipa AgoraEducation.ipa


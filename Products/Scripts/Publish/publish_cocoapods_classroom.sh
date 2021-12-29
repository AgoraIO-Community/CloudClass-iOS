#!/bin/sh
SDK_Version=$1

if [ ${#SDK_Version} -le 0 ]; then
    echo "parameter nil"
    exit -1
fi

SDK_Name="AgoraClassroomSDK"
SDK_Path="../../../SDKs/"

SDKs_Path="${SDK_Path}/${SDK_Name}"

cd ${SDKs_Path}

Tag=${SDK_Name}_iOS_v${SDK_Version}

git add ${SDK_Name}_iOS.podspec
git commit -m "[ENH]:${Tag}"
git tag -d ${Tag}
git push originGithub :refs/tags/${Tag}

git tag ${Tag}
git push originGithub --tags

pod spec lint ${SDK_Name}_iOS.podspec --allow-warnings --verbose
pod trunk push ${SDK_Name}_iOS.podspec --allow-warnings --verbose

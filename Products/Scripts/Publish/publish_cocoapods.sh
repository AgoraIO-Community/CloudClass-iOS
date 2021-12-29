#!/bin/sh
SDK_Name=$1
SDK_Path=$2
SDK_Version=$3

SDKs_Path="${SDK_Path}/${SDK_Name}"

cd ${SDKs_Path}

Tag=${SDK_Name}_v${SDK_Version}

git tag -d ${Tag}
git push originGithub :refs/tags/${Tag}
git tag ${Tag}
git push originGithub --tags

pod spec lint ${SDK_Name}.podspec --allow-warnings --verbose
pod trunk push ${SDK_Name}.podspec --allow-warnings --verbose
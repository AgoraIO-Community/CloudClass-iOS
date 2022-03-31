#!/bin/sh
SDK_Version=$1

if [ ${#SDK_Version} -le 0 ]; then
    echo "parameter nil"
    exit -1
fi

SDK_Name="AgoraClassroomSDK_iOS"

cd ../../../

#开源库需要先提交 tag 才能验证
Tag=${SDK_Name}_v${SDK_Version}

git add ${SDK_Name}.podspec
git commit -m "[ENH]:${Tag}"
git tag -d ${Tag}
git push originGithub :refs/tags/${Tag}
git tag ${Tag}
git push originGithub --tags

pod spec lint  ${SDK_Name}.podspec --allow-warnings --verbose
pod trunk push ${SDK_Name}.podspec --allow-warnings --verbose
pod trunk info ${SDK_Name}
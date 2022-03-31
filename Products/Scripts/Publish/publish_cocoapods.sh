#!/bin/sh
SDK_Name=$1
SDK_Version=$2

if [ ${#SDK_Name} -le 0 ]; then
    echo "parameter 1 nil"
    exit -1
fi

if [ ${#SDK_Version} -le 0 ]; then
    echo "parameter 2 nil"
    exit -1
fi

cd ../../../

#开源库需要先提交 tag 才能验证
Tag=${SDK_Name}_v${SDK_Version}

git add ${SDK_Name}.podspec
git commit -m "[ENH]:${Tag}"
git tag -d ${Tag}
git push originGithub :refs/tags/${Tag}
git tag ${Tag}
git push originGithub --tags

pod spec lint ${SDK_Name}.podspec --allow-warnings --verbose
pod trunk push ${SDK_Name}.podspec --allow-warnings --verbose
pod trunk info ${SDK_Name}
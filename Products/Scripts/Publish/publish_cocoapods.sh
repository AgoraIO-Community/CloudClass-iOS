#!/bin/sh
SDK_Name=$1

cd ../../../
pwd

Podspec_Path=${SDK_Name}.podspec

# params check
if [ ${#SDK_Name} -le 0 ]; then
    echo "parameter 1 nil"
    exit -1
fi

if [[ ! -f $Podspec_Path ]]; then
echo "podspec not found"
exit 1
fi

# get version
Version_Cmd=`grep "spec.version\s*=\s*\"\d.\d.\d\"" "${Podspec_Path}" | sed -r 's/.*"(.+)".*/\1/'`

SDK_Version=$Version_Cmd
if [[ -z $SDK_Version ]]; then
echo "get version unsuccessfully"
exit -1
fi

echo "$SDK_Name version: $SDK_Version"

# originGithub check
Remote_Cmd=`git remote | grep 'originGithub'`
if [[ -z $Remote_Cmd ]]; then
git remote add originGithub 'git@github.com:AgoraIO-Community/CloudClass-iOS.git'
fi

# tag check
Tag=${SDK_Name}_v${SDK_Version}
Tag_Check_Cmd=`git ls-remote --tags originGithub | grep "refs/tags/$Tag"`
if [[ -n ${Tag_Check_Cmd} ]]; then
 echo "Tag exists in originGithub"
 exit -1
fi

 # push tag
git tag -d ${Tag}
git push origin :refs/tags/${Tag}
git tag ${Tag}
git push origin ${Tag}
git push originGithub ${Tag}

# pod push
pod spec lint ${Podspec_Path} --allow-warnings --verbose
pod trunk push ${Podspec_Path} --allow-warnings --verbose
pod trunk info ${SDK_Name}

# push branch to originGithub
Branch_Name=release/${SDK_Version}
git push originGithub ${Branch_Name}
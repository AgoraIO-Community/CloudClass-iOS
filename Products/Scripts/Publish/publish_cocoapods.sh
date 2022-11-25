#!/bin/sh
SDK_Name=$1
Podspec_Path=${SDK_Name}.podspec

cd $(dirname $0)
cd ../../../
pwd

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
SDK_Version=`grep "spec.version\s*=\s*\"\d.\d.\d\"" ${Podspec_Path} | sed -r 's/.*"(.+)".*/\1/'`
echo $Podspec_Path
if [[ -z $SDK_Version ]]; then
    echo "Get version unsuccessfully"
    exit -1
fi

echo "$SDK_Name version: $SDK_Version"
Target_Branch=release/${SDK_Version}

# current branch check
Current_Branch=`git rev-parse --abbrev-ref HEAD`
if [[ ${Current_Branch} != ${Target_Branch} ]]; then
    echo "Branch error! \nCurrent: ${Current_Branch}"
    exit -1
fi

# originGithub check
Remote_Cmd=`git remote | grep 'originGithub'`
if [[ -z $Remote_Cmd ]]; then
    echo "Add remote originGithub"
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
git tag ${Tag}
git push origin ${Tag}
git push originGithub ${Tag}

# pod push
pod spec lint ${Podspec_Path} --allow-warnings --verbose
pod trunk push ${Podspec_Path} --allow-warnings --verbose
pod trunk info ${SDK_Name}

# push branch to originGithub
git push originGithub ${Target_Branch}
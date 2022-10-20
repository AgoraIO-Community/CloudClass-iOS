#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

SDK_Name=$1

Current_Path=$(cd "$(dirname "$0")";pwd)
SDKs_Path="$Current_Path/../../../SDKs"
Products_Root_Path="$Current_Path/../../Libs"
Products_Path="$Products_Root_Path/$SDK_Name"
Builder_Path="${SDKs_Path}/AgoraBuilder"

if [ ! -d $Products_Root_Path ];then
    mkdir $Products_Root_Path
fi

rm -rf ${Products_Path}
mkdir ${Products_Path}

errorExit() {
    Build_Result=$1

    if [ $Build_Result != 0 ]; then
        echo "${Color} ======${SDK_Name} Fails======== ${Res}"
        exit -1
    fi

    echo "${Color} ======${SDK_Name} Succeeds======== ${Res}"
}

podContentReplace() {
    podfilePath="$Builder_Path/Podfile"

    startText="use_frameworks!"
    endText="post_install do |installer|"

    startIndex=`grep -n "$startText" $podfilePath | cut -d ":" -f 1`
    endIndex=`grep -n "$endText" $podfilePath | cut -d ":" -f 1`

    deleteStartIndex=$[$startIndex+1]
    deleteEndIndex=$[$endIndex-1]

    if [ $deleteEndIndex -ge $deleteStartIndex ];then
        sed -i "" "${deleteStartIndex},${deleteEndIndex}d" $podfilePath
    fi
    
    replace="${startText}\n"
    sed -i "" "s/${startText}/${replace}/g" $podfilePath

    podContentPath=$Current_Path/${SDK_Name}_Pod

    sed -i "" "${startIndex}r ${podContentPath}" $podfilePath
}

dependencyCheck() {
    cd $Builder_Path

    cat Podfile | while read rows
    do
        if [[ $rows != *"/Binary"* ]];then
            continue
        fi

        # remove space
        line=`echo $rows | sed s/[[:space:]]//g`
        
        libName=`echo $line | sed "s:pod\'\(.*\)\/Binary.*:\1:g"`
        repoPath=`echo $line | sed "s:.*\:path=>\'\(.*\)\/$libName.*\':\1:g"`

        repoAbsolutePath=$Builder_Path/$repoPath

        echo "$SDK_Name dependency repo:$repoAbsolutePath"
        dependencyPath="$repoAbsolutePath/Products/Libs/$libName/$libName.framework"

        # dependency check
        if [ -d $dependencyPath ]; then
            continue
        fi
        
        # call buildframework
        echo "dependencyPath: $dependencyPath not found"
        echo "$SDK_Name call build: $libName"

        dependencySDKPath="$repoAbsolutePath/Products/Scripts/SDK"
        if [ ! -d $dependencySDKPath ]; then
            pwd
            echo "dependencySDKPath not found: $dependencySDKPath"
            exit
        fi

       sh $dependencySDKPath/buildframework.sh $libName

        if [ $? -ne 0 ];then
            exit
        fi

        cd $Current_Path
    done

   cd $Current_Path
   podContentReplace
}

echo "${Color} ======${SDK_Name} Start======== ${Res}"

podContentReplace

dependencyCheck

# # current path is under Products/Scripts/SDK
$Current_Path/buildExecution.sh $Builder_Path ${SDK_Name} Release

errorExit $?

# delete useless files
IsContains(){
    ContainingLibs=("AgoraEduUI.framework" "AgoraClassroomSDK_iOS.framework")
    [[ ${ContainingLibs[@]/$1/} != ${ContainingLibs[@]} ]];echo $?
}
Files=$(ls ${Products_Path})

dSYMs_iPhone_folder="dSYMs_iPhone"
dSYMs_Simulator_folder="dSYMs_Simulator"

for FileName in ${Files}
do
    if [[ $dSYMs_iPhone_folder =~ $FileName ]]; then
        echo dsym_ip
    elif [[ $dSYMs_Simulator_folder =~ $FileName ]]; then
        echo dsym_simu
    else
        result=`IsContains $FileName`

        if [ $result != 0 ]; then
            rm -fr ${Products_Path}/${FileName}
            echo $Products_Path/dSYMs_iPhone/${FileName}.dSYM
            rm -fr $Products_Path/dSYMs_iPhone/${FileName}.dSYM
            rm -fr $Products_Path/dSYMs_Simulator/${FileName}.dSYM
        fi
    fi
done


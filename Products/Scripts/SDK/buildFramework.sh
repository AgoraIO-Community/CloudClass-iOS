#!/bin/bash
Color='\033[1;36m'
Res='\033[0m'

SDK_Name=$1

Current_Path=`pwd`
SDKs_Path="../../../SDKs"
Products_Root_Path="../../Libs"
Products_Path="$Products_Root_Path/$SDK_Name"
Builder_Path="${SDKs_Path}/AgoraBuilder"

if [ ! -d $Products_Root_Path ];then
    mkdir $Products_Root_Path
fi

rm -rf ${Products_Path}
mkdir ${Products_Path}

errorExit() {
    SDK_Name=$1
    Build_Result=$2

    if [ $Build_Result != 0 ]; then
        echo "SDK_Name: ${SDK_Name}"
        exit 1
    fi
    echo "build result: $Build_Result"
    echo "${SDK_Name} build success"
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

    sed -i "" "${startIndex}r ${SDK_Name}_Pod.txt" $podfilePath
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

        dependencyPath="$repoPath/Products/Libs/$libName/$libName.framework"
        
        # call buildframework of dependency
        if [ ! -f $dependencyPath ]; then
            cd $repoPath/Products/Scripts/SDK
            sh buildframework.sh $libName
            cd $Current_Path
        fi
    done
    
    cd $Current_Path
    podContentReplace
}

echo "${Color} ======${SDK_Name} Start======== ${Res}"

podContentReplace

dependencyCheck

# current path is under Products/Scripts/SDK
./buildExecution.sh $Builder_Path ${SDK_Name} Release

errorExit ${SDK_Name} $?

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


Root_Path=$1
SDK_Name=$2
Scheme_Name=$SDK_Name
Mode=$3
Product_Path="Build/product"
Frameworks_Path="../../Products/Libs/"
Simulator_dSYM_Path="../../Products/Libs/dSYMs_Simulator/"
iPhone_dSYM_Path="../../Products/Libs/dSYMs_iPhone/"

Derived_Data_Path=$Product_Path/derived_data
iOS_Product_Path=$Product_Path/ios
iPhone_Product_Path=$iOS_Product_Path/iphone
Simulator_Product_Path=$iOS_Product_Path/simulator
Universal_Product_Path=$iOS_Product_Path/universal

cd $Root_Path

# prepare
rm -rf $iPhone_Product_Path/*
rm -rf $Simulator_Product_Path/*
rm -rf $Universal_Product_Path/*
rm -rf $Derived_Data_Path/*

mkdir $Derived_Data_Path

# parameter 1: os
buildFunc() {
    OS=$1

    OS_TYPE=""
    TARGET_FILE=""
    PROJECT_TYPE=""
    ARC=""

    if [ ! -f "Podfile" ];then
        TARGET_FILE=AgoraBuilder.xcodeproj
        PROJECT_TYPE="-project"
    else
        TARGET_FILE=AgoraBuilder.xcworkspace
        PROJECT_TYPE="-workspace"
        pod install --repo-update
    fi

    if [ "${OS}" = "iphoneos" ];then
        OS_TYPE="iphoneos"
        ARC="-arch armv7 -arch arm64"
    else
        OS_TYPE="iphonesimulator"
        ARC="-arch x86_64"
    fi  

    xcodebuild -quiet clean ${PROJECT_TYPE} ${TARGET_FILE}\
    -scheme ${Scheme_Name} 
    
    xcodebuild -quiet ${PROJECT_TYPE} ${TARGET_FILE}\
    -scheme ${Scheme_Name}\
    -sdk ${OS_TYPE}\
    -configuration ${Mode}\
    ${ARC}\
    -derivedDataPath $Derived_Data_Path || exit 1
}

# compile
# simulator
rm -rf $Derived_Data_Path/*
buildFunc "iphonesimulator"
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/*.framework $Simulator_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/*/*.framework $Simulator_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/*.dSYM $Simulator_dSYM_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/*/*.dSYM $Simulator_dSYM_Path

# iphone
rm -rf $Derived_Data_Path/*
buildFunc "iphoneos"
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/*.framework $iPhone_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/*/*.framework $iPhone_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/*.dSYM $iPhone_dSYM_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/*/*.dSYM $iPhone_dSYM_Path

#parameters 1: SDK Name
handleEveryFramework() {
    SDK_Name=$1
    echo `pwd`

    iPhone_Modules_Path="$iPhone_Product_Path/$SDK_Name.framework/Modules/${SDK_Name}.swiftmodule/."
    Simulator_Modules_Path="$Simulator_Product_Path/$SDK_Name.framework/Modules/${SDK_Name}.swiftmodule/."

    # merge
    if [ -d $Simulator_Modules_Path ]; then
        cp -r $Simulator_Modules_Path $iPhone_Modules_Path
    fi

    Swift_Header=$SDK_Name.framework/Headers/$SDK_Name-Swift.h
    Simulator_Swift_Header=$Simulator_Product_Path/$Swift_Header
    iPhone_Swift_Header=$iPhone_Product_Path/$Swift_Header

    if [ -f $Simulator_Swift_Header ]; then
        echo "merge swift header"
        cat < $Simulator_Swift_Header >> $iPhone_Swift_Header
    fi

    cp -r $iPhone_Product_Path/$SDK_Name.framework $Universal_Product_Path
    lipo -create $iPhone_Product_Path/$SDK_Name.framework/$SDK_Name $Simulator_Product_Path/$SDK_Name.framework/$SDK_Name -output $Universal_Product_Path/$SDK_Name.framework/$SDK_Name

    cp -r $Universal_Product_Path/$SDK_Name.framework $Frameworks_Path
}

Files=$(ls $iPhone_Product_Path)

for FileName in $Files
do
    if [[ $FileName =~ ".framework" ]]
    then
        SDK_Name=${FileName%.*}
        echo "SDK_Name $SDK_Name"
        handleEveryFramework $SDK_Name
    fi
done
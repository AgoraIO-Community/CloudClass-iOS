Root_Path=$1
SDK_Name=$2
Scheme_Name=$SDK_Name
Mode=$3
Product_Path="$Root_Path/Build/product"
Frameworks_Path="../../Frameworks"

Derived_Data_Path=$Product_Path/derived_data
iOS_Product_Path=$Product_Path/ios
iPhone_Product_Path=$iOS_Product_Path/iphone
Simulator_Product_Path=$iOS_Product_Path/simulator
Universal_Product_Path=$iOS_Product_Path/universal
Bundle=$Universal_Product_Path/$SDK_Name.framework/$SDK_Name.bundle
iPhone_Modules_Path="$iPhone_Product_Path/$SDK_Name.framework/Modules/${SDK_Name}.swiftmodule/."
Simulator_Modules_Path="$Simulator_Product_Path/$SDK_Name.framework/Modules/${SDK_Name}.swiftmodule/."

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
        TARGET_FILE=${SDK_Name}.xcodeproj
        PROJECT_TYPE="-project"
    else
        TARGET_FILE=${SDK_Name}.xcworkspace
        PROJECT_TYPE="-workspace"
        pod install --repo-update
    fi

    if [ "${OS}" = "iphoneos" ];then
        OS_TYPE="iphoneos"
        ARC="-arch armv7 -arch armv7s -arch arm64"
    else
        OS_TYPE="iphonesimulator"
        ARC="-arch x86_64"
    fi  

    xcodebuild clean ${PROJECT_TYPE} ${TARGET_FILE}\
    -scheme ${Scheme_Name} 
    
    xcodebuild ${PROJECT_TYPE} ${TARGET_FILE}\
    -scheme ${Scheme_Name}\
    -sdk ${OS_TYPE}\
    -configuration ${Mode}\
    ${ARC}\
    -derivedDataPath $Derived_Data_Path BITCODE_GENERATION_MODE=bitcode || exit 1
}

# compile
# iphone
rm -rf $Derived_Data_Path/*
buildFunc "iphoneos"
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/$SDK_Name.framework $iPhone_Product_Path

# simulator
rm -rf $Derived_Data_Path/*
buildFunc "iphonesimulator"
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/$SDK_Name.framework $Simulator_Product_Path

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

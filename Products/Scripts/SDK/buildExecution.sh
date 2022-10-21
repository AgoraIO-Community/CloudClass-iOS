Root_Path=$1
SDK_Name=$2
Scheme_Name=$SDK_Name
Mode=$3

# current path is under AgoraBuilder
cd $Root_Path

# xcodebuild output path
Product_Path="Build/product"
Derived_Data_Path=$Product_Path/derived_data
iOS_Product_Path=$Product_Path/ios
iPhone_Product_Path=$iOS_Product_Path/iphone
Simulator_Product_Path=$iOS_Product_Path/simulator
Universal_Product_Path=$iOS_Product_Path/universal

# final target path
Lib_Path="../../Products/Libs/$SDK_Name"
Simulator_dSYM_Path="$Lib_Path/dSYMs_Simulator/"
iPhone_dSYM_Path="$Lib_Path/dSYMs_iPhone/"

# prepare
rm -rf $Derived_Data_Path
rm -rf $iOS_Product_Path
rm -rf $Simulator_dSYM_Path
rm -rf $iPhone_dSYM_Path

mkdir $Derived_Data_Path
mkdir $iOS_Product_Path
mkdir $iPhone_Product_Path
mkdir $Simulator_Product_Path
mkdir $Universal_Product_Path
mkdir $Simulator_dSYM_Path
mkdir $iPhone_dSYM_Path

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
        ARC="-arch arm64"
    else
        OS_TYPE="iphonesimulator"
        ARC="-arch x86_64"
    fi

    xcodebuild clean ${PROJECT_TYPE} ${TARGET_FILE}\
    -quiet\
    -scheme ${Scheme_Name}

    xcodebuild ${PROJECT_TYPE} ${TARGET_FILE}\
    -quiet\
    -scheme ${Scheme_Name}\
    -sdk ${OS_TYPE}\
    -configuration ${Mode}\
    ${ARC}\
    -derivedDataPath $Derived_Data_Path BITCODE_GENERATION_MODE=bitcode || exit 1
}

# compile
# simulator
buildFunc "iphonesimulator"
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/${SDK_Name}/${SDK_Name}.framework $Simulator_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphonesimulator/${SDK_Name}/${SDK_Name}.framework.dSYM $Simulator_dSYM_Path

# iphone
buildFunc "iphoneos"
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/${SDK_Name}/${SDK_Name}.framework $iPhone_Product_Path
cp -r $Derived_Data_Path/Build/Products/Release-iphoneos/${SDK_Name}/${SDK_Name}.framework.dSYM $iPhone_dSYM_Path

#parameters 1: SDK Name
handleEveryFramework() {
    Current_SDK_Name=$1

    iPhone_Modules_Path="$iPhone_Product_Path/$Current_SDK_Name.framework/Modules/${Current_SDK_Name}.swiftmodule/."
    Simulator_Modules_Path="$Simulator_Product_Path/$Current_SDK_Name.framework/Modules/${Current_SDK_Name}.swiftmodule/."

    # merge
    if [ -d $Simulator_Modules_Path ]; then
        cp -r $Simulator_Modules_Path $iPhone_Modules_Path
    fi

    Swift_Header=$Current_SDK_Name.framework/Headers/$Current_SDK_Name-Swift.h
    Simulator_Swift_Header=$Simulator_Product_Path/$Swift_Header
    iPhone_Swift_Header=$iPhone_Product_Path/$Swift_Header

    if [ -f $Simulator_Swift_Header ]; then
        echo "merge swift header"
        cat < $Simulator_Swift_Header >> $iPhone_Swift_Header
    fi

    cp -r $iPhone_Product_Path/$Current_SDK_Name.framework $Universal_Product_Path
    lipo -create $iPhone_Product_Path/$Current_SDK_Name.framework/$Current_SDK_Name $Simulator_Product_Path/$Current_SDK_Name.framework/$Current_SDK_Name -output $Universal_Product_Path/$Current_SDK_Name.framework/$Current_SDK_Name

    cp -r $Universal_Product_Path/$Current_SDK_Name.framework $Lib_Path
}

Files=$(ls $iPhone_Product_Path)

for FileName in $Files
do
    if [[ $FileName =~ ".framework" ]]
    then
        Current_SDK_Name=${FileName%.*}
        echo "Current_SDK_Name $Current_SDK_Name"
        handleEveryFramework $Current_SDK_Name
    fi
done || exit 1

echo Package_Publish: $Package_Publish
echo is_tag_fetch: $is_tag_fetch
echo arch: $arch
echo source_root: %source_root%
echo output: /tmp/jenkins/${project}_out
echo build_date: $build_date
echo build_time: $build_time
echo release_version: $release_version
echo short_version: $short_version
echo BUILD_NUMBER: ${BUILD_NUMBER}
echo Branch_Name: ${open_cloudclass_ios_branch}

export all_proxy=http://10.80.1.174:1080

# difference
Repo_Name="open-cloudclass-ios"
SDK_Array=(AgoraEduUI AgoraClassroomSDK_iOS)
Branch_Name=${open_cloudclass_ios_branch}

# import
. ../apaas-cicd-ios/Products/Scripts/Other/v1/operation_print.sh

# path
CICD_Scripts_Path="../apaas-cicd-ios/Products/Scripts"
CICD_Build_Path="${CICD_Scripts_Path}/SDK/Build"
CICD_Pack_Path="${CICD_Scripts_Path}/SDK/Pack"
CICD_Upload_Path="${CICD_Scripts_Path}/SDK/Upload"

# dependency
./Products/Scripts/Build/dependency.sh ${Repo_Name}

# build
for SDK in ${SDK_Array[*]} 
do
  ${CICD_Build_Path}/v1/build.sh ${SDK} ${Repo_Name}
  
  errorPrint $? "${SDK} build"
  
  # publish
  if [ "${Package_Publish}" = true ]; then
    ${CICD_Pack_Path}/v1/package.sh ${SDK} ${Repo_Name}

    errorPrint $? "${SDK} package"
      
    ${CICD_Upload_Path}/v1/upload_artifactory.sh ${SDK} ${Branch_Name} ${Repo_Name} ${is_official_build}

    errorPrint $? "${SDK} upload"
  fi
done

unset all_proxy

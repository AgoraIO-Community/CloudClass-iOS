SDK_Name=$1
SDK_Version=$2

Tag=${SDK_Name}_v${SDK_Version}

git tag -d ${Tag}
git push origin :refs/tags/${Tag}
git push originGithub :refs/tags/${Tag}
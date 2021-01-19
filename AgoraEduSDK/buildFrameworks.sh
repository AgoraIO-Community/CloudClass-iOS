#!/bin/bash
COLOR='\033[1;36m'
RES='\033[0m'

Root_Path="../../../../"


rm -rf Frameworks/*

echo "${COLOR} ======AgoraLog Start======== ${RES}"
cd "Modules/AgoraLog/Build/shell"
sh "build.sh" > "AgoraLog.log"
cd $Root_Path

echo "${COLOR} ======AgoraReplay Start======== ${RES}"
cd "Modules/AgoraReplay/Build/shell"
sh "build.sh" > "AgoraReplay.log"
cd $Root_Path

echo "${COLOR} ======AgoraReplayUI Start======== ${RES}"
cd "Modules/AgoraReplayUI/Build/shell"
sh "build.sh" > "AgoraReplayUI.log"
cd $Root_Path

echo "${COLOR} ======AgoraWhiteBoard Start======== ${RES}"
cd "Modules/AgoraWhiteBoard/Build/shell"
sh "build.sh" > "AgoraWhiteBoard.log"
cd $Root_Path

echo "${COLOR} ======EduSDK Start======== ${RES}"
cd "Modules/EduSDK/Build/shell"
sh "build.sh" > "EduSDK.log"
cd $Root_Path

echo "${COLOR} ======AgoraEduSDK Start======== ${RES}"
cd "Modules/AgoraEduSDK/Build/shell"
sh "build.sh" > "AgoraEduSDK.log"
cd $Root_Path

# 运行项目 demo

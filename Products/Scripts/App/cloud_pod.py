#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import re
from enum import Enum

# Base Enum
class PODMODE(Enum):
    Source = 0
    Binary = 1
    HalfBinary = 2

class RTCVERSION(Enum):
    Pre = 0
    Re = 1

# Base Data
ExtcuteDir = "../../../App/".strip()
BaseProjPath = ExtcuteDir + "AgoraEducation" + ".xcodeproj"

SourcePodContent =  """
    # common libs
    pod 'AgoraUIBaseViews', :path => '../../apaas-common-libs-ios/SDKs/AgoraUIBaseViews/AgoraUIBaseViews_Local.podspec'
    pod 'AgoraExtApp', :path => '../../apaas-common-libs-ios/SDKs/AgoraExtApp/AgoraExtApp_Local.podspec'
    pod 'AgoraWidget', :path => '../../apaas-common-libs-ios/SDKs/AgoraWidget/AgoraWidget_Local.podspec'

    # open source libs
    pod 'AgoraEduContext', :path => '../SDKs/AgoraEduContext/AgoraEduContext.podspec'
    pod 'AgoraEduUI', :path => '../SDKs/AgoraEduUI/AgoraEduUI.podspec'
    pod 'AgoraUIEduBaseViews', :path => '../SDKs/Modules/AgoraUIEduBaseViews/AgoraUIEduBaseViews_Local.podspec'
    pod 'AgoraReport', :path => '../../apaas-common-libs-ios/SDKs/AgoraReport/AgoraReport.podspec'
    pod 'AgoraRx', :path => '../../apaas-common-libs-ios/SDKs/AgoraRx/AgoraRx.podspec'

    # rtc (default pre)
    pod 'AgoraClassroomSDK_iOS/PreRtc', :path => '../SDKs/AgoraClassroomSDK/AgoraClassroomSDK_iOS.podspec'
    pod 'AgoraEduCore/PreRtc', :path => '../../cloudclass-ios/SDKs/AgoraEduCoreFull.podspec'
    pod 'AgoraRte/PreRtc', :path => '../../common-scene-sdk/iOS/AgoraRte.podspec'

    # widgets
    pod 'AgoraWidgets', :path => '../../open-apaas-extapp-ios/Widgets/AgoraWidgets/AgoraWidgets.podspec'
    pod 'ChatWidget', :path => '../../open-apaas-extapp-ios/Widgets/ChatWidget/ChatWidget.podspec'
    pod 'AgoraExtApps', :path => '../../open-apaas-extapp-ios/ExtApps/AgoraExtApps.podspec'
end
   """

BinaryPodContent = """
    pod 'AgoraClassroomSDK', :path => '../Products/AgoraClassroomSDK_Binary.podspec'
end
"""

RePodContent = """
    pod 'AgoraRtcKit', :path => '../../common-scene-sdk/iOS/ReRtc/AgoraRtcKit_Binary.podspec'
"""

BaseParams = {"extcuteDir": "./",
              "podMode": PODMODE.Source,
              "rtcVersion": RTCVERSION.Pre,
              "updateFlag": False}

# Base Functions
def HandlePath(path):
    path = path.strip()
    if os.path.exists(path) == False:
        print  ('Invalid Path!' + path)
        sys.exit(1)

def reRtcHandle(lines):
    if BaseParams["rtcVersion"] == RTCVERSION.Pre:
        return
        
    print("Replace PreRtc with ReRtc")

    oriRtcPod = "pod 'AgoraRtcEngine_iOS'"
    preRtcStr = '/PreRtc'
    reRtcStr = '/ReRtc'

    for index,str in enumerate(lines):
        if preRtcStr in str:
            str = str.replace(preRtcStr,reRtcStr)

        if oriRtcPod in str:
            str = RePodContent

        lines[index] = str

def generatePodfile():
    podFilePath = ExtcuteDir + '%s' % 'Podfile'
    if BaseParams["podMode"] == PODMODE.HalfBinary:
        return

    key = "# open source libs"
    lineNumber = 0
    foundLine = 0
    with open(podFilePath,'r') as f:
        lines = f.readlines()

    for line in lines:
        lineNumber += 1
        if key in line:
            foundLine = lineNumber
            break

    lines = lines[:foundLine]
    if BaseParams["podMode"] == PODMODE.Source:
        lines.append(SourcePodContent)
        reRtcHandle(lines)
    elif BaseParams["podMode"] == PODMODE.Binary:
        lines.append(BinaryPodContent)
    
    with open(podFilePath,'w') as f:
        f.writelines(lines)
 
def executePod():
    podFilePath = ExtcuteDir + '/%s' % 'Podfile'
    HandlePath(BaseProjPath)
    HandlePath(podFilePath)

    generatePodfile()

    # 改变当前工作目录到指定的路径
    os.chdir(ExtcuteDir)
    print  ('====== pod install log ======')
    if BaseParams["updateFlag"] == True:
        os.system('pod install --repo-update')
    else:
        os.system('pod install --no-repo-update')

def main():
    paramsLen = len(sys.argv)
    if paramsLen == 1:
        sys.exit(1)
    elif paramsLen == 2:
        # 0为source pod, 1为binary pod
        PodMode = sys.argv[1]
    elif paramsLen == 3:
        PodMode = sys.argv[1]
        # 0为大重构rtc, 1为老版本rtc
        RtcVersion = sys.argv[2]
        BaseParams["rtcVersion"] = RTCVERSION.Re if RtcVersion == "0" else RTCVERSION.Pre
        print  ('Rtc Version: ' + BaseParams["rtcVersion"].name)
    
    BaseParams["podMode"] = PODMODE.Source if PodMode == "0" else PODMODE.Binary
    print  ('Pod Mode: ' + BaseParams["podMode"].name)

   

    # 若为source pod，开发者模式
    if BaseParams["podMode"] == PODMODE.Source:
        print "BaseParams:\n" + str(BaseParams)
        modifyFlag = raw_input("Need Modify Base Paramaters? Yes: 0, NO: Any\n")

        if modifyFlag == "0":
            # 是否需要更新cocoapods repo
            print ("Update Cocoapods repo: don't update: 0, update: 1")
            updateFlag = raw_input()
            if (updateFlag != "0" and updateFlag != "1"):
                print("Invalid input, don't update dafaultly")
                updateFlag = "0"
            BaseParams["updateFlag"] = False if updateFlag == "0" else True
    
    executePod()

if __name__ == '__main__':
    main()


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
    pod 'AgoraWidget', :path => '../../apaas-common-libs-ios/SDKs/AgoraWidget/AgoraWidget_Local.podspec'
    pod 'AgoraReport', :path => '../../apaas-common-libs-ios/SDKs/AgoraReport/AgoraReport.podspec'
    pod 'AgoraRx', :path => '../../apaas-common-libs-ios/SDKs/AgoraRx/AgoraRx.podspec'

    # rtc (default pre)
    pod 'AgoraEduCore', :path => '../../cloudclass-ios/AgoraEduCore_Local.podspec'
    pod 'AgoraRte', :path => '../../common-scene-sdk/iOS/AgoraRte.podspec'

    # open source libs
    pod 'AgoraEduContext', :path => '../AgoraEduContext.podspec'
    pod 'AgoraEduUI', :path => '../AgoraEduUI.podspec'
    pod 'AgoraClassroomSDK_iOS', :path => '../AgoraClassroomSDK_iOS.podspec'
    
    # widgets
    pod 'AgoraWidgets', :path => '../../open-apaas-extapp-ios/AgoraWidgets.podspec'

    pod 'MLeaksFinder'
    post_install do |installer|
      ## Fix for XCode 12.5
      find_and_replace("Pods/FBRetainCycleDetector/FBRetainCycleDetector/Layout/Classes/FBClassStrongLayout.mm",
        "layoutCache[currentClass] = ivars;", "layoutCache[(id<NSCopying>)currentClass] = ivars;")
    end
end
   """

BinaryPodContent = """
  pod 'AgoraClassroomSDK_iOS', :path => '../AgoraClassroomSDK_iOS.podspec'
  pod 'AgoraEduContext', :path => '../AgoraEduContext.podspec'
  pod 'AgoraEduUI', :path => '../AgoraEduUI.podspec'
  pod 'AgoraWidgets', :path => '../../open-apaas-extapp-ios/AgoraWidgets.podspec'
    
  pod 'AgoraUIBaseViews', :path => '../Products/AgoraUIBaseViews_Binary.podspec'
  pod 'AgoraEduCore', :path => '../Products/AgoraEduCore_Binary.podspec'
  pod 'AgoraWidget', :path => '../Products/AgoraWidget_Binary.podspec'
end
"""

PreRtcContent = """
    pod 'AgoraRtcEngine_iOS', '3.5.2'
"""

RePodContent = """
    pod 'AgoraRtcKit', :path => '../../common-scene-sdk/iOS/ReRtc/AgoraRtcKit_Binary.podspec'
"""

LeaksFinderContent = """
def find_and_replace(dir, findstr, replacestr)
  Dir[dir].each do |name|
      text = File.read(name)
      replace = text.gsub(findstr,replacestr)
      if text != replace
          puts "Fix: " + name
          File.open(name, "w") { |file| file.puts replace }
          STDOUT.flush
      end
  end
  Dir[dir + '*/'].each(&method(:find_and_replace))
end
"""

BaseParams = {"podMode": PODMODE.Source,
              "rtcVersion": RTCVERSION.Pre,
              "updateFlag": False}

# Base Functions
def HandlePath(path):
    path = path.strip()
    if os.path.exists(path) == False:
        print  ('Invalid Path!' + path)
        sys.exit(1)

def rtcHandle(lines):
    preRtcPod = "pod 'AgoraRtcEngine_iOS'"
    reRtcPod = "pod 'AgoraRtcKit'"
    preRtcStr = '/PreRtc'
    reRtcStr = '/ReRtc'
    
    if BaseParams["rtcVersion"] == RTCVERSION.Pre:
        print("Replace ReRtc with PreRtc")
        for index,str in enumerate(lines):
            if reRtcStr in str:
                str = str.replace(reRtcStr,preRtcStr)

            if reRtcPod in str:
                str = PreRtcContent

            lines[index] = str
    else:    
        print("Replace PreRtc with ReRtc")
        for index,str in enumerate(lines):
            if preRtcStr in str:
                str = str.replace(preRtcStr,reRtcStr)

            if preRtcPod in str:
                str = RePodContent

            lines[index] = str


def addLeaksFinderFunction(lines):
    if BaseParams["podMode"] != PODMODE.Source:
        return
    
    print("Add function for MLeaksFinder")
    keyword = "target"
    funcName = "def find_and_replace"
    addIndex = -1
    for index,str in enumerate(lines):
        if funcName in str:
            addIndex = -1
            break
        if keyword in str:
            addIndex = index
    
    if addIndex != -1:
        newStr = LeaksFinderContent + "\n" + lines[addIndex]
        lines[addIndex] = newStr


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
        addLeaksFinderFunction(lines)
    elif BaseParams["podMode"] == PODMODE.Binary:
        lines.append(BinaryPodContent)

    rtcHandle(lines)
    
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
    os.system('rm -rf Podfile.lock')
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
        modifyFlag = input("Need Update pod repo? Yes: 0, NO: Any\n")

        # 是否需要更新cocoapods repo
        if modifyFlag == "0":
            BaseParams["updateFlag"] = True
    
    executePod()

if __name__ == '__main__':
    main()


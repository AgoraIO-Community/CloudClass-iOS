#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys

def main():
    App_Path = sys.argv[1]
    Environment = sys.argv[2]
     
    CoreEnvi = "0"
    TokenEnvi = "environment: .dev"
    
    if Environment == "QATestALL":
        CoreEnvi = "0"
        TokenEnvi = "environment: .dev"
    elif Environment == "QAPreALL":
        CoreEnvi = "1"
        TokenEnvi = "environment: .pre"
    elif Environment == "QAProALL":
        CoreEnvi = "2"
        TokenEnvi = "environment: .pro"
    else:
        print("default dev evni in environment.py")
     
    f = open(App_Path + "/AgoraEducation/Main/Controllers/LoginViewController.swift", 'r+')
    content = f.read()
    
    print(App_Path)
    
    position = content.find("AgoraClassroomSDK.launch(launchConfig,")
    
    if position != -1:
        string1 = "let setEnvironment = NSSelectorFromString(\"setEnvironment:\")\n"
        string2 = "AgoraClassroomSDK.perform(setEnvironment, with: "
        string3 = CoreEnvi + ")\n"
        
        string = string1 + string2 + string3
    
        content = content[:position] + string + content[position:]
        content = re.sub(r'environment: .pro', TokenEnvi, content)
        
        f.seek(0)
        f.write(content)
        f.truncate()

if __name__ == "__main__":
    main()

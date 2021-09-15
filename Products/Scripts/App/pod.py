#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys

def main():
    App_Path = sys.argv[1]

    f = open(App_Path + "/Podfile", 'r+')
    content = f.read()
    
    print(App_Path)

    contentNew = re.sub(r'sourcePod', "#sourcePod", content)
    contentNew = re.sub(r'halfBinaryPod', "#halfBinaryPod", contentNew)
    contentNew = re.sub(r'#binaryPod', "binaryPod", contentNew)

    contentNew = re.sub(r'def #halfBinaryPod', "def halfBinaryPod", contentNew)
    contentNew = re.sub(r'def #sourcePod', "def sourcePod", contentNew)
    
    f.seek(0)
    f.write(contentNew)
    f.truncate()

if __name__ == "__main__":
    main()

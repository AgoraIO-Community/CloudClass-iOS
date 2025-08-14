#!/bin/bash

# cd this file path
cd $(dirname $0)
echo pwd: `pwd`

# path
CICD_Scripts_Path="../../../../apaas-cicd-ios/Products/Scripts"

# Get script path
if [ -z "$CICD_Scripts_Path" ]; then
    echo "Error: CICD_Scripts_Path is not set"
    exit 1
fi

# Process script path
script_path="${CICD_Scripts_Path}/AgoraBuilder"
if [ ! -d "$script_path" ]; then
    echo "Error: Script directory not found: $script_path"
    exit 1
fi

# Get destination path
dst_path="../../Builder/"
dst_path_full=$(cd "$dst_path" && pwd)
if [ $? -ne 0 ]; then
    echo "Error: Cannot resolve destination path: $dst_path"
    exit 1
fi

# Execute copy operation
python "${script_path}/copy.py" "${dst_path_full}"

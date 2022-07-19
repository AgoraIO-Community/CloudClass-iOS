[root@localhost shell_order]# cat test27.sh
#!/bin/bash
#print the directory and file
 
for file in /home/hustyangju/*
do
if [ -d "$file" ]
then
  echo "$file is directory"
elif [ -f "$file" ]
then
  echo "$file is file"
fi
done
[root@localhost shell_order]# ./test27.sh
/home/hustyangju/array is directory
/home/hustyangju/menuwindow-7.12 is directory
/home/hustyangju/menuwindow-build-desktop is directory
/home/hustyangju/shell_order is directory
[root@localhost shell_order]#

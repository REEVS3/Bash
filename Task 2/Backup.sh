#!/bin/bash

echo "Backup Script"


if [ $# -eq 0 ]
then
    echo "No argument"
    read -p "path of dir:" dir


    userPath=$dir
else
    userPath=$1
fi

        echo "Compression...."
   tar -zcvf $userPath.tar.gz $userPath



if [ $? -eq 0 ]
then
                echo "Conection Inputs"
        read -p "enter target server ip: " setIP
        read -p "enter username: " usernm
                read -p "enter target dir: " targetDir
else

        echo "Compression Faild"
    exit 1
fi

scp $userPath.tar.gz $usernm@$setIP:$targetDir


if [ $? -eq 0 ]
then
        echo "" ; echo "File transfer successfully"
else
        echo "" ;echo "File transfer fail"
fi

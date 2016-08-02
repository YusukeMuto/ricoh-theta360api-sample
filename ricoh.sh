#!/bin/bash

function usage() {
cat <<_EOT_
Usage:
  $ricoh.sh [-a] arg

Description:
  This script will take picture with RICOH THETA S connecting by THETAXS********.OSC wifi.

Options:
  -a    none

_EOT_
exit 1
}

function start_session() {
    string=$(curl -X POST http://192.168.1.1:80/osc/commands/execute -d '{"name": "camera.startSession"}')
    raw=$(expr "$string" : '.*"sessionId":"\([^"]*\)"')
    echo "$raw"
    return 0
}

function close_session() {
    curl -X POST http://192.168.1.1:80/osc/commands/execute -d "{\"name\": \"camera.closeSession\", \"parameters\": {\"sessionId\": \"$1\"}}"
    return 0
}

function take_picture() {
    curl -X POST http://192.168.1.1:80/osc/commands/execute -d "{\"name\": \"camera.takePicture\", \"parameters\": {\"sessionId\": \"$1\"}}"
    return 0
}

function get_filename() {
    string=$(curl -X POST http://192.168.1.1:80/osc/state)
    raw=$(expr "$string" : '.*"_latestFileUri":"\([^"]*\)"')
    echo "$raw"
    return 0
}

function get_image() {
    picname=pic360.jpg
    echo ""
    echo "please input filename(default: pic360.jpg)"
    read filename

    if [ -n "$filename" ]
    then
	picname="$filename"
	echo "filename = $filename"
    fi
    
    curl -X POST http://192.168.1.1:80/osc/commands/execute -d "{\"name\": \"camera.getImage\", \"parameters\": {\"fileUri\": \"$1\"}}" > $picname
    echo "open file!"
    open -a "RICOH THETA" $picname
    return 0
}


echo ""
echo "Hello, I will take pictures for you!"
echo ""
echo "This session information is"
echo ""
curl http://192.168.1.1:80/osc/info
echo ""

isTakePic=y

#================================================#
# Option
#================================================#
#echo "Do you want to take picture(y or n)?"
#read isTakePic
#while [ "$isTakePic" != y -a "$isTakePic" != n ]
#do
#    echo "Sorry, I can't undestand. Please retry."
#    echo "Do you want to take picture(y or n)?"
#    read isTakePic
#done
#================================================#
if [ "$isTakePic" = y ]
then
    echo "OK I Will TAKE PICTURE!"

    sessionId="`start_session`"
    echo "We are in sessionId=${sessionId} !"
    echo ""
    take_picture `echo $sessionId`
    sleep 8;
    picname="`get_filename`"
    echo "Latest Picture name is $picname !"

    nextJob=g
    while [ "$nextJob" = t -o "$nextJob" = g ]
    do
	echo "What do you want to do (t[take new picture],g[getImage],e[end])?"
	read nextJob
	if [ "$nextJob" = t ]
	then
	   take_picture `echo $sessionId`
	   sleep 8;
	   picname="`get_filename`"
	   echo "Latest Picture name is $picname !"
	elif [ "$nextJob" = g ]
	then
	    get_image `echo $picname`
	elif [ "$nextJob" = e ]
	then
	    close_session `echo $sessionId`
	    echo "Finish!"
	else
	    echo "I can't understand. orz"
	fi
    done
        
elif [ "$isTakePic" = n ]
then
    echo "OK"
fi


echo "Bye :)"
	   



#!/bin/bash

while [ -n "$1" ]
do
	echo "Uploading $1..."
	curl -F "json=<$1"  http://ghcspeed-nomeata.rhcloud.com/result/add/json/
	echo
	shift
done

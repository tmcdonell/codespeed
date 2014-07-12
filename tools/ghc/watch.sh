#!/bin/bash

scripts=$(dirname $0)
cd /data1/breitner/ghc/ghc-speed

set nullglob

while sleep 60
do
	(cd ghc-master; git pull)
	for rev in $(cd ghc-master; git log --oneline --first-parent db19c665ec5055c2193b2174519866045aeff09a..HEAD | cut -d\  -f1)
	do
		if [ -z "$rev-*log" -a -z "ghc-$rev" ]
		then
			$scripts/run-speed $rev
			$scripts/log2json.pl $rev*.log
			$scripts/upload.sh $rev*.json
		fi
done

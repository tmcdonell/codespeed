#!/bin/bash

scripts="$(realpath "$(dirname $0)")"
cd ~/logs/


while true
do
	(cd ghc-master; git pull)
	for rev in $(cd ghc-master; git log --oneline --first-parent db19c665ec5055c2193b2174519866045aeff09a..HEAD | cut -d\  -f1)
	do
		if ! [ -e "$rev.log" -o -d "ghc-$rev" ]
		then
			echo "Benchmarking $rev..."
			$scripts/run-speed.sh "$rev" >/dev/null
			$scripts/log2json.pl "$rev.log"
			$scripts/upload.sh "$rev.json"
			break
		fi
	done
	sleep 60 || break
done

#!/bin/bash

scripts="$(realpath "$(dirname $0)")"
cd ~/logs/


while true
do
	(cd ghc-master; git pull)
	for rev in $(cd ghc-master; git log --oneline --first-parent cfeededff5662a6e2dc0104eb00adcca4d4ae984 | cut -d\  -f1 | tac)
	do
		if ! [ -e "$rev.log" -o  -e "$rev.log.broken" -o -d "ghc-tmp-$rev" ]
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

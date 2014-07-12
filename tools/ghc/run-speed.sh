#!/bin/bash

function say {
	echo
	echo "$@"
	echo
}

function run {
	    echo "$@"
		"$@"
}

rev="$1"
if [ -z "$rev" ]
then
  echo "$0 <rev>"
fi

set -e

cd /data1/breitner/ghc/ghc-speed/

cd ghc-master
git pull
git submodule update --recursive
cd ..



if [ -e "ghc-$rev" ]
then
	echo "ghc-$rev already exists"
	exit 1
fi

#logfile="$rev-$(date --iso=minutes).log"
logfile="$rev.log"
exec > >(tee "$logfile".tmp)
exec 2>&1

say "Cloning"

run git clone --recursive --reference ghc-master git://git.haskell.org/ghc "ghc-$rev"
cd "ghc-$rev"
run git checkout "$rev"

say "Identifying"

run git log -n 1

say "Code stats"

run ohcount compiler/

run ohcount rts/

run ohcount testsuite/

say "Booting"

run perl boot

say "Configuring"

run ./configure 

say "Building"

run /usr/bin/time -o buildtime make -j8 V=0
echo "Buildtime was:"
cat buildtime

say "Running the testsuite"

run make -C testsuite fast VERBOSE=2 THREADS=8

say "Running nofib"

run cd nofib/
run make boot
run make
run cd ..

say "Total space used"

run du -sc .

say "Cleaning up"

run cd ..
run rm -rf "ghc-$rev"

mv "$logfile".tmp "$logfile"

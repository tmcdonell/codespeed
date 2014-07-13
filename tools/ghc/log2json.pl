#!/usr/bin/perl

use strict;
use warnings;

use File::Basename;
use File::Slurp;
use JSON;
use IPC::Run qw/run/;

for my $filename (@ARGV) {
	my $output = dirname($filename)."/".basename($filename,".log"). ".json";

	my $log = read_file($filename);

	my %results;

	my $commit;
	if ($log =~ m/^commit ([a-f0-9]+)$/m) {
		$commit = $1;
	} else {
		die "Coult not find commit ID in $filename\n";
	}

	$results{'testsuite/tests'}= $1
		if ($log =~ m/^ +(\d+) total tests, which gave rise to/m);
	$results{'testsuite/expected passes'} = $1
		if ($log =~ m/^ +(\d+) expected passes/m);
	$results{'testsuite/framework failures'} = $1
		if ($log =~ m/^ +(\d+) caused framework failures/m);
	$results{'testsuite/unexpected passes'} = $1
		if ($log =~ m/^ +(\d+) unexpected passes/m);
	$results{'testsuite/expected failures'} = $1
		if ($log =~ m/^ +(\d+) expected failures/m);
	$results{'testsuite/unexpected failures'} = $1
		if ($log =~ m/^ +(\d+) unexpected failures/m);

	my $out;
	run (["nofib-analyse", "--csv=Allocs"], \$log, \$out) or die "cat: $?";
	for (split /^/, $out) {
		$results{"nofib/allocs/$1"} = $2 if /(.*),(.*)/;
	}
	run (["nofib-analyse", "--csv=Runtime"], \$log, \$out) or die "cat: $?";
	for (split /^/, $out) {
		$results{"nofib/runtime/$1"} = $2 if /(.*),(.*)/ and $2 > 1.0;
	}

	my $data = [];
	while ( my ($key, $value) = each %results ) {
		push @$data, {
			commitid => $commit,
			project => "GHC",
			branch => "default",
			executable => "ghc",
			environment => "nomeata's buildbot",
			benchmark => $key,
			result_value => $value,
		}
	};
	write_file($output, to_json($data, {utf8 => 1, pretty => 1}));
}

#!perl -T

use strict;
use warnings;

use Test::More tests => 1;
use Test::Dist::VersionSync;
use Test::Builder::Tester;

test_out(
	'ok 1 - modules list isa ARRAY',
	'ok 2 # skip No module found in the distribution.',
	'ok 3 # skip No module found in the distribution.',
);
Test::Dist::VersionSync::ok_versions(
	modules => [],
);
test_test( "ok_versions() detects empty list." );

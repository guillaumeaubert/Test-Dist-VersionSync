#!perl -T

use strict;
use warnings;

use Test::More tests => 5;
use Test::Dist::VersionSync;
use Test::Builder::Tester;


use_ok( 'Cwd' );

# Get untainted root directory.
my ( $root_directory ) = Cwd::getcwd() =~ /^(.*?)$/;

ok(
	chdir( 't/22-ok_versions-modules_list' ),
	'Change directory to t/22-ok_versions-modules_list.',
);

ok(
	unshift( @INC, 'lib/' ),
	'Add the test lib/ directory to @INC.',
);

test_out(
	'ok 1 - modules list isa ARRAY',
	'    1..4',
	'    ok 1 - use TestModule1;',
	'    ok 2 - Module TestModule1 declares a version.',
	'    ok 3 - use TestModule2;',
	'    ok 4 - Module TestModule2 declares a version.',
	'ok 2 - Retrieve versions for all modules listed.',
	'ok 3 - The modules declare only one version.',
);
Test::Dist::VersionSync::ok_versions(
	modules =>
	[
		'TestModule1',
		'TestModule2',
	],
);
test_test( "ok_versions() detects matching versions." );

ok(
	chdir( $root_directory ),
	'Change back to the original directory.',
);

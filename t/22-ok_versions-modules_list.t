#!perl -T

use strict;
use warnings;

use Test::Builder::Tester;
use Test::Dist::VersionSync;
use Test::FailWarnings -allow_deps => 1;
use Test::More tests => 5;


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

test_out( '1..3')
	if $Test::More::VERSION >= 1.005000005;
test_out( 'ok 1 - modules list isa ARRAY' );
test_out( '    TAP version 13' )
	if $Test::More::VERSION >= 1.005 && $Test::More::VERSION < 1.005000005;
test_out( '    1..4' );
test_out( '    ok 1 - use TestModule1;' );
test_out( '    ok 2 - Module TestModule1 declares a version.' );
test_out( '    ok 3 - use TestModule2;' );
test_out( '    ok 4 - Module TestModule2 declares a version.' );
test_out( 'ok 2 - Retrieve versions for all modules listed.' );
test_out( 'ok 3 - The modules declare only one version.' );

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

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
	chdir( 't/20-ok_versions-sync' ),
	'Change directory to t/20-ok_versions-sync.',
);

ok(
	unshift( @INC, 'lib/' ),
	'Add the test lib/ directory to @INC.',
);

test_out( 'ok 1 - No MANIFEST.SKIP found, skipping.' );
test_out( 'ok 2 - The MANIFEST file is present at the root of the distribution.' );
test_out( 'ok 3 - Retrieve MANIFEST file.' );
test_out( '    TAP version 13' )
	if $Test::More::VERSION >= 1.005;
test_out( '    1..4' );
test_out( '    ok 1 - use TestModule1;' );
test_out( '    ok 2 - Module TestModule1 declares a version.' );
test_out( '    ok 3 - use TestModule2;' );
test_out( '    ok 4 - Module TestModule2 declares a version.' );
test_out( 'ok 4 - Retrieve versions for all modules listed.' );
test_out( 'ok 5 - The modules declare only one version.' );

Test::Dist::VersionSync::ok_versions();

test_test( "ok_versions() detects matching versions." );

ok(
	chdir( $root_directory ),
	'Change back to the original directory.',
);

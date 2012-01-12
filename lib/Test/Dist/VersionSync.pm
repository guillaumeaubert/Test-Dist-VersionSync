package Test::Dist::VersionSync;

use strict;
use warnings;

use Data::Dumper;
use Test::More;


=head1 NAME

Test::Dist::VersionSync - Verify that all the modules in a distribution have the same version number.


=head1 VERSION

Version 1.0.0

=cut

our $VERSION = '1.0.0';


=head1 SYNOPSIS

	use Test::Dist::VersionSync;
	Test::Dist::VersionSync::ok_versions();


=head1 USE AS A TEST FILE

The most common use should be to add a module_versions.t file to your tests directory for a given distribution, with the following content:

	#!perl -T
	
	use strict;
	use warnings;
	
	use Test::More;
	
	# Ensure a recent version of Test::Dist::VersionSync
	my $version_min = '1.0.0';
	eval "use Test::Dist::VersionSync $version_min";
	plan( skip_all => "Test::Dist::VersionSync $version_min required for testing module versions in the distribution." )
		if $@;

	Test::Dist::VersionSync::ok_versions();

=head1 FUNCTIONS

=head2 ok_versions()

Verify that all the Perl modules in the distribution have the same version
number.

	# Default, use MANIFEST and MANIFEST.SKIP to find out what modules exist.
	ok_versions();
	
	# Optional, specify a list of modules to check for identical versions.
	ok_versions(
		modules =>
		[
			'Test::Module1',
			'Test::Module2',
			'Test::Module3',
		],
	);

=cut

sub ok_versions
{
	my ( %args ) = @_;
	my $modules = delete( $args{'modules'} );
	
	# Find out via Test::Builder if a plan has been declared, otherwise we'll
	# declare our own.
	my $builder = Test::More->builder();
	my $plan_declared = $builder->has_plan();
	
	# If a list of files was passed, verify that the argument is an arrayref.
	# Otherwise, load the files from MANIFEST and MANIFEST.SKIP.
	if ( defined( $modules) )
	{
		Test::More::plan( tests => 3 )
			unless $plan_declared;
		
		Test::More::isa_ok(
			$modules,
			'ARRAY',
			'modules list',
		);
	}
	else
	{
		Test::More::plan( tests => 5 )
			unless $plan_declared;
		
		$modules = _get_modules_from_manifest();
	}
	
	# If we have modules, check their versions.
	SKIP:
	{
		Test::More::skip(
			'No module found in the distribution.',
			2,
		) unless scalar( @$modules ) != 0;
		
		my $versions = {};
		Test::More::subtest(
			'Retrieve versions for all modules listed.',
			sub
			{
				Test::More::plan( tests => scalar( @$modules ) * 2 );
				
				foreach my $module ( @$modules )
				{
					Test::More::use_ok( $module );
					
					my $version = $module->VERSION();
					my $version_declared = Test::More::ok(
						defined( $version ),
						"Module $module declares a version.",
					);
					
					$version = '(undef)'
						unless $version_declared;
					
					$versions->{ $version } ||= [];
					push( @{ $versions->{ $version } }, $module );
				}
			}
		);
		
		is(
			scalar( keys %$versions ),
			1,
			'The modules declare only one version.',
		) || diag( 'Versions and the modules they were found in: ' . Dumper( $versions ) );
	}
}


=head2 import()

Import a test plan. This uses the regular Test::More plan options.

	use Test::Dist::VersionSync tests => 4;
	
	ok_versions();

Test::Dist::VersionSync also detects if Test::More was already used with a test
plan declared and will piggyback on it. For example:

	use Test::More tests => 2;
	use Test::Dist::VersionSync;
	
	ok( 1, 'Some Test' );
	ok_versions();

=cut

sub import
{
	my ( $self, %test_plan ) = @_;
	
	Test::More::plan( %test_plan )
		if scalar( keys %test_plan ) != 0;
}

=begin _private

=head1 INTERNAL FUNCTIONS

=head2 _get_modules_from_manifest

Retrieve an arrayref of modules using the MANIFEST file at the root of the
distribution. IF MANIFEST.SKIP is present, its list of exclusions is used
to filter out modules to verify.

	my $modules = _get_modules_from_manifest();

=end _private

=cut

sub _get_modules_from_manifest
{
	# Gather a list of exclusion patterns for files listed in MANIFEST.
	my $excluded_patterns;
	if ( -e 'MANIFEST.SKIP' )
	{
		Test::More::ok(
			open( MANIFESTSKIP, '<', 'MANIFEST.SKIP' ),
			'Retrieve MANIFEST.SKIP file.',
		) || diag( "Failed to open < MANIFEST.SKIP file: $!." );
		
		my $exclusions = [];
		foreach my $pattern ( <MANIFESTSKIP> )
		{
			chomp( $pattern );
			push( @$exclusions, $pattern );
		}
		
		$excluded_patterns = '(' . join( '|', @$exclusions ) . ')'
			if scalar( @$exclusions ) != 0;
	}
	else
	{
		Test::More::ok(
			1,
			'No MANIFEST.SKIP found, skipping.',
		);
	}
	
	# Retrieve the list of modules in MANIFEST.
	Test::More::ok(
		-e 'MANIFEST',
		'The MANIFEST file is present at the root of the distribution.',
	);
	
	Test::More::ok(
		open( MANIFEST, '<', 'MANIFEST' ),
		'Retrieve MANIFEST file.',
	) || diag( "Failed to open < MANIFEST file: $!." );
	
	my $modules = [];
	foreach my $file ( <MANIFEST> )
	{
		chomp( $file );
		next if defined( $excluded_patterns ) && $file =~ /$excluded_patterns/;
		next unless $file =~ m/^lib[\\\/](.*)\.pm$/;
		
		my $module = $1;
		$module =~ s/[\\\/]/::/g;
		push( @$modules, $module );
	}
	
	return $modules;
}


=head1 AUTHOR

Guillaume Aubert, C<< <aubertg at cpan.org> >>.


=head1 BUGS

Please report any bugs or feature requests to C<bug-test-dist-versionsync at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-dist-versionsync>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

	perldoc Test::Dist::VersionSync


You can also look for information at:

=over

=item *

RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=test-dist-versionsync>

=item *

AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/test-dist-versionsync>

=item *

CPAN Ratings

L<http://cpanratings.perl.org/d/test-dist-versionsync>

=item *

Search CPAN

L<http://search.cpan.org/dist/test-dist-versionsync/>

=back


=head1 COPYRIGHT & LICENSE

Copyright 2012 Guillaume Aubert.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1;

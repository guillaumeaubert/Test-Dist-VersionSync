use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
	module_name         => 'Test::Dist::VersionSync',
	license             => 'artistic',
	dist_author         => q{Guillaume Aubert <aubertg@cpan.org>},
	dist_version_from   => 'lib/Test/Dist/VersionSync.pm',
	build_requires      =>
	{
		'Carp'                  => 0,
		'Data::Dumper'          => 0,
		'Test::Builder::Tester' => 0,
		'Test::More'            => 0.94,
	},
	requires            =>
	{
		'perl'         => 5.006,
	},
	add_to_cleanup      =>
	[
		'Test-Dist-VersionSync-*',
	],
	create_makefile_pl  => 'traditional',
	configure_requires  =>
	{
		'Module::Build'         => 0,
	},
	meta_merge          =>
	{
		resources               =>
		{
			repository  => 'https://github.com/guillaumeaubert/Test-Dist-VersionSync',
			homepage    => 'https://metacpan.org/release/Test-Dist-VersionSync',
			bugtracker  => 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=test-dist-versionsync',
		},
	},
);

$builder->create_build_script();

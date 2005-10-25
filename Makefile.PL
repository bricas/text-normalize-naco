use ExtUtils::MakeMaker;

WriteMakefile(
	NAME         => 'Text::Normalize::NACO',
	VERSION_FROM => 'lib/Text/Normalize/NACO.pm',
	PREREQ_PM    => {
		'Test::More'      => 0
	}
);

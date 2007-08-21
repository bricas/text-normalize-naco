use inc::Module::Install 0.67;

name 'Text-Normalize-NACO';
perl_version '5.008'; # need 5.008 for unicode
all_from 'lib/Text/Normalize/NACO.pm';

requires 'Text::Unidecode';
requires 'Test::More';

auto_install;
WriteAll;

use inc::Module::Install;
name 'URI-ShortUrlServices-Expand';
all_from 'lib/URI/ShortUrlServices/Expand.pm';
readme_from 'lib/URI/ShortUrlServices/Expand.pm';
readme_markdown_from 'lib/URI/ShortUrlServices/Expand.pm';
readme_pod_from 'lib/URI/ShortUrlServices/Expand.pm';
githubmeta;

requires 'Regexp::Assemble';
requires 'HTTP::Lite';
requires 'JSON';
requires 'WebService::Wedata';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;

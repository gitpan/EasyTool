require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
        'NAME' => 'EasyTool',
        'VERSION'       =>      '2006.06.13',
        dist            =>      { COMPRESS => 'gzip -9f', SUFFIX => 'gz'}
);
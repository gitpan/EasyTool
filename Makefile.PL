require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
	'NAME' => 'EasyTool',
	'VERSION_FROM'	=>	'EasyTool.pm',
	'PREREQ_PM'     => {
		'Time::Local'=>'0',
		'MIME::Base64'=>'0',
		'MIME::QuotedPrint'=>'0',
		'Digest::MD5'=>'0',
		'FileHandle'=>'0'
 	},
	dist		=>	{ COMPRESS => 'gzip -9f', SUFFIX => '.gz'}
);


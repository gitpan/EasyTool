package EasyTool;
use strict;
use warnings(FATAL=>'all');

use Time::Local;#required be TimeFunc

BEGIN{
	$EasyTool::VERSION='2006.06.13';
};
sub foo{1};
sub _name_pkg_name{__PACKAGE__;}

require EasyTool::TimeFunc;

1;

__END__
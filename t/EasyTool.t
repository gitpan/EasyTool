use strict;
use warnings(FATAL=>'all');
use Time::Local;
use EasyTool;

#===export EasyTest Function
sub plan {&EasyTest::std_plan};
*ok = \&EasyTest::ok;
sub DIE {&EasyTest::DIE};
sub NO_DIE {&EasyTest::NO_DIE};
sub ANY {&EasyTest::ANY};
#==============================

plan(216);


sub localtimezone {
        return int ((Time::Local::timegm(0,0,0,1,0,2000)-Time::Local::timelocal(0,0,0,1,0,2000))/3600);
}

my ($true,$false)=(1,'');

#EasyTool::is_int, test 1-18
ok(&DIE, \&EasyTool::is_int, []);
ok($true,\&EasyTool::is_int,[0]);
ok($true, \&EasyTool::is_int,[1]);
ok($true,\&EasyTool::is_int,[-1]);
ok($true,\&EasyTool::is_int,[-2147483648]);
ok($true,\&EasyTool::is_int,[2147483647]);
ok($false,\&EasyTool::is_int,[-2147483649]);
ok($false,\&EasyTool::is_int,[2147483648]);
ok($true,\&EasyTool::is_int,[10,-10,20]);
ok($true,\&EasyTool::is_int,[-10,-10,20]);
ok($false,\&EasyTool::is_int,[20,-10,20]);
ok($false,\&EasyTool::is_int,[21,-10,20]);
ok($false,\&EasyTool::is_int,[-11,-10,20]);
ok($true,\&EasyTool::is_int,[22147483648,0,undef]);
ok($false,\&EasyTool::is_int,[-1,0,undef]);
ok($true,\&EasyTool::is_int,[-22147483648,undef,0]);
ok($false,\&EasyTool::is_int,[1,undef,0]);
ok(&DIE, \&EasyTool::is_int, ['1', 2, 3, 4]);

#EasyTool::is_id, test 19-22
ok($false, \&EasyTool::is_id, [0]);
ok($true, \&EasyTool::is_id, [1]);
ok($true, \&EasyTool::is_id, [4294967295]);
ok($false, \&EasyTool::is_id, [4294967296]);

#EasyTool::is_email, test 23-31
ok(&DIE, \&EasyTool::is_email, []);
ok($false, \&EasyTool::is_email, [undef]);
ok($true, \&EasyTool::is_email, ['_@0-A.zA']);
ok($true, \&EasyTool::is_email, ['0@0.zAktfG']);
ok($false, \&EasyTool::is_email, ['t@t.zAktfGa']);
ok($false, \&EasyTool::is_email, ['t@test.a']);
ok($true, \&EasyTool::is_email, ['__-.-b@0.0.com']);
ok($false, \&EasyTool::is_email, ['tadas']);
ok($false, \&EasyTool::is_email, ['test@a..com']);

#EasyTool::trim, test 32-37
ok(&DIE, \&EasyTool::trim, []);
ok(undef, \&EasyTool::trim, [undef]);
ok("test", \&EasyTool::trim, ["test"]);
ok("test", \&EasyTool::trim, [" \t test"]);
ok("test", \&EasyTool::trim, ["  \rtest \n "]);
ok("test", \&EasyTool::trim, ["test \f "]);

#EasyTool::in, test 38-44
ok(&DIE, \&EasyTool::in, []);
ok($true, \&EasyTool::in, [1, 1]);
ok($false, \&EasyTool::in, [1]);
ok($true, \&EasyTool::in, ['a', {'a' => 1, 'b' => 2}]);
ok($false, \&EasyTool::in, [1, {'a' => 1, 'b' => 2}]);
ok($false, \&EasyTool::in, [undef, {'a' => 1, 'b' => 2}]);
ok($true, \&EasyTool::in, [undef, 1, undef]);

#EasyTool::ifnull, test 45-48
ok(&DIE, \&EasyTool::ifnull, [1]);
ok(1, \&EasyTool::ifnull, [1, 2]);
ok(2, \&EasyTool::ifnull, [undef, 2]);
ok(&DIE, \&EasyTool::ifnull, [1, 2, 3]);

#EasyTool::read_file
#EasyTool::write_file
#EasyTool::append_file
#EasyTool::delete_file
#EasyTool::csv_2_array
#EasyTool::array_2_csv, test 49-54
ok(1, \&EasyTool::array_2_csv, ["test.csv", [[1, 'a'], [2, 'b']]]);
ok("\"1\",\"a\"\n\"2\",\"b\"", \&EasyTool::read_file, ["test.csv"]);
ok(8, \&EasyTool::write_file, ["test.csv", "3,c\n4,d\n"]);
ok(8, \&EasyTool::append_file, ["test.csv", "5,e\n6,f\n"]);
ok([[3, 'c'], [4, 'd'], [5, 'e'], [6, 'f']], \&EasyTool::csv_2_array, ["test.csv"]);
ok(1, \&EasyTool::delete_file, ["test.csv"]);

#EasyTool::md5_hex, test 55
ok('098f6bcd4621d373cade4e832627b4f6', \&EasyTool::md5_hex, ["test"]);

#EasyTool::crc32, test 56
ok(3632233996, \&EasyTool::crc32, ["test"]);

#EasyTool::encode_hex
#EasyTool::decode_hex, test 57
ok("test string", \&EasyTool::decode_hex, [EasyTool::encode_hex("test string")]);

#EasyTool::encode_base64
#EasyTool::decode_base64, test 58
ok("test string", \&EasyTool::decode_base64, [EasyTool::encode_base64("test string")]);

#EasyTool::url_encode
#EasyTool::url_decode, test 59
ok('<&%$/ \|=+_]{>@^', \&EasyTool::url_decode, [EasyTool::url_encode('<&%$/ \|=+_]{>@^')]);

#EasyTool::html_encode
#EasyTool::html_decode, test 60
ok(";<>&lt\"", \&EasyTool::html_decode, [EasyTool::html_encode(";<>&lt\"")]);

#EasyTool::qquote
#EasyTool::qquote_bin, test 61-62
ok("\"\\\\n\"", \&EasyTool::qquote, ['\n']);
ok("\"\\x5C\\x6E\"", \&EasyTool::qquote_bin, ['\n']);

#EasyTool::dump, test 63-66
ok('20', \&EasyTool::dump, ['20']);
ok('[10, 20]', \&EasyTool::dump, [['10', '20']]);
ok('{"num1" => 10, "num2" => 20}', \&EasyTool::dump, [{"num1" => "10", "num2" => "20"}]);
ok('()', \&EasyTool::dump, []);

#EasyTool::test_var, test 67-68
ok(1, \&EasyTool::test_var, [1]);
ok(1, \&EasyTool::test_var, []);


#EasyTool::_time_func_is_int, test 69-84
ok($true,\&EasyTool::_time_func_is_int,[0]);
ok($true, \&EasyTool::_time_func_is_int,[1]);
ok($true,\&EasyTool::_time_func_is_int,[-1]);
ok($true,\&EasyTool::_time_func_is_int,[-2147483648]);
ok($true,\&EasyTool::_time_func_is_int,[2147483647]);
ok($false,\&EasyTool::_time_func_is_int,[-2147483649]);
ok($false,\&EasyTool::_time_func_is_int,[2147483648]);
ok($true,\&EasyTool::_time_func_is_int,[10,-10,20]);
ok($true,\&EasyTool::_time_func_is_int,[-10,-10,20]);
ok($false,\&EasyTool::_time_func_is_int,[20,-10,20]);
ok($false,\&EasyTool::_time_func_is_int,[21,-10,20]);
ok($false,\&EasyTool::_time_func_is_int,[-11,-10,20]);
ok($true,\&EasyTool::_time_func_is_int,[22147483648,0,undef]);
ok($false,\&EasyTool::_time_func_is_int,[-1,0,undef]);
ok($true,\&EasyTool::_time_func_is_int,[-22147483648,undef,0]);
ok($false,\&EasyTool::_time_func_is_int,[1,undef,0]);

#EasyTool::time_2_str, test 85-90
ok('1983-03-07 01:02:03',\&EasyTool::time_2_str,['1983-03-07 01:02:03']);
ok(&DIE,\&EasyTool::time_2_str,[]);
ok(&DIE,\&EasyTool::time_2_str,[1,2,3]);
ok("1983-03-07 01:02:03 1983-03-07 ".(415846923-&localtimezone()*3600)." 1983 83 03 3 07 7 1 1 01 01 AM am 02 2 03 3",\&EasyTool::time_2_str,['1983-03-07 01:02:03','%datetime %date %timestamp %yyyy %yy %MM %M %dd %d %h12 %h %hh12 %hh %AP %ap %mm %m %ss %s']);
ok('2000-01-01 00:30:00 am',\&EasyTool::time_2_str,['2000-01-01 00:30:00','%yyyy-%MM-%dd %hh12:%mm:%ss %ap']);
ok('2000-01-01 00:30:00 pm',\&EasyTool::time_2_str,['2000-01-01 12:30:00','%yyyy-%MM-%dd %hh12:%mm:%ss %ap']);

#EasyTool::time_2_timestamp, test 91-105
ok(&DIE,\&EasyTool::time_2_timestamp,[]);
ok(&DIE,\&EasyTool::time_2_timestamp,[946656000,2]);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983-03-07 01:02:03']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,[' 1983-03-07 01:02:03 ']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983-03-07T01:02:03']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983/03/07 01:02:03']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983.03.07 01:02:03']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983-03-07 01.02.03']);
ok(415846923-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['83-3-7 1:2:3']);
ok(415843200-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['1983-03-07']);
ok(946688523-&localtimezone()*3600,\&EasyTool::time_2_timestamp,['01:02:03']);
ok(946656000,\&EasyTool::time_2_timestamp,['946656000']);
ok(&DIE,\&EasyTool::time_2_timestamp,[10]);
ok(&DIE,\&EasyTool::time_2_timestamp,[0]);
ok(&DIE,\&EasyTool::time_2_timestamp,[-1]);

#EasyTool::is_time, test 106-122
ok(&DIE,\&EasyTool::is_time,[]);
ok(&DIE,\&EasyTool::is_time,[946656000,2]);
ok(1,\&EasyTool::is_time,['1983-03-07 01:02:03']);
ok(1,\&EasyTool::is_time,[' 1983-03-07 01:02:03 ']);
ok(1,\&EasyTool::is_time,['1983-03-07T01:02:03']);
ok(1,\&EasyTool::is_time,['1983/03/07 01:02:03']);
ok(1,\&EasyTool::is_time,['1983.03.07 01:02:03']);
ok(1,\&EasyTool::is_time,['1983-03-07 01.02.03']);
ok(1,\&EasyTool::is_time,['83-3-7 1:2:3']);
ok(1,\&EasyTool::is_time,['1983-03-07']);
ok(1,\&EasyTool::is_time,['01:02:03']);
ok(1,\&EasyTool::is_time,['946656000']);
ok('',\&EasyTool::is_time,[10]);
ok('',\&EasyTool::is_time,[0]);
ok('',\&EasyTool::is_time,[-1]);
ok('',\&EasyTool::is_time,[{}]);
ok('',\&EasyTool::is_time,[[]]);

#EasyTool::hash_2_timestamp, test 123-126
ok(&DIE,\&EasyTool::hash_2_timestamp,[]);
ok(&DIE,\&EasyTool::hash_2_timestamp,[{},2]);
ok(415846923-&localtimezone()*3600,\&EasyTool::hash_2_timestamp,[{year=>1983,month=>3,day=>7,hour=>1,min=>2,sec=>3}]);
ok(&DIE,\&EasyTool::hash_2_timestamp,[{year=>1983,month=>'aaa',day=>7,hour=>1,min=>2,sec=>3}]);

#EasyTool::time_2_hash, test 127-130
ok(&DIE,\&EasyTool::time_2_hash,[]);
ok(&DIE,\&EasyTool::time_2_hash,[946656000,2]);
ok({year=>1983,month=>3,day=>7,hour=>1,min=>2,sec=>3},\&EasyTool::time_2_hash,['1983-03-07 01:02:03']);
ok({year=>1983,month=>3,day=>7,hour=>1,min=>2,sec=>3},\&EasyTool::time_2_hash,[415846923-&localtimezone()*3600]);

#EasyTool::now, test 131
ok(CORE::time(),\&EasyTool::now,[]);

#EasyTool::time, test 132
ok(CORE::time(),\&EasyTool::time,[]);

#EasyTool::timestamp_now, test 133
ok(CORE::time(),\&EasyTool::timestamp_now,[]);

#EasyTool::date_now, test 134
local $_=[localtime(CORE::time())];
ok(sprintf('%04s-%02s-%02s',$_->[5]+1900,$_->[4]+1,$_->[3]),\&EasyTool::date_now,[]);

#EasyTool::datetime_now, test 135
local $_=[localtime(CORE::time())];
ok(sprintf('%04s-%02s-%02s %02s:%02s:%02s',$_->[5]+1900,$_->[4]+1,$_->[3],$_->[2],$_->[1],$_->[0]),\&EasyTool::datetime_now,[]);

#EasyTool::day_of_month, test 136-155
ok(&DIE,\&EasyTool::day_of_month,[]);
ok(&DIE,\&EasyTool::day_of_month,[2001]);
ok(&DIE,\&EasyTool::day_of_month,[2001,9,2]);
ok(31,\&EasyTool::day_of_month,[2000,1]);
ok(29,\&EasyTool::day_of_month,[2000,2]);
ok(31,\&EasyTool::day_of_month,[2000,3]);
ok(30,\&EasyTool::day_of_month,[2000,4]);
ok(31,\&EasyTool::day_of_month,[2000,5]);
ok(30,\&EasyTool::day_of_month,[2000,6]);
ok(31,\&EasyTool::day_of_month,[2000,7]);
ok(31,\&EasyTool::day_of_month,[2000,8]);
ok(30,\&EasyTool::day_of_month,[2000,9]);
ok(31,\&EasyTool::day_of_month,[2000,10]);
ok(30,\&EasyTool::day_of_month,[2000,11]);
ok(31,\&EasyTool::day_of_month,[2000,12]);
ok(&DIE,\&EasyTool::day_of_month,[2000,13]);
ok(28,\&EasyTool::day_of_month,[2001,2]);
ok(28,\&EasyTool::day_of_month,[2002,2]);
ok(28,\&EasyTool::day_of_month,[2003,2]);
ok(29,\&EasyTool::day_of_month,[2004,2]);

#EasyTool::day_of_week, test 156-164
ok(&DIE,\&EasyTool::day_of_week,[]);
ok(&DIE,\&EasyTool::day_of_week,[1, 2]);
ok(0, \&EasyTool::day_of_week,['2006-07-02']);
ok(1, \&EasyTool::day_of_week,['2006-07-03']);
ok(2, \&EasyTool::day_of_week,['2006-07-04']);
ok(3, \&EasyTool::day_of_week,['2006-07-05']);
ok(4, \&EasyTool::day_of_week,['2006-07-06']);
ok(5, \&EasyTool::day_of_week,['2006-07-07']);
ok(6, \&EasyTool::day_of_week,['2006-07-08']);

#EasyTool::localtimezone, test 165
ok(&localtimezone(),\&EasyTool::localtimezone,[]);

#timestamp_add, test 166-173
ok(DIE,\&EasyTool::timestamp_add,[]);
ok(DIE,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6},1]);
ok(453013629-&localtimezone()*3600,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6}]);
ok(1102469523-&localtimezone()*3600,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{year=>20,month=>20,day=>30,hour=>40,min=>500,sec=>600}]);
ok(415846923-&localtimezone()*3600,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{}]);
ok(447728823-&localtimezone()*3600,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{year=>1,day=>3,min=>5}]);
ok(421131729-&localtimezone()*3600,\&EasyTool::timestamp_add,['1983-03-07 01:02:03',{month=>2,hour=>4,sec=>6}]);
ok(DIE,\&EasyTool::timestamp_add,['1983-03-31',{month=>1}]);

#timestamp_set, test 174-182
ok(DIE,\&EasyTool::timestamp_set,[]);
ok(DIE,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9},1]);
ok(453013629-&localtimezone()*3600,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9}]);
ok(1102469523-&localtimezone()*3600,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{year=>2004,month=>12,day=>8,hour=>1,min=>32,sec=>03}]);
ok(415846923-&localtimezone()*3600,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{}]);
ok(447728823-&localtimezone()*3600,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{year=>1984,day=>10,min=>7}]);
ok(421131729-&localtimezone()*3600,\&EasyTool::timestamp_set,['1983-03-07 01:02:03',{month=>5,hour=>5,sec=>9}]);
ok(DIE,\&EasyTool::timestamp_set,['1983-03-31',{month=>4}]);
ok(DIE,\&EasyTool::timestamp_set,['1983-02-28',{day=>29}]);

#date_add, test 183-190
ok(DIE,\&EasyTool::date_add,[]);
ok(DIE,\&EasyTool::date_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6},1]);
ok('1984-05-10',\&EasyTool::date_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6}]);
ok('2004-12-08',\&EasyTool::date_add,['1983-03-07 01:02:03',{year=>20,month=>20,day=>30,hour=>40,min=>500,sec=>600}]);
ok('1983-03-07',\&EasyTool::date_add,['1983-03-07 01:02:03',{}]);
ok('1984-03-10',\&EasyTool::date_add,['1983-03-07 01:02:03',{year=>1,day=>3,min=>5}]);
ok('1983-05-07',\&EasyTool::date_add,['1983-03-07 01:02:03',{month=>2,hour=>4,sec=>6}]);
ok(DIE,\&EasyTool::date_add,['1983-03-31',{month=>1}]);

#date_set, test 191-199
ok(DIE,\&EasyTool::date_set,[]);
ok(DIE,\&EasyTool::date_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9},1]);
ok('1984-05-10',\&EasyTool::date_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9}]);
ok('2004-12-08',\&EasyTool::date_set,['1983-03-07 01:02:03',{year=>2004,month=>12,day=>8,hour=>1,min=>32,sec=>03}]);
ok('1983-03-07',\&EasyTool::date_set,['1983-03-07 01:02:03',{}]);
ok('1984-03-10',\&EasyTool::date_set,['1983-03-07 01:02:03',{year=>1984,day=>10,min=>7}]);
ok('1983-05-07',\&EasyTool::date_set,['1983-03-07 01:02:03',{month=>5,hour=>5,sec=>9}]);
ok(DIE,\&EasyTool::date_set,['1983-03-31',{month=>4}]);
ok(DIE,\&EasyTool::date_set,['1983-02-28',{day=>29}]);

#datetime_add, test 200-207
ok(DIE,\&EasyTool::datetime_add,[]);
ok(DIE,\&EasyTool::datetime_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6},1]);
ok('1984-05-10 05:07:09',\&EasyTool::datetime_add,['1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6}]);
ok('2004-12-08 01:32:03',\&EasyTool::datetime_add,['1983-03-07 01:02:03',{year=>20,month=>20,day=>30,hour=>40,min=>500,sec=>600}]);
ok('1983-03-07 01:02:03',\&EasyTool::datetime_add,['1983-03-07 01:02:03',{}]);
ok('1984-03-10 01:07:03',\&EasyTool::datetime_add,['1983-03-07 01:02:03',{year=>1,day=>3,min=>5}]);
ok('1983-05-07 05:02:09',\&EasyTool::datetime_add,['1983-03-07 01:02:03',{month=>2,hour=>4,sec=>6}]);
ok(DIE,\&EasyTool::datetime_add,['1983-03-31',{month=>1}]);

#datetime_set, test 208-216
ok(DIE,\&EasyTool::datetime_set,[]);
ok(DIE,\&EasyTool::datetime_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9},1]);
ok('1984-05-10 05:07:09',\&EasyTool::datetime_set,['1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9}]);
ok('2004-12-08 01:32:03',\&EasyTool::datetime_set,['1983-03-07 01:02:03',{year=>2004,month=>12,day=>8,hour=>1,min=>32,sec=>03}]);
ok('1983-03-07 01:02:03',\&EasyTool::datetime_set,['1983-03-07 01:02:03',{}]);
ok('1984-03-10 01:07:03',\&EasyTool::datetime_set,['1983-03-07 01:02:03',{year=>1984,day=>10,min=>7}]);
ok('1983-05-07 05:02:09',\&EasyTool::datetime_set,['1983-03-07 01:02:03',{month=>5,hour=>5,sec=>9}]);
ok(DIE,\&EasyTool::datetime_set,['1983-03-31',{month=>4}]);
ok(DIE,\&EasyTool::datetime_set,['1983-02-28',{day=>29}]);

1;

















package EasyTest;
use strict;
use warnings(FATAL=>'all');

#===================================
#===Module  : EasyTest
#===Comment : module for writing test script
#===================================

#===================================
#===Author  : qian.yu            ===
#===Email   : foolfish@cpan.org  ===
#===MSN     : qian.yu@adways.net ===
#===QQ      : 19937129           ===
#===Homepage: www.lua.cn         ===
#===================================

use Exporter 'import';
use Test qw();

our $bool_std_test;
our $plan_test_count;
our $test_count;
our $succ_test;
our $fail_test;
our ($true,$false);

BEGIN{
        our @EXPORT = qw(&ok &plan &std_plan &DIE &NO_DIE);
        $bool_std_test='';
        $plan_test_count=undef;
        $test_count=0;
        $succ_test=0;
        $fail_test=0;
        ($true,$false) = (1,'');
};

sub foo{1};
sub _name_pkg_name{__PACKAGE__;}

#===ok($result,$value); if $result same as $value test succ, else test fail
#===ok($result,$func,$ra_param);#same as ok($result,$func,$ra_param,0);
#===ok($ra_result,$func,$ra_param,1); test result in array  mode
#===ok($   result,$func,$ra_param,0); test result in scalar mode
sub ok{
        my $param_count=scalar(@_);
        if($param_count==2){
                if(&dump($_[0]) eq &dump($_[1])){
                        $test_count++;$succ_test++;
                        if($bool_std_test){
                                Test::ok($true);
                        }else{
                                print "ok $test_count\n";
                        }
                        return $true;
                }else{
                        $test_count++;$fail_test++;
                        if($bool_std_test){
                                Test::ok($false);
                        }else{
                                my $caller_info=sprintf('LINE %04s',[caller(0)]->[2]);
                                print "not ok $test_count $caller_info\n";
                        }
                        return $false;
                }
        }elsif($param_count==4||$param_count==3){
                my $result;
                my $mode;
                if($param_count==3){
                        $mode=1;
                }elsif($param_count==4&&defined($_[3])&&$_[3]==0){
                        $mode=1;
                }elsif($param_count==4&&defined($_[3])&&$_[3]==1){
                        $mode=2;
                }else{#default
                        $mode=1;
                }
                if($mode==1){
                        eval{$result=$_[1]->(@{$_[2]});};
                }elsif($mode==2){
                        eval{$result=[$_[1]->(@{$_[2]})];};
                }else{
                        CORE::die 'BUG';
                }
                if($@){
                        undef $@;
                        if(DIE($_[0])){
                                $test_count++;$succ_test++;
                                if($bool_std_test){
                                        Test::ok($true);
                                }else{
                                        print "ok $test_count\n";
                                }
                                return $true;
                        }else{
                                $test_count++;$fail_test++;
                                if($bool_std_test){
                                        Test::ok($false);
                                }else{
                                        my $caller_info=sprintf('LINE %04s',[caller(0)]->[2]);
                                        print "not ok $test_count $caller_info\n";
                                }
                                return $false;
                        }
                }else{
                        if ((defined $_[0]) && (defined $result)){
                            if (ref $_[0] ne 'ARRAY'){
                                if (ANY($_[0])){
                                    $_[0] = undef;
                                    $result = undef;
                                }
                            }else{
                                if($#{$_[0]} == $#$result){
                                    foreach(0 .. $#{$_[0]}){
                                        if(ANY($_[0][$_])){
                                            @{$_[0]}[$_] = undef;
                                            @$result[$_] = undef;
                                        }
                                    }
                                }
                            }
                        }
                        if(NO_DIE($_[0])){
                                $test_count++;$succ_test++;
                                if($bool_std_test){
                                        Test::ok($true);
                                }else{
                                        print "ok $test_count\n";
                                }
                                return $true;
                        }elsif(&dump($_[0]) eq &dump($result)){
                                $test_count++;$succ_test++;
                                if($bool_std_test){
                                        Test::ok($true);
                                }else{
                                        print "ok $test_count\n";
                                }
                                return $true;
                        }else{
                                $test_count++;$fail_test++;
                                if($bool_std_test){
                                        Test::ok($false);
                                }else{
                                        my $caller_info=sprintf('LINE %04s',[caller(0)]->[2]);
                                        print "not ok $test_count $caller_info\n";
                                }
                                return $false;
                        }
                }
        }else{
                CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'ok: param count should be 2, 3, 4');
        }
}

sub plan($){
        $plan_test_count=$_[0];
        print "plan to test $plan_test_count \n";
}

sub std_plan($){
        $plan_test_count=$_[0];
        $bool_std_test=1;
        Test::plan(tests=>$plan_test_count);
}

sub DIE{
        my $code=1;
        if(scalar(@_)==0){
                return bless [$code,'DIE'],'Framework::EasyTest::CONSTANT';
        }elsif(scalar(@_)==1){
                return ref $_[0] eq 'Framework::EasyTest::CONSTANT' && $_[0]->[0]==$code?1:'';
        }else{
                die 'EasyTest::DIE: param number should be 0 or 1';
        }
}

sub NO_DIE{
        my $code=2;
        if(scalar(@_)==0){
                return bless [$code,'NO_DIE'],'Framework::EasyTest::CONSTANT';
        }elsif(scalar(@_)==1){
                return ref $_[0] eq 'Framework::EasyTest::CONSTANT' && $_[0]->[0]==$code?1:'';
        }else{
                die 'EasyTest::NO_DIE: param number should be 0 or 1';
        }
}

sub ANY{
        my $code=3;
        if(scalar(@_)==0){
                return bless [$code,'ANY'],'Framework::EasyTest::CONSTANT';
        }elsif(scalar(@_)==1){
                return ref $_[0] eq 'Framework::EasyTest::CONSTANT' && $_[0]->[0]==$code?1:'';
        }else{
                die 'EasyTest::ANY: param number should be 0 or 1';
        }
}

END{
        if(!$bool_std_test){
                if(defined($plan_test_count)){
                        if($plan_test_count==($succ_test+$fail_test)&&$fail_test==0){
                                print "plan test $plan_test_count ,finally test $test_count, $succ_test succ,$fail_test fail,test successful!\n";
                        }else{
                                CORE::die "plan test $plan_test_count ,finally test $test_count, $succ_test succ,$fail_test fail,test failed!\n";
                        }
                }else{
                        print "finally test $test_count, $succ_test succ,$fail_test fail\n";
                }
        }
}

sub qquote {
        local($_) = shift;
        s/([\\\"\@\$])/\\$1/g;
        s/([^\x00-\x7f])/sprintf("\\x{%04X}",ord($1))/eg if utf8::is_utf8($_);
        return qq("$_") unless
                /[^ !"\#\$%&'()*+,\-.\/0-9:;<=>?\@A-Z[\\\]^_`a-z{|}~]/;  # fast exit
        s/([\a\b\t\n\f\r\e])/{
                "\a" => "\\a","\b" => "\\b","\t" => "\\t","\n" => "\\n",
            "\f" => "\\f","\r" => "\\r","\e" => "\\e"}->{$1}/eg;
        s/([\0-\037\177])/'\\x'.sprintf('%02X',ord($1))/eg;
        s/([\200-\377])/'\\x'.sprintf('%02X',ord($1))/eg;
        return qq("$_");
}

sub qquote_bin{
        local($_) = shift;
        s/([\x00-\xff])/'\\x'.sprintf('%02X',ord($1))/eg;
        s/([^\x00-\x7f])/sprintf("\\x{%04X}",ord($1))/eg if utf8::is_utf8($_);
        return qq("$_");
}

sub dump{
        my $max_line=80;
        my $param_count=scalar(@_);
        my ($flag,$str1,$str2);
        if($param_count==1){
                my $data=$_[0];
                my $type=ref $data;
                if($type eq 'ARRAY'){
                        my $strs=[];
                        foreach(@$data){push @$strs,&dump($_);}

                        $str1='[';$flag=0;
                        foreach(@$strs){$str1.=$_.",\x20";$flag=1;}
                        if($flag==1){chop($str1);chop($str1);}
                        $str1.=']';

                        $str2='[';
                        foreach(@$strs){s/\n/\n\x20\x20/g;$str2.="\n\x20\x20".$_.',';}
                        $str2.="\n]";

                        return length($str1)>$max_line?$str2:$str1;
                }elsif($type eq 'HASH'){
                        my $strs=[];
                        foreach(keys(%$data)){push @$strs,[qquote($_),&dump($data->{$_})];}

                        $str1='{';$flag=0;
                        foreach(@$strs){$str1.="$_->[0]\x20=>\x20$_->[1],\x20";$flag=1;}
                        if($flag==1){chop($str1);chop($str1);}
                        $str1.='}';

                        $str2='{';
                        foreach(@$strs){ $_->[1]=~s/\n/\n\x20\x20/g;$str2.="\n\x20\x20$_->[0]\x20=>\x20$_->[1],";}
                        $str2.="\n}";

                        return length($str1)>$max_line?$str2:$str1;
                }elsif($type eq 'SCALAR'||$type eq 'REF'){
                        return "\\".&dump($$data);
                }elsif($type eq ''){
                        $flag=0;
                        if(!defined($data)){return 'undef'};
                        eval{if($data eq int $data){$flag=1;}};
                        if($@){undef $@;}
                        if($flag==0){return qquote($data);}
                        elsif($flag==1){return $data;}
                        else{ die 'dump:BUG!';}
                }else{
                        return ''.$data;#===if not a simple type
                }
        }else{
                my $strs=[];
                foreach(@_){push @$strs,&dump($_);}

                $str1='(';
                $flag=0;
                foreach(@$strs){$str1.=$_.",\x20";$flag=1;}
                if($flag==1){chop($str1);chop($str1);}
                $str1.=')';

                $str2='(';
                foreach(@$strs){s/\n/\n\x20\x20/g;$str2.="\n\x20\x20".$_.',';}
                $str2.="\n)";

                return length($str1)>$max_line?$str2:$str1;
        }
}

1;

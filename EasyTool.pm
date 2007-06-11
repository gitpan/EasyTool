package EasyTool;
use strict;
use warnings(FATAL=>'all');

our $VERSION = '1.0.7';

#===================================
#===Module  : 43f0273ba176b02f
#===Version : 43f0078871b146ba
#===================================

#===================================
#===Module  : Framework::EasyTool
#===File    : lib/Framework/EasyTool.pm
#===Comment : tools
#===Require : Time::Local FileHandle Digest::MD5 MIME::Base64 MIME::QuotedPrint
#===================================

#===================================
#===Author  : qian.yu            ===
#===Email   : foolfish@cpan.org  ===
#===MSN     : qian.yu@adways.net ===
#===QQ      : 19937129           ===
#===Homepage: www.lua.cn         ===
#===================================

#=======================================
#===Author  : huang.shuai            ===
#===Email   : huang.shuai@adways.net ===
#===MSN     : huang.shuai@adways.net ===
#=======================================

#===1.0.7(2007-06-11): fix CORE::die bug, add mkdirs function, modify ifnull function, modify write_file function
#===1.0.6(2007-03-20): add lwp get web page function
#===1.0.5(2007-02-09): fix bug in _time_func_is_int and is_int
#===1.0.4(2006-09-08): add function text_2_html
#===1.0.3(2006-08-18): fix date bug
#===1.0.2(2006-07-28): add function crc32
#===1.0.1(2006-07-27): fix bugs, add functions, document format
#===1.0.0(2006-06-12): first release

use Time::Local;
use FileHandle;

sub foo{1};
sub _name_pkg_name{__PACKAGE__;}

#===========================================
#===ture and false
  sub _name_true{1;}
  sub _name_false{'';}
  sub true{scalar(@_)==1?defined($_[0])&&($_[0] eq &_name_true):&_name_true;}
  sub false{scalar(@_)==1?defined($_[0])&&($_[0] eq &_name_false):&_name_false;}
#===========================================

#===========================================
#====regional and language
  sub _name_un{'un';} #Country Independent
  sub _name_cn{'cn';} #China
  sub _name_jp{'jp';} #Japan
#===========================================

#===========================================
#===names for encoding
  sub _name_encoding{[&_name_utf8,&_name_ascii,&_name_gb2312,&_name_gbk,&_name_gb18030,&_name_euc_jp,&_name_shift_jis,&_name_iso_2022_jp];}
  #===un
  sub _name_utf8{'utf8';}
  sub _name_ascii{'ascii';}
  #===cn
  sub _name_gb2312{'gb2312';}
  sub _name_gbk{'gbk';}
  sub _name_gb18030{'gb18030';}
  #===jp
  sub _name_euc_jp{'euc-jp';}
  sub _name_shift_jis{'shift-jis';}
  sub _name_iso_2022_jp{'iso-2022-jp';}

#===========================================

#===========================================
#===datetime
  #===un
  sub _name_datetime_zero_gmt{946684800;}
  #===cn
  sub _name_timezone_china{8;}
  sub _name_datetime_zero_china{946656000;}
  #===jp
  sub _name_timezone_japan{9;}
  sub _name_datetime_zero_japan{946652400;}
#===========================================

#===========================================
#===options

  #default datetime format, in Adways China Office, we like '%04s/%02s/%02s %02s:%02s:%02s', and in Japan Office maybe they prefer '%04s/%02s/%02s %02s:%02s:%02s'
  #!THIS IS NOT EASY TO CONFIG,PLEASE DON'T DO BIG CHANGE
  #our $_DEFAULT_DATETIME_FORMAT='%04s/%02s/%02s %02s:%02s:%02s';
  
  
our $_TIMEFUNC_DEFAULT_DATETIME_FORMAT;
our $_TIMEFUNC_DEFAULT_DATE_FORMAT;
our $_TIMEFUNC_MIN_TIMESTAMP;
our $_TIMEFUNC_MAX_TIMESTAMP;

BEGIN{
  $_TIMEFUNC_DEFAULT_DATETIME_FORMAT='%04s-%02s-%02s %02s:%02s:%02s';
  $_TIMEFUNC_DEFAULT_DATE_FORMAT='%04s-%02s-%02s';

  $_TIMEFUNC_MIN_TIMESTAMP=31536000;   #'1971-01-01 00:00:00 GMT'
  $_TIMEFUNC_MAX_TIMESTAMP=2145916800; #max of int
};
#===========================================

#===========================================
#===Common Define
#$flag:  _name_true for true and _name_false for false
#$str : a scalar can be a string or undef
#===========================================

#===$flag=is_int($str,$min,$max);
#===check whether $str is integer and  $max>$str>=$min
#===$flag=is_int($str);
#===check whether $str is integer and  2147483648>$str>=-2147483648
#===$min :  set null if no lower bound restrict
#===$max :  set null if no upper bound restrict
sub is_int{
  my $param_count=scalar(@_);
  my ($str,$num,$max,$min)=(exists $_[0]?$_[0]:$_,undef,undef,undef);
  if($param_count==1||$param_count==2||$param_count==3){
    eval{$num=int($str);};
    if($@){undef $@;return defined(&_name_false)?&_name_false:'';}
#==1.0.5==
    if($str !~ /^-?\d+$/){return defined(&_name_false)?&_name_false:'';}
#    if($num ne $str){return defined(&_name_false)?&_name_false:'';}
#===end===
    if($param_count==1){
      $max=2147483648;$min=-2147483648;
    }elsif($param_count==2){
      $max=2147483648;$min=$_[1];
    }elsif($param_count==3){
      $max=$_[2];$min=$_[1];
    }else{
      CORE::die 'is_int: BUG!';
    }
    if((!defined($min)||$num>=$min)&&(!defined($max)||$num<$max)){
      return defined(&_name_true)?&_name_true:1;
    }else{
      return defined(&_name_false)?&_name_false:'';
    }
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'is_int: param count should be 1, 2 or 3');
  }
}

#===$flag=is_id($id)
#===check 32bit unsigned int id,start from 1
sub is_id{
  return is_int(shift,1,4294967296);
}

#===$flag=is_email($email)
#===check whether a valid email address
sub is_email{
  my $param_count=scalar(@_);
  if($param_count==1){
    local $_=$_[0];
    if(!defined($_)){
      return defined(&_name_false)?&_name_false:'';
    }elsif(/^[a-zA-Z0-9\_]\@([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/){
      return defined(&_name_true)?&_name_true:1;
    }elsif(/^[a-zA-Z0-9\_][a-zA-Z0-9\_\.\-]*[a-zA-Z0-9\_]\@([a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}$/){
      return defined(&_name_true)?&_name_true:1;
    }else{
      return defined(&_name_false)?&_name_false:'';
    }
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'is_email: param count should be 1');
  }
}

#===$str=trim($str)
#===delete blank before and after $str, return undef if $str is undef
sub trim {
  my $param_count=scalar(@_);
  if($param_count==1){
    local $_=$_[0];
    unless(defined($_)){return undef;}
    s/^\s+//,s/\s+$//;
    return $_ ;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'trim: param count should be 1');
  }
}

#===$flag=in($word,$word1,$word2,..)
#===if $word in $word1,$word2... return true else return false
#===$flag=in($word,$rh)
#===if $word in keys of $rh return true else return false
#===$word can be undef
sub in {
  my $param_count=scalar(@_);
  if(($param_count==2)&&(ref ($_[1]) eq 'HASH')){
    if(defined($_[0])){
      if(exists $_[1]->{$_[0]}){
        return defined(&_name_true)?&_name_true:1;
      }else{
        return defined(&_name_false)?&_name_false:'';
      }
    }else{
      return defined(&_name_false)?&_name_false:'';
    }
  }elsif($param_count>=1){
    my $word=shift;
    foreach(@_){
      if(defined($word)&&defined($_)&&($word eq $_)){
        return defined(&_name_true)?&_name_true:1;
      }elsif((!defined($word))&&(!defined($_))){
        return defined(&_name_true)?&_name_true:1;  
      }else{
        next;
      }
    }
    return defined(&_name_false)?&_name_false:'';
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'in: param count should be at least 1');
  }
}

#===$value=ifnull($scalar1,$scalar2)
#===If $scalar1 is not undef, return $scalar1, else return $scalar2
sub ifnull{
  my $param_count=scalar(@_);
  if($param_count==2){
    return defined($_[0])?$_[0]:$_[1];
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'ifnull: param count should be 2');
  }
}

#===$bytes=read_file($file_path)
sub read_file{
  my $file_path=shift;
  my $_max_file_len = 100000000;
  my $fh=FileHandle->new($file_path,'r');
  if(!defined($fh)){
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'read_file: open file failed');#return undef
  }
  binmode($fh);
  my $bytes;
  $fh->read($bytes,$_max_file_len);
  $fh->close();
  $bytes;
}

#===$byte_count=write_file($file_path,$bytes)
sub write_file{
  my ($file_path,$bytes)=@_;
  my $fh=FileHandle->new($file_path,'w');
  if(!defined($fh)){
  	if($file_path=~/^(.+)[\\\/][^\\\/]+$/){
  		mkdirs($1);
  		$fh=FileHandle->new($file_path,'w');
  	}else{
  		CORE::die ((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'write_file: open file failed');#return undef
  	}
  }
  binmode($fh);
  my $byte_count=$fh->syswrite($bytes);
  $fh->close();
  return $byte_count;
}

#===$byte_count=append_file($file_path,$bytes)
sub append_file{
  my ($file_path,$bytes)=@_;
  my $fh=FileHandle->new($file_path,'a');
  if(!defined($fh)){
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'append_file: open file failed');#return undef
  }
  binmode($fh);
  my $byte_count=$fh->syswrite($bytes);
  $fh->close();
  return $byte_count;
}

#===$flag=mkdirs($dir)
#===make dir and its parent dir,return true,if fail will die
sub mkdirs{
	my ($dir)=@_;
	my $r=mkdir($dir);
	if(!$r){
		if($dir=~/^(.+)[\\\/][^\\\/]+$/){
			mkdirs($1);
			return mkdir($dir);
		}else{
			#return false
			CORE::die ((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'mkdirs: cannot make dir');
		}
	}else{
		return $r;
	}
}
#==1.0.1==
#===$delete_num=delete_file($file_path)
sub delete_file{
  my $file_path = shift;
  unlink $file_path;
}


#===$ra_array=csv_2_array($file_path)
sub csv_2_array{
  my $file_path = shift;
  my $fh=FileHandle->new($file_path,'r');
  if(!defined($fh)){
    CORE::die ((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'csv_2_array: open file failed');#return undef
  }
  
  my @res;
  while(defined(my $line = <$fh>)){
    $line .= <$fh> while ($line =~ tr/"// % 2 and !eof);  
    chomp($line);  
    $line =~ s/(?:\x0D\x0A|[\x0D\x0A])?$/,/;  
    my $iIndex;
    my @columns;
    while(($iIndex=index($line, ','))!=-1){  
      my $field = '';        
      while(($field =~ tr/"// %2 or $field eq '') and $iIndex!=-1){
        $field .= substr($line, 0, $iIndex+1);
        $line = substr($line,$iIndex+1);
        $iIndex = index($line, ',');
      }
      chop($field);
      if(($field=~tr/"//)>0){
        $field = substr($field, 1);
        chop($field);
        $field =~ s/""/"/g;
      }
      push @columns, $field;
    }
    #$line =~ s/(?:\x0D\x0A|[\x0D\x0A])?$/,/;
    #my @columns = map {/^"(.*)"$/s ? scalar($_ = $1, s/""/"/g, $_) : $_} ($line =~ /("[^"]*(?:""[^"]*)*"|[^,]*),/g);
    if(@columns>0){
      push @res,\@columns;
    }
  }
  $fh->close();
  return \@res;
}

#===$flag=array_2_csv($file_path, $ra_array)
sub array_2_csv{
  my ($file_path, $ra_array) = @_;
  return unless(defined($ra_array));
  my $fh=FileHandle->new($file_path,'w');
  if(!defined($fh)){
    CORE::die ((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'array_2_csv: open file failed');#return undef
  }
  my $file = '';
  foreach my $ra_line (@$ra_array){
    my $line = '';
    foreach my $field(@$ra_line){
      $field =~ s/"/""/g;
      $line .= '"'.$field.'",';
    }    
    if($line ne ''){
      chop($line);
      $file .= $line."\n";
    }
  }
  chop($file);
  $fh->print($file);
  $fh->close();
  return defined(&_name_true)?&_name_true:1;
}

#===$md5=md5_hex($str)
sub md5_hex{
  require Digest::MD5;
  Digest::MD5::md5_hex(@_);
}

#===$crc=crc32($str)
sub crc32{
  my $crc = 0xFFFFFFFF;
  my $poly = 0xEDB88320;
  my ($tcmp) = @_;
  foreach (split(//,$tcmp)){
    my $comp = ($crc ^ ord($_)) & 0xFF;
    for (my $cnt = 0; $cnt < 8; $cnt++){
      $comp = ($comp & 1) ? ($poly ^ ($comp >> 1)) : ($comp >> 1); 
    }
    $crc = (($crc>>8) & 0x00FFFFFF) ^ $comp; 
  }
  return $crc^0xFFFFFFFF;
}

#===$str=encode_hex($str)
sub encode_hex{
  uc(unpack('H*',$_[0]));
}

#===$str=decode_hex($str)
sub decode_hex{
  pack('H*',$_[0]);
}

#===$str=encode_base64($str)
sub encode_base64{
  require MIME::Base64;
  MIME::Base64::encode_base64(@_);
}

#===$str=decode_base64($str)
sub decode_base64{
  require MIME::Base64;
  MIME::Base64::decode_base64(@_);
}

#===$url_str=url_encode($url_str)
sub url_encode {
  my $url_str = shift;
  $url_str =~ s/([^a-z0-9_.!~*'() -])/sprintf "%%%02X", ord($1)/egi;
  $url_str =~ tr/ /+/;
  return $url_str;
}

#===$url_str=url_decode($url_str)
sub url_decode {
  my $url_str = shift;
  $url_str =~ tr/\+/ /;
  $url_str =~ s/%([a-f0-9][a-f0-9])/chr( hex( $1 ) )/egi;
  return $url_str;
}

#===$str=html_encode($str)
sub html_encode{
  my ($str) = @_;
  $str =~ s/&/&amp;/g;
  $str =~ s/"/&quot;/g;
  $str =~ s/</&lt;/g;
  $str =~ s/>/&gt;/g;
  $str =~ s/ /&nbsp;/g;
  return $str;
}

#===$str=html_decode($str)
sub html_decode{
  my ($str) = @_;
  $str =~ s/&nbsp;/ /g;
  $str =~ s/&gt;/>/g;
  $str =~ s/&lt;/</g;
  $str =~ s/&quot;/"/g;
  $str =~ s/&amp;/&/g;
  return $str;
}
#===end===

#==1.0.4==
sub text_2_html($) {
    my ($text) = @_;
    unless($text){return '';}
    $text =~ s/\&/\&amp;/g;
    $text =~ s/"/\&quot;/g;
    $text =~ s/ / \&nbsp;/g;
    $text =~ s/</\&lt;/g;
    $text =~ s/>/\&gt;/g;
    $text =~ s/[\a\f\e\0\r]//isg;
    $text =~ s/document.cookie/documents\&\#46\;cookie/isg;
    $text =~ s/'/\&\#039\;/g;
    $text =~ s/\$/\&\#36;/isg;
    $text =~ s|\n\n|<p></p>|g;
    $text =~ s|\n|<br />|g;
    $text =~ s/\t/ \&nbsp; \&nbsp;/g;
    return $text;
}
#===end===

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

sub lwp_get {
    my $url = shift;
    require LWP::UserAgent;
    my $ua = new LWP::UserAgent;
    my $request = new HTTP::Request('GET', $url);
    my $content = $ua->request($request);
    return $content->{_content};
}

sub lwp_post {
    my ($url, $rh_data) = @_;
    my $ra_data = [];
    foreach (keys %$rh_data) {
        push (@$ra_data, $_);
        push (@$ra_data, $rh_data->{$_});
    }
    require LWP::UserAgent;
    my $ua = new LWP::UserAgent;
    my $request = new HTTP::Request('POST', $url, $ra_data);
    my $content = $ua->request($request);
    return $content;
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

my $var=undef;
sub test_var{
  our $var;
  if(scalar(@_)==1){
    $var=$_[0];
  }else{
    return $var;
  }
}

#===time support function
#===support year from 1971 to 2037
#===if you want more function,please use EasyDateTime
#===the time zone used in these function is server local time zone

#===To use these function please 
#use Time::Local;

#===the 'time' in function name means time_str, please read the description of $time_str

#===$timestamp : unix timestamp, an integer like 946656000
#===$datetime  : date time string, a string, like '2004-08-28 08:06:00'
#===$date      : date string, a string like, like '2004-08-28'

#===$rh_offset : a hash represent the offset in two times
#===$rh_offset is a struct like {year=>0,month=>0,day=>0,hour=>0,min=>0,sec=>0}
#===if some item in $rh_offset is not set ,use zero instead, integer can be negative
#===one month: {month=>1} 
#===one day  : {day=>1}

#===$time_str

#Samples can be accepted
#  '2004-08-28 08:06:00' ' 2004-08-28 08:06:00 '
#  '2004-08-28T08:06:00' '2004/08/28 08:06:00'
#  '2004.08.28 08:06:00' '2004-08-28 08.06.00'
#  '04-8-28 8:6:0' '2004-08-28' '08:06:00'
#  '946656000'

#Which string can be accepted?
#  rule 0:an int represent seconds since the Unix Epoch (January 1 1970 00:00:00 GMT) can be accepted
#  rule 1:there can be some blank in the begin or end of DATETIME_STR e.g. ' 2004-08-28 08:06:00 '
#  rule 2:date can be separate by . / or - e.g. '2004/08/28 08:06:00'
#  rule 3:time can be separate by . or : e.g. '2004-08-28 08.06.00'
#  rule 4:date and time can be join by white space or 'T' e.g. '2004-08-28T08:06:00'
#  rule 5:can be (date and time) or (only date) or (only time) e.g. '2004-08-28' or '08:06:00'
#  rule 6:year can be 2 digits or 4 digits,other field can be 2 digits or 1 digit e.g. '04-8-28 8:6:0'
#  rule 7:if only the date be set then the time will be set to 00:00:00
#    if only the time be set then the date will be set to 2000-01-01

#===$template option
#===FORMAT
#%datetime   return string like '2004-08-28 08:06:00'
#%date       return string like '2004-08-28'
#%timestamp  return unix timestamp

#===YEAR
#%yyyy       A full numeric representation of a year, 4 digits(2004)
#%yy         A two digit representation of a year(04)

#===MONTH
#%MM         Numeric representation of a month, with leading zeros (01..12)
#%M          Numeric representation of a month, without leading zeros (1..12)

#===DAY
#%dd         Day of the month, 2 digits with leading zeros (01..31)
#%d          Day of the month without leading zeros (1..31)

#===HOUR
#%h12        12-hour format of an hour without leading zeros (1..12)
#%h          24-hour format of an hour without leading zeros (0..23)
#%hh12       12-hour format of an hour with leading zeros (01..12)
#%hh         24-hour format of an hour with leading zeros (00..23)
#%ap         a Lowercase Ante meridiem and Post meridiem  (am or pm)
#%AP         Uppercase Ante meridiem and Post meridiem (AM or PM)

#===MINUTE
#%mm         Minutes with leading zeros (00..59)
#%m          Minutes without leading zeros (0..59)

#===SECOND
#%ss         Seconds, with leading zeros (00..59)
#%s          Seconds, without leading zeros (0..59)


#add month 的陷阱
#5月31号加一个月，会die掉，有的时候你可能不会轻易发现这个问题，但务必请非常注意

##########################################################################

#===for internal use
sub _time_func_is_int{
  my $param_count=scalar(@_);
  my ($str,$num,$max,$min)=(exists $_[0]?$_[0]:$_,undef,undef,undef);
  my ($true,$false) = (1,'');
  if($param_count==1||$param_count==2||$param_count==3){
    eval{$num=int($str);};
    if($@){undef $@;return defined(&_name_false)?&_name_false:'';}
#==1.0.5==
    if($str !~ /^-?\d+$/){return defined(&_name_false)?&_name_false:'';}
#    if($num ne $str){return defined(&_name_false)?&_name_false:'';}
#===end===
    if($param_count==1){
      $max=2147483648;$min=-2147483648;
    }elsif($param_count==2){
      $max=2147483648;$min=$_[1];
    }elsif($param_count==3){
      $max=$_[2];$min=$_[1];
    }else{
      CORE::die '_time_func_is_int: BUG!';
    }
  
    if((!defined($min)||$num>=$min)&&(!defined($max)||$num<$max)){
      return $true;
    }else{
      return $false;
    }
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'_time_func_is_int: param count should be 1, 2 or 3');
  }
}

#===$format_str=time_2_str($time_str[,$template])
#===time_2_str($time_str) return str such as '2000-01-01 00:00:00'
#===time_2_str($time_str,'%yyyy-%MM-%dd') return str such as '2000-01-01'
sub time_2_str {
  my $param_count=scalar(@_);
  if($param_count==1){
    if(!defined($_[0])){return undef;}
    local $_=time_2_timestamp($_[0]);
    $_=[localtime($_)];
    return sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$_->[5]+1900,$_->[4]+1,$_->[3],$_->[2],$_->[1],$_->[0]);
  }elsif($param_count==2){
    if(!defined($_[0])){return undef;}
    local $_=time_2_timestamp($_[0]);
    my $format_str=$_[1];
    if(!defined($format_str)){
      $_=[localtime($_)];
      return sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$_->[5]+1900,$_->[4]+1,$_->[3],$_->[2],$_->[1],$_->[0]);
    }
    my $t=[localtime($_)];
    my $map={
      ss=>sprintf('%02s',$t->[0]),
      s=>$t->[0],
      mm=>sprintf('%02s',$t->[1]),
      m=>$t->[1],
      AP=>$t->[2]>=12?'PM':'AM',
      ap=>$t->[2]>=12?'pm':'am',
      hh=>sprintf('%02s',$t->[2]),
      h=>$t->[2],
      hh12=>sprintf('%02s',$t->[2]>=12?($t->[2]-12):$t->[2]),
      h12=>$t->[2]>=12?($t->[2]-12):$t->[2],
      dd=>sprintf('%02s',$t->[3]),
      d=>$t->[3],
      MM=>sprintf('%02s',$t->[4]+1),
      M=>$t->[4]+1,
      yyyy=>$t->[5]+1900,
      yy=>sprintf('%02s', ($t->[5]+1900)%100), #==1.0.3==
      date=>sprintf($_TIMEFUNC_DEFAULT_DATE_FORMAT,$t->[5]+1900,$t->[4]+1,$t->[3]),
      datetime=>sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$t->[5]+1900,$t->[4]+1,$t->[3],$t->[2],$t->[1],$t->[0]),
      timestamp=>$_
    };

#AM and PM - What is Noon and Midnight?
#AM and PM start immediately after Midnight and Noon (Midday) respectively.
#This means that 00:00 AM or 00:00 PM (or 12:00 AM and 12:00 PM) have no meaning.
#Every day starts precisely at midnight and AM starts immediately after that point in time e.g. 00:00:01 AM (see also leap seconds)
#To avoid confusion timetables, when scheduling around midnight, prefer to use either 23:59 or 00:01 to avoid confusion as to which day is being referred to.
#It is after Noon that PM starts e.g. 00:00:01 PM (12:00:01)

    $format_str=~s/%timestamp/$map->{timestamp}/g;
    $format_str=~s/%datetime/$map->{datetime}/g;
    $format_str=~s/%date/$map->{date}/g;
    $format_str=~s/%yyyy/$map->{yyyy}/g;
    $format_str=~s/%hh12/$map->{hh12}/g;
    $format_str=~s/%h12/$map->{h12}/g;
    $format_str=~s/%ss/$map->{ss}/g;
    $format_str=~s/%mm/$map->{mm}/g;
    $format_str=~s/%AP/$map->{AP}/g;
    $format_str=~s/%ap/$map->{ap}/g;
    $format_str=~s/%hh/$map->{hh}/g;
    $format_str=~s/%dd/$map->{dd}/g;
    $format_str=~s/%MM/$map->{MM}/g;
    $format_str=~s/%yy/$map->{yy}/g;
    $format_str=~s/%h/$map->{h}/g;
    $format_str=~s/%M/$map->{M}/g;
    $format_str=~s/%d/$map->{d}/g;
    $format_str=~s/%m/$map->{m}/g;
    $format_str=~s/%s/$map->{s}/g;

    return $format_str;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_str: param count should be 1 or 2');
  }
}

#===$timestamp=time_2_timestamp($time_str)
#2000-01-01 00:00:00 +08:00   946656000
sub time_2_timestamp{
  my $param_count=scalar(@_);
  if($param_count==1){
    local $_ = shift;
    if(!defined($_)) {return undef;}
    if(/^\s*(\d{4}|\d{2})([\-\.\/])(\d{1,2})\2(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal(0,0,0,$4,$3-1,$1);};
      if($@){undef $@;CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_timestamp: unsupport time string format');}else{return $_;}
    }elsif(/^\s*(\d{4}|\d{2})([\-\.\/])(\d{1,2})\2(\d{1,2})(\x20+|T)(\d{1,2})([\:\.])(\d{1,2})\7(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal($9,$8,$6,$4,$3-1,$1);};
      if($@){undef $@;CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_timestamp: unsupport time string format');}else{return $_;}
    }elsif(/^\s*(\d{1,2})([\:\.])(\d{1,2})\2(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal($4,$3,$1,1,1-1,2000);};
      if($@){undef $@;CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_timestamp: unsupport time string format');}else{return $_;}
    }elsif(&_time_func_is_int($_,$_TIMEFUNC_MIN_TIMESTAMP,$_TIMEFUNC_MAX_TIMESTAMP)){
      return $_;
    }else{
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_timestamp: unsupport time string format');
    }
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_timestamp: param count should be 1');
  }
}

#===$flag=is_time($time_str)
sub is_time{
  my $param_count=scalar(@_);
  if($param_count==1){
    my ($true,$false) = (1,'');
    local $_ = $_[0];
    if(!defined($_)){return $false;}#if undef
    if(ref $_ ne ''){return $false;}#if not a scalar
    if(/^\s*(\d{4}|\d{2})([\-\.\/])(\d{1,2})\2(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal(0,0,0,$4,$3-1,$1);};
      if($@){undef $@;return $false;}else{return $true;}
    }elsif(/^\s*(\d{4}|\d{2})([\-\.\/])(\d{1,2})\2(\d{1,2})(\x20+|T)(\d{1,2})([\:\.])(\d{1,2})\7(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal($9,$8,$6,$4,$3-1,$1);};
      if($@){undef $@;return $false;}else{return $true;}
    }elsif(/^\s*(\d{1,2})([\:\.])(\d{1,2})\2(\d{1,2})\s*$/){
      eval{$_=Time::Local::timelocal($4,$3,$1,1,1-1,2000);};
      if($@){undef $@;return $false;}else{return $true;}
    }elsif(&_time_func_is_int($_,$_TIMEFUNC_MIN_TIMESTAMP,$_TIMEFUNC_MAX_TIMESTAMP)){
      return $true;
    }else{
      return $false;
    }
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'is_time: param count should be 1');
  }
}

#===$time=hash_2_timestamp({year=>2000,month=>1,day=>1,hour=>0,min=>0,sec=>0})
#===if some item not set ,default value will be used
sub hash_2_timestamp{
  my $param_count=scalar(@_);
  if($param_count==1){
    local $_ = [];
    my $rh_time=$_[0];
    if(!defined($rh_time)){return undef;}
    $_->[5]=defined($rh_time->{'year'})?_time_func_is_int($rh_time->{'year'})?$_[0]->{'year'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):2000;
    $_->[4]=defined($rh_time->{'month'})?_time_func_is_int($rh_time->{'month'})?$_[0]->{'month'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):1;
    $_->[3]=defined($rh_time->{'day'})?_time_func_is_int($rh_time->{'day'})?$_[0]->{'day'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):1;
    $_->[2]=defined($rh_time->{'hour'})?_time_func_is_int($rh_time->{'hour'})?$_[0]->{'hour'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):0;
    $_->[1]=defined($rh_time->{'min'})?_time_func_is_int($rh_time->{'min'})?$_[0]->{'min'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):0;
    $_->[0]=defined($rh_time->{'sec'})?_time_func_is_int($rh_time->{'sec'})?$_[0]->{'sec'}:CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time'):0;
    eval{$_=Time::Local::timelocal($_->[0],$_->[1],$_->[2],$_->[3],$_->[4]-1,$_->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: not a valid time');}
    return $_;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'hash_2_timestamp: param count should be 1');
  }
}

#===$rh_time=time_2_hash($time_str)
#===$rh_time is a struct like {year=>2000,month=>1,day=>1,hour=>0,min=>0,sec=>0}
sub time_2_hash{
  my $param_count=scalar(@_);
  if($param_count==1){
    if(!defined($_[0])){return undef;}
    local $_=[localtime(time_2_timestamp($_[0]))];
    return {year=>$_->[5]+1900,month=>$_->[4]+1,day=>$_->[3],hour=>$_->[2],min=>$_->[1],sec=>$_->[0]};
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'time_2_hash: param count should be 1');
  }
}

#===$timestamp=&now();
#===same as CORE::time();
sub now{
  CORE::time();
}

#===$timestamp=&time();
#===same as CORE::time();
sub time{
  CORE::time();
}

#===$date=&date_now();
sub date_now{
  local $_=[localtime(&now())];
  sprintf($_TIMEFUNC_DEFAULT_DATE_FORMAT,$_->[5]+1900,$_->[4]+1,$_->[3]);
}

#===$datetime=&datetime_now();
sub datetime_now{
  local $_=[localtime(&now())];
  sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$_->[5]+1900,$_->[4]+1,$_->[3],$_->[2],$_->[1],$_->[0]);
}

#===$timestamp=&timestamp_now();
#===same as now();
sub timestamp_now{
  &now();
}

#===$day_count=day_of_month($year,$month)
sub day_of_month{
  my $param_count=scalar(@_);
  if($param_count==2){
    if(!&_time_func_is_int($_[0],1901,2038)){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'day_of_month: $1 should be integer in [1901,2037]');
    }
    if(!&_time_func_is_int($_[1],1,13)){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'day_of_month: $2 should be integer in [1,12]');
    }
    local $_=[31,28,31,30,31,30,31,31,30,31,30,31]->[$_[1]-1];
    ++$_ if $_[1] == 2 && (!($_[0] % 4));
    return $_;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'day_of_month: param count should be 2');
  }
}

#==1.0.1==
#===$day_count=day_of_week($time_str)
sub day_of_week{
  my $param_count=scalar(@_);
  if($param_count==1){
    if(!defined($_[0])){return undef;}
    local $_=[localtime(time_2_timestamp($_[0]))];
    return $_->[6];
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'day_of_week: param count should be 1');
  }
}
#===end===

#===$time_zone=localtimezone()
sub localtimezone {
  return int ((timegm(0,0,0,1,0,2000)-timelocal(0,0,0,1,0,2000))/3600);
}

#===$timestamp=timestamp_add($time_str,$rh_offset)
sub timestamp_add{
  my $param_count=scalar(@_);
  if($param_count==2){
    my ($month,$sec)=(0,0);
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_add: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_add: $2 should be a hash_ref');
    }
    $month+=12*(_time_func_is_int($_[1]->{'year'})?$_[1]->{'year'}:0);
    $month+=_time_func_is_int($_[1]->{'month'})?$_[1]->{'month'}:0;
    $sec+=86400*(_time_func_is_int($_[1]->{'day'})?$_[1]->{'day'}:0);
    $sec+=3600*(_time_func_is_int($_[1]->{'hour'})?$_[1]->{'hour'}:0);
    $sec+=60*(_time_func_is_int($_[1]->{'min'})?$_[1]->{'min'}:0);
    $sec+=_time_func_is_int($_[1]->{'sec'})?$_[1]->{'sec'}:0;
    my $t=[localtime(time_2_timestamp($_[0])+$sec)];
    $t->[5]=int($t->[5]+($t->[4]+$month)/12);
    $t->[4]= ($t->[4]+$month)%12;
    eval{$t=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4],$t->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_set: not a valid time');}
    return $t;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_add: param count should be 2');
  }
}

#===$timestamp=timestamp_set($time_str,$rh_time)
sub timestamp_set{
  my $param_count=scalar(@_);
  if($param_count==2){
#==1.0.1==
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_set: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_set: $2 should be a hash_ref');
    }
#===end===
    my $t=[localtime(time_2_timestamp($_[0]))];
    my $rh_time=$_[1];
    $t->[5]=_time_func_is_int($rh_time->{'year'})?$rh_time->{'year'}:$t->[5]+1900;
    $t->[4]=_time_func_is_int($rh_time->{'month'})?$rh_time->{'month'}:$t->[4]+1;
    $t->[3]=_time_func_is_int($rh_time->{'day'})?$rh_time->{'day'}:$t->[3];
    $t->[2]=_time_func_is_int($rh_time->{'hour'})?$rh_time->{'hour'}:$t->[2];
    $t->[1]=_time_func_is_int($rh_time->{'min'})?$rh_time->{'min'}:$t->[1];
    $t->[0]=_time_func_is_int($rh_time->{'sec'})?$rh_time->{'sec'}:$t->[0];
    eval{$t=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4]-1,$t->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_set: not a valid time');}
    return $t;
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'timestamp_set: param count should be 2');
  }
}

#===$date=date_add($time_str,$rh_offset)
sub date_add{
  my $param_count=scalar(@_);
  if($param_count==2){
    my ($month,$sec)=(0,0);
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_add: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_add: $2 should be a hash_ref');
    }
    $month+=12*(_time_func_is_int($_[1]->{'year'})?$_[1]->{'year'}:0);
    $month+=_time_func_is_int($_[1]->{'month'})?$_[1]->{'month'}:0;
    $sec+=86400*(_time_func_is_int($_[1]->{'day'})?$_[1]->{'day'}:0);
    $sec+=3600*(_time_func_is_int($_[1]->{'hour'})?$_[1]->{'hour'}:0);
    $sec+=60*(_time_func_is_int($_[1]->{'min'})?$_[1]->{'min'}:0);
    $sec+=_time_func_is_int($_[1]->{'sec'})?$_[1]->{'sec'}:0;
    my $t=[localtime(time_2_timestamp($_[0])+$sec)];
    $t->[5]=int($t->[5]+($t->[4]+$month)/12);
    $t->[4]= ($t->[4]+$month)%12;
    eval{local $_=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4],$t->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_add: not a valid time');}
    return sprintf($_TIMEFUNC_DEFAULT_DATE_FORMAT,$t->[5]+1900,$t->[4]+1,$t->[3]);
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_add: param count should be 2');
  }
}

#===$date=date_set($time_str,$rh_time)
sub date_set{
  my $param_count=scalar(@_);
  if($param_count==2){
#==1.0.1==
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_set: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_set: $2 should be a hash_ref');
    }
#===end===
    my $t=[localtime(time_2_timestamp($_[0]))];
    my $rh_time=$_[1];
    $t->[5]=_time_func_is_int($rh_time->{'year'})?$rh_time->{'year'}:$t->[5]+1900;
    $t->[4]=_time_func_is_int($rh_time->{'month'})?$rh_time->{'month'}:$t->[4]+1;
    $t->[3]=_time_func_is_int($rh_time->{'day'})?$rh_time->{'day'}:$t->[3];
    $t->[2]=_time_func_is_int($rh_time->{'hour'})?$rh_time->{'hour'}:$t->[2];
    $t->[1]=_time_func_is_int($rh_time->{'min'})?$rh_time->{'min'}:$t->[1];
    $t->[0]=_time_func_is_int($rh_time->{'sec'})?$rh_time->{'sec'}:$t->[0];
    eval{local $_=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4]-1,$t->[5]);};
#==1.0.1==
#    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_set: not a valid time');}
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_set: not a valid time');}
#===end===
    return sprintf($_TIMEFUNC_DEFAULT_DATE_FORMAT,$t->[5],$t->[4],$t->[3]);
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'date_set: param count should be 2');
  }
}

#===$datetime=datetime_add($time_str,$rh_offset)
sub datetime_add{
  my $param_count=scalar(@_);
  if($param_count==2){
    my ($month,$sec)=(0,0);
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_add: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_add: $2 should be a hash_ref');
    }
    $month+=12*(_time_func_is_int($_[1]->{'year'})?$_[1]->{'year'}:0);
    $month+=_time_func_is_int($_[1]->{'month'})?$_[1]->{'month'}:0;
    $sec+=86400*(_time_func_is_int($_[1]->{'day'})?$_[1]->{'day'}:0);
    $sec+=3600*(_time_func_is_int($_[1]->{'hour'})?$_[1]->{'hour'}:0);
    $sec+=60*(_time_func_is_int($_[1]->{'min'})?$_[1]->{'min'}:0);
    $sec+=_time_func_is_int($_[1]->{'sec'})?$_[1]->{'sec'}:0;
    my $t=[localtime(time_2_timestamp($_[0])+$sec)];
    $t->[5]=int($t->[5]+($t->[4]+$month)/12);
    $t->[4]= ($t->[4]+$month)%12;
    eval{local $_=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4],$t->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_add: not a valid time');}
    return sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$t->[5]+1900,$t->[4]+1,$t->[3],$t->[2],$t->[1],$t->[0]);
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_add: param count should be 2');
  }
}

#===$datetime=datetime_set($time_str,$rh_time)
sub datetime_set{
  my $param_count=scalar(@_);
  if($param_count==2){
#==1.0.1==
    if(!is_time($_[0])){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_set: $1 not a valid time_str');
    }
    if(ref $_[1] ne 'HASH'){
      CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_set: $2 should be a hash_ref');
    }
#===end===
    my $t=[localtime(time_2_timestamp($_[0]))];
    my $rh_time=$_[1];
    $t->[5]=_time_func_is_int($rh_time->{'year'})?$rh_time->{'year'}:$t->[5]+1900;
    $t->[4]=_time_func_is_int($rh_time->{'month'})?$rh_time->{'month'}:$t->[4]+1;
    $t->[3]=_time_func_is_int($rh_time->{'day'})?$rh_time->{'day'}:$t->[3];
    $t->[2]=_time_func_is_int($rh_time->{'hour'})?$rh_time->{'hour'}:$t->[2];
    $t->[1]=_time_func_is_int($rh_time->{'min'})?$rh_time->{'min'}:$t->[1];
    $t->[0]=_time_func_is_int($rh_time->{'sec'})?$rh_time->{'sec'}:$t->[0];
    eval{local $_=Time::Local::timelocal($t->[0],$t->[1],$t->[2],$t->[3],$t->[4]-1,$t->[5]);};
    if($@){CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_set: not a valid time');}
    return sprintf($_TIMEFUNC_DEFAULT_DATETIME_FORMAT,$t->[5],$t->[4],$t->[3],$t->[2],$t->[1],$t->[0]);
  }else{
    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'datetime_set: param count should be 2');
  }
}

#==1.0.1==
#sub inet_aton{
#  local $_=shift;
#  if(!defined($_)){return 0;}
#  if(/^\s*(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\s*$/){
#    if($1>=0&&$1<256&&$2>=0&&$2<256&&$3>=0&&$3<256&&$4>=0&&$4<256){
#      return $1*16777216+$2*65536+$3*256+$4;
#    };
#  };
#  return 0;
#}
#
#sub filter_hash_restrict{
#  my $param_count=scalar(@_);
#  if($param_count==2){
#    my $rs={};
#    foreach(@{$_[1]}){
#      if(exists($_[0]->{$_})){
#        $rs->{$_}=$_[0]->{$_}
#      }else{
#        CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'filter_hash_restrict: key not found');
#      }
#    }  
#    return $rs;
#  }else{
#    CORE::die((defined(&_name_pkg_name)?&_name_pkg_name.'::':'').'filter_hash_restrict: param count should be 2');
#  }
#}
#===end===


1;

__END__


=head1 NAME

EasyTool - The Library of Perl Functions in Common Usage

=head1 SYNOPSIS

  use EasyTool;
  
  if(defined(&EasyTool::foo)){
    print "lib is included";
  }else{
    print "lib is not included";
  }
  
  print EasyTool::is_int(2147483647); #true
  print EasyTool::is_int(-2147483648); #true
  print EasyTool::is_int(2147483648); #false

  print EasyTool::is_id(4294967295); #true
  print EasyTool::is_id(4294967296); #false
  
  print EasyTool::is_email("xxx.abc@test.com"); #true
  
  print EasyTool::trim(" \t test\n "); #test
  
  print EasyTool::in('a', {'a' => 1, 'b' => 2}); #true
  print EasyTool::in(undef, 1, undef); #true
  
  print EasyTool::ifnull(undef, 1); #1
  
  print EasyTool::read_file("file.in");
  print EasyTool::write_file("file.out", "string");
  print EasyTool::append_file("file.out", "string");
  print EasyTool::delete_file("file.out");
  
  $ra_array = EasyTool::csv_2_array("a.csv");
  print EasyTool::array_2_csv("a.csv", $ra_array);
  
  print EasyTool::md5_hex("test"); #'098f6bcd4621d373cade4e832627b4f6'

  print EasyTool::crc32("test"); #3632233996

  $str = &EasyTool::encode_hex("hello");
  print EasyTool::decode_hex($str); #hello

  $str = &EasyTool::encode_base64("hello");
  print EasyTool::decode_base64($str); #hello

  $str = &EasyTool::url_encode('<&%$/ \|=+_]{>@^');
  print EasyTool::url_decode($str); #<&%$/ \|=+_]{>@^

  $str = &EasyTool::html_encode(";<>&lt\"");
  print EasyTool::html_decode($str); #;<>&lt"

  print EasyTool::qquote('\n'); #"\\n"
  print EasyTool::qquote_bin('\n'); #"\\n"
  
  print EasyTool::dump(['1', {'a' => '1', 'b' => '2'}, undef]); #[1, {"a" => 1, "b" => 2}, ()]
  
  print EasyTool::test_var(); #undef
  print EasyTool::test_var(1); #1
  print EasyTool::test_var(); #1

  print EasyTool::time_2_str('1983-03-07 01:02:03','%yyyy-%MM-%%dd');
  print EasyTool::time_2_str('1983-03-07 01:02:03');
  print EasyTool::time_2_str('1983-03-07');
  print EasyTool::time_2_str('2004-08-28T08:06:00');
  print EasyTool::time_2_str('946656000');
  print EasyTool::time_2_str(' 1983-03-07 ');
  print EasyTool::time_2_str('1983-03-07T01:02:03');


  print EasyTool::is_time('1983-03-07 01:02:03');
  print EasyTool::time_2_timestamp('1983-03-07 01:02:03');
  print EasyTool::hash_2_timestamp({year=>1983,month=>3,day=>7,hour=>1,min=>2,sec=>3});
  $rh_time=EasyTool::time_2_hash('1983-03-07 01:02:03'); #{year=>1983,month=>3,day=>7,hour=>1,min=>2,sec=>3}
  
  print EasyTool::now();
  print EasyTool::time();
  print EasyTool::datetime_now();
  print EasyTool::date_now();

  print EasyTool::day_of_month(2000,2); #29
  print EasyTool::day_of_week('2006-07-02'); #0
  print EasyTool::timestamp_set('1983-03-07 01:02:03',{year=>1984,month=>5,day=>10,hour=>5,min=>7,sec=>9});#maybe 453013629
  print EasyTool::datetime_set('1983-03-07 01:02:03',{year=>1984,day=>10,min=>7});#'1984-03-10 01:07:03'
  print EasyTool::date_set('1983-03-07 01:02:03'',{month=>5,hour=>5,sec=>9});#'1983-05-07'
  
  print EasyTool::timestamp_add('1983-03-07 01:02:03',{year=>1,month=>2,day=>3,hour=>4,min=>5,sec=>6});#maybe 453013629
  $datetime=EasyTool::datetime_add('1983-03-07 01:02:03',{year=>1,day=>3,min=>5});#'1984-03-10 01:07:03'
  $date=EasyTool::date_add('1983-03-07 01:02:03',{month=>2,hour=>4,sec=>6});#'1983-05-07'
  
I<The synopsis above only lists the major methods and parameters.>

=head1 DESCRIPTION 

The EasyTool module aims to provide a easy to use, easy to port function set

you can copy and paste some function to embed into your code as easy as possiable
youc can also make some modification on function as you need

=head2 First of All

  support time from 1971 to 2037
  if you want more function,please use EasyDateTime
  the time zone used in these function is server local time zone

=head2 Notation and Conventions 

=head3 function name

  the 'time' in function name means time_str, please read the description of $time_str

=head3 param and return value

  $str: $str is a string
  $email: $email is a string as be accept as a email address

  $file_path: $file_path is the path of file you want to operate
  $bytes: $bytes is the content to write or append
  $byte_count: $byte_count is the length of $bytes
  $delete_num: $delete_num is the number of files be deleted

  $ra_array: an array represent the csv content

  $time_str: $time_str is the string as be accept as a time 

    Samples can be accepted
    '2004-08-28 08:06:00' ' 2004-08-28 08:06:00 '
    '2004-08-28T08:06:00' '2004/08/28 08:06:00'
    '2004.08.28 08:06:00' '2004-08-28 08.06.00'
    '04-8-28 8:6:0' '2004-08-28' '08:06:00'
    '946656000'

    Which string can be accepted?
    rule 0: Unix Timestamp, an int represent seconds since the Unix Epoch (January 1 1970 00:00:00 GMT) can be accepted
    rule 1: there can be some blank in the begin or end of string e.g. ' 2004-08-28 08:06:00 '
    rule 2: date can be separate by . / or - e.g. '2004/08/28 08:06:00'
    rule 3: time can be separate by . or : e.g. '2004-08-28 08.06.00'
    rule 4: date and time can be join by white space or 'T' e.g. '2004-08-28T08:06:00'
    rule 5: can be (date and time) or (only date) or (only time) e.g. '2004-08-28' or '08:06:00'
    rule 6: year can be 2 digits or 4 digits,other field can be 2 digits or 1 digit e.g. '04-8-28 8:6:0'
    rule 7: if only the date be set then the time will be set to 00:00:00
    if only the time be set then the date will be set to 2000-01-01
  
  
  $timestamp : unix timestamp, an integer like 946656000
  $datetime  : date time string, a string, like '2004-08-28 08:06:00'
  $date      : date string, a string like, like '2004-08-28'

  $rh_time   : a hash represent a time
  $rh_time is a struct like {year=>2000,month=>1,day=>1,hour=>0,min=>0,sec=>0}
  if some item in $rh_time is not set ,use default value instead
  default values: year=>2000,month=>1,day=>1,hour=>0,min=>0,sec=>0
  
  $rh_offset : a hash represent the offset in two times
  $rh_offset is a struct like {year=>0,month=>0,day=>0,hour=>0,min=>0,sec=>0}
  if some item in $rh_offset is not set ,use zero instead, integer can be negative
  one month: {month=>1} 
  one day  : {day=>1}
  one month and one day: {month=>1,day=>1}
  when you add a time with $rh_offset such as {year=>0,month=>0,day=>0,hour=>0,min=>0,sec=>0}, it will add second first,then
    miniute, hour, day, month, year
  
  $template option:
  #===FORMAT
  #%datetime   return string like '2004-08-28 08:06:00'
  #%date       return string like '2004-08-28'
  #%timestamp  return unix timestamp
  
  #===YEAR
  #%yyyy       A full numeric representation of a year, 4 digits(2004)
  #%yy         A two digit representation of a year(04)
  
  #===MONTH
  #%MM         Numeric representation of a month, with leading zeros (01..12)
  #%M          Numeric representation of a month, without leading zeros (1..12)
  
  #===DAY
  #%dd         Day of the month, 2 digits with leading zeros (01..31)
  #%d          Day of the month without leading zeros (1..31)
  
  #===HOUR
  #%h12        12-hour format of an hour without leading zeros (1..12)
  #%h          24-hour format of an hour without leading zeros (0..23)
  #%hh12       12-hour format of an hour with leading zeros (01..12)
  #%hh         24-hour format of an hour with leading zeros (00..23)
  #%ap         a Lowercase Ante meridiem and Post meridiem  (am or pm)
  #%AP         Uppercase Ante meridiem and Post meridiem (AM or PM)
  
  #===MINUTE
  #%mm         Minutes with leading zeros (00..59)
  #%m          Minutes without leading zeros (0..59)
  
  #===SECOND
  #%ss         Seconds, with leading zeros (00..59)
  #%s          Seconds, without leading zeros (0..59)
  
  $bool: 1 for true and '' for false

=head3 extra knowledge
  
  AM and PM - What is Noon and Midnight?
  AM and PM start immediately after Midnight and Noon (Midday) respectively.
  This means that 00:00 AM or 00:00 PM (or 12:00 AM and 12:00 PM) have no meaning.
  Every day starts precisely at midnight and AM starts immediately after that point in time e.g. 00:00:01 AM (see also leap seconds)
  To avoid confusion timetables, when scheduling around midnight, prefer to use either 23:59 or 00:01 to avoid confusion as to which day is being referred to.
  It is after Noon that PM starts e.g. 00:00:01 PM (12:00:01)

=head1 basic function

=head2 foo - check whether this module is be used

  if(defined(&EasyTool::foo)){
    print "lib is included";
  }else{
    print "lib is not included";
  }
  
=head2 is_int - whether $str is integer and  $max>$str>=$min

  &EasyTool::is_int($str);
  &EasyTool::is_int($str, $min);
  &EasyTool::is_int($str, $min, $max);
  
  default $max is 2147483648, default min is -2147483648

=head2 is_id - whether this is a 32bit unsigned int id, 1<=$id<4294967296

  &EasyTool::is_id($id);

=head2 is_email -  whether this is a valid email address

  &EasyTool::is_email($email);

=head2 trim - delete blank before and after $str, return undef if $str is undef

  $str = &EasyTool::trim($str);

=head2 in - whether $word is in the scalars or is the key of the hash after it

  &EasyTool::in($word,$word1,$word2,..);
  &EasyTool::in($word,$rh);

  $word can be undef

=head2 ifnull - If $scalar1 is not undef, return $scalar1, else return $scalar2

  &EasyTool::ifnull($scalar1,$scalar2)

=head2 read_file - Read file in binmode

  $bytes=&EasyTool::read_file($file_path)

=head2 write_file - Write file in binmode

  $byte_count=&EasyTool::write_file($file_path,$bytes)

=head2 append_file - Append file in binmode

  $byte_count=&EasyTool::append_file($file_path,$bytes)

=head2 delete_file - Delete file

  $delete_num=&EasyTool::delete_file($file_path)

=head2 csv_2_array - Read the content of .csv file and put the data into array_ref of array_ref

  $ra_array=&EasyTool::csv_2_array($file_path)

=head2 array_2_csv - Write .csv file with the data in $ra_array

  &EasyTool::array_2_csv($file_path, $ra_array)

=head2 md5_hex - Encrypt by MD5

  $md5 = &EasyTool::md5_hex($str)

=head2 crc32 - Encrypt by CRC32

  $crc = &EasyTool::crc32($str)

=head2 encode_hex decode_hex - encode and decode string in HEX

  $str = &EasyTool::encode_hex($str)
  $str = &EasyTool::decode_hex($str)

=head2 encode_base64 decode_base64 - encode and decode string in Base64

  Every 3*8bit will be convert into 4*6bit, then add 2bit 0 before every 6bit
  11010101 11000101 00110011 -> 110101 011100 010100 110011
                             -> 00110101 00011100 00010100 00110011
  then every byte convert with the table below:
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+
  | 0 | A | 8 | I |16 | Q |24 | Y |32 | g |40 | o |48 | w |56 | 4 |pad| = |
  | 1 | B | 9 | J |17 | R |25 | Z |33 | h |41 | p |49 | x |57 | 5 |   |   |
  | 2 | C |10 | K |18 | S |26 | a |34 | i |42 | q |50 | y |58 | 6 |   |   |
  | 3 | D |11 | L |19 | T |27 | b |35 | j |43 | r |51 | z |59 | 7 |   |   |
  | 4 | E |12 | M |20 | U |28 | c |36 | k |44 | s |52 | 0 |60 | 8 |   |   |
  | 5 | F |13 | N |21 | V |29 | d |37 | l |45 | t |53 | 1 |61 | 9 |   |   |
  | 6 | G |14 | O |22 | W |30 | e |38 | m |46 | u |54 | 2 |62 | + |   |   |
  | 7 | H |15 | P |23 | X |31 | f |39 | n |47 | v |55 | 3 |63 | / |   |   |
  +---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+---+

  $str = &EasyTool::encode_base64($str)
  $str = &EasyTool::decode_base64($str)

=head2 url_encode url_decode - encode and decode string in URLs

  +------------------------+---------------+
  | 0-9 A-Z a-z _.!~*'()-  | Not changed   |
  | space                  | +             |
  | others                 | %xx(xx is HEX)|
  +------------------------+---------------+

  $str = &EasyTool::url_encode($str);
  $str = &EasyTool::url_decode($str);

=head2 html_encode html_decode - encode and decode string in HTML

  +---+-------+
  | > |  &gt; |
  | < |  &lt; |
  | " | &quot;|
  | & | &amp; |
  |   | &nbsp;|
  +---+-------+

  $str = &EasyTool::html_encode($str);
  $str = &EasyTool::html_decode($str);

=head2 text_2_html - convert text into HTML

    $text =~ s/\&/\&amp;/g;
    $text =~ s/"/\&quot;/g;
    $text =~ s/ / \&nbsp;/g;
    $text =~ s/</\&lt;/g;
    $text =~ s/>/\&gt;/g;
    $text =~ s/[\a\f\e\0\r]//isg;
    $text =~ s/document.cookie/documents\&\#46\;cookie/isg;
    $text =~ s/'/\&\#039\;/g;
    $text =~ s/\$/\&\#36;/isg;
    $text =~ s|\n\n|<p></p>|g;
    $text =~ s|\n|<br />|g;
    $text =~ s/\t/ \&nbsp; \&nbsp;/g;
	+---------------+--------------------+
	|       &       |        &amp;       |
	|       "       |       &quot;       |
	|     space     |       &nbsp;       |
	|       <       |        &lt;        |
	|       >       |        &gt;        |
	|  \a\f\e\0\r   |                    |
	|document.cookie|documents&#46;cookie|
	|       '       |       &#039;       |
	|       $       |        &#36;       |
	|     \n\n      |      <p></p>       |
	|      \n       |       <br />       |
	|      \t       |   \&nbsp; \&nbsp;  |
	+---------------+--------------------+

	$html = &EasyTool::text_2_html($str);

=head2 qquote qquote_bin - put string into double-quotes

  $str = &EasyTool::qquote($str);
  $str = &EasyTool::qquote_bin($str);

=head2 dump - Dump the scalar, array, hash, onto the screen

  &EasyTool::dump($data);

=head2 test_var - Store the value of $var

  $var = &EasyTool::test_var();
  &EasyTool::test_var($var);

=head2 time_2_str - format output time string

  $format_str=EasyTool::time_2_str($time_str[,$template])
  time_2_str($time_str) return str such as '2000-01-01 00:00:00'
  time_2_str($time_str,'%yyyy-%MM-%dd') return str such as '2000-01-01'

=head2 is_time - whether this is a valid time string

  $bool=EasyTool::is_time($time_str)

=head2 time_2_timestamp - input is $time_str output is unix timestamp

  $timestamp=EasyTool::time_2_timestamp($time_str)

=head2 hash_2_timestamp - input is hash output is unix timestamp

  $timestamp=EasyTool::hash_2_timestamp($rh_time)

=head2 time_2_hash

  $rh_time=EasyTool::time_2_hash($time_str)

=head2 get time of now

  $timestamp=EasyTool::now();
  $timestamp=EasyTool::time();
  $datetime=EasyTool::datetime_now();
  $date=EasyTool::date_now();

=head2 day_of_month - get day count of specified month

  $day_count=day_of_month($year,$month)

=head2 day_of_week - get day number in week

  $day_count=day_of_week($time_str)

=head2 set time funcion
  
  $timestamp=EasyTool::timestamp_set($time_str,$rh_time);
  $date=EasyTool::date_set($time_str,$rh_time);
  $datetime=EasyTool::datetime_set($time_str,$rh_time)

=head2 time operate funcion

  $timestamp=EasyTool::timestamp_add($time_str,$rh_offset);
  $datetime=EasyTool::datetime_add($time_str,$rh_offset);
  $date=EasyTool::date_add($time_str,$rh_offset)

=head1 COPYRIGHT

The EasyTool module is Copyright (c) 2003-2005 QIAN YU.
All rights reserved.

You may distribute under the terms of either the GNU General Public
License or the Artistic License, as specified in the Perl README file.

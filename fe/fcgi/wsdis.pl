#!/usr/bin/perl
 
use bigint;
use re 'eval';
 
my %ops = (
  'push'  => { 'imp' => 's',  'code' => 's',  'arg' => 'int'   },
  'dup'   => { 'imp' => 's',  'code' => 'ns', 'arg' => 'void'  },
  'copy'  => { 'imp' => 's',  'code' => 'ts', 'arg' => 'int'   },
  'swap'  => { 'imp' => 's',  'code' => 'nt', 'arg' => 'void'  },
  'pop'   => { 'imp' => 's',  'code' => 'nn', 'arg' => 'void'  },
  'slide' => { 'imp' => 's',  'code' => 'tn', 'arg' => 'int'   },
  'add'   => { 'imp' => 'ts', 'code' => 'ss', 'arg' => 'void'  },
  'sub'   => { 'imp' => 'ts', 'code' => 'st', 'arg' => 'void'  },
  'mul'   => { 'imp' => 'ts', 'code' => 'sn', 'arg' => 'void'  },
  'div'   => { 'imp' => 'ts', 'code' => 'ts', 'arg' => 'void'  },
  'mod'   => { 'imp' => 'ts', 'code' => 'tt', 'arg' => 'void'  },
  'stor'  => { 'imp' => 'tt', 'code' => 's',  'arg' => 'void'  },
  'retr'  => { 'imp' => 'tt', 'code' => 't',  'arg' => 'void'  },
  'mark'  => { 'imp' => 'n',  'code' => 'ss', 'arg' => 'label' },
  'call'  => { 'imp' => 'n',  'code' => 'st', 'arg' => 'label' },
  'jump'  => { 'imp' => 'n',  'code' => 'sn', 'arg' => 'label' },
  'jzero' => { 'imp' => 'n',  'code' => 'ts', 'arg' => 'label' },
  'jneg'  => { 'imp' => 'n',  'code' => 'tt', 'arg' => 'label' },
  'ret'   => { 'imp' => 'n',  'code' => 'tn', 'arg' => 'void'  },
  'end'   => { 'imp' => 'n',  'code' => 'nn', 'arg' => 'void'  },
  'putc'  => { 'imp' => 'tn', 'code' => 'ss', 'arg' => 'void'  },
  'puti'  => { 'imp' => 'tn', 'code' => 'st', 'arg' => 'void'  },
  'getc'  => { 'imp' => 'tn', 'code' => 'ts', 'arg' => 'void'  },
  'geti'  => { 'imp' => 'tn', 'code' => 'tt', 'arg' => 'void'  },
);
 
my %vregex=('void'=>'','int'=>'[st]+n','label'=>'[st]*n');
 
sub parseb
{
  my $str = shift;
  my $blen = length($str) - 2;
  my $sign = substr $str, 0, 1, "0b";
  $sign =~ y/st/+-/;
  $str =~ y/stn/01/d;
  return " $sign" . oct($str) . "(${blen}b)";
}
my (%idic,%cregex);
while ( my ($k,$v)=each %ops )
{
  $idic{join'',@{$v}{qw(imp code)}}={inst=>$k,arg=>$v->{arg}};
  push @{$cregex{$v->{imp}}},$v->{code};
}
$_=join'|',@$_ for values %cregex;
 
my $impregex=join '|',do{my%tmp;@tmp{map$_->{imp},values%ops}=();keys%tmp};
undef $/;
#my $enc=<>=~y/ \t\n\0-\xff/stn/dr;
my $enc;
($enc=<>)=~y/ \t\n\0-\xff/stn/d;
my $iref;
while ( $enc=~/\G($impregex)((??{$cregex{$1}}))((??{$iref=$idic{"$1$2"};$vregex{$iref->{arg}}}))/g )
{
  my $v=$3 eq '' ? '' : $3 eq 'n' ? ' null' : parseb($3);
  print $iref->{inst}, $v, "\n";
}

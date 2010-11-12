#!./perl -w

BEGIN {
    chdir 't' if -d 't';
    @INC = '../lib';
}

require './test.pl';
plan( tests => 73 );


package x;
sub new { bless {}, shift }
sub test { 1 }
sub fail { die "fail\n" }

package main;
sub f($) { $_[0] }
@a = (1,2,3);
ok( $c = x&&->new,     'constant &&->' );
ok( $c&&->test,        '&&->member' );
ok( $c&&->test(),      '&&->member()' );
ok( $c&&->test(1,2,3), '&&->member(args)' );
ok( $c&&->test(@a),    '&&->member(@args)' );
ok( f $c &&->test,     'f &&->member (weird toke.c error)' );

undef $c;

ok( !defined eval { $cc    &&-> fail;        } and !$@, 'undef &&->fail',        $@ );
ok( !defined eval { $cc    &&-> fail();      } and !$@, 'undef &&->fail()',      $@ );
ok( !defined eval { $cc    &&-> fail(1,2,3); } and !$@, 'undef &&->fail(args)',  $@ );
ok( !defined eval { $cc    &&-> fail(@a);    } and !$@, 'undef &&->fail(@args)', $@ );
ok( !defined eval { $c     &&-> fail;        } and !$@, 'explicit undef &&->fail',        $@ );
ok( !defined eval { $c     &&-> fail();      } and !$@, 'explicit undef &&->fail()',      $@ );
ok( !defined eval { $c     &&-> fail(1,2,3); } and !$@, 'explicit undef &&->fail(args)',  $@ );
ok( !defined eval { $c     &&-> fail(@a);    } and !$@, 'explicit undef &&->fail(@args)', $@ );
ok( !defined eval { undef  &&-> fail;        } and !$@, 'literal undef &&->fail',        $@ );
ok( !defined eval { undef  &&-> fail();      } and !$@, 'literal undef &&->fail()',      $@ );
ok( !defined eval { undef  &&-> fail(1,2,3); } and !$@, 'literal undef &&->fail(args)',  $@ );
ok( !defined eval { undef  &&-> fail(@a);    } and !$@, 'literal undef &&->fail(@args)', $@ );

$s = sub { 1 };

ok( $s&&->(),           '&&->()' );
ok( $s&&->(1,2,3),      '&&->(args)' );
ok( $s&&->(@a),         '&&->(@a)' );

undef $s;

ok( !defined eval { $ss   &&-> ();      } and !$@, 'undef &&-> ()',      $@ );
ok( !defined eval { $ss   &&-> (1,2,3); } and !$@, 'undef &&-> (args)',  $@ );
ok( !defined eval { $ss   &&-> (@a);    } and !$@, 'undef &&-> (@args)', $@ );
ok( !defined eval { $s    &&-> ();      } and !$@, 'explicit undef &&-> ()',      $@ );
ok( !defined eval { $s    &&-> (1,2,3); } and !$@, 'explicit undef &&-> (args)',  $@ );
ok( !defined eval { $s    &&-> (@a);    } and !$@, 'explicit undef &&-> (@args)', $@ );
ok( !defined eval { undef &&-> ();      } and !$@, 'literal undef &&-> ()',      $@ );
ok( !defined eval { undef &&-> (1,2,3); } and !$@, 'literal undef &&-> (args)',  $@ );
ok( !defined eval { undef &&-> (@a);    } and !$@, 'literal undef &&-> (@args)', $@ );

$a = [1,2,3];

is( $a &&-> [0], 1,      '&&-> []' );
is( $a &&-> [1], 2,      '&&-> []' );
is( f($a &&-> [2] ), 3,  '&&-> [], lvalue defer' );

undef $a;

ok( !defined eval { $aa   &&-> [0] } and !$@, 'undef &&-> []', $@ );          ok( ref $aa ne 'ARRAY', '&&-> [] no vivify' );
ok( !defined eval { $a    &&-> [0] } and !$@, 'explicit undef &&-> []', $@ ); ok( ref $a  ne 'ARRAY', '&&-> [] no vivify' );
ok( !defined eval { undef &&-> [0] } and !$@, 'literal undef &&-> []', $@ );
ok( !defined eval { f($a &&-> [2]) } and !$@, 'undef &&-> [], lvalue defer' );

$h = { a=>1, b=>2, c=>3 };
sub c { 'c' }

is( $h &&->{a},     1,    '&&->{}');
is( $h &&->{'b'},   2,    '&&->{""}');
is( $h &&->{c()},   3,    '&&->{c()}');
is( f($h &&->{b}),  2,    '&&->{}, lvalue defer');

undef $h;

ok( !defined eval { $hh   &&->{a}   } and !$@, 'undef &&->{}');      ok( ref $hh ne 'HASH', '&&-> {} no vivify' );
ok( !defined eval { $hh   &&->{'b'} } and !$@, 'undef &&->{""}');    ok( ref $hh ne 'HASH', '&&-> {""} no vivify' );
ok( !defined eval { $hh   &&->{c()} } and !$@, 'undef &&->{c()}');   ok( ref $hh ne 'HASH', '&&-> {c()} no vivify' );
ok( !defined eval { $h    &&->{a}   } and !$@, 'explicit undef &&->{}');        ok( ref $h ne 'HASH', '&&-> {} no vivify' );
ok( !defined eval { $h    &&->{'b'} } and !$@, 'explicit undef &&->{""}');      ok( ref $h ne 'HASH', '&&-> {""} no vivify' );
ok( !defined eval { $h    &&->{c()} } and !$@, 'explicit undef &&->{c()}');     ok( ref $h ne 'HASH', '&&-> {c()} no vivify' );
ok( !defined eval { f($h  &&->{c})  } and !$@, 'explicit undef &&->{}, lvalue defer'); ok( ref $h ne 'HASH', 'f(&&-> {}) no vivify' );
ok( !defined eval { undef &&->{a}   } and !$@, 'literal undef &&->{}');
ok( !defined eval { undef &&->{'b'} } and !$@, 'literal undef &&->{""}');
ok( !defined eval { undef &&->{c()} } and !$@, 'literal undef &&->{c()}');

package complicated;
sub new { bless {}, shift }
sub complex { return { big => { long => [ { nested => ["tables","structures"] }, { with => [ "arrays", "arrayrefs" ] } ] } } }
sub simple { return undef };
sub medium { return {} };

package main;

ok( $complicated = complicated&&->new() );
is( $complicated&&->complex&&->{big}&&->{long}&&->[0]&&->{nested}&&->[0], "tables" );
is( $complicated&&->complex&&->{big}&&->{long}&&->[0]&&->{nested}&&->[1], "structures" );
is( $complicated&&->complex&&->{big}&&->{long}&&->[1]&&->{with}&&->[0],   "arrays" );
is( $complicated&&->complex&&->{big}&&->{long}&&->[1]&&->{with}&&->[1],   "arrayrefs" );
is( $complicated&&->complex&&->{nop}&&->{long}&&->[0]&&->{nested}&&->[0], undef );
is( $complicated&&->complex&&->{big}&&->{xxxx}&&->[0]&&->{nested}&&->[0], undef );
is( $complicated&&->complex&&->{big}&&->{long}&&->[4]&&->{nested}&&->[0], undef );
is( $complicated&&->complex&&->{big}&&->{long}&&->[0]&&->{futons}&&->[0], undef );
is( $complicated&&->complex&&->{big}&&->{long}&&->[0]&&->{nested}&&->[4], undef );
is( $complicated&&->simple&&->{big}&&->{long}&&->[0]&&->{nested}&&->[0],  undef );
is( $complicated&&->medium&&->{big}&&->{long}&&->[0]&&->{nested}&&->[0],  undef );
is( $xxxxxxxxxxx&&->complex&&->{big}&&->{long}&&->[0]&&->{nested}&&->[0], undef );
$xxxxxxxxxxx=1; #Shutup, perl

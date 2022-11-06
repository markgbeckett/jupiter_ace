: pi 3.14159 ;

: dr pi 180 f/ ;

: rd 1 dr f/ ;

: 2drop ( fp -- )
    drop drop
;

: 2dup ( fp -- fp fp )
    over over
;

: 2swap ( fp1 fp2 -- fp2 fp1 )
    4 roll 4 roll
;

: 2over ( fp1 fp2 -- fp1 fp2 fp1 )
    4 pick 4 pick
;

: 2rot ( fp1 fp2 fp3 -- fp2 fp3 fp1 )
    6 roll 6 roll
;

: 2@ ( addr -- fp )
    dup @ swap 2+ @
;

: 2! ( fp addr -- )
    rot over ! 2+ !
;

: 2roll ( fpn ... fp1 n -- fpn-1 ... fp1 fpn )
    2 * dup 1+
    roll swap roll
;

: sqrt ( fp -- fp )
    1.0 10 0 do
	2over 2over f/ f+
	0.5 f*
    loop

    2swap 2drop
;

: sin ( fp -- fp )
    2dup 2dup 2dup f* fnegate
    2rot 2rot
    27 2 do
	6 pick 6 pick
	f* i i 1+ *
	ufloat f/
	2dup 2rot f+ 2swap
	2
    +loop

    2drop 2swap 2drop
;

: cos ( fp -- fp )
    1.57080
    2swap f-
    sin
;

: tan ( fp -- fp )
    2dup sin
    2swap cos
    f/
;

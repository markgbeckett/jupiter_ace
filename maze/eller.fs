DECIMAL 16 BASE C!

10 CONSTANT WIDTH
10 CONSTANT HEIGHT

: YESNO
    3C2B C@ 1 AND
;

: GR ( PATTERN<8> ASCII -- )
    8 * 2BFF + DUP
    8 +
    DO
	I C! -1
    +LOOP
;

00 00 00 00 00 00 00 00 00 GR

01 01 01 01 01 01 01 01 01 GR

00 00 00 00 00 00 00 FF 02 GR

01 01 01 01 01 01 01 FF 03 GR

CREATE MAZE WIDTH HEIGHT * 2 * ALLOT

: MAZE@ ( COL ROW -- VAL )
    WIDTH * + 2 * MAZE +
    C@
;

: MAZE! ( VAL COL ROW -- )
    WIDTH * + 2 * MAZE +
    C!
;

: SET@ ( COL ROW -- VAL )
    WIDTH * + 2 * MAZE 1+ +
    C@
;

: SET! ( VAL COL ROW -- )
    WIDTH * + 2 * MAZE 1+ +
    C!
;

: RESETMAZE ( -- )
    HEIGHT 0 DO
	WIDTH 0 DO
	    3
	    I J WIDTH * + 2 * MAZE +
	    !
	LOOP
    LOOP
;

: PRROW ( ROW -- )
    1 EMIT
    WIDTH 0 DO
	I OVER MAZE@
	EMIT
    LOOP
    CR
    DROP
;

: PRMAZE
    CR SPACE
    WIDTH 0 DO
	2 EMIT
    LOOP
    CR

    HEIGHT 0 DO
	I PRROW
    LOOP
;

: ?RIGHT ( COL ROW -- )
    MAZE@ 1 AND
;

: CLEARRIGHT ( COL ROW -- )
    OVER OVER MAZE@
    FE AND
    ROT ROT MAZE!
;

: ?DOWN ( COL ROW -- )
    MAZE@ 2 AND
;

: CLEARDOWN ( COL ROW -- )
    OVER OVER MAZE@
    FD AND
    ROT ROT MAZE!
;

1 VARIABLE NEXTSET

: ASSIGNSETS ( ROW -- )
    WIDTH 0 DO
	I OVER SET@ 0= IF
	    NEXTSET @ DUP
	    I 4 PICK SET!
	    1+ NEXTSET !
	THEN
    LOOP

    DROP
;

: MERGESETS ( ROW NEW OLD -- )
    WIDTH 0 DO
	I 4 PICK SET@ ( R N O V -- )
	3 PICK = IF  ( R N O -- )
	    I 4 PICK CLEARRIGHT
	THEN
    LOOP
    
    WIDTH 0 DO
	I 4 PICK SET@ ( R N O S -- )
	OVER = IF ( R N O -- )
	    OVER I 5 PICK 
	    SET!
	THEN
    LOOP
    DROP DROP DROP
;

    



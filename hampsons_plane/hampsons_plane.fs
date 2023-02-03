DECIMAL 16 BASE C!

: KEY ( -- C )
    ( CLEAR PREVIOUS KEY PRESSES )
    BEGIN
	INKEY 0=
    UNTIL
    
    ( WAIT FOR KEY PRESS )
    BEGIN
	INKEY
    ?DUP UNTIL

    ( ECHO TO SCREEN )
    DUP ECHO
;

: .2DIGIT ( N -- )
    ( PRINT 2-DIGIT NUMNER )
    00 ( CONVERT TO DOUBLE-PRECISION )
    <# # # #>
    TYPE
;

: GR ( N7 N6 N5 N4 N3 N2 N1 N0 C -- )
    8 * 2BFF + DUP 8 + DO
	I C!
    -1 +LOOP
;

: SETUP ( -- )
    ( SET UP UDG )
    00 7E 7E 7E 7E 7E 7E 00 10 GR
    C3 81 00 00 00 00 81 C3 11 GR
;
	
: RAND ( -- N )
    ( CRUDE RANDOM-NUMBER GENERATOR )
    3C2B @ ( FRAMES )

    BEGIN
	( WAIT FOR IT TO CHANGE )
	3C2B @ OVER = 0=
    UNTIL

    1FFF AND ( NARROW DOWN TO ROM ADDRESSES )
    C@ ( RETRIEVE VALUE )
;

: SCREEN
    ( PRINT GAME BOARD )
    CLS
    
    ." ###abcdefghijklmnopqrstuvwxyz###"

    23 EMIT 23 EMIT
    1C 0 DO 10 EMIT LOOP
    23 EMIT 23 EMIT
    
    0B 1 DO
	I A < IF ." 0" THEN
	I .

	24 0 DO 10 EMIT LOOP

	I A < IF ." 0" THEN
	I .
    LOOP
    
    23 EMIT 23 EMIT
    1C 0 DO 10 EMIT LOOP
    23 EMIT 23 EMIT

    ." ###abcdefghijklmnopqrstuvwxyz###"
;

: TURN9 ( ASCIIROW ASCIICOL1 ASCIICOL2 -- )
    ( WORK OUT ROW OFFSET )
    ASCII 0 -
    SWAP
    ASCII 0 -
    A * + 

    20 * ( 20h CHARS PER ROW )

    SWAP

    ( WORK OUT COLUMN OFFSET )
    ASCII a -

    ( COMBINE TO GIVE GAME-BOARD OFFSET )
    +
    DISPLAY + 2 + ( 2400H )

    ( INVERT NINE-TILE FOOTPRINT AROUND SELECTED TILE )
    3 0 DO
	DUP DUP
	@ 0101 XOR
	SWAP !

	DUP 2+ DUP
	C@ 01 XOR
	SWAP C!
	20 +
    LOOP

    DROP	
;

: INP3
    BEGIN
	14 0 AT ." Give letter   " KEY

	DUP 60 > OVER 7B < AND 0= ( CHECK A-Z )
    WHILE
        ( REPEAT IF NOT )
        DROP
    REPEAT

    BEGIN
	14 0 AT ." Give first digit" KEY
	DUP 30 = OVER 31 = OR 0= ( CHECK 0-1 )
    WHILE
        ( REPEAT IF NOT )
        DROP
    REPEAT

    BEGIN
	14 0 AT ." Give second digit" KEY
	DUP 2F > OVER 3A < AND 0= ( CHECK 0-9 )
    WHILE
	    DROP ( REPEAT, IF NOT )
    REPEAT
    14 0 AT 20 SPACES
;

: SKILL
    14 0 AT ." Skill level "
    KEY 30 -

    64 * 0 DO
	BEGIN
	    RAND 1F AND
	    DUP 19 >
	WHILE
	    DROP
	REPEAT

	61 + ( CONVERT TO COLUMN VALUE )
	RAND 1 AND

	BEGIN
	    RAND F AND
	    OVER 0A *
	    OVER  + 0D >
	WHILE
	    DROP
	REPEAT

	31 + SWAP 30 + SWAP TURN9
    LOOP
;

: ?FINISHED ( -- FLAG )

    2422 1
    10 0 DO
	OVER DUP 1C + SWAP DO
	    I C@ 10 = AND
	LOOP

	SWAP 20 + SWAP
    LOOP

    SWAP DROP
;

: GAME ( -- )
    SETUP
    SKILL

    BEGIN
	INP3 TURN9
	?FINISHED
    UNTIL

    KEY
;

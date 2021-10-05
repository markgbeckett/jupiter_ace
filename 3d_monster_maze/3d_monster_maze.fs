( CASE CONSTRUCT FOR JUPITER ACE / MINSTREL 4TH )

( CHECK SYNTAX GUIDES MATCH )
: ?PAIRS ( M N -- FLAG )
  = 0= ( ARE THEY NOT EQUAL? )
  IF
    ." ERROR 5" CR ABORT ( ABORT COMPILATION, IF NOT EQUAL )
  THEN
;

0 COMPILER CASE
  0 ( MARKER ON STACK, USED BY ENDCASE TO CHECK DONE )
  9 ( SYNTAX GUIDE, MUST MATCH WITH 'OF' )
RUNS>
  DROP ( NOTHING TO DO EXCEPT DROP ADDR OF PARAMETER FIELD )
;

2 COMPILER OF
  9 ?PAIRS ( CHECK PRECEDED BY CASE OR ENDOF )
  HERE ( SAVE CURRENT DICTIONARY LOCATION FOR ENDOF )
  0 , ( RESERVE TWO BYTES AT THAT LOCATION )
  7 ( SYNTAX GUIDE, MUST MATCH WITH 'ENDOF' )
RUNS>
  >R ( SAVE PARAMETER-FIELD ADDR )
  OVER = ( CHECK FOR MATCH WITH CASE VALUE, PRESERVING COPY OF INPUT )
  R> ( RECOVER PARAMETER-FIELD ADDR )
  SWAP ( BRING MATCH RESULT BACK TO TOP OF STACK )
  IF ( INDICATES MATCH ) 
    DROP DROP ( DROP PARAMETER-FIELD ADDR AND INPUT, AS DONE )
  ELSE
    @ ( RETRIEVE OFFSET TO NEXT 'OF' FROM PARAMETER FIELD )
    R> + >R ( ADVANCE TO NEXT 'OF' STATEMENT )
  THEN
;

( IF SYNTAX IS CORRECT, TOS = 7 AND 2OS = PARAM FIELD OF 'OF'
2 COMPILER ENDOF
  7 ?PAIRS ( CHECK PRECEDED BY 'OF' )
  HERE ( PUT CURRENT DICTIONARY LOCATION ON STACK )
  SWAP ( SWAP WITH ADDRESS OF PARAM FIELD FOR 'OF' )
  0 , ( RESERVE TWO BYTES IN DICTIONARY )
  OVER OVER - ( WORK OUT OFFSET FROM 'OF' TO 'HERE' )
  SWAP ! ( STORE IN PARAMETER FIELD OF 'OF' )
  9 ( SYNTAX GUIDE, MUST MATCH TO 'OF' OR 'OTHERWISE' )
RUNS>
  @ ( RETRIEVE OFFSET TO JUST AFTER 'ENDCASE' FROM PARAMETER FIELD )
  R> + 4 - >R ( APPLY TO RETURN ADDRESS, NEED TO BACKTRACK BY 4 )
;

0 COMPILER OTHERWISE
  9 ?PAIRS ( CHECK PRECEDED BY 'CASE' OR 'ENDOF' )
  8 ( SYNTAX GUIDE, MUST MATCH WITH 'ENDCASE' )
RUNS>
  DROP DROP ( DROP PARAMETER-FIELD ADDR AND INPUT, AS DONE )
;

0 COMPILER ENDCASE
  8 ?PAIRS ( CHECK PRECEDED BY 'OTHERWISE' )
  BEGIN 
    ?DUP ( IF PARAMETER-FIELD ADDRESS NON-ZERO, DUPLICATE )
  WHILE ( OTHERWISE, ALL DONE )
    HERE OVER - ( WORK OUT OFFSET )
    SWAP ! ( STORE IN PARAMETER FIELD OF 'ENDOF' )
  REPEAT ( DO FOR EACH 'ENDOF' )
RUNS>
  DROP ( DROP PARAMETER FIELD, AS DONE )
;

( REPRODUCED FROM S. VICKERS 'FORTH PROGRAMMING', P 143 )
: .S ( -- )
    ( USEFUL FOR DEBUGGING )
    15419 @ HERE 12 +
    OVER OVER -
    IF
	DO
	    I @
	    .
	2 +LOOP
    ELSE
	DROP
	DROP
    THEN
;

( RANDOM NUMBER GENERATOR FROM S. VICKERS, "PROGRAMMING FORTH", P. 83 )
0 VARIABLE SEED

( UPDATE RANDOM-NUMBER SEED )
: SEEDON
    SEED @ 75 U* 75 0 D+
    OVER OVER U< - -
    1- DUP SEED !
;

( GENERATE RANDOM NUMBER )
: RND ( N -- RND(N) )
    SEEDON U* SWAP DROP
;

( SET RANDOM NUMBER SEED )
: RAND ( N -- )
    ?DUP 0=
    IF
	15403 @ SWAP
    THEN
    
    SEED !
;

( ALLOCATE SPACE FOR MAZE IN MEMORY )
CREATE MAZE 16 18 * ALLOT

( DISPLAY MAZE ON-SCREEN, FOR DEBUGGING )
: PRINTMAZE ( -- )
    18 0 DO ( STEP THROUGH ROWS )
	I 2 + 2 AT ( BEGIN AT COLUMN TWO )
	16 0 DO ( STEP THROUGH COLUMNS )
	    ( RETRIEVE CELL DATA FOR LOCATION )
	    J 16 * I + MAZE + C@
	    ( TRANSLATE INTO PRINTABLE CHARACTER )
	    CASE
		128 OF
		    ASCII W EMIT
		ENDOF
		0 OF
		    32 EMIT
		ENDOF
		51 OF
		    ASCII M EMIT
		ENDOF
		45 OF
		    ASCII E EMIT
		ENDOF
		8 OF
		    ASCII : EMIT
		ENDOF
		OTHERWISE
		ASCII . EMIT
	    ENDCASE
	LOOP
    LOOP
;

( INITIALISE MAZE WITH ALL WALLS FILLED IN )
: CLEARMAZE ( -- )
    MAZE DUP 16 18 * + SWAP
    DO
	128 I C! ( 128 IS CODE FOR WALL )
    LOOP
;

: MAZEGET ( X Y -- C )
    SWAP 16 * +
    MAZE +
    C@
;

: MAZESET ( X Y C -- )
    >R ( SAVE NEW VALUE )
    SWAP 16 * +
    MAZE +
    R>
    SWAP C!
;

: MOVENORTH ( X Y -- NX NY FLAG )
    SWAP
    DUP 0> IF
	1- SWAP 1
    ELSE
	SWAP 0
    THEN
;

: MOVESOUTH ( X Y -- NX NY FLAG )
    SWAP
    DUP 17 < IF
	1+ SWAP 1
    ELSE
	SWAP 0
    THEN
;

: MOVEEAST ( X Y -- NX NY FLAG )
    DUP 15 < IF
	1+ 1
    ELSE
	0 
    THEN
;

: MOVEWEST ( X Y -- NX NY FLAG )
    DUP 0> IF
	1- 1
    ELSE
	0 
    THEN
;

: 2DUP ( X Y -- X Y X Y )
    OVER
    OVER
;

: TRYNORTH ( X Y -- NX NY FLAG )
    MOVENORTH ( ATTEMPT TO MOVE NORTH )

    0= IF ( IF FAIL, THEN EXIT )
	0 EXIT
    THEN

    2DUP MAZEGET ( RETRIEVE NEW-LOCATION STATUS )

    0= IF ( IF ALREADY A PASSAGE,  EXIT )
	1 EXIT
    THEN

    OVER 0= IF ( IF TOP OF THE MAZE, REVERSE AND EXIT )
	MOVESOUTH
	DROP
	0 EXIT
    THEN

    2DUP 1+ MAZEGET ( CHECK IF PASSAGE TO EAST OF NEW LOCATION )

    0= IF ( REVERSE AND EXIT, IF SO )
	MOVESOUTH
	DROP
	0 EXIT
    THEN

    2DUP 1- MAZEGET ( CHECK IF PASSAGE TO WEST OF NEW LOCATION )

    0= IF ( REVERSE AND EXIT, IF SO )
	MOVESOUTH
	DROP
	0 EXIT
    THEN

    2DUP 0 MAZESET ( ALL GOOD, SO EXTEND PASSAGE AND REPORT SUCCESS )
    1
;

: TRYSOUTH ( X Y -- NX NY FLAG )
    MOVESOUTH ( ATTEMPT TO MOVE SOUTH )

    0= IF ( IF FAIL, THEN EXIT )
	0 EXIT
    THEN

    2DUP MAZEGET ( RETRIEVE NEW-LOCATION STATUS )

    0= IF ( IF ALREADY A PASSAGE, THEN EXIT )
	1 EXIT
    THEN

    OVER 17 = IF ( IF BOTTOM OF THE MAZE, REVERSE AND EXIT )
	MOVENORTH
	DROP
	0 EXIT
    THEN

    2DUP 1+ MAZEGET ( CHECK IF PASSAGE TO EAST OF NEW LOCATION )

    0= IF ( REVERSE AND EXIT, IF SO )
	MOVESOUTH
	DROP
	0 EXIT
    THEN

    2DUP 1- MAZEGET ( CHECK IF PASSAGE TO WEST OF NEW LOCATION )

    0= IF ( REVERSE AND EXIT, IF SO )
	MOVESOUTH
	DROP
	0 EXIT
    THEN

    2DUP 0 MAZESET ( ALL GOOD, SO EXTEND PASSAGE AND REPORT SUCCESS )
    1
;

: TRYEAST ( X Y -- NX NY FLAG )
    MOVEEAST

    0= IF
	0 EXIT
    THEN

    2DUP MAZEGET

    0= IF
	1 EXIT
    THEN

    DUP
    15 = IF
	MOVEWEST
	DROP
	0 EXIT
    THEN
    

    OVER 1+ OVER MAZEGET

    0= IF
	MOVEWEST
	DROP
	0 EXIT
    THEN

    OVER 1- OVER MAZEGET

    0= IF
	MOVEWEST
	DROP
	0 EXIT
    THEN

    2DUP

    0 MAZESET
    1
;

: TRYWEST ( X Y -- NX NY FLAG )
    MOVEWEST

    0= IF
	0 EXIT
    THEN

    2DUP MAZEGET

    0= IF
	1 EXIT
    THEN

    DUP
    0= IF
	MOVEEAST
	DROP
	0 EXIT
    THEN
    
    OVER 1+ OVER MAZEGET

    0= IF
	MOVEEAST
	DROP
	0 EXIT
    THEN

    OVER 1- OVER MAZEGET

    0= IF
	MOVEEAST
	DROP
	0 EXIT
    THEN

    2DUP

    0 MAZESET
    1
;

: MAKEPASSAGE ( X Y DIR LEN -- NX NY )
    BEGIN
	>R ( SAVE LENGTH FOR LATER )

	DUP

	>R ( SAVE COPY OF DIRN FOR LATER )

	( EXTEND PASSAGE BASED ON VALUE OF DIRN )
	CASE
	    0 OF TRYNORTH ENDOF
	    1 OF TRYWEST ENDOF
	    2 OF TRYSOUTH ENDOF
	    3 OF TRYEAST ENDOF
	    OTHERWISE 0
	ENDCASE

	( RETRIEVE DIR AND LEN FROM RETURN STACK )
	R>
	R>

	( BRING STATUS TO TOP OF STACK AND TEST )
	ROT 0= IF ( ALL DONE )
	    DROP
	    DROP

	    EXIT
	THEN

	( DECREMENT LENGTH )
	1-

	( AND CHECK IF DONE )
	DUP
    0= UNTIL

    ( BALANCE STACK )
    DROP
    DROP
;

( SEE MANUAL. P. 147 )
DEFINER CODE
  DOES>
    CALL
;

: GR ( SEE MANUAL, P. 71 )
    8 * 11263 +
    DUP 8 +

    DO
	I C!
	-1
    +LOOP
;

: SETUPUDG
    ( CROSSHATCH PATTERN )
    170 85 170 85 170 85 170 85
    1
    GR
;

: TURNLEFT ( DIR -- NEWDIR )
    3 +
    4 MOD
;

: TURNRIGHT ( DIR -- NEWDIR )
    1+
    4 MOD
;

: MOVE ( X Y DIR -- NX NY )
    DUP
    2 MOD IF
	2 -
	+
    ELSE
	1-
	ROT +
	SWAP
    THEN
;

: 3DUP
    3 PICK
    3 PICK
    3 PICK
;

( FIRST COL AT DISTANCE )
CREATE DISTCOL   0 C,  1 C,  4 C,  6 C,  8 C,  9 C, 10 C,

( MAX WALL HEIGHT AT DISTANCE )
CREATE DISTWALL 20 C, 18 C, 12 C,  8 C,  4,C,  2 C,  2 C,

: DRAWLWALL ( COL FLAG -- )
    OVER 9216 +

    SWAP ( COL ADDR FLAG )

    IF ( WALL )
	OVER ?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN

	145 OVER C!
	32 +

	OVER -2 * 18 +

	?DUP IF
	    0 DO
		144 OVER C!
		32 +
	    LOOP
	THEN

	140 OVER C!
	32 +

	OVER ?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN
    ELSE
	SWAP
	DISTWALL + C@
	SWAP
	OVER 20 SWAP - 2 /

	?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN

	OVER 0 DO
	    1 OVER C!
	    32 +
	LOOP

	OVER 20 SWAP - 2 /
	?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN
    THEN

    DROP
    DROP
;

: DRAWRWALL ( COL FLAG -- )
    OVER 9236 SWAP - SWAP

    IF ( WALL )
	OVER ?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN

	146 OVER C!
	32 +

	OVER -2 * 18 +

	?DUP IF
	    0 DO
		144 OVER C!
		32 +
	    LOOP
	THEN

	23 OVER C!
	32 +

	OVER ?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN
    ELSE
	SWAP
	DISTWALL + C@
	SWAP
	OVER 20 SWAP - 2 /

	?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN

	OVER 0 DO
	    1 OVER C!
	    32 +
	LOOP

	OVER 20 SWAP - 2 /
	?DUP IF
	    0 DO
		32 OVER C!
		32 +
	    LOOP
	THEN
    THEN

    DROP
    DROP
;
	
: DRAWLSEG ( DIST FLAG -- )
    >R ( SAVE FLAG )
    DUP DISTCOL + 1+ C@ ( COMPUTE UPPER BOUND ON LOOP )
    SWAP DISTCOL + C@ ( COMPUTE LOWER BOUND ON LOOP )
    DO ( DRAW EACH WALL SEGMENT )
	I J DRAWLWALL
    LOOP

    R> DROP ( RETRIEVE FLAG AND DROP )
;

: DRAWRSEG ( DIST FLAG -- )
    >R ( SAVE FLAG ) 
    DUP DISTCOL + 1+ C@ ( COMPUTE UPPER BOUND ON LOOP )
    SWAP DISTCOL + C@ ( COMPUTE LOWER BOUND ON LOOP )
    DO ( DRAW EACH WALL SEGMENT )
	I J DRAWRWALL
    LOOP

    R> DROP ( RETRIEVE FLAG AND DROP )
;

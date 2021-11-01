( DEFINER FOR SMALL MACHINE-CODE ROUTINES )
( SEE MANUAL. P. 147 )
DEFINER CODE
  DOES>
    CALL
;

( SPACE IN WHICH TO HOLD COPY OF DISPLAY BUFFER )
( FOR DOUBLE BUFFERING )
( PROVIDED THIS IS START OF DICTIONARY, AFTER CODE, SHOULD )
( RESIDE AT #3C76 )
CREATE BUFFER 704 ALLOT

( CLEAR BUFFER - SETTING EACH CELL TO SPACE )
CODE FRAMECLEAR
    #21 C,  35 C,  3F C, ( LD HL, BUFFER+#02BF )
    #3E C, #20 C,        ( LD A, 'SPACE' )  
    #77 C,               ( LD <HL>, A )
    #11 C,  34 C,  3F C, ( LD DE, BUFFER+#02BE )
    #01 C, #BF C, #02 C, ( LD BC, #02BF )
    #ED C, #B8 C,        ( LDDR )
    #FD C, #E9 C,        ( JP IY )

( COPY BUFFER INTO DISPLAY )
CODE FRAMEUPDATE
    #21 C,  76 C,  3C C, ( LD HL, BUFFER )
    #11 C, #00 C, #24 C, ( LD DE, #2400 )
    #01 C, #C0 C, #02 C, ( LD BC, #02C0 )
    #ED C, #B0 C,        ( LDIR )
    #FD C, #E9 C,        ( JP IY )

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

( IF SYNTAX IS CORRECT, TOS = 7 AND 2OS = PARAM FIELD OF 'OF' )
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

: WAITKEY ( -- KEY )
    BEGIN
	INKEY 0=
    UNTIL

    BEGIN
	INKEY ?DUP
    UNTIL
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

16 CONSTANT MAZEW

18 CONSTANT MAZEH

( ALLOCATE SPACE FOR MAZE IN MEMORY )
CREATE MAZE MAZEW MAZEH * ALLOT

( DISPLAY MAZE ON-SCREEN, FOR DEBUGGING )
: PRINTMAZE ( -- )
    MAZEH 0 DO ( STEP THROUGH ROWS )
	I 2 + 2 AT ( BEGIN AT COLUMN TWO )
	MAZEW 0 DO ( STEP THROUGH COLUMNS )
	    ( RETRIEVE CELL DATA FOR LOCATION )
	    J MAZEW * I + MAZE + C@
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
    MAZE DUP MAZEW MAZEH * + SWAP
    DO
	128 I C! ( 128 IS CODE FOR WALL )
    LOOP
;

: MAZEGET ( X Y -- C )
    SWAP MAZEW * +
    MAZE +
    C@
;

: MAZESET ( X Y C -- )
    >R ( SAVE NEW VALUE )
    SWAP MAZEW * +
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
    DUP MAZEH 1- < IF
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

: 3DUP
    3 PICK
    3 PICK
    3 PICK
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
	MOVENORTH
	DROP
	0 EXIT
    THEN

    2DUP 1- MAZEGET ( CHECK IF PASSAGE TO WEST OF NEW LOCATION )

    0= IF ( REVERSE AND EXIT, IF SO )
	MOVENORTH
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

: CREATEMAZE
    MAZEH 2- MAZEW 2- ( COORDINATES OF BOTTOM-RIGHT CORNER )
    2DUP 0 MAZESET ( CREATE START OF PASSAGE )
    
    0 ( COUNTER )
    BEGIN
	4 RND ( CHOOSE RANDOM DIRECTION )
	6 RND 1+ ( CHOOSE RANDOM LENGTH, 1..6 )

	ROT OVER + ( UPDATE COUNTER )
	>R ( SAVE COUNTER )

	MAKEPASSAGE

	R> ( RETRIEVE COUNTER )

	DUP ( CHECK IF DONE )

	800 >
    UNTIL
    
    DROP
    DROP
    DROP
;

: MAKEEXIT ( -- )
    0 0 ( DUMMY STACK ENTRIES )
    BEGIN
	DROP DROP ( CLEAR PREVIOUS ATTEMPT )

	( COMPUTE NEW RANDOM LOCATION IN TOP ONE THIRD OF MAZE )
	MAZEH 3 / RND 1+ 
	MAZEW 2- RND 1+
	
	2DUP MAZEGET ( RETRIEVE MAZE ELEMENT )
    0= UNTIL ( CONTINUE UNTIL FIND A PASSAGE )

    ( INSERT EXIT )
    2DUP 
    45 MAZESET

    ( CHECK THERE IS ONLY ONE WAY TO GET TO EXIT )
    ( MAZE-GENERATION TECHNIQUE MEANS THERE MUST BE )
    ( AT LEAST ONE PATH )
    ( EX EY )

    ( RETRIEVE CELL VALUE TO NORTH )
    SWAP 1- SWAP MAZEGET

    ( IF PASSAGE, THEN SET FLAG TO CONFIRM NO MORE )
    0=

    >R ( STORE FLAG ON RETURN STACK )
    
    ( CHECK EAST )
    2DUP 1+
    MAZEGET

    ( IF PASSAGE, THEN CHECK IF THIS IS FIRST ONE )
    0= IF
	R> ( RETRIEVE FLAG FROM RETURN STACK )
	1 = IF
	    ( ALREADY A PASSAGE, SO MAKE THIS ONE A WALL )
	    2DUP 1+
	    128 MAZESET
	THEN
	
	( WHATEVER HAPPENED, THERE IS A PASSAGE )
	( AT THIS POINT )
	1 >R 
    THEN
    
    ( CHECK SOUTH )
    2DUP SWAP 1+ SWAP
    MAZEGET

    ( IF PASSAGE, THEN CHECK IF THIS IS FIRST ONE )
    0= IF
	R> ( RETRIEVE FLAG FROM RETURN STACK )
	1= IF
	    ( ALREADY A PASSAGE, SO MAKE THIS ONE A WALL )
	    2DUP SWAP 1+ SWAP
	    128 MAZESET
	THEN
	
	( WHATEVER HAPPENED, THERE IS A PASSAGE )
	( AT THIS POINT )
	1 >R
    THEN
    
    ( CHECK WEST )
    2DUP 1-
    MAZEGET

    0= IF
	R> ( RETRIEVE FLAG FROM RETURN STACK )
	1= IF
	    ( ALREADY A PASSAGE, SO MAKE THIS ONE A WALL )
	    2DUP 1-
	    128 MAZESET
	THEN
	
	( WHATEVER HAPPENED, THERE IS A PASSAGE )
	( AT THIS POINT )
	1 >R
    THEN

    ( CLEAR RETURN STACK AND BALANCE STACK )
    R> DROP
    DROP DROP
;

: PLACEREX ( -- )
    0 0 ( DUMMY COORDINATES TO START WITH )

    BEGIN
	DROP DROP
	MAZEH 4 / RND 1+
	MAZEW 2- RND 1+
	2DUP MAZEGET
    0= UNTIL

    51 MAZESET
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
	-
    ELSE
	1-
	ROT +
	SWAP
    THEN
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
	
( LOOK UP TABLE FOR WIDTH OF END WALL AT DIFFERENT DISTANCES )
CREATE DISTWIDTH 21 C, 19 C, 13 C, 9 C, 5 C, 3 C, 1 C,

( LOOK UP TABLE FOR HEIGHT OF END WALL AT DIFFERENT DISTANCES )
CREATE DISTHEIGHT 20 C, 18 C, 12 C, 8 C, 4 C, 2 C, 2 C, 

: DRAWEWALL ( DIST -- )
    DUP ( SAVE COPY OF DISTANCE )
    DISTWIDTH + C@ ( RETRIEVE WIDTH OF END WALL )
    21 OVER - 2 / >R ( WORK OUT AND SAVE OFFSET FROM LEFT )
    SWAP ( RETRIEVE SAVED COPY OF DIST )
    DISTHEIGHT + C@ ( RETRIEVE WALL HEIGHT )
    20 OVER - 2 / ( WORK OUT OFFSET FROM TOP )
    32 * ( TURN IT INTO A ROW OFFSET )
    9216 + R> + ( DISPLACE FROM BEGINNING OF DISPLAY BUFFER )

    SWAP 0 DO ( FOR EACH ROW )
	DUP

	3 PICK 0 DO ( FOR EACH COLUMN )
	    1 OVER C!
	    1+
	LOOP

	DROP
	32 +
    LOOP

    ( BALANCE STACK )
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

CREATE 3DVIEW 768 ALLOT ( SPACE FOR M/CODE )

0 VARIABLE EXITVIS ( INDICATES EXIT IS VISIBLE )

0 VARIABLE PLMOVED ( INDICATES FRAME NEEDS UPDATED )

: DRAWVIEW ( X Y DIR -- )
    0 ( START AT DISTANCE 0 )
    
    BEGIN
	>R ( SAVE CURRENT DISTANCE )

	( PRINT LEFT WALL SEGMENT )
	3DUP TURNLEFT MOVE MAZEGET
	128 = I SWAP DRAWLSEG ( 3DVIEW CALL )

	( PRINT RIGHT WALL SEGMENT )
	3DUP TURNRIGHT MOVE MAZEGET
	128 = I SWAP DRAWRSEG ( [ 3DVIEW 3 + ] CALL )

	( .S : X Y DIR )

	( MOVE FORWARD )
	>R I MOVE R>

	( CHECK FOR WALL )
	3 PICK 3 PICK MAZEGET

	DUP 45 = IF
	    I 1+
	    49F2 CALL ( DISPLAY EXIT )
	    DROP 1
	ELSE 128 = ( .S : X Y DIR FLAG1 )
	    DUP IF
		( IF END WALL, THEN DRAW )
		I 1+ DRAWEWALL ( [ 3DVIEW 6 + ] CALL )
	    THEN
	THEN
	
	R> 1+ DUP 6 =
	ROT

	( IF HAVE REACHED END WALL OR DISTANCE 6 WE ARE DONE )
	OR	
    UNTIL

    ( .S NX NY DIR DIST )

    ( CHECK IF GOT TO FULL DISTANCE )
    6 = IF
	DROP
	MAZEGET

	128 = IF
	    2 BUFFER 298 + 2 SWAP C!
	    3 BUFFER 330 + 3 SWAP C!
	ELSE
	    151 BUFFER 298 +  C!
	    19 BUFFER 330 +  C!
	THEN
    ELSE
	DROP
	DROP
	DROP
    THEN
   
;

: CYCLEPAT ( CYCLE EXIT PATTERN )
    [ 3DVIEW 12 + ] CALL ( 3DVIEW + 12 )

    ( UPDATE NEW CHARACTER )
    32 96 RND +
    2 RND 128 * + 
    SWAP C!
;

: TEST
    MAZEH 2- MAZEW 2- 0 ( STARTING POSITION FOR TEST )

    FRAMECLEAR
    1 PLMOVED ! ( NEED TO REDRAW FRAME )
    0 EXITVIS !
    
    BEGIN
	( CHECK IF NEED TO UPDATE VIEW )
	PLMOVED @ IF
	    FRAMECLEAR
	    3DUP DRAWVIEW
	    FRAMEUPDATE
	    0 PLMOVED !
	THEN

	( CHECK IF NEED TO UPDATE EXIT )
	EXITVIS @ ?DUP IF
	    [ 3DVIEW 9 + ] CALL
	    CYCLEPAT
	    FRAMEUPDATE
	THEN
	
	0 22 AT .S

	INKEY CASE
	    54 OF
		TURNLEFT
		1 PLMOVED !
	    ENDOF

	    57 OF
		TURNRIGHT
		1 PLMOVED !
	    ENDOF

	    56 OF
		3DUP MOVE MAZEGET
		128 - IF
		    >R I MOVE R>
		THEN
		1 PLMOVED !
	    ENDOF

	    OTHERWISE
	ENDCASE

	0
    UNTIL
;

    

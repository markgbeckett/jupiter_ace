( CLEARTRAIL .S DEM RUN INSTRS MAN STEP LR UD WAIT AUTO CHOICE RT LT DN UP MOUSE SRAM DRAW PATH DOOR MOVE SCAN X+ X- Y+ Y- SP XP YP PP PSET RAM SCR PRINT CLEAR IU IV IX OU OV OX P1 P T U V W X Y Z RND SEED GR G D )

( VARIABLES ARE USED, AS FOLLOWS:                        )
(   Z - MAZE SIZE--1, 2, OR 3                            )
(   P1 - LOCATION OF SCREEN COPY IN MEMORY               )
(   P - LOCATION OF CURRENT SCREEN SECTION IN MEMORY     )
(   W - LOCATION OF CURRENT MAZE SECTION IN MEMORY       )
(   U,V -- COORDINATE FOR ACTIVE MAZE SEGMENT            )
(                                                        )
(                                                        )
( MEMORY LAYOUT IS, AS FOLLOWS:                          )
( [HERE + 30]                                            )
( VARIABLE W POINTS TO ACTIVE MAZE SEGMENT               )
( BITS SET HAVE FOLLOWING MEANING:                       )
(  0 - CAN MOVE RIGHT FROM THIS CELL                     )
(  1 - CAN MOVE LEFT FROM THIS CELL                      )
(  2 - CAN MOVE UP FROM THIS CELL                        )
(  3 - CAN MOVE DOWN FROM THIS CELL                      )
(  4 - HAS BEEN VISITED DURING AUTO-SOLVER MODE          )
(  5 - WITH BIT 6, HOLDS BREADCRUMB TRAIL                )
(      00 - ARRIVED FROM LEFT                            )
(      01 - ARRIVED FROM RIGHT                           )
(      10 - ARRIVED FROM ABOVE                           )
(      11 - ARRIVED FROM BELOW                           )
(  7 - CELL HAS BEEN VISITED, DURING MAZE GENERATION     )
(                                                        )
(                                                        )
( INITIALISED AS FOLLOWS                                 )
( <---       32x         --->                            )
( 00 00 ...                00                            )
( 00 00 ...                00                            )
( ...                     ...   21x                      )
( 00 00 ...                00                            )
( [VARIABLES P AND P1 POINT HERE]                        )
( 01 01 ...             01 03                            )
( 01 01 ...             01 03                            )
( ...                     ...   20x                      )
( 01 01 ...             01 03                            )
( 02 02 ...             02 04                            )

( D - ARRAY OF 24 QUADRUPLES OF DIRECTIONS FOR MAZE GENERATION )

CREATE D ALLOT 48 ( 48 WORDS = 96 BYTES )

: GR ( -- )
    ( ASCII 1 = INTERIOR CELL )
    ( ASCII 2 = BOTTOM WALL )
    ( ASCII 3 = RIGHT-HAND WALL )
    ( ASCII 4 = BOTTOM, RIGHT-HAND CORNER )
    ( ADD 4 TO ASCII VALUE TO INCLUDE MOUSE )
    ( ADD 8 TO ASCII VALUE TO INCLUDE SMALL MOUSE )

    G ( LOCATION OF USER-DEFINED-GRAPHICS DATA )

    96 0 DO 
	DUP @
	11272 I + ( 11272 IS LOCATION OF ASCII 1 IN MEMORY )
	! ( WRITE TWO BYTES AT A TIME )
	2+
	2
    +LOOP

    DROP
;

: RND ( N -- RND N )
    SEED @
    75 U*
    75 0 D+
    OVER OVER
    U< - - 1-
    DUP
    SEED !
    U* SWAP
    DROP
;

( INITIALISE MAZE GRAPH AND IN-MEMORY COPY OF DISPLAY )
: CLEAR ( SIZE -- )
    ( SIZE = 1, 2, 3 FOR SMALL, MEDIUM, LARGE )
    Z ! ( STORE SIZE IN Z )

    HERE 30 + ( FIND FREE MEMORY IN WHICH TO PUT MAZE )
    DUP W ! ( W HOLDS START OF CURRENT MAZE SECTION )

    Z @ ( RETRIEVE SIZE )
    DUP * 336 *
    SWAP

    ( FILL MAZE GRAPH WITH ZEROS TWO BYTES AT A TIME )
    OVER 0 DO
	0 OVER ! 2+
    LOOP
    
    ( AFTER WORKSPACE COMES SCREEN BUFFER )
    DUP P ! ( P HOLDS START OF CURRENT DISPLAY SECTION )
    DUP P1 ! ( P1 HOLDS START OF DISPLAY BUFFER )

    ( FILL SCREEN BUFFER WITH ONES )
    SWAP 0 DO
	257 OVER ! ( 257 = 0101H )
	2+
    LOOP

    DROP ( STACK EMPTY )

    ( FOR EACH BOARD SECTION, SET RIGHT-MOST EDGE TO CONTAIN 03 )
    ( SET BOTTOM EDGE TO BE 02 AND BOTTOM, RIGHT CORNER )
    ( TO BE 04 )
    P @ 1-
    Z @ DUP * 0 DO
	20 0 DO
	    32 + ( MOVE TO END OF CURRENT ROW )
	    3 OVER C!
	LOOP

	1+ ( ADVANCE TO START OF ROW 32 OF SCREEN SECTION )
	16 0 DO
	    514 OVER ! 2+ ( 514 = 0202H )
	LOOP

	1- ( REVERSE ONE CELL, TO GET BOTTOM-RIGHT CORNER )
	4 OVER C!
    LOOP

    DROP ( STACK IS EMPTY )
;

: PRINT ( -- )
    P @ ( RETRIEVE START OF GAME BOARD )

    ( 9216 TO 9983 IS DISPLAY BUFFER )
    9888 9216 DO ( 21*32 CHARS )
	DUP
	@
	I !
	2+
	2
    +LOOP
    
    DROP
    
    ( PRINT GAME SEGMENT COORDINATES V,U )
    ( AT BOTTOM RIGHT CORNER )
    ( 9916 = 9216 + 21*32 + 28 )

    V @ 48 + ( CONVERT TO ASCII )
    9916 C!
    44 9917 C! ( 44 IS ASCII COMMA )
    U @ 48 + ( CONVERT TO ASCII )
    9918 C!
;

( ADD VALUE TO SCREEN OFFSET )
: SCR ( OFFSET INCREMENT -- OFFSET )
    OVER P @ + ( CALCULATE OFFSET INTO CURRENT SCREEN SECTION )

    DUP C@ ( OFFSET INCREMENT ADDR OLD_VALUE )
    ROT
    + ( OFFSET ADDR NEW_VALUE )

    DUP ROT C! ( SAVE NEW VALUE )
    OVER 9216 + C! ( AND UPDATE ACTUAL DISPLAY )
;

( APPLY OR MASK TO LOCATION IN MAZE GRAPH )
: RAM ( OFFSET MASK -- OFFSET )
    OVER W @ + ( CALCULATE OFFSET INTO GAME BOARD )
    
    DUP C@ ( RETRIEVE VALUE, KEEPING COPY OF ADDRESS )
    ROT ( .S : OFFSET ADDR OLD_VALUE MASK )
    OR ( APPLY MASK )

    SWAP C! ( SAVE NEW VALUE )
;
    ( FIND THE START OF THE ACTIVE BOARD   )
    ( SECTION IN MEMORY.                   )
    ( BOARD CONSISTS OF SIZE*SIZE SECTIONS )
    ( EACH SECTION IS 21*32 SQUARES, OR    )
    ( 672 BYTES, MEANING THE CURRENT       )
    ( SECTION IS SIZE*V + U SECTIONS IN,   )
    ( IN LINEARISED MEMORY                 )

( SET P TO POINT TO START OF CURRENT SCREEN SECTION )
: PSET
    U @ 1- ( RETRIEVE U AND NORMALISE TO ZERO )
    672 * ( WORK OUT ROW OFFSET )
    
    V @ 1- ( RETRIEVE V AND NORMALISE TO ZERO )
    Z @ ( RETRIEVE SIZE )
    * 672 * ( WORK OUT COLUMN OFFSET )

    + ( ADD ROW AND COLUMN OFFSET )
    HERE 30 + ( CALCULATE START OF MAZE GRAPH )
    OVER + W ! ( UPDATE W )

    P1 @ + ( RETRIEVE START OF SCREEN )
    P ! ( STORE START OF CURRENT SCREEN SECTION )
;

: PP
 ROT * 672 * DUP
 W @ + W !
 P @ + P !
 + PRINT
;

: YP
 DUP V @ + V
 ! DUP -608 * Z
 @ PP
;

: XP
 DUP U @ + U
 ! DUP -30 * 1
 PP
;

: SP
 U @ Z @ <
 IF
  U @ 1+ U !
 ELSE
  1 U ! V @
  Z @ <
  IF
   V @ 1+ V !
  ELSE
   1 V !
  THEN
 THEN
 PSET PRINT
;

: Y-
 X @ DUP 31 >
 IF
  32 - W @ +
  C@ 128 <
  IF
   X @ 4 RAM 2
   SCR 32 - 8 RAM
   X ! 1
  ELSE
   0
  THEN
 ELSE
  V @ 1 > OVER
  608 + W @ +
  672 Z @ * -
  C@ 128 < AND
  IF
   132 RAM 2 SCR -1
   YP DUP 32 + 2
   SCR DROP 8 RAM X
   ! 1
  ELSE
   DROP 0
  THEN
 THEN
;

: Y+
 X @ DUP 608 <
 IF
  32 + W @ +
  C@ 128 <
  IF
   X @ 8 RAM 32
   + 2 SCR 4 RAM
   32 RAM X ! 1
  ELSE
   0
  THEN
 ELSE
  V @ Z @ <
  OVER 608 - W @
  + 672 Z @ *
  + C@ 128 < AND
  IF
   136 RAM DUP 32 +
   2 SCR DROP 1 YP
   2 SCR 4 RAM 32
   RAM X ! 1
  ELSE
   DROP 0
  THEN
 THEN
;

: X-
 X @ DUP 31 AND
 0>
 IF
  1- W @ + C@
  128 <
  IF
   X @ 2 RAM 1
   SCR 1- 1 RAM 16
   RAM X ! 1
  ELSE
   0
  THEN
 ELSE
  U @ 1 > OVER
  642 - W @ +
  C@ 128 < AND
  IF
   130 RAM 1 SCR -1
   XP 1+ 1 SCR 1-
   1 RAM 16 RAM X
   ! 1
  ELSE
   DROP 0
  THEN
 THEN
;

: X+
 X @ DUP 31 AND
 30 <
 IF
  1+ W @ + C@
  128 <
  IF
   X @ 1 RAM 1+
   1 SCR 2 RAM 48
   RAM X ! 1
  ELSE
   0
  THEN
 ELSE
  U @ Z @ <
  OVER 642 + W @
  + C@ 128 < AND
  IF
   129 RAM 1+ 1 SCR
   1- 1 XP 1 SCR
   2 RAM 48 RAM X
   ! 1
  ELSE
   DROP 0
  THEN
 THEN
;

: SCAN
 X @ W @ +
 C@ 48 AND 16 /
 DUP 0 =
 IF
  X @ DUP 608 <
  IF
   32 + X !
  ELSE
   1 YP X !
  THEN
 ELSE
  DUP 1 =
  IF
   X @ DUP 31 AND
   30 <
   IF
    1+ X !
   ELSE
    1 XP X !
   THEN
  ELSE
   DUP 2 =
   IF
    X @ DUP 31 >
    IF
     32 - X !
    ELSE
     -1 YP X !
    THEN
   ELSE
    X @ DUP 31 AND
    0 >
    IF
     1- X !
    ELSE
     -1 XP X !
    THEN
   THEN
  THEN
 THEN
 DROP
;

( USED WHEN CREATING MAZE TO ADVANCE TO NEXT AVAILABLE SQUARE )
: MOVE ( OFFSET -- NEW_OFFSET )
    ( CHECK IF OFFSET < 150*SIZE^2 AND SET T ACCORDINGLY )
    DUP
    150 Z @ DUP
    * *

    < IF
	1 T !
    ELSE
	0 T !
    THEN

    ( .S : OFFSET )
    BEGIN
	24 RND ( PICK RANDOM NUMBER BETWEEN 0 AND 23 )
	DUP + DUP + ( THEM MULTIPLY BY 4 )
	1- D + 4 ( INDEX INTO D, WHICH STORES SEQUENCES OF SEARCH DIRECTIONS )

	( .S : OFFSET DIRN COUNT )
	BEGIN
	    OVER OVER + C@ ( RETRIEVE NEXT DIRECTION FROM D ARRAY )

	    DUP 1 = IF ( TRY TO MOVE RIGHT )
		X+
	    ELSE
		DUP 2 =	IF ( TRY TO MOVE LEFT )
		    X-
		ELSE
		    DUP 3 = IF ( TRY TO MOVE DOWN )
			Y+
		    ELSE ( TRY TO MOVE UP )
			Y- 
		    THEN
		THEN
	    THEN

	    IF ( MOVED, THEN CLEAR STACK AND EXIT )
		DROP DROP DROP ( .S : OFFSET )
		EXIT
	    THEN

	    DROP ( .S : OFFSET DIR COUNT )

	    1- ?DUP ( CHECK IF FURTHER DIRECTIONS TO TRY ... )
	WHILE
	REPEAT ( ... REPEAT, IF SO )

	( IF GET THIS FAR, THEN AT A DEAD END )
	DROP ( .S : OFFSET )
	
	SCAN ( BACKTRACK ONE STEP )

	0 ( AND TRY AGAIN )
    UNTIL
;


( CREATE DOOR -- THAT IS, ENTRY OR EXIT -- ON BORDER OF MAZE )
: DOOR ( N -- OFFSET CHAR )
    ( N  -- SIDE ON WHICH TO LOCATE DOOR 0=RIGHT; 1=TOP; 2=BOTTOM; 3=LEFT )
    ( OFFSET HOLDS OFFSET TO LOCATION OF DOOR IN CURRENT SEGMENT )
    ( CHAR INDICATES MODIFICATION TO BE APPLIED TO SCREEN FILE TO SHOW DOOR )

    3 OVER -
    OX ! ( STORE OPPOSITE WALL, WHICH WILL BE FOR EXIT, IF COMPUTING ENTRY )

    ( THIS IS EFFECTIVELY A BIG CASE STATEMENT )
    ?DUP IF ( IF N > 0 )
	1-
	?DUP IF ( IF N > 1 )
	    1-
	    ?DUP IF ( IF N = 3, LEFT-HAND WALL )
		20 RND 32 * ( RANDOMLY SELECT LOCATION ON LEFT-HAND WALL OF MAZE SECTION )
		DUP 
		X ! ( STORE IN X )

		( WORK OUT WHICH SECTION )
		1 U ! ( AS LEFT-HAND WALL, U MUST BE 1 )
		Z @ RND 1+ 
		V ! ( V RANDOMLY CHOSEN FROM 1, ..., Z+1 )
		SWAP ( .S : OFFSET 3 )
		
	    ELSE ( N = 2, BOTTOM WALL )
		31 RND 608 + ( RANDOMLY SELECT LOCATION ON BOTTOM WALL OF MAZE SECTION -- NOTE 608 = 19*32 )
		DUP X ! ( STORE IN X )

		( WORK OUT WHICH SECTION )
		Z @ DUP V ! ( AS RIGHTHAND SIDE, V MUST BE Z )
		RND 1+ U ! ( U RANDOMLY CHOSEN FROM 1, ..., Z+1 )
		32 + ( ADVANCE ONE ROW, AS IMAGE CORRECTION IS APPLIED ON ROW BELOW )
		2 ( .S : OFFSET 2 )
	    THEN
	ELSE ( N = 1, TOP WALL )
	    31 RND ( RANDOMLY SELECT LOCATION ON TOP WALL OF MAZE SECTION )
	    DUP X ! ( STORE IN X )

	    ( WORK OUT WHICH SECTION )
	    1 V ! ( AS TOP, V MUST BE 1 )
	    Z @ RND 1+ U ! ( U RANDOMLY CHOSEN FROM 1, ..., Z+1 )
	    2 ( .S : OFFSET 2 )
	THEN
    ELSE ( N = 0, RIGHT-HAND WALL )
	20 RND ( RANDOMLY CHOOSE ROW FOR ENTRY )
	32 * 30	+ ( WORK OUT OFFSET TO RIGHT-HAND WALL )
	DUP X ! ( STORE ENTRY LOCATION )
	Z @ DUP U ! ( U MUST BE RIGHT-MOST SECTION )
	RND ( WORK OUT VERTICAL SECTION, RANDOMLY )
	1+ V ! ( NORMALISE TO 1 AND STORE )
	1+ ( ADVANCE OFFSET TO NEXT CELL, AS RIGHTHAND WALL IS IN NEIGHBOUR )
	1 ( .S : OFFSET 1 )
    THEN
    
    PSET ( UPDATE MAZE-GRAPH AND SCREEN SECTION ADDR )
;

: PATH
    Z @ DUP * 620
    * 1-
    BEGIN
	X @ 128 RAM DROP
	MOVE 1- ?DUP
    WHILE
    REPEAT
;

: DRAW
 4 RND DOOR X @
 IX ! U @ IU
 ! V @ IV !
 PRINT SCR DROP PATH OX
 @ DOOR X @ 64
 RAM OX ! U @
 OU ! V @ OV
 ! SCR DROP
;

: SRAM ( X N -- X )
    OVER 
    W @ + 
    DUP C@ ( .S : X N LOC VAL )
    ROT AND ( .S : X LOC NEW_VAL )
    SWAP
    C! ( STORE UPDATED VALUE )
;

: MOUSE ( X FLAG -- X )
    IF
	( LOOP FOR 300*[4-Z] )
	4
	Z @ - 300
	* 0
	DO
	LOOP
    THEN
    
    4 SCR
;

( TRY TO MOVE MOUSE UP.                                         )
( FIRST, CHECK IF SQUARE ABOVE HAS BEEN VISITED.                )
(    IF SO, THEN CHECK IF THERE ARE OTHER OPTIONS TO LEAVE CELL )
(       IF THERE ARE, THEN EXIT, SO CAN TRY THOSE OPTIONS       )
(    OTHERWISE, KNOW AT DEAD END, SO                            )
(       BACKTRACK UP BUT BLOCK OFF CELL BELOW                   )
( OTHERWISE, NOT VISITED SO                                     ) 
(    MOVE UP NORMALLY                                          )
: UP ( OFFSET -- NEW_OFFSET FLAG )
    DUP
    DUP 32 < ( CHECK IF FIRST ROW )
    DUP T ! ( STORE ANSWER IN T )

    ( .S : OFFSET OFFSET FLAG )
    IF ( FIRST ROW OF SEGMENT )
	640 + Z @ 672 * - ( CALCULATE CORRESPONDING LOCATION IN ABOVE SEGMENT )
    THEN
    
    32 - W @ + C@ ( MOVE UP AND RETRIEVE STATUS OF CELL )

    16 AND ( CHECK IF VISITED )
    IF
	DUP W @ + C@ ( RETRIEVE STATUS AT CURRENT LOCATION )
	11 AND ?DUP ( CHECK IF OTHER DIRECTIONS TO TRY, 11 = %00001011 )
	IF
	    EXIT ( .S : OFFSET FLAG ) ( FLAG IS NON-ZERO )
	ELSE
	    0 MOUSE ( PRINT SMALL MOUSE POINTER )
	    139 SRAM ( UPDATE STATUS TO PREVENT MOVING DOWN; 139 = %10001011 )

	    T @ IF
		-1 YP
	    ELSE
		32 -
	    THEN
	    151 SRAM
  THEN
 ELSE
  T @
  IF
   -1 YP
  ELSE
   32 -
  THEN
  1 MOUSE 16 RAM
 THEN
 0
;

( TRY TO MOVE DOWN.                                             )
( FIRST, CHECK IF SQUARE BELOW HAS BEEN VISITED.                )
(    IF SO, THEN CHECK IF THERE ARE OTHER OPTIONS TO LEAVE CELL )
(       IF THERE ARE, THEN EXIT, SO CAN TRY THOSE OPTIONS       )
(    OTHERWISE, KNOW AT DEAD END, SO                            )
(       BACKTRACK DOWN BUT BLOCK OFF CELL ABOVE                 )
( OTHERWISE, NOT VISITED SO                                     ) 
(    MOVE DOWN NORMALLY                                         )
: DN ( OFFSET -- NEW_OFFSET FLAG )
    DUP
    DUP 607 > ( CHECK IF FINAL ROW OF CURRENT SEGMENT )
    DUP T ! ( STORE ANSWER IN T )

    IF ( FINAL ROW )
	640 - Z @ 672 * + ( WORK OUT OFFSET TO CORRESPONDING POSN IN SEGMENT BELOW )
    THEN
    
    32 + W @ + ( MOVE DOWN ONE ROW )
    C@ ( AND RETRIEVE STATUS FOR THAT CELL )

    16 AND IF ( HAS BEEN VISITED )
	DUP W @ + C@ ( RETRIEVE STATUS OF CURRENT LOCATION )
	7 AND ?DUP ( CHECK IF ANY OTHER DIRECTIONS TO TRY )
	IF ( OTHER DIRECTION TO TRY, THEN EXIT )
	    EXIT  ( WITH TOS NON-ZERO )
	ELSE
	    0 MOUSE ( REPRINT SMALL MOUSE, TO INDICATE BACKTRACK )
	    135 SRAM ( PREVENT MOVE UP , 135 = %10000111 )

	    T @ ( MOVE DOWN )
	    IF
		1 YP
	    ELSE
		32 +
	    THEN
	    
	    155 SRAM ( PREVENT MOVE UP , 155 = %10011011 )
	THEN
    ELSE ( MOVE DOWN )
	T @ IF ( NEED TO CHANGE SCREEN SEGMENT )
	    1 YP
	ELSE ( NORMAL MOVE )
	    32 +
	THEN
	
	1 MOUSE ( PRINT MOUSE )

	16 RAM ( SET CELL TO BE VISITED )
    THEN
    0 ( INDICATING HAS MOVED )
;

( TRY TO MOVE LEFT                                              )
( FIRST, CHECK IF SQUARE TO LEFT HAS BEEN VISITED.              )
(    IF SO, THEN CHECK IF THERE ARE OTHER OPTIONS TO LEAVE CELL )
(       IF THERE ARE, THEN EXIT, SO CAN TRY THOSE OPTIONS       )
(    OTHERWISE, KNOW AT DEAD END, SO                            )
(       BACKTRACK LEFT BUT BLOCK OFF RIGHT CELL                 )
( OTHERWISE, NOT VISITED SO                                     ) 
(    MOVE RIGHT NORMALLY                                        )
: LT ( OFFSET -- NEW_OFFSET FLAG )
    DUP
    DUP 31 AND ( ISOLATE COLUMN VALUE OF CURRENT LOCATION )
    0= ( CHECK IF COLUMN ZERO )
    DUP T ! ( STORE OUTCOME OF TEST )

    IF ( COLUMN ZERO )
	641 - ( SUBTRACT 20 ROWS PLUS ONE )
    THEN
    
    1- W @ + C@ ( MOVE LEFT AND RETRIEVE VALUE )
    
    16 AND IF ( CHECK IF VISITED )
	DUP
	W @ + C@
	13 AND ( CHECK IF OTHER DIRECTIONS TO TRY )

	?DUP IF ( OTHER DIRECTIONS TO TRY, THEN TRY THEM )
	    EXIT ( WITH TOS NON-ZERO )
	ELSE 
	    0 MOUSE ( REPRINT SMALL MOUSE, TO INDICATE BACKTRACK )
	    141 SRAM ( PREVENT MOVE RIGHT : 141 = %10001101 )
	    
	    ( MOVE LEFT )
	    T @ 
	    IF
		-1 XP
	    ELSE
		1-
	    THEN
	    
	    158 SRAM ( PREVENT MOVE LEFT : 158 = %10011110 )
	THEN
    ELSE ( MOVE DOWN NORMALLY )
	T @
	IF
	    -1 XP
	ELSE
	    1-
	THEN
	1 MOUSE 16 RAM
    THEN
    
    0 ( INDICATES MOVED )
;

( TRY TO MOVE RIGHT.                                            )
( FIRST, CHECK IF SQUARE TO RIGHT HAS BEEN VISITED.             )
(    IF SO, THEN CHECK IF THERE ARE OTHER OPTIONS TO LEAVE CELL )
(       IF THERE ARE, THEN EXIT, SO CAN TRY THOSE OPTIONS       )
(    OTHERWISE, KNOW AT DEAD END, SO                            )
(       BACKTRACK RIGHT BUT BLOCK OFF LEFT CELL                 )
( OTHERWISE, NOT VISITED SO                                     ) 
(    MOVE RIGHT NORMALLY                                        )
: RT ( OFFSET -- NEW_OFFSET FLAG )
    DUP DUP
    31 AND ( EXTRACT COLUMN INDEX )

    30 = ( CHECK IF COLUMN 30 )
    DUP T ! ( STORE ANSWER )

    ( .S : X X FLAG )
    IF ( IF COLUMN 30 ADD 
	641 + ( ADD 20 ROWS AND ONE EXTRA )
    THEN
    
    1+ ( MOVE RIGHT )

    ( .S : X NX )
    W @ + C@ ( RETRIEVE VALUE )

    16 AND ( CHECK IF VISITED ALREADY )

    IF ( VISITED )
	( .S : X )
	DUP
	W @ + C@ ( RETRIEVE STATUS FOR CURRENT LOCATION )
	14 AND ( CHECK IF CAN MOVE IN ANOTHER DIRECTION : 14 = 00001110 )

	?DUP ( IF SO, DUPLICATE )
	
	IF 
	    EXIT ( .S : X FLAG ) ( FLAG IS NON-ZERO )
	ELSE ( NO WHERE ELSE TO MOVE )
	    ( .S : X )
	    0 MOUSE ( UPDATE TO SMALL MOUSE POINTER )
	    
	    142 SRAM ( PREVENT MOVE LEFT ; 142 = % 10001110 )

	    ( MOVE RIGHT, CHECKING IF NEED TO MOVE SEGMENT )
	    T @ IF
		1 XP
	    ELSE
		1+
	    THEN
	    
	    157 SRAM ( PREVENT MOVE RIGHT : 157 = %10011101 )
	THEN
    ELSE ( IF NOT VISITED )
	T @ ( CHECK IF SCREEN SWAP )
	IF 
	    1 XP ( MOVE RIGHT TO NEXT SCREEN SEGMENT )
	ELSE
	    1+ ( MOVE RIGHT )
	THEN

	1 MOUSE ( PRINT MOUSE AT NEW LOCATION, PAUSING FIRST )
	16 RAM ( MARK LOCATION AS VISITED )
    THEN
    
    0 ( INDICATES MOVED )
;

( MAKE A MOVE IN AUTO MODE )
: CHOICE ( X -- X FLAG )
    DUP W @ + C@ ( RETRIEVE INFO ABOUT CURRENT LOCATION )
    Y ! ( SAVE TO Y )
    Y @

    1 AND IF ( CHECK IF CAN MOVE RIGHT )
	RT ( IF SO, TRY )

	0= IF ( IF SUCCESSFUL, DONE )
	    EXIT
	THEN
    THEN

    Y @
    2 AND IF ( CHECK IF CAN MOVE LEFT )
	LT

	0= IF ( IF SUCCESSFUL, DONE )
	    EXIT 
	THEN
    THEN

    Y @

    4 AND IF ( CHECK IF CAN MOVE UP )
	UP

	0= IF ( IF SUCCESSFUL, DONE )
	    EXIT
	THEN
    THEN

    Y @
    
    8 AND IF ( CHECK IF CAN MOVE DOWN )
	DN

	0= IF ( IF SUCCESSFUL, DONE )
	    EXIT
	THEN
    THEN

;

( AUTOMATICALLY SOLVE MAZE )
: AUTO ( -- )
    IX @ ( RETRIEVE STARTING POSITION )
    16 RAM ( MARK AS VISITED )

    ( .S : X )
    BEGIN
	W @ OVER + ( RETRIEVE PROPERTIES FOR CURRENT LOCATION )
	C@
	64 AND 0= ( CHECK IF BIT 6 IS SET, INDICATING EXIT ) 
    WHILE
	    ( IF NOT, MAKE NEXT MOVE )
	    CHOICE
    REPEAT
    
    DROP ( EMPTY STACK BEFORE RETURNING )
;

( WAIT FOR KEYPRES )
: WAIT ( --- KEY )
    1000 0 ( WAIT BRIEFLY, IN CASE OF PREVIOUS KEY PRESS? )
    DO
    LOOP
    
    BEGIN
	INKEY
	?DUP 
    UNTIL ( REPEAT UNLESS KEY IS PRESSED )
;

: UD
    X @ W @ +
    C@ AND
    IF
	X @ -4 SCR OVER
	1 = OVER 607 >
	AND 3 PICK -1 =
	3 PICK 32 < AND
	OR
	IF
	    SWAP YP
	ELSE
	    SWAP 32 * +
	THEN
	4 SCR X ! 1
    ELSE
	DROP 0
    THEN
;

: LR
    X @ W @ +
    C@ AND
    IF
	X @ -4 SCR OVER
	1 = OVER 31 AND
	30 = AND 3 PICK
	-1 = 3 PICK 31
	AND 0= AND OR
	IF
	    SWAP XP
	ELSE
	    +
	THEN
	4 SCR X ! 1
    ELSE
	DROP 0
    THEN
;

( MANUALLY TRY TO MOVE MOUSE BY ONE CELL )
: STEP ( -- )
    BEGIN
	WAIT ( RETRIEVE KEYPRESS )
	95 AND ( CAPITALISE )
	DUP 65 = IF ( 'A' = UP )
	    DROP
	    -1 4 UD
	ELSE
	    DUP 90 = IF ( 'Z' = DOWN )
		DROP
		1 8 UD
	    ELSE
		DUP 75 = IF ( 'K' = RIGHT )
		    DROP
		    1 1 LR
		ELSE
		    DUP 77 = IF ( 'M' = LEFT )
			DROP
			-1 2 LR
		    ELSE ( INVALID KEYPRESS )
			DROP 0
		    THEN
		THEN
	    THEN
	THEN
    UNTIL ( REPEAT, IF NO VALID KEYPRESS )
;

: MAN ( -- )
    BEGIN
	STEP

	( RETRIEVE CURRENT LOCATION AND CHECK IF EXIT )
	X @
	W @
	+
	C@
	64 AND ( EXIT INDICATED BY BIT 6 BEING SET )
    UNTIL
;

( REMOVE BREADCRUMB TRAIL FROM MAZE GRAPH )
( *** NEW WORK, NOT PART OF ORIGINAL PROGRAM *** )
: CLEARTRAIL ( --- )
    HERE 30 + ( FIND START OF MAZE GRAPH )
    Z @ DUP * 672 * ( WORK OUT SIZE OF GRAPH )
    0 DO
	DUP
	C@ ( RETRIEVE CURRENT VALUE )
	207 AND ( ZERO BITS 4 AND 5 )

	OVER C! ( STORE UPDATED VALUE )

	1+ ( MOVE TO NEXT ADDRESS )
    LOOP
    
    DROP ( CLEAR STACK )
;

: INSTRS ( --- )
    INVIS ( HIDE FORTH MONITOR CONFIRMATIONS )
    CLS

    3 8 AT ." A-MOUZ-IN-MASE " ( USE INVERSE VIDEO AND PAD WITH ONE SPACE )
    5 8 AT ." An experience in"
    7 9 AT ." MAZE-O-CHISM" ( USE INVERSE VIDEO AND PAD WITH ONE SPACE )
    10 0 AT ."  This program constructs a maze before your very eyes, no less. "
    CR
    ." You ca. solve it yourself, usingthe A, Z, K and M keys; or watcha very short-sighted, timorous, and elasticated mouse, riccochetfrom start to finish."
    ( KEYS ARE PRINTED INVERSE VIDEO, TYPOS ARE PRESERVED FROM ORIGINAL )

    22 23 AT ." <ANYKEY>"

    GR ( INITIALISE GRAPHICS )

    WAIT ( WAIT FOR KEY PRESS )
    DROP
;

( CALL TO RUN PROGRAM )
: RUN ( --- )
    INSTRS ( DISPLAY INSTRUCTIONS )
    CLS
    
    BEGIN
	16 0 AT ." ? Maze size"
	16 16 AT ." 1 Small" ( OPTION NUMBERS ARE PRINTED IN INVERSE VIDEO )
	17 16 AT ." 2 Medium"
	18 16 AT ." 3 Large"

	BEGIN
	    WAIT ( WAIT FOR KEY PRESS )
	    48 - ( SUBTRACT ASCII "1" )
	    DUP ( CHECK IS VALID SELECTION )
	    1 < OVER 3 > OR
	WHILE
		DROP ( TRY AGAIN IF NOT VALID SELECTION )
	REPEAT
	
	CLS 
	CLEAR ( SET UP SPACE FOR MAZE IN MEMORY )

	FAST ( SWITCH TO FAST MODE )
	DRAW ( CREATE MAZE )

	IU @ U ! ( SET CURRENT MAZE SECTION TO INITIAL SECTION )
	IV @ V !
	PSET ( UPDATE P AND W POINTERS FOR RIGHT SECTIN )

	PRINT ( PRINT CURRENT MAZE SECTION )

	IX @ ( RETRIEVE STARTING POSITION -- THAT IS, OFFSET )
	4 SCR ( PRINT MOUSE )
	X ! ( SAVE CURRENT OFFSET )
	
	CLEARTRAIL ( REMOVE BREADCRUMB TRAIL FROM MAZE GRAPH )

	SLOW ( RE-ENABLE KEYBOARD INTERACTIONS )

	22 10 AT ." Play or Watch?" ( *** WAS CORRUPTED *** )

	BEGIN
	    WAIT ( WAIT FOR KEYPRESS )
	    95 AND ( CAPITALISE )
	    DUP
	    80 = IF ( PLAY? )
		DROP
		22 10 AT 15 SPACES ( CLEAR MESSAGE )
		MAN ( PLAY GAME )
		1 ( INDICATES SUCCESS )
	    ELSE 
		DUP
		87 = IF ( WATCH? )
		    DROP
		    22 10 AT 15 SPACES

		    FAST
		    AUTO ( SOLVE MAZE AUTOMATICALLY )
		    SLOW
		    
		    1 ( SUCCESS )
		ELSE
		    DROP
		    0
		THEN
	    THEN
	UNTIL

	( WAIT FOR ~ 1 SECOND ??? SHOULD BE LONGER ??? )
	5000 0 DO
	LOOP

	CLS

	0 ( INFINITE LOOP, SO GO BACK FOR ANOTHER GO )
    UNTIL
;

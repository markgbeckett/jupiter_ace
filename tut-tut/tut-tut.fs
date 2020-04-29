( TUT-TUT FOR JUPITER ACE                       )
( ORIGINAL GAME BY DAVID STEPHENSON 2019        )
( PORTED TO JUPITER ACE BY GEORGE BECKETT 2020  )
(                                               )
(                                               )
( TO TYPE IN TO REAL ACE, START AT BOTTOM --    )
( THAT IS, LAST WORD IN LISTING -- AND WORK UP  )
(                                               )
( TO RUN, ENTER 'TUTTUT'                        )
(                                               )
( FILES:                                        )
(   TUT-TUT.FS -- THIS FORTH SOURCE             )
(   TUT-TUT_LEVELS.ASM -- LEVEL DATA            )
(   TUT-TUT_MESSAGES.ASM -- MESSAGE DATA        )
(   TUT-TUT_CHARSET.ASM -- CHAR BITMAPS         )
(   2DUP.ASM -- OPTIONAL M/CODE IMPL OF 2DUP    )
(   TUT-TUT.TAP -- PRE-COMPILED EMULATOR FILE   )
(                                               )
(                                               )
(                                               )
( SOURCE CODE MANUALLY TRANSCRIBED FROM ACE     )
( IN CASE OF PROBLEMS, CONTACT:                 )
( MARKGBECKETT@GMAIL.COM                        )

: TUTTUT
  SETUPUDG
  PRINTACKNOW ( ACKNOWLEDGEMENTS )
  0 HISCORE ! ( RESET HIGH SCORE )
  
  BEGIN ( GAME LOOP )
      RESETSCREEN

      NEWGAME
      PRINTKEYS
      PRINTSCORE
      PRINTSAIR
      
      SPLASHSCREEN

      INTROSND
      PRINTLEVEL

      BEGIN
          26 0 DO
              2 0 DO
	          CHECKCAUGHT
		  AMULET @ 0=
		  IF
  	            GETMOVE

	            IF
	              CHECKMOVE

                      IF
		          MOVEPL
                       THEN
                    ELSE
                      CHECKPAUSE CHECKRESET

	            THEN
		  THEN

		  BRACELET @ 0=
		  IF
	            I 3 + I DO
	              I MOVEMUMMY
	            2 +LOOP
		  ELSE
		    4 0 DO
		      HALT
		    LOOP
		  THEN
		  
		  RESETLEVEL @ ENDGAME @ OR

		  IF
		      LEAVE
		  THEN
              LOOP

	      RESETLEVEL @ ENGAME @ OR
	      IF
	        LEAVE
              THEN
	    LOOP

	    RESETLEVEL @
	    IF
	      0 RESETLEVEL !
	      DROP DROP
	      PRINTLEVEL
	    ELSE
	      0 AMULET !
	      0 BRACELET !
	      AIR @ 1- DUP
	      AIR !
	      DUP 0=
	      IF
		  1 ENDGAME !
	      THEN
	      DUP 3 <
	      IF
	        CLEARMESSAGE
		19 9 AT	." MUST GET OUT!"
		DROP
	      ELSE 6 < 
	        IF
		  CLEARMESSAGE
		  19 8 AT ." HARD TO BREATHE"
	        THEN
              THEN
	      PRINTAIR
            THEN
	    ENDGAME @
	  UNTIL

      ( UPDATE HIGH SCORE )
      HISCORE @ SCORE @ MAX
      HISCORE !

      0 ( INFINITE LOOP )
  UNTIL
;

: TEST ( LVL -- )
  LEVEL !
  RESETSCREEN
  RESETKEYS

  0 ENDGAME !
  0 SCORE !
  21 AIR !

  PRINTLEVEL

  BEGIN
    26 0 DO
      2 0 DO
        CHECKCAUGHT
        AMULET @ 0=
	IF
  	  GETMOVE
          IF
            CHECKMOVE
            IF
              MOVEPL
            THEN
          ELSE
	    CHECKPAUSE CHECKRESET
          THEN
        THEN

	BRACELET @ 0=
	IF
	  I 3 + I DO
	  I MOVEMUMMY
	  2 +LOOP
	ELSE
	  4 0 DO
	    HALT
	  LOOP
	THEN
		  
	RESETLEVEL @ ENDGAME @ OR

	IF
	  LEAVE
	THEN
      LOOP

      RESETLEVEL @ ENGAME @ OR
      IF
        LEAVE
      THEN
    LOOP

    RESETLEVEL @
    IF
      0 RESETLEVEL !
      DROP DROP
      PRINTLEVEL
    ELSE
      0 AMULET !
      0 BRACELET !
      AIR @ 1- DUP
      AIR !
      0=
      IF
        1 ENDGAME !
      THEN
      DUP 3 <
      IF
        CLEARMESSAGE
	19 9 AT ." MUST GET OUT!"
	DROP
      ELSE
        6 < IF
	  CLEARMESSAGE
	  19 8 AT ." HARD TO BREATHE"
	THEN
      THEN

      PRINTAIR
    THEN
    ENDGAME @
  UNTIL
  DROP DROP ( BALANCE STACK )
;


: PRINTACKNOW
  CLS

  2 4 AT ." ZX81KEYBOARDADVENTURE.COM"
  4 7 AT ." PRESENTS A GAME BY"
  6 8 AT ." DAVID STEPHENSON"
  10 12 AT ." TUT-TUT"
  13 8 AT ." COPYRIGHT MMXIX"
  15 3 AT ." SPECIAL THANKS TO ROD BELL"
  17 3 AT ." PORTED TO THE JUPITER ACE"
  19 5 AT ." BY GEORGE BECKETT 2020"

  300 0 DO
   HALT
  LOOP
;

: GETMOVE ( X Y -- X Y NX NY 1 / X Y 0 )
    INKEY DUP
    IF
      >R 2DUP R> DUP

      112 = ( 'p' - RIGHT )
      IF
        SWAP 1+ SWAP EXIT
      THEN

      DUP 111 = ( 'o' - LEFT )
      IF
        SWAP 1- SWAP EXIT
      THEN

      DUP 113 = ( 'q' - UP )
      IF
        ROT 1- ROT ROT EXIT
      THEN

      97 = ( 'a' - DOWN )
      IF
        SWAP 1+ SWAP 1 EXIT
      THEN

      DROP DROP      
      0 ( INDICATES KEY PRESSED )
  THEN
;

: CHECKMOVE ( X Y NX NY -- X Y NX NY 1 / X Y 0 )
  2DUP SCREEN DUP

  CHECKWALL

  IF
    DROP DROP DROP
    0 EXIT
  THEN

  DUP
  CHECKGEM

  IF
    DROP
    1 EXIT
  THEN

  DUP 
  CHECKKEYS

  IF
    DROP
    1 EXIT
  THEN

  DUP
  CHECKEXIT

  DUP -1 = IF
    DROP DROP DROP DROP
    0 EXIT
  THEN
    
  IF
    DROP
    1
    EXIT
  THEN

  DUP CHECKBRACELET
  IF
    DROP
    1
    EXIT
  THEN

  DUP CHECKAMULET
  IF
    DROP
    1
    EXIT
  THEN
  
  CHECKLOCK

  EXIT
;

: CHECKWALL ( CHAR -- FLAG )
  DUP DUP 0 > SWAP 5 < AND SWAP 14 = OR ( WALL OR BORDER )
;

: CHECKBRACELET ( CHAR -- FLAG )
  5 =
  IF
    BRACELETSND
    SCORE @ 75 + SCORE !
    1 BRACELET !
    PRINTSCORE
    1
  ELSE
    0
  THEN
;

: CHECKAMULET ( CHAR -- FLAG )
  6 =
  IF
    AMULETSND
    SCORE @ 100 + SCORE !
    1 AMULET !
    PRINTSCORE
    1
  ELSE
    0
  THEN
;

: CHECKGEM ( CHAR --  FLAG )
  7 =
  IF
    PICKUPSND
    SCORE @ 25 + SCORE !
    PRINTSCORE
    1
  ELSE
    0
  THEN
;

: RESETKEYS ( -- )
  4 0 DO
    0 KEYS I + C!
  LOOP
;

: PRINTKEYS ( -- ) 
  ROFFSET 18 + COFFSET 4 + AT
  4 0 DO
    KEYS I + C@ 128 * 49 + I + EMIT
  LOOP
;

: CHECKKEYS ( CHAR -- FLAG )
  DUP DUP
  48 > SWAP 53 < AND
  IF
    PICKUPSND
    49 - KEYS + 1 SWAP C!
    PRINTKEYS
    SCORE @ 10 + SCORE !
    PRINTSCORE
    1
  ELSE
    DROP 0
  THEN
;
  
: CHECKEXIT ( CHAR -- FLAG ) 
  180 =
  IF
    KEYS 3 + C@ 0= IF
      -1 EXIT
    THEN
    
    LEVEL @ 1+

    DUP MAXLEVEL = IF
      SCORE @ TSCORE <
      IF
        CLEARLEVEL CLEARSPLASH
        8 7 AT ." YOU NEED AT LEAST"
        10 9 AT TSCORE . ." POINTS TO"
        12 8 AT ." ENTER FINAL TOMB"
	CLEARMESSAGE
	19 4 AT ." UNWORTH OF TUT'S RICHES"

        200 0 DO
	  HALT
	LOOP

        CLEARMESSAGE
	DROP
	2 ( RETURN TO LEVEL 3 )
      ELSE
        CLEARMESSAGE
	19 4 AT ." TUT'S TREASURY UNLOCKED"
	200 0 DO
	  HALT
	LOOP
	CLEARMESSAGE
      THEN
    THEN

    DUP MAXLEVEL >
    IF 
      DROP 2 ( RETURN TO LEVEL 2 )
    THEN 

    INTROSND
    LEVEL !
    1 RESETLEVEL !
    SCORE @ AIR @ 5 * + SCORE !
    RESETAIR 1
  ELSE
    0
  THEN
;

: CHECKLOCK ( X Y NX NY CHAR -- X Y NX NY FLAG )
  ( CHECK IF A LOCK )
  DUP DUP 176 > SWAP 180 < AND 0=
  IF ( EXIT IF NOT )
    DROP 1
    EXIT
  THEN

  ( CHECK HAVE RIGHT KEY )
  DUP 177 - KEYS +
  C@ 0=
  IF ( EXIT IF NOT )
    DROP DROP DROP
    2DUP 1
    EXIT
  THEN

  ( CHECK IF LOCK CAN BE MOVE )
  >R 2DUP ( X Y NX NY NX NY R:CHAR )
  2 * 5 PICK -
  SWAP ( X Y NX NY RY NX ) 
  2 * 6 PICK -
  SWAP ( X Y NX NY RX RY )

  2DUP SCREEN
  32 = IF ( SPACE, SO CAN BE )
    LOCKSND
    AT R> EMIT
    1 EXIT
  ELSE ( OTHERWISE NOT )
    DROP DROP DROP DROP R> DROP
    2DUP 1 EXIT
  THEN
;


: MOVEPL ( X Y NX NY -- NX NY)
  4 ROLL 4 ROLL ( BRING OLD POSN TO TOP )
  AT 32 EMIT
  2DUP
  PRINTPL
;


: CHECKCAUGHT ( X Y -- X Y )
  4 0 DO ( CHECK EACH MUMMY IN TURN )
    2DUP
    MUMMIES I 4 * +
    DUP C@
    SWAP 1+ C@

    MATCHCOORD IF
      1 CAUGHT !
      LEAVE
    THEN
  LOOP

  CAUGHT @ IF
    0 CAUGHT !
    PRINTDIED
    DIESND
    SCORE @ 25 - 0 MAX
    SCORE !
    PRINTSCORE
    PRINTMUMMY
    RESETPLPOSN
    2DUP PRINTPL
  THEN
;


: PRINTLEVEL ( -- )
  CLEARLEVEL
  LEVEL @ DRAWLEVEL
  PRINTAIR
  PRINTSCORE
  RESETKEYS PRINTKEYS
  RESETMUMMIES PRINTMUMMIES
  RESETPLPOSN 2DUP PRINTPL
;

: DRAWLEVEL ( LEVEL -- )
  19 6 AT 20 SPACES
  >R I ( SAVE LEVEL FOR LATER )
  28 * GAMELEVELS  + @ ( REL_ADDR )
  GAMELEVELS + ( ADDR )
  ROFFSET COFFSET 2DUP AT >R >R
  DUP C@ ( ADDR CODE )

  BEGIN
    DUP 255 < ( 255 SIGNALS END OF LEVEL DATA )
  WHILE
    16 /MOD ( ADDR COUNT CHAR )

    DUP 0= IF ( REPLACE BLANK )
      DROP 32
    THEN
    
    ( CHECK FOR DOOR )
    DUP DUP 4 > SWAP 9 < AND IF
      172 +
    THEN
      
    ( CHECK FOR KEY )
    DUP DUP 8 > SWAP 13 < AND IF
      40 +
    THEN

    ( CHECK FOR BRACELET, AMULET OR GEM )
    DUP DUP 12 > SWAP 16 < AND IF
      8 -
    THEN

    SWAP ( ADDR CHAR COUNT )

    1+ 0 DO 
      DUP EMIT
	
      R> R> R> R>
      1+ ( ADDR CHAR R C+1 )

      ( CHECK FOR LINE WRAP )
      DUP COFFSET 24 + = IF
	  DROP COFFSET
	  SWAP 1+ SWAP
	  2DUP AT ( ADDR CHAR R+1 C )
	THEN

        >R >R >R >R ( ADDR CHAR )
      LOOP

      DROP 1+
      DUP C@ ( ADDR CHAR )
   REPEAT

    DROP DROP
    R> R>
    DROP DROP

    ( PRINT LEVEL NAME )
    ROFFSET 16 + COFFSET 4 + AT
    R> 28 * GAMELEVELS + 12 +
    DUP 16 + SWAP DO
      I C@ EMIT
    LOOP
;
        
: CHECKRESET ( -- )
  INKEY 114 = IF
    DIESND
    CLEARSPLASH
    ROFFSET 6 + COFFSET 6 + AT
    ." RESET LEVEL"
    ROFFSET 8 + COFFSET 7 + AT
    ." YES OR NO" ( USE INV MODE FOR 'Y' AND 'N' )
    GETKEY
    ASCII Y = IF 
      1 RESETLEVEL ! SCORE @ 2 / SCORE !
    ELSE
      1 ENDGAME !
    THEN
  THEN
;


: RESETSCREEN ( -- ) 
  CLS

  DRAWBORDER

  0 12 AT ." TUT-TUT"
  ROFFSET 18 + COFFSET 1- AT ." KEYS:"
  ROFFSET 18 + COFFSET 13 + AT ." SCORE:"
  ROFFSET 19 + COFFSET 1- AT ." AIR:"

  CLEARLEVEL
;

: DRAWBORDER ( -- )
  ROFFSET 1- COFFSET 1- AT
  203 EMIT

  25 1 DO
    14 EMIT
  LOOP

  212 EMIT

  ROFFSET 15 + ROFFSET DO
    I COFFSET 1- AT 14 EMIT
    I COFFSET 24 + AT 14 EMIT
  LOOP

  ROFFSET 15 + COFFSET 1- AT
  212 EMIT

  25 1 DO
    14 EMIT
  LOOP

  203 EMIT
;

: CLEARLEVEL ( -- )
  ROFFSET 15 + ROFFSET
  DO
    I COFFSET AT
    24 0 DO
      1 EMIT
    LOOP
  LOOP
;

: CLEARMESSAGE ( -- )
  16 ROFFSET + COFFSET AT
  24 SPACES
;
  
: SPLASHSCREEN ( -- )
  0 KEYPRESS !
  16 0 DO
    CLEARMESSAGE
    CLEARSPLASH
    I 4 MOD PRINTSPLASH

    200 0 DO
      INKEY

      IF 
        1 KEYPRESS !
        LEAVE
      THEN

      HALT
    LOOP

    KEYPRESS @

    IF
      LEAVE
    THEN
  LOOP

  ( WAIT FOR NO KEY PRESS, TO AVOID SPACE READ AS BREAK IN BEEP )
  BEGIN
    INKEY 0=
  UNTIL
;

: CLEARSPLASH ( -- )
  ROFFSET 13 + COFFSET 1+
  DO
    I COFFSET 2 + AT
    20 SPACES
  LOOP
;

: PRINTSPLASH ( N -- )
  DUP >R 2 * MESSAGES + @ ( CALC OFFSET TO RIGHT MESSAGE )
  MESSAGES +

  BEGIN
    DUP C@ ROFFSET + ( LINE STARTS WITH COORD )
    SWAP 1+ DUP C@ COFFSET +
    ROT SWAP AT
    1+

    BEGIN
      DUP 1+ SWAP C@
      DUP 13 -  ( 13 MEANS END OF LINE )
    WHILE
      EMIT
    REPEAT
 
    DROP DUP C@ 12 = ( 12 MEANS END OF MESSAGE )
  UNTIL

  DROP R> 0= ( SCREEN 0 IS SPECIAL, AS INCLUDES HIGH SCORE )
  IF
    11 ROFFSET + 15 COFFSET + AT
    HISCORE @ 0
    <# # # # # # # #> TYPE
  THEN
;


: NEWGAME ( -- )
  RESETKEYS
  0 ENDGAME !
  0 SCORE !
  21 AIR !
  0 LEVEL !
;

: RESETPLPOSN ( -- X Y )
  GAMELEVELS LEVEL @ 28 * + 2 +
  DUP C@ ROFFSET +
  SWAP 1+
  C@ COFFSET +
;

: PRINTPL ( X Y -- ) 
  2DUP AT + 2 MOD 10 + EMIT
;

: RESETMUMMIES ( -- )
  GAMELEVELS LEVEL @ 28 * + 4 +
  4 0 DO
    DUP DUP C@ ROFFSET + ( ADDR ADDR ADDR XCOORD )
    SWAP 1+ C@ COFFSET + SWAP ( ADDR YCOORD XCOORD )
    MUMMIES I 4 * +
    >R I C!
    I 1+ C!
    0 I 2+ C!
    1 R> 3 + C!
    2+
  LOOP

  DROP
;
    
: RESETAIR ( -- ) 
  21 AIR !
;
  
: MATCHCOORD ( X1 Y1 X2 Y2 -- FLAG )
  >R ROT = SWAP R> = AND
;

GETMUMMY ( N -- X Y DX DY )
  4 * MUMMIES +
  DUP C@ 
  SWAP 1+ DUP C@
  SWAP 1+ DUP C@
  SWAP 1+ C@
;

: APPLYDIR ( X Y DX DY -- X Y NX NY )
  DUP 255 = ( UINT FOR -1 )
  IF
    DROP -1
  THEN
  3 PICK +
  >R
  DUP 255 =
  IF
    DROP -1
  THEN
  3 PICK +
  R>
;


: FINDDIR ( PX PY X Y -- PX PY X Y 32(PX-X)+(PY-Y) )
  2DUP 5 PICK - 
  >R
  5 PICK - 32 * 
  R>
  + NEGATE
;

: TRYDIR (  X Y DX DY -- DX DY FLAG )
  2DUP 5 PICK +
  SWAP
  6 PICK +
  SWAP
  SCREEN
  DUP DUP 32 = SWAP 10 = OR SWAP 11 = OR IF
    >R >R DROP DROP R> R> 1
  ELSE
    DROP DROP DROP DROP 0 0 0
  THEN
;

: MSTOREDIR ( DX DY I -- )
  >R SWAP R>
  4 * MUMMIES + 2+
  DUP >R C!
  R> 1+ C!
;


: MOVEMUMMY ( N -- )
  >R ( SAVE MUMMY REF )
  I GETMUMMY

  6 PICK 6 PICK 6 PICK 6 PICK 
  MATCHCOORD ( CHECK IF MUMMY ON PLAYER SQUARE )

  IF (DO NOTHING, IF SO )
    DROP DROP DROP DROP R>
    DROP EXIT
  THEN

  APPLYDIR ( WORK OUT MUMMY MOVE )
  2DUP SCREEN ( AND SEE WHAT IS THERE )

  DUP DUP 32 = SWAP 10 = OR SWAP 11 = OR IF
    ( OKAY TO MOVE )
    2DUP SWAP
    MUMMIES I 4 * +
    DUP >R C!
    R> 1+ C!
    PRINTMUMMY
    AT 32 EMIT
    R> DROP EXIT
  THEN

  DROP DROP ( NEED TO CHANGE DIRECTION )
            ( CHECK WHERE PLAYER IS )
  FINDDIR ( PX PY X Y PX-X PY-Y )

  DUP 16 > ( DOWN )
  IF
    3 PICK 3 PICK
    1 0 TRYDIR
    IF
      I MSTOREDIR
      DROP DROP DROP R> DROP
      EXIT
    ELSE
      DROP DROP
    THEN
  THEN
  
  DUP 0> ( RIGHT )
  IF
    3 PICK 3 PICK
    0 1 TRYDIR
    IF
      I MSTOREDIR
      DROP DROP DROP R> DROP
      EXIT
    ELSE
      DROP DROP
    THEN
  THEN

  DUP -16 < ( UP )
  IF
    3 PICK 3 PICK
    -1 0 TRYDIR
    IF
      I MSTOREDIR
      DROP DROP DROP R> DROP
      EXIT
    ELSE
      DROP DROP
    THEN
  THEN

  DUP 0< ( LEFT )
  IF
    3 PICK 3 PICK
    0 -1 TRYDIR
    IF
      I MSTOREDIR
      DROP DROP DROP
      R> DROP
      EXIT
    ELSE
      DROP DROP
    THEN
  THEN

  I MUMMYBACK
  DROP DROP DROP
  R> DROP
;
 
: MUMMYBACK ( I -- )
  4 * MUMMIES + 2 +
  DUP C@ DUP 255 = ( UINT VER OF -1 )
  IF
    DROP DUP 1 SWAP C!
    1+ 0 SWAP C!
    EXIT
  THEN
  
  1 =
  IF
    DUP 0 SWAP C!
    1+ 1 SWAP C!
    EXIT
  THEN

  DUP 1+ C@ 1 =
  IF
    DUP 0 SWAP C!
    1+ -1 SWAP C!
    EXIT
  THEN

  DUP -1 SWAP C!
  1+ 0 SWAP C!
;

: PRINTMUMMIES ( -- ) 
  4 0 DO
    MUMMIES I 4 * +
    DUP C@ SWAP 1+ C@
    PRINTMUMMY
  LOOP
;

: PRINTMUMMY ( X Y -- ) 
  2DUP AT + 2 MOD 8 + EMIT
;

: PRINTSCORE ( -- ) 
  ROFFSET 18 + COFFSET 19 + AT
  SCORE @ 0 ( MAKE LONG INT )
  <# # # # # # #> TYPE
;

: PRINTAIR ( -- ) 
  ROFFSET 19 + COFFSET 4 + AT
  AIR @ 0 DO
    12 EMIT
  LOOP

  ROFFSET 19 + COFFSET 4 + AIR @ + AT
  21 AIR @ - 0 DO
    32 EMIT
  LOOP
;

: PRINTDIED ( -- )
  20 0 DO
    2 0 DO
      2DUP AT
      128 I * 10 +
      EMIT
      HALT HALT
    LOOP
  LOOP
;

: INTROSND ( -- )
  268 250 BEEP
  150 125 BEEP
  179 125 BEEP
  179 250 BEEP
  268 250 BEEP
  179 250 BEEP
  DIEDSND
;

: DIEDSND ( -- )
  268 250 BEEP
  201 125 BEEP
  201 125 BEEP
  150 250 BEEP
  268 125 BEEP
  268 125 BEEP
;

: BRACELETSND ( -- )
  213 4 BEEP
  451 8 BEEP
;

: AMULETSND ( -- )
  301 8 BEEP
  358 4 BEEP
;

: PICKUPSND ( -- )
  213 4 BEEP
;

: SCREEN ( X Y -- CHAR ) 
  SWAP 32 * + ( 32 CHARS PER ROW )
  9216 + ( START OF SCREEN MEMORY )
  C@
;

: MATCHCOORD ( X1 Y1 X2 Y2 -- FLAG )
  >R ROT = SWAP R> = AND 
;


( NOT USED SINCE VER 0.83 )
: UNPACKCOORD ( Z -- X Y )
  DUP 32 / OFFSET +
  SWAP
  32 MOD OFFSET + 1+
;

( NOT USED SINCE VER 0.83 )
: PACKCOORD ( X Y -- Z )
  OFFSET 1+ -
  SWAP OFFSET -
  32 *
  +
;

: GETKEY ( -- KEY )
  ( WAIT FOR NO KEY FIRST )
  BEGIN
    INKEY 0=
  UNTIL

 ( WAIT FOR KEY )
  BEGIN
    INKEY
    ?DUP
  UNTIL
;

 ( MCODE ALTERNATIVE ALSO AVAIL. SEE 2DUP.ASM )
: 2DUP ( X Y -- X Y X Y )
  OVER OVER ;

: .T ( PRINT STACK ON ROW 0 )
  0 0 AT 32 SPACES ( CLEAR ANY PREVIOUS TEXT )
  0 0 AT .S
;

: .S ( -- ) ( PRINT STACK, FROM ACE MANUAL P. 143 ) 
  15419 @ HERE 12 +
  OVER OVER -
  IF
    DO
      I @ . 2
    +LOOP
  ELSE
    DROP DROP
  THEN
;

: RESETCS ( -- )
  7776 ( START OF CAPITAL LETTERS IN ROM )
  11784 ( DESTINATION IN CHARACTER RAM )
  26 0 DO ( RESTORE LETTERS A--Z )
    DUP 0 SWAP C! 1+ ( CLEAR FIRST ROW )

    6 0 DO ( THEN FILL IN SIX MIDDLE ROWS )
      R> ( SAVE DESTINATION )
      DUP C@ ( RETRIEVE NEXT ROW )
      I C! ( COPY TO DESTINATION )
      1+ R> 1+  ( INCREMENT SOURCE AND DESTINATION )
    LOOP

    DUP 0 SWAP C! 1+ ( CLEAR BOTTOM ROW )
  LOOP

  DROP DROP ( BALANCE STACK )
;

: SETUPUDG ( -- ) ( POPULATE UDGS AND EGYPTIAN CHARS )
  CHARSET
  BEGIN
    DUP 1+ SWAP C@
    DUP 13 - ( 13 INDICATES END OF SET )
  WHILE
    8 * 11264 +

    8 0 DO
      >R
      DUP C@
      I C!
      1+ R> 1+
    LOOP
    
    DROP
  REPEAT

  DROP DROP
;

( TAKEN FROM ACE MANUAL P. 147 )
CODE HALT 118 C, 253 C, 233 C, ( PAUSE 1/50TH SEC ) 

( TAKEN FROM ACE MANUAL P. 147 )
DEFINER CODE
DOES>
  CALL
;

CREATE CHARSET 297 ALLOT ( SPACE FOR 33 UDGS )
CREATE KEYS 4 ALLOT
CREATE MUMMIES 16 ALLOT 
CREATE GAMELEVELS 4386 * ALLOT ( BASED ON ASSEMBLED SIZE OF TUT-TUT_LEVELS.ASM )
CREATE MESSAGES 585 ALLOT ( BASED ON ASSEMBLED SIZE OF TUT-TUT_MESSAGES.ASM )

0 VARIABLE AIR
0 VARIABLE HISCORE
0 VARIABLE SCORE
0 VARIABLE LEVEL
0 VARIABLE BRACELET
0 VARIABLE AMULET
0 VARIABLE CAUGHT
0 VARIABLE RESETLEVEL
0 VARIABLE ENDGAME
0 VARIABLE KEYPRESS

4 CONSTANT COFFSET ( COL OFFSET FOR GAME BOARD )
3 CONSTANT ROFFSET ( ROW OFFSET FOR GAME BOARD )
5000 CONSTANT TSCORE ( MIN SCORE TO PROCEED TO FINAL LEVEL )
28 CONSTANT MAXLEVEL ( COUNTING FROM ZERO )
123 VERSION ( VERSION * 100 )

DECIMAL 16 BASE C! ( SWITCH TO HEX )

CREATE DATA 0EC9 ALLOT

:  CENTIPEDE ( -- )
    ( CALL MAIN GAME LOOP, WHICH IS M/CODE )
    ( 3C60 CALL )
    CODE 4+ CALL
;

: TITLE1 ( FIRST TITLE SCREEN )
    CLS
    ."
    "
    15 0 AT ." P R E S E N T S                " 
;

: TITLE2 ( SECOND TITLE SCREEN )
    CLS
;

:  TITLE3 ( THIRD TITLE SCREEN )
    CLS
;

: L@ ( IDX - DURATION )
    1- LNGTH + C@ ( RETRIEVE DURATION OF NEXT NOTE )
;

: N@ ( IDX - NOTE )
    1- DUP + ( IDX = 2*<IDX-1> )
    NTS + @ ( RETRIEVE TONE VALUE )
;

CREATE LNGTH 
01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 02 C, 01 C,
01 C, 02 C, 01 C, 01 C, 02 C, 01 C, 01 C, 01 C,
01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C,
01 C, 03 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C,
02 C, 01 C, 01 C, 02 C, 01 C, 01 C, 02 C, 01 C,
01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C,
01 C, 01 C, 01 C, 03 C, 01 C, 01 C, 01 C, 01 C,
01 C, 01 C, 02 C, 01 C, 01 C, 02 C, 01 C, 01 C,
02 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C,
01 C, 01 C, 01 C, 01 C, 01 C, 03 C, 01 C, 01 C,
01 C, 01 C, 01 C, 01 C, 02 C, 01 C, 01 C, 02 C,
01 C, 01 C, 02 C, 01 C, 01 C, 01 C, 01 C, 01 C,
01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 01 C, 03 C,

CREATE NTS
00FD , 00E1 , 00D5 , 00BE , 00A9 , 00D5 , 00A9 , 00B3 ,
00E1 , 00B3 , 00BE , 00EF , 00BE , 00FD , 00E1 , 00D5 ,
00BE , 00A9 , 00D5 , 00A9 , 007F , 008E , 00A9 , 00D5 ,
00A9 , 008E , 00FD , 00E1 , 00D5 , 00BE , 00A9 , 00D5 ,
00A9 , 00B3 , 00E1 , 00B3 , 00BE , 00EF , 00BE , 00FD ,
00E1 , 00D5 , 00BE , 00A9 , 00D5 , 00A9 , 007F , 008E ,
00A9 , 00D5 , 00A9 , 008E , 0152 , 012D , 011C , 00FD ,
00E1 , 011C , 00E1 , 00EF , 012D , 00EF , 00FD , 013F ,
00FD , 0152 , 012D , 011C , 00FD , 00E1 , 011C , 00E1 ,
00A9 , 00BE , 00E1 , 011C , 00E1 , 00BE , 0152 , 012D ,
011C , 00FD , 00E1 , 011C , 00E1 , 00EF , 012D , 00EF ,
00FD , 013F , 00FD , 0152 , 012D , 011C , 00FD , 00E1 ,
011C , 00E1 , 00A9 , 00BE , 00E1 , 011C , 00E1 , 00BE ,

0 VARIABLE ?JOYSTICK

: INTRO
    ( CHECK IF JOYSTICK COULD BE PRESENT )
    400 0 DO
	1 IN 0= IF
	    DROP 1
	THEN
    LOOP
    
    ?JOYSTICK C!

    ( DISPLAY OPENING TITLES - THREE SCREENS )
    BEGIN
	0 PSN !	TITLE1

	1A 0 DO
	    INTR
	LOOP

	TITLE2
	1A 0 DO
	    INTR
	LOOP

	TITLE3
	34 0 DO
	    INTR
	    INKEY D = IF
		2 ?JOYSTICK C!
		LEAVE
	    THEN

	    ?JOYSTICK C@ IF
		1 IN 20 = IF
		    2 ?JOYSTICK C!
		    LEAVE
		THEN
	    THEN
	LOOP

	?JOYSTICK 2 =
    UNTIL

    190 1F4 BEEP
;

0000 VARIABLE PSN

: INTR ( PLAY NEXT NOTE IN INTRO SEQUENCE )
    ( RETRIEVE NOTE INDEX AND INCREMENT )
    PSN @
    1+ DUP
    DUP PSN !

    ( .S : PSN PSN )
    N@ SWAP L@
    AF * BEEP

    ( CHECK AND, IF NECESSARY, RESET INDEX )
    PSN @ 68 = IF
	0 PSN !
    THEN
;

: GO
    INTRO
    
    BEGIN
	INS ( INSTRUCTIONS )
	CENTIPEDE ( MAIN GAME )

	( END OF GAME, PAUSE BEFORE RESTARTING )
	15 0 AT ." P R E S S  E N T E R          " ( 32 CHARS )

	BEGIN
	    INKEY 0D = ( CHECK FOR ENTER )
	UNTIL

    0 UNTIL ( LOOP INDEFINITELY )
;

: INS
    CLS

    ( INSTRUCTIONS FORMATTED INTO LINES, ORIGINAL HAS ONE STRING )
    ."        C E N T I P E D E"
    ."        _________________"
    ."  Use 'J' and 'L' for left and"
    ." right, 'I' and 'M' for up and"
    ." down and 'A' to fire to shoot"
    ." the centipede."

    15 0 AT
    ."  P R E S S  E N T E R          "

    C8 1F4 BEEP

    BEGIN
	INKEY 0D =
    UNTIL
;

:  SAVE GO ;

:  VLIST  GO ;

:  EDIT GO ;

:  FORGET GO ;

:  REDEFINE GO ;

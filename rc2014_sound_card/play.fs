216 CONSTANT REG
208 CONSTANT DAT

CREATE SNDNOTES ( C, C#, D, D#, E, F, F#, G, G#, A, A#, B )
438 , 404 , 381 , 360 , 339 , 320 , 302 , 285 , 269 , 254 , 240 , 226

DEFINER CODE DOES> CALL ;

CODE HALT 118 C, 253 C, 233 C,
    
: PAUSE ( N -- )
    0
    DO
	HALT
    LOOP
;

: GETNOTE
    ( N -- NOTE )
    2 * SNDNOTES +
    @
;
: SNDSETUP ( VAL -- )
    7 REG OUT
    DAT OUT
;

: SETVOL ( VOL CHANNEL -- )
    7 + REG OUT
    DAT OUT
;

: SNDMUTE ( CHAN -- )
    0 SWAP
    SETVOL
;

: SNDMUTEALL
    4 1 DO
	I SNDMUTE
    LOOP
;

: PLAYNOTE ( NOTE CHANNEL -- )
    1- 2 *
    DUP REG OUT
    OVER
    256 MOD DAT OUT
    1+ REG OUT
    256 / DAT OUT
;

: TEST
    -1 11 9 8 6 3 2 0
    BEGIN
	DUP 1+
    WHILE
	    GETNOTE
	    1 PLAYNOTE
	    20 PAUSE
    REPEAT
;

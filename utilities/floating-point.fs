: PI 3.14159 ;

: DR PI 180 F/ ;

: RD 1 DR F/ ;

: 2DROP ( FP -- )
    DROP DROP
;

: 2DUP ( FP -- FP FP )
    OVER OVER
;

: 2SWAP ( FP1 FP2 -- FP2 FP1 )
    4 ROLL 4 ROLL
;

: 2OVER ( FP1 FP2 -- FP1 FP2 FP1 )
    4 PICK 4 PICK
;

: 2ROT ( FP1 FP2 FP3 -- FP2 FP3 FP1 )
    6 ROLL 6 ROLL
;

: 2@ ( ADDR -- FP )
    DUP @ SWAP 2+ @
;

: 2! ( FP ADDR -- )
    ROT OVER ! 2+ !
;

: 2ROLL ( FPN ... FP1 N -- FPN-1 ... FP1 FPN )
    2 * DUP 1+
    ROLL SWAP ROLL
;

: SQRT ( FP -- FP )
    1.0 10 0 DO
	2OVER 2OVER F/ F+
	0.5 F*
    LOOP

    2SWAP 2DROP
;

: SIN ( FP -- FP )
    2DUP 2DUP 2DUP F* FNEGATE
    2ROT 2ROT
    27 2 DO
	6 PICK 6 PICK
	F* I I 1+ *
	UFLOAT F/
	2DUP 2ROT F+ 2SWAP
	2
    +LOOP

    2DROP 2SWAP 2DROP
;

: COS ( FP -- FP )
    1.57080
    2SWAP F-
    SIN
;

: TAN ( FP -- FP )
    2DUP SIN
    2SWAP COS
    F/
;

: ATN ( FP -- FP )
    ( COMPUTE ARCTAN OF -1 < FP < 1 RADIANS. CONVERGES SLOWLY )
    2DUP 2DUP 2DUP F* FNEGATE ( X X -X^2 )
    2ROT 2ROT ( -X^2 X X )

    101 3 DO
	6 PICK 6 PICK F*
	I UFLOAT F/

	( MULTIPLIER SUM NEXT_TERM )
	2DUP 2ROT F+ 2SWAP
    2 +LOOP

    2DROP ( MULTIPLIER SUM )
    2SWAP
    2DROP ( SUM )
;

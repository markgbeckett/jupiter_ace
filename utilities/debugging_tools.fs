( PRINT CONTENTS OF DATA STACK )
( REPRODUCED FROM JUPITER ACE MANUAL, P. 143 )
: .S
    15419 @ HERE 12 + ( TOP, BOTTOM )
    OVER OVER -
    IF ( STACK IS NOT EMPTY )
	DO
	    I @ .
	2 +LOOP
    ELSE
	DROP DROP
    THEN
;

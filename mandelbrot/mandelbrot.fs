DECIMAL

: MANDEL  ( -- )
    ( INTEGER-BASED MANDELBROT SET )
    8192 -8192 DO ( C_IM )
	3850 -16384 DO ( C_RE )
	    J 0 0 1 ( -- C_IM Z_RE Z_IM FLAG )
	    50 0 DO ( MAX 50 ITERS )
		>R ( SAVE FLAG )
		OVER DUP 8192 */ ( Z_RE^2 )
		OVER DUP 8192 */ ( Z_IM^2 )
		OVER OVER + ( Z_RE^2 + Z_IM^2 )
		R> SWAP ( BALANCE RETURN STACK )
		0< IF ( IF Z_RE^2 + Z_IM^2 > 32768, ABANDON )
		    DROP DROP
		    DROP 0
		    LEAVE
		ELSE ( COMPLETE ITERATION )
		    J SWAP ( RETREIVE C_RE )
		    >R ( SAVE FLAG )
		    - - ( Z_RE^2 - Z_IM^2 + C_CUR )
		    >R ( SAVE IT )
		    4096 */ OVER + ( 2*Z_RE*Z_IM + C_IM )
		    R> ( RETRIEVE Z_RE' )
		    SWAP ( -- C_IM Z_RE' Z_IM' )
		    R> ( RETRIEVE FLAG )
		THEN
	    LOOP

	    IF ( PLOT PIXEL )
		DROP DROP DROP ( BALANCE STACK )
		I 16384 + 317 / ( X COORD )
		J 8192 + 373 / ( Y COORD )
		1 PLOT
	    ELSE ( DO NOTHING )
		DROP DROP DROP ( BALANCE STACK )
	    THEN

	    ( NEXT C VALUE )
	317 +LOOP
    373 +LOOP
;

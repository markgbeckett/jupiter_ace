REX_TABLE:
	dw REX_R_00
	dw REX_L_00
	dw REX_R_01
	dw REX_L_01
	dw REX_R_02
	dw REX_L_02
	dw REX_R_03
	dw REX_L_03
	dw REX_R_04
	dw REX_L_04
	dw REX_R_05
	dw REX_L_05
	
	;; Rex data

	;; Rex Right Step, Distance 0
REX_R_00:
	DEFB $00
        DEFB $00, $19, _BLACK, _BLACK, _TOPBLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _RIGHTBLACK, _BLACK, _BLACK
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _TOPRIGHTWHITE, _BLACK, _BLACK
        DEFB $07, $19, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _TOPLEFTBLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACK, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _TOPBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _TOPRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _BOTTOMRIGHTWHITE, _BOTTOMLEFTWHITE, _BLACK, _TOPBLACK, _SPACE, _SPACE, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _LEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMLEFTWHITE, _BOTTOMLEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK , _BLACK, _BOTTOMLEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _RIGHTBLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _TOPBLACK
        DEFB $07, $19, _LEFTBLACK, _SPACE, _LEFTBLACK, _TOPRIGHTBLACK, _LEFTBLACK, _SPACE, _LEFTBLACK, _TOPRIGHTBLACK, _LEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _BOTTOMLEFTWHITE, _LEFTBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK , _SPACE, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _RIGHTBLACK, _LEFTBLACK, _SPACE
        DEFB $07, $19, _TOPRIGHTWHITE, _RIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _TOPRIGHTBLACK, _BLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _RIGHTBLACK, _LEFTBLACK, _SPACE
        DEFB $07, $19, _BOTTOMLEFTWHITE, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _TOPBLACK, _TOPBLACK, _SPACE, _SPACE, _SPACE, _BLACK, _BOTTOMRIGHTBLACK
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _TOPLEFTWHITE, _TOPRIGHTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _BOTTOMLEFTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _BLACK, _TOPLEFTBLACK , _SPACE, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
	DEFB $07, $19, _LEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _BOTTOMRIGHTBLACK, _BLACK, _TOPBLACK, _TOPLEFTBLACK , _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
	;; DEFB $07, $19, _BLACK, _BOTTOMBLACK, _SPACE, _TOPRIGHTWHITE, _BLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPBLACK, _BOTTOMLEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMRIGHTWHITE, _TOPLEFTBOTTOMRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBOTTOMRIGHT, _SPACE, _SPACE, _BOTTOMLEFTBLACK
	;; DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _TOPLEFTWHITE, _TOPLEFTBLACK , _SPACE, _RIGHTBLACK, _SPACE, _BLACK, _SPACE, _TOPRIGHTBLACK, _BOTTOMLEFTBLACK, _TOPLEFTWHITE, _TOPLEFTBLACK , _SPACE, _TOPLEFTBOTTOMRIGHT, _RIGHTBLACK, _LEFTBLACK
        DEFB $00

	;; Rex Left Step, Distance 0
REX_L_00:
	DEFB $00		
        DEFB $00, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _TOPBLACK, _SPACE, _RIGHTBLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _TOPLEFTBLACK, _BLACK, _BLACK, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _LEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BLACK, _BLACK, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _RIGHTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _SPACE, _BLACK, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK
        DEFB $07, $19, _TOPRIGHTBLACK, _LEFTBLACK, _RIGHTBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _TOPRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _BLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB $07, $19, _SPACE, _TOPBLACK, _TOPLEFTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _BLACK, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _BLACK, _TOPBLACK, _SPACE
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BOTTOMBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _SPACE, _SPACE
        DEFB $07, $19, _Y, _O, _U, _SPACE, _H, _A, _V, _E, _SPACE, _B, _E, _E, _N, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK, _LEFTBLACK, _SPACE, _BOTTOMBLACK
        DEFB $07, $1f, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK, _BOTTOMBLACK, _TOPBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $01, $1f, _P, _O, _S, _T, _H, _U, _M, _O, _U, _S, _L, _Y, _SPACE, _A, _W, _A, _R, _D, _E, _D, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $01, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _P, _O, _I, _N, _T, _S, _SPACE, _A, _N, _D, _SPACE, _S, _E, _N, _T, _E, _N, _C, _E, _D
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _T, _O, _SPACE, _R, _O, _A, _M, _SPACE, _T, _H, _E, _SPACE, _M, _A, _Z, _E, _SPACE, _F, _O, _R, _E, _V, _E, _R, _FULLSTOP
        DEFB $07, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _I, _F, _SPACE, _Y, _O, _U, _SPACE, _W, _I, _S, _H, _SPACE, _T, _O, _SPACE, _A, _P, _P, _E, _A, _L
        DEFB $07, $19, _TOPBLACK, _SPACE, _BLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _SPACE, _BOTTOMRIGHTWHITE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BOTTOMLEFTWHITE, _SPACE, _P, _R, _E, _S, _S, _SPACE, _INVA, _COMMA, _SPACE, _E, _L, _S, _E, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $07, $19, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
	DEFB $08, $19, _TOPRIGHTWHITE, _BOTTOMLEFTTOPRIGHT, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMBLACK, _BOTTOMLEFTBLACK, _SPACE, _P, _R, _E, _S, _S, _SPACE, _INVC, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE
	DEFB $08, $19, _BLACK, _BLACK, _BLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _SPACE, _SPACE, _BOTTOMBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
	;;          DEFB $08, $19, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _TOPLEFTWHITE, _LEFTBLACK, _TOPLEFTBOTTOMRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
	;;          DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE
        DEFB $00

	;; Rex Right Step, Distance 1
REX_R_01:
	DEFB $00
        DEFB $28, $04, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMLEFTBLACK
        DEFB $1b, $06, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $19, $07, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $19, $07, _RIGHTBLACK, _TOPRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _BOTTOMRIGHTWHITE
        DEFB $18, $09, _BOTTOMRIGHTBLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $16, $0A, _SPACE, _BLACK, _BLACK, _TOPRIGHTBLACK, _BLACK, _TOPLEFTWHITE, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $16, $0A, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _BOTTOMRIGHTBLACK, _BLACK, _BLACK
        DEFB $16, $0A, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _SPACE, _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB $15, $0B, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE
        DEFB $15, $0B, _RIGHTBLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPLEFTBLACK
        DEFB $15, $0B, _RIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $16, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $15, $0B, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $15, $0B, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE
        DEFB $15, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $16, $0A, _RIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPLEFTBOTTOMRIGHT, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $14, $0C, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _TOPBLACK, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK
        DEFB $14, $05, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK, _SPACE
        DEFB $00

	;; Rex Left Step, Distance 1
REX_L_01:
	DEFB $00
        DEFB $07, $06, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMLEFTBLACK
        DEFB $19, $08, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $17, $0A, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _SPACE
        DEFB $15, $0B, _SPACE, _TOPLEFTWHITE, _BLACK, _O, _BLACK, _BLACK, _BLACK, _BLACK, _O, _BLACK, _LEFTBLACK
        DEFB $15, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $15, $0B, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $14, $0D, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _TOPRIGHTWHITE, _SPACE
        DEFB $12, $0E, _SPACE, _BLACK, _BLACK, _LEFTBLACK, _TOPCHEQUERBOTTOMWHITE, _V, _V, _TOPBLACKBOTTOMCHEQUER, _TOPBLACKBOTTOMCHEQUER, _V, _V, _INVCHEQUERBOARD, _BLACK, _LEFTBLACK
        DEFB $12, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _TOPWHITEBOTTOMCHEQUER, _SPACE, _SPACE, _TOPCHEQUERBOTTOMWHITE, _TOPCHEQUERBOTTOMWHITE, _SPACE, _TOPWHITEBOTTOMCHEQUER, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _SPACE
        DEFB $11, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $11, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _INVCHEQUERBOARD, _SPACE, _SPACE, _SPACE, _SPACE, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $11, $0F, _SPACE, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _TOPWHITEBOTTOMCHEQUER, _SPACE, _SPACE, _TOPWHITEBOTTOMCHEQUER, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $11, $10, _SPACE, _TOPCHEQUERBOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE
        DEFB $10, $10, _SPACE, _BOTTOMLEFTWHITE, _TOPCHEQUERBOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $10, $0F, _TOPRIGHTBLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $11, $0F, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _LEFTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $12, $0E, _RIGHTBLACK, _BLACK, _BLACK, _LEFTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $10, $0F, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE
        DEFB $11, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK, _SPACE, _RIGHTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK
        DEFB $1b, $06, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
	;;         DEFB $1b, $05, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK, _TOPLEFTBLACK
        DEFB $00

REX_R_02:
	DEFB $00
        DEFB $88, $03, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK
        DEFB $1d, $04, _BOTTOMRIGHTWHITE, _BLACK, _BOTTOMRIGHTWHITE, _LEFTBLACK
        DEFB $1b, $05, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1b, $05, _RIGHTBLACK, _BOTTOMLEFTBLACK, _TOPBLACK, _TOPLEFTBLACK, _TOPRIGHTWHITE
        DEFB $1b, $06, _BLACK, _TOPRIGHTWHITE, _SPACE, _TOPLEFTWHITE, _BLACK, _BOTTOMLEFTBLACK
        DEFB $19, $07, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $19, $07, _RIGHTBLACK, _LEFTBLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $19, $07, _TOPRIGHTBLACK, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1a, $06, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $1a, $06, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _TOPLEFTWHITE, _BLACK
        DEFB $1a, $07, _BOTTOMLEFTWHITE, _BLACK, _RIGHTBLACK, _BLACK, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMBLACK
        DEFB $18, $03, _BOTTOMBLACK, _BLACK, _LEFTBLACK
        DEFB $00

REX_L_02:
	DEFB $00
        DEFB $67, $04, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE
        DEFB $1c, $05, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1b, $05, _BLACK, _TOPLEFTWHITE, _BLACK, _TOPRIGHTWHITE, _LEFTBLACK
        DEFB $1a, $07, _RIGHTBLACK, _TOPRIGHTBLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPLEFTWHITE, _SPACE
        DEFB $19, $07, _TOPLEFTWHITE, _LEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK
        DEFB $19, $07, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _SPACE, _BLACK, _BLACK, _BLACK
        DEFB $19, $08, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _BLACK, _LEFTBLACK
        DEFB $18, $08, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _TOPRIGHTBLACK, _BLACK
        DEFB $18, $08, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _TOPBLACK
        DEFB $17, $08, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $18, $09, _BLACK, _BLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _LEFTBLACK
        DEFB $17, $09, _BOTTOMLEFTWHITE, _BLACK, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _TOPLEFTBLACK
        DEFB $16, $0A, _BOTTOMBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _TOPRIGHTBLACK, _BLACK, _LEFTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $1d, $03, _BOTTOMLEFTWHITE, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK
        DEFB $00
	
REX_R_03:
	DEFB $00
        DEFB $e9, $03, _RIGHTBLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1d, $03, _TOPRIGHTBLACK, _BLACK, _TOPLEFTBLACK
        DEFB $1c, $04, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMBLACK, _LEFTBLACK
        DEFB $1c, $04, _RIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $1d, $03, _BLACK, _BLACK, _BLACK
        DEFB $1c, $05, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPLEFTBLACK
        DEFB $00

REX_L_03:
	DEFB $00
        DEFB $c9, $03, _TOPLEFTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $1c, $04, _RIGHTBLACK, _TOPRIGHTWHITE, _BLACK, _TOPLEFTWHITE
        DEFB $1c, $04, _TOPRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _TOPBLACK, _TOPLEFTBOTTOMRIGHT
        DEFB $1c, $05, _RIGHTBLACK, _BLACK, _BOTTOMBLACK, _BLACK, _LEFTBLACK
        DEFB $1b, $05, _TOPRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $1b, $05, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1b, $05, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1a, $06, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _LEFTBLACK, _TOPBLACK, _BLACK, _LEFTBLACK
        DEFB $1e, $02, _TOPBLACK, _TOPBLACK
        DEFB $00

REX_R_04:
	DEFB $01
        DEFB $0a, $01, _BOTTOMBLACK
        DEFB $1e, $02, _BOTTOMRIGHTBLACK, _BLACK
        DEFB $1e, $03, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK
        DEFB $1d, $02, _TOPRIGHTBLACK, _TOPLEFTBLACK
        DEFB $00

REX_L_04:
	DEFB $00
        DEFB $e9, $02, _BOTTOMRIGHTBLACK, _BOTTOMBLACK
        DEFB $1e, $02, _TOPRIGHTBLACK, _BOTTOMRIGHTWHITE
        DEFB $1e, $03, _BLACK, _TOPLEFTWHITE, _TOPRIGHTWHITE
        DEFB $1d, $03, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMLEFTTOPRIGHT
        DEFB $1d, $03, _TOPBLACK, _TOPBLACK, _TOPRIGHTWHITE
        DEFB $00

REX_R_05:
	DEFB $01
        DEFB $2a, $01, _BOTTOMBLACK
        DEFB $1f, $01, _TOPBLACK
        DEFB $00

REX_L_05:
	DEFB $01
        DEFB $2a, $01, _BLACK
        DEFB $1f, $01, _BLACK
        DEFB $00


RING_MASTER:
	DEFB _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BOTTOMBLACK, _MINUS, _MINUS, _MINUS, _BOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _PLUS, _O, _PLUS, _BLACK, _TOPCHEQUERBOTTOMBLACK, _SPACE, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _EQUALS, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _BLACK
        DEFB _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPRIGHTBLACK, _BOTTOMBLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE
        DEFB _BLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _I, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _I, _SPACE, _SPACE, _BLACK, _SPACE, _BOTTOMRIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _I, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _LEFTBLACK, _SPACE, _TOPLEFTBOTTOMRIGHT, _BOTTOMBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _SPACE, _BOTTOMLEFTTOPRIGHT, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _SPACE, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _LEFTBLACK, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _ASTERISK, _ASTERISK, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _LEFTBLACK, _I, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _TOPRIGHTWHITE, _PLUS, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _BLACK, _BOTTOMLEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _TOPRIGHTWHITE, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _BLACK, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _ASTERISK, _BOTTOMRIGHTBLACK, _BLACK, _ASTERISK, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK
        DEFB _TOPBLACK, _TOPBLACK, _TOPLEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _SPACE, _TOPBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

RING_M_BOW:
	DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _TOPCHEQUERBOTTOMBLACK, _BOTTOMRIGHTWHITE, _TOPRIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _SPACE, _SPACE, _SPACE, _O, _SPACE, _SPACE, _SPACE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _TOPBLACK, _BOTTOMBLACK, _BOTTOMRIGHTBLACK, _SPACE, _RIGHTBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _SPACE, _RIGHTBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _SPACE, _TOPLEFTWHITE, _BLACK
        DEFB _LEFTBLACK, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _BOTTOMBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _I, _ASTERISK, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _BOTTOMBLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTPARENTH, _RIGHTBLACK, _SPACE


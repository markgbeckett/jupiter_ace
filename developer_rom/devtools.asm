	;; Additional words that are useful for developers

	;; Switch to hexadecimal mode (analogue of built-in DECIMAL)
w_hex:
	FORTH_WORD "HEX"
	ld (IX + 0x3F), 0x10
	jp (iy)	
.word_end:

	;; Definer word to allow small m/code routines to be stored in
	;; (and called from) FORTH words (see Jupiter Ace manual,
	;; Ch 25, p.147)
w_code:
.name:  ABYTEC 0 "CODE"
.name_end:
	dw LINK                 ; Link field 
	SET_VAR LINK, $         
	db .name_end - .name    ; Name-length field
	dw 0x1085               ; Code field
	dw .entry               ; Parameter field
	db 0xe8, 0x10, 0xf0, 0xff
.entry:	db 0xcd, 0xf0, 0x0f
	db 0xa7, 0x10
	db 0xb6, 0x04
.word_end:

w_diss:
	FORTH_WORD "DIS"
	include "z80_dis_ace.asm"
.word_end:

w_hdump:
	FORTH_WORD "DUMP"
	jp HDUMP
.word_end:
	

;; 	;; .S ( -- )
;; 	;; Pronounced "dot-S". A debugging command writes Forth stack
;; 	;; contents to screen without affecting stack
FORTH_MODE = #0ec3
w_dots:
	FORTH_WORD_ADDR ".S", FORTH_MODE

	dw 0x1011		; Stack next word
	dw 0x3c3b		; SPARE
	dw 0x08b3		; @
	dw 0x0460		; HERE
	dw 0x1011		; Stack next word
	dw 0x000c		; 12 (decimal)
	dw 0x0dd2		; + (ADD)
	dw 0x0912		; OVER
	dw 0x0912		; OVER
	dw 0x0de1		; - (SUBTRACT)
	dw 0x1283		; ?BRANCH
	dw 0x0015		; Forward 21 (decimal) bytes
	dw 0x1323		; Shuffle
	dw 0x12e9		; I (RETRIEVE LOOP INDEX)
	dw 0x08b3		; @
	dw 0x09b3		; . (PRINT IT)
	dw 0x1011		; Stack next word
	dw 0x0002		;
	dw 0x133c		; END OF LOOP
	dw 0xfff3		; -13 (decimal) bytes
	dw 0x1271		; BRANCH
	dw 0x0007		; +7 (decimal) bytes
	dw 0x0879		; DROP
	dw 0x0879		; DROP
	dw 0x12a4		; END
	dw 0x04b6		; NEXT
.word_end:

	;; Tut-tut for Jupiter Ace
	;; Original Game by David Stephenson 2019
	;; Ported to Jupiter Ace by George Beckett 2020
	;;
	;; This file contains an optimised Z80 implementation
	;; of 2DUP for Jupiter Ace. To use this version, you
	;; should assemble the source code--to provide the binary
	;; representation of the instructions--and then manually
	;; insert these binary values into a word definition of
	;; 2DUP -- using the CODE word from manual. For an example,
	;; see definition of HALT in 'tut-tut.fs'.
	;;	
	;; In case of problems, contact:
	;; markgbeckett@gmail.com

	org 0x0000

2DUP:	call 0x084e		; TOS -> BC
	rst 0x18		; NOS -> DE

	ld hl, (0x3c3b)		; Addr of TOS

	ld (hl),e		; Push DE
	inc hl
	ld (hl),d
	inc hl
	ld (hl),c		; Push BC
	inc hl
	ld (hl),b
	inc hl

	ld (hl),e		; Push DE
	inc hl
	ld (hl),d
	inc hl
	ld (hl),c		; Push BC
	inc hl
	ld (hl),b
	inc hl

	ld (0x3c3b),hl 		; Store new stack addr
	
	jp (iy)			; Return to FORTH
END:	

	org 0x0000
	;; Optimised Z80 implementation of 2DUP
	;; for Jupiter Ace. Should be inserted
	;; into a word definition -- e.g. using
	;; CODE word from manual.

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

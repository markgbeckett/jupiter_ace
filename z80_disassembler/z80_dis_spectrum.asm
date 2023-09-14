	include "z80_disassembler.asm"

	;; Retrieve character set
	include "spectrum_chars.asm"

TVFLAGS:	equ 0x5c3c
STKEND:		equ 0x5c65

	;; Initialise display, etc.
INIT:
	;; Retrieve address from stack into DE
	xor a
	ld (TVFLAGS),a

	ret

	;; Print A to screen, protecting registers
PRINT_A:
	push bc
	push de
	push hl
	exx
	rst 0x10
	exx
	pop hl
	pop de
	pop bc

EXIT:	ret

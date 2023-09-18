	org 0x6800

	include "z80_disassembler.asm"

	;; Retrieve character set
	include "spectrum_chars.asm"

TVFLAGS:	equ 0x5c3c
DISS:		equ 0x5c65

EXT_ADDR: equ 0x00
IND_ADDR: equ 0x01
IMM_ADDR:	equ 0x02
IMM_EXT_ADDR:	equ 0x03

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

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
REL_ADDR:	equ 0x04

ADDRESS:	dw 0x0000

	;; Initialise display, etc.
INIT:
	;; Retrieve address from stack into DE
	xor a
	ld (TVFLAGS),a

	ret

	;; Make sure character in A is printable, replacing with a
	;; fullstop if not printable
	;;
	;; On entry:
	;;   A - character to test
	;;
	;; On exit:
	;;   A - character to print
	;;   C - corrupted
	
CHECKPRINTABLE:	

	;; Check low-end range
	cp _SPACE
	jr c, NONPRINT

	;; Check high-end range
	cp _COPYRIGHT+1
	jr nc, NONPRINT

	ret
	
	;; Character is not printable, so replace it
NONPRINT:
	ld a, _FULLSTOP
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

TAB:	ld a, 0x06
	jr PRINT_A


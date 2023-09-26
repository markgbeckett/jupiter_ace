	org 0x7800

	include "z80_disassembler.asm"

	;; Retrieve character set
	include "..\..\zx80\utilities\zx80_chars.asm"
DISS:		dw DISS_BUFF
DISS_BUFF:	ds 0x20

	;; Following codes must be sequential
EXT_ADDR:	equ 0x02
IND_ADDR:	equ 0x03
IMM_ADDR:	equ 0x04
IMM_EXT_ADDR:	equ 0x05
REL_ADDR:	equ 0x06

SCROLL_COUNT:	db 0x00
ADDRESS:	dw 0x00
OLD_SP:		dw 0x67FC
PRPOS:		equ 0x06E0		; Corrupts HL, BC, and DE
PRINT_CH:	equ 0x0720
TVFLAGS:	equ 0x5C3C

	;; Initialise display, etc.
INIT:
	ld (OLD_SP),SP
	
	xor a
	ld (SCROLL_COUNT),a
	
	ret

	;; Print A to screen, protecting registers
PRINT_A:
	push bc
	push de
	push hl
	exx
	push bc
	push de
	push hl
	push af
	
	cp _EOL
	jr nz, PRINT_CNT

	ld a,(SCROLL_COUNT)
	inc a
	ld (SCROLL_COUNT),a

	cp 0x16
	jr nc, EXIT

PRINT_CNT:
	pop af
	push af
	
	call PRPOS
	pop af
	call PRINT_CH

	pop hl
	pop de
	pop bc
	exx
	pop hl
	pop de
	pop bc

	ret
	
	;; Exit to BASIC
EXIT:	
	;; Transfer address of next command to disasseble to HL, so it
	;; is returned to BASIC
	ld h,b
	ld l,c
	
	ld sp,(OLD_SP)			; Balance stack
	pop bc

	ret

END:	

	org 0x6800
	
	include "z80_disassembler.asm"

	;; Retrieve character set
	include "..\utilities\jupiter_chars.asm"

DISS:		dw 0x2701		; Address of AceFORTH pad
ADDRESS:	equ 0x27FE
OLD_SP:		equ 0x27FC

EXT_ADDR: equ 0x00
IND_ADDR: equ 0x01
IMM_ADDR:	equ 0x02
IMM_EXT_ADDR:	equ 0x03
REL_ADDR:	equ 0x04
	
SCROLL_COUNT:	db 0x00
	
SCRPOS:	equ 0x3C1C
L_HALF:	equ 0x3C24
KEYSCAN: equ 0x0336
SCROLL:	equ 0x0421
	
	;; Initialise display, etc.
INIT:
	ld (OLD_SP),SP
	
	;; Retrieve address from stack into DE
	rst 0x18
	ld (ADDRESS),de

	;; Ensure print to upper screen
	res 3,(IX+0x3E)	

	;; Reset scroll count
	ld a, 0x16
	ld (SCROLL_COUNT),a
	
	ret

	;; Print A to screen, protecting registers
PRINT_A:
	push bc
	push de
	push hl

	ld de,(SCRPOS)
	ld hl,(L_HALF)
	scf

	sbc hl,de
	ex de,hl

	push af
	call c, CHECK_SCROLL
	pop af
	
	cp 0x0D

	jr z, NEWLINE

	ld (hl),a
	inc hl

	jr PRINT_CONT

TAB:	push hl
	ld hl,(SCRPOS)

TAB_STEP:
	inc hl
	ld a,l
	and %00001111
	jr nz, TAB_STEP

	dec hl
	dec hl
	
	ld (SCRPOS),hl
	
	pop hl

	ret
	
NEWLINE:
	inc hl
	ld a,l
	and 0x1F
	jr nz, NEWLINE

PRINT_CONT:
	ld (SCRPOS),hl

	pop hl
	pop de
	pop bc

	ret

CHECK_SCROLL:
	ld a,(SCROLL_COUNT)
	inc a
	cp 0x17

	jr c, CHECK_CONT

CHECK_LOOP:
	call KEYSCAN
	jr z, CHECK_LOOP

	cp _SPACE
	jr nz, RESET_SCROLL

	jr EXIT
	
RESET_SCROLL:
	xor a
	
CHECK_CONT:
	ld (SCROLL_COUNT),a
	
	call SCROLL

	ret

	;; Return to Forth
EXIT:	ld ix, 0x3C00
	ld sp, (OLD_SP)
	pop bc			; Balance stack
	
	jp (iy)

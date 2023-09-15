	include "z80_disassembler.asm"

	;; Retrieve character set
	include "..\3d_monster_maze\jupiter_chars.asm"

STKEND:	dw 0x2701		; Address if AceFORTH pad
SCROLL_COUNT:	dw 0x67FE
OLD_SP:	dw 0x67FC
	
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

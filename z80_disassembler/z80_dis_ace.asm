	org 0x6800
	
	include "z80_disassembler.asm"

	;; Retrieve character set
	include "..\utilities\jupiter_chars.asm"

DISS:		dw 0x2701		; Address of AceFORTH pad
ADDRESS:	equ 0x27FE
OLD_SP:		equ 0x27FC
LINE_COUNT:	equ 0x27FB
	

EXT_ADDR: equ 0x01
IND_ADDR: equ 0x02
IMM_ADDR:	equ 0x03
IMM_EXT_ADDR:	equ 0x04
REL_ADDR:	equ 0x05
	
SCRPOS:	equ 0x3C1C
L_HALF:	equ 0x3C24
KEYSCAN: equ 0x0336
SCROLL:	equ 0x0421		; Routine to scroll screen and move
				; SCRPOS up by one line
	
	;; Initialise display, etc.
INIT:
	ld (OLD_SP),SP
	
	;; Retrieve address from stack into DE
	rst 0x18
	ld (ADDRESS),de

	;; Ensure print to upper screen
	res 3,(IX+0x3E)	

	;; Reset scroll count
	xor a
	ld (LINE_COUNT),a
	
	ret

	;; Print A to screen, protecting registers
PRINT_A:
	;; Save current registers
	push bc
	push de
	push hl

	;; Check if need to scroll
	ld de,(SCRPOS)		; Retrieve current print location
	ld hl,(L_HALF)		; Retrieve start locn for lower screen
	scf

	sbc hl,de		; Carry indicates if SCRPOS > L_HALF
	ex de,hl		; HL = SCRPOS

	jr nc, NO_SCROLL

	call SCROLL

	;; HL contains current print location

NO_SCROLL:
	;; Check for newline
	cp 0x0D
	jr z, NEWLINE

	;; If not new line, then print character
	ld (hl),a
	inc hl

	jr PRINT_CONT

NEWLINE:
	;; Update line count and check if need to pause
	ld a,(LINE_COUNT)
	inc a

	cp 0x17

	;; Continue if no need to pause
	jr c, NO_WAIT
	
	push hl			; Save print posn

	;; Wait for key press
CHECK_LOOP:
	call KEYSCAN
	jr z, CHECK_LOOP

	;; Check for Break
	cp _SPACE
	jr z, EXIT

	;; Reset line count
	xor a

	;; Restore screen position
	pop hl
	
NO_WAIT:
	ld (LINE_COUNT),a

	;;  Implement newline
NEWLINE_ADVANCE:
	inc hl
	ld a,l
	and 0x1F
	jr nz, NEWLINE_ADVANCE

PRINT_CONT:
	;; Save new print position
	ld (SCRPOS),hl

	;; Restore registers
	pop hl
	pop de
	pop bc

	;; Done
	ret

	;; Advance to column 14
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
	
	;; Return to Forth
EXIT:	ld ix, 0x3C00
	ld sp, (OLD_SP)
	pop bc			; Balance stack
	
	jp (iy)

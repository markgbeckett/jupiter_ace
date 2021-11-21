	;; 3D rendering routines 

BUFFER:		equ 0x3c76	; Address of screen buffer
				; To write directly to screen, use 0x2400
STACK_TO_BC:	equ 0x084e	; ROM routine to extract TOS into BC pair

	include "jupiter_chars.asm"
	
	org 0x49f3		; Set ORG address to be start of 3DVIEW 
				; word in dictionary, and make sure
				; word has enough space for END - ORG
				; addr.
	
	;; Jump table to ensure persisent execution addresses for
	;; Forth-accessible routines
	jp DRAWLSEG		; 3DVIEW + 00
	jp DRAWRSEG		; 3DVIEW + 03
	jp DRAWEWALL		; 3DVIEW + 06
	jp DRAWEXIT		; 3DVIEW + 09
	jp CYCLE_PATTERN	; 3DVIEW + 12
	jp DRAW_REX		; 3DVIEW + 15

	;; Variables
REX_STEPS:	db 0x00		; Count steps

	;; Character data for different views of Rex
	include "3dmm_graphics.asm"
	
	;; ======================================================
	;; Macro to print a column of characters
	;;
	;; On entry:
	;;   HL - pointer to first cell in buffer to be populated
	;;   DE - step size (ususally one row, which is 32 bytes)
	;;   B  - number of characters to print
	;; 
	;; N.B. Z80ASM has simplistic macro support, which does
	;; not seem to be able to cope with labels, so DJNZ
	;; command is hand-assembled to work around this.
	;; ======================================================
	mfill:	macro char

	ld a, char
mfill_loop:
	ld (hl),a
	add hl,de
	db 0x10, 0xfc 		; djnz -4
	
	endm

	;; ======================================================
	;; Fill in one column of wall on left of view
	;; 
	;; On entry, BC contains column number
	;; ======================================================
DRAW_L_WALL:	
	;; Move to correct display column
	ld hl, BUFFER
	add hl, bc

	ld de, 0x0020		; Displacement to next display row
		
	ld b,c			; Move column number into b, so can
				; use with DJNZ (backup copy in c)
	
	;;  Check if spaces needed at top of wall
	ld a,b
	and a
	jr z, NO_L_TOP

	;; Fill on spaces
L_TOP:	mfill _SPACE

	;; Print sloping wall 
NO_L_TOP:
	ld (hl), _TOPRIGHTWHITE
	add hl, de

	;; Print mid-section, if any
L_MIDDLE:
	ld b,c			; Retrieve column number from backup
	
	;; Work out a = 18-2*b
	sla b
	ld a, 18
	sub b

	and a
	jr z, NO_L_MID

	ld b,a			; B contains number of wall
				; sections to print
	
L_MID:	mfill _BLACK

	;; Print lower diagonal wall section
NO_L_MID:
	ld (hl), _BOTTOMRIGHTWHITE
	add hl, de

	ld a,c
	and a

	ret z 			; Done, if no space at bottom

L_BOTTOM:
	ld b,c
	mfill _SPACE
	
NO_L_BOT:
	ret

	;; ======================================================
	;; Fill in one column of wall on right of view 
	;; On entry, TOS contains column number
	;; ======================================================
DRAW_R_WALL:	
	push bc			; Save column number
	
	;; Move to correct display column
	ld a,20
	sub c
	ld c,a			; B=0 already, so BC = column offset
	
	ld hl, BUFFER
	add hl, bc		
	
	ld de, 0x0020		; Displacement to next display row
		
	;; Retrieve column and copy into b
	pop bc
	ld b,c
	
	;;  Check if spaces needed at top
	ld a,b
	and a
	jr z, NO_R_TOP

	;; Fill on spaces
R_TOP:	mfill 32

	;; Print sloping wall 
NO_R_TOP:
	ld (hl), _TOPLEFTWHITE
	add hl, de

	;; Print mid-section, if any
R_MIDDLE:
	ld b,c
	
	;; Work out a = 18-2b
	sla b
	ld a, 18
	sub b

	and a
	jr z, NO_R_MID

	ld b,a			; B contains number of wall
				; sections to print
	
R_MID:	mfill _BLACK

	;; Print lower diagonal wall section
NO_R_MID:
	ld (hl), _BOTTOMLEFTWHITE
	add hl, de

	ld a,c
	and a

	ret z			; Done, if no space at bottom

R_BOTTOM:
	ld b,c
	mfill _SPACE
	
NO_R_BOT:
	ret


	;; ======================================================
	;; Fill in one column of gap on left of view 
	;; On entry, TOS contains column number
	;; ======================================================
DRAW_L_GAP:
	;; Move to correct display column
	ld hl, BUFFER
	add hl,bc

	push hl			; Save for later

	;; Work out height of wall at specific column
	ld hl, DISTWALL
	add hl,bc
	ld a,(hl)

	;; Retrieve display pointer
	pop hl
	ld de, 0x0020
	
	ld c,a
	
	and a

	jr z, L_GAP
	ld b,a

TOP_L_GAP:
	mfill _SPACE

	;; Print 20-2*col wall graphics
L_GAP:	
	ld b,c
	sla b
	ld a, 20
	sub b
	and a
	jr nz, L_FACE_LOOP

	sbc hl,de
	ld (hl),2
	add hl,de
	ld (hl),3
	add hl,de
	jr NO_L_GAP
	
L_FACE_LOOP:
	ld b,a

	mfill _CHEQUERBOARD

NO_L_GAP:
	ld a,c
	and a
	ret z 			; Done, if no space at bottom

BOT_L_GAP:
	ld b,c
	mfill _SPACE
	
NO_L_B_GAP:
	ret
	
	;; ======================================================
	;; Fill in one column of gap on right of view. 
	;; On entry, TOS contains column number
	;; ======================================================
DRAW_R_GAP:
	push bc			; Save column number
	
	;; Move to correct display column
	ld a,20
	sub c
	ld c,a			; B=0, so BC = column offset
	
	ld hl, BUFFER
	add hl, bc

	;; Retrieve column
	pop bc

	;; Work out height of wall
	push hl			; Save for later
	ld hl, DISTWALL
	add hl,bc
	ld a,(hl)
	ld c,a

	;; Retrieve display pointer
	pop hl
	ld de, 0x0020
	
	and a
	jr z, R_GAP
	ld b,a

TOP_R_GAP:
	mfill _SPACE
	
	;; Print 20-2*col wall graphics
R_GAP:	
	ld b,c
	sla b
	ld a, 20
	sub b
	and a
	jr nz, R_FACE_LOOP

	sbc hl,de
	ld (hl),_TOPWHITEBOTTOMCHEQUER
	add hl,de
	ld (hl),_TOPCHEQUERBOTTOMWHITE
	add hl,de
	jr NO_R_GAP

R_FACE_LOOP:
	ld b,a

	mfill _CHEQUERBOARD

NO_R_GAP:
	ld a,c
	and a
	ret z			; Done, if no space at bottom

BOT_R_GAP:
	ld b,c
	mfill _SPACE
	
NO_R_B_GAP:
	ret


	;; ======================================================
	;; Draw lefthand wall segment. On entry, TOS is a flag
	;; (1=wall, 0=gap), 2OS is distance
	;; ======================================================
DRAWLSEG:
	rst 0x18		; Retrieve flag into DE

	ld a,e			; Save flag 
	push af

	rst 0x18		; Retrieve distance

	ld hl, DISTCOL		; Retrieve column info
	add hl, de

	ld c,(hl)		; Retrieve starting column
	inc hl
	ld a, (hl)		; Retrieve one more than final column

	sub c			; Work out number of columns to print
	ld b,a			; and move to loop counter

DLS_LOOP:
	pop af			; Retrieve flag
	push af

	push bc			; Save loop counter
	ld b,0x00

	and a			; Check if wall or gap
	jr z, DLS_GAP
	call DRAW_L_WALL
	jr DLS_CONT
	
DLS_GAP:	
	call DRAW_L_GAP

DLS_CONT:
	pop bc			; Retrieve loop counter and col
	inc c			; Move to next column

	djnz DLS_LOOP
	
	pop af			; Balance stack
	
	jp (iy)			; Done
	
	;; ======================================================
	;; Draw righthand wall segment. On entry, TOS is a flag
	;; (1=wall, 0=gap), 2OS is distance
	;; ======================================================
DRAWRSEG:
	rst 0x18		; Retrieve flag into DE

	ld a,e			; Save flag 
	push af

	rst 0x18		; Retrieve distance into DE

	ld hl, DISTCOL		; Retrieve column info
	add hl, de

	ld c,(hl)		; Retrieve starting column
	inc hl
	ld a, (hl)		; Retrieve one more than final column

	sub c			; Work out number of columns to print
	ld b,a			; and move to loop counter

DRS_LOOP:
	pop af			; Retrieve flag
	push af

	push bc			; Save loop counter
	ld b,0x00

	and a			; Check if wall of gap
	jr z, DRS_GAP
	call DRAW_R_WALL
	jr DRS_CONT
	
DRS_GAP:	
	call DRAW_R_GAP

DRS_CONT:
	pop bc			; Retrieve loop counter and col
	inc c			; Move to next column

	djnz DRS_LOOP
	
	pop af			; Balance stack
	
	jp (iy)			; Done


	;; ======================================================
	;; Draw end-wall section. On entry, TOS contains
	;; distance.
	;; ======================================================
DRAWEWALL:
	rst 0x18		; Retrieve TOS into DE

	ld hl, DISTWIDTH
	add hl,de
	ld b,(hl)

	ld hl, DISTHEIGHT
	add hl,de
	ld c,(hl)

	;; BC contains width and height of end-wall section

	push bc			; Save it

	;; Work out row offset of end-wall section
	ld a, 20
	sub c
	sra a			; A contains row offset

	ld hl, BUFFER		; Start of display buffer
	ld de, 0x0020		; Row offset

	and a			; Check if non-zero offset to be applied
	jr z, DEW_COL_OFFSET

	ld b,a			; Move to counter

DEW_ROWSTEP:
	add hl, de
	djnz DEW_ROWSTEP

DEW_COL_OFFSET:
	;; HL contains start of row buffer
	
	pop bc			; Retrieve end-wall size
	push bc

	;;  Work out column offset
	ld a,21
	sub b
	sra a

	ld b,0
	ld c,a
	add hl,bc

	;; HL now points to top-left corner of end-wall section
	ld a,0x01

	pop bc
DEW_RLOOP:
	push bc
	push hl

DEW_CLOOP:	
	ld (hl),a
	inc hl
	djnz DEW_CLOOP

	pop hl
	pop bc

	add hl,de		; Move to next row

	dec c			; Check if any more rows
	jr nz, DEW_RLOOP

	;; Done
	jp (iy)
	

	
	;; ======================================================
	;; Draw exit, face-on. On entry, TOS contains
	;; distance (measured in segments).
	;; ======================================================
DRAWEXIT:
	rst 0x18		; Retrieve TOS into DE

	;; Check distance
	ld a,e
	cp 6
	jr c, DE_VISIBLE

	jp (iy)
	
	;; Work out width of exit, based on distance
DE_VISIBLE:
	ld hl, DISTCOL
	add hl, de

	ld d,(hl)		; Retrieve starting column for distance
	sla d
	ld a,21 		; Width of screen view + 1

	sub d			; A is width of exit + 1

	ld c,a			; Save it
	ld b,2			; Initial width

	;; Draw centre of exit
	ld hl, BUFFER + 0x14a 	; Offset to middle of view
	ld de, EXIT_PATTERN + 0x0b ; Last character in pattern

DE_SQUARE:
	dec de			; Advance to next character
	push de			; Save it
	push bc			; Save width data

	ld a,(de)		; Retrieve next character

	ld de, 0x0020		; One-row offset

	;; Print top of square
	dec hl 			; Move left

	and a
	sbc hl, de		; Move up

DE_TOP:	ld (hl),a
	inc hl
	djnz DE_TOP

	pop bc			; Restore current width
	push bc

	dec b
	
DE_RIGHT:
	ld (hl),a
	add hl,de		; Move to next row
	djnz DE_RIGHT

	pop bc			; Restore current width
	push bc

DE_BOTTOM:
	ld (hl),a
	dec hl			; Move left
	djnz DE_BOTTOM

	pop bc			; Restore current width
	push bc

	dec b

DE_LEFT:
	ld (hl),a
	and a
	sbc hl,de		; Move up
	djnz DE_LEFT

	pop bc			; Retrieve width info
	pop de			; Retrieve pointer to exit pattern

	inc b			; Next level out is two chars wider
	inc b

	ld a,b			; Check if done
	sub c

	jr c, DE_SQUARE

	jp (iy)

CYCLE_PATTERN:
	ld hl, EXIT_PATTERN + 1
	ld de, EXIT_PATTERN
	ld bc, 0x000a
	ldir

	ex de,hl		; DE is address for new char
	dec de
	
	rst 0x10		; DE to stack

	jp (iy)
	
	
EXIT_PATTERN:
	db "V", "`", "/", "W", "X", "B", "I", "V", "C", "S", "G"
	
DISTWALL:
	 db 1, 4, 4, 4, 6, 6, 8, 8, 9, 10                                                                                
DISTCOL:
	db 0, 1, 4, 6, 8, 9, 10

DISTWIDTH: db 21, 19, 13, 9, 5, 3, 1
	
DISTHEIGHT: db 20, 18, 12, 8, 4, 2, 2

	;; Print Rex
	;;
	;; On entry, TOS contains distance
DRAW_REX:
	rst 0x18			; Retrieve TOS into DE

	;; Check within view
	ld a,e
	cp 0x06
	jr nc, DR_DONE
	
	sla e				; Multiply E by 4 (D = 0)
	sla e
	
	;;  Check if left or right foot forward
	ld a, (REX_STEPS)
	and %00000001
	jr z, DR_RIGHT_FOOT
	inc e			; If left, add 2 to E
	inc e

DR_RIGHT_FOOT:
	;; Find address of relevant Rex data
	ld hl, REX_TABLE
	add hl, de

	ld e,(hl)
	inc hl
	ld d,(hl)

	ex de,hl		; HL points to Rex data

	;; Work out offset into BUFFER (**high byte first**)
	ld d,(hl)
	inc hl
	ld e,(hl)
	inc hl			; HL now points to row length

	push hl			; Save pointer
	ld hl,BUFFER
	add hl,de		; HL points to first print location

	pop de			; DE points into Rex data

	ex de,hl		; DE points into BUFFER and HL points into Rex data

	ld b,0x00
	ld c,(hl) 		; Length of Row
	inc hl

	jr DR_PRINT_ROW

DR_NEXT_ROW:
	ld a,(hl)		; Retrieve next offset
	inc hl

	;; If zero, done
	and a
	jr Z, DR_DONE

	;;  Add offset to DE
	add a,e
	jr nc, DR_NO_CARRY
	inc d			; Apply carry

DR_NO_CARRY:
	ld e,a
	
	;; Retrieve row length
	ld b,0x00
	ld c,(hl)
	inc hl

DR_PRINT_ROW:
	ldir

	jr DR_NEXT_ROW

DR_DONE:
	jp (iy)
	
END:	


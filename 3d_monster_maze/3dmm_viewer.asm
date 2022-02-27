MAZE:		equ 0x4199
EXITVIS:	equ 0x5c79
_WALL:		equ 0x80
_EXIT:		equ 0x40
_MAZEH:		equ 0x0012
_MAZEW:		equ 0x0012
	
	;; 3D rendering routines 

BUFFER:		equ 0x3c76	; Address of screen buffer
				; To write directly to screen, use 0x2400
STACK_TO_BC:	equ 0x084e	; ROM routine to extract TOS into BC pair

	include "jupiter_chars.asm"
	
	org 0x49e3		; Set ORG address to be start of 3DVIEW 
				; word in dictionary, and make sure
				; word has enough space for END - ORG
				; addr.
	
	;; Jump table to ensure persisent execution addresses for
	;; Forth-accessible routines
	jp DRAWVIEW		; 3DVIEW + 0x00
	jp DRAWEXIT		; 3DVIEW + 0x03
	jp CYCLE_PATTERN	; 3DVIEW + 0x06
	jp DRAW_REX		; 3DVIEW + 0x09
	jp FRAME_CLEAR		; 3DVIEW + 0x0C
	jp FRAME_UPDATE		; 3DVIEW + 0x0F
	jp FRAME_GRAB		; 3DVIEW + 0x12
	jp FTYPE		; 3DVIEW + 0x15
	
	;; Variables
REX_STEPS:	db 0x00		; Count steps (3DVIEW + 0x18)

	;; Status messages
STATUS_MSG:	 		; 3DVIEW + 0x19 
	db "   REX LIES IN WAIT   " ; Status = 0
	db _SPACE, _INVR, _INVU, _INVN
	dm " HE IS BEHIND YOU " ; Status = 1
	db _SPACE, _INVR, _INVU, _INVN
	dm " HE IS BESIDE YOU " ; Status = 2
	db "   REX HAS SEEN YOU   " ; Status = 3
	db " FOOTSTEPS APPROACHING" ; Status = 4
	db " HE IS HUNTING FOR YOU" ; Status = 5
	db "                      " ; Status = 6
	
	
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
	mfill:	macro char	; (2+B*31)

	ld a, char 		; (7)
mfill_loop:
	ld (hl),a		; (7)
	add hl,de		; (11)
	db 0x10, 0xfc 		; djnz -4 (13/8)
	
	endm

	;; ======================================================
	;; Fill in one column of wall on left of view
	;; 
	;; On entry, BC contains column number
	;; ======================================================
DRAW_L_WALL:			; (~779)
	;; Move to correct display column
	ld hl, BUFFER		; (10)
	add hl, bc		; (11)

	ld de, 0x0020		; Displacement to next display row (10)
		
	ld b,c			; Move column number into b, so can (4)
				; use with DJNZ (backup copy in c)
	
	;;  Check if spaces needed at top of wall
	ld a,b			; (4)
	and a			; (4)
	jr z, NO_L_TOP		; (12/7)

	;; Fill on spaces
L_TOP:	mfill _SPACE		; (2+31*B)

	;; Print sloping wall 
NO_L_TOP:
	ld (hl), _TOPRIGHTWHITE ; (10)
	add hl, de		; (11)

	;; Print mid-section, if any
L_MIDDLE:
	ld b,c			; Retrieve column number from backup (4)
	
	;; Work out a = 18-2*b
	sla b			; (4)
	ld a, 18		; (7)
	sub b			; (4)

	and a			; (4)
	jr z, NO_L_MID		; (12/7)

	ld b,a			; B contains number of wall (4)
				; sections to print
	
L_MID:	mfill _BLACK		; (2+31*B)

	;; Print lower diagonal wall section
NO_L_MID:
	ld (hl), _BOTTOMRIGHTWHITE ; (10)
	add hl, de		   ; (11)

	ld a,c			; (4)
	and a			; (4)

	ret z 			; Done, if no space at bottom (11/5)

L_BOTTOM:
	ld b,c 			; (4)
	mfill _SPACE		; (2+31*B)
	
NO_L_BOT:
	ret			; (10)

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
	;; On entry:
	;; 	BC is column to be filled
	;; ======================================================
DRAW_L_GAP:			; (~859)
	;; Move to correct display column
	ld hl, BUFFER		; (10)
	add hl,bc		; (11)

	push hl			; Save for later (11)

	;; Work out height of wall at specific column
	ld hl, DISTWALL 	; (10)
	add hl,bc		; (11)
	ld a,(hl)		; (7)

	;; Retrieve display pointer
	pop hl			; (10)
	ld de, 0x0020		; (10)
	
	ld c,a			; (4)
	
	and a			; (4)

	jr z, L_GAP		; (12/7)
	ld b,a			; (4)

TOP_L_GAP:
	mfill _SPACE		; (2+31*B)

	;; Print 20-2*col wall graphics
L_GAP:	
	ld b,c			; (4)
	sla b			; (4)
	ld a, 20		; (7)
	sub b			; (4)
	and a			; (4)
	jr nz, L_FACE_LOOP	; (12/7)

	sbc hl,de		; (15)
	ld (hl),2		; (10)
	add hl,de		; (11)
	ld (hl),3		; (10)
	add hl,de		; (11)
	dec c			; (4)
	jr NO_L_GAP		; (12)
	
L_FACE_LOOP:
	ld b,a			; (4)

	mfill _CHEQUERBOARD	; (2+31*B)

NO_L_GAP:
	ld a,c			; (4)
	and a			; (4)
	ret z 			; Done, if no space at bottom (12/7)

BOT_L_GAP:
	ld b,c			; (4)
	mfill _SPACE		; (2+31*B)
	
NO_L_B_GAP:			; (10)
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
	dec c
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
	;; Draw lefthand wall segment.
	;; 
	;; On entry:
	;; 	A = flag to print wall/ gap
	;; 	DE = distance from player
	;;
	;; On exit:
	;; 
	;; ======================================================
DRAWLSEG:			;  (~130 + 820*SEG)
	push af			; (11)
	ld hl, DISTCOL		; Retrieve column info (10)
	add hl, de		; (11)

	ld c,(hl)		; Retrieve starting column (7)
	inc hl			; (6)
	ld a, (hl)		; Retrieve one more than final column (7)

	sub c			; Work out number of columns to print (4)
	ld b,a			; and move to loop counter (4)

DLS_LOOP:
	pop af			; Retrieve flag (10)
	push af			; (11)

	push bc			; Save loop counter (11)
	ld b,0x00		; (7)

	and a			; Check if wall or gap (4)
	jr z, DLS_GAP		; (12/7)
	call DRAW_L_WALL	; (17 + 779)
	jr DLS_CONT		; (12)
	
DLS_GAP:	
	call DRAW_L_GAP		; (17 + 859)

DLS_CONT:
	pop bc			; Retrieve loop counter and col (10)
	inc c			; Move to next column (4)

	djnz DLS_LOOP		; (13/8)
	
	pop af			; Balance stack (10)

	ret			; (10)
	;; jp (iy)			; Done
	
	;; ======================================================
	;; Draw righthand wall segment.
	;; 
	;; On entry:
	;; 	A = flag to print wall/ gap
	;; 	DE = distance from player
	;;
	;; On exit:
	;; 
	;; ======================================================
DRAWRSEG:
	push af
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
	ret
	;; jp (iy)			; Done


	;; ======================================================
	;; Draw end-wall section.
	;;
	;; On entry:
	;; 	DE - Distance to player
	;;
	;; On exit:
	;; 	AF, BC, DE, HL - corrupted
	;; ======================================================
DRAWEWALL:
	;; Check if maximum distance (which is 6)
	ld a,e
	cp 0x06
	jr c, DE_CONT

	ld hl, BUFFER+298
	ld (hl), _TOPWHITEBOTTOMCHEQUER
	ld hl, BUFFER+330
	ld (hl), _TOPCHEQUERBOTTOMWHITE

	ret
	
DE_CONT:
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
	ret
	

	;; ======================================================
	;; Move position
	;;
	;; On entry:
	;; 	A - direction
	;; 	D - current row
	;; 	E - current col
	;;
	;; On exit:
	;; 	A = direction
	;; 	D = new row
	;; 	E = new col
	;; 	B corrupted
	;; ======================================================
MOVE:	; (59/53)
	ld b,a 			; Save direction (4)

	;; Check if east-west
	and %00000001		; Z false, if so (7)

	ld a,b			; Restore direction (4)

	jr z, MOVE_NS		; (12/7)
MOVE_EW:
	sub 2			; A = -1 for E, 1 for W (7)
	sub e			; Apply to column counter (4)
	cpl			; (4)
	inc a			; (4)
	
	ld e,a			; Save new column value (4)
	
	ld a,b			; Restore direction (4)
	ret			; Done (10)

MOVE_NS:
	dec a			; (4)
	add d			; (4)

	ld d,a			; (4)
	
	ld a,b			; (4)
	ret			; (10)

	;; ======================================================
	;; Retrieve maze address corresponding to coordinate in
	;; DE
	;;
	;; On entry:
	;; 	D = row
	;;      E = col
	;; 
	;; On exit:
	;; 	HL = address
	;; 	D = row
	;;      E = col
	;;      A, B corrupted
	;; ======================================================
MAZE_ADDR:			; (106+B*23 => 336)
	ld hl, MAZE		; (10)
	
	ld b,d			; B = row number (4)
	inc b			; Do one extra, to avoid zero loop (4)

	push de			; Save coordinates (11)
	ld de, _MAZEW		; DE = one-row offset (10)

MA_LOOP:
	add hl,de		; (10)
	djnz MA_LOOP		; (13/8)

	;; Correct for extra row
	and a			; (4)
	sbc hl,de		; (10)

	pop de			; Retrieve coordinates (10)
	push de			; (11)

	ld d,0			; (7)
	add hl, de		; (10)

	pop de			; Restore coordinates (10)

	ret			; (10)
	
	;; ======================================================
	;; Draw view
	;;
	;; On entry:
	;; 	TOS - Direction
	;;      2OS - Column
	;; 	3OS - Row
	;; ======================================================
DRAWVIEW:	
	;; Set exit to not visible (indicated by -1)
	ld hl, EXITVIS
	ld (hl), 0xFF
	inc hl
	ld (hl), 0xFF
	
	;; Retrieve coordinates and direction
	rst 0x18		; Retrieve direction into DE
	ld a,e			; Move to A
	push af			; ... and save

	rst 0x18		; Retrieve column value

	ld l,e			; Move to L
	push hl			; ... and save it

	rst 0x18		; Retrieve row value

	pop hl			; Restore column value
	ld h,e			; Incorporate row value
	ex de,hl
	
	pop af			; Restore direction
		
	;; Start from distance 0
	ld b, 0x00
	
	;; Get cell to left
VIEW_LOOP:
	push af			; Save direction and location (11)
	push de			; Save location               (11)
	push bc			; Saver distance counter      (11)
	
	add a, 0x03		; Turn left (7)
	and %00000011		; (7)
	
	call MOVE		; (17 + 59/53)
	call MAZE_ADDR		; (17 + 336)
	ld a,(hl)		; Retrieve cell value (7)
	
	;; Draw wall or gap
	and _WALL 		; (7)
	pop bc			; (10)
	push bc			; (10)
	
	ld d,0			; (7)
	ld e,b			; (4)

	call DRAWLSEG		; (17 + 130+N*820)

	;; Get cell to right
	pop bc			; (10)
	pop de			; (10)
	pop af			; (10)
	push af			; (11)
	push de			; (11)
	push bc			; (11)

	inc a			; Turn right (4)
	and %00000011		; (7)

	call MOVE		; (17)
	call MAZE_ADDR		; (17)
	ld a,(hl)		; Retrieve cell value (7)

	;; Draw wall or gap
	and _WALL		; (7)
	pop bc			; (10)
	push bc			; (11)
	
	ld d,0			; (7)
	ld e,b			; (4)

	call DRAWRSEG		; (17  + 130+N*820)
FORWARD:	
	;; Move forward
	pop bc			; (10)
	pop de			; (10)
	pop af			; (10)
	push af			; (11)

	inc b			; (4)
	push bc			; (11)
	call MOVE		; (17)
	call MAZE_ADDR		; (17)
	pop bc			; (10)
	
	;; Check for exit
	ld a,(hl)		; (7)
	cp _EXIT		; (7)
	jr NZ, WALL_CHECK	; (true = 12)

	ld hl, EXITVIS		
	ld (hl),b
	inc hl
	ld (hl),0x00

;;;  	call WAITB		; Introduce delay to slow code for shallow views
	
	pop af			; Balance stack

	jr WALL_DONE		; Done
	
	;; Check for wall (special case for distance 6)
WALL_CHECK:
	cp _WALL		; (7)
	jr nz, NEXT_STEP	; (true = 12)

	;; Transfer current distance to DE
	ld e,b
	ld d,0x00
	
	push bc
	call DRAWEWALL
	pop bc
	
 	call WAITB		; Introduce delay to slow code for shallow views
	
	pop af			; Balance stack
	
	jr WALL_DONE

	;; Check if done
NEXT_STEP:
	pop hl 			; Dirn is temporarily in H (10)

	ld a,b			; (4)
	cp 0x06			; Check if reached maximum distance (7)
	jr z, VIEW_DONE		; (7)

	ld a,h			; Restore distance (4)
	jr VIEW_LOOP		; (12)
	
VIEW_DONE:
	;; Draw horizon at distance 6
	ld hl, BUFFER+298
	ld (hl), _BOTTOMBLACK
	ld hl, BUFFER+330
	ld (hl), _TOPBLACK

WALL_DONE:
	jp (iy)

	
WAIT_NO_DRAW:
	ld b,54
	call WAIT4000
	jp (iy)

WAITB:
	ld a,7			; Work out 7-b
	sub b
	ld b,a
WAIT4000:	
	ld de,80
WAIT_LOOP:
	dec de			; (6)
	ld a,d			; (4)
	or e			; (4)
	jr nz, WAIT_LOOP	; (12/7)
	djnz WAIT4000
	
	ret
	
	
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
	and %00000010
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

	;; Clear buffer and apply template text
	;; ( TEMPLATE -- )
FRAME_CLEAR:
	ld hl, BUFFER + 0x02bf
	ld a, _SPACE		; Space character
	ld (hl),a
	ld de, BUFFER + 0x02be
	ld bc, 0x02bf
	lddr

	rst 0x18		; Retrieve template code to DE

	;;  HL = MESSAGE_TABLE + 2*DE
	ld hl, FC_MESSAGE_TABLE
	add hl, de
	add hl, de

	;; Retrieve address into HL
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de, hl

	;; Retrieve offset
FC_NEWLINE:
	ld c, (hl)
	inc hl
	ld b,(hl)
	inc hl

	;; Check for -1 (i.e., end of message)
	inc bc
	ld a,b
	or c

	jr z, FC_DONE
	dec bc

	;; Work out offset into BUFFER and store in DE
	;; Preserve HL also
	ld de,BUFFER
	ex de,hl
	add hl,bc
	ex de,hl 
	
FC_LOOP:
	ld a,(hl)
	inc hl
	cp 0x0D			; Check for end of message
	jr z, FC_NEWLINE
	ld (de),a
	inc de
	jr FC_LOOP

FC_DONE:
	jp (iy)

FC_MESSAGE_TABLE:
	dw FC_MESS_1
	dw FC_MESS_2
	dw FC_MESS_3

FC_MESS_1:
	dw 0xffff 		; No message

FC_MESS_2:
	dw 10*32+22
	db "SCORE", 0x0d
	dw 0xffff

FC_MESS_3:
	dw 1*32+22
	db "YOU HAVE", 0x0d
	dw 2*32+22
	db "ELUDED", 0x0d
	dw 3*32+22
	db "HIM AND", 0x0d
	dw 4*32+22
	db "SCORED", 0x0d
	dw 6*32+22
	db "POINTS", 0x0d
	dw 8*32+22
	db "REX IS", 0x0d
	dw 9*32+22
	db "VERY", 0x0d
	dw 10*32+22
	db "ANGRY", 0x0d
	dw 12*32+22
	db "YOU'LL", 0x0d
	dw 13*32+22
	db "NEED MORE", 0x0d
	dw 14*32+22
	db "LUCK THIS", 0x0d
	dw 15*32+22
	db "TIME", 0x0d
	dw 0xffff

	;; Update display with contents of buffer
	;; ( -- )
FRAME_UPDATE:
	ld hl, BUFFER
	ld de, 0x2400		; Start of display buffer
	ld bc, 0x02c0
	ldir
	jp (iy)

	;; Copy current screen into buffer
	;; ( TEMPLATE -- )
FRAME_GRAB:
	ld hl, 0x2400
	ld de, BUFFER
	ld bc, 0x02c0
	ldir
	jp (iy)
	
	;; ======================================================
	;; FTYPE - transcribe text from pad into buffer
	;;
	;; On entry:
	;; 	TOS - Offset into buffer
	;;      2OS - Length of text
	;; 	3OS - Address of text
	;; ======================================================
FTYPE:
	;;  Work out offset into buffer
	rst 0x18		; Retrieve offset into DE
	ld hl, BUFFER		
	add hl, de		; Add offset to start of buffer

	push hl			; Save offset

	call 0x084e		; Retrieve length into BC
	rst 0x18		; Retrieve start address into DE

	pop hl			; Retrieve buffer offset

FT_LOOP:
	ld a,b			; Check if any characters still to print
	or c
	jr z, FT_DONE

	ld a,(de)		; Retrieve next character
	inc de			; Advance message pointer
	dec bc			; Decrement character count
	ld (hl),a		; Write character to BUFFER location
	inc hl			; Move to next location

	jr FT_LOOP		; Repeat
	
FT_DONE:
	jp (iy)			; Return to FORTH
	
TEST:
	;;  Retrieve direction
	rst 0x18
	ld a,e

	;; Retrieve column
	rst 0x18
	ld l,e

	;; Save it and retrieve row
	push hl
	rst 0x18
	pop hl

	ld h,e

	;; Move row and col to DE
	ex de,hl

	call MOVE

	;; Push coordinates back onto stack
	push af
	
	rst 0x10

	pop af

	;; Push direction back onto stack
	ld e,a
	ld d,0
	rst 0x10
	
	jp (iy)
END:	

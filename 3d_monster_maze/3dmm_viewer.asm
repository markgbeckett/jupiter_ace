	;; Render a wall/ no-wall section
	;;
	;; On entry, stack contains ...
BUFFER:		equ 0x2400
STACK_TO_BC:	equ 0x084e
	
	org 0x499d

mfill:	macro char

	ld a, char
	ld (hl),a
	add hl,de
	db 0x10, 0xfc 		; djnz -4
	
	endm

	;; ======================================================
	;; Fill in one column of wall on left of view 
	;; On entry, TOS contains column number
	;; ======================================================
DRAW_L_WALL:	
	;; Move to correct display column
	ld hl, BUFFER
	add hl, bc

	ld de, 0x0020		; Displacement to next display row
		
	ld b,c			; Move column number into b, so can
				; use with DJNZ (c is backup)
	
	;;  Check if spaces needed at top
	ld a,b
	and a
	jr z, NO_L_TOP

	;; Fill on spaces
L_TOP:	mfill 32

	;; Print sloping wall 
NO_L_TOP:
	ld (hl), 145
	add hl, de

	;; Print mid-section, if any
L_MIDDLE:
	ld b,c
	
	;; Work out a = 18-2b
	sla b
	ld a, 18
	sub b

	and a
	jr z, NO_L_MID

	ld b,a			; B contains number of wall
				; sections to print
	
L_MID:	mfill 144

	;; Print lower diagonal wall section
NO_L_MID:
	ld (hl),140
	add hl, de

	ld a,c
	and a

	jr z, NO_L_BOT

L_BOTTOM:
	ld b,c
	mfill 32
	
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
	ld c,a
	
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
	ld (hl), 146
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
	
R_MID:	mfill 144

	;; Print lower diagonal wall section
NO_R_MID:
	ld (hl),23
	add hl, de

	ld a,c
	and a

	jr z, NO_R_BOT

R_BOTTOM:
	ld b,c
	mfill 32
	
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

	;; Work out height of wall
	ld hl, DISTWALL
	add hl,bc
	ld a,(hl)

	;; Retrieve display pointer
	pop hl
	ld de, 0x0020
	
	ld b,a
	ld c,a
	
	and a
	jr z, L_GAP

TOP_L_GAP:
	mfill 32
	
L_GAP:	
	ld b,c
	sla b
	ld a, 20
	sub b
	and a
	jr z, NO_L_GAP

L_FACE_LOOP:
	ld b,a

	mfill 1

NO_L_GAP:
	ld a,c
	and a
	jr z, NO_L_B_GAP

BOT_L_GAP:
	ld b,c
	mfill 32
	
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
	ld c,a
	
	ld hl, BUFFER
	add hl, bc

	;; Retrieve column and copy into b
	pop bc

	;; Work out height of wall
	push hl			; Save for later
	ld hl, DISTWALL
	add hl,bc
	ld a,(hl)

	;; Retrieve display pointer
	pop hl
	ld de, 0x0020
	
	ld b,a
	ld c,a
	
	and a
	jr z, R_GAP

TOP_R_GAP:
	mfill 32
	
R_GAP:	
	ld b,c
	sla b
	ld a, 20
	sub b
	and a
	jr z, NO_R_GAP

R_FACE_LOOP:
	ld b,a

	mfill 1

NO_R_GAP:
	ld a,c
	and a
	jr z, NO_R_B_GAP

BOT_R_GAP:
	ld b,c
	mfill 32
	
NO_R_B_GAP:
	ret


	;; Draw lefthand wall segment. On entry, TOS is a flag
	;; (1=wall, 0=gap), 2OS is distance
	;;
DRAWLSEG:
	rst 0x18		; Retrieve Flag

	ld a,e			; Save flag 
	push af

	rst 0x18		; Retrieve distance

	ld hl, DISTCOL		; Retrieve column info
	add hl, de

	ld c,(hl)		; Retrieve starting column
	inc hl
	ld a, (hl)		; Retrieve finishing column

	sub c			; Work out number of columns to print
	ld b,a			; and move to loop counter

DLS_LOOP:
	pop af			; Retrieve flag
	push af

	push bc			; Save loop counter
	ld b,0x00

	and a			; Check if wall of gap

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
	
	;; Draw righthand wall segment. On entry, TOS is a flag
	;; (1=wall, 0=gap), 2OS is distance
	;;
DRAWRSEG:
	rst 0x18		; Retrieve Flag

	ld a,e			; Save flag 
	push af

	rst 0x18		; Retrieve distance

	ld hl, DISTCOL		; Retrieve column info
	add hl, de

	ld c,(hl)		; Retrieve starting column
	inc hl
	ld a, (hl)		; Retrieve finishing column

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


DISTWALL:
	 db 1, 4, 4, 4, 6, 6, 8, 8, 9, 9                                                                                
DISTCOL:
	db 0, 1, 4, 6, 8, 9, 10

END:	


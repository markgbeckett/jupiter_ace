	org $5580

CHECKFIRE:
	push af
	push bc

	;; Check for input mode
	ld a, $BF
	in a,($FE)
	ld b,a
	and %00001000		; 'H'
	jr nz, CHF_CONT
	dec a
	ld (USE_JOYSTICK),a

CHF_CONT:	
	ld a,b
	and %00000100		; 'K'
	jr nz, CHF_CONT_2
	ld (USE_JOYSTICK),a
	
CHF_CONT_2:
	;; Check if bullet in-flight
	ld bc,($3F90)
	ld a,b
	or c
	jp nz, $3F48

	;; Check if joystick is enabled
	ld a,(USE_JOYSTICK)
	and a
	jr nz, CHF_JOY
	
	;; Check for keyboard fire 'A'
	ld a,($FD)
	in a,($FE)
	and %00000001
	jp z, $3F3F
	jr CHF_DONE
	
	;; Check for joystick fire
CHF_JOY:
	xor a
	in a,($01)
	and %00100000
	jp nz, $3F3F

	;; No fire, so done
CHF_DONE:	
	pop bc
	pop af

	ret

CHECK_DIRN:
	push af

	;; Check if joystick is enabled
	ld a,(USE_JOYSTICK)
	and a
	jr nz, CHD_J_UP
	
	;; Check directions
	ld a, $DF
	in a,($FE)
	and %00000100		; 'I' - UP
	jr nz, CHD_K_RIGHT
	ld a,b
	cp $10
	jr z, CHD_K_RIGHT
	dec b
	call $3D18
	and a
	jr z, CHD_K_RIGHT
	cp $07
	jp nc, $4540
	inc b
	nop
	nop

CHD_K_RIGHT:	
	ld a,$BF
	in a,($FE)
	and %00000010		; 'L' - RIGHT
	jr nz, CHD_K_LEFT
	ld a,c
	cp $1F
	jr z, CHD_K_LEFT
	inc c
	call $3D18
	and a
	jr z, CHD_K_LEFT
	cp $05
	jp nc, $4540
	dec c
	nop
	nop
	nop

CHD_K_LEFT:	
	ld a,$BF
	in a,($FE)
	and %00001000
	jr nz, CHD_K_DOWN
	ld a,c
	cp $00
	jr z, CHD_K_DOWN
	dec c
	call $3D18
	and a
	jr z, CHD_K_DOWN
	cp $05
	jp nc, $4540
	inc c
	nop
	nop
	nop

CHD_K_DOWN:
	ld a,($7F)
	in a, ($FE)
	and %00000010
	jr nz, CHD_DONE
	ld a,b
	cp $16
	jr z, CHD_DONE
	inc b
	call $3D18
	and a
	jr z, CHD_DONE
	cp $05
	jp nc, $4540 		; $3E58
	dec b

	jr CHD_DONE
	
	;; Check directions (joystick version)
CHD_J_UP:
	xor a
	in a,($01)
	and %00000001		; 'I' - UP
	jr z, CHD_J_RIGHT
	ld a,b
	cp $10
	jr z, CHD_J_RIGHT
	dec b
	call $3D18
	and a
	jr z, CHD_J_RIGHT
	cp $07
	jp nc, $4540
	inc b

CHD_J_RIGHT:	
	xor a
	in a,($01)
	and %00000100		; 'L' - RIGHT
	jr z, CHD_J_LEFT
	ld a,c
	cp $1F
	jr z, CHD_J_LEFT
	inc c
	call $3D18
	and a
	jr z, CHD_J_LEFT
	cp $05
	jp nc, $4540
	dec c

CHD_J_LEFT:	
	xor a
	in a,($01)
	and %00001000
	jr z, CHD_J_DOWN
	ld a,c
	cp $00
	jr z, CHD_J_DOWN
	dec c
	call $3D18
	and a
	jr z, CHD_J_DOWN
	cp $05
	jp nc, $4540
	inc c

CHD_J_DOWN:
	xor a
	in a, ($01)
	and %00000010
	jr z, CHD_DONE
	ld a,b
	cp $16
	jr z, CHD_DONE
	inc b
	call $3D18
	and a
	jr z, CHD_DONE
	cp $05
	jp nc, $4540 		; $3E58
	dec b

CHD_DONE:
	pop af
	
	ret


USE_JOYSTICK:	db 0x00

END:	

	

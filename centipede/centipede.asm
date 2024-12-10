; z80dasm 1.1.6
; command line: z80dasm -g 15452 -a -l -o centipede.asm centipede.bin

	;; Register mappings for AY-3-8910/ AY-3-8912 card
AY_TONE_1:	equ 0x00
AY_TONE_2:	equ 0x02
AY_TONE_3:	equ 0x04
AY_NOISE_FREQ:	equ 0x06
AY_MIXER:	equ 0x07
AY_VOL_1:	equ 0x08
AY_VOL_2:	equ 0x09
AY_ENV_P:	equ 0x0B
AY_ENV_SH:	equ 0x0D

AY_MIN_VOL:	equ 0x00	; Minimum volume for sound card
AY_MAX_VOL:	equ 0x0F	; Maximum volume for sound card
AY_MAX_CHANNEL:	equ 0x03	; Three channels
	
AY_REG_PORT:	equ 0fdh
AY_DAT_PORT:	equ 0ffh

DISPLAY:	equ 0x2400	; Start of display buffer
FRAMES:		equ 0x3C2B
	
	org	03c5ch

START:	nop			;3c5c
	nop			;3c5d
	nop			;3c5e
	nop			;3c5f

	;; Entry point for game
	call sub_4188h		;3c60 - Save IX, IY, and SP to enable
				;       return to Forth
	call sub_41b0h		;3c63 - Initialise buffer at 4180h
	call sub_3d90h		;3c66 - Initialise game screen
	call sub_4288h		;3c69 - Initialise centipede store and
				;       display it
	call sub_46e8h		;3c6c - Zero some variables
	nop			;3c6f
	nop			;3c70
	nop			;3c71
	nop			;3c72
	nop			;3c73
	nop			;3c74
	nop			;3c75
	nop			;3c76
	nop			;3c77
l3c78h:
	call sub_3ca8h		;3c78 - Initialise sound card
	nop			;3c7b
	nop			;3c7c
	nop			;3c7d
	nop			;3c7e
	nop			;3c7f

	;; Main game loop
l3c80h:	call 041c8h		;3c80 - Does nothing
	call sub_3ee0h		;3c83 - Play sound
	call sub_3f28h		;3c86 - Check for fire
	call sub_3ee0h		;3c89 - Play sound
	call sub_3f28h		;3c8c - Check for fire
	call sub_3ef0h		;3c8f - Check for keyboard directions
	call sub_44e8h		;3c92 - Check centipede
	call sub_46f8h		;3c95 - Move centipede?
	jp l3c80h		;3c98 - Jump back to start
	nop			;3c9b
	nop			;3c9c
	nop			;3c9d
	nop			;3c9e
	nop			;3c9f
	nop			;3ca0
	nop			;3ca1
	nop			;3ca2
	nop			;3ca3
	nop			;3ca4
	nop			;3ca5
	nop			;3ca6
	nop			;3ca7

	;; Initialise AY sound card
sub_3ca8h:
	call WRITE_TO_AY	;3ca8 - Set mixer
	db AY_MIXER, %00110101  ; Channel A noise; Channel B sound;
				; Channel C off
	call WRITE_TO_AY	;3cad - Set Channel A vol to wave pattern
	db AY_VOL_1, $10
	call WRITE_TO_AY	; Set Envelope period (high byte)
	db AY_ENV_P+1, $08
	call WRITE_TO_AY	;3cb7 - Set noise period
	db AY_NOISE_FREQ, $04
	call WRITE_TO_AY	;3cbc - Set Channel B vol to 0
	db AY_VOL_2, $00

	ret			;3cc1

	nop			;3cc2
	nop			;3cc3
	nop			;3cc4
	nop			;3cc5
	nop			;3cc6
	nop			;3cc7
	nop			;3cc8
	nop			;3cc9
	nop			;3cca
	nop			;3ccb
	nop			;3ccc
	nop			;3ccd
	nop			;3cce
	nop			;3ccf
	nop			;3cd0
	nop			;3cd1
	nop			;3cd2
	nop			;3cd3
	nop			;3cd4
	nop			;3cd5
	nop			;3cd6
	nop			;3cd7
	nop			;3cd8
	nop			;3cd9
	nop			;3cda
	nop			;3cdb
	nop			;3cdc
	nop			;3cdd
	nop			;3cde
	nop			;3cdf
	nop			;3ce0
	nop			;3ce1
	nop			;3ce2
	nop			;3ce3
	nop			;3ce4
	nop			;3ce5
	nop			;3ce6
	nop			;3ce7
	nop			;3ce8
	nop			;3ce9
	nop			;3cea
	nop			;3ceb
	nop			;3cec
	nop			;3ced
	nop			;3cee
	nop			;3cef


	;; Update AY register
	;; 
	;; On entry:
	;; - Address at TOS points to register number and value
	;;
	;; On exit:
	;; - Return address advanced two bytes
	;; - All registers preserved
WRITE_TO_AY:
	ex (sp),hl		;3cf0 - Retrieve address from top of stack

	push af			;3cf1 
	ld a,(hl)		;3cf2 - Retrieve register number
	inc hl			;3cf3 - Advance to next byte
	out (AY_REG_PORT),a	;3cf4 - Select it
	ld a,(hl)		;3cf6 - Retrieve data
	inc hl			;3cf7 - Advance to return address
	out (AY_DAT_PORT),a	;3cf8 - Update register

	pop af			;3cfa
	ex (sp),hl		;3cfb - Restore HL and push return address
	
	ret			;3cfc

	nop			;3cfd
	nop			;3cfe
	nop			;3cff

	;; Store character in A at screen location B,C
sub_3d00h:
	push hl			;3d00
	push bc			;3d01
	ld hl,02400h		;3d02
	srl b			;3d05
	rr l			;3d07
	srl b			;3d09
	rr l			;3d0b
	srl b			;3d0d
	rr l			;3d0f
	add hl,bc		;3d11
	ld (hl),a		;3d12
	pop bc			;3d13
	pop hl			;3d14
	ret			;3d15
	nop			;3d16
	nop			;3d17


	;; Retrieve character at screen location B,C
sub_3d18h:
	push hl			;3d18
	push bc			;3d19
	ld hl,02400h		;3d1a
	srl b		;3d1d
	rr l		;3d1f
	srl b		;3d21
	rr l		;3d23
	srl b		;3d25
	rr l		;3d27
	add hl,bc			;3d29
	ld a,(hl)			;3d2a
	pop bc			;3d2b
	pop hl			;3d2c
	ret			;3d2d
	nop			;3d2e
	nop			;3d2f

	;; Generate random number
	;; 
	;; On entry:
	;;
	;; On exit:
	;;   A - random number
sub_3d30h:
	push hl			;3d30
	ld a,(l3d3fh)		;3d31
	rlc a			;3d34
	ld l,a			;3d36
	ld a,r			;3d37 - Random number ?
l3d39h:
	add a,l			;3d39
	ld (l3d3fh),a		;3d3a
	pop hl			;3d3d

	ret			;3d3e

l3d3fh:	db %10001011		;3d3f - Seed for random-number generator

	;; Play sound using built-in speaker
	;;
	;; On entry:
	;;   Five sound parameters are stored immediately after call
	;;     Param 0 - Tone 
	;;     Param 1 - Tone increment
	;;     Param 2 - Duration (combined with Param 0)
	;;     Param 3 - Not used
	;;     Param 4 - Tone limit
	;;
	;; Operation of the Ace beeper is described (briefly) at
	;; https://k1.spdns.de/Vintage/Sinclair/80/Jupiter%20Ace/ROMs/io.txt
PLAY_BEEPER:
	ex (sp),ix		;3d40 - Retrieve return address

	push af			;3d42 - Preserve registers
	push bc			;3d43
	push de			;3d44

	ld d,(ix+000h)		;3d45 - Tone (wavelength)
	ld e,(ix+002h)		;3d48 - Duration

l3d4bh:	ld c,e			;3d4b

l3d4ch:	ld b,d			;3d4c - Pause appropriate time to create
l3d4dh:	djnz l3d4dh		;3d4d   tone

	ld a,b			;3d4f - Will always be zero
	out (0feh),a		;3d50 - Push loud-speaker diaphram out

	ld b,d			;3d52 - Pause appropriate time to create
l3d53h:	djnz l3d53h		;3d53   tone

	ld a,07fh		;3d55
	out (0feh),a		;3d57 - Push loud-speaker diaphram out

	in a,(0feh)		;3d59 - Push loud-speaker diaphram in
				;and read bottom-left keyboard half row
				;(V, B, N, M, Space)

	;; Check for space
	rra			;3d5b
	jr c,l3d64h		;3d5c - Skip ahead if not pressed
	nop			;3d5e
	nop			;3d5f
	nop			;3d60
	nop			;3d61
	nop			;3d62
	nop			;3d63
l3d64h:	dec e			;3d64 - Decrement duration
	jp nz,l3d4ch		;3d65

	ld a,e			;3d68 - Will always be zero
	add a,(ix+002h)		;3d69  
	ld e,a			;3d6c - Effectively, e is duration again

	ld a,d			;3d6d - Update tone
	add a,(ix+001h)		;3d6e
	ld d,a			;3d71

	cp (ix+004h)		;3d72 - Check if reached limit and
	jp nz,l3d4bh		;3d75 - repeat if not

	;; Retrueve registers
	pop de			;3d78
	pop bc			;3d79
	pop af			;3d7a

	;; Balance stack for return
	inc ix		;3d7b
	inc ix		;3d7d
	inc ix		;3d7f
	inc ix		;3d81
	inc ix		;3d83

	ex (sp),ix	;3d85 - Restore IX

	ret		;3d87


	nop		;3d88
	nop		;3d89
	nop		;3d8a
	nop		;3d8b
	nop		;3d8c
	nop		;3d8d
	nop		;3d8e
	nop		;3d8f

	;; Initialisation routine #3 - Initialie game screen
sub_3d90h:
	call sub_3de0h		;3d90 - Set up graphics

	;; Clear row 17h of the display
	ld hl,DISPLAY+17h*20h-01h	;3d93 - Address 26DF = end of row 17
l3d96h:	ld (hl),000h		;3d96
	dec hl			;3d98
	ld a,l			;3d99
	cp 0bfh			;3d9a
	jr nz,l3d96h		;3d9c

	;; Randomly distribute mushrooms
l3d9eh:	call sub_3d30h		;3d9e
	and 00fh		;3da1
	jr nz,l3da9h		;3da3
	ld (hl),004h		;3da5 - Plot mushroom
	jr l3dabh		;3da7
l3da9h:
	ld (hl),000h		;3da9 - Plot space
l3dabh:
	dec hl			;3dab

	;; Check if done (top-left of screen is HL=2400h)
	ld a,h			;3dac
	cp 023h			;3dad 
	jr nz,l3d9eh		;3daf - Repeat if not

	ld bc,00020h		;3db1
	ld de,02400h		;3db4
	ld hl,l3dc0h		;3db7
	ldir		;3dba

	call sub_3f18h		;3dbc

	ret			;3dbf

	;; Top line of game screen
l3dc0h: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04 ; Score
	db 0x00
l3dc9h:	db 0x05, 0x05		; Lives
	db 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00
l3dd4h:	db 0x41, 0x41, 0x41 	; Name of high-scoring player
	db 0x00
l3dd8h: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	;; Set up graphics
sub_3de0h:
	ld bc,00058h		;3de0 - 11 characters
	ld de,02c08h		;3de3 - Character 1
	ld hl,l3df0h		;3de6 - 
	ldir		;3de9
	ret			;3deb
	nop			;3dec
	nop			;3ded
	nop			;3dee
	nop			;3def

	;; Graphics characters (extends as far as 3E48h)
l3df0h:	nop			;3df0 - Quarter mushroom
	ld a,h			;3df1
	jp nz,0122ah		;3df2
	nop			;3df5
	nop			;3df6
	nop			;3df7
	nop			;3df8 - Half mushroom
	ld a,h			;3df9
	add a,d			;3dfa
	add a,d			;3dfb
	xor d			;3dfc
	djnz l3dffh		;3dfd
l3dffh:	nop			;3dff
	nop			;3e00 - Three-quarter mushroom
	ld a,h			;3e01
	add a,d			;3e02
	add a,d			;3e03
	add a,0aah		;3e04
	jr nc,l3e28h		;3e06
	nop			;3e08 - Full mushroom
	ld a,h			;3e09
	add a,d			;3e0a
	add a,d			;3e0b
	add a,0aah		;3e0c
	jr z,l3e48h		;3e0e
	djnz l3e22h		;3e10 - Space ship
	jr c,$+86		;3e12
	sub 0feh		;3e14
	ld a,h			;3e16
	jr c,l3e29h		;3e17
	db $10			;3198 - Laser
	db $10			;3e19
	djnz $+18		;3e1b
	djnz l3e2fh		;3e1d
	db $10			;3e1f
	db $3c			;3e20 - Centipede body
	ld a,(hl)		;3e21
l3e22h:
	sbc a,c			;3e22
	sbc a,c			;3e23
	sbc a,c			;3e24
	rst 38h			;3e25
	ld b,d			;3e26
	inc h			;3e27

l3e28h:	inc a			;3e28 - Centipede head

l3e29h:	ld b,d			;3e29
	cp l			;3e2a

l3e2bh:	cp l			;3e2b
	jp l42ffh		;3e2c

l3e2fh:	inc h			;3e2f
	inc h			;3e30 - Explosion ?
	ld d,d			;3e31
	adc a,d			;3e32
	and a			;3e33
	ld d,l			;3e34
	adc a,l			;3e35
	add a,a			;3e36
	inc bc			;3e37
	inc h			;3e38 - ?
	ld c,d			;3e39
	ld d,c			;3e3a
	push hl			;3e3b
	ld l,d			;3e3c
	ld (hl),c		;3e3d
	pop hl			;3e3e
	ret nz			;3e3f
	inc e			;3e40 - Square
	ld a,04fh		;3e41
	adc a,a			;3e43
	rst 38h			;3e44
	ld d,d			;3e45
	sub d			;3e46
	ld c,c			;3e47

l3e48h:	nop			;3e48
	nop			;3e49
	nop			;3e4a
	nop			;3e4b
	nop			;3e4c
	nop			;3e4d
	nop			;3e4e
	nop			;3e4f
	nop			;3e50
	nop			;3e51
	nop			;3e52
	nop			;3e53
	nop			;3e54
	nop			;3e55
	nop			;3e56
	nop			;3e57
l3e58h:
	jp l4540h		;3e58
	nop			;3e5b
	nop			;3e5c
l3e5dh:
	nop			;3e5d
	nop			;3e5e
	nop			;3e5f
sub_3e60h:
	push af			;3e60
	ld a,0dfh		;3e61
	in a,(0feh)		;3e63
	bit 2,a		;3e65
	jp nz,l3e80h		;3e67
	ld a,b			;3e6a
	cp 010h		;3e6b
	jp z,l3e80h		;3e6d
	dec b			;3e70
	call sub_3d18h		;3e71
	and a			;3e74
	jp z,l3e80h		;3e75
	cp 007h		;3e78
	jp nc,l3e58h		;3e7a
	inc b			;3e7d
	nop			;3e7e
	nop			;3e7f
l3e80h:
	ld a,0bfh		;3e80
	in a,(0feh)		;3e82
	bit 1,a		;3e84
	jp nz,l3ea0h		;3e86
	ld a,c			;3e89
	cp 01fh		;3e8a
	jp z,l3ea0h		;3e8c
	inc c			;3e8f
	call sub_3d18h		;3e90
	and a			;3e93
	jp z,l3ea0h		;3e94
	cp 005h		;3e97
	jp nc,l3e58h		;3e99
	dec c			;3e9c
	nop			;3e9d
	nop			;3e9e
	nop			;3e9f
l3ea0h:
	ld a,0bfh		;3ea0
	in a,(0feh)		;3ea2
	bit 3,a		;3ea4
	jp nz,l3ec0h		;3ea6
	ld a,c			;3ea9
	cp 000h		;3eaa
	jp z,l3ec0h		;3eac
	dec c			;3eaf
	call sub_3d18h		;3eb0
	and a			;3eb3
	jp z,l3ec0h		;3eb4
	cp 005h		;3eb7
	jp nc,l3e58h		;3eb9
	inc c			;3ebc
	nop			;3ebd
	nop			;3ebe
	nop			;3ebf
l3ec0h:
	ld a,07fh		;3ec0
	in a,(0feh)		;3ec2
	bit 1,a		;3ec4
	jp nz,l3eddh		;3ec6
	ld a,b			;3ec9
	cp 016h		;3eca
	jp z,l3eddh		;3ecc
	inc b			;3ecf
	call sub_3d18h		;3ed0
	and a			;3ed3
	jp z,l3eddh		;3ed4
	cp 005h		;3ed7
	jp nc,l3e58h		;3ed9
	dec b			;3edc
l3eddh:
	pop af			;3edd
	ret			;3ede
	nop			;3edf

	;; Game routine #2 - Play sounds
sub_3ee0h:
	jp l4940h		;3ee0 - If flee active, make sound
l3ee3h:	jp l4a00h		;3ee3 - Otherwise, play game sound
	nop			;3ee6
	nop			;3ee7
	nop			;3ee8
	nop			;3ee9
	nop			;3eea
	nop			;3eeb
	nop			;3eec
sub_3eedh:
	nop			;3eed
	nop			;3eee
	nop			;3eef
sub_3ef0h:
	push af			;3ef0
	push bc			;3ef1
	ld bc,(l3f12h)		;3ef2
	call sub_3d18h		;3ef6
l3ef9h:
	cp 005h		;3ef9
	jp nz,l3e58h		;3efb
	ld a,000h		;3efe
	call sub_3d00h		;3f00
	call sub_3e60h		;3f03
	ld a,005h		;3f06
	call sub_3d00h		;3f08
	ld (l3f12h),bc		;3f0b
	pop bc			;3f0f
	pop af			;3f10
	ret			;3f11
l3f12h:
	dw $160B		; Parameter related to fire function
	nop			;3f14
	nop			;3f15
	nop			;3f16
	nop			;3f17
	
sub_3f18h:
	push bc			;3f18
	ld bc,0160fh		;3f19
	ld a,005h		;3f1c
	call sub_3d00h		;3f1e
	ld (l3f12h),bc		;3f21
	jp l4028h		;3f25

	;; Check for fire
sub_3f28h:
	push af			;3f28
	push bc			;3f29

	;; Check for in-flight bullet
	ld bc,(l3f90h)		;3f2a
	ld a,b			;3f2e
	or c			;3f2f
	jp nz,l3f48h		;3f30

	;; No in-flight bullet, so check if fire being pressed
	ld a,0fdh		;3f33
	in a,(0feh)		;3f35 - Read from port FDFEh (keys 'A',...'G')
	bit 0,a			;3f37 - Check if 'A' pressed
	jp z,l3f3fh		;3f39 - If so, fire laser

	;; Otherwise, done
	pop bc			;3f3c
	pop af			;3f3d
	ret			;3f3e

	;; Fire laser
l3f3fh:	ld bc,(l3f12h)		;3f3f
	dec b			;3f43
	jp l3f92h		;3f44
	nop			;3f47

l3f48h:	call sub_3d18h		;3f48
	cp 006h		;3f4b
	jp z,l3f60h		;3f4d 
	
l3f50h:
	ld a,006h		;3f50
	call sub_3d00h		;3f52
l3f55h:
	ld bc,00000h		;3f55
l3f58h:
	ld (l3f90h),bc		;3f58
	pop bc			;3f5c
	pop af			;3f5d
	ret			;3f5e
	nop			;3f5f

l3f60h:	ld a,000h		;3f60
	call sub_3d00h		;3f62
	dec b			;3f65
	jp z,l3f55h		;3f66

l3f69h:	call sub_3d18h		;3f69
	cp 000h		;3f6c
	jp nz,l3f79h		;3f6e
	ld a,006h		;3f71
	call sub_3d00h		;3f73
	jp l3f58h		;3f76
l3f79h:
	cp 005h		;3f79
	jp nc,l3f50h		;3f7b
	dec a			;3f7e
	jp nz,l3f8ah		;3f7f
	push hl			;3f82
	ld hl,00100h		;3f83
	call sub_3fc0h		;3f86
	pop hl			;3f89
l3f8ah:
	call sub_3d00h		;3f8a
	jp l3f55h		;3f8d

l3f90h:	dw 0x0513		; 3f90 - Bullet in flight

	;; Arrive her from fire laser (0x3F44)
l3f92h:	call sub_3f98h		;3f92
	jp l3f69h		;3f95

sub_3f98h:
	jp l4998h		;3f98
	nop			;3f9b
	nop			;3f9c
	nop			;3f9d
	nop			;3f9e
	nop			;3f9f

sub_3fa0h:
	call WRITE_TO_AY	;3fa0
	db AY_NOISE_FREQ, $1F

	call WRITE_TO_AY	;3fa5
	db AY_ENV_P+1, $04

	call WRITE_TO_AY		;3faa
	db AY_MIXER, %00111111

	call WRITE_TO_AY		;3faf
	db AY_ENV_SH, $04

	ret			;3fb4

	nop			;3fb5
	nop			;3fb6
	nop			;3fb7
l3fb8h:
	nop			;3fb8
	nop			;3fb9
l3fbah:
	ld e,b			;3fba
l3fbbh:
	inc sp			;3fbb
l3fbch:
	nop			;3fbc
l3fbdh:
	ex af,af'			;3fbd
	inc h			;3fbe
	nop			;3fbf
sub_3fc0h:
	push bc			;3fc0
	push de			;3fc1
	push hl			;3fc2
	push af			;3fc3
	ld de,l3fbbh		;3fc4
	ld a,(de)			;3fc7
	add a,h			;3fc8
	daa			;3fc9
	ld (de),a			;3fca
	dec de			;3fcb
	ld a,(de)			;3fcc
	adc a,l			;3fcd
	daa			;3fce
	ld (de),a			;3fcf
	call c,sub_4048h		;3fd0
	dec de			;3fd3
	ld a,(de)			;3fd4
	adc a,000h		;3fd5
	daa			;3fd7
	ld (de),a			;3fd8
	dec de			;3fd9
	ld a,(de)			;3fda
	adc a,000h		;3fdb
	daa			;3fdd
	ld (de),a			;3fde
	call sub_3fe8h		;3fdf
	pop af			;3fe2
	pop hl			;3fe3
	pop de			;3fe4
	pop bc			;3fe5
	ret			;3fe6
	nop			;3fe7
sub_3fe8h:
	ld hl,02780h		;3fe8
	ld de,l3fb8h		;3feb
	ld b,005h		;3fee
l3ff0h:
	ld a,(de)			;3ff0
	inc de			;3ff1
	push af			;3ff2
	ld (hl),a			;3ff3
	xor a			;3ff4
	rld		;3ff5
	add a,030h		;3ff7
	ld (hl),a			;3ff9
	inc hl			;3ffa
	pop af			;3ffb
	and 00fh		;3ffc
	add a,030h		;3ffe
	ld (hl),a			;4000
	inc hl			;4001
	djnz l3ff0h		;4002
	ld hl,02780h		;4004
l4007h:
	ld a,(hl)			;4007
	cp 030h		;4008
	jr nz,l4011h		;400a
	ld (hl),000h		;400c
	inc hl			;400e
	jr l4007h		;400f
l4011h:
	ld a,(02787h)		;4011
	and a			;4014
	jr nz,l401ch		;4015
	ld a,030h		;4017
	ld (02787h),a		;4019
l401ch:
	ld hl,02780h		;401c
	ld de,02400h		;401f
	ld bc,00008h		;4022
	ldir		;4025
	ret			;4027
l4028h:
	ld bc,00000h		;4028
	ld (l3f90h),bc		;402b
	ld (l3fb8h),bc		;402f
	ld (l3fbah),bc		;4033
	push af			;4037
	ld a,002h		;4038
	ld (l3fbch),a		;403a
	pop af			;403d
	ld bc,0240ah		;403e
	ld (l3fbdh),bc		;4041
	pop bc			;4045
	ret			;4046
	nop			;4047
sub_4048h:
	push hl			;4048
	push af			;4049
	ld a,(l3fbch)		;404a
	cp 00ah		;404d
	jr z,l405eh		;404f
	inc a			;4051
	ld (l3fbch),a		;4052
	ld hl,(l3fbdh)		;4055
	inc hl			;4058
	ld (hl),005h		;4059
	ld (l3fbdh),hl		;405b
l405eh:
	pop af			;405e
	pop hl			;405f
	ret			;4060
	nop			;4061
	nop			;4062
	nop			;4063
	nop			;4064
	nop			;4065
	nop			;4066
	nop			;4067
sub_4068h:
	ld a,b			;4068
	cp 017h		;4069
	ret nc			;406b
	ld a,c			;406c
	cp 020h		;406d
	ret nc			;406f
	call sub_3d18h		;4070
	xor 080h		;4073
	call sub_3d00h		;4075
	ret			;4078
	nop			;4079
	nop			;407a
	nop			;407b
	nop			;407c
	nop			;407d
	nop			;407e
	nop			;407f
sub_4080h:
	push bc			;4080
	ld a,c			;4081
	add a,l			;4082
	ld c,a			;4083
	call sub_4068h		;4084
	ld a,b			;4087
	sub l			;4088
	ld b,a			;4089
	call sub_4068h		;408a
	ld a,c			;408d
	sub l			;408e
	ld c,a			;408f
	call sub_4068h		;4090
	ld a,c			;4093
	sub l			;4094
	ld c,a			;4095
	call sub_4068h		;4096
	ld a,b			;4099
	add a,l			;409a
	ld b,a			;409b
	call sub_4068h		;409c
	ld a,b			;409f
	add a,l			;40a0
	ld b,a			;40a1
	call sub_4068h		;40a2
	ld a,c			;40a5
	add a,l			;40a6
	ld c,a			;40a7
	call sub_4068h		;40a8
	ld a,c			;40ab
	add a,l			;40ac
	ld c,a			;40ad
	call sub_4068h		;40ae
	pop bc			;40b1
	ret			;40b2
	nop			;40b3
	nop			;40b4
	nop			;40b5
	nop			;40b6
	nop			;40b7
sub_40b8h:
	ld l,000h		;40b8
l40bah:
	call sub_4080h		;40ba
	call sub_40d0h		;40bd
	call sub_4080h		;40c0
	inc l			;40c3
	ld a,l			;40c4
	cp 01fh		;40c5
	jr nz,l40bah		;40c7

	call WRITE_TO_AY		;40c9
	db AY_VOL_1, $10

	ret

	nop			;40cf

sub_40d0h:
	ld a,l			;40d0
	ld (040eah),a		;40d1
	call sub_49d0h		;40d4

	call WRITE_TO_AY		;40d7
	db AY_VOL_1, $0F

	call WRITE_TO_AY		;40dc
	db AY_VOL_2, $0F
	
	call WRITE_TO_AY		;40e1
	db AY_MIXER, %00101111
	
	call WRITE_TO_AY		;40e6
	db AY_NOISE_FREQ, $1E
	
	ret			;40eb

	nop			;40ec
	nop			;40ed
	nop			;40ee
	nop			;40ef
	nop			;40f0
	nop			;40f1
	nop			;40f2
	nop			;40f3
	nop			;40f4
	nop			;40f5
	nop			;40f6
	nop			;40f7
	nop			;40f8
	nop			;40f9
	nop			;40fa
	nop			;40fb
	nop			;40fc
	nop			;40fd
	nop			;40fe
	nop			;40ff
l4100h:
	nop			;4100


	;; Centipede storage
	;;
	;; 4101--410c - row coordinate
	;; 4121--412c - column coordinate
	;; 4141--411c - segment info
	;;              Bit 0 - set for head, reset for body
	;; 		Bit 5 - set if segment displayed
	;; 4161-416c - temporary store for background character
	;; 
	;; These are original values from TAP file, though they are
	;; probably not rlevant, as they are overwritten by the
	;; initialisation routine
l4101h:
	db $14, $0c, $14, $15, $15, $16, $15, $13
	db $12, $12, $12, $12, $13, $13, $14, $15
	db $13, $12, $13, $14, $14, $14, $11, $14
	db $11, $10, $16, $15, $16, $15, $00, $00
	db $1a, $18, $11, $11, $12, $12, $13, $17
	db $15, $08, $07, $06, $04, $00, $19, $00
	db $08, $1c, $18, $02, $1f, $18, $06, $07
	db $1b, $02, $02, $01, $0b, $03, $00, $01
	db $25, $24, $64, $66, $66, $71, $27, $27
	db $24, $64, $64, $65, $25, $33, $39, $3f
	db $37, $33, $3b, $39, $37, $3f, $37, $31
	db $39, $3d, $31, $39, $3b, $27, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $04
	db $04, $00, $00, $00, $00, $00, $00, $00
	db $05, $00, $00, $00, $00, $00, $00 

;; 	inc d			;4101
;; 	add hl,bc			;4102
;; 	ld de,01515h		;4103
;; 	ld d,016h		;4106
;; 	ld d,00fh		;4108
;; 	ld bc,00c16h		;410a
;; 	ld d,013h		;410d
;; 	inc d			;410f
;; 	dec d			;4110
;; 	inc de			;4111
;; 	ld (de),a			;4112
;; 	inc de			;4113
;; 	inc d			;4114
;; 	inc d			;4115
;; 	inc d			;4116
;; 	ld de,01114h		;4117
;; 	djnz l4132h		;411a
;; 	dec d			;411c
;; 	ld d,015h		;411d
;; 	nop			;411f
;; 	nop			;4120
;; 	rra			;4121
;; 	add hl,de			;4122
;; 	rrca			;4123
;; 	rlca			;4124
;; 	ex af,af'			;4125
;; 	ex af,af'			;4126
;; 	add hl,bc			;4127
;; 	ld a,(bc)			;4128
;; 	inc c			;4129
;; 	rrca			;412a
;; 	rla			;412b
;; 	add hl,de			;412c
;; 	dec d			;412d
;; 	nop			;412e
;; 	add hl,de			;412f
;; 	nop			;4130
;; 	ex af,af'			;4131
;; l4132h:
;; 	inc e			;4132
;; 	jr $+4		;4133
;; 	rra			;4135
;; 	jr $+8		;4136
;; 	rlca			;4138
;; 	dec de			;4139
;; 	ld (bc),a			;413a
;; 	ld (bc),a			;413b
;; 	ld bc,0030bh		;413c
;; 	nop			;413f
;; 	ld bc,0277fh		;4140
;; 	daa			;4143
;; 	ld h,(hl)			;4144
;; 	ld h,(hl)			;4145
;; 	ld (hl),d			;4146
;; 	ld (hl),d			;4147
;; 	ld (hl),e			;4148
;; 	daa			;4149
;; 	ld h,071h		;414a
;; 	dec h			;414c
;; 	inc sp			;414d
;; 	inc sp			;414e


;; 	add hl,sp			;414f
;; 	ccf			;4150
;; 	scf			;4151
;; 	inc sp			;4152
;; 	dec sp			;4153
;; 	add hl,sp			;4154
;; 	scf			;4155
;; 	ccf			;4156
;; 	scf			;4157
;; 	ld sp,l3d39h		;4158
;; 	ld sp,03b39h		;415b
;; 	daa			;415e
;; 	nop			;415f
;; 	nop			;4160
;; 	nop			;4161
;; 	nop			;4162
;; 	nop			;4163
;; 	nop			;4164
;; 	nop			;4165
;; 	nop			;4166
;; 	nop			;4167
;; 	nop			;4168
;; 	nop			;4169
;; 	nop			;416a
;; 	nop			;416b
;; 	nop			;416c
;; 	nop			;416d
;; 	nop			;416e
;; 	nop			;416f
;; 	inc b			;4170
;; 	inc b			;4171
;; 	nop			;4172
;; 	nop			;4173
;; 	nop			;4174
;; 	nop			;4175
;; 	nop			;4176
;; 	nop			;4177
;; 	nop			;4178
;; 	dec b			;4179
;; 	nop			;417a
;; 	nop			;417b
;; 	nop			;417c
;; 	nop			;417d
;; 	nop			;417e
;; 	nop			;417f

	;; 8-byte buffer, initialised at beginning of game so, likely,
	;; does not matter what is here
l4180h:	db 0x07
	db 0x05
	db 0x00
	db $3E
	db $60
	db $01
	db $04			; Used when initialising centipede
	db $00

	;; Initialisation routine
	;;
	;; Save state for return to Forth interpretter, which requires
	;; preserving IX, IY, and SP (see Steven Vickers, "Jupiter Ace
	;; Forth Programming", Chapter 25, p.148)
	;;
	;; On entry:
	;;
	;; On exit:
	;;   HL - corrupted
sub_4188h:
	pop hl			;4188 - Retrieve return address and
				;  balance stack as at parent routine
	ld (IX_STR),ix		;4189
	ld (IY_STR),iy		;418d
	ld (SP_STR),sp		;4191
	jp (hl)			;4195 - Return
	nop			;4196
	nop			;4197
	
IX_STR:	dw 0x0000	
IY_STR:	dw 0x0000
SP_STR:	dw 0x0000
	
	nop			;419e
	nop			;419f

	;; Prepare to exit game
	;;
	;; Restore state for return to Forth interpretter, which
	;; requires reinstating previous values of IX, IY, and SP (see
	;; Steven Vickers, "Jupiter Ace Forth Programming", Chapter 25,
	;; p.148)
	;;
	;; On entry:
	;;
	;; On exit:
	;;   HL - corrupted
sub_41a0h:
	pop hl			;41a0
	ld ix,(IX_STR)		;41a1
	ld iy,(IY_STR)		;41a5
	ld sp,(SP_STR)		;41a9
	jp (hl)			;41ad
	nop			;41ae
	nop			;41af


	;; Initialisation routine #2
sub_41b0h:
	ld hl,l41c0h		;41b0 - Write 8 bytes from 41c0 to 4180
	ld de,l4180h		;41b3
	ld bc,00008h		;41b6
	ldir		;41b9

	ret			;41bb

	nop			;41bc
	nop			;41bd
	nop			;41be
	nop			;41bf

l41c0h: db $0c, $00, $00, $00, $00, $00, $01, $00

	;; Game routine #1 - not used
	ret			;41c8

	ld a,07fh		;41c9
	in a,(0feh)		;41cb
	rra			;41cd
	jr nc,l41d2h		;41ce
	pop af			;41d0
	ret			;41d1
l41d2h:
	call sub_41a0h		;41d2
	ld de,l41ddh		;41d5
	call 00979h		;41d8
	jp (iy)		;41db
l41ddh:
	rlca			;41dd
	nop			;41de
	ld d,e			;41df
	ld d,h			;41e0
	ld c,a			;41e1
	ld d,b			;41e2
	ld d,b			;41e3
	ld b,l			;41e4
	ld b,h			;41e5
	nop			;41e6
	nop			;41e7


	;; Initialise centipede storage??
sub_41e8h:
	push ix			;41e8
	push bc			;41ea
	push de			;41eb
	push hl			;41ec
	push af			;41ed

	;; Reset bit 6 of memory locations 4141, ..., 415f inclusive
	ld hl,04141h		;41ee
	ld b,01fh		;41f1
l41f3h:
	res 6,(hl)		;41f3
	inc hl			;41f5
	djnz l41f3h		;41f6

	;; Row number of each segment in 4101...410C, column number in
	;; 4121...412C, body/head value in 4141...414C
	ld ix,l4101h		;41f8 - Start of centipede storage
	ld b,00ch		;41fc - Centipede has 12 segments
	ld c,000h		;41fe - First segment is in column 0
	ld h,046h		;4200 - ??? 
	ld a,(l4180h+7)		;4202
	and a			;4205
	jr z,l420ah		;4206
	set 3,h		;4208 - H=$4E
l420ah:	ld (ix+000h),001h	;420a - Set row coordinate to 01 for all
				;       segments
	ld (ix+020h),c		;420e - Set column coordinate
	ld (ix+040h),h		;4211 - ??? 
	inc ix			;4214 - Next segment
	inc c			;4216 - Increase column coordinate
	djnz l420ah		;4217 - Repeat

	dec ix			;4219 - Set last segment to be head
	set 0,(ix+040h)		;421b

	;; Check if centipede needs to be split
	ld ix,l4101h		;421f
	ld a,(l4180h+6)		;4223
	ld b,a			;4226
l4227h:	dec b			;4227
	jp z,l4240h		;4228

	ld (ix+000h),002h	;422b
	call sub_3d30h		;422f - Get random number
	and 01fh		;4232
	ld (ix+020h),a		;4234
	call sub_4618h		;4237
	nop			;423a
	inc ix		;423b
	jp l4227h		;423d

l4240h:
	pop af			;4240
	pop hl			;4241
	pop de			;4242
	pop bc			;4243
	pop ix		;4244
	ret			;4246
	nop			;4247


	;; Display centipede
sub_4248h:
	;; Save registers
	push ix			;4248
	push bc			;424a
	push de			;424b
	push hl			;424c
	push af			;424d

	ld ix,l4101h		;424e - Start of centipede
	ld d,00ch		;4252 - 12 segments
l4254h:
	;; Retrieve coordinates of current segment into B and C
	ld b,(ix+000h)		;4254
	ld c,(ix+020h)		;4257

	;; Retrieve any object at B,C into A
	call sub_3d18h		;425a
	cp 005h			;425d - Check if space ship, bullet, flea, ...
	jp nc,l4273h+1		;425f - Jump forward if is

	set 5,(ix+040h)		;4262 - Comfirm is displayed
	ld (ix+060h),a		;4266 - Save original character for later
	ld a,007h		;4269 - Centipede body
	bit 0,(ix+040h)		;426b - Is it the head?
	jr nz,l4273h		;426f
	ld a,008h		;4271 - Centipede head

l4273h:	call sub_3d00h		;4273 - Display character
	inc ix			;4276 - Advance to next segment
	dec d			;4278 - Check if any more segments
	jp nz,l4254h		;4279 - Loop if so

	pop af			;427c
	pop hl			;427d
	pop de			;427e
	pop bc			;427f
	pop ix			;4280

	ret			;4282
	
	nop			;4283
	nop			;4284
	nop			;4285
	nop			;4286
	nop			;4287

sub_4288h:
	call sub_41e8h		;4288
	call sub_4248h		;428b
	ret			;428e
	nop			;428f

sub_4290h:
	push ix		;4290
	push bc			;4292
	push de			;4293
	push hl			;4294
	push af			;4295
	ld ix,l4100h		;4296
	ld a,(l4180h+5)		;429a
	xor 001h		;429d
	ld (l4180h+5),a		;429f
l42a2h:
	inc ix		;42a2
	push ix		;42a4
	pop bc			;42a6
	ld a,c			;42a7
	cp 01fh		;42a8
	jp nz,l42b4h		;42aa
	pop af			;42ad
	pop hl			;42ae
	pop de			;42af
	pop bc			;42b0
	pop ix		;42b1
	ret			;42b3
l42b4h:
	bit 6,(ix+040h)		;42b4
	jp z,l42a2h		;42b8
	ld a,(l4180h+5)		;42bb
	cp 001h		;42be
	jp z,l42cah		;42c0
	bit 3,(ix+040h)		;42c3
	jp z,l42a2h		;42c7
l42cah:
	ld b,(ix+000h)		;42ca
	ld c,(ix+020h)		;42cd
	call sub_3d18h		;42d0
	cp 006h		;42d3
	jp nz,l4310h		;42d5
	call sub_41a0h		;42d8
	rst 20h			;42db
	ex af,af'			;42dc
	nop			;42dd
	nop			;42de
	nop			;42df
	nop			;42e0
	nop			;42e1
	nop			;42e2
	nop			;42e3
	nop			;42e4
	nop			;42e5
	nop			;42e6
	nop			;42e7
	nop			;42e8
	nop			;42e9
	nop			;42ea
	nop			;42eb
	nop			;42ec
	nop			;42ed
	nop			;42ee
	nop			;42ef
	nop			;42f0
	nop			;42f1
	nop			;42f2
	nop			;42f3
	nop			;42f4
	nop			;42f5
	nop			;42f6
	nop			;42f7
	nop			;42f8
	nop			;42f9
	nop			;42fa
	nop			;42fb
	nop			;42fc
	nop			;42fd
	nop			;42fe
l42ffh:
	nop			;42ff
sub_4300h:
	bit 1,(ix+040h)		;4300
	jr z,l4308h		;4304
	inc c			;4306
	ret			;4307
l4308h:
	dec c			;4308
	ret			;4309
	nop			;430a
	nop			;430b
	nop			;430c
	nop			;430d
l430eh:
	nop			;430e
	nop			;430f
l4310h:
	bit 0,(ix+040h)		;4310
	jp z,l43d0h		;4314
	bit 5,(ix+040h)		;4317
	jr z,l4323h		;431b
	ld a,(ix+060h)		;431d
	call sub_3d00h		;4320
l4323h:
	call sub_4300h		;4323
	ld a,c			;4326
	cp 020h		;4327
	jr nc,l4360h		;4329
	call sub_3d18h		;432b
	cp 000h		;432e
	jr z,l433dh		;4330
	cp 005h		;4332
	jr z,l433dh		;4334
	cp 006h		;4336
	jr z,l433dh		;4338
	jp l4360h		;433a
l433dh:
	call sub_3d18h		;433d
	cp 007h		;4340
	jr nc,l4352h		;4342
	ld (ix+060h),a		;4344
	ld a,007h		;4347
	call sub_3d00h		;4349
	set 5,(ix+040h)		;434c
	jr l4356h		;4350
l4352h:
	res 5,(ix+040h)		;4352
l4356h:
	ld (ix+000h),b		;4356
	ld (ix+020h),c		;4359
	jp l42a2h		;435c
	nop			;435f
l4360h:
	ld a,002h		;4360
	xor (ix+040h)		;4362
	ld (ix+040h),a		;4365
	call sub_4300h		;4368
	bit 2,(ix+040h)		;436b
	jr nz,l4374h		;436f
	dec b			;4371
	jr l4375h		;4372
l4374h:
	inc b			;4374
l4375h:
	ld a,b			;4375
	cp 010h		;4376
	jr nz,l437eh		;4378
	set 2,(ix+040h)		;437a
l437eh:
	cp 016h		;437e
	jp nz,l433dh		;4380
	res 2,(ix+040h)		;4383
	bit 4,(ix+040h)		;4387
	jr nz,l4395h		;438b
	ld hl,l4180h+1		;438d
	inc (hl)			;4390
	set 4,(ix+040h)		;4391
l4395h:
	call sub_3d30h		;4395
	and 002h		;4398
	xor (ix+040h)		;439a
	ld (ix+040h),a		;439d
	ld a,c			;43a0
	cp 000h		;43a1
	jp z,l43aeh		;43a3
	cp 01fh		;43a6
	jp z,l43b5h		;43a8
	jp l433dh		;43ab
l43aeh:
	set 1,(ix+040h)		;43ae
	jp l433dh		;43b2
l43b5h:
	res 1,(ix+040h)		;43b5
	jp l433dh		;43b9
	nop			;43bc
	nop			;43bd
	nop			;43be
	nop			;43bf
	nop			;43c0
	nop			;43c1
	nop			;43c2
	nop			;43c3
	nop			;43c4
	nop			;43c5
	nop			;43c6
	nop			;43c7
	nop			;43c8
	nop			;43c9
	nop			;43ca
	nop			;43cb
	nop			;43cc
	nop			;43cd
	nop			;43ce
	nop			;43cf
l43d0h:
	call sub_3d18h		;43d0
	cp 008h		;43d3
	jr nz,l43e9h		;43d5
	ld a,(ix+03fh)		;43d7
	and 041h		;43da
	cp 040h		;43dc
	jr z,l43e9h		;43de
	nop			;43e0
	nop			;43e1
	nop			;43e2
	ld a,(ix+060h)		;43e3
	call sub_3d00h		;43e6
l43e9h:
	call sub_4440h		;43e9
	ld b,(ix+001h)		;43ec
	ld c,(ix+021h)		;43ef
	call sub_3d18h		;43f2
	cp 008h		;43f5
	jr nz,l4401h		;43f7
	ld a,(ix+061h)		;43f9
	ld (ix+060h),a		;43fc
	jr l4423h		;43ff
l4401h:
	cp 007h		;4401
	jr nz,l4416h		;4403
	ld a,008h		;4405
	call sub_3d00h		;4407
	ld a,(ix+061h)		;440a
	ld (ix+060h),a		;440d
	ld (ix+061h),008h		;4410
	jr l4423h		;4414
l4416h:
	cp 007h		;4416
	jr nc,l4423h		;4418
	ld (ix+060h),a		;441a
	ld a,008h		;441d
	call sub_3d00h		;441f
	nop			;4422
l4423h:
	ld a,b			;4423
	cp 016h		;4424
	jr nz,l4436h		;4426
	bit 4,(ix+040h)		;4428
	jr nz,l4436h		;442c
	ld hl,l4180h+1		;442e
	inc (hl)			;4431
	set 4,(ix+040h)		;4432
l4436h:
	ld (ix+000h),b		;4436
	ld (ix+020h),c		;4439
	jp l42a2h		;443c
	nop			;443f
sub_4440h:
	ld a,(ix+040h)		;4440
	and 010h		;4443
	ld h,a			;4445
	ld a,(ix+041h)		;4446
	and 0eeh		;4449
	or h			;444b
	ld (ix+040h),a		;444c
	ret			;444f
	nop			;4450
	nop			;4451
	nop			;4452
	nop			;4453
	nop			;4454
	nop			;4455
	nop			;4456
	nop			;4457
	nop			;4458
	nop			;4459
	nop			;445a
	nop			;445b
	nop			;445c
	nop			;445d
	nop			;445e
	nop			;445f
sub_4460h:
	push ix		;4460
	push bc			;4462
	push hl			;4463
	push af			;4464
	ld ix,l4100h		;4465
l4469h:
	inc ix		;4469
	push ix		;446b
	pop bc			;446d
	ld a,c			;446e
	cp 01fh		;446f
	jr nz,l4479h		;4471
	pop af			;4473
	pop hl			;4474
	pop bc			;4475
	pop ix		;4476
	ret			;4478
l4479h:
	bit 6,(ix+040h)		;4479
	jr z,l4469h		;447d
	ld b,(ix+000h)		;447f
	ld c,(ix+020h)		;4482
	call sub_3d18h		;4485
	cp 006h		;4488
	jr nz,l44afh		;448a
l448ch:
	ld a,004h		;448c
	call sub_3d00h		;448e
	res 6,(ix+040h)		;4491
	ld hl,01000h		;4495
	bit 0,(ix+040h)		;4498
	jr z,l44a1h		;449c
	ld hl,00001h		;449e
l44a1h:
	call sub_4908h		;44a1
	set 0,(ix+03fh)		;44a4
	ld hl,l4180h		;44a8
	dec (hl)			;44ab
	jp l4469h		;44ac
l44afh:
	jp l46d0h		;44af
	nop			;44b2
	nop			;44b3
	nop			;44b4
	nop			;44b5
l44b6h:
	ld b,h			;44b6
	ld (0e5f5h),hl		;44b7
	ld hl,(l44b6h)		;44ba
	ld a,h			;44bd
	xor 066h		;44be
	ld h,a			;44c0
	ld a,l			;44c1
	xor 066h		;44c2
	ld l,a			;44c4
	ld (l44b6h),hl		;44c5
	ld (02c3eh),hl		;44c8
	ld (02c46h),hl		;44cb
	pop hl			;44ce
	pop af			;44cf
	ret			;44d0
l44d1h:
	nop			;44d1
	nop			;44d2
	nop			;44d3
	nop			;44d4
	nop			;44d5
	nop			;44d6
	nop			;44d7
sub_44d8h:
	call sub_4460h		;44d8
	call 044b8h		;44db
	call sub_4290h		;44de
	call sub_4630h		;44e1
	ret			;44e4
	nop			;44e5
	nop			;44e6
	nop			;44e7
sub_44e8h:
	push af			;44e8
	ld a,(l4180h)		;44e9
	and a			;44ec
	jp z,l44f8h		;44ed
	call sub_44d8h		;44f0
	pop af			;44f3
	ret			;44f4
	nop			;44f5
	nop			;44f6
l44f7h:
	nop			;44f7
l44f8h:
	ld a,(l44d1h)		;44f8
	and a			;44fb
	jp nz,l4508h		;44fc
	ld a,040h		;44ff
	ld (l44d1h),a		;4501
	pop af			;4504
	ret			;4505
	nop			;4506
	nop			;4507
l4508h:
	dec a			;4508
	ld (l44d1h),a		;4509
	jr z,l4510h		;450c
	pop af			;450e
	ret			;450f
l4510h:
	ld a,(l41c0h)		;4510
	ld (l4180h),a		;4513
	ld a,000h		;4516
	ld (l4180h+1),a		;4518
	ld (l4180h+2),a		;451b
	ld a,(l4180h+6)		;451e
	inc a			;4521
	cp 00dh		;4522
	jr z,l452bh		;4524
	ld (l4180h+6),a		;4526
	jr l4533h		;4529
l452bh:
	ld a,001h		;452b
	ld (l4180h+6),a		;452d
	ld (l4180h+7),a		;4530
l4533h:
	call sub_4288h		;4533
	pop af			;4536
	ret			;4537
	nop			;4538
	nop			;4539
	nop			;453a
	nop			;453b
	nop			;453c
	nop			;453d
	nop			;453e
	nop			;453f
l4540h:
	call sub_40b8h		;4540
	ld ix,l4101h		;4543
l4547h:
	bit 6,(ix+040h)		;4547
	jr z,l455fh		;454b
	bit 5,(ix+040h)		;454d
	jr z,l455fh		;4551
	ld b,(ix+000h)		;4553
	ld c,(ix+020h)		;4556
	ld a,(ix+060h)		;4559
	call sub_3d00h		;455c
l455fh:
	inc ix		;455f
	push ix		;4561
	pop bc			;4563
	ld a,c			;4564
	cp 01fh		;4565
	jr nz,l4547h		;4567
	ld hl,02420h		;4569
l456ch:
	ld a,(hl)			;456c
	cp 005h		;456d
	jr c,l4573h		;456f
	ld (hl),000h		;4571
l4573h:
	inc hl			;4573
	ld a,l			;4574
	cp 0e0h		;4575
	jr nz,l456ch		;4577
	ld a,h			;4579
	cp 026h		;457a
	jr nz,l456ch		;457c
	ld c,000h		;457e
l4580h:
	ld b,016h		;4580
l4582h:
	call sub_3d18h		;4582
	and a			;4585
	jr z,l459ch		;4586
	cp 004h		;4588
	jr nc,l459ch		;458a
	call sub_3d18h		;458c
	xor 080h		;458f
	call sub_3d00h		;4591
	call sub_45b8h		;4594
	ld a,004h		;4597
	call sub_3d00h		;4599
l459ch:
	djnz l4582h		;459c
	inc c			;459e
	ld a,c			;459f
	cp 020h		;45a0
	jr nz,l4580h		;45a2
	ld sp,(SP_STR)		;45a4
	ld a,000h		;45a8
	ld (l46e0h),a		;45aa
	call sub_41a0h		;45ad
	jp l45d0h		;45b0
	nop			;45b3
	nop			;45b4
	nop			;45b5
	nop			;45b6
	nop			;45b7
sub_45b8h:
	call sub_3fa0h		;45b8
	call sub_49c5h		;45bb
	ld hl,03000h		;45be
l45c1h:
	dec hl			;45c1
	ld a,h			;45c2
	or l			;45c3
	jr nz,l45c1h		;45c4
	ld hl,00500h		;45c6
	call sub_3fc0h		;45c9
	ret			;45cc
	nop			;45cd
	nop			;45ce
	nop			;45cf
l45d0h:
	ld a,(l3fbch)		;45d0
	and a			;45d3
	jp nz,l45e0h		;45d4
	call sub_41a0h		;45d7
	jp l4800h		;45da
	nop			;45dd
	nop			;45de
	nop			;45df
l45e0h:
	dec a			;45e0
	ld (l3fbch),a		;45e1
	ld hl,(l3fbdh)		;45e4
	ld (hl),000h		;45e7
	dec hl			;45e9
	ld (l3fbdh),hl		;45ea
	ld a,000h		;45ed
	ld (l4180h),a		;45ef
	ld a,(l4180h+6)		;45f2
	dec a			;45f5
	ld (l4180h+6),a		;45f6
	ld bc,0160fh		;45f9
	ld a,005h		;45fc
	call sub_3d00h		;45fe
	ld (l3f12h),bc		;4601
	ld bc,00000h		;4605
	ld (l3f90h),bc		;4608
	jp l3c78h		;460c
	nop			;460f
	nop			;4610
	nop			;4611
	nop			;4612
	nop			;4613
	nop			;4614
	nop			;4615
	nop			;4616
	nop			;4617


sub_4618h:
	push af			;4618
	call sub_3d30h		;4619
	and 00ah		;461c
	or 045h		;461e
	ld (ix+040h),a		;4620
	ld a,(l4180h+7)		;4623
	cp 001h		;4626
	jr nz,l462eh		;4628
	set 3,(ix+040h)		;462a
l462eh:
	pop af			;462e
	ret			;462f

sub_4630h:
	push hl			;4630
	push af			;4631
	ld a,(l4180h+2)		;4632
	cp 001h		;4635
	jp z,l4658h		;4637
	ld a,(l4180h)		;463a
	ld h,a			;463d
	ld a,(l4180h+1)		;463e
	cp h			;4641
	jr z,l4647h		;4642
	pop af			;4644
	pop hl			;4645
	ret			;4646
l4647h:
	ld a,001h		;4647
	ld (l4180h+2),a		;4649
	ld hl,06060h		;464c
	ld (l4180h+3),hl		;464f
l4652h:
	pop af			;4652
	pop hl			;4653
	ret			;4654
	nop			;4655
	nop			;4656
	nop			;4657
l4658h:
	ld a,(l4180h+3)		;4658
	dec a			;465b
	ld (l4180h+3),a		;465c
	jr nz,l4652h		;465f
	ld a,(l4180h+4)		;4661
	cp 020h		;4664
	jr z,l466ah		;4666
	sub 008h		;4668
l466ah:
	ld (l4180h+3),a		;466a
	ld (l4180h+4),a		;466d
	push ix		;4670
	ld ix,l4100h		;4672
l4676h:
	inc ix		;4676
	push ix		;4678
	pop hl			;467a
	ld a,l			;467b
	cp 01fh		;467c
	jr nz,l4685h		;467e
	pop ix		;4680
	pop af			;4682
	pop hl			;4683
	ret			;4684
l4685h:
	bit 6,(ix+040h)		;4685
	jp nz,l4676h		;4689
	ld (ix+000h),010h		;468c
	ld hl,04d1fh		;4690
	call sub_3d30h		;4693
	and 001h		;4696
	jr nz,l469dh		;4698
	ld hl,04f00h		;469a
l469dh:
	ld a,(l4180h+7)		;469d
	cp 001h		;46a0
	jr z,l46abh		;46a2
	call sub_3d30h		;46a4
	and 008h		;46a7
	xor h			;46a9
	ld h,a			;46aa
l46abh:
	ld (ix+040h),h		;46ab
	ld (ix+020h),l		;46ae
	ld a,(l4180h)		;46b1
	inc a			;46b4
	ld (l4180h),a		;46b5
	ld (ix+060h),000h		;46b8
	pop ix		;46bc
	pop af			;46be
	pop hl			;46bf
	ret			;46c0
	nop			;46c1
	nop			;46c2
	nop			;46c3
	nop			;46c4
	nop			;46c5
	nop			;46c6
	nop			;46c7
	nop			;46c8
	nop			;46c9
	nop			;46ca
	nop			;46cb
	nop			;46cc
	nop			;46cd
	nop			;46ce
	nop			;46cf
l46d0h:
	ld a,(ix+060h)		;46d0
	cp 006h		;46d3
	jp nz,l4469h		;46d5
	jp l448ch		;46d8
	nop			;46db
	nop			;46dc
	nop			;46dd
	nop			;46de
	nop			;46df
l46e0h:
	db 0x00			;46e0 - Flea is active
l46e1h:
	dec c			;46e1
l46e2h:
	ld d,001h		;46e2
l46e4h:
	nop			;46e4
l46e5h:
	ld bc,00020h		;46e5

	;; Initialisation #5 - Zero some variables
sub_46e8h:
	push af			;46e8
	ld a,000h		;46e9
	ld (l46e0h),a		;46eb - Flee is not active
	ld (l46e2h+1),a		;46ee
	pop af			;46f1
	
	ret			;46f2

	nop			;46f3
	nop			;46f4
	nop			;46f5
	nop			;46f6
	nop			;46f7
sub_46f8h:
	push bc			;46f8
	push de			;46f9
	push hl			;46fa
	push af			;46fb
	ld a,(l46e0h)		;46fc
	and a			;46ff
	jp nz,l4750h		;4700
	ld a,(l46e2h+1)		;4703
	and a			;4706
	jp nz,l471dh		;4707
	ld a,(l4180h+6)		;470a
	cp 002h		;470d
	jr z,l4716h		;470f
l4711h:
	pop af			;4711
	pop hl			;4712
	pop de			;4713
	pop bc			;4714
	ret			;4715
l4716h:
	ld a,001h		;4716
	ld (l46e2h+1),a		;4718
	jr l4711h		;471b
l471dh:
	call sub_3d30h		;471d
	and 03fh		;4720
	jr nz,l4711h		;4722
	ld b,001h		;4724
	call sub_3d30h		;4726
	and 01fh		;4729
	ld c,a			;472b
	ld (l46e1h),bc		;472c
	ld a,001h		;4730
	ld (l46e0h),a		;4732 - ??? Flea is active
	call sub_3d18h		;4735
	ld (l46e5h+1),a		;4738
	ld a,00bh		;473b
	call sub_3d00h		;473d
	ld l,001h		;4740
	call sub_3d30h		;4742
	and h			;4745
	xor h			;4746
	ld (l46e4h),a		;4747
	jp l4711h		;474a
	nop			;474d
	nop			;474e
	nop			;474f
l4750h:
	ld a,(l46e5h)		;4750
	xor 001h		;4753
	ld (l46e5h),a		;4755
	ld h,a			;4758
	ld a,(l46e4h)		;4759
	and a			;475c
	jp nz,l4764h		;475d
	or h			;4760
	jp z,l4711h		;4761
l4764h:
	ld bc,(l46e1h)		;4764
	call sub_3d18h		;4768
	cp 006h		;476b
	jp nz,l4783h		;476d
	ld a,004h		;4770
	call sub_3d00h		;4772
	ld hl,00005h		;4775
	call sub_3fc0h		;4778
	ld a,000h		;477b
	ld (l46e0h),a		;477d
	jp l4711h		;4780
l4783h:
	ld a,(l46e5h+1)		;4783
	cp 000h		;4786
	jr z,l4794h		;4788
	cp 005h		;478a
	jr nc,l4790h		;478c
	jr l47a0h		;478e
l4790h:
	ld a,000h		;4790
	jr l47a0h		;4792
l4794h:
	ld h,000h		;4794
	call sub_3d30h		;4796
	and 003h		;4799
	jr nz,l479fh		;479b
	ld h,004h		;479d
l479fh:
	ld a,h			;479f
l47a0h:
	call sub_3d00h		;47a0
	inc b			;47a3
	call sub_3d18h		;47a4
	ld (l46e5h+1),a		;47a7
	ld a,b			;47aa
	cp 017h		;47ab
	jr nz,l47bbh		;47ad
	ld a,000h		;47af
	dec b			;47b1
	call sub_3d00h		;47b2
	ld (l46e0h),a		;47b5
	jp l4711h		;47b8
l47bbh:
	ld a,00bh		;47bb
	call sub_3d00h		;47bd
	ld (l46e1h),bc		;47c0
	jp l4711h		;47c4
	nop			;47c7
	nop			;47c8
	nop			;47c9
	nop			;47ca
	nop			;47cb
	nop			;47cc
	nop			;47cd
	nop			;47ce
	nop			;47cf
	push af			;47d0
l47d1h:	ld a,(l46e0h)		;47d1 - Check if flea active
	and a			;47d4
	jr nz,l47e0h		;47d5 - Jump forward if so

	;; Set Channel B volume to zero
	call WRITE_TO_AY	;47d7
	db AY_VOL_2, $00
	
l47dch:	pop af			;47dc - Restore AF
	jp l3ee3h		;47dd - Return to top level of Game
				;       Routine #2

	;; Make flea-dropping sound effect
l47e0h:	call WRITE_TO_AY		;47e0
	db AY_MIXER, %00110101
	
	call WRITE_TO_AY		;47e5
	db AY_VOL_2, $0C

	ld a,(l46e2h)		;47ea
	add a,a			;47ed
	add a,a			;47ee
	add a,a			;47ef

	call WRITE_TO_AY		;47f0
	db AY_TONE_2+1, $05
	ld (l47fch),a		;47f5

	call WRITE_TO_AY		;47f8
	db AY_TONE_2
l47fch:	db $b0

	jr l47dch		;47fd
	nop			;47ff
l4800h:
	call sub_4968h		;4800
	ld de,02417h		;4803
l4806h:
	inc de			;4806
	inc hl			;4807
	ld a,l			;4808
	cp 009h		;4809
	jr nz,l4810h		;480b
l480dh:
	jp l4900h		;480d
l4810h:
	ld a,(de)		;4810
	cp (hl)			;4811
	jr c,l4818h		;4812
	jr z,l4806h		;4814
	jr l480dh		;4816
l4818h:
	ld bc,00008h		;4818
	ld de,02418h		;481b
	ld hl,02400h		;481e
	ldir		;4821
	ld bc,00008h		;4823
	ld de,l3dd8h		;4826
	ld hl,02400h		;4829
	ldir		;482c
	jp l4850h		;482e
	nop			;4831
	nop			;4832
	nop			;4833
	nop			;4834
	nop			;4835
	nop			;4836
	nop			;4837
sub_4838h:
	pop hl			;4838
	ld a,(hl)			;4839
	ld (03c1dh),a		;483a
	inc hl			;483d
	ld a,(hl)			;483e
	ld (03c1ch),a		;483f
l4842h:
	inc hl			;4842
	ld a,(hl)			;4843
	and 07fh		;4844
	rst 8			;4846
	ld a,(hl)			;4847
	and 080h		;4848
	jr z,l4842h		;484a
	inc hl			;484c
	jp (hl)			;484d
	nop			;484e
	nop			;484f
l4850h:
	call 04830h		;4850
	inc h			;4853
	push bc			;4854
	ld d,a			;4855
	ld h,l			;4856
	ld l,h			;4857
	ld l,h			;4858
	jr nz,$+102		;4859
	ld l,a			;485b
	ld l,(hl)			;485c
	ld h,l			;485d
	ld hl,5920		;485e
	ld l,a			;4861
	ld (hl),l			;4862
	jr nz,$+105		;4863
	ld l,a			;4865
	ld (hl),h			;4866
	jr nz,$+118		;4867
	ld l,b			;4869
	push hl			;486a
	call 04830h		;486b
	inc h			;486e
	push hl			;486f
	ld l,b			;4870
	ld l,c			;4871
	ld h,a			;4872
	ld l,b			;4873
	ld h,l			;4874
	ld (hl),e			;4875
	ld (hl),h			;4876
	jr nz,l48ech		;4877
	ld h,e			;4879
	ld l,a			;487a
	ld (hl),d			;487b
	ld h,l			;487c
	jr nz,$+118		;487d
l487fh:
	ld l,a			;487f
	ld h,h			;4880
	ld h,c			;4881
	ld a,c			;4882
	ld l,020h		;4883
	and b			;4885
	call sub_4838h		;4886
	dec h			;4889
	dec b			;488a
	ld b,l			;488b
	ld l,(hl)			;488c
	ld (hl),h			;488d
	ld h,l			;488e
	ld (hl),d			;488f
	jr nz,l490bh		;4890
	ld l,a			;4892
	ld (hl),l			;4893
	ld (hl),d			;4894
	jr nz,l4905h		;4895
	ld h,c			;4897
	ld l,l			;4898
	ld h,l			;4899
	jr nz,$+104		;489a
	ld l,a			;489c
	ld (hl),d			;489d
	jr nz,$+34		;489e
	and b			;48a0
	call sub_4838h		;48a1
	dec h			;48a4
	dec h			;48a5
	ld (hl),b			;48a6
	ld l,a			;48a7
	ld (hl),e			;48a8
	ld (hl),h			;48a9
	ld h,l			;48aa
	ld (hl),d			;48ab
	ld l,c			;48ac
	ld (hl),h			;48ad
	ld a,c			;48ae
	xor (hl)			;48af
	call sub_4838h		;48b0
	dec h			;48b3
	ld l,e			;48b4
	dec l			;48b5
	dec l			;48b6
	xor l			;48b7
	ld hl,0256bh		;48b8
l48bbh:
	nop			;48bb
	nop			;48bc
	nop			;48bd
l48beh:
	ld a,(03c26h)		;48be
	cp 005h		;48c1
	jr nz,l48d6h		;48c3
	ld a,l			;48c5
	cp 06bh		;48c6
	jr z,l48beh		;48c8
	dec hl			;48ca
	ld (hl),02dh		;48cb
l48cdh:
	ld a,(03c26h)		;48cd
	cp 000h		;48d0
	jr nz,l48cdh		;48d2
	jr l48bbh		;48d4
l48d6h:
	and 0dfh		;48d6
	cp 05bh		;48d8
	jr nc,l48bbh		;48da
	cp 041h		;48dc
	jr c,l48bbh		;48de
	ld (hl),a			;48e0
	inc hl			;48e1
	ld a,l			;48e2
	cp 06eh		;48e3
	jr z,l48e9h		;48e5
	jr l48cdh		;48e7
l48e9h:
	ld bc,00003h		;48e9
l48ech:
	ld de,l3dd4h		;48ec
	ld hl,0256bh		;48ef
	ldir		;48f2
	ld bc,00003h		;48f4
	ld de,02414h		;48f7
	ld hl,0256bh		;48fa
	ldir		;48fd
	nop			;48ff
l4900h:
	call sub_4980h		;4900
	jp (iy)		;4903
l4905h:
	nop			;4905
	nop			;4906
	nop			;4907
sub_4908h:
	call sub_3fc0h		;4908
l490bh:
	bit 4,(ix+040h)		;490b
	ret z			;490f
	ld hl,l4180h+1		;4910
	dec (hl)			;4913
	ret			;4914
	nop			;4915
	nop			;4916
	nop			;4917
	nop			;4918
	nop			;4919
	nop			;491a
	nop			;491b
	nop			;491c
	nop			;491d
	nop			;491e
	nop			;491f
	nop			;4920
	nop			;4921


	db "M", "O", "R", "E", "C", "O", "D", "E"+080h
	dw $01FB		; Length field
	dw $3C59		; Link field
	db $08			; Name-length field
	dw $0FEC		; Code field
	
	;; Parameter field for MORECODE
	nop			;4931
	nop			;4932
	nop			;4933
	nop			;4934
	nop			;4935
	nop			;4936
	nop			;4937
	nop			;4938
	nop			;4939
	nop			;493a
	nop			;493b
	nop			;493c
	nop			;493d
	nop			;493e
	nop			;493f

	;; Accessed by Game routine #2
l4940h:	push af			;4940

	;; Check if flea is active
	ld a,(l46e0h)		;4941
	and a			;4944

	;;  Jump forward, if not
	jp z,l47d1h		;4945

	;; A = -(A+40)  (01 -> BF)
	ld a,(l46e2h)		;4948
	add a,040h		;494b
	neg			;494d

	ld (l4958h),a		;494f
	ld (l495ch),a		;4952

	call PLAY_BEEPER	;4955 - Play [flea] sound
l4958h: db $AA, $00, $08, $00
l495ch:	db $AA

	jp l47d1h		;495d
	nop			;4960
	nop			;4961
	nop			;4962
	nop			;4963
	nop			;4964
	nop			;4965
	nop			;4966
	nop			;4967

sub_4968h:
	call WRITE_TO_AY	;4968
	db AY_MIXER, 0xFF	;496b

	ld hl,02420h		;496d
	ld (hl),000h		;4970
	ld de,02421h		;4972
	ld bc,002deh		;4975
	ldir		;4978
	ld hl,023ffh		;497a
	ret			;497d
	nop			;497e
	nop			;497f
sub_4980h:
	call 04830h		;4980
	dec h			;4983
	ld l,d			;4984
	ld b,a			;4985
	ld h,c			;4986
	ld l,l			;4987
	ld h,l			;4988
	jr nz,l49fah		;4989
	halt			;498b
	ld h,l			;498c
	ld (hl),d			;498d
	xor (hl)			;498e
	ret			;498f
	nop			;4990
	nop			;4991
	nop			;4992
	nop			;4993
	nop			;4994
	nop			;4995
	nop			;4996
	nop			;4997

	;; Play laser sound (internal speaker and AY)
	;;
	;; Arrive here from fire laser (0x3F98)
	;;
	;; Looks to use content of ROM addresses 0x0000--0x0018 to
	;; create a white-noise-like laser sound
	;;
	;; On entry:
	;;
	;; On exit:
	;; 

l4998h:	call WRITE_TO_AY	;4998
	db AY_ENV_SH, 0x00	;499b
	
sub_499dh:
	;; Save registers
	push bc			;499d
	push de			;499e
	push af			;499f

	ld bc,0fefeh		;49a0 - Port for built-in beeper
	ld de,00018h		;49a3 - Point to random-ish data in ROM?

l49a6h:	ld a,(de)		;49a6
	ld b,a			;49a7 - Set duration of sound wave

	ld a,$FF		;49a8
	out (c),a		;49aa

l49ach:	djnz l49ach		;49ac - Pause for B iterations

	ld a,000h		;49ae
	out (c),a		;49b0
	in a,(c)		;49b2

	dec e			;49b4 - Decrement loop counter and
	jr nz,l49a6h		;49b5   repeat (if not done).

	;; Restore registers
	pop af			;49b7
	pop de			;49b8
	pop bc			;49b9

	ret			;49ba
	
	nop			;49bb
	nop			;49bc
	nop			;49bd
	nop			;49be
	nop			;49bf
	nop			;49c0
	nop			;49c1
	nop			;49c2
	nop			;49c3
	nop			;49c4
sub_49c5h:
	call sub_499dh		;49c5
	call sub_499dh		;49c8
	ret			;49cb
	nop			;49cc
	nop			;49cd
	nop			;49ce
	nop			;49cf
sub_49d0h:
	ld a,l			;49d0
	scf			;49d1
	rla			;49d2
	add a,080h		;49d3
	nop			;49d5
	nop			;49d6
	nop			;49d7
	ld (l49e1h),a		;49d8
	ld (l49e5h),a		;49db

	call PLAY_BEEPER		;49de
l49e1h: db $BD, $40, $05, $00
l49e5h:	db $BD

	ret			;49e6
	nop			;49e7
	nop			;49e8
	nop			;49e9
	nop			;49ea
	nop			;49eb
	nop			;49ec
	nop			;49ed
	nop			;49ee
	nop			;49ef
	nop			;49f0
	nop			;49f1
	nop			;49f2
	nop			;49f3
	nop			;49f4
	nop			;49f5
	nop			;49f6
	nop			;49f7
	nop			;49f8
	nop			;49f9
l49fah:
	nop			;49fa
	nop			;49fb
	nop			;49fc
	nop			;49fd
	nop			;49fe
	nop			;49ff


l4a00h:	push af			;4a00
	push hl			;4a01

	;; Check if flea is active
	ld a,(l46e0h)		;4a02
	and a			;4a05

	;; Call subroutine if no flea
	call z,sub_4a18h	;4a06

	ld hl,FRAMES		;4a09
	ld a,(hl)		;4a0c

	;; Wait for next frame
l4a0dh:	cp (hl)			;4a0d
	jr z,l4a0dh		;4a0e

	pop hl			;4a10
	pop af			;4a11

	ret			;4a12

l4a13h:	db 0x04			;4a13
l4a14h: db 0xA0			;4a14
l4a15h:	ld (bc),a		;4a15
	nop			;4a16
	nop			;4a17

	;; Play background sound (if no flea on screen)
sub_4a18h:
	;; Check timer #1, which counts down from 0F t0 00, playing a
	;; sound when counter reaches 00, or reducing the volume based
	;; on the value otherwise
	ld a,(l4a13h)		;4a18
	dec a			;4a1b
	ld (l4a13h),a		;4a1c

	jr nz,l4a50h		;4a1f

	;; Check timer #2, which steps through four tone values
	ld a,(l4a14h)		;4a21
	add a,020h		;4a24
	cp 000h			;4a26
	jr nz,l4a2ch		;4a28
	ld a,0a0h		;4a2a - Reset counter

l4a2ch:	ld (l4a14h),a		;4a2c
	ld a,00fh		;4a2f
	ld (l4a13h),a		;4a31
	nop			;4a34
	nop			;4a35
	nop			;4a36
	nop			;4a37
	nop			;4a38
	nop			;4a39
	nop			;4a3a
	nop			;4a3b
	nop			;4a3c
	ld a,(l4a14h)		;4a3d

	;; Update tone for speaker sound in parameters below
	ld (l4a49h),a		;4a40
	ld (l4a4dh),a		;4a43

	call PLAY_BEEPER	;4a46 - Play sound
l4a49h:	db $A0, $00, $08, $00	;4a49
l4a4dh:	db $A0			;4a4d

	nop			;4a4e
	nop			;4a4f

l4a50h:	ld a,(l4a13h)		;4a50
	cp 001h			;4a53
	jr nz,l4a88h		;4a55

	ld a,(l4a15h)		;4a57
	inc a			;4a5a
	and 003h		;4a5b
	ld (l4a15h),a		;4a5d

	ld hl,00a00h		;4a60
	and a			;4a63
	jr z,l4a75h		;4a64

	ld hl,00b00h		;4a66
	dec a			;4a69
	jr z,l4a75h		;4a6a

	ld hl,00a00h		;4a6c
	dec a			;4a6f
	jr z,l4a75h		;4a70

	ld hl,00f00h		;4a72

l4a75h:	ld a,002h		;4a75
	out (AY_REG_PORT),a	;4a77
	ld a,l			;4a79
	out (AY_DAT_PORT),a	;4a7a
	ld a,003h		;4a7c
	out (AY_REG_PORT),a	;4a7e
	ld a,h			;4a80
	out (AY_DAT_PORT),a	;4a81

	ret			;4a83

	nop			;4a84
	nop			;4a85
	nop			;4a86
	nop			;4a87

l4a88h:	ld a,AY_VOL_2		;4a88
	out (AY_REG_PORT),a	;4a8a
	ld a,(l4a13h)		;4a8c
	out (AY_DAT_PORT),a	;4a8f
	
	ret			;4a91
	nop			;4a92
	nop			;4a93
	nop			;4a94
	nop			;4a95
	nop			;4a96
	nop			;4a97
	nop			;4a98
	nop			;4a99
	nop			;4a9a
	nop			;4a9b
	nop			;4a9c
	nop			;4a9d
	nop			;4a9e
	nop			;4a9f
	nop			;4aa0
	nop			;4aa1
	nop			;4aa2
	nop			;4aa3
	nop			;4aa4
	nop			;4aa5
	nop			;4aa6
	nop			;4aa7
	nop			;4aa8
	nop			;4aa9
	nop			;4aaa
	nop			;4aab
	nop			;4aac
	nop			;4aad
	nop			;4aae
	nop			;4aaf
	nop			;4ab0
	nop			;4ab1
	nop			;4ab2
	nop			;4ab3
	nop			;4ab4
	nop			;4ab5
	nop			;4ab6
	nop			;4ab7
	nop			;4ab8
	nop			;4ab9
	nop			;4aba
	nop			;4abb
	nop			;4abc
	nop			;4abd
	nop			;4abe
	nop			;4abf
	nop			;4ac0
	nop			;4ac1
	nop			;4ac2
	nop			;4ac3
	nop			;4ac4
	nop			;4ac5
	nop			;4ac6
	nop			;4ac7
	nop			;4ac8
	nop			;4ac9
	nop			;4aca
	nop			;4acb
	nop			;4acc
	nop			;4acd
	nop			;4ace
	nop			;4acf
	nop			;4ad0
	nop			;4ad1
	nop			;4ad2
	nop			;4ad3
	nop			;4ad4
	nop			;4ad5
	nop			;4ad6
	nop			;4ad7
	nop			;4ad8
	nop			;4ad9
	nop			;4ada
	nop			;4adb
	nop			;4adc
	nop			;4add
	nop			;4ade
	nop			;4adf
	nop			;4ae0
	nop			;4ae1
	nop			;4ae2
	nop			;4ae3
	nop			;4ae4
	nop			;4ae5
	nop			;4ae6
	nop			;4ae7
	nop			;4ae8
	nop			;4ae9
	nop			;4aea
	nop			;4aeb
	nop			;4aec
	nop			;4aed
	nop			;4aee
	nop			;4aef
	nop			;4af0
	nop			;4af1
l4af2h:
	nop			;4af2
	nop			;4af3
	nop			;4af4
	nop			;4af5
	nop			;4af6
	nop			;4af7
	nop			;4af8
	nop			;4af9
	nop			;4afa
	nop			;4afb
	nop			;4afc
	nop			;4afd
	nop			;4afe
	nop			;4aff
	nop			;4b00
	nop			;4b01
	nop			;4b02
	nop			;4b03
	nop			;4b04
	nop			;4b05
	nop			;4b06
	nop			;4b07
	nop			;4b08
	nop			;4b09
	nop			;4b0a
	nop			;4b0b
	nop			;4b0c
	nop			;4b0d
	nop			;4b0e
	nop			;4b0f
	nop			;4b10
	nop			;4b11
	nop			;4b12
	nop			;4b13
	nop			;4b14
	nop			;4b15
	nop			;4b16
	nop			;4b17
	nop			;4b18
	nop			;4b19
	nop			;4b1a
	nop			;4b1b
	nop			;4b1c
	nop			;4b1d
	nop			;4b1e
	nop			;4b1f
	nop			;4b20
	nop			;4b21
	nop			;4b22
	nop			;4b23
	nop			;4b24

END:
	
	;; FORTH WORD CENTIPEDE
;; 	ld b,e			;4b25
;; 	ld b,l			;4b26
;; 	ld c,(hl)			;4b27
;; 	ld d,h			;4b28
;; l4b29h:
;; 	ld c,c			;4b29
;; 	ld d,b			;4b2a
;; 	ld b,l			;4b2b
;; 	ld b,h			;4b2c
;; 	push bc			;4b2d
;; 	rrca			;4b2e
;; 	nop			;4b2f
;; 	ld l,049h		;4b30 - Link field
;; 	add hl,bc			;4b32
;; 	jp 0110eh		;4b33
;; 	djnz l4b98h		;4b36
;; 	inc a			;4b38
;; 	and a			;4b39
;; 	djnz l4af2h		;4b3a
;; 	inc b			;4b3c
;; 	ld d,h			;4b3d
;; 	ld c,c			;4b3e
;; 	ld d,h			;4b3f
;; 	ld c,h			;4b40
;; 	ld b,l			;4b41
;; 	or c			;4b42
;; 	add a,c			;4b43
;; 	ld (bc),a			;4b44
;; 	ld (0064bh),a		;4b45
;; 	jp 01d0eh		;4b48
;; 	ld a,(bc)			;4b4b
;; 	sub (hl)			;4b4c
;; 	inc de			;4b4d
;; 	nop			;4b4e
;; l4b4fh:
;; 	ld (bc),a			;4b4f
;; 	call c,0a0a0h		;4b50
;; 	and b			;4b53
;; 	and b			;4b54
;; 	and b			;4b55
;; 	and b			;4b56
;; 	and b			;4b57
;; l4b58h:
;; 	and b			;4b58
;; 	and b			;4b59
;; 	and b			;4b5a
;; 	and b			;4b5b
;; 	and b			;4b5c
;; 	and b			;4b5d
;; 	and b			;4b5e
;; 	and b			;4b5f
;; l4b60h:
;; 	and b			;4b60
;; 	and b			;4b61
;; 	and b			;4b62
;; 	and b			;4b63
;; 	and b			;4b64
;; 	and b			;4b65
;; 	and b			;4b66
;; 	and b			;4b67
;; 	and b			;4b68
;; 	and b			;4b69
;; l4b6ah:
;; 	and b			;4b6a
;; 	and b			;4b6b
;; l4b6ch:
;; 	and b			;4b6c
;; 	and b			;4b6d
;; 	and b			;4b6e
;; l4b6fh:
;; 	xor a			;4b6f
;; 	and b			;4b70
;; 	jr nz,l4b93h		;4b71
;; 	jr nz,l4b95h		;4b73
;; 	jr nz,l4b97h		;4b75
;; 	jr nz,l4b99h		;4b77
;; 	jr nz,l4b9bh		;4b79
;; 	jr nz,l4b9dh		;4b7b
;; 	jr nz,$+34		;4b7d
;; 	jr nz,l4ba1h		;4b7f
;; 	jr nz,l4ba3h		;4b81
;; 	jr nz,l4ba5h		;4b83
;; 	jr nz,$+34		;4b85
;; 	jr nz,l4ba9h		;4b87
;; 	jr nz,l4babh		;4b89
;; 	jr nz,l4badh		;4b8b
;; 	jr nz,l4bafh		;4b8d
;; 	and b			;4b8f
;; 	and b			;4b90
;; 	jr nz,l4bb3h		;4b91
;; l4b93h:
;; 	jr nz,l4b29h		;4b93
;; l4b95h:
;; 	inc de			;4b95
;; 	sub a			;4b96
;; l4b97h:
;; 	sub (hl)			;4b97
;; l4b98h:
;; 	inc de			;4b98
;; l4b99h:
;; 	sub a			;4b99
;; 	sub l			;4b9a
;; l4b9bh:
;; 	djnz $+23		;4b9b
;; l4b9dh:
;; 	inc de			;4b9d
;; 	ld d,015h		;4b9e
;; 	inc de			;4ba0
;; l4ba1h:
;; 	ld (de),a			;4ba1
;; 	sub l			;4ba2
;; l4ba3h:
;; 	sub h			;4ba3
;; 	inc de			;4ba4
;; l4ba5h:
;; 	dec d			;4ba5
;; 	djnz l4bb8h		;4ba6
;; 	sub h			;4ba8
;; l4ba9h:
;; 	inc de			;4ba9
;; 	sub a			;4baa
;; l4babh:
;; 	djnz l4bbdh		;4bab
;; l4badh:
;; 	djnz l4bbfh		;4bad
;; l4bafh:
;; 	and b			;4baf
;; 	and b			;4bb0
;; 	jr nz,l4bc3h		;4bb1
;; l4bb3h:
;; 	djnz $-109		;4bb3
;; 	sub e			;4bb5
;; 	ld (de),a			;4bb6
;; 	sub l			;4bb7
;; l4bb8h:
;; 	djnz l4b4fh		;4bb8
;; 	sub l			;4bba
;; 	djnz $+23		;4bbb
;; l4bbdh:
;; 	djnz $+23		;4bbd
;; l4bbfh:
;; 	dec d			;4bbf
;; 	sub e			;4bc0
;; 	djnz l4b58h		;4bc1
;; l4bc3h:
;; 	sub c			;4bc3
;; 	sub a			;4bc4
;; 	dec d			;4bc5
;; 	djnz l4bd8h		;4bc6
;; 	sub l			;4bc8
;; 	djnz l4b60h		;4bc9
;; 	djnz l4bddh		;4bcb
;; 	djnz l4bdfh		;4bcd
;; 	and b			;4bcf
;; l4bd0h:
;; 	and b			;4bd0
;; 	djnz l4be3h		;4bd1
;; 	djnz l4b6ah		;4bd3
;; 	djnz l4b6ch		;4bd5
;; 	sub l			;4bd7
;; l4bd8h:
;; 	djnz l4b6fh		;4bd8
;; 	sub l			;4bda
;; 	djnz $+23		;4bdb
;; l4bddh:
;; 	djnz $+23		;4bdd
;; l4bdfh:
;; 	dec d			;4bdf
;; 	djnz $+18		;4be0
;; 	sub l			;4be2
;; l4be3h:
;; 	sub l			;4be3
;; 	djnz l4bfbh		;4be4
;; 	djnz $+18		;4be6
;; 	sub l			;4be8
;; 	djnz $-105		;4be9
;; 	djnz l4bfdh		;4beb
;; 	djnz l4bffh		;4bed
;; 	and b			;4bef
;; l4bf0h:
;; 	and b			;4bf0
;; 	djnz l4c03h		;4bf1
;; 	djnz $-109		;4bf3
;; 	sub e			;4bf5
;; 	ld (de),a			;4bf6
;; 	ld d,093h		;4bf7
;; 	ld (de),a			;4bf9
;; 	sub c			;4bfa
;; l4bfbh:
;; 	sub e			;4bfb
;; 	dec d			;4bfc
;; l4bfdh:
;; 	sub e			;4bfd
;; 	sub (hl)			;4bfe
;; l4bffh:
;; 	dec d			;4bff
;; 	djnz $+18		;4c00
;; 	sub l			;4c02
;; l4c03h:
;; 	sub c			;4c03
;; 	sub e			;4c04
;; 	dec d			;4c05
;; 	sub e			;4c06
;; 	sub a			;4c07
;; 	sub c			;4c08
;; 	sub e			;4c09
;; 	ld (de),a			;4c0a
;; 	jr nz,l4c2dh		;4c0b
;; 	jr nz,l4c2fh		;4c0d
;; 	and b			;4c0f
;; 	and b			;4c10
;; 	jr nz,l4c33h		;4c11
;; 	jr nz,l4c35h		;4c13
;; 	jr nz,l4c37h		;4c15
;; 	jr nz,$+34		;4c17
;; 	jr nz,l4c2bh		;4c19
;; 	djnz l4c2dh		;4c1b
;; 	djnz l4c3fh		;4c1d
;; 	jr nz,$+34		;4c1f
;; 	jr nz,l4c43h		;4c21
;; 	jr nz,l4c45h		;4c23
;; 	jr nz,$+34		;4c25
;; 	jr nz,$+34		;4c27
;; 	jr nz,$+34		;4c29
;; l4c2bh:
;; 	jr nz,$+34		;4c2b
;; l4c2dh:
;; 	jr nz,$+34		;4c2d
;; l4c2fh:
;; 	and b			;4c2f
;; 	and b			;4c30
;; 	jr nz,l4c53h		;4c31
;; l4c33h:
;; 	jr nz,l4c55h		;4c33
;; l4c35h:
;; 	jr nz,l4c57h		;4c35
;; l4c37h:
;; 	sub l			;4c37
;; 	djnz $+23		;4c38
;; 	dec d			;4c3a
;; 	sub a			;4c3b
;; 	djnz l4bd0h		;4c3c
;; 	dec d			;4c3e
;; l4c3fh:
;; 	ld de,01317h		;4c3f
;; 	dec d			;4c42
;; l4c43h:
;; 	inc de			;4c43
;; 	ld (de),a			;4c44
;; l4c45h:
;; 	sub h			;4c45
;; 	ld d,010h		;4c46
;; 	djnz l4c5ah		;4c48
;; 	djnz $+18		;4c4a
;; 	djnz l4c5eh		;4c4c
;; 	djnz l4bf0h		;4c4e
;; 	and b			;4c50
;; 	djnz l4c63h		;4c51
;; l4c53h:
;; 	djnz $+18		;4c53
;; l4c55h:
;; 	djnz l4c67h		;4c55
;; l4c57h:
;; 	sub l			;4c57
;; 	djnz l4c6fh		;4c58
;; l4c5ah:
;; 	dec d			;4c5a
;; 	ld de,01596h		;4c5b
;; l4c5eh:
;; 	dec d			;4c5e
;; 	djnz $+23		;4c5f
;; 	djnz l4c78h		;4c61
;; l4c63h:
;; 	sub e			;4c63
;; 	djnz l4bfbh		;4c64
;; 	dec d			;4c66
;; l4c67h:
;; 	djnz $+18		;4c67
;; 	djnz l4c7bh		;4c69
;; 	djnz l4c7dh		;4c6b
;; 	djnz l4c7fh		;4c6d
;; l4c6fh:
;; 	and b			;4c6f
;; 	and b			;4c70
;; 	djnz l4c83h		;4c71
;; 	djnz l4c85h		;4c73
;; 	djnz l4c87h		;4c75
;; 	sub l			;4c77
;; l4c78h:
;; 	djnz l4c8fh		;4c78
;; 	dec d			;4c7a
;; l4c7bh:
;; 	djnz l4c8dh		;4c7b
;; l4c7dh:
;; 	dec d			;4c7d
;; 	dec d			;4c7e
;; l4c7fh:
;; 	djnz $+23		;4c7f
;; 	djnz l4c98h		;4c81
;; l4c83h:
;; 	djnz l4c95h		;4c83
;; l4c85h:
;; 	sub l			;4c85
;; 	dec d			;4c86
;; l4c87h:
;; 	djnz l4c99h		;4c87
;; 	djnz l4c9bh		;4c89
;; 	djnz l4c9dh		;4c8b
;; l4c8dh:
;; 	djnz l4c9fh		;4c8d
;; l4c8fh:
;; 	and b			;4c8f
;; 	and b			;4c90
;; 	djnz l4ca3h		;4c91
;; 	djnz l4ca5h		;4c93
;; l4c95h:
;; 	djnz l4ca7h		;4c95
;; 	sub c			;4c97
;; l4c98h:
;; 	sub e			;4c98
;; l4c99h:
;; 	dec d			;4c99
;; l4c9ah:
;; 	dec d			;4c9a
;; l4c9bh:
;; 	djnz l4cadh		;4c9b
;; l4c9dh:
;; 	dec d			;4c9d
;; 	dec d			;4c9e
;; l4c9fh:
;; 	djnz $+23		;4c9f
;; 	djnz $+23		;4ca1
;; l4ca3h:
;; 	sub e			;4ca3
;; 	sub a			;4ca4
;; l4ca5h:
;; 	sub c			;4ca5
;; 	sub (hl)			;4ca6
;; l4ca7h:
;; 	djnz l4cb9h		;4ca7
;; 	djnz l4cbbh		;4ca9
;; 	djnz l4cbdh		;4cab
;; l4cadh:
;; 	djnz l4cbfh		;4cad
;; 	and b			;4caf
;; 	and b			;4cb0
;; 	djnz l4cc3h		;4cb1
;; 	djnz l4cc5h		;4cb3
;; 	djnz l4cc7h		;4cb5
;; 	djnz l4cc9h		;4cb7
;; l4cb9h:
;; 	djnz l4ccbh		;4cb9
;; l4cbbh:
;; 	djnz l4ccdh		;4cbb
;; l4cbdh:
;; 	djnz l4ccfh		;4cbd
;; l4cbfh:
;; 	djnz l4cd1h		;4cbf
;; 	djnz l4cd3h		;4cc1
;; l4cc3h:
;; 	djnz l4cd5h		;4cc3
;; l4cc5h:
;; 	djnz l4cd7h		;4cc5
;; l4cc7h:
;; 	djnz l4cd9h		;4cc7
;; l4cc9h:
;; 	djnz $+18		;4cc9
;; l4ccbh:
;; 	djnz l4cddh		;4ccb
;; l4ccdh:
;; 	djnz l4cdfh		;4ccd
;; l4ccfh:
;; 	and b			;4ccf
;; 	and b			;4cd0
;; l4cd1h:
;; 	jr nz,l4ce3h		;4cd1
;; l4cd3h:
;; 	sub (hl)			;4cd3
;; 	inc de			;4cd4
;; l4cd5h:
;; 	sub a			;4cd5
;; 	sub (hl)			;4cd6
;; l4cd7h:
;; 	inc de			;4cd7
;; 	sub a			;4cd8
;; l4cd9h:
;; 	sub c			;4cd9
;; l4cdah:
;; 	djnz l4cf0h		;4cda
;; l4cdch:
;; 	sub l			;4cdc
;; l4cddh:
;; 	sub h			;4cdd
;; 	inc de			;4cde
;; l4cdfh:
;; 	sub a			;4cdf
;; 	sub l			;4ce0
;; 	djnz l4c78h		;4ce1
;; l4ce3h:
;; 	inc de			;4ce3
;; 	sub h			;4ce4
;; 	ld (de),a			;4ce5
;; 	sub l			;4ce6
;; 	sub c			;4ce7
;; 	djnz l4c7fh		;4ce8
;; 	sub (hl)			;4cea
;; 	inc de			;4ceb
;; 	sub a			;4cec
;; 	djnz l4cffh		;4ced
;; 	and b			;4cef
;; l4cf0h:
;; 	and b			;4cf0
;; 	djnz l4d03h		;4cf1
;; 	sub l			;4cf3
;; 	djnz $+18		;4cf4
;; 	sub l			;4cf6
;; 	djnz $-105		;4cf7
;; 	sub l			;4cf9
;; 	ld d,012h		;4cfa
;; 	sub l			;4cfc
;; 	sub c			;4cfd
;; 	sub e			;4cfe
;; l4cffh:
;; 	ld (de),a			;4cff
;; 	sub l			;4d00
;; 	djnz l4c98h		;4d01
;; l4d03h:
;; 	djnz l4c9ah		;4d03
;; 	djnz $-105		;4d05
;; 	sub l			;4d07
;; 	sub l			;4d08
;; 	sub l			;4d09
;; 	sub l			;4d0a
;; 	djnz l4d1dh		;4d0b
;; 	djnz $+18		;4d0d
;; 	and b			;4d0f
;; 	and b			;4d10
;; 	djnz l4d23h		;4d11
;; 	sub l			;4d13
;; 	djnz $+18		;4d14
;; 	sub l			;4d16
;; 	djnz $-105		;4d17
;; 	sub l			;4d19
;; 	djnz l4d2ch		;4d1a
;; 	sub l			;4d1c
;; l4d1dh:
;; 	sub l			;4d1d
;; 	djnz l4d30h		;4d1e
;; 	sub l			;4d20
;; 	djnz $-105		;4d21
;; l4d23h:
;; 	djnz $-105		;4d23
;; 	djnz $-105		;4d25
;; 	sub l			;4d27
;; 	sub l			;4d28
;; 	sub l			;4d29
;; 	sub l			;4d2a
;; 	inc de			;4d2b
;; l4d2ch:
;; 	sub l			;4d2c
;; 	djnz $+18		;4d2d
;; 	and b			;4d2f
;; l4d30h:
;; 	and b			;4d30
;; 	djnz l4d43h		;4d31
;; 	ld d,093h		;4d33
;; 	ld (de),a			;4d35
;; 	ld d,093h		;4d36
;; 	ld (de),a			;4d38
;; 	sub l			;4d39
;; 	djnz l4d4ch		;4d3a
;; 	sub l			;4d3c
;; 	sub l			;4d3d
;; 	djnz l4d50h		;4d3e
;; 	ld d,093h		;4d40
;; 	ld (de),a			;4d42
;; l4d43h:
;; 	djnz l4cdah		;4d43
;; 	djnz l4cdch		;4d45
;; 	sub l			;4d47
;; 	ld de,01695h		;4d48
;; 	sub e			;4d4b
;; l4d4ch:
;; 	ld (de),a			;4d4c
;; 	djnz l4d5fh		;4d4d
;; 	and b			;4d4f
;; l4d50h:
;; 	sub (hl)			;4d50
;; 	inc de			;4d51
;; 	ld b,b			;4d52
;; 	nop			;4d53
;; 	and b			;4d54
;; 	jr nz,l4d77h		;4d55
;; 	jr nz,l4d79h		;4d57
;; 	jr nz,l4d7bh		;4d59
;; 	jr nz,l4d7dh		;4d5b
;; 	jr nz,l4d7fh		;4d5d
;; l4d5fh:
;; 	jr nz,l4d81h		;4d5f
;; 	jr nz,l4d83h		;4d61
;; 	jr nz,l4d85h		;4d63
;; 	jr nz,l4d87h		;4d65
;; 	jr nz,l4d89h		;4d67
;; 	jr nz,l4d8bh		;4d69
;; 	jr nz,l4d8dh		;4d6b
;; 	jr nz,l4d8fh		;4d6d
;; 	jr nz,l4d91h		;4d6f
;; 	jr nz,l4d93h		;4d71
;; 	and b			;4d73
;; 	xor a			;4d74
;; 	and b			;4d75
;; 	and b			;4d76
;; l4d77h:
;; 	and b			;4d77
;; 	and b			;4d78
;; l4d79h:
;; 	and b			;4d79
;; 	and b			;4d7a
;; l4d7bh:
;; 	and b			;4d7b
;; 	and b			;4d7c
;; l4d7dh:
;; 	and b			;4d7d
;; 	and b			;4d7e
;; l4d7fh:
;; 	and b			;4d7f
;; 	and b			;4d80
;; l4d81h:
;; 	and b			;4d81
;; 	and b			;4d82
;; l4d83h:
;; 	and b			;4d83
;; 	and b			;4d84
;; l4d85h:
;; 	and b			;4d85
;; 	and b			;4d86
;; l4d87h:
;; 	and b			;4d87
;; 	and b			;4d88
;; l4d89h:
;; 	and b			;4d89
;; 	and b			;4d8a
;; l4d8bh:
;; 	and b			;4d8b
;; 	and b			;4d8c
;; l4d8dh:
;; 	and b			;4d8d
;; 	and b			;4d8e
;; l4d8fh:
;; 	and b			;4d8f
;; 	and b			;4d90
;; l4d91h:
;; 	and b			;4d91
;; 	and b			;4d92
;; l4d93h:
;; 	call c,01011h		;4d93
;; 	dec d			;4d96
;; 	nop			;4d97
;; 	ld de,00010h		;4d98
;; 	nop			;4d9b
;; 	add hl,de			;4d9c
;; l4d9dh:
;; 	dec bc			;4d9d
;; 	sub (hl)			;4d9e
;; 	inc de			;4d9f
;; 	jr nz,l4da2h		;4da0
;; l4da2h:
;; 	ret nc			;4da2
;; 	and b			;4da3
;; 	jp nc,0c5a0h		;4da4
;; 	and b			;4da7
;; 	out (0a0h),a		;4da8
;; 	push bc			;4daa
;; 	and b			;4dab
;; 	adc a,0a0h		;4dac
;; 	call nc,0d3a0h		;4dae
;; l4db1h:
;; 	and b			;4db1
;; 	and b			;4db2
;; 	and b			;4db3
;; 	and b			;4db4
;; 	and b			;4db5
;; 	and b			;4db6
;; 	and b			;4db7
;; 	and b			;4db8
;; 	and b			;4db9
;; 	and b			;4dba
;; 	and b			;4dbb
;; 	and b			;4dbc
;; l4dbdh:
;; 	and b			;4dbd
;; 	and b			;4dbe
;; 	and b			;4dbf
;; 	and b			;4dc0
;; 	and b			;4dc1
;; 	or (hl)			;4dc2
;; 	inc b			;4dc3
;; 	ld d,h			;4dc4
;; 	ld c,c			;4dc5
;; 	ld d,h			;4dc6
;; 	ld c,h			;4dc7
;; 	ld b,l			;4dc8
;; 	or d			;4dc9
;; 	defb 0edh;next byte illegal after ed		;4dca
;; 	ld bc,04b47h		;4dcb
;; l4dceh:
;; 	ld b,0c3h		;4dce
;; 	ld c,01dh		;4dd0
;; 	ld a,(bc)			;4dd2
;; 	sub (hl)			;4dd3
;; 	inc de			;4dd4
;; 	sbc a,001h		;4dd5
;; 	jr nz,l4df9h		;4dd7
;; 	jr nz,l4dfbh		;4dd9
;; 	jr nz,l4d7dh		;4ddb
;; l4dddh:
;; 	and b			;4ddd
;; 	and b			;4dde
;; 	and b			;4ddf
;; 	and b			;4de0
;; 	and b			;4de1
;; 	and b			;4de2
;; 	and b			;4de3
;; 	and b			;4de4
;; 	and b			;4de5
;; 	and b			;4de6
;; 	and b			;4de7
;; 	and b			;4de8
;; 	and b			;4de9
;; 	and b			;4dea
;; 	and b			;4deb
;; 	and b			;4dec
;; 	and b			;4ded
;; 	and b			;4dee
;; 	and b			;4def
;; 	and b			;4df0
;; l4df1h:
;; 	jr nz,l4e13h		;4df1
;; 	jr nz,l4e15h		;4df3
;; 	jr nz,l4e17h		;4df5
;; 	jr nz,l4e19h		;4df7
;; l4df9h:
;; 	jr nz,l4e1bh		;4df9
;; l4dfbh:
;; 	jr nz,l4d9dh		;4dfb
;; l4dfdh:
;; 	jr nz,l4e1fh		;4dfd
;; 	jr nz,l4e21h		;4dff
;; 	jr nz,l4e23h		;4e01
;; 	jr nz,l4e25h		;4e03
;; 	jr nz,l4e27h		;4e05
;; 	jr nz,l4e29h		;4e07
;; 	jr nz,l4e2bh		;4e09
;; 	jr nz,l4e2dh		;4e0b
;; 	jr nz,l4e2fh		;4e0d
;; 	jr nz,l4db1h		;4e0f
;; 	jr nz,l4e33h		;4e11
;; l4e13h:
;; 	jr nz,l4e35h		;4e13
;; l4e15h:
;; 	jr nz,l4e37h		;4e15
;; l4e17h:
;; 	jr nz,l4e39h		;4e17
;; l4e19h:
;; 	jr nz,l4e3bh		;4e19
;; l4e1bh:
;; 	jr nz,l4dbdh		;4e1b
;; 	jr nz,l4e62h		;4e1d
;; l4e1fh:
;; 	jr nz,l4e66h		;4e1f
;; l4e21h:
;; 	jr nz,l4e71h		;4e21
;; l4e23h:
;; 	jr nz,l4e79h		;4e23
;; l4e25h:
;; 	jr nz,l4e70h		;4e25
;; l4e27h:
;; 	jr nz,l4e79h		;4e27
;; l4e29h:
;; 	jr nz,l4e70h		;4e29
;; l4e2bh:
;; 	jr nz,l4e71h		;4e2b
;; l4e2dh:
;; 	jr nz,$+71		;4e2d
;; l4e2fh:
;; 	jr nz,$-94		;4e2f
;; 	jr nz,l4e53h		;4e31
;; l4e33h:
;; 	jr nz,l4e55h		;4e33
;; l4e35h:
;; 	jr nz,l4e57h		;4e35
;; l4e37h:
;; 	jr nz,l4e59h		;4e37
;; l4e39h:
;; 	jr nz,l4e5bh		;4e39
;; l4e3bh:
;; 	jr nz,l4dddh		;4e3b
;; 	jr nz,l4e5fh		;4e3d
;; l4e3fh:
;; 	jr nz,l4e61h		;4e3f
;; 	jr nz,l4e63h		;4e41
;; 	jr nz,l4e65h		;4e43
;; 	jr nz,l4e67h		;4e45
;; 	jr nz,l4e69h		;4e47
;; 	jr nz,l4e6bh		;4e49
;; 	jr nz,l4e6dh		;4e4b
;; 	jr nz,l4e6fh		;4e4d
;; 	jr nz,l4df1h		;4e4f
;; 	jr nz,l4e73h		;4e51
;; l4e53h:
;; 	jr nz,l4e75h		;4e53
;; l4e55h:
;; 	jr nz,l4e77h		;4e55
;; l4e57h:
;; 	jr nz,l4e79h		;4e57
;; l4e59h:
;; 	jr nz,l4e7bh		;4e59
;; l4e5bh:
;; 	jr nz,l4dfdh		;4e5b
;; 	and b			;4e5d
;; 	and b			;4e5e
;; l4e5fh:
;; 	and b			;4e5f
;; 	and b			;4e60
;; l4e61h:
;; 	and b			;4e61
;; l4e62h:
;; 	and b			;4e62
;; l4e63h:
;; 	and b			;4e63
;; 	and b			;4e64
;; l4e65h:
;; 	and b			;4e65
;; l4e66h:
;; 	and b			;4e66
;; l4e67h:
;; 	and b			;4e67
;; 	and b			;4e68
;; l4e69h:
;; 	and b			;4e69
;; 	and b			;4e6a
;; l4e6bh:
;; 	and b			;4e6b
;; 	and b			;4e6c
;; l4e6dh:
;; 	and b			;4e6d
;; 	and b			;4e6e
;; l4e6fh:
;; 	and b			;4e6f
;; l4e70h:
;; 	and b			;4e70
;; l4e71h:
;; 	jr nz,l4e93h		;4e71
;; l4e73h:
;; 	jr nz,l4e95h		;4e73
;; l4e75h:
;; 	jr nz,l4e97h		;4e75
;; l4e77h:
;; 	jr nz,l4e99h		;4e77
;; l4e79h:
;; 	jr nz,l4e9bh		;4e79
;; l4e7bh:
;; 	jr nz,l4e9dh		;4e7b
;; 	jr nz,l4e9fh		;4e7d
;; l4e7fh:
;; 	jr nz,l4ea1h		;4e7f
;; 	jr nz,l4ea3h		;4e81
;; 	jr nz,l4ea5h		;4e83
;; l4e85h:
;; 	jr nz,l4ea7h		;4e85
;; 	jr nz,l4ea9h		;4e87
;; 	jr nz,l4eabh		;4e89
;; 	jr nz,l4eadh		;4e8b
;; 	jr nz,l4eafh		;4e8d
;; 	jr nz,l4eb1h		;4e8f
;; 	jr nz,l4eb3h		;4e91
;; l4e93h:
;; 	jr nz,l4eb5h		;4e93
;; l4e95h:
;; 	jr nz,l4eb7h		;4e95
;; l4e97h:
;; 	jr nz,l4eb9h		;4e97
;; l4e99h:
;; 	jr nz,l4ebbh		;4e99
;; l4e9bh:
;; 	jr nz,l4ebdh		;4e9b
;; l4e9dh:
;; 	jr nz,l4e3fh		;4e9d
;; l4e9fh:
;; 	and b			;4e9f
;; 	and b			;4ea0
;; l4ea1h:
;; 	and b			;4ea1
;; 	and b			;4ea2
;; l4ea3h:
;; 	and b			;4ea3
;; 	and b			;4ea4
;; l4ea5h:
;; 	jr nz,l4ec7h		;4ea5
;; l4ea7h:
;; 	jr nz,l4ec9h		;4ea7
;; l4ea9h:
;; 	jr nz,l4ecbh		;4ea9
;; l4eabh:
;; 	jr nz,l4ecdh		;4eab
;; l4eadh:
;; 	jr nz,l4ecfh		;4ead
;; l4eafh:
;; 	jr nz,l4ed1h		;4eaf
;; l4eb1h:
;; 	jr nz,l4ed3h		;4eb1
;; l4eb3h:
;; 	jr nz,l4ed5h		;4eb3
;; l4eb5h:
;; 	jr nz,l4ed7h		;4eb5
;; l4eb7h:
;; 	jr nz,l4ed9h		;4eb7
;; l4eb9h:
;; 	jr nz,l4edbh		;4eb9
;; l4ebbh:
;; 	jr nz,l4eddh		;4ebb
;; l4ebdh:
;; 	jr nz,l4e5fh		;4ebd
;; l4ebfh:
;; 	jr nz,l4ee1h		;4ebf
;; 	jr nz,l4ee3h		;4ec1
;; 	jr nz,l4e65h		;4ec3
;; 	jr nz,l4ee7h		;4ec5
;; l4ec7h:
;; 	jr nz,l4ee9h		;4ec7
;; l4ec9h:
;; 	jr nz,l4eebh		;4ec9
;; l4ecbh:
;; 	jr nz,l4eedh		;4ecb
;; l4ecdh:
;; 	jr nz,l4eefh		;4ecd
;; l4ecfh:
;; 	jr nz,l4ef1h		;4ecf
;; l4ed1h:
;; 	jr nz,l4ef3h		;4ed1
;; l4ed3h:
;; 	jr nz,l4ef5h		;4ed3
;; l4ed5h:
;; 	jr nz,l4ef7h		;4ed5
;; l4ed7h:
;; 	jr nz,l4ef9h		;4ed7
;; l4ed9h:
;; 	jr nz,l4efbh		;4ed9
;; l4edbh:
;; 	jr nz,l4efdh		;4edb
;; l4eddh:
;; 	jr nz,l4e7fh		;4edd
;; 	jr nz,l4f23h		;4edf
;; l4ee1h:
;; 	jr nz,$+91		;4ee1
;; l4ee3h:
;; 	jr nz,l4e85h		;4ee3
;; 	jr nz,l4f07h		;4ee5
;; l4ee7h:
;; 	jr nz,l4f09h		;4ee7
;; l4ee9h:
;; 	jr nz,l4f0bh		;4ee9
;; l4eebh:
;; 	jr nz,l4f0dh		;4eeb
;; l4eedh:
;; 	jr nz,l4f0fh		;4eed
;; l4eefh:
;; 	jr nz,l4f11h		;4eef
;; l4ef1h:
;; 	jr nz,l4f13h		;4ef1
;; l4ef3h:
;; 	jr nz,l4f15h		;4ef3
;; l4ef5h:
;; 	jr nz,l4f17h		;4ef5
;; l4ef7h:
;; 	jr nz,l4f19h		;4ef7
;; l4ef9h:
;; 	jr nz,l4f1bh		;4ef9
;; l4efbh:
;; 	jr nz,l4f1dh		;4efb
;; l4efdh:
;; 	jr nz,l4e9fh		;4efd
;; 	jr nz,l4f21h		;4eff
;; 	jr nz,l4f23h		;4f01
;; l4f03h:
;; 	jr nz,l4ea5h		;4f03
;; 	jr nz,l4f27h		;4f05
;; l4f07h:
;; 	jr nz,l4f29h		;4f07
;; l4f09h:
;; 	jr nz,l4f2bh		;4f09
;; l4f0bh:
;; 	jr nz,l4f2dh		;4f0b
;; l4f0dh:
;; 	jr nz,l4f2fh		;4f0d
;; l4f0fh:
;; 	jr nz,l4f31h		;4f0f
;; l4f11h:
;; 	jr nz,l4f33h		;4f11
;; l4f13h:
;; 	jr nz,l4f35h		;4f13
;; l4f15h:
;; 	jr nz,l4f37h		;4f15
;; l4f17h:
;; 	jr nz,l4f39h		;4f17
;; l4f19h:
;; 	jr nz,l4f3bh		;4f19
;; l4f1bh:
;; 	jr nz,l4f3dh		;4f1b
;; l4f1dh:
;; 	jr nz,l4ebfh		;4f1d
;; 	and b			;4f1f
;; 	and b			;4f20
;; l4f21h:
;; 	and b			;4f21
;; 	and b			;4f22
;; l4f23h:
;; 	and b			;4f23
;; 	and b			;4f24
;; 	and b			;4f25
;; 	and b			;4f26
;; l4f27h:
;; 	and b			;4f27
;; 	and b			;4f28
;; l4f29h:
;; 	and b			;4f29
;; 	and b			;4f2a
;; l4f2bh:
;; 	and b			;4f2b
;; 	and b			;4f2c
;; l4f2dh:
;; 	and b			;4f2d
;; 	and b			;4f2e
;; l4f2fh:
;; 	and b			;4f2f
;; 	and b			;4f30
;; l4f31h:
;; 	and b			;4f31
;; 	and b			;4f32
;; l4f33h:
;; 	and b			;4f33
;; 	and b			;4f34
;; l4f35h:
;; 	jr nz,l4f57h		;4f35
;; l4f37h:
;; 	jr nz,l4f59h		;4f37
;; l4f39h:
;; 	jr nz,l4f5bh		;4f39
;; l4f3bh:
;; 	jr nz,l4f5dh		;4f3b
;; l4f3dh:
;; 	jr nz,l4f5fh		;4f3d
;; 	jr nz,l4f61h		;4f3f
;; 	jr nz,l4ee3h		;4f41
;; l4f43h:
;; 	jr nz,l4f65h		;4f43
;; 	jr nz,l4f67h		;4f45
;; 	jr nz,l4f69h		;4f47
;; 	jr nz,l4f6bh		;4f49
;; 	jr nz,l4f6dh		;4f4b
;; 	jr nz,l4f6fh		;4f4d
;; 	jr nz,l4f71h		;4f4f
;; 	jr nz,l4f73h		;4f51
;; 	jr nz,l4ef5h		;4f53
;; 	jr nz,l4f77h		;4f55
;; l4f57h:
;; 	jr nz,l4f79h		;4f57
;; l4f59h:
;; 	jr nz,l4f7bh		;4f59
;; l4f5bh:
;; 	jr nz,l4f7dh		;4f5b
;; l4f5dh:
;; 	jr nz,l4f7fh		;4f5d
;; l4f5fh:
;; 	jr nz,l4f81h		;4f5f
;; l4f61h:
;; 	jr nz,l4f03h		;4f61
;; 	jr nz,l4fa8h		;4f63
;; l4f65h:
;; 	jr nz,l4f95h		;4f65
;; l4f67h:
;; 	jr nz,l4fadh		;4f67
;; l4f69h:
;; 	jr nz,l4fbah		;4f69
;; l4f6bh:
;; 	jr nz,l4fbch		;4f6b
;; l4f6dh:
;; 	jr nz,l4fbbh		;4f6d
;; l4f6fh:
;; 	jr nz,l4fb6h		;4f6f
;; l4f71h:
;; 	jr nz,$+91		;4f71
;; l4f73h:
;; 	jr nz,l4f15h		;4f73
;; 	jr nz,l4f97h		;4f75
;; l4f77h:
;; 	jr nz,l4f99h		;4f77
;; l4f79h:
;; 	jr nz,l4f9bh		;4f79
;; l4f7bh:
;; 	jr nz,l4f9dh		;4f7b
;; l4f7dh:
;; 	jr nz,l4f9fh		;4f7d
;; l4f7fh:
;; 	jr nz,l4fa1h		;4f7f
;; l4f81h:
;; 	jr nz,l4f23h		;4f81
;; 	jr nz,l4fa5h		;4f83
;; 	jr nz,l4fa7h		;4f85
;; 	jr nz,l4fa9h		;4f87
;; 	jr nz,l4fabh		;4f89
;; 	jr nz,l4fadh		;4f8b
;; 	jr nz,l4fafh		;4f8d
;; 	jr nz,l4fb1h		;4f8f
;; 	jr nz,l4fb3h		;4f91
;; 	jr nz,l4f35h		;4f93
;; l4f95h:
;; 	jr nz,l4fb7h		;4f95
;; l4f97h:
;; 	jr nz,l4fb9h		;4f97
;; l4f99h:
;; 	jr nz,l4fbbh		;4f99
;; l4f9bh:
;; 	jr nz,l4fbdh		;4f9b
;; l4f9dh:
;; 	jr nz,$+34		;4f9d
;; l4f9fh:
;; 	jr nz,l4fc1h		;4f9f
;; l4fa1h:
;; 	jr nz,l4f43h		;4fa1
;; 	and b			;4fa3
;; 	and b			;4fa4
;; l4fa5h:
;; 	and b			;4fa5
;; 	and b			;4fa6
;; l4fa7h:
;; 	and b			;4fa7
;; l4fa8h:
;; 	and b			;4fa8
;; l4fa9h:
;; 	and b			;4fa9
;; 	and b			;4faa
;; l4fabh:
;; 	and b			;4fab
;; 	and b			;4fac
;; l4fadh:
;; 	and b			;4fad
;; 	and b			;4fae
;; l4fafh:
;; 	and b			;4faf
;; 	and b			;4fb0
;; l4fb1h:
;; 	and b			;4fb1
;; 	and b			;4fb2
;; l4fb3h:
;; 	and b			;4fb3
;; 	and b			;4fb4
;; 	or (hl)			;4fb5
;; l4fb6h:
;; 	inc b			;4fb6
;; l4fb7h:
;; 	ld d,h			;4fb7
;; 	ld c,c			;4fb8
;; l4fb9h:
;; 	ld d,h			;4fb9
;; l4fbah:
;; 	ld c,h			;4fba
;; l4fbbh:
;; 	ld b,l			;4fbb
;; l4fbch:
;; 	or e			;4fbc
;; l4fbdh:
;; 	ld b,a			;4fbd
;; 	ld bc,l4dceh		;4fbe
;; l4fc1h:
;; 	ld b,0c3h		;4fc1
;; 	ld c,01dh		;4fc3
;; 	ld a,(bc)			;4fc5
;; 	ld de,00310h		;4fc6
;; 	nop			;4fc9
;; 	ld de,00010h		;4fca
;; 	nop			;4fcd
;; 	add hl,de			;4fce
;; 	dec bc			;4fcf
;; 	sub (hl)			;4fd0
;; 	inc de			;4fd1
;; 	nop			;4fd2
;; 	ld bc,0a0a0h		;4fd3
;; 	and b			;4fd6
;; 	and b			;4fd7
;; 	and b			;4fd8
;; 	and b			;4fd9
;; 	and b			;4fda
;; 	and b			;4fdb
;; 	and b			;4fdc
;; 	and b			;4fdd
;; 	and b			;4fde
;; 	and b			;4fdf
;; 	and b			;4fe0
;; 	and b			;4fe1
;; 	and b			;4fe2
;; 	and b			;4fe3
;; 	and b			;4fe4
;; 	and b			;4fe5
;; 	and b			;4fe6
;; 	and b			;4fe7
;; 	and b			;4fe8
;; 	and b			;4fe9
;; 	and b			;4fea
;; 	and b			;4feb
;; 	and b			;4fec
;; 	and b			;4fed
;; 	and b			;4fee
;; 	and b			;4fef
;; 	and b			;4ff0
;; 	and b			;4ff1
;; 	and b			;4ff2
;; 	and b			;4ff3
;; 	sub l			;4ff4
;; 	jr nz,l5017h		;4ff5
;; 	jr nz,l5019h		;4ff7
;; 	jr nz,l501bh		;4ff9
;; 	jr nz,l501dh		;4ffb
;; 	jr nz,$+34		;4ffd
;; 	jr nz,$+34		;4fff
;; 	jr nz,l5023h		;5001
;; 	jr nz,l5025h		;5003
;; 	jr nz,l5027h		;5005
;; 	jr nz,l5029h		;5007
;; 	jr nz,$+34		;5009
;; 	jr nz,l502dh		;500b
;; 	jr nz,$+34		;500d
;; 	jr nz,l5031h		;500f
;; 	jr nz,l5033h		;5011
;; 	dec d			;5013
;; 	sub l			;5014
;; 	ld b,e			;5015
;; 	ld l,a			;5016
;; l5017h:
;; 	ld (hl),b			;5017
;; 	ld a,c			;5018
;; l5019h:
;; 	ld (hl),d			;5019
;; 	ld l,c			;501a
;; l501bh:
;; 	ld h,a			;501b
;; 	ld l,b			;501c
;; l501dh:
;; 	ld (hl),h			;501d
;; 	jr nz,l509fh		;501e
;; 	jr nz,l5064h		;5020
;; 	ld l,a			;5022
;; l5023h:
;; 	ld l,h			;5023
;; 	ld h,h			;5024
;; l5025h:
;; 	ld h,(hl)			;5025
;; 	ld l,c			;5026
;; l5027h:
;; 	ld h,l			;5027
;; 	ld l,h			;5028
;; l5029h:
;; 	ld h,h			;5029
;; 	jr nz,$+78		;502a
;; 	ld (hl),h			;502c
;; l502dh:
;; 	ld h,h			;502d
;; 	ld l,031h		;502e
;; 	add hl,sp			;5030
;; l5031h:
;; 	jr c,l5067h		;5031
;; l5033h:
;; 	dec d			;5033
;; 	sub l			;5034
;; 	jr nz,l5057h		;5035
;; 	jr nz,l5059h		;5037
;; 	jr nz,l505bh		;5039
;; 	jr nz,l505dh		;503b
;; 	jr nz,l505fh		;503d
;; 	jr nz,l5061h		;503f
;; 	jr nz,$+34		;5041
;; 	jr nz,l5065h		;5043
;; 	jr nz,l5067h		;5045
;; 	jr nz,l5069h		;5047
;; 	jr nz,l506bh		;5049
;; 	jr nz,l506dh		;504b
;; 	jr nz,l506fh		;504d
;; 	jr nz,l5071h		;504f
;; 	jr nz,$+34		;5051
;; 	dec d			;5053
;; 	sub l			;5054
;; 	jr nz,$+87		;5055
;; l5057h:
;; 	ld l,(hl)			;5057
;; 	ld h,c			;5058
;; l5059h:
;; 	ld (hl),l			;5059
;; 	ld (hl),h			;505a
;; l505bh:
;; 	ld l,b			;505b
;; 	ld l,a			;505c
;; l505dh:
;; 	ld (hl),d			;505d
;; 	ld l,c			;505e
;; l505fh:
;; 	ld (hl),e			;505f
;; 	ld h,l			;5060
;; l5061h:
;; 	ld h,h			;5061
;; 	jr nz,$+116		;5062
;; l5064h:
;; 	ld h,l			;5064
;; l5065h:
;; 	ld (hl),b			;5065
;; 	ld (hl),d			;5066
;; l5067h:
;; 	ld l,a			;5067
;; 	ld h,h			;5068
;; l5069h:
;; 	ld (hl),l			;5069
;; 	ld h,e			;506a
;; l506bh:
;; 	ld (hl),h			;506b
;; 	ld l,c			;506c
;; l506dh:
;; 	ld l,a			;506d
;; 	ld l,(hl)			;506e
;; l506fh:
;; 	jr nz,l50e0h		;506f
;; l5071h:
;; 	ld h,(hl)			;5071
;; 	jr nz,$+23		;5072
;; 	sub l			;5074
;; 	jr nz,l5097h		;5075
;; 	jr nz,l50edh		;5077
;; 	ld l,b			;5079
;; 	ld l,c			;507a
;; 	ld (hl),e			;507b
;; l507ch:
;; 	jr nz,$+101		;507c
;; 	ld h,c			;507e
;; 	ld (hl),e			;507f
;; 	ld (hl),e			;5080
;; 	ld h,l			;5081
;; 	ld (hl),h			;5082
;; 	ld (hl),h			;5083
;; 	ld h,l			;5084
;; 	jr nz,l50f0h		;5085
;; 	ld (hl),e			;5087
;; 	jr nz,$+107		;5088
;; 	ld l,h			;508a
;; 	ld l,h			;508b
;; 	ld h,l			;508c
;; 	ld h,a			;508d
;; 	ld h,c			;508e
;; 	ld l,h			;508f
;; 	jr nz,$+34		;5090
;; 	jr nz,l50a9h		;5092
;; 	sub l			;5094
;; 	jr nz,l50b7h		;5095
;; l5097h:
;; 	jr nz,l50b9h		;5097
;; 	jr nz,l50bbh		;5099
;; 	jr nz,l50bdh		;509b
;; 	jr nz,l50bfh		;509d
;; l509fh:
;; 	jr nz,l50c1h		;509f
;; 	jr nz,l50c3h		;50a1
;; 	jr nz,l50c5h		;50a3
;; 	jr nz,l50c7h		;50a5
;; 	jr nz,l50c9h		;50a7
;; l50a9h:
;; 	jr nz,l50cbh		;50a9
;; 	jr nz,l50cdh		;50ab
;; 	jr nz,l50cfh		;50ad
;; 	jr nz,l50d1h		;50af
;; 	jr nz,l50d3h		;50b1
;; 	dec d			;50b3
;; 	and b			;50b4
;; 	and b			;50b5
;; 	and b			;50b6
;; l50b7h:
;; 	and b			;50b7
;; 	and b			;50b8
;; l50b9h:
;; 	and b			;50b9
;; 	and b			;50ba
;; l50bbh:
;; 	and b			;50bb
;; 	and b			;50bc
;; l50bdh:
;; 	and b			;50bd
;; 	and b			;50be
;; l50bfh:
;; 	and b			;50bf
;; 	and b			;50c0
;; l50c1h:
;; 	and b			;50c1
;; 	and b			;50c2
;; l50c3h:
;; 	and b			;50c3
;; 	and b			;50c4
;; l50c5h:
;; 	and b			;50c5
;; 	and b			;50c6
;; l50c7h:
;; 	and b			;50c7
;; 	and b			;50c8
;; l50c9h:
;; 	and b			;50c9
;; 	and b			;50ca
;; l50cbh:
;; 	and b			;50cb
;; 	and b			;50cc
;; l50cdh:
;; 	and b			;50cd
;; 	and b			;50ce
;; l50cfh:
;; 	and b			;50cf
;; 	and b			;50d0
;; l50d1h:
;; 	and b			;50d1
;; 	and b			;50d2
;; l50d3h:
;; 	and b			;50d3
;; 	ld de,01510h		;50d4
;; 	nop			;50d7
;; 	ld de,00010h		;50d8
;; 	nop			;50db
;; 	add hl,de			;50dc
;; 	dec bc			;50dd
;; 	sub (hl)			;50de
;; 	inc de			;50df
;; l50e0h:
;; 	jr nz,l50e2h		;50e0
;; l50e2h:
;; 	and b			;50e2
;; 	ret nc			;50e3
;; 	and b			;50e4
;; 	jp nc,0c5a0h		;50e5
;; 	and b			;50e8
;; 	out (0a0h),a		;50e9
;; 	out (0a0h),a		;50eb
;; l50edh:
;; 	and b			;50ed
;; 	push bc			;50ee
;; 	and b			;50ef
;; l50f0h:
;; 	adc a,0a0h		;50f0
;; 	call nc,0c5a0h		;50f2
;; 	and b			;50f5
;; 	jp nc,0a0a0h		;50f6
;; 	and b			;50f9
;; 	and b			;50fa
;; 	and b			;50fb
;; 	and b			;50fc
;; 	and b			;50fd
;; 	and b			;50fe
;; 	and b			;50ff
;; 	and b			;5100
;; 	and b			;5101
;; 	or (hl)			;5102
;; 	inc b			;5103
;; 	ld c,h			;5104
;; 	ret nz			;5105
;; 	ld de,0c100h		;5106
;; 	ld c,a			;5109
;; 	ld (bc),a			;510a
;; 	jp 01f0eh		;510b
;; 	ld c,037h		;510e
;; 	ld d,c			;5110
;; 	jp nc,0960dh		;5111
;; 	ex af,af'			;5114
;; 	or (hl)			;5115
;; 	inc b			;5116
;; 	ld c,(hl)			;5117
;; 	ret nz			;5118
;; 	dec d			;5119
;; 	nop			;511a
;; 	ld a,(bc)			;511b
;; 	ld d,c			;511c
;; 	ld (bc),a			;511d
;; 	jp 01f0eh		;511e
;; 	ld c,06bh		;5121
;; 	ex af,af'			;5123
;; 	jp nc,0a90dh		;5124
;; 	ld d,c			;5127
;; 	jp nc,0b30dh		;5128
;; 	ex af,af'			;512b
;; 	or (hl)			;512c
;; 	inc b			;512d
;; 	ld c,h			;512e
;; 	ld b,a			;512f
;; 	ld d,h			;5130
;; 	ret z			;5131
;; 	ld l,a			;5132
;; 	nop			;5133
;; 	dec e			;5134
;; 	ld d,c			;5135
;; 	inc b			;5136
;; 	call pe,0010fh		;5137
;; 	ld bc,00101h		;513a
;; 	ld bc,00201h		;513d
;; 	ld bc,00201h		;5140
;; 	ld bc,00201h		;5143
;; 	ld bc,00101h		;5146
;; 	ld bc,00101h		;5149
;; 	ld bc,00101h		;514c
;; 	ld bc,00101h		;514f
;; 	inc bc			;5152
;; 	ld bc,00101h		;5153
;; 	ld bc,00101h		;5156
;; 	ld (bc),a			;5159
;; 	ld bc,00201h		;515a
;; 	ld bc,00201h		;515d
;; 	ld bc,00101h		;5160
;; 	ld bc,00101h		;5163
;; 	ld bc,00101h		;5166
;; 	ld bc,00101h		;5169
;; 	inc bc			;516c
;; 	ld bc,00101h		;516d
;; 	ld bc,00101h		;5170
;; 	ld (bc),a			;5173
;; 	ld bc,00201h		;5174
;; 	ld bc,00201h		;5177
;; 	ld bc,00101h		;517a
;; 	ld bc,00101h		;517d
;; 	ld bc,00101h		;5180
;; 	ld bc,00101h		;5183
;; 	inc bc			;5186
;; 	ld bc,00101h		;5187
;; 	ld bc,00101h		;518a
;; 	ld (bc),a			;518d
;; 	ld bc,00201h		;518e
;; 	ld bc,00201h		;5191
;; 	ld bc,00101h		;5194
;; 	ld bc,00101h		;5197
;; 	ld bc,00101h		;519a
;; 	ld bc,00101h		;519d
;; 	inc bc			;51a0
;; 	ld c,(hl)			;51a1
;; 	ld d,h			;51a2
;; 	out (0d7h),a		;51a3
;; 	nop			;51a5
;; 	ld (hl),051h		;51a6
;; 	inc bc			;51a8
;; 	call pe,0fd0fh		;51a9
;; 	nop			;51ac
;; 	pop hl			;51ad
;; 	nop			;51ae
;; 	push de			;51af
;; 	nop			;51b0
;; 	cp (hl)			;51b1
;; 	nop			;51b2
;; 	xor c			;51b3
;; 	nop			;51b4
;; 	push de			;51b5
;; 	nop			;51b6
;; 	xor c			;51b7
;; 	nop			;51b8
;; 	or e			;51b9
;; 	nop			;51ba
;; 	pop hl			;51bb
;; 	nop			;51bc
;; 	or e			;51bd
;; 	nop			;51be
;; 	cp (hl)			;51bf
;; 	nop			;51c0
;; 	rst 28h			;51c1
;; 	nop			;51c2
;; 	cp (hl)			;51c3
;; 	nop			;51c4
;; 	defb 0fdh,000h,0e1h	;illegal sequence		;51c5
;; 	nop			;51c8
;; 	push de			;51c9
;; 	nop			;51ca
;; 	cp (hl)			;51cb
;; 	nop			;51cc
;; 	xor c			;51cd
;; 	nop			;51ce
;; 	push de			;51cf
;; 	nop			;51d0
;; 	xor c			;51d1
;; 	nop			;51d2
;; 	ld a,a			;51d3
;; 	nop			;51d4
;; 	adc a,(hl)			;51d5
;; 	nop			;51d6
;; 	xor c			;51d7
;; 	nop			;51d8
;; 	push de			;51d9
;; 	nop			;51da
;; 	xor c			;51db
;; 	nop			;51dc
;; 	adc a,(hl)			;51dd
;; 	nop			;51de
;; 	defb 0fdh,000h,0e1h	;illegal sequence		;51df
;; 	nop			;51e2
;; 	push de			;51e3
;; 	nop			;51e4
;; 	cp (hl)			;51e5
;; 	nop			;51e6
;; 	xor c			;51e7
;; 	nop			;51e8
;; 	push de			;51e9
;; 	nop			;51ea
;; 	xor c			;51eb
;; 	nop			;51ec
;; 	or e			;51ed
;; 	nop			;51ee
;; 	pop hl			;51ef
;; 	nop			;51f0
;; 	or e			;51f1
;; 	nop			;51f2
;; 	cp (hl)			;51f3
;; 	nop			;51f4
;; 	rst 28h			;51f5
;; 	nop			;51f6
;; 	cp (hl)			;51f7
;; 	nop			;51f8
;; 	defb 0fdh,000h,0e1h	;illegal sequence		;51f9
;; 	nop			;51fc
;; 	push de			;51fd
;; 	nop			;51fe
;; 	cp (hl)			;51ff
;; 	nop			;5200
;; 	xor c			;5201
;; 	nop			;5202
;; 	push de			;5203
;; 	nop			;5204
;; 	xor c			;5205
;; 	nop			;5206
;; 	ld a,a			;5207
;; 	nop			;5208
;; 	adc a,(hl)			;5209
;; 	nop			;520a
;; 	xor c			;520b
;; 	nop			;520c
;; 	push de			;520d
;; 	nop			;520e
;; 	xor c			;520f
;; 	nop			;5210
;; 	adc a,(hl)			;5211
;; 	nop			;5212
;; 	ld d,d			;5213
;; 	ld bc,0012dh		;5214
;; 	inc e			;5217
;; 	ld bc,000fdh		;5218
;; 	pop hl			;521b
;; 	nop			;521c
;; 	inc e			;521d
;; 	ld bc,000e1h		;521e
;; 	rst 28h			;5221
;; 	nop			;5222
;; 	dec l			;5223
;; 	ld bc,000efh		;5224
;; 	defb 0fdh,000h,03fh	;illegal sequence		;5227
;; 	ld bc,000fdh		;522a
;; 	ld d,d			;522d
;; 	ld bc,0012dh		;522e
;; 	inc e			;5231
;; 	ld bc,000fdh		;5232
;; 	pop hl			;5235
;; 	nop			;5236
;; 	inc e			;5237
;; 	ld bc,000e1h		;5238
;; 	xor c			;523b
;; 	nop			;523c
;; 	cp (hl)			;523d
;; 	nop			;523e
;; 	pop hl			;523f
;; 	nop			;5240
;; 	inc e			;5241
;; 	ld bc,000e1h		;5242
;; 	cp (hl)			;5245
;; 	nop			;5246
;; 	ld d,d			;5247
;; 	ld bc,0012dh		;5248
;; 	inc e			;524b
;; 	ld bc,000fdh		;524c
;; 	pop hl			;524f
;; 	nop			;5250
;; 	inc e			;5251
;; 	ld bc,000e1h		;5252
;; 	rst 28h			;5255
;; 	nop			;5256
;; 	dec l			;5257
;; 	ld bc,000efh		;5258
;; 	defb 0fdh,000h,03fh	;illegal sequence		;525b
;; 	ld bc,000fdh		;525e
;; 	ld d,d			;5261
;; 	ld bc,0012dh		;5262
;; 	inc e			;5265
;; 	ld bc,000fdh		;5266
;; 	pop hl			;5269
;; 	nop			;526a
;; 	inc e			;526b
;; 	ld bc,000e1h		;526c
;; 	xor c			;526f
;; 	nop			;5270
;; 	cp (hl)			;5271
;; 	nop			;5272
;; 	pop hl			;5273
;; 	nop			;5274
;; 	inc e			;5275
;; 	ld bc,000e1h		;5276
;; 	cp (hl)			;5279
;; 	nop			;527a
;; 	ld c,c			;527b
;; 	ld c,(hl)			;527c
;; 	ld d,h			;527d
;; 	ld d,d			;527e
;; 	rst 8			;527f
;; 	ld l,a			;5280
;; 	nop			;5281
;; 	xor b			;5282
;; 	ld d,c			;5283
;; 	dec b			;5284
;; 	jp 09f0eh		;5285
;; 	ld (de),a			;5288
;; 	ld de,00010h		;5289
;; 	nop			;528c
;; 	rst 30h			;528d
;; 	ld d,d			;528e
;; 	pop bc			;528f
;; 	ex af,af'			;5290
;; 	ld c,b			;5291
;; 	ld c,e			;5292
;; 	ld de,01a10h		;5293
;; 	nop			;5296
;; 	ld de,00010h		;5297
;; 	nop			;529a
;; 	inc hl			;529b
;; 	inc de			;529c
;; 	inc b			;529d
;; 	ld d,e			;529e
;; 	ld (0fb13h),a		;529f
;; 	rst 38h			;52a2
;; 	rst 8			;52a3
;; 	ld c,l			;52a4
;; 	ld de,01a10h		;52a5
;; 	nop			;52a8
;; 	ld de,00010h		;52a9
;; 	nop			;52ac
;; 	inc hl			;52ad
;; 	inc de			;52ae
;; 	inc b			;52af
;; 	ld d,e			;52b0
;; 	ld (0fb13h),a		;52b1
;; 	rst 38h			;52b4
;; 	jp nz,0114fh		;52b5
;; 	djnz l52eeh		;52b8
;; 	nop			;52ba
;; 	ld de,00010h		;52bb
;; 	nop			;52be
;; 	inc hl			;52bf
;; 	inc de			;52c0
;; 	inc b			;52c1
;; 	ld d,e			;52c2
;; 	in a,(00bh)		;52c3
;; 	ld de,00d10h		;52c5
;; 	nop			;52c8
;; 	ld c,d			;52c9
;; 	inc c			;52ca
;; 	add a,e			;52cb
;; 	ld (de),a			;52cc
;; 	dec b			;52cd
;; 	nop			;52ce
;; 	ld d,013h		;52cf
;; 	and h			;52d1
;; 	ld (de),a			;52d2
;; 	ld (0eb13h),a		;52d3
;; 	rst 38h			;52d6
;; 	in a,(00bh)		;52d7
;; 	ld de,00d10h		;52d9
;; 	nop			;52dc
;; 	ld c,d			;52dd
;; 	inc c			;52de
;; 	adc a,l			;52df
;; 	ld (de),a			;52e0
;; 	and a			;52e1
;; 	rst 38h			;52e2
;; 	ld de,09010h		;52e3
;; 	ld bc,01011h		;52e6
;; 	call p,09801h		;52e9
;; 	dec bc			;52ec
;; 	or (hl)			;52ed
;; l52eeh:
;; 	inc b			;52ee
;; 	ld d,b			;52ef
;; 	ld d,e			;52f0
;; 	adc a,009h		;52f1
;; 	nop			;52f3
;; 	add a,h			;52f4
;; 	ld d,d			;52f5
;; 	inc bc			;52f6
;; 	ret p			;52f7
;; 	rrca			;52f8
;; 	ld (hl),000h		;52f9
;; 	ld c,c			;52fb
;; 	ld c,(hl)			;52fc
;; 	ld d,h			;52fd
;; 	jp nc,0003dh		;52fe
;; 	or 052h		;5301
;; 	inc b			;5303
;; 	jp 0f70eh		;5304
;; 	ld d,d			;5307
;; 	or e			;5308
;; 	ex af,af'			;5309
;; 	add hl,bc			;530a
;; 	ld c,06bh		;530b
;; 	ex af,af'			;530d
;; 	ld l,e			;530e
;; 	ex af,af'			;530f
;; 	rst 30h			;5310
;; 	ld d,d			;5311
;; 	pop bc			;5312
;; 	ex af,af'			;5313
;; 	ld e,051h		;5314
;; 	add a,l			;5316
;; 	ex af,af'			;5317
;; 	dec bc			;5318
;; 	ld d,c			;5319
;; 	ld de,0af10h		;531a
;; 	nop			;531d
;; 	ld l,l			;531e
;; 	dec c			;531f
;; 	sbc a,b			;5320
;; 	dec bc			;5321
;; 	rst 30h			;5322
;; 	ld d,d			;5323
;; 	or e			;5324
;; 	ex af,af'			;5325
;; 	ld de,06810h		;5326
;; 	nop			;5329
;; 	ld c,d			;532a
;; 	inc c			;532b
;; 	add a,e			;532c
;; 	ld (de),a			;532d
;; 	dec bc			;532e
;; 	nop			;532f
;; 	ld de,00010h		;5330
;; 	nop			;5333
;; 	rst 30h			;5334
;; 	ld d,d			;5335
;; 	pop bc			;5336
;; 	ex af,af'			;5337
;; 	and h			;5338
;; 	ld (de),a			;5339
;; 	or (hl)			;533a
;; 	inc b			;533b
;; 	ld b,a			;533c
;; 	rst 8			;533d
;; 	ld d,l			;533e
;; 	nop			;533f
;; 	inc bc			;5340
;; 	ld d,e			;5341
;; l5342h:
;; 	ld (bc),a			;5342
;; 	jp 0850eh		;5343
;; 	ld d,d			;5346
;; 	sbc a,a			;5347
;; 	ld (de),a			;5348
;; 	sbc a,e			;5349
;; 	ld d,e			;534a
;; 	inc sp			;534b
;; 	ld c,e			;534c
;; 	ld de,01510h		;534d
;; 	nop			;5350
;; 	ld de,00010h		;5351
;; 	nop			;5354
;; 	add hl,de			;5355
;; 	dec bc			;5356
;; 	sub (hl)			;5357
;; 	inc de			;5358
;; 	jr nz,l535bh		;5359
;; l535bh:
;; 	and b			;535b
;; 	ret nc			;535c
;; 	and b			;535d
;; 	jp nc,0c5a0h		;535e
;; 	and b			;5361
;; 	out (0a0h),a		;5362
;; 	out (0a0h),a		;5364
;; 	and b			;5366
;; 	push bc			;5367
;; 	and b			;5368
;; 	adc a,0a0h		;5369
;; 	call nc,0c5a0h		;536b
;; 	and b			;536e
;; 	jp nc,0a0a0h		;536f
;; 	and b			;5372
;; 	and b			;5373
;; 	and b			;5374
;; 	and b			;5375
;; 	and b			;5376
;; 	and b			;5377
;; 	and b			;5378
;; 	and b			;5379
;; 	and b			;537a
;; 	sbc a,a			;537b
;; 	ld (de),a			;537c
;; 	in a,(00bh)		;537d
;; 	ld de,00d10h		;537f
;; 	nop			;5382
;; 	ld c,d			;5383
;; 	inc c			;5384
;; 	adc a,l			;5385
;; 	ld (de),a			;5386
;; 	push af			;5387
;; 	rst 38h			;5388
;; 	ld de,00010h		;5389
;; 	nop			;538c
;; 	adc a,l			;538d
;; 	ld (de),a			;538e
;; 	cp c			;538f
;; 	rst 38h			;5390
;; 	or (hl)			;5391
;; 	inc b			;5392
;; 	ld c,c			;5393
;; 	ld c,(hl)			;5394
;; 	out (023h),a		;5395
;; 	ld bc,l5342h		;5397
;; 	inc bc			;539a
;; 	jp 01d0eh		;539b
;; 	ld a,(bc)			;539e
;; 	sub (hl)			;539f
;; 	inc de			;53a0
;; 	adc a,000h		;53a1
;; 	jr nz,l53c5h		;53a3
;; 	jr nz,l53c7h		;53a5
;; 	jr nz,l53c9h		;53a7
;; 	jr nz,$+69		;53a9
;; 	jr nz,$+71		;53ab
;; 	jr nz,l53fdh		;53ad
;; 	jr nz,l5405h		;53af
;; 	jr nz,$+75		;53b1
;; 	jr nz,l5405h		;53b3
;; 	jr nz,$+71		;53b5
;; 	jr nz,l53fdh		;53b7
;; 	jr nz,$+71		;53b9
;; 	jr nz,l53ddh		;53bb
;; 	jr nz,l53dfh		;53bd
;; 	jr nz,l53e1h		;53bf
;; 	jr nz,l53e3h		;53c1
;; 	jr nz,l53e5h		;53c3
;; l53c5h:
;; 	jr nz,l53e7h		;53c5
;; l53c7h:
;; 	jr nz,l53e9h		;53c7
;; l53c9h:
;; 	jr nz,l542ah		;53c9
;; 	ld e,a			;53cb
;; 	ld e,a			;53cc
;; 	ld e,a			;53cd
;; 	ld e,a			;53ce
;; 	ld e,a			;53cf
;; 	ld e,a			;53d0
;; 	ld e,a			;53d1
;; 	ld e,a			;53d2
;; 	ld e,a			;53d3
;; 	ld e,a			;53d4
;; 	ld e,a			;53d5
;; 	ld e,a			;53d6
;; 	ld e,a			;53d7
;; 	ld e,a			;53d8
;; 	ld e,a			;53d9
;; 	ld e,a			;53da
;; 	jr nz,l53fdh		;53db
;; l53ddh:
;; 	jr nz,l53ffh		;53dd
;; l53dfh:
;; 	jr nz,l5401h		;53df
;; l53e1h:
;; 	jr nz,l5403h		;53e1
;; l53e3h:
;; 	jr nz,l5405h		;53e3
;; l53e5h:
;; 	jr nz,l5407h		;53e5
;; l53e7h:
;; 	jr nz,l5409h		;53e7
;; l53e9h:
;; 	jr nz,l540bh		;53e9
;; 	jr nz,l540dh		;53eb
;; 	jr nz,l540fh		;53ed
;; 	jr nz,l5411h		;53ef
;; 	jr nz,l5413h		;53f1
;; 	jr nz,l5415h		;53f3
;; 	jr nz,l5417h		;53f5
;; 	jr nz,l5419h		;53f7
;; 	jr nz,l541bh		;53f9
;; 	jr nz,$+34		;53fb
;; l53fdh:
;; 	jr nz,l541fh		;53fd
;; l53ffh:
;; 	jr nz,$+34		;53ff
;; l5401h:
;; 	jr nz,$+34		;5401
;; l5403h:
;; 	jr nz,l545ah		;5403
;; l5405h:
;; 	ld (hl),e			;5405
;; 	ld h,l			;5406
;; l5407h:
;; 	jr nz,l5430h		;5407
;; l5409h:
;; 	ld c,d			;5409
;; 	daa			;540a
;; l540bh:
;; 	jr nz,l546eh		;540b
;; l540dh:
;; 	ld l,(hl)			;540d
;; 	ld h,h			;540e
;; l540fh:
;; 	jr nz,l5438h		;540f
;; l5411h:
;; 	ld c,h			;5411
;; 	daa			;5412
;; l5413h:
;; 	jr nz,l547bh		;5413
;; l5415h:
;; 	ld l,a			;5415
;; 	ld (hl),d			;5416
;; l5417h:
;; 	jr nz,l5485h		;5417
;; l5419h:
;; 	ld h,l			;5419
;; 	ld h,(hl)			;541a
;; l541bh:
;; 	ld (hl),h			;541b
;; 	jr nz,l547fh		;541c
;; 	ld l,(hl)			;541e
;; l541fh:
;; 	ld h,h			;541f
;; 	jr nz,$+34		;5420
;; 	jr nz,l5496h		;5422
;; 	ld l,c			;5424
;; 	ld h,a			;5425
;; 	ld l,b			;5426
;; 	ld (hl),h			;5427
;; 	inc l			;5428
;; 	daa			;5429
;; l542ah:
;; 	ld c,c			;542a
;; 	daa			;542b
;; 	jr nz,l548fh		;542c
;; 	ld l,(hl)			;542e
;; 	ld h,h			;542f
;; l5430h:
;; 	jr nz,l5459h		;5430
;; 	ld c,l			;5432
;; 	daa			;5433
;; 	jr nz,l549ch		;5434
;; 	ld l,a			;5436
;; 	ld (hl),d			;5437
;; l5438h:
;; 	jr nz,$+119		;5438
;; 	ld (hl),b			;543a
;; 	jr nz,l549eh		;543b
;; 	ld l,(hl)			;543d
;; 	ld h,h			;543e
;; 	jr nz,$+34		;543f
;; 	jr nz,$+34		;5441
;; 	ld h,h			;5443
;; 	ld l,a			;5444
;; 	ld (hl),a			;5445
;; 	ld l,(hl)			;5446
;; 	jr nz,l54aah		;5447
;; 	ld l,(hl)			;5449
;; 	ld h,h			;544a
;; 	jr nz,l5474h		;544b
;; 	ld b,c			;544d
;; 	daa			;544e
;; 	jr nz,l54c5h		;544f
;; 	ld l,a			;5451
;; 	jr nz,l54bah		;5452
;; 	ld l,c			;5454
;; 	ld (hl),d			;5455
;; 	ld h,l			;5456
;; 	jr nz,$+118		;5457
;; l5459h:
;; 	ld l,a			;5459
;; l545ah:
;; 	jr nz,l54cfh		;545a
;; 	ld l,b			;545c
;; 	ld l,a			;545d
;; 	ld l,a			;545e
;; 	ld (hl),h			;545f
;; 	jr nz,l5482h		;5460
;; 	jr nz,l54d8h		;5462
;; 	ld l,b			;5464
;; 	ld h,l			;5465
;; 	jr nz,l54cbh		;5466
;; 	ld h,l			;5468
;; 	ld l,(hl)			;5469
;; 	ld (hl),h			;546a
;; 	ld l,c			;546b
;; 	ld (hl),b			;546c
;; 	ld h,l			;546d
;; l546eh:
;; 	ld h,h			;546e
;; 	ld h,l			;546f
;; 	ld l,011h		;5470
;; 	djnz $+23		;5472
;; l5474h:
;; 	nop			;5474
;; 	ld de,00010h		;5475
;; 	nop			;5478
;; 	add hl,de			;5479
;; 	dec bc			;547a
;; l547bh:
;; 	sub (hl)			;547b
;; 	inc de			;547c
;; 	jr nz,l547fh		;547d
;; l547fh:
;; 	and b			;547f
;; 	ret nc			;5480
;; 	and b			;5481
;; l5482h:
;; 	jp nc,0c5a0h		;5482
;; l5485h:
;; 	and b			;5485
;; 	out (0a0h),a		;5486
;; 	out (0a0h),a		;5488
;; 	and b			;548a
;; 	push bc			;548b
;; 	and b			;548c
;; 	adc a,0a0h		;548d
;; l548fh:
;; 	call nc,0c5a0h		;548f
;; 	and b			;5492
;; 	jp nc,0a0a0h		;5493
;; l5496h:
;; 	and b			;5496
;; 	and b			;5497
;; 	and b			;5498
;; 	and b			;5499
;; 	and b			;549a
;; 	and b			;549b
;; l549ch:
;; 	and b			;549c
;; 	and b			;549d
;; l549eh:
;; 	and b			;549e
;; 	ld de,0c810h		;549f
;; 	nop			;54a2
;; 	ld de,0f410h		;54a3
;; 	ld bc,00b98h		;54a6
;; 	sbc a,a			;54a9
;; l54aah:
;; 	ld (de),a			;54aa
;; 	in a,(00bh)		;54ab
;; 	ld de,00d10h		;54ad
;; 	nop			;54b0
;; 	ld c,d			;54b1
;; 	inc c			;54b2
;; 	adc a,l			;54b3
;; 	ld (de),a			;54b4
;; 	push af			;54b5
;; 	rst 38h			;54b6
;; 	or (hl)			;54b7
;; 	inc b			;54b8
;; 	ld d,e			;54b9
;; l54bah:
;; 	ld b,c			;54ba
;; 	ld d,(hl)			;54bb
;; 	push bc			;54bc
;; 	dec bc			;54bd
;; 	nop			;54be
;; 	sbc a,d			;54bf
;; 	ld d,e			;54c0
;; 	inc b			;54c1
;; 	jp l430eh		;54c2
;; l54c5h:
;; 	ld d,e			;54c5
;; 	or (hl)			;54c6
;; 	inc b			;54c7
;; 	ld d,(hl)			;54c8
;; 	ld c,h			;54c9
;; 	ld c,c			;54ca
;; l54cbh:
;; 	ld d,e			;54cb
;; 	call nc,0000bh		;54cc
;; l54cfh:
;; 	pop bc			;54cf
;; 	ld d,h			;54d0
;; 	dec b			;54d1
;; 	jp l430eh		;54d2
;; 	ld d,e			;54d5
;; 	or (hl)			;54d6
;; 	inc b			;54d7
;; l54d8h:
;; 	ld b,l			;54d8
;; 	ld b,h			;54d9
;; 	ld c,c			;54da
;; 	call nc,0000bh		;54db
;; 	pop de			;54de
;; 	ld d,h			;54df
;; 	inc b			;54e0
;; 	jp l430eh		;54e1
;; 	ld d,e			;54e4
;; 	or (hl)			;54e5
;; 	inc b			;54e6
;; 	ld b,(hl)			;54e7
;; 	ld c,a			;54e8
;; 	ld d,d			;54e9
;; 	ld b,a			;54ea
;; 	ld b,l			;54eb
;; 	call nc,0000bh		;54ec
;; 	ret po			;54ef
;; 	ld d,h			;54f0
;; 	ld b,0c3h		;54f1
;; 	ld c,043h		;54f3
;; l54f5h:
;; 	ld d,e			;54f5
;; 	or (hl)			;54f6
;; 	inc b			;54f7
;; 	ld d,d			;54f8
;; 	ld b,l			;54f9
;; 	ld b,h			;54fa
;; 	ld b,l			;54fb
;; 	ld b,(hl)			;54fc
;; 	ld c,c			;54fd
;; 	ld c,(hl)			;54fe
;; 	push bc			;54ff
;; 	dec bc			;5500
;; 	nop			;5501
;; 	pop af			;5502
;; 	ld d,h			;5503
;; 	ex af,af'			;5504
;; 	jp l430eh		;5505
;; 	ld d,e			;5508
;; 	or (hl)			;5509
;; 	inc b			;550a
;; 	inc e			;550b
;; 	ret m			;550c
;; 	inc sp			;550d
;; 	dec hl			;550e
;; 	jp p,024adh		;550f
;; 	sbc a,c			;5512
;; 	jp 09d06h		;5513
;; 	xor 001h		;5516
;; 	nop			;5518
;; 	ccf			;5519
;; 	inc a			;551a
;; 	and l			;551b
;; 	ex af,af'			;551c
;; 	and l			;551d
;; 	ex af,af'			;551e
;; 	dec hl			;551f
;; 	ld l,d			;5520
;; 	dec c			;5521
;; 	cp h			;5522
;; 	ld e,d			;5523
;; 	bit 3,h		;5524
;; 	ld e,b			;5526
;; 	ld d,b			;5527
;; 	adc a,h			;5528
;; 	defb 0fdh,0c4h,0e6h	;illegal sequence		;5529
;; 	ld h,e			;552c
;; 	ld e,b			;552d
;; 	call p,04bd2h		;552e
;; 	ld (bc),a			;5531
;; 	push hl			;5532
;; 	sub a			;5533
;; 	ex af,af'			;5534
;; 	ld h,l			;5535
;; 	sbc a,a			;5536
;; 	daa			;5537
;; 	ld a,e			;5538
;; 	and b			;5539
;; 	ld e,h			;553a
;; 	ret z			;553b
;; 	ld de,0dfb2h		;553c
;; 	sub b			;553f
;; 	cp c			;5540
;; 	ld d,h			;5541
;; 	dec de			;5542
;; 	or e			;5543
;; 	call p,0035fh		;5544
;; 	add hl,bc			;5547
;; 	ld l,e			;5548
;; 	inc (hl)			;5549
;; 	exx			;554a
;; 	sub b			;554b
;; 	push de			;554c
;; 	sbc a,d			;554d
;; 	jr nc,l54f5h		;554e
;; 	ld c,a			;5550
;; 	ld c,e			;5551
;; 	add a,a			;5552
;; 	ld d,(hl)			;5553
;; l5554h:
;; 	ret nc			;5554
;; 	or c			;5555
;; 	call nc,0bed1h		;5556
;; 	jr c,l5597h		;5559
;; 	ld (hl),l			;555b
;; 	rst 20h			;555c
;; 	ld e,0a5h		;555d
;; 	ld c,047h		;555f
;; 	ld c,a			;5561
;; 	ld e,b			;5562
;; 	xor 053h		;5563
;; 	inc e			;5565
;; 	ld e,d			;5566
;; 	ld l,(hl)			;5567
;; 	inc (hl)			;5568
;; 	or l			;5569
;; 	jp m,01660h		;556a
;; 	xor h			;556d
;; 	ld e,a			;556e
;; 	or l			;556f
;; 	ld a,d			;5570
;; 	adc a,d			;5571
;; 	adc a,b			;5572
;; 	and l			;5573
;; 	pop bc			;5574
;; 	call c,06821h		;5575
;; 	exx			;5578
;; 	ld l,(hl)			;5579
;; 	ld l,l			;557a
;; 	and (hl)			;557b
;; 	djnz l5554h		;557c
;; 	djnz l55d7h		;557e
;; 	or 03fh		;5580
;; 	rra			;5582
;; 	ld d,e			;5583
;; 	jp p,0d820h		;5584
;; 	ld h,h			;5587
;; 	ld hl,(09a22h)		;5588
;; sub_558bh:
;; 	call p,0b5cch		;558b
;; 	dec a			;558e
;; 	sbc a,b			;558f
;; 	ld l,b			;5590
;; 	ex af,af'			;5591
;; 	pop af			;5592
;; 	ld e,02bh		;5593
;; 	xor d			;5595
;; 	or (hl)			;5596
;; l5597h:
;; 	nop			;5597
;; 	ld h,e			;5598
;; 	rrca			;5599
;; 	ex af,af'			;559a
;; 	ld c,b			;559b
;; 	ld e,(hl)			;559c
;; 	xor e			;559d
;; 	jp nc,0b28bh		;559e
;; 	ld a,(de)			;55a1
;; 	ld l,c			;55a2
;; 	sub l			;55a3
;; 	jr z,l55b3h		;55a4
;; 	dec b			;55a6
;; 	ld (081c1h),a		;55a7
;; 	pop hl			;55aa
;; 	ld c,l			;55ab
;; 	ld d,b			;55ac
;; 	adc a,b			;55ad
;; 	ld h,l			;55ae
;; 	sub d			;55af
;; 	ld (hl),c			;55b0
;; 	ret p			;55b1
;; 	ld l,(hl)			;55b2
;; l55b3h:
;; 	xor b			;55b3
;; 	ld a,(hl)			;55b4
;; 	jp z,087a9h		;55b5
;; 	ld (hl),h			;55b8
;; 	ld l,062h		;55b9
;; 	pop af			;55bb
;; 	ld b,b			;55bc
;; 	and 072h		;55bd
;; 	ret c			;55bf
;; 	cp l			;55c0
;; 	add a,h			;55c1
;; 	halt			;55c2
;; 	add hl,bc			;55c3
;; 	daa			;55c4
;; 	call m,06efdh		;55c5
;; 	and d			;55c8
;; 	cpl			;55c9
;; 	inc (hl)			;55ca
;; 	ld h,09ah		;55cb
;; 	ld l,(hl)			;55cd
;; 	dec h			;55ce
;; 	ld e,(hl)			;55cf
;; 	sub a			;55d0
;; 	ld c,c			;55d1
;; 	sbc a,c			;55d2
;; 	ld d,a			;55d3
;; 	ld d,e			;55d4
;; 	sub l			;55d5
;; 	ret m			;55d6
;; l55d7h:
;; 	and c			;55d7
;; 	cp b			;55d8
;; 	ld c,d			;55d9
;; 	ld e,b			;55da
;; 	inc de			;55db
;; 	adc a,056h		;55dc
;; 	and h			;55de
;; 	ld d,(hl)			;55df
;; 	or l			;55e0
;; 	dec b			;55e1
;; 	ld a,(09b6ch)		;55e2
;; 	adc a,l			;55e5
;; 	jr nc,$-97		;55e6
;; 	ld d,d			;55e8
;; 	sbc a,0adh		;55e9
;; 	ld b,c			;55eb
;; 	and 0bbh		;55ec
;; 	sbc a,h			;55ee
;; 	ld e,a			;55ef
;; 	sbc a,l			;55f0
;; 	cp (hl)			;55f1
;; 	sub a			;55f2
;; 	ld d,a			;55f3
;; 	or l			;55f4
;; 	ret nc			;55f5
;; 	ret			;55f6
;; 	jp nz,0616eh		;55f7
;; 	add a,0cfh		;55fa
;; 	or b			;55fc
;; 	ld c,l			;55fd
;; 	xor h			;55fe
;; 	ret c			;55ff
;; 	call m,0bcc9h		;5600
;; 	ret m			;5603
;; 	ld (hl),e			;5604
;; 	jr z,l5633h		;5605
;; 	rlca			;5607
;; 	inc bc			;5608
;; 	ld sp,hl			;5609
;; 	ld c,03dh		;560a
;; 	ld c,d			;560c
;; 	adc a,c			;560d
;; 	ld l,(hl)			;560e
;; 	ld c,a			;560f
;; 	xor 006h		;5610
;; 	xor 0deh		;5612
;; 	and b			;5614
;; 	dec l			;5615
;; 	or h			;5616
;; 	ld (hl),h			;5617
;; 	daa			;5618
;; 	ld (hl),e			;5619
;; 	and a			;561a
;; 	ld a,(hl)			;561b
;; 	sub d			;561c
;; 	ei			;561d
;; 	sbc a,a			;561e
;; 	jp po,06a4dh		;561f
;; 	ret z			;5622
;; 	ld hl,0cd08h		;5623
;; 	ld l,021h		;5626
;; 	ld d,e			;5628
;; 	rst 30h			;5629
;; 	dec hl			;562a
;; 	ld l,091h		;562b
;; 	ld e,(hl)			;562d
;; 	scf			;562e
;; 	call nc,0cdbch		;562f
;; 	ld l,c			;5632
;; l5633h:
;; 	ld hl,(0dcc3h)		;5633
;; 	ret nz			;5636
;; 	dec (hl)			;5637
;; 	jp m,02dc1h		;5638
;; 	dec sp			;563b
;; 	add a,0b5h		;563c
;; 	call z,02cadh		;563e
;; 	push bc			;5641
;; 	add a,04dh		;5642
;; 	xor l			;5644
;; 	call c,0ded1h		;5645
;; 	cp e			;5648
;; 	ld (de),a			;5649
;; 	add a,e			;564a
;; 	ld c,a			;564b
;; 	ld c,a			;564c
;; 	and a			;564d
;; 	dec (hl)			;564e
;; 	rst 18h			;564f
;; 	push de			;5650
;; 	adc a,c			;5651
;; 	or (hl)			;5652
;; 	adc a,l			;5653
;; 	or c			;5654
;; 	jp z,0e8c9h		;5655
;; 	daa			;5658
;; 	scf			;5659
;; 	jr c,l5692h		;565a
;; 	ld d,c			;565c
;; 	ld a,056h		;565d
;; 	adc a,(hl)			;565f
;; 	ld l,0d6h		;5660
;; 	jp po,0a0a5h		;5662
;; 	sub 05eh		;5665
;; 	ld (0e570h),a		;5667
;; 	ld d,d			;566a
;; 	ld h,h			;566b
;; 	ld d,d			;566c
;; 	ld e,c			;566d
;; 	ld b,l			;566e
;; 	sub (hl)			;566f
;; 	and 071h		;5670
;; 	inc hl			;5672
;; 	sub h			;5673
;; 	inc l			;5674
;; 	call pe,0b120h		;5675
;; 	cp e			;5678
;; 	ld (0eb57h),hl		;5679
;; 	and e			;567c
;; 	ld b,d			;567d
;; 	inc de			;567e
;; 	ld bc,0666ah		;567f
;; 	ret nz			;5682
;; 	cp 038h		;5683
;; 	sub e			;5685
;; 	sub (hl)			;5686
;; 	ld h,c			;5687
;; 	ld c,c			;5688
;; 	sbc a,a			;5689
;; 	inc b			;568a
;; 	ld a,e			;568b
;; 	ld bc,0f184h		;568c
;; 	sbc a,096h		;568f
;; 	and (hl)			;5691
;; l5692h:
;; 	ld a,h			;5692
;; 	ld l,l			;5693
;; 	jp p,07d8bh		;5694
;; 	jp z,l44f7h		;5697
;; 	dec hl			;569a
;; 	dec e			;569b
;; 	push de			;569c
;; 	ld e,(hl)			;569d
;; 	ld d,b			;569e
;; 	xor a			;569f
;; 	ld l,h			;56a0
;; 	or 005h		;56a1
;; 	ld l,a			;56a3
;; 	ex de,hl			;56a4
;; 	and a			;56a5
;; 	adc a,0f5h		;56a6
;; 	xor 0a3h		;56a8
;; 	scf			;56aa
;; 	adc a,e			;56ab
;; 	daa			;56ac
;; 	and 01ah		;56ad
;; 	ld e,(hl)			;56af
;; 	ret nc			;56b0
;; 	or h			;56b1
;; 	ei			;56b2
;; 	ld l,d			;56b3
;; 	pop de			;56b4
;; 	sub e			;56b5
;; 	call z,0c12bh		;56b6
;; 	and l			;56b9
;; 	inc de			;56ba
;; 	sub b			;56bb
;; 	ld e,d			;56bc
;; 	out (0edh),a		;56bd
;; 	dec e			;56bf
;; 	ld a,e			;56c0
;; 	add a,a			;56c1
;; 	ld a,d			;56c2
;; 	dec d			;56c3
;; 	xor d			;56c4
;; 	ld c,h			;56c5
;; 	call nz,0a336h		;56c6
;; 	ex af,af'			;56c9
;; 	ld b,c			;56ca
;; 	push hl			;56cb
;; 	ret po			;56cc
;; 	and b			;56cd
;; 	ld l,08dh		;56ce
;; 	add a,0f7h		;56d0
;; 	inc e			;56d2
;; 	and b			;56d3
;; 	xor d			;56d4
;; 	rra			;56d5
;; 	ld c,h			;56d6
;; 	sbc a,d			;56d7
;; 	sbc a,d			;56d8
;; 	dec a			;56d9
;; 	ld a,(bc)			;56da
;; 	ld sp,hl			;56db
;; 	xor 017h		;56dc
;; 	dec b			;56de
;; 	ret z			;56df
;; 	inc a			;56e0
;; 	adc a,c			;56e1
;; 	jp nz,09df0h		;56e2
;; 	ld d,h			;56e5
;; 	xor c			;56e6
;; 	ld h,d			;56e7
;; 	jp p,l5933h		;56e8
;; 	defb 0edh;next byte illegal after ed		;56eb
;; 	ld (bc),a			;56ec
;; 	cp l			;56ed
;; 	adc a,l			;56ee
;; 	or (hl)			;56ef
;; 	adc a,d			;56f0
;; 	ld (bc),a			;56f1
;; 	ld d,h			;56f2
;; 	adc a,046h		;56f3
;; 	call po,06524h		;56f5
;; 	ld e,b			;56f8
;; 	xor c			;56f9
;; 	ld d,d			;56fa
;; 	add a,(hl)			;56fb
;; 	adc a,l			;56fc
;; 	ld l,l			;56fd
;; 	ld l,d			;56fe
;; 	ld c,l			;56ff
;; l5700h:
;; 	call m,sub_3eedh		;5700
;; 	ld a,046h		;5703
;; 	ret m			;5705
;; 	nop			;5706
;; 	ld l,l			;5707
;; 	pop hl			;5708
;; 	ld (l3ef9h),a		;5709
;; 	cp e			;570c
;; 	xor e			;570d
;; 	dec e			;570e
;; 	jp 0a95eh		;570f
;; 	ld h,e			;5712
;; 	jr nz,l5776h		;5713
;; 	sub c			;5715
;; 	defb 0edh;next byte illegal after ed		;5716
;; 	adc a,b			;5717
;; 	inc e			;5718
;; 	daa			;5719
;; 	rst 10h			;571a
;; 	call pe,07a99h		;571b
;; 	ld d,h			;571e
;; 	call pe,01638h		;571f
;; 	ret po			;5722
;; 	ld b,(hl)			;5723
;; 	call 075a9h		;5724
;; 	ld a,h			;5727
;; 	jp po,06707h		;5728
;; 	cp d			;572b
;; 	call 0b562h		;572c
;; 	ld b,03eh		;572f
;; 	scf			;5731
;; 	dec hl			;5732
;; 	sub l			;5733
;; 	sbc a,0c2h		;5734
;; 	push hl			;5736
;; 	rst 10h			;5737
;; 	rst 8			;5738
;; 	cp l			;5739
;; 	xor h			;573a
;; 	ld (hl),c			;573b
;; 	jp nz,l487fh		;573c
;; 	ret nc			;573f
;; 	ld d,e			;5740
;; 	exx			;5741
;; 	nop			;5742
;; 	dec a			;5743
;; 	call nc,063b5h		;5744
;; 	rrca			;5747
;; 	ld a,d			;5748
;; 	dec de			;5749
;; 	ld l,068h		;574a
;; 	adc a,a			;574c
;; 	call z,017b8h		;574d
;; 	or e			;5750
;; 	ld a,c			;5751
;; 	ld sp,0602dh		;5752
;; 	rla			;5755
;; 	or e			;5756
;; 	ld a,(de)			;5757
;; 	jr z,l57bfh		;5758
;; 	add a,b			;575a
;; 	cp (hl)			;575b
;; 	ld e,(hl)			;575c
;; 	ld (hl),b			;575d
;; 	jp nz,0e588h		;575e
;; 	call po,04b7eh		;5761
;; 	jp nz,06badh		;5764
;; 	dec h			;5767
;; 	sbc a,028h		;5768
;; 	sub 003h		;576a
;; 	cp 0dbh		;576c
;; 	ld c,l			;576e
;; 	adc a,c			;576f
;; 	jr c,l5700h		;5770
;; 	cp e			;5772
;; 	nop			;5773
;; 	xor a			;5774
;; 	sub d			;5775
;; l5776h:
;; 	and e			;5776
;; 	adc a,d			;5777
;; 	ld h,(hl)			;5778
;; 	or 03eh		;5779
;; 	ret p			;577b
;; 	xor 030h		;577c
;; 	ld a,d			;577e
;; 	ld e,h			;577f
;; 	or c			;5780
;; 	ld e,c			;5781
;; 	ld h,l			;5782
;; 	dec de			;5783
;; 	exx			;5784
;; 	ld b,b			;5785
;; 	push hl			;5786
;; 	rra			;5787
;; 	xor l			;5788
;; 	pop de			;5789
;; 	inc (hl)			;578a
;; 	ld h,c			;578b
;; l578ch:
;; 	ld c,l			;578c
;; 	xor d			;578d
;; 	ld e,a			;578e
;; 	ld a,(de)			;578f
;; 	inc h			;5790
;; 	sbc a,083h		;5791
;; 	xor h			;5793
;; 	ld a,(de)			;5794
;; 	sub a			;5795
;; 	ld l,0d6h		;5796
;; 	adc a,l			;5798
;; 	jr nz,l57d0h		;5799
;; 	call z,0d988h		;579b
;; 	ld l,c			;579e
;; 	sub l			;579f
;; 	ld l,c			;57a0
;; 	inc bc			;57a1
;; 	ld h,h			;57a2
;; 	add a,(hl)			;57a3
;; 	inc a			;57a4
;; 	xor b			;57a5
;; 	ret c			;57a6
;; 	add hl,bc			;57a7
;; 	sbc a,h			;57a8
;; 	cp a			;57a9
;; 	ld a,(bc)			;57aa
;; 	jr z,l578ch		;57ab
;; 	ld d,l			;57ad
;; 	defb 0ddh,091h,0a7h	;illegal sequence		;57ae
;; 	ld d,(hl)			;57b1
;; 	halt			;57b2
;; 	dec e			;57b3
;; 	inc d			;57b4
;; 	ld e,a			;57b5
;; 	call z,0855fh		;57b6
;; 	ld (de),a			;57b9
;; 	and c			;57ba
;; 	ld c,d			;57bb
;; 	add hl,de			;57bc
;; 	ld h,h			;57bd
;; 	or l			;57be
;; l57bfh:
;; 	ld hl,(03b05h)		;57bf
;; 	ld d,h			;57c2
;; 	ld e,00bh		;57c3
;; 	jp p,0e433h		;57c5
;; 	nop			;57c8
;; 	and (hl)			;57c9
;; 	ret m			;57ca
;; 	add hl,bc			;57cb
;; 	defb 0ddh,0cbh,0fah,0cch	;set 1,(ix-006h) & ld h,(ix-006h)		;57cc
;; l57d0h:
;; 	xor h			;57d0
;; 	adc a,(hl)			;57d1
;; 	push de			;57d2
;; 	or (hl)			;57d3
;; 	add hl,sp			;57d4
;; 	nop			;57d5
;; 	sub 094h		;57d6
;; 	and e			;57d8
;; 	dec hl			;57d9
;; 	jr l5800h		;57da
;; l57dch:
;; 	or h			;57dc
;; 	ld h,c			;57dd
;; l57deh:
;; 	ld e,b			;57de
;; 	rst 28h			;57df
;; 	dec e			;57e0
;; 	adc a,0d4h		;57e1
;; 	ld e,07fh		;57e3
;; 	jp po,0b25ah		;57e5
;; 	ld b,06ah		;57e8
;; 	ld d,d			;57ea
;; 	inc c			;57eb
;; 	dec l			;57ec
;; 	in a,(071h)		;57ed
;; 	jp m,0d5f7h		;57ef
;; 	jp nz,0f15fh		;57f2
;; 	halt			;57f5
;; 	add hl,hl			;57f6
;; 	push af			;57f7
;; 	ld l,a			;57f8
;; 	sub a			;57f9
;; 	jp po,022c6h		;57fa
;; 	sbc a,h			;57fd
;; 	ld h,h			;57fe
;; 	sbc a,l			;57ff
;; l5800h:
;; 	call m,09244h		;5800
;; 	sbc a,08ch		;5803
;; 	and e			;5805
;; 	ld b,e			;5806
;; 	jp pe,08fd5h		;5807
;; 	ld l,a			;580a
;; 	call c,0347eh		;580b
;; 	cp l			;580e
;; 	pop bc			;580f
;; 	jr c,l57dch		;5810
;; 	ld c,l			;5812
;; 	sbc a,h			;5813
;; 	and h			;5814
;; 	dec hl			;5815
;; 	and b			;5816
;; 	ld a,030h		;5817
;; 	call z,016b8h		;5819
;; 	ld e,d			;581c
;; 	jr nz,l5800h		;581d
;; 	ld e,l			;581f
;; 	ld (hl),l			;5820
;; 	ld c,l			;5821
;; 	add a,a			;5822
;; 	ld d,(hl)			;5823
;; l5824h:
;; 	sbc a,l			;5824
;; 	ld e,d			;5825
;; 	ld l,c			;5826
;; 	ld d,e			;5827
;; 	ld l,d			;5828
;; 	nop			;5829
;; 	ld a,h			;582a
;; 	jr l57deh		;582b
;; 	add hl,sp			;582d
;; 	push de			;582e
;; 	ret			;582f
;; 	daa			;5830
;; 	ld a,d			;5831
;; 	xor a			;5832
;; 	rra			;5833
;; 	ld d,c			;5834
;; 	di			;5835
;; 	ret c			;5836
;; 	ld sp,00d1bh		;5837
;; 	jp 0679fh		;583a
;; 	ld a,c			;583d
;; 	ld de,07579h		;583e
;; 	ld b,02ch		;5841
;; 	sub d			;5843
;; 	ret pe			;5844
;; 	ld (0896dh),a		;5845
;; 	sbc a,c			;5848
;; 	djnz $+124		;5849
;; 	ret z			;584b
;; 	ld e,b			;584c
;; 	call nc,08c7dh		;584d
;; 	call nc,00eb4h		;5850
;; 	jr z,l588ah		;5853
;; 	ld e,h			;5855
;; 	xor (hl)			;5856
;; 	rra			;5857
;; 	dec sp			;5858
;; 	nop			;5859
;; 	rst 0			;585a
;; 	ret nc			;585b
;; 	ld b,d			;585c
;; 	ld a,e			;585d
;; 	add a,b			;585e
;; 	ld (hl),a			;585f
;; 	ld a,c			;5860
;; 	ld c,d			;5861
;; 	ld e,03ch		;5862
;; 	sbc a,b			;5864
;; 	and (hl)			;5865
;; 	jp m,0b4b5h		;5866
;; 	cp h			;5869
;; 	ld d,b			;586a
;; 	inc b			;586b
;; 	ld h,h			;586c
;; 	jr c,l5824h		;586d
;; 	sbc hl,sp		;586f
;; 	inc bc			;5871
;; 	ex af,af'			;5872
;; 	adc a,b			;5873
;; 	ld (bc),a			;5874
;; 	ld e,l			;5875
;; 	sub e			;5876
;; 	ld a,(bc)			;5877
;; 	sub 054h		;5878
;; 	inc h			;587a
;; 	ld (06678h),a		;587b
;; 	ld (0d217h),a		;587e
;; 	ld a,(hl)			;5881
;; 	sbc a,a			;5882
;; 	ld e,d			;5883
;; 	inc l			;5884
;; 	inc l			;5885
;; 	cp c			;5886
;; 	adc a,h			;5887
;; 	ld l,l			;5888
;; 	xor h			;5889
;; l588ah:
;; 	ld b,(hl)			;588a
;; 	and e			;588b
;; 	jp m,0aeb2h		;588c
;; 	sub d			;588f
;; 	or l			;5890
;; 	ld bc,0d037h		;5891
;; 	ld (hl),c			;5894
;; 	ld de,01c14h		;5895
;; 	ld c,0fbh		;5898
;; 	adc a,d			;589a
;; 	jp 0769bh		;589b
;; 	ld e,(hl)			;589e
;; 	rst 30h			;589f
;; 	and (hl)			;58a0
;; 	sub b			;58a1
;; 	ld (0fa7ah),a		;58a2
;; 	and a			;58a5
;; 	cp b			;58a6
;; 	add a,d			;58a7
;; 	jp po,0a2f2h		;58a8
;; 	ld l,a			;58ab
;; 	ld c,e			;58ac
;; 	ld (00219h),a		;58ad
;; 	pop de			;58b0
;; 	ld e,d			;58b1
;; 	ld (hl),l			;58b2
;; 	ld d,b			;58b3
;; 	ld h,b			;58b4
;; 	or b			;58b5
;; 	sub 034h		;58b6
;; 	jp pe,0d54eh		;58b8
;; 	ret po			;58bb
;; 	ld a,(bc)			;58bc
;; 	add a,056h		;58bd
;; 	call nz,05b49h		;58bf
;; 	add hl,bc			;58c2
;; 	xor e			;58c3
;; 	ld (hl),044h		;58c4
;; 	add hl,hl			;58c6
;; 	dec hl			;58c7
;; l58c8h:
;; 	ld h,d			;58c8
;; 	dec (hl)			;58c9
;; 	ld l,d			;58ca
;; 	ld a,a			;58cb
;; 	add a,d			;58cc
;; 	ld h,d			;58cd
;; 	sub (hl)			;58ce
;; 	ld (hl),09ah		;58cf
;; 	jp po,040e2h		;58d1
;; 	ld b,035h		;58d4
;; 	push de			;58d6
;; 	ld l,e			;58d7
;; 	daa			;58d8
;; 	jr nc,l5945h		;58d9
;; 	call po,0da15h		;58db
;; 	cpl			;58de
;; 	scf			;58df
;; 	adc a,(hl)			;58e0
;; 	and d			;58e1
;; 	ld h,d			;58e2
;; 	adc a,(hl)			;58e3
;; 	halt			;58e4
;; 	ld h,c			;58e5
;; 	ld c,0aah		;58e6
;; 	or d			;58e8
;; 	jr nc,l58c8h		;58e9
;; 	and (hl)			;58eb
;; 	add hl,de			;58ec
;; 	ret			;58ed
;; 	adc a,b			;58ee
;; 	ld c,005h		;58ef
;; 	jp c,08f15h		;58f1
;; 	ld (hl),h			;58f4
;; 	inc c			;58f5
;; 	dec a			;58f6
;; 	or a			;58f7
;; 	rst 10h			;58f8
;; 	ld e,(hl)			;58f9
;; 	ld c,c			;58fa
;; 	set 0,e		;58fb
;; 	dec l			;58fd
;; 	and d			;58fe
;; 	sbc a,e			;58ff
;; 	call m,sub_558bh		;5900
;; 	daa			;5903
;; 	jr $-110		;5904
;; 	ld c,(hl)			;5906
;; 	ld h,c			;5907
;; 	scf			;5908
;; 	ld l,l			;5909
;; 	rst 0			;590a
;; 	pop de			;590b
;; 	and e			;590c
;; 	xor c			;590d
;; 	or b			;590e
;; 	adc a,c			;590f
;; 	dec b			;5910
;; 	ld a,b			;5911
;; 	and (hl)			;5912
;; 	call z,00053h		;5913
;; 	and b			;5916
;; 	inc e			;5917
;; 	ld l,e			;5918
;; 	cp 0b2h		;5919
;; 	ld e,0bah		;591b
;; 	ld (hl),d			;591d
;; 	ld c,a			;591e
;; 	ld c,c			;591f
;; l5920h:
;; 	dec bc			;5920
;; 	push de			;5921
;; 	rst 28h			;5922
;; 	call nz,00e28h		;5923
;; 	ld c,0c8h		;5926
;; 	ld d,d			;5928
;; 	cp 0a8h		;5929
;; 	ld b,b			;592b
;; 	out (02ah),a		;592c
;; 	ld (hl),c			;592e
;; 	ld h,0b9h		;592f
;; 	dec e			;5931
;; 	cp e			;5932
;; l5933h:
;; 	xor (hl)			;5933
;; 	ld a,l			;5934
;; 	pop hl			;5935
;; 	ld d,00fh		;5936
;; 	di			;5938
;; 	ret pe			;5939
;; 	ld d,e			;593a
;; 	pop de			;593b
;; 	ld b,c			;593c
;; 	ld l,c			;593d
;; 	xor d			;593e
;; 	halt			;593f
;; 	dec a			;5940
;; 	ld (hl),e			;5941
;; 	jr nz,$+114		;5942
;; 	sub h			;5944
;; l5945h:
;; 	ld b,b			;5945
;; 	call z,00af5h		;5946
;; 	ret po			;5949
;; 	defb 0edh;next byte illegal after ed		;594a
;; 	xor a			;594b
;; 	jp po,l507ch		;594c
;; 	ld a,l			;594f
;; 	ld e,e			;5950
;; 	add a,e			;5951
;; 	ld l,h			;5952
;; 	ld b,(hl)			;5953
;; 	ld c,c			;5954
;; 	jp m,00ed9h		;5955
;; 	ld (hl),d			;5958
;; 	jp c,06b50h		;5959
;; 	ret p			;595c
;; 	ld l,06ah		;595d
;; 	add a,d			;595f
;; 	add a,0b4h		;5960
;; 	ret nc			;5962
;; 	ld b,c			;5963
;; 	ld a,(bc)			;5964
;; 	cp b			;5965
;; 	ld l,h			;5966
;; 	dec hl			;5967
;; 	ld (hl),e			;5968
;; 	inc l			;5969
;; 	sub d			;596a
;; 	ret c			;596b
;; 	ldd		;596c
;; 	push af			;596e
;; 	ld (hl),e			;596f
;; 	add a,(hl)			;5970
;; 	ld d,046h		;5971
;; 	sra h		;5973
;; 	ld b,a			;5975
;; 	sub (hl)			;5976
;; 	ld (hl),e			;5977
;; 	rst 20h			;5978
;; 	rst 18h			;5979
;; 	call pe,03b7fh		;597a
;; 	ld a,b			;597d
;; 	add a,d			;597e
;; 	ld h,l			;597f

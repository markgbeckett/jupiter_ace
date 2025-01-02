; z80dasm 1.1.6
; command line: z80dasm -g 15452 -a -l -o centipede.asm centipede.bin

	;; Disassembly of the Jupiter Ace game 'Centipede', written by
	;; Colin Dooley and published by Boldfield Computing in 1984.
	;;
	;; In an interview with the curator of the Jupiter Ace archive
	;; (https://www.jupiter-ace.co.uk), Colin noted that he wrote
	;; the game on an actual Jupiter Ace, hand-assembling code into
	;; hex before entering it into the computer. To my mind, this is
	;; an impresive feat of stamina and careful organisation, and is
	;; the reason ehy there is quite a bit of unused space in the
	;; code (filled with NOP commands). I suspect Colin laid out
	;; the game code, by hand, and left space between routines to
	;; allow for later changes without the need to relocate
	;; significant amounts of existing code.

	;; Register mappings for AY-3-8910/ AY-3-8912 card
AY_TONE_A:	equ 0x00
AY_TONE_B:	equ 0x02
AY_TONE_C:	equ 0x04
AY_NOISE_FREQ:	equ 0x06
AY_MIXER:	equ 0x07
AY_VOL_A:	equ 0x08
AY_VOL_B:	equ 0x09
AY_VOL_C:	equ 0x0A
AY_ENV_P:	equ 0x0B
AY_ENV_SH:	equ 0x0D

AY_MIN_VOL:	equ 0x00	; Minimum volume for sound card
AY_MAX_VOL:	equ 0x0F	; Maximum volume for sound card
AY_MAX_CHANNEL:	equ 0x03	; Three channels
	
AY_REG_PORT:	equ 0fdh
AY_DAT_PORT:	equ 0ffh

	;; Jupiter Ace Memory Map and System Variables
DISPLAY:	equ 0x2400	; Start of display buffer
CHARSET:	equ 0x2C00	; Start of character RAM 
KEYCOD:		equ 0x3c26	; ASCII code of last key pressed
FRAMES:		equ 0x3C2B

SHIP_CHR:	equ 0x05	; Character code of ship graphic
CENB_CHR:	equ 0x07	; Centipede body
CENH_CHR:	equ 0x08	; Centipede head
	
	org	03c5ch

START:	nop			;3c5c
	nop			;3c5d
	nop			;3c5e
	nop			;3c5f

	;; Entry point for game
	call SAVE_FORTH		;3c60 - Save IX, IY, and SP to enable
				;       return to Forth
	call RESTORE_GAME_DEFAULTS	;3c63 - Initialise buffer at 4180h
	call INIT_GAME_SCREEN	;3c66 - Set up graphics and initialise
				;       game screen
	call sub_4288h		;3c69 - Initialise centipede store and
				;       display centipede
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

l3c78h:	call sub_3ca8h		;3c78 - Initialise sound card
	nop			;3c7b
	nop			;3c7c
	nop			;3c7d
	nop			;3c7e
	nop			;3c7f

	;; Main game loop
l3c80h:	call 041c8h		;3c80 - Does nothing
	call sub_3ee0h		;3c83 - Play game sound
	call sub_3f28h		;3c86 - Check for fire
	call sub_3ee0h		;3c89 - Play game sound
	call sub_3f28h		;3c8c - Check for fire
	call sub_3ef0h		;3c8f - Check for direction keys
	call sub_44e8h		;3c92 - Service centipede
	call sub_46f8h		;3c95 - Service flea 

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
	db AY_VOL_A, $10
	call WRITE_TO_AY	; Set Envelope period (high byte)
	db AY_ENV_P+1, $08
	call WRITE_TO_AY	;3cb7 - Set noise period
	db AY_NOISE_FREQ, $04
	call WRITE_TO_AY	;3cbc - Set Channel B vol to 0
	db AY_VOL_B, $00

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
	;;
	;; On entry:
	;;   A - character to print
	;;   B - row coordinate of character
	;;   C - column coordinate of character
	;;
	;; On exit:
	;; 
PUT_CHR:
	;; Save registers used in routine
	push hl			;3d00
	push bc			;3d01

	;; Compute address of location for character, which is
	;; DISPLAY+0x20*B+C. Because low byte of display memory is 0x00
	;; and because B is in range 0x00--0x16 (that is, only bits
	;; 0,...,4 are relevant, can quickly multiply B by 0x20, by
	;; copying bits 0, 1, and, 2 of B into bits 5, 6, and 7 of L and
	;; bits 3 and 4 of B into bits 0 and 1 of H, which is what is
	;; done here
	ld hl,DISPLAY		;3d02 - Start of display

	;; Move B0, B1, B2 into L5, L6, and L7 (also move B3 and B4 into
	;; B0 and B1)
	srl b			;3d05
	rr l			;3d07
	srl b			;3d09
	rr l			;3d0b
	srl b			;3d0d
	rr l			;3d0f

	;; Move B4 and B5 into H0 and H1 and add on C to make final
	;; address
	add hl,bc		;3d11

	;; Deposit character
	ld (hl),a		;3d12

	;; Restore registers 
	pop bc			;3d13
	pop hl			;3d14

	;; ... and done
	ret			;3d15
	
	nop			;3d16
	nop			;3d17


	;; Retrieve character at screen location B,C
	;;
	;; On entry:
	;;   B - row coordinate of character
	;;   C - column coordinate of character
	;;
	;; On exit:
	;;   A - character retrieved
	;; 
GET_CHAR:
	;; Save registers used in routine
	push hl			;3d18
	push bc			;3d19

	;; Compute address of character, which is
	;; DISPLAY+0x20*B+C. Because low byte of display memory is 0x00
	;; and because B is in range 0x00--0x16 (that is, only bits
	;; 0,...,4 are relevant, can quickly multiply B by 0x20, by
	;; copying bits 0, 1, and, 2 of B into bits 5, 6, and 7 of L and
	;; bits 3 and 4 of B into bits 0 and 1 of H, which is what is
	;; done here
	ld hl,DISPLAY	;3d1a - Start of display

	;; Move B0, B1, B2 into L5, L6, and L7 (also move B3 and B4 into
	;; B0 and B1)
	srl b		;3d1d
	rr l		;3d1f
	srl b		;3d21
	rr l		;3d23
	srl b		;3d25
	rr l		;3d27

	;; Move B4 and B5 into H0 and H1 and add on C to make final
	;; address
	add hl,bc			;3d29

	;; Retrieve character
	ld a,(hl)			;3d2a

	;; Restore registers 
	pop bc			;3d2b
	pop hl			;3d2c

	;; ... and done
	ret			;3d2d

	nop			;3d2e
	nop			;3d2f

	;; Generate random number
	;; 
	;; On entry:
	;;
	;; On exit:
	;;   A - random number
RND:	push hl			;3d30
	ld a,(l3d3fh)		;3d31
	rlc a			;3d34
	ld l,a			;3d36
	ld a,r			;3d37 - Random number ?
l3d39h:	add a,l			;3d39
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
INIT_GAME_SCREEN:
	call sub_3de0h		;3d90 - Set up graphics

	;; Clear bottom row of the display
	ld hl,DISPLAY+17h*20h-01h	;3d93 - Address 26DF = end of row 21
l3d96h:	ld (hl),000h		;3d96
	dec hl			;3d98
	ld a,l			;3d99
	cp 0bfh			;3d9a
	jr nz,l3d96h		;3d9c

	;; Randomly place mushrooms onto the screen by visiting each
	;; character cell in turn (starting at end of row 20 and working
	;; right-to-left, bottom-to-top. For each cell, there is a
	;; 1-in-16 chance a mushroom will be printed.
l3d9eh:	call RND		;3d9e - Generate random number
	and 00fh		;3da1 - Isolate low-order nibble, given
				;       16 possible values
	jr nz,l3da9h		;3da3 - Unless is zero skip forward to
				;       print a blank square

	ld (hl),004h		;3da5 - Display mushroom
	jr l3dabh		;3da7

l3da9h:	ld (hl),000h		;3da9 - Display space

l3dabh:	dec hl			;3dab

	;; Check if done (top-left of screen is HL=2400h)
	ld a,h			;3dac - Done when HL=23FF, which is
	cp 023h			;3dad   first time that H drops to 0x23 
	jr nz,l3d9eh		;3daf - Repeat if not

	;; Print title row, inc. score, high score, and lives left
	ld bc,00020h		;3db1
	ld de,DISPLAY
	ld hl,SCORE_PANEL	;3db7
	ldir			;3dba

	call sub_3f18h		;3dbc - Initialise bug buster, reset
				;       score, dart location, and number
				;       of lives

	ret			;3dbf

	;; Top line of game screen
SCORE_PANEL: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30 ; Score
	db 0x00
l3dc9h:	db 0x05, 0x05		; Lives
	db 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00
l3dd4h:	db 0x41, 0x41, 0x41 	; Name of high-scoring player
	db 0x00
l3dd8h: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; High score

	;; Set up user-defined graphics
	;;
	;; On entry:
	;;
	;; One exit:
	;;   BC, DE, HL - corrupted
sub_3de0h:
	ld bc,11*8		;3de0 - 11 characters
	ld de,CHARSET+0x08	;3de3 - Start of character with code 1
	ld hl,UDG_DATA		;3de6 - Start of bitmap data

	ldir			;3de9

	ret			;3deb

	nop			;3dec
	nop			;3ded
	nop			;3dee
	nop			;3def

	;; Graphics characters bitmap data

	;; Quarter-mushroom (1)
UDG_DATA:
	db %00000000
	db %01111100
	db %11000010
	db %00101010
	db %00010010
	db %00000000
	db %00000000
	db %00000000

	;; Half-mushroom (2)
MROOM2:	db %00000000
	db %01111100
	db %10000010
	db %10000010
	db %10101010
	db %00010000
	db %00000000
	db %00000000

MROOM3:	;; Three-quarter mushroom (3)
	db %00000000
	db %01111100
	db %10000010
	db %10000010
	db %11000110
	db %10101010
	db %00110010
	db %00100000

MROOM4:	;; Full mushroom (4)
	db %00000000
	db %01111100
	db %10000010
	db %10000010
	db %11000110
	db %10101010
	db %00101000
	db %00111000

BBLAST:	;; Bug Blaster (5)
	db %00010000
	db %00010000
	db %00111000
	db %01010100
	db %11010110
	db %11111110
	db %01111100
	db %00111000

	;; Dart (6)
DART:	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	db %00010000
	
	;; Centipede head (7)
HEAD:	db %00111100
	db %01111110
	db %10011001
	db %10011001
	db %10011001
	db %11111111
	db %01000010
	db %00100100

	;; Centipede body (8)
l3e28h:	db %00111100
	db %01000010
	db %10111101
	db %10111101
	db %11000011
	db %11111111
	db %01000010
	db %00100100

	;; Spider left (9)
	db %00100100
	db %01010010
	db %10001010
	db %10100111
	db %01010101
	db %10001101
	db %10000111
	db %00000011

	;; Spider right (10)
	db %00100100
	db %01001010
	db %01010001
	db %11100101
	db %01101010
	db %01110001
	db %11100001
	db %11000000

	;; Flea (11)
	db %00011100
	db %00111110
	db %01001111
	db %10001111
	db %11111111
	db %01010010
	db %10010010
	db %01001001
	
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

	;; Arrive here if player moves spaceship into enemy (centipede
	;; or flea).
l3e58h:	jp l4540h		;3e58

	nop			;3e5b
	nop			;3e5c
l3e5dh:
	nop			;3e5d
	nop			;3e5e
	nop			;3e5f


	;; Check if direction controls pressed and move ship
sub_3e60h:
	push af			;3e60

	;; Port 0xDFFE reads keyboard half-row "Y", ..., "P"
	ld a,0dfh		;3e61
	in a,(0feh)		;3e63
	bit 2,a			;3e65 - Check if "I" pressed
	jp nz,l3e80h		;3e67 - Move on if not

	;; Try to move up
	ld a,b			;3e6a - Retrieve row 
	cp 010h			;3e6b - Check if upper limit
	jp z,l3e80h		;3e6d - Skip forward if so
	dec b			;3e70 - Otherwise try to move ship up
	call GET_CHAR		;3e71 - Check if obstruction
	and a			;3e74 
	jp z,l3e80h		;3e75 - Skip forward if not, as done
	cp CENB_CHR		;3e78 - Check if mushroom or laser
	jp nc,l3e58h		;3e7a - If not, must be centipede or flea
	inc b			;3e7d - Otherwise reverse move, as blocked
	nop			;3e7e
	nop			;3e7f

	;; Port 0xBFFE reads keyboard half-row "H", ..., "Enter"
l3e80h:	ld a,0bfh		;3e80
	in a,(0feh)		;3e82
	bit 1,a			;3e84 - Check if "L" pressed
	jp nz,l3ea0h		;3e86 - Move on, if not

	;; Try to move right
	ld a,c			;3e89 - Retrieve column
	cp 01fh			;3e8a - Check if at right-hand limit
	jp z,l3ea0h		;3e8c - Move on, if so
	inc c			;3e8f - Attempt to move right
	call GET_CHAR		;3e90 - Check for obstruction
	and a			;3e93 - Move on, if none
	jp z,l3ea0h		;3e94
	cp SHIP_CHR		;3e97 - Check if mushroom
	jp nc,l3e58h		;3e99 - If not, must be centipede or flea
	dec c			;3e9c - Otherwise, reverse move as blocked
	nop			;3e9d
	nop			;3e9e
	nop			;3e9f

	;; Port 0xBFFE reads keyboard half-row "H", ..., "Enter"
l3ea0h:	ld a,0bfh		;3ea0
	in a,(0feh)		;3ea2
	bit 3,a			;3ea4 - Check if "J" prssed
	jp nz,l3ec0h		;3ea6 - Move on if not

	;; Try to move left
	ld a,c			;3ea9 - Retrieve row
	cp 000h			;3eaa - Check if at left-hand limit
	jp z,l3ec0h		;3eac - Move on, if so
	dec c			;3eaf - Attempt to move left
	call GET_CHAR		;3eb0 - Check for obstruction
	and a			;3eb3 - Move on, if none
	jp z,l3ec0h		;3eb4
	cp SHIP_CHR		;3eb7 - Check if mushroom
	jp nc,l3e58h		;3eb9 - If not, must be centipede or flea
	inc c			;3ebc - Otherwise, reverse move as blocked
	nop			;3ebd
	nop			;3ebe
	nop			;3ebf

	;; Port 0x7FFE reads keyboard half-row "V", ..., "Space"
l3ec0h:	ld a,07fh		;3ec0
	in a,(0feh)		;3ec2
	bit 1,a			;3ec4 - Check if "M" pressed
	jp nz,l3eddh		;3ec6 - Move on, if not

	;; Attempt to move down
	ld a,b			;3ec9 - Retrieve row
	cp 016h			;3eca - Check if bottom of screen
	jp z,l3eddh		;3ecc - Move on, if so
	inc b			;3ecf - Attempt to move down
	call GET_CHAR		;3ed0 - Check for obstruction
	and a			;3ed3 - Move on, if none
	jp z,l3eddh		;3ed4
	cp 005h			;3ed7 - Check if mushroom
	jp nc,l3e58h		;3ed9 - If not, must be centipede or flea
	dec b			;3edc - Otherwise, reverse move as blocked

	;; Done
l3eddh:	pop af			;3edd
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


	;; Game routine #3 - Check for direction keys
sub_3ef0h:
	push af			;3ef0
	push bc			;3ef1

	ld bc,(SHIP_COORD)	;3ef2 - Retrieve current ship coord
	call GET_CHAR		;3ef6 - Retrieve character at spaceship
				;       location

l3ef9h:	cp SHIP_CHR		;3ef9 - Check if is ship

	jp nz,l3e58h		;3efb - Jump forward if not

	;; Clear ship
	ld a,000h		;3efe
	call PUT_CHR		;3f00

	;; Check if direction controls pressed and move ship
	call sub_3e60h		;3f03

	;; Redisplay ship
	ld a,SHIP_CHR		;3f06
	call PUT_CHR		;3f08
	
	ld (SHIP_COORD),bc	;3f0b

	pop bc			;3f0f
	pop af			;3f10

	ret			;3f11

SHIP_COORD:
	dw $160B		; Coordinate of ship (row, col)
	nop			;3f14
	nop			;3f15
	nop			;3f16
	nop			;3f17

	;; Print ship, reset number of lives, score, and set no dart in
	;; flight
sub_3f18h:
	push bc			;3f18

	;; Display ship in starting location
	ld bc,0160fh		;3f19 - Starting location is (22,15)
	ld a,005h		;3f1c
	call PUT_CHR		;3f1e
	ld (SHIP_COORD),bc	;3f21 - Store location

	jp l4028h		;3f25 - Continue with remainder of
				;       routine

	;; Check for fire button being pressed
sub_3f28h:
	push af			;3f28
	push bc			;3f29

	;; Check for in-flight bullet
	ld bc,(BULLET_COORD)	;3f2a - Retrieve bullet coordinates
	ld a,b			;3f2e - Non-zero coordinate indicates
	or c			;3f2f   a bullet is in flight
	jp nz,l3f48h		;3f30 - Jump forward to move bullet, if
				;       so

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
l3f3fh:	ld bc,(SHIP_COORD)		;3f3f - Possibly space ship coordinate?
	dec b			;3f43 - Move one square up to where
				;       bullet will first appear
	jp l3f92h		;3f44
	
	nop			;3f47

	;; Deal with bullet in flight
	;;
	;; On entry:
	;;   BC - Coordinates of bullet (row and col)
l3f48h:	call GET_CHAR		;3f48 - Retrieve character at B,C
	cp 006h			;3f4b - Check is bullet
	jp z,l3f60h		;3f4d - Move on, if so

	;; Display bullet at current coordinate (assume this is then
	;; handled by another routine)
l3f50h:	ld a,006h		;3f50
	call PUT_CHR		;3f52

l3f55h:	ld bc,00000h		;3f55 -  Cancel bullet

	;; Update bullet coordinate
l3f58h:	ld (BULLET_COORD),bc	;3f58

	;; Restore registers and exit
	pop bc			;3f5c
	pop af			;3f5d

	ret			;3f5e
	nop			;3f5f

l3f60h:	ld a,000h		;3f60 - Clear bullet from current 
	call PUT_CHR		;3f62   location
	dec b			;3f65 - Move bullet up screen

	jp z,l3f55h		;3f66 - If reach top of screen, delete
				;       bullet and done

l3f69h:	call GET_CHAR		;3f69 - Check if something in new cell
	cp 000h			;3f6c
	jp nz,l3f79h		;3f6e - Jump forward if so

	ld a,006h		;3f71 - Otherwise display bullet at new locn
	call PUT_CHR		;3f73 

	jp l3f58h		;3f76 - ... and wrap up routine

	;; Bullet has hit something
l3f79h:	cp 005h			;3f79 - Check if mushroom
	jp nc,l3f50h		;3f7b - If not, replace object (flea or
				;       centipede segment) by bullet and
				;       let another routine deal with
				;       consequences

	dec a			;3f7e - Damage mushroom
	jp nz,l3f8ah		;3f7f - Skip forward if mushroom not yet
				;       destroyed

	;; Update score (having destroyed mushroom)
	push hl			;3f82
	ld hl,00100h		;3f83 - one point
	call UPDATE_SCORE	;3f86
	pop hl			;3f89

l3f8ah:	call PUT_CHR		;3f8a - Print new character (either
				;       partial mushroom or space, if
				;       destroyed)

	jp l3f55h		;3f8d - Cancel bullet and wrap up

BULLET_COORD:
	db 0x13, 0x05	; 3f90 - Coordinate of bullet (row,
			; col). N.B. This define is based on the values
			; at these memory locations in the TAP file
			; though, in practice, these values are zeroed
			; when the game starts

	
	;; Arrive her from fire laser (0x3F44)
l3f92h:	call sub_3f98h		;3f92 - Play laser sound
	jp l3f69h		;3f95 - Continue with checking if bullet
				;       has hit anything

sub_3f98h:
	jp l4998h		;3f98 - Play laser sound (and return)
	nop			;3f9b
	nop			;3f9c
	nop			;3f9d
	nop			;3f9e
	nop			;3f9f

	;; Regeneration sound for mushroom
REGEN_SND:
	call WRITE_TO_AY	;3fa0
	db AY_NOISE_FREQ, $1F

	call WRITE_TO_AY	;3fa5
	db AY_ENV_P+1, $04

	call WRITE_TO_AY	;3faa
	db AY_MIXER, %00110111

	call WRITE_TO_AY	;3faf
	db AY_ENV_SH, $04

	ret			;3fb4

	nop			;3fb5
	nop			;3fb6
	nop			;3fb7

SCORE:	
l3fb8h:	db 0x00, 0x00		;3fb8
l3fbah:	db 0x58			;3fba
l3fbbh: db 0x33			;3fbb

NO_LIVES: db 0x00		;3fbc - Store for number of lives remaining
NEXT_SHIP_LOCN:	dw 0x2408	;3fbd - Store for screen address of next
				;       ship to use, if player dies
	nop			;3fbf

	;; Update score
	;;
	;; Maximum possible score is 99,999,999, which is a very high
	;; score
	;;
	;; On entry:
	;;   HL - score increment (decimal with low digits in H and high
	;;        digits in L). E.g., HL=0x1000 is 10 points and
	;;        HL=0x0010 is 1,000 points
	;;
	;; On exit:
	;;   
UPDATE_SCORE:
	push bc			;3fc0
	push de			;3fc1
	push hl			;3fc2
	push af			;3fc3

	ld de,SCORE+0x03	;3fc4 - Final digits of score (units and
				;       tens)
	ld a,(de)		;3fc7 - Retrieve digits
	add a,h			;3fc8 - Add low part of score increment
	daa			;3fc9   Adjust, as decimal calculation
	ld (de),a		;3fca - Store it
	dec de			;3fcb - Move to next digits (hundreds
				;       and thousands)
	ld a,(de)		;3fcc - Retrive digits and add high part
	adc a,l			;3fcd   of score increment, including any
				;       carry
	daa			;3fce - Adjust, as decimal calculation
	ld (de),a		;3fcf - Store it

	;; If carry from thousands (i.e., have scored multiple of 10,000
	;; points, award an extra life)
	call c,INC_LIVES	;3fd0

	dec de			;3fd3 - Move on to next digit (10^4 and
				;       10^5)
	ld a,(de)		;3fd4 - Retrieve digit
	adc a,000h		;3fd5 - Add any carry from previous calc
	daa			;3fd7
	ld (de),a		;3fd8 - Store it
	
	dec de			;3fd9 - Move on to next digit (10^6 and 10^7)
	ld a,(de)		;3fda - Retrieve digit
	adc a,000h		;3fdb - Add any carry as decimal calc
	daa			;3fdd
	ld (de),a		;3fde - Store it

	call sub_3fe8h		;3fdf

	;; Restore registers and done
	pop af			;3fe2
	pop hl			;3fe3
	pop de			;3fe4
	pop bc			;3fe5

	ret			;3fe6
	
	nop			;3fe7


	;; Do something to score
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

	;; Continuation of initialisation routine at 3F18

	;; Initially no dart in flight, score is zero, and player has
	;; two spare lives
l4028h:	ld bc,00000h		;4028
	ld (BULLET_COORD),bc	;402b - Set bullet coordinate to 00,00
	ld (SCORE),bc		;402f
	ld (SCORE+2),bc		;4033

	push af			;4037
	ld a,002h		;4038
	ld (NO_LIVES),a		;403a
	pop af			;403d

	;; Set screen address where next bug-buster is printed
	ld bc,DISPLAY+0x0A	;403e
	ld (NEXT_SHIP_LOCN),bc	;4041

	;; Restore BC ...
	pop bc			;4045

	;; ... and done
	ret			;4046

	nop			;4047

	;; Award extra life (noting player can have maximum of 10 spare
	;; lives)
	;;
	;; On entry:
	;;
	;; On exit:
	;; 
INC_LIVES:
	;; Save registers
	push hl			;4048
	push af			;4049

	ld a,(NO_LIVES)		;404a - Retrieve current lives count
	cp 00ah			;404d - Check if 10 lives (maximum)
	jr z,l405eh		;404f - Skip forward if so

	inc a			;4051 - Increase lives by one and
	ld (NO_LIVES),a		;4052   store it

	;; Add another ship to display
	ld hl,(NEXT_SHIP_LOCN)	;4055
	inc hl			;4058
	ld (hl),005h		;4059
	ld (NEXT_SHIP_LOCN),hl	;405b

	;; Restore registers
l405eh:	pop af			;405e
	pop hl			;405f

	ret			;4060

	nop			;4061
	nop			;4062
	nop			;4063
	nop			;4064
	nop			;4065
	nop			;4066
	nop			;4067

	;; Invert character (as part of explosion when player dies)
	;;
	;; On entry:
	;;   B - row coordinate of character
	;;   C - column coordinate of character
	;;
	;; On exit:
	;;   A - corrupt
INVERT_CHR:
	ld a,b			;4068 - Retrieve row
	cp 017h			;4069 - Check is on-screen
	ret nc			;406b
	ld a,c			;406c - Retrieve column
	cp 020h			;406d - Check is on-screen
	ret nc			;406f

	call GET_CHAR		;4070 - Retrieve characteter
	xor 080h		;4073 - Invert character
	call PUT_CHR		;4075 - Print character

	ret			;4078
	
	nop			;4079
	nop			;407a
	nop			;407b
	nop			;407c
	nop			;407d
	nop			;407e
	nop			;407f

	;; Print step of explosion, which creates an effect by inverting
	;; cells in the E, NE, N, NW, W, SW, S, and SE direction from
	;; the spaceship
	;;
	;; On entry:
	;;   B,C - Coordinates of epicentre of explosion
	;;   L   - Distance out of step
	;;
	;; On exit
	;;   A   - Corrupt
sub_4080h:
	push bc			;4080 - Save coordinate

	;;  Compute coordinate of right cell of explosion
	ld a,c			;4081 - Retrieve column coord and add
	add a,l			;4082   step
	ld c,a			;4083
	
	call INVERT_CHR		;4084 - Invert it

	;; Compute coordinate of top-right cell of explosion
	ld a,b			;4087 - Retrieve row coord and subtract
	sub l			;4088   step from it
	ld b,a			;4089
	
	call INVERT_CHR		;408a - Invert it

	;; Compute coordinate of top cell of explosion
	ld a,c			;408d - Retrieve column coord and 
	sub l			;408e   subtract step
	ld c,a			;408f
	
	call INVERT_CHR		;4090 - Invert it

	;; Compute coordinate of top-left cell
	ld a,c			;4093 - Retrieve column coord and
	sub l			;4094   subtract step
	ld c,a			;4095

	call INVERT_CHR		;4096 - Invert it

	;; Compute coordinate of left cell
	ld a,b			;4099 - Retrieve column coord and
	add a,l			;409a   add step
	ld b,a			;409b
	
	call INVERT_CHR		;409c - Invert it

	;; Compute coordinate of bottom-left cell
	ld a,b			;409f - Retrieve row coord and
	add a,l			;40a0   add step
	ld b,a			;40a1
	
	call INVERT_CHR		;40a2 - Invert it

	;; Compute coordinate of bottom cell
	ld a,c			;40a5 - Retrieve column coord and
	add a,l			;40a6   add step to it
	ld c,a			;40a7
	
	call INVERT_CHR		;40a8 - Invert it

	;; Compute coordinate of bottom-right cell
	ld a,c			;40ab - Retrieve column coord and
	add a,l			;40ac   add step to it
	ld c,a			;40ad
	
	call INVERT_CHR		;40ae - Invert it

	;; Restore coordinates
	pop bc			;40b1

	;; Done
	ret			;40b2

	nop			;40b3
	nop			;40b4
	nop			;40b5
	nop			;40b6
	nop			;40b7

	;; Create explosion
DISP_EXPLOSION:
	ld l,000h		;40b8 - Set initial radius of explosion

l40bah:	call sub_4080h		;40ba - Invert corner cells at current radius
	call sub_40d0h		;40bd - Step of explosion sound
	call sub_4080h		;40c0 - Revert corner cells at current
				;       radius

	inc l			;40c3 - Increase radius

	ld a,l			;40c4 - Check if reached edge of screen
	cp 01fh			;40c5

	jr nz,l40bah		;40c7 - Repeat, if not

	;; Reset Channel A volume
	call WRITE_TO_AY	;40c9
	db AY_VOL_A, $10

	ret

	nop			;40cf

	;; Explosion sound and beeper
sub_40d0h:
	ld a,l			;40d0 - Retrieve radius of explosion
	ld (EXP_SND+1),a	;40d1 - Store it as AY output data

	call sub_49d0h		;40d4 - Call explosion beeper

	;; Reset volume on AY channels A and B and turn on white noise
	;; on channel B
	call WRITE_TO_AY	;40d7
	db AY_VOL_A, $0F

	call WRITE_TO_AY	;40dc
	db AY_VOL_B, $0F
	
	call WRITE_TO_AY	;40e1
	db AY_MIXER, %00100111

	;; White noise frequency is based on current radius of explosion
	;; (set earlier in this subroutine)
	call WRITE_TO_AY	;40e6
EXP_SND:
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
	;;              Bit 0 - set for head, reset for body (or maybe
	;;                      moving vertical)
	;; 		Bit 1 - set if centipede moving right/ reset if
	;; 		        moving left
	;;              Bit 2 - set if moving down screen, otherwise up
	;; 		Bit 3 - set if double-speed segment	
	;;              Bit 4 - ???
	;; 		Bit 5 - set if segment displayed
	;;              Bit 6 - set if active segment
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
SEGMENT_CNT:	db 0x07		; Count of number of centipede segments
				; on screen
BOTTOM_ROW_CNT:	db 0x05 	; Count of number of centipede segments
				; that have reached bottom of screen
XTRA_CENT_FLAG:	db 0x00 	; Flag indicating if new-centipede timer
				; active
XTRA_CENT_TIMER: db $3E, $60	; Timer and initial-timer value for
				; introducing extra centipedes, if
				; player does not complete level quickly
				; enough

	db $01
	db $04			; Used when initialising centipede
	db $00

	;; Initialisation routine - Save Forth environment
	;;
	;; Save state for return to Forth interpretter, which requires
	;; preserving IX, IY, and SP (see Steven Vickers, "Jupiter Ace
	;; Forth Programming", Chapter 25, p.148)
	;;
	;; On entry:
	;;
	;; On exit:
	;;   HL - corrupted
SAVE_FORTH:
	pop hl			;4188 - Retrieve return address so that
				;       stack pointer is as in parent
				;       routine
	ld (IX_STR),ix		;4189 - Save IX
	ld (IY_STR),iy		;418d - Save IY
	ld (SP_STR),sp		;4191 - Save SP
	
	jp (hl)			;4195 - Return (HL contains return address

	
	nop			;4196
	nop			;4197

	;; Storage for registers that need to be restored before
	;; returning to Forth interpretter
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
	pop hl			;41a0 - Retrieve return address before
				;       resetting SP
	ld ix,(IX_STR)		;41a1 - Restore IX
	ld iy,(IY_STR)		;41a5 - Restore IY
	ld sp,(SP_STR)		;41a9 - Restore SP

	jp (hl)			;41ad - Return 

	nop			;41ae
	nop			;41af


	;; Initialisation routine #2
	;;
	;; Restore game status to defaults
	;;
	;; On entry:
	;;
	;; On exit:
	;;   BC, DE, HL - corrupted
RESTORE_GAME_DEFAULTS:
	ld hl,GAME_STATS	;41b0 - Game status is represented by
	ld de,SEGMENT_CNT	;41b3   8 bytes which can be initialised
	ld bc,00008h		;41b6   from copy located immediatelly
	ldir			;41b9   after this routine

	ret			;41bb - Done

	nop			;41bc
	nop			;41bd
	nop			;41be
	nop			;41bf

	;; Initial game status
GAME_STATS: db $0C, $00, $00, $00, $00, $00, $01, $00

	;; Game routine #1 - not used
	ret			;41c8

	ld a,07fh		;41c9
	in a,(0feh)		;41cb
	rra			;41cd
	jr nc,l41d2h		;41ce
	pop af			;41d0
	ret			;41d1

l41d2h:	call sub_41a0h		;41d2
	ld de,l41ddh		;41d5
	call 00979h		;41d8
	jp (iy)			;41db

l41ddh:	rlca			;41dd
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

l41f3h:	res 6,(hl)		;41f3
	inc hl			;41f5
	djnz l41f3h		;41f6

	;; Row number of each segment in 4101...410C, column number in
	;; 4121...412C, body/head value in 4141...414C
	ld ix,l4101h		;41f8 - Start of centipede storage
	ld b,00ch		;41fc - Centipede has 12 segments
	ld c,000h		;41fe - First segment is in column 0
	ld h,%01000110		;4200 - Segment status
	ld a,(SEGMENT_CNT+7)	;4202
	and a			;4205
	jr z,l420ah		;4206
	set 3,h			;4208 - H=$4E
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
	ld a,(SEGMENT_CNT+6)	;4223
	ld b,a			;4226
l4227h:	dec b			;4227
	jp z,l4240h		;4228

	ld (ix+000h),002h	;422b
	call RND		;422f - Get random number
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
	call GET_CHAR		;425a
	cp 005h			;425d - Check if space ship, bullet, flea, ...
	jp nc,l4273h+1		;425f - Jump forward if is

	set 5,(ix+040h)		;4262 - Comfirm is displayed
	ld (ix+060h),a		;4266 - Save original character for later
	ld a,007h		;4269 - Centipede body
	bit 0,(ix+040h)		;426b - Is it the head?
	jr nz,l4273h		;426f
	ld a,008h		;4271 - Centipede head

l4273h:	call PUT_CHR		;4273 - Display character
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
	call sub_41e8h		;4288 - Initialise centipede storage
	call sub_4248h		;428b - Display centipede
	
	ret			;428e
	nop			;428f

sub_4290h:
	push ix			;4290
	push bc			;4292
	push de			;4293
	push hl			;4294
	push af			;4295

	ld ix,l4100h		;4296 - Point to address immediately
				;before beginning of centipede data
				;(means first INC IX below works)

	;; Toggle bit 0 of SEGMENT_CNT+5, which is simple one-bit flag
	;; that determines if the centipede should move on this game
	;; loop
	ld a,(SEGMENT_CNT+5)	;429a
	xor 001h		;429d
	ld (SEGMENT_CNT+5),a	;429f

l42a2h:	inc ix		;42a2 - Advance to next segment

	;; Check if have handled all segments
	push ix		;42a4
	pop bc		;42a6
	ld a,c		;42a7
	cp 01fh		;42a8
	jp nz,l42b4h	;42aa - Proceed with main routine, if not

	;; Return to Game Routine #5, if done
	pop af			;42ad
	pop hl			;42ae
	pop de			;42af
	pop bc			;42b0
	pop ix			;42b1

	ret			;42b3

l42b4h:	bit 6,(ix+040h)		;42b4 - Check if active segment
	jp z,l42a2h		;42b8 - Continue to next segment, if not

	;; Check if segment moves on this game loop -- if
	;; (SEGMENT_CNT+5) = 1 or if double-speed segment
	ld a,(SEGMENT_CNT+5)	;42bb - Check if (SEGMENT_CNT+5)=1
	cp 001h			;42be 
	jp z,l42cah		;42c0 - If so, move segment

	;; May still move, if double-speed segment
	bit 3,(ix+040h)		;42c3 - Is double-speed segment?
	jp z,l42a2h		;42c7 - Continue to next segment, if not

l42cah:	ld b,(ix+000h)		;42ca - Retrieve coordinates of current
	ld c,(ix+020h)		;42cd   segment

	;; Check if laser at current location ???
	call GET_CHAR		;42d0
	cp 006h			;42d3
	jp nz,l4310h		;42d5

	call sub_41a0h		;42d8 - Exit game???
	rst 20h			;42db
	ex af,af'		;42dc
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

	;; Move segment left or right
sub_4300h:
	bit 1,(ix+040h)		;4300 - Is centipede facing right
	jr z,l4308h		;4304 - Move forward if not
	inc c			;4306 - Increase col coord
	
	ret			;4307

l4308h:	dec c			;4308 - Decrease col coord
	
	ret			;4309

	nop			;430a
	nop			;430b
	nop			;430c
	nop			;430d

l430eh:	nop			;430e
	nop			;430f

	;; Move centipede segment
	;;
	;; On entry
	;; - B, C coordinate of segment
	;; - IX points to a head segment
	;;
	;; On exit
	;; 
l4310h:	bit 0,(ix+040h)		;4310 - Check if head segment
	jp z,l43d0h		;4314 - Jump forward, if not
	
	bit 5,(ix+040h)		;4317 - Check if segment is masked
	jr z,l4323h		;431b - Jump forward if not
	ld a,(ix+060h)		;431d - Reinstate masked character
	call PUT_CHR		;4320

l4323h:	call sub_4300h		;4323 - Move centipede head left/ right,
				;       according to which direction it
				;       is facing

	ld a,c			;4326 - Retrieve column coord
	cp 020h			;4327 - Check if at right (or left) edge
				;       of screen
	jr nc,l4360h		;4329 - Jump on, to change direction if
				;       so

	;; Check centipede can move into space
	call GET_CHAR		;432b
	cp 000h			;432e - Is it a space?
	jr z,l433dh		;4330 - Continue, if so
	cp 005h			;4332 - Is it spaceship?
	jr z,l433dh		;4334 - Continue, if so
	cp 006h			;4336 - Is it a laser?
	jr z,l433dh		;4338 - Continue, if so
	jp l4360h		;433a - Otherwise change direction

	;; Update new centipede segment location
l433dh:	call GET_CHAR		;433d
	cp 007h			;4340 - Check if centipede
	jr nc,l4352h		;4342 - Jump forward if so
	ld (ix+060h),a		;4344
	ld a,007h		;4347 - Print centipede body
	call PUT_CHR		;4349
	set 5,(ix+040h)		;434c - Confirm segment is displayed
	jr l4356h		;4350

	;; Arrive here if new location is a centipede segment
l4352h:	res 5,(ix+040h)		;4352 - Confirm segment not displayed
l4356h:	ld (ix+000h),b		;4356 - Store new location
	ld (ix+020h),c		;4359

	jp l42a2h		;435c - Move on to next segment
	
	nop			;435f

	;; Centipede has hit obstacle or edge of screen so need to move
	;; down (or up a row) and change direction

	;; Change direction
l4360h:	ld a,%00000010		;4360 - Bit 1 of segment status indicates
	xor (ix+040h)		;4362   horizontal direction
	ld (ix+040h),a		;4365

	call sub_4300h		;4368 - Move centipede right/ left

	;;  Check if going up the screen or down
	bit 2,(ix+040h)		;436b - Bit 2 of segment status indicates
	jr nz,l4374h		;436f   vertical direction

	dec b			;4371 - Move up
	jr l4375h		;4372
	
l4374h:	inc b			;4374 - Move down

	;; Check if at row 0x10 and, if so, set centiped to bead down
	;; screen (deals with case of centipede moving back up screen)
l4375h:	ld a,b			;4375
	cp 010h			;4376
	jr nz,l437eh		;4378
	set 2,(ix+040h)		;437a

	;; Check if reached bottom of screen and, if so, set centipede
	;; to start moving up screen
l437eh:	cp 016h			;437e
	jp nz,l433dh		;4380 - Move on to update segment, if
				;       not.
	res 2,(ix+040h)		;4383 - Otherwise, set centipede segment
				;       to move up screen

	;; Check if segment has been near bottom of screen before
	bit 4,(ix+040h)		;4387 - Bit 4 of segment status
				;       indicates if so
	jr nz,l4395h		;438b - If so, move on

	;;  Increase number ofof centipede segments that have been near
	;;  bottom of screen
	ld hl,BOTTOM_ROW_CNT		;438d
	inc (hl)			;4390

	set 4,(ix+040h)		;4391

	;; Randomly choose whether centipede moves left or right
l4395h:	call RND		;4395
	and %00000010		;4398 - Bit 1 on segment status
				;       indicates horizontal direction
	xor (ix+040h)		;439a
	ld (ix+040h),a		;439d

	;; Check if at left or right edge of screen
	ld a,c			;43a0
	cp 000h			;43a1 - Check if left-hand edge of screen
	jp z,l43aeh		;43a3

	cp 01fh			;43a6 - Check if right-hand edge of screen
	jp z,l43b5h		;43a8

	jp l433dh		;43ab - Update segment

l43aeh:	set 1,(ix+040h)		;43ae - Set centipede to move right

	jp l433dh		;43b2

l43b5h:	res 1,(ix+040h)		;43b5 - Set centipede to move left

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

	;; Move centipede body segment
	;;
	;; On entry:
	;;   BC - location of segment
	;;   IX - points to segment in centipede data structure
l43d0h:	call GET_CHAR		;43d0
	cp 008h			;43d3 - Check if body segment displayed
	jr nz,l43e9h		;43d5 - Jump forward, if not

	;; Check if previous segment is active and body
	ld a,(ix+03fh)		;43d7
	and %01000001		;43da
	cp 040h			;43dc
	jr z,l43e9h		;43de - Jump forward, if so
	
	nop			;43e0
	nop			;43e1
	nop			;43e2

	;; Restore previous character
	ld a,(ix+060h)		;43e3
	call PUT_CHR		;43e6

l43e9h:	call sub_4440h		;43e9 - copy (most) of status from next
				;       segment into current

	ld b,(ix+001h)		;43ec - retrieve coordinates of next
	ld c,(ix+021h)		;43ef   segment and character there
	call GET_CHAR		;43f2

	cp 008h			;43f5 - Check if body segment displayed
	jr nz,l4401h		;43f7   and jump forward if not.

	ld a,(ix+061h)		;43f9 - Move masked character from next 
	ld (ix+060h),a		;43fc   segment into current

	jr l4423h		;43ff

l4401h:	cp 007h			;4401 - Check if head
	jr nz,l4416h		;4403 - Jump forward, if not

	;; Print body character
	ld a,008h		;4405
	call PUT_CHR		;4407

	ld a,(ix+061h)		;440a
	ld (ix+060h),a		;440d
	ld (ix+061h),008h	;4410

	jr l4423h		;4414

l4416h:	cp 007h			;4416
	jr nc,l4423h		;4418

	ld (ix+060h),a		;441a
	ld a,008h		;441d
	call PUT_CHR		;441f

	nop			;4422

l4423h:	ld a,b			;4423 - Check if on bottom row
	cp 016h			;4424
	jr nz,l4436h		;4426

	;; Check if first time at bottom of screen?
	bit 4,(ix+040h)		;4428 - Check if Bit 4 of status is set
	jr nz,l4436h		;442c - Move on, if so

	ld hl,BOTTOM_ROW_CNT	;442e - Increase counter and set Bit 4 of
	inc (hl)		;4431   segment's status register
	set 4,(ix+040h)		;4432

	;; Update coordinates and move on to next segment
l4436h:	ld (ix+000h),b		;4436
	ld (ix+020h),c		;4439

	jp l42a2h		;443c

	nop			;443f

sub_4440h:
	ld a,(ix+040h)		;4440 - Extract and save value of Bit 4 of
				;       segment status
	and %00010000		;4443
	ld h,a			;4445
	
	ld a,(ix+041h)		;4446
	and %11101110		;4449 - Mask off head and bit 4 
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

	;; Check if centipede hit by laser
sub_4460h:
	push ix		;4460
	push bc			;4462
	push hl			;4463
	push af			;4464

	ld ix,l4100h		;4465 - One before start of centipede

l4469h:	inc ix		;4469 - Advance to next segment

	;; Check if done (last segment)
	push ix		;446b - 
	pop bc		;446d
	ld a,c		;446e
	cp 01fh		;446f
	
	jr nz,l4479h		;4471

	pop af			;4473
	pop hl			;4474
	pop bc			;4475
	pop ix			;4476
	
	ret			;4478

l4479h:	bit 6,(ix+040h)		;4479 - Check if masked character???
	jr z,l4469h		;447d - Move on to next segment, if not
	
	ld b,(ix+000h)		;447f - Retrieve coordinates of segment
	ld c,(ix+020h)		;4482
	call GET_CHAR		;4485 - and then character at those
				;       coordinates
	cp 006h			;4488 - Check if laser
	jr nz,l44afh		;448a - If not, check if masked
				;       character was a laser, following
				;       code below, if it was

l448ch:	ld a,004h		;448c - Replace character with mushroom
	call PUT_CHR		;448e

	res 6,(ix+040h)		;4491 - Reset masked-segment flag
	ld hl,01000h		;4495 - Score for hitting body (10 pts)
	bit 0,(ix+040h)		;4498 - Check if have hit head
	jr z,l44a1h		;449c - Jump forward, if not
	ld hl,00001h		;449e - Have hit head (100 points)
l44a1h:	call sub_4908h		;44a1 - Update score decrement active
				;       segment count

	set 0,(ix+03fh)		;44a4 - Set previous segment to be head
	ld hl,SEGMENT_CNT		;44a8
	dec (hl)		;44ab
	
	jp l4469h		;44ac - Continue to next segment
	
l44afh:	jp l46d0h		;44af
	nop			;44b2
	nop			;44b3
	nop			;44b4
	nop			;44b5

	;; Copy of centipede legs
l44b6h:	db %01000100
	db %00100010

	;; Move legs on centipede
l44b8h:	push af
	push hl
	ld hl,(l44b6h)		;44ba
	ld a,h			;44bd
	xor %01100110		;44be
	ld h,a			;44c0
	ld a,l			;44c1
	xor %01100110		;44c2
	ld l,a			;44c4

	ld (l44b6h),hl		;44c5

	ld (02c3eh),hl		;44c8 Char 7 - Row 0 and 1
	ld (02c46h),hl		;44cb Char 8 - Row 0 and 1

	pop hl			;44ce
	pop af			;44cf

	ret			;44d0

NEW_CENT_TIMER:	nop		;44d1
	nop			;44d2
	nop			;44d3
	nop			;44d4
	nop			;44d5
	nop			;44d6
	nop			;44d7


	;; Service centipede -- called from Game Routine #5 (44e8)
sub_44d8h:
	call sub_4460h		;44d8 - Check if centipede hit by laser
	call l44b8h		;44db - Animate centipede's legs
	call sub_4290h		;44de - Move centipede
	call sub_4630h		;44e1 - Check if should add new
				;one-segment centipede

	ret			;44e4

	nop			;44e5
	nop			;44e6
	nop			;44e7


	;; Game Routine #5
sub_44e8h:
	push af			;44e8

	;; Check if centipede is visible
	ld a,(SEGMENT_CNT)	;44e9
	and a			;44ec
	jp z,l44f8h		;44ed - Jump forward to new-centipede
				;       timer, if no centipede

	;; Otherwise, move centipede
	call sub_44d8h		;44f0

	pop af			;44f3

	ret			;44f4

	nop			;44f5
	nop			;44f6
l44f7h:	nop			;44f7

	;; Check if time to introduce new centipede which, when a
	;; centipede is destroyed or after player loses a life, on a
	;; count of 40h
l44f8h:	ld a,(NEW_CENT_TIMER)	;44f8
	and a			;44fb
	jp nz,l4508h		;44fc - Could be JR NZ

	;; If zero (from previous use), reset timer
	ld a,040h		;44ff
	ld (NEW_CENT_TIMER),a	;4501

	;; Balance stack and done
	pop af			;4504

	ret			;4505 - return to main game loop

	nop			;4506
	nop			;4507

	;; Decrement new-centipede timer and check if time to release
	;; new centipede
l4508h:	dec a			;4508
	ld (NEW_CENT_TIMER),a	;4509

	jr z,l4510h		;450c - Jump forward if timer reaches zero

	;; Balance stack and done
	pop af			;450e

	ret			;450f - return to main game loop

	;; Initialise new centipede
l4510h:	ld a,(GAME_STATS)	;4510
	ld (SEGMENT_CNT),a	;4513

	ld a,000h		;4516
	ld (BOTTOM_ROW_CNT),a	;4518
	ld (XTRA_CENT_FLAG),a	;451b

	ld a,(SEGMENT_CNT+6)	;451e
	inc a			;4521
	cp 00dh			;4522
	jr z,l452bh		;4524
	ld (SEGMENT_CNT+6),a	;4526

	jr l4533h		;4529

	;; ????
l452bh:	ld a,001h		;452b
	ld (SEGMENT_CNT+6),a	;452d
	ld (SEGMENT_CNT+7),a	;4530
	
l4533h:	call sub_4288h		;4533 - Initialise and display centipede

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

	;; Arrive here if player moves spaceship into enemy (centipede
	;; or flea). Arrive here from l3e58h:
l4540h:	call DISP_EXPLOSION	;4540 - Display explosion

	ld ix,l4101h		;4543 - Pointer to centipede

	;; Delete centipede
l4547h:	bit 6,(ix+040h)		;4547 - Check if ???
	jr z,l455fh		;454b 
	bit 5,(ix+040h)		;454d - Is segment visible
	jr z,l455fh		;4551 - Jump forward if not

	;; Restore masked character (from under centipede)
	ld b,(ix+000h)		;4553 - Row value of segment
	ld c,(ix+020h)		;4556 - Column value of segment
	ld a,(ix+060h)		;4559 - Masked character

	call PUT_CHR		;455c
l455fh:
	inc ix			;455f - Move to next segment
	push ix			;4561
	pop bc			;4563

	;; Check if done (i.e., all segments deleted), otherwise repeat.
	ld a,c			;4564
	cp 01fh			;4565
	jr nz,l4547h		;4567

	;; Delete everything other than mushrooms from game board
	ld hl,02420h		;4569 - Move to start of game board (row
				;       1, column 0)
l456ch:	ld a,(hl)		;456c - Retrieve character and check if
	cp 005h			;456d   mushroom
	jr c,l4573h		;456f - Jump forward if is
	ld (hl),000h		;4571 - Otherwise delete

l4573h:	inc hl			;4573 - Move to next cell

	;; Check if reach row 23 = (2*8+7)
	ld a,l			;4574 - Check if low part of row 
	cp 0e0h			;4575   coordinate is 7 
	jr nz,l456ch		;4577 - Repeat if not
	ld a,h			;4579 - Check if high part of row
	cp 026h			;457a   coordinate is 2 (0x26-0x24 = 0x02)
	jr nz,l456ch		;457c - Repeat if not

	;; Replace any partial mushrooms with whole mushrooms, updating
	;; score for any partial mushrooms found. Because there is at
	;; most one partial mushroom per column (the first one a laser
	;; would hit), only need to search up from the bottom of each
	;; row until we find a partial mushroom/ whole mushroom)
	ld c,000h		;457e - Start at bottom-left corner
l4580h:	ld b,016h		;4580

	;; Find mushroom
l4582h:	call GET_CHAR		;4582 - Retrieve character
	and a			;4585 - If nothing there, move on
	jr z,l459ch		;4586   to check next cell

	cp 004h			;4588 - If not partial mushroom, move on
	jr nc,l459ch		;458a   to check next cell *** could
				;       probably move to next column
				;       here ***

	call GET_CHAR		;458c - Invert character
	xor 080h		;458f
	call PUT_CHR		;4591

	call sub_45b8h		;4594

	ld a,004h		;4597 - Replace character with whole mushroom
	call PUT_CHR		;4599

l459ch:	djnz l4582h		;459c - Advance to next cell up (if any
				;       more)

	;; Adavance to next column (if anymore)
	inc c			;459e - Increment column
	ld a,c			;459f - Check if reached righthand side
	cp 020h			;45a0   of screen
	jr nz,l4580h		;45a2 - Repeat if not

	ld sp,(SP_STR)		;45a4 - Restore stack pointer ???

	;; Disable flea
	ld a,000h		;45a8
	ld (FLEA_FLAG),a	;45aa

	call sub_41a0h		;45ad - Restore Forth environment

	jp l45d0h		;45b0
	nop			;45b3
	nop			;45b4
	nop			;45b5
	nop			;45b6
	nop			;45b7

	;; Play mushroom regeneration sound and update score
	;; 
	;; Called from routine (0x4594) to regenerate mushrooms after
	;; player has died
sub_45b8h:
	call REGEN_SND		;45b8
	call REGEN_BPR		;45bb

	;; Pause
	ld hl,03000h		;45be
l45c1h:	dec hl			;45c1
	ld a,h			;45c2
	or l			;45c3
	jr nz,l45c1h		;45c4

	;; Add 5 to score
	ld hl,00500h		;45c6 - 5 points
	call UPDATE_SCORE	;45c9

	ret			;45cc

	nop			;45cd
	nop			;45ce
	nop			;45cf

	;; Check if out of lives
l45d0h:	ld a,(NO_LIVES)		;45d0 - Retrieve number of lives
	and a			;45d3 - Check if zero
	jp nz,l45e0h		;45d4 - Move on, if not
	call sub_41a0h		;45d7 - Otherwise, restore Forth
				;       environment
	jp l4800h		;45da
	
	nop			;45dd
	nop			;45de
	nop			;45df

	;; Decrease number of lives and reset level
l45e0h:	dec a			;45e0
	ld (NO_LIVES),a		;45e1
	ld hl,(NEXT_SHIP_LOCN)	;45e4
	ld (hl),000h		;45e7
	dec hl			;45e9
	ld (NEXT_SHIP_LOCN),hl	;45ea
	ld a,000h		;45ed
	ld (SEGMENT_CNT),a		;45ef

	ld a,(SEGMENT_CNT+6)		;45f2
	dec a			;45f5
	ld (SEGMENT_CNT+6),a		;45f6

	ld bc,0160fh		;45f9
	ld a,005h		;45fc
	call PUT_CHR		;45fe
	ld (SHIP_COORD),bc		;4601
	ld bc,00000h		;4605
	ld (BULLET_COORD),bc		;4608
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
	call RND		;4619
	and 00ah		;461c
	or 045h		;461e
	ld (ix+040h),a		;4620
	ld a,(SEGMENT_CNT+7)		;4623
	cp 001h		;4626
	jr nz,l462eh		;4628
	set 3,(ix+040h)		;462a
l462eh:
	pop af			;462e
	ret			;462f

	;; Check if time to introduce extra, one-segment centipede. Once
	;; all centipede segments have visited bottom row of screen,
	;; additional one-segment centipedes are introduced one by one
	;; after set amounts of time. The time until each extra
	;; centipede appears reduces as each new centipede appears.
sub_4630h:
	;; Save registers
	push hl			;4630
	push af			;4631

	;; Check if new-centipede timer is active and, if so, move on to
	;; service timer
	ld a,(XTRA_CENT_FLAG)	;4632
	cp 001h			;4635

	jp z,l4658h		;4637 - Move on to service timer

	;; Check if all of centipede segments have now visited is on
	;; bottom of screen and, if so, initialise new-centipede timer
	ld a,(SEGMENT_CNT)	;463a
	ld h,a			;463d
	ld a,(BOTTOM_ROW_CNT)	;463e
	cp h			;4641
	
	jr z,l4647h		;4642 - Move on to set timer

	pop af			;4644
	pop hl			;4645
	
	ret			;4646

	;;  Initialise new-centipede timer
l4647h:	ld a,001h		;4647
	ld (XTRA_CENT_FLAG),a	;4649 - Confirms timer is active
	ld hl,06060h		;464c - Intially, timer is set to 60
				;       game loops, (plus timer-length
				;       set to 60 game loops)
	ld (XTRA_CENT_TIMER),hl	;464f - Initial value for timer

l4652h:	pop af			;4652
	pop hl			;4653

	ret			;4654
	nop			;4655
	nop			;4656
	nop			;4657

	;; Service new-centipede timer

l4658h:	ld a,(XTRA_CENT_TIMER)	;4658 - Decrement timer byte
	dec a			;465b
	ld (XTRA_CENT_TIMER),a	;465c

	jr nz,l4652h		;465f - If not zero, done

	;; Reduce start-length of extra-centipede timer, unless has
	;; already dropped to 20 game loops
	ld a,(XTRA_CENT_TIMER+1)	;4661
	cp 020h			;4664
	jr z,l466ah		;4666

	sub 008h		;4668

	;; Reset timer and store new start-length of timer
l466ah:	ld (XTRA_CENT_TIMER),a	;466a
	ld (XTRA_CENT_TIMER+1),a ;466d

	;; Search through existing segments, looking for an inactive
	;; segment that can be used for extra, one-segment centipede
	push ix			;4670 - Save IX

	ld ix,l4100h		;4672 - Immediately before start of
				;       centipede dataset

l4676h:	inc ix			;4676 - Advance to next segment

	;; Check if done (all segments)
	push ix			;4678
	pop hl			;467a
	ld a,l			;467b
	cp 01fh			;467c

	jr nz,l4685h		;467e - Move forward, if not

	;; Restore registers
	pop ix			;4680
	pop af			;4682
	pop hl			;4683

	;; Done
	ret			;4684

	;; Find first inactive centipede segment and use to create new
	;; one-segment centipede
l4685h:	bit 6,(ix+040h)		;4685 - Bit 6 determines if centipede is
				;       active
	jp nz,l4676h		;4689 - Loop if segment is active

	;; Once found, activate new, one-cell centipede
	ld (ix+000h),010h	;468c - Set starting row to 0x10

	;; Randomly set HL to be 0x4D1F or 0x4F00 (H - segment status; L
	;; - column)
	ld hl,04d1fh		;4690 - 0x4D = %01001101 (head, facing
				;       left, moving down, double-speed,
				;       segment active)
	call RND		;4693
	and 001h		;4696
	jr nz,l469dh		;4698
	ld hl,04f00h		;469a - 0x4F = %01001111 (head, facing
				;       right, moving down, double-speed,
				;       segment active)

	;; Check if double-speed is option
l469dh:	ld a,(SEGMENT_CNT+7)	;469d
	cp 001h			;46a0
	jr z,l46abh		;46a2

	;; Randomly set status bit 3 (set indicates double-speed centipede)
	call RND		;46a4
	and 008h		;46a7
	xor h			;46a9
	ld h,a			;46aa

l46abh:	ld (ix+040h),h		;46ab - Set status
	ld (ix+020h),l		;46ae - Set column coordinate

	;; Count additional centipede segment
	ld a,(SEGMENT_CNT)	;46b1
	inc a			;46b4
	ld (SEGMENT_CNT),a	;46b5

	;; Set mask to be blank
	ld (ix+060h),000h	;46b8

	;; Restore registers
	pop ix			;46bc
	pop af			;46be
	pop hl			;46bf

	;; Done
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

l46d0h:	ld a,(ix+060h)		;46d0 - Retrieve masked bit
	cp 006h			;46d3 - Check if laser 
	jp nz,l4469h		;46d5 - Move on to next segment if not
	jp l448ch		;46d8 - Jump back to handle centipede
				;       being hit
	
	nop			;46db
	nop			;46dc
	nop			;46dd
	nop			;46de
	nop			;46df
FLEA_FLAG:
	db 0x00			;46e0 - Flea is active
FLEA_COORD:	dec c			;46e1 - Flea column number
l46e2h:	ld d,001h		;46e2 - Flee row number
l46e4h:	nop			;46e4
l46e5h:	db 0x01			;46e5
CHAR_SAVE:
	db 0x20
	db 0x00
	
	;; Initialisation #5 - Zero some variables
sub_46e8h:
	push af			;46e8
	ld a,000h		;46e9
	ld (FLEA_FLAG),a		;46eb - Flee is not active
	ld (l46e2h+1),a		;46ee - Set to level 0
	pop af			;46f1
	
	ret			;46f2

	nop			;46f3
	nop			;46f4
	nop			;46f5
	nop			;46f6
	nop			;46f7


	;; Game Routine #6 - Service Flea
	;;
	;; On all levels other than first, fleas randomly drop down from
	;; top of screen, depositing new mushrooms as they go.
	;;
	;; This routine checks if there is an active flea and, if so,
	;; moves it. If no flea, the routine potentially introduces a
	;; flea.
sub_46f8h:
	push bc			;46f8
	push de			;46f9
	push hl			;46fa
	push af			;46fb

	;; Check if flea is active and move it, if so
	ld a,(FLEA_FLAG)	;46fc
	and a			;46ff
	jp nz,l4750h		;4700

	;; Check if past first level. If so, maybe introduce flea
	ld a,(l46e2h+1)		;4703
	and a			;4706
	jp nz,l471dh		;4707

	;; Check number of active centipedes?
	ld a,(SEGMENT_CNT+6)	;470a
	cp 002h			;470d
	jr z,l4716h		;470f

l4711h:	pop af			;4711
	pop hl			;4712
	pop de			;4713
	pop bc			;4714

	ret			;4715

l4716h:	ld a,001h		;4716
	ld (l46e2h+1),a		;4718
	jr l4711h		;471b

l471dh:	call RND		;471d - RND(4) with zero indicating
				;       introduction of flea
	and 03fh		;4720
	jr nz,l4711h		;4722 - If non-zero, done
	
	ld b,001h		;4724 - Set flea row-count to top of
				;       screen
	call RND		;4726 - Compute random column for flea 
	and 01fh		;4729   in 0,...,31
	ld c,a			;472b
	ld (FLEA_COORD),bc	;472c - Save flea coordinate
	ld a,001h		;4730
	ld (FLEA_FLAG),a	;4732 - Note flea is active

	;; Check and save the character at new flea's location
	call GET_CHAR		;4735
	ld (CHAR_SAVE),a	;4738

	;; Print flea
	ld a,00bh		;473b
	call PUT_CHR		;473d

	;; ??? This doesn't appear to do anything (plus not clear what
	;; initial value of h will be)
	ld l,001h		;4740
	call RND		;4742
	and h			;4745
	xor h			;4746
	ld (l46e4h),a		;4747

	jp l4711h		;474a - Done
	nop			;474d
	nop			;474e
	nop			;474f

	;; Service flea
l4750h:	ld a,(l46e5h)		;4750
	xor 001h		;4753
	ld (l46e5h),a		;4755

	ld h,a			;4758
	ld a,(l46e4h)		;4759
	and a			;475c
	jp nz,l4764h		;475d
	or h			;4760
	jp z,l4711h		;4761 - Done

	;; Retrieve location of flea and check if hit by laser
l4764h:	ld bc,(FLEA_COORD)		;4764
	call GET_CHAR		;4768
	cp 006h			;476b
	jp nz,l4783h		;476d - Move on if not

	;; Flea hit by laser, so replace by mushroom
	ld a,004h		;4770
	call PUT_CHR		;4772

	;; Update score
	ld hl,00005h		;4775 - 500 points
	call UPDATE_SCORE	;4778

	;; Deactivate flea
	ld a,000h		;477b
	ld (FLEA_FLAG),a		;477d

	;; Done
	jp l4711h		;4780

l4783h:	ld a,(CHAR_SAVE)		;4783 - Retrieve character masked by flea
	cp 000h			;4786
	jr z,l4794h		;4788
	cp 005h		;478a
	jr nc,l4790h		;478c
	jr l47a0h		;478e
l4790h:
	ld a,000h		;4790
	jr l47a0h		;4792

	;; Decide whether flea deposits mushroom (one in four chance)
l4794h:	ld h,000h		;4794 - Assume space

	call RND		;4796 - Compute RND(4)
	and 003h		;4799
	
	jr nz,l479fh		;479b
	ld h,004h		;479d - Set to mushroom if RND(4)=0

l479fh:	ld a,h			;479f - Retrieve space/ mushroom and print it
l47a0h:	call PUT_CHR		;47a0

	;; Retrieve whatever is immediately below flea on screen and save it
	inc b			;47a3
	call GET_CHAR		;47a4
	ld (CHAR_SAVE),a	;47a7

	;; Check if at bottom of screen
	ld a,b			;47aa
	cp 017h			;47ab
	jr nz,l47bbh		;47ad

	;; If so, make sure previous flea location is blank and set flea
	;; as inactive
	ld a,000h		;47af
	dec b			;47b1
	call PUT_CHR		;47b2
	ld (FLEA_FLAG),a		;47b5

	;; Done
	jp l4711h		;47b8

	;; Print flea and store new flea coordinates
l47bbh:	ld a,00bh		;47bb
	call PUT_CHR		;47bd
	ld (FLEA_COORD),bc		;47c0

	;; Done
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
l47d1h:	ld a,(FLEA_FLAG)		;47d1 - Check if flea active
	and a			;47d4
	jr nz,l47e0h		;47d5 - Jump forward if so

	;; Set Channel B volume to zero
	call WRITE_TO_AY	;47d7
	db AY_VOL_B, $00
	
l47dch:	pop af			;47dc - Restore AF
	jp l3ee3h		;47dd - Return to top level of Game
				;       Routine #2

	;; Make flea-dropping sound effect
l47e0h:	call WRITE_TO_AY		;47e0
	db AY_MIXER, %00110101
	
	call WRITE_TO_AY		;47e5
	db AY_VOL_B, $0C

	;; Set tone for flea-drop based on row coordinate of flea
	ld a,(l46e2h)		;47ea - Retrieve row number
	add a,a			;47ed - Multiply by 8
	add a,a			;47ee
	add a,a			;47ef

	call WRITE_TO_AY	;47f0
	db AY_TONE_B+1, $05

	ld (l47fch),a		;47f5

	call WRITE_TO_AY		;47f8
	db AY_TONE_B
l47fch:	db $b0

	jr l47dch		;47fd
	nop			;47ff

l4800h:	call sub_4968h		;4800

	;; Check for high score???
	ld de,02417h		;4803 - One less than largest possible
				;       digit of score

l4806h:	inc de			;4806 - Advance to next digit of high score
	inc hl			;4807 - Advance to next digit of score
	ld a,l			;4808 - Check if done
	cp 009h			;4809
	jr nz,l4810h		;480b - Jump forward if not

l480dh:	jp l4900h		;480d - Move on, not a high score

l4810h:	ld a,(de)		;4810 - Retrieve digit from high score
	cp (hl)			;4811 - Compare to score
	jr c,l4818h		;4812 - Jump forward if new high score
	jr z,l4806h		;4814 - Repeat if digits are same, could
				;       still be a new high score
	jr l480dh		;4816 - Not a high score, so move on

	;; New high score achieved: copy into score field
l4818h:	ld bc,00008h		;4818
	ld de,02418h		;481b
	ld hl,02400h		;481e
	ldir			;4821

	;; Copy score into buffer
	ld bc,00008h		;4823
	ld de,l3dd8h		;4826
	ld hl,02400h		;4829
	ldir			;482c

	jp l4850h		;482e

	nop			;4831
	nop			;4832
	nop			;4833
	nop			;4834
	nop			;4835
	nop			;4836
	nop			;4837

	;; Print message
sub_4838h:
	pop hl			;4838 - Retrieve return address

	ld a,(hl)		;4839 - Retrieve address into 0x3c1c
	ld (03c1dh),a		;483a 
	inc hl			;483d
	ld a,(hl)		;483e
	ld (03c1ch),a		;483f

l4842h:	inc hl			;4842
	ld a,(hl)		;4843
	and 07fh		;4844 - Mask off inverse flag (indicates
				;       end of string)
	rst 8			;4846 - Print it

	ld a,(hl)		;4847 - Check for inverse flag
	and 080h		;4848
	jr z,l4842h		;484a - Continue if not end of string

	inc hl			;484c
	jp (hl)			;484d

	nop			;484e
	nop			;484f

	;; Print high-score message
l4850h:	call 04838h		;4850 - *** Bug: was call 04830h ***
	db 0x24, 0xC5		; Screen location for message
	dm "Well done! You got th"
	db 0xE5

	call 04838h		; - *** Bug: was call 04830h ***
	db 0x24, 0xE5		; Screen location for message
	dm "highest score today. "
	db 0xA0

	call sub_4838h		;4886
	db 0x25, 0x05		; Screen location for message
	dm "Enter your name for  "
	db 0xA0
	
	call sub_4838h		;48a1
	db 0x25, 0x25		; Screen location for message
	dm "posterity"
	db 0xAE
	
	call sub_4838h		;48b0
	db 0x25, 0x6B		; Screen location for message
	dm "--"
	db 0xAD

	;; Start of input field for name
	ld hl,0256bh		;48b8
l48bbh:	nop			;48bb
	nop			;48bc
	nop			;48bd
l48beh:	ld a,(KEYCOD)		;48be - Get key press
	cp 005h			;48c1 - Check for "Delete"
	jr nz,l48d6h		;48c3

	;; Check if already at start of field
	ld a,l			;48c5
	cp 06bh			;48c6 - Check if start of field
	jr z,l48beh		;48c8 - Ignore and jump back, if is

	dec hl			;48ca
	ld (hl),"-"		;48cb

l48cdh:	ld a,(KEYCOD)		;48cd - Wait for key to be released
	cp 000h			;48d0
	jr nz,l48cdh		;48d2

	jr l48bbh		;48d4 - Then repeat
	
l48d6h:	and 0dfh		;48d6 - Mask off bit 7
	cp 05bh			;48d8 - Is key > "Z"? 
	jr nc,l48bbh		;48da - Ignore if so

	cp 041h			;48dc - Is key < "A"
	jr c,l48bbh		;48de - Ignore if so

	;; at this point, key is one of "A", ..., "Z"
	ld (hl),a		;48e0
	inc hl			;48e1
	ld a,l			;48e2
	cp 06eh			;48e3 - Check if end
	jr z,l48e9h		;48e5 - If so, done
	jr l48cdh		;48e7 - Otherwise, get next key

	;; Copy name to high-score name buffer
l48e9h:	ld bc,00003h		;48e9
l48ech:	ld de,l3dd4h		;48ec
	ld hl,0256bh		;48ef
	ldir		;48f2

	;; Copy name to top of screen
	ld bc,00003h		;48f4
	ld de,02414h		;48f7
	ld hl,0256bh		;48fa
	ldir			;48fd
	nop			;48ff

l4900h:	call sub_4980h		;4900 - Print Game Over
	jp (iy)			;4903 - Return to Forth 
	
l4905h:	nop			;4905
	nop			;4906
	nop			;4907

sub_4908h:
	call UPDATE_SCORE	;4908
l490bh:
	bit 4,(ix+040h)		;490b
	ret z			;490f

	;; Reduce number of active centipede segments
	ld hl,BOTTOM_ROW_CNT		;4910
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

	;; Play sound for flee, if flee is active
	;; 
	;; Accessed by Game routine #2
l4940h:	push af			;4940

	;; Check if flea is active
	ld a,(FLEA_FLAG)		;4941
	and a			;4944

	;;  Jump forward, if not
	jp z,l47d1h		;4945

	;; A = -(A+40)
	ld a,(l46e2h)		;4948 - Retrieve row number for flea
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

	;; Turn off sound and clear screen
	;;
	;; On exit:
	;;   HL - 0x23FF (immediately before start of display)
sub_4968h:
	;; Turn off AY sound
	call WRITE_TO_AY	;4968
	db AY_MIXER, 0xFF	;496b

	;; Clear screen
	ld hl,02420h		;496d
	ld (hl),000h		;4970
	ld de,02421h		;4972
	ld bc,002deh		;4975
	ldir			;4978

	ld hl,023ffh		;497a

	ret			;497d
	
	nop			;497e
	nop			;497f

sub_4980h:
	call 04838h		; - *** Bug: was call 04830h ***
	db $25, $6A
	dm "Game over"
	db $AE

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


REGEN_BPR:	
	call sub_499dh		;49c5 - Laser beeper
	call sub_499dh		;49c8 - Laser beeper

	ret			;49cb

	nop			;49cc
	nop			;49cd
	nop			;49ce
	nop			;49cf

	;; Play explosion beeper
sub_49d0h:
	ld a,l			;49d0 - Retrieve radius and work out
	scf			;49d1   2*RADIUS+1
	rla			;49d2
	add a,080h		;49d3 - Add 0x80
	nop			;49d5
	nop			;49d6
	nop			;49d7
	ld (EXP_BPR),a		;49d8 - Store in beeper routine params
	ld (EXP_BPR+4),a	;49db

	call PLAY_BEEPER	;49de - Call beeper routine
EXP_BPR: db $BD, $40, $05, $00, $BD

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
	ld a,(FLEA_FLAG)	;4a02
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

l4a88h:	ld a,AY_VOL_B		;4a88
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

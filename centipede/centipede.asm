; z80dasm 1.1.6
; command line: z80dasm -g 15452 -a -l -o centipede.asm centipede.bin

	;; Disassembly of the Jupiter Ace game 'Centipede', written by
	;; Colin Dooley and published by Boldfield Computing in 1984.
	;;
	;; The original Centipede game was developed by Donna Bailey and
	;; Ed Logg, and published by Atari in 1981 for a range of
	;; 6502-based consoles and so-called "cocktail tables". In the
	;; game, a centipede winds its way down a playing field strewn
	;; with randomly placed mushrooms. Armed with a "bug-blaster"
	;; that fires darts up the screen, the player has to shoot the
	;; centipede and avoid colliding with it. Each time the player
	;; hits a segment of the centipede it disappears though if the
	;; player hits somewhere in the middle of the centipede, the
	;; remaining segments continue as two separate centipedes. If
	;; the player is too slow, more single-centipede segments are
	;; added to the game board. Several other enemies -- notably, a
	;; flea, a spider and a scorpion -- may appear and have to be
	;; dealt with.
	;;
	;; The Ace version is a reasonably accurate conversion, though
	;; lacks the spider and the scorpion. Game play is smooth and
	;; with a reasonable difficulty level. The game is enhanced by
	;; sound effects remeniscent of the original and even supports
	;; the Boldfield Soundbox.
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
AY_DATA_WRITE_PORT:	equ 0ffh

	;; Jupiter Ace Memory Map and System Variables
DISPLAY:	equ 0x2400	; Start of display buffer
PAD:		equ 0x2701	; Pad - workspace for Forth
CHARSET:	equ 0x2C00	; Start of character RAM 
KEYCOD:		equ 0x3c26	; ASCII code of last key pressed
FRAMES:		equ 0x3C2B

	;; Graphics
UDG_BLANK:	equ 0x00
UDG_MUSH_1:	equ 0x01
UDG_MUSH_2:	equ 0x02
UDG_MUSH_3:	equ 0x03
UDG_MUSH_4:	equ 0x04
UDG_BUGB:	equ 0x05
UDG_DART:	equ 0x06
UDG_CENT_H:	equ 0x07
UDG_CENT_B:	equ 0x08
UDG_SPID_L:	equ 0x09
UDG_SPID_R:	equ 0x0A
UDG_FLEA:	equ 0x0B

ACE_IO_PORT:	equ 0xFE
	
	;; Code origin is start of parameter field for DATAM
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
	call CREATE_CENTIPEDE		;3c69 - Initialise centipede store and
				;       display centipede
	call INIT_FLEA		;3c6c - Deactivate flea
	
	nop			;3c6f
	nop			;3c70
	nop			;3c71
	nop			;3c72
	nop			;3c73
	nop			;3c74
	nop			;3c75
	nop			;3c76
	nop			;3c77

l3c78h:	call INIT_AY		;3c78 - Initialise sound card
	nop			;3c7b
	nop			;3c7c
	nop			;3c7d
	nop			;3c7e
	nop			;3c7f

	;; Main game loop
GAME_LOOP:
	call GAME_STEP_0	;3c80 - Does nothing
	call GAME_STEP_1	;3c83 - Play game sound and synchronise
				;       game by waiting for FRAMES to be
				;       updated
	call GAME_STEP_2	;3c86 - Check if fire has been pressed
	call GAME_STEP_1	;3c89 - Play game sound and synchronise
				;       game by waiting for FRAMES to be
				;       updated
	call GAME_STEP_2	;3c8c - Check for fire
	call GAME_STEP_3		;3c8f - Check for direction keys
	call GAME_STEP_4		;3c92 - Service centipede
	call GAME_STEP_5		;3c95 - Service flea 

	jp GAME_LOOP		;3c98 - Jump back to start

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
	;;
	;; On entry:
	;;
	;; On exit:
	;;   - All registered preserved
	;; 
INIT_AY:
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
	;; 
WRITE_TO_AY:
	ex (sp),hl		;3cf0 - Retrieve address from top of stack

	push af			;3cf1 
	ld a,(hl)		;3cf2 - Retrieve register number
	inc hl			;3cf3 - Advance to next byte
	out (AY_REG_PORT),a	;3cf4 - Select it
	ld a,(hl)		;3cf6 - Retrieve data
	inc hl			;3cf7 - Advance to return address
	out (AY_DATA_WRITE_PORT),a	;3cf8 - Update register

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
  	;;   - All registered preserved
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
	;;   - All other registered preserved
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

	;; ------------------------------------------------------------
	;; Play sound using built-in speaker
	;;
	;; On entry:
	;; - Five sound parameters are stored immediately after call
	;;   instruction:
	;;     Param 0 - Tone 
	;;     Param 1 - Tone increment
	;;     Param 2 - Duration (combined with Param 0)
	;;     Param 3 - Not used
	;;     Param 4 - Tone limit
	;;
	;; On exit:
	;; - All registers preserved
	;; 
	;; Operation of the Ace beeper is described (briefly) at
	;; https://k1.spdns.de/Vintage/Sinclair/80/Jupiter%20Ace/ROMs/io.txt
	;; ------------------------------------------------------------
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
	out (ACE_IO_PORT),a	;3d50 - Push loud-speaker diaphram out

	ld b,d			;3d52 - Pause appropriate time to create
l3d53h:	djnz l3d53h		;3d53   tone

	ld a,07fh		;3d55
	out (ACE_IO_PORT),a	;3d57 - Push loud-speaker diaphram out

	in a,(ACE_IO_PORT)	;3d59 - Push loud-speaker diaphram in
				;and read bottom-left keyboard half row
				;(V, B, N, M, Space)

	;; Possibly, some debugging code triggered by pressing 'Space':
	;; the subsequent NOP commands have replaced some debugging code
	rra			;3d5b - Check if Space pressed and
	jr c,l3d64h		;3d5c   skip ahead if not

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

	;; Initialisation routine #3 - Initialise game screen
INIT_GAME_SCREEN:
	call SETUP_GRAPHICS		;3d90 - Set up graphics

	;; Clear bottom row of the display
	ld hl,DISPLAY+17h*20h-01h	;3d93 - Address 26DF = end of row 21
l3d96h:	ld (hl),000h		;3d96 - Step through addresses 26DF, ..., 26C0
	dec hl			;3d98   inserting spaces as we go
	ld a,l			;3d99 - Check if completed row
	cp 0bfh			;3d9a 
	jr nz,l3d96h		;3d9c - Repeat, if not

	;; Randomly place mushrooms onto the screen by visiting each
	;; character cell in turn (starting at end of row 20 and working
	;; right-to-left, bottom-to-top. For each cell, there is a
	;; 1-in-16 chance a mushroom will be printed.
l3d9eh:	call RND		;3d9e - Generate random number
	and 00fh		;3da1 - Isolate low-order nibble, given
				;       16 possible values
	jr nz,l3da9h		;3da3 - Unless is zero skip forward to
				;       print a blank square

	ld (hl),UDG_MUSH_4	;3da5 - Display mushroom
	jr l3dabh		;3da7

l3da9h:	ld (hl),UDG_BLANK	;3da9 - Display space

l3dabh:	dec hl			;3dab

	;; Check if done (top-left of screen is HL=2400h)
	ld a,h			;3dac - Done when HL=23FF, which is
	cp 023h			;3dad   first time that H decrements to
				;       0x23
	jr nz,l3d9eh		;3daf - Repeat if not

	;; Print title row, inc. score, high score, and lives left
	ld bc,00020h		;3db1
	ld de,DISPLAY
	ld hl,STATUS_PANEL	;3db7
	ldir			;3dba

	call INIT_BUGB		;3dbc - Initialise bug buster, reset
				;       score, dart location, and number
				;       of lives

	ret			;3dbf

	;; Top line of game screen
STATUS_PANEL: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30 ; Score
	db 0x00
l3dc9h:	db 0x05, UDG_BUGB	; Lives
	db 0x00, 0x00, 0x00, 0x00, 0x00
	db 0x00, 0x00, 0x00, 0x00
l3dd4h:	db "A", "A", "A" 	; Name of high-scoring player
	db 0x00
l3dd8h: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; High score

	;; Set up user-defined graphics
	;;
	;; On entry:
	;;
	;; One exit:
	;;   BC, DE, HL - corrupted
SETUP_GRAPHICS:
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
	db %00110000
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

	;; Arrive here if player moves bug-buster into enemy (centipede
	;; or flea) or enemy moves into bug-buster.
l3e58h:	jp l4540h		;3e58

	nop			;3e5b
	nop			;3e5c
l3e5dh:
	nop			;3e5d
	nop			;3e5e
	nop			;3e5f


	;; Check if direction controls pressed and move bug-buster
sub_3e60h:
	push af			;3e60

	;; Port 0xDFFE reads keyboard half-row "Y", ..., "P"
	ld a,0dfh		;3e61
	in a,(ACE_IO_PORT)	;3e63
	bit 2,a			;3e65 - Check if "I" pressed
	jp nz,l3e80h		;3e67 - Move on if not

	;; Try to move up
	ld a,b			;3e6a - Retrieve row 
	cp 010h			;3e6b - Check if top of patrol area
	jp z,l3e80h		;3e6d - Skip forward, if so (no move)
	dec b			;3e70 - Otherwise try to move ship up
	call GET_CHAR		;3e71 - Check if obstruction
	and a			;3e74 
	jp z,l3e80h		;3e75 - Skip forward if not, as done
	cp UDG_CENT_H		;3e78 - Check if mushroom or dart
	jp nc,l3e58h		;3e7a - If not, must be centipede or
				;       flea, which will mean life lost
	inc b			;3e7d - Otherwise reverse move, as blocked

	nop			;3e7e
	nop			;3e7f

	;; Port 0xBFFE reads keyboard half-row "H", ..., "Enter"
l3e80h:	ld a,0bfh		;3e80
	in a,(ACE_IO_PORT)	;3e82
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
	cp UDG_MUSH_4+1		;3e97 - Check if mushroom
	jp nc,l3e58h		;3e99 - If not, must be centipede or
				;       flea, which will mean life lost
	dec c			;3e9c - Otherwise, reverse move as blocked

	nop			;3e9d
	nop			;3e9e
	nop			;3e9f

	;; Port 0xBFFE reads keyboard half-row "H", ..., "Enter"
l3ea0h:	ld a,0bfh		;3ea0
	in a,(ACE_IO_PORT)	;3ea2
	bit 3,a			;3ea4 - Check if "J" prssed
	jp nz,l3ec0h		;3ea6 - Move on if not

	;; Try to move left
	ld a,c			;3ea9 - Retrieve column
	cp 000h			;3eaa - Check if at left-hand limit
	jp z,l3ec0h		;3eac - Move on, if so
	dec c			;3eaf - Attempt to move left
	call GET_CHAR		;3eb0 - Check for obstruction
	and a			;3eb3 - Move on, if none
	jp z,l3ec0h		;3eb4
	cp UDG_MUSH_4+1		;3eb7 - Check if mushroom
	jp nc,l3e58h		;3eb9 - If not, must be centipede or
				;       flea, which will mean life lost
	inc c			;3ebc - Otherwise, reverse move as blocked

	nop			;3ebd
	nop			;3ebe
	nop			;3ebf

	;; Port 0x7FFE reads keyboard half-row "V", ..., "Space"
l3ec0h:	ld a,07fh		;3ec0
	in a,(ACE_IO_PORT)	;3ec2
	bit 1,a			;3ec4 - Check if "M" pressed
	jp nz,l3eddh		;3ec6 - Move on, if not

	;; Attempt to move down
	ld a,b			;3ec9 - Retrieve row
	cp 016h			;3eca - Check if bottom of patrol area
	jp z,l3eddh		;3ecc - Move on, if so
	inc b			;3ecf - Attempt to move down
	call GET_CHAR		;3ed0 - Check for obstruction
	and a			;3ed3 - Move on, if none
	jp z,l3eddh		;3ed4
	cp UDG_MUSH_4+1		;3ed7 - Check if mushroom
	jp nc,l3e58h		;3ed9 - If not, must be centipede or
				;       flea, which will mean life lost
	dec b			;3edc - Otherwise, reverse move as blocked

	;; Done
l3eddh:	pop af			;3edd

	ret			;3ede

	nop			;3edf

	
	;; ------------------------------------------------------------
	;; Game routine #1 - Play sounds and time synchronisation
	;; ------------------------------------------------------------
	;; This code is quite spaghetti-like. First jump is to a block
	;; of code that checks if flea is active and, if so, plays sound
	;; effect via beeper before jumping to second block of code
	;; which, if flea is active, plays AY sound effect. Control
	;; eventually returns to the second jump statement in this
	;; top-level routine, which will -- if flea not active -- play a
	;; background sound effect (on beeper any AY) before pausing
	;; game until FRAMES is updated, effectivly fixing timing of
	;; game loop for consistent play. Second routine RETurns to main
	;; game loop.
	;; ------------------------------------------------------------
GAME_STEP_1:
	jp l4940h		;3eea - If flee active, produce sound
				;       effect
l3ee3h:	jp l4a00h		;3ee3 - Otherwise, play background sound

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


	;; ------------------------------------------------------------
	;; Game routine #3 - Check for direction keys
	;; ------------------------------------------------------------
	;; Check if bug-buster has collided by an enemy (centipede or
	;; flea), then check if any direction keys are pressed. Move
	;; bug-buster, if possible, and check again has not collided
	;; with any enemies.
	;; 
	;; On entry:
	;;
	;; On exit:
	;; - All registers preserved
	;; ------------------------------------------------------------
GAME_STEP_3:
	;; Save registers
	push af			;3ef0
	push bc			;3ef1

	ld bc,(BUGB_COORD)	;3ef2 - Retrieve current bug-buster
				;       coordinates
	call GET_CHAR		;3ef6 - Retrieve character at bug-buster
				;       location

l3ef9h:	cp UDG_BUGB		;3ef9 - Check if is bug-buster
	jp nz,l3e58h		;3efb - Life lost if not, as bug-buster
				;	must have collided with an enemy

	;; Clear bug-buster
	ld a,UDG_BLANK		;3efe
	call PUT_CHR		;3f00

	;; Check if direction controls pressed and update bug-buster
	;; coordinates
	call sub_3e60h		;3f03

	;; Redisplay bug-buster
	ld a,UDG_BUGB		;3f06
	call PUT_CHR		;3f08

	;; Save new bug-buster coordinates
	ld (BUGB_COORD),bc	;3f0b

	;; Restore registers
	pop bc			;3f0f
	pop af			;3f10

	;; Done
	ret			;3f11

BUGB_COORD:
	dw $160B		; Coordinate of bug-buster (row, col)
	nop			;3f14
	nop			;3f15
	nop			;3f16
	nop			;3f17

	;; Print bug-buster, reset number of lives, score, and set no
	;; dart in flight
INIT_BUGB:
	push bc			;3f18

	;; Display bug-buster in starting location
	ld bc,22*256+15		;3f19 - Starting location is (22,15)
	ld a,UDG_BUGB		;3f1c
	call PUT_CHR		;3f1e
	ld (BUGB_COORD),bc	;3f21 - Store location

	jp l4028h		;3f25 - Continue with remainder of
				;       routine

	;; ------------------------------------------------------------
	;; Game routine #2 - Check for fire button
	;; ------------------------------------------------------------
	;; ------------------------------------------------------------
GAME_STEP_2:
	;; Save registers
	push af			;3f28
	push bc			;3f29

	;; Check for in-flight dart
	ld bc,(DART_COORD)	;3f2a - Retrieve dart coordinates
	ld a,b			;3f2e - Non-zero coordinate indicates
	or c			;3f2f   dart is in flight
	jp nz,l3f48h		;3f30 - Jump forward to move dart, if
				;       so

	;; No in-flight dart, so check if fire being pressed
	ld a,0fdh		;3f33 - Read from port FDFEh 
	in a,(ACE_IO_PORT)	;3f35   (keys 'A',...'G')
	bit 0,a			;3f37 - Check if 'A' pressed
	jp z,l3f3fh		;3f39 - If so, fire dart

	;; Otherwise, done
	pop bc			;3f3c
	pop af			;3f3d
	
	ret			;3f3e

	;; Fire dart
l3f3fh:	ld bc,(BUGB_COORD)	;3f3f - Retrieve coordinates of bug-blaster
	dec b			;3f43 - Move up one square to where
				;       dart will first appear
	jp l3f92h		;3f44
	
	nop			;3f47

	;; Deal with dart in flight and, if no dart, check if fire is
	;; pressed.
	;;
	;; On entry:
	;;   BC - Coordinates of dart (row and col)
	;;
	;; On exit:
	;;   All registers preserved
	;; 
l3f48h:	call GET_CHAR		;3f48 - Retrieve character at B,C
	cp UDG_DART		;3f4b - Check if is dart
	jp z,l3f60h		;3f4d - Move on, if so

	;; Display dart at current coordinate (should be picked up by
	;; routine that handles other object)
l3f50h:	ld a,UDG_DART		;3f50
	call PUT_CHR		;3f52

	;; End dart in flight, by resetting coordinates
l3f55h:	ld bc,00000h		;3f55 
l3f58h:	ld (DART_COORD),bc	;3f58

	;; Restore registers and exit
	pop bc			;3f5c
	pop af			;3f5d

	ret			;3f5e

	nop			;3f5f

	;; Move dart up one square
l3f60h:	ld a,UDG_BLANK		;3f60 - Clear dart from current 
	call PUT_CHR		;3f62   location
	dec b			;3f65 - Move dart up screen

	jp z,l3f55h		;3f66 - If reach top of screen, delete
				;       dart and done

	;; Check if dart has hit something
l3f69h:	call GET_CHAR		;3f69 - Check if something at (new)
	cp UDG_BLANK		;3f6c   dart location
	jp nz,l3f79h		;3f6e - Jump forward if so

	ld a,UDG_DART		;3f71 - Otherwise display dart at new locn
	call PUT_CHR		;3f73 

	jp l3f58h		;3f76 - ... and wrap up routine

	;; Dart has hit something
l3f79h:	cp UDG_MUSH_4+1		;3f79 - Check if mushroom
	jp nc,l3f50h		;3f7b - If not, replace object (flea or
				;       centipede segment) by dart and
				;       let another routine deal with
				;       consequences

	;; Damage mushroom and check if destroyed
	dec a			;3f7e - Damage mushroom
	jp nz,l3f8ah		;3f7f - Skip forward if mushroom not yet
				;       destroyed

	;; Update score (having destroyed mushroom)
	push hl			;3f82
	
	ld hl,00100h		;3f83 - one point
	call UPDATE_SCORE	;3f86
	
	pop hl			;3f89

l3f8ah:	call PUT_CHR		;3f8a - Print new mushroom (either
				;       partial mushroom or space, if
				;       destroyed)

	jp l3f55h		;3f8d - Cancel dart and wrap up

DART_COORD:
	db 0x13, 0x05	; 3f90 - Coordinate of dart (row,
			; col). N.B. This define is based on the values
			; at these memory locations in the TAP file
			; though, in practice, these values are zeroed
			; when the game starts

	
	;; Arrive her from firing dart (0x3F44)
	;;
	;; On entry:
	;; - BC holds coordinates of new dart
l3f92h:	call sub_3f98h		;3f92 - Play dart sound

	jp l3f69h		;3f95 - Continue with checking if dart
				;       has hit anything

sub_3f98h:
	jp l4998h		;3f98 - Play fire sound (and return)
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

SCORE:	db 0x00, 0x00		;3fb8
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
	;;   HL - score increment (BCD with low digits in H and high
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

	call DISP_SCORE		;3fdf - Convert score to ASCII and display

	;; Restore registers and done
	pop af			;3fe2
	pop hl			;3fe3
	pop de			;3fe4
	pop bc			;3fe5

	ret			;3fe6
	
	nop			;3fe7

	;; Display score (having first converted it to ASCII
DISP_SCORE:
	ld hl,PAD+0x7F		;3fe8 - Location in Forth Pad in which
				;       to store score as string
	ld de,SCORE		;3feb - Location of score in BCD
	ld b,005h		;3fee - Four bytes (eight digits) of
				;       score plus location containing
				;       number of lives

	;; *** NOTE: Loop cycles through all digits of score (in pairs)
	;; converting to ASCII and then does same for number of lives
	;; (which is stored immediately after score). Assume this is
	;; done to ensure the subsequent routine will hit a non-zero
	;; value, even if score is zero. However, it is not obvious this
	;; routine is ever called when score is zero. ***
l3ff0h:	ld a,(de)		;3ff0 - Retrieve next two digits (we
				;       refer to them as "Y" and "Z"
				;       below)

	inc de			;3ff1 - Advance pointer to next pair of
				;       digits

	push af			;3ff2 - Save current digits

	;; Retrieve high digit into A
	ld (hl),a		;3ff3 - Store in HL
	xor a			;3ff4 - (HL) = $YZ ; A = $00
	rld			;3ff5 - A = $0Y ; (HL) = $Z0  
	add a,"0"		;3ff7 - Convert to ASCII
	ld (hl),a		;3ff9 - Store digit

	inc hl			;3ffa - Advance pointer to location for
				;       next digit

	pop af			;3ffb - Restore digits

	and 00fh		;3ffc - Isolate lower digit into A
	add a,"0"		;3ffe - Convert to ASCII
	ld (hl),a		;4000 - Store digit
	inc hl			;4001 - Advance pointer to location for
				;       next digit

	djnz l3ff0h		;4002 - Repeat if more digits

	ld hl,PAD+0x7F		;4004 - Point to start of score string

	;; Find first non-zero digit of score, replacing zeros with
	;; spaces until then (this is routine that relies on non-zero
	;; value being stored in NO_LIVES: see note above)
l4007h:	ld a,(hl)		;4007
	cp "0"			;4008 - Check is non-zero and, if so, move
	jr nz,l4011h		;400a   on.
	ld (hl),000h		;400c   Otherwise, replace with space.
	
	inc hl			;400e - Advance to next digit and repeat
	jr l4007h		;400f

	;; Check for case when score is zero (if final digit of ASCII
	;; score is a space character)
l4011h:	ld a,(PAD+0x86)		;4011 - Retrieve digit
	and a			;4014 - Check if Space
	jr nz,l401ch		;4015 - Jump forward if not
	ld a,"0"		;4017 - Otherwise replace
	ld (PAD+0x86),a		;4019   by "0"

	;; Copy score string from Pad onto display
l401ch:	ld hl,PAD+0x7F		;401c - Location of string in Pad
	ld de,DISPLAY		;401f 
	ld bc,00008h		;4022 - Eight digits
	ldir			;4025

	ret			;4027

	;; Continuation of initialisation routine at 3F18

	;; Initially no dart in flight, score is zero, and player has
	;; two spare lives
l4028h:	ld bc,00000h		;4028
	ld (DART_COORD),bc	;402b - Set dart coordinate to 00,00
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
	ld (hl),UDG_BUGB	;4059
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

l4100h:	nop			;4100

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
	;;              Bit 4 - set if segment has reached bottom of
	;;                      screen
	;; 		Bit 5 - set if segment masked another character
	;;              Bit 6 - set if active segment
	;; 4161-416c - temporary store for background character
	;; 
	;; These are original values from TAP file, though they are
	;; probably not rlevant, as they are overwritten by the
	;; initialisation routine
l4101h:
	db $14, $09, $11, $15, $15, $16, $16, $16
	db $0F, $01, $16, $0C, $16, $13, $14, $15
	db $13, $12, $13, $14, $14, $14, $11, $14
	db $11, $10, $16, $15, $16, $15, $00, $00
	db $1F, $19, $0F, $07, $08, $08, $09, $0A
	db $0C, $0F, $17, $19, $15, $00, $19, $00
	db $08, $1C, $18, $02, $1f, $18, $06, $07
	db $1b, $02, $02, $01, $0b, $03, $00, $01
	db $7F, $27, $27, $66, $66, $72, $72, $73
	db $27, $26, $71, $25, $33, $33, $39, $3f
	db $37, $33, $3b, $39, $37, $3f, $37, $31
	db $39, $3d, $31, $39, $3b, $27, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $04
	db $04, $00, $00, $00, $00, $00, $00, $00
	db $05, $00, $00, $00, $00, $00, $00 


	;; 8-byte buffer, initialised at beginning of game so, likely,
	;; does not matter what is here
GAME_STATS:	
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
CENT_MOVE:	db $01		; Flag determines if centipede can move
CENTIPEDE_COUNT:
	db $04			; Used when initialising centipede
DBL_SPEED_FLAG:	
	db $00			; Used to indicate if double-speed
				; centipedes are possible

	;; ------------------------------------------------------------
	;; Initialisation routine - Save Forth environment
	;; ------------------------------------------------------------
	;; Save state for return to Forth interpretter, which requires
	;; preserving IX, IY, and SP (see Steven Vickers, "Jupiter Ace
	;; Forth Programming", Chapter 25, p.148)
	;;
	;; On entry:
	;;
	;; On exit:
	;;   HL - corrupted
	;; ------------------------------------------------------------
SAVE_FORTH:
	pop hl			;4188 - Retrieve return address so that
				;       stack pointer is as in parent
				;       routine
	ld (IX_STR),ix		;4189 - Save IX
	ld (IY_STR),iy		;418d - Save IY
	ld (SP_STR),sp		;4191 - Save SP
	
	jp (hl)			;4195 - Return (HL contains return
				;       address)

	
	nop			;4196
	nop			;4197

	;; Storage for registers that need to be restored before
	;; returning to Forth interpretter
IX_STR:	dw 0x3C00	
IY_STR:	dw 0x04C8
SP_STR:	dw 0x7FF8
	
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
RESTORE_FORTH:
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
	ld hl,INIT_GAME_STATS	;41b0 - Game status is represented by
	ld de,GAME_STATS	;41b3   8 bytes which can be initialised
	ld bc,00008h		;41b6   from copy located immediatelly
	ldir			;41b9   after this routine

	ret			;41bb - Done

	nop			;41bc
	nop			;41bd
	nop			;41be
	nop			;41bf

	;; Initial game status (copied into GAME_STATS during
	;; initialisation)
INIT_GAME_STATS: db $0C		; Number of centipede segments
	db $00			; Bottom-row count
	db $00			; Flag for extra centipedes
	db $00, $00		; Timer for exta centipedes
	db $00
	db $01			; Number of centipedes
	db $00			; Flag for double-speed centipedes

	;; ------------------------------------------------------------
	;; Game routine #0
	;; ------------------------------------------------------------
	;; Not used, though looks to be a quick way to exit back to
	;; Forth during debugging. If first instruction is replaced by
	;; `push af`, this routine will check if Space key is pressed
	;; and exit to Forth, if so.
	;;
	;; On entry:
	;;
	;; On exit:
	;;   - All registered preserved
	;; ------------------------------------------------------------
GAME_STEP_0:
	ret			;41c8 During debugging, is probably
				;     `push af`

	;; Read keyboard half-row V,...,Space and check if Space pressed
	ld a,07fh		;41c9
	in a,(ACE_IO_PORT)	;41cb
	rra			;41cd - Check for Space and jump forward
	jr nc,l41d2h		;41ce   if pressed

	pop af			;41d0 - Otherwise, balance stack and done
	ret			;41d1

l41d2h:	call RESTORE_FORTH	;41d2

	ld de,EXIT_STR		;41d5
	call 00979h		;41d8 - PRINT_STR routine in ROM

	jp (iy)			;41db - Return to Forth

EXIT_STR:
	dw 0x0007
	dm "STOPPED"

	nop			;41e6
	nop			;41e7


	;; Initialise centipede data structure
	;;
	;; Centipede data structure has four, one-dimension arrays of 15
	;; bytes (corresponding to fifteen potential centipede segments)
	;;
	;; 4101--4120 - Centipede row coordinate
	;; 4121--4140 - Centipede column coordinate
	;; 4141--4160 - Centipede status
	;; 4161--4180 - Temporary store for masked character, when
	;;              overwritten by a centipede segment
	;;
	;; On entry:
	;;
	;; On exit:
	;; 
INIT_CENTIPEDE:
	;; Save registers
	push ix			;41e8
	push bc			;41ea
	push de			;41eb
	push hl			;41ec
	push af			;41ed

	;; Start with all centipede segments inactive (bit 6 of
	;; corresponding status entry reser)
	ld hl,04141h		;41ee - Centipede status array
	ld b,01fh		;41f1 - Fifteen segments

l41f3h:	res 6,(hl)		;41f3
	inc hl			;41f5
	djnz l41f3h		;41f6

	;; Centipede initially has 12 segments, running horizontally
	;; from the top-left corner of the screen
	;; 
	;; Row number of each segment in 4101...410C, column number in
	;; 4121...412C, body/head value in 4141...414C
	ld ix,l4101h		;41f8 - Start of centipede storage
	ld b,00ch		;41fc - Centipede has 12 segments
	ld c,000h		;41fe - First segment is in column 0
	ld h,%01000110		;4200 - Segment status (bit 1 => moving
				;       right; bit 2 => moving down; bit
				;       6 => active)

	;; Check if double-speed active
	ld a,(DBL_SPEED_FLAG)	;4202
	and a			;4205
	jr z,l420ah		;4206
	set 3,h			;4208 - Set double-speed

	;; Initialise each segment in turn
l420ah:	ld (ix+000h),001h	;420a - Set row coordinate to 01 for all
				;       segments
	ld (ix+020h),c		;420e - Set column coordinate
	ld (ix+040h),h		;4211 - Set status byte 
	inc ix			;4214 - Next segment
	inc c			;4216 - Increase column coordinate
	djnz l420ah		;4217 - Repeat

	;; Set last segment to be head
	dec ix			;4219 - IX was one past end of data
				;       structure
	set 0,(ix+040h)		;421b

	;; Check if centipede needs to be split
	ld ix,l4101h		;421f - Start of centipede
	ld a,(CENTIPEDE_COUNT)	;4223 - Retrieve number of centipedes
	ld b,a			;4226 - Will be used as a counter

	;; For each additional centipede, which are head-only, convert
	;; next tail segment into one-cell centipede randomly located on
	;; row 2
l4227h:	dec b			;4227
	jp z,l4240h		;4228 - If B=0, done

	;; Turn current segment into head-only centipede
	ld (ix+000h),002h	;422b - Set row coordinate to 2
	call RND		;422f - Randomly choose column coordinate
	and 01fh		;4232 (could be duplicate column values
				;     for multiple head-only centipedes)
	ld (ix+020h),a		;4234

	call sub_4618h		;4237 - Set status byte for head-only
				;       centipede
	
	nop			;423a
	inc ix			;423b - Advance to next segment
	jp l4227h		;423d   and repeat (NOTE: Could be JR)

l4240h:				; Restore registers
	pop af			;4240
	pop hl			;4241
	pop de			;4242
	pop bc			;4243
	pop ix			;4244

	ret			;4246

	nop			;4247


	;; Display centipede
	;;
	;; On entry:
	;;
	;; On exit:
	;; 
DISP_CENTIPEDE:
	;; Save registers
	push ix			;4248
	push bc			;424a
	push de			;424b
	push hl			;424c
	push af			;424d

	ld ix,l4101h		;424e - Start of centipede
	ld d,00ch		;4252 - 12 segments

l4254h:	;; Retrieve coordinates of current segment into B and C
	ld b,(ix+000h)		;4254
	ld c,(ix+020h)		;4257

	;; Retrieve any object at B,C into A
	call GET_CHAR		;425a
	cp UDG_BUGB		;425d - Check if bug-buster, dart, flea, ...
	jp nc,l4273h		;425f - Jump forward if is (BUG: was 0x4274,
				;       but that is mid-instruction)

	;; At this point, cell is either blank or contains a mushroom
	set 5,(ix+040h)		;4262 - Set character-mask flag on cell
				;       status
	ld (ix+060h),a		;4266 - Save original character for later

	;; Display centipede segment
	ld a,UDG_CENT_H		;4269 - Centipede head
	bit 0,(ix+040h)		;426b - Is it the head?
	jr nz,l4273h		;426f - Jump forward, if so
	ld a,UDG_CENT_B		;4271 - Centipede body

l4273h:	call PUT_CHR		;4273 - Display character

	;; Advance to next segment
	inc ix			;4276 - Advance to next segment

	dec d			;4278 - Check if any more segments
	jp nz,l4254h		;4279 - Loop if so

	;; Restore registers
	pop af			;427c
	pop hl			;427d
	pop de			;427e
	pop bc			;427f
	pop ix			;4280

	;; Done
	ret			;4282
	
	nop			;4283
	nop			;4284
	nop			;4285
	nop			;4286
	nop			;4287

	;; Initialisation routine #4 - set up centipede data structure
CREATE_CENTIPEDE:
	call INIT_CENTIPEDE	;4288 - Initialise centipede storage
	call DISP_CENTIPEDE	;428b - Display centipede
	
	ret			;428e

	nop			;428f

	;; ------------------------------------------------------------
	;; Move centipede(s)
	;; ------------------------------------------------------------
	;; Step through each segment of each centipede moving the
	;; segment one step at a time, having first checked if the
	;; segment has been hit by the dart or by the bug-buster.
	;;
	;; If the centipede hits a dart, then it changes into a mushroom
	;; and, if it is not the head or final body segment of a
	;; centipede, the tail becomes a new centipede, with the leading
	;; body segment turning into a head.
	;;
	;; If the centipede hits the bug-buster, the player loses a life
	;; and (assuming the player has lives left) the game is reset.
	;;
	;; Head sections continue to move horizontally in a particular
	;; direction until they reach an obstacle (mushroom) or edge of
	;; the playing area, at which point they drop down (or up) one
	;; row and reverse their direction.  If a centipede reaches
	;; bottom of playing area, they begin to move back up the
	;; playing area but only to row 16, at which point they start
	;; moving down again, and so on.
	;;
	;; Body sections simply follow preceding section or head. 	
	;; ------------------------------------------------------------
MOVE_C:
	;; Save all registers
	push ix			;4290
	push bc			;4292
	push de			;4293
	push hl			;4294
	push af			;4295

	ld ix,l4100h		;4296 - Point to address immediately
				;before beginning of centipede data
				;(means first INC IX below works)

	;; Toggle bit 0 of CENT_MOVE, which is simple one-bit flag
	;; that determines if the centipede should move on this game
	;; loop
	ld a,(CENT_MOVE)	;429a
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

	;; Check if dart at current location. This should not be
	;; possible, as previous subroutine in this section of the game
	;; loop should already have checked this. Will raise error if is
	;; a dart and, otherwise, continue with routine.
	call GET_CHAR		;42d0
	cp UDG_DART		;42d3
	jp nz,l4310h		;42d5 - Continue with routine

	call RESTORE_FORTH	;42d8 - Restore registers for return to
				;       Forth

	rst 20h			;42db - ROM error restart routine
	db 0x08			; Indicates overflow in floating-point
				; arithmetic

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
	;; - IX points current segment
	;;
	;; On exit
	;; 
l4310h:	bit 0,(ix+040h)		;4310 - Check if head segment
	jp z,l43d0h		;4314 - Jump forward, if not

	;; From here on, dealing with a head segment
	bit 5,(ix+040h)		;4317 - Check if segment has masked
				;       another charcter
	jr z,l4323h		;431b - Jump forward if not
	ld a,(ix+060h)		;431d - Reinstate masked character
	call PUT_CHR		;4320

l4323h:	call sub_4300h		;4323 - Move centipede head left/ right
				;       by decrementing/ incrementing C,
				;       according to which direction it
				;       is facing

	;; Check if centipede has reached edge of screen
	ld a,c			;4326 - Retrieve column coord
	cp 020h			;4327 - Check if at right (or left) edge
				;       of screen (that is, A=$20 or
				;       A=$FF)
	jr nc,l4360h		;4329 - Jump on, to change direction if
				;       so

	;; Check centipede can move into space
	call GET_CHAR		;432b
	cp UDG_BLANK		;432e - Is it a space?
	jr z,l433dh		;4330 - Continue, if so
	cp UDG_BUGB		;4332 - Is it bugbuster
	jr z,l433dh		;4334 - Continue, if so
	cp UDG_DART		;4336 - Is it a dart?
	jr z,l433dh		;4338 - Continue, if so
	jp l4360h		;433a - Otherwise change direction

	;; Update new centipede segment location
l433dh:	call GET_CHAR		;433d
	cp UDG_CENT_H		;4340 - Check if a centipede or other
				;       enemy
	jr nc,l4352h		;4342 - Jump forward if so
	ld (ix+060h),a		;4344 - Store character
	ld a,UDG_CENT_H		;4347 - Display centipede head
	call PUT_CHR		;4349
	set 5,(ix+040h)		;434c - Confirm segment is masking
				;       another character
	jr l4356h		;4350 - Move on

	;; Arrive here if new location contains another enemy
l4352h:	res 5,(ix+040h)		;4352 - Confirm segment not masked

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
				;       (which will effectively move
				;       segment back to column it was in
				;       before move)

	;;  Check if going up the screen or down
	bit 2,(ix+040h)		;436b - Bit 2 of segment status indicates
	jr nz,l4374h		;436f   vertical direction

	dec b			;4371 - Move up
	jr l4375h		;4372
	
l4374h:	inc b			;4374 - Move down

	;; Check if at row 0x10 and, if so, set centipede direction to
	;; down (deals with case of centipede moving back up
	;; screen and oterwise has no effect)
l4375h:	ld a,b			;4375
	cp 010h			;4376
	jr nz,l437eh		;4378
	set 2,(ix+040h)		;437a

	;; Check if reached bottom of screen and, if so, set centipede
	;; vertical direction to up
l437eh:	cp 016h			;437e
	jp nz,l433dh		;4380 - Move on to update segment, if
				;       not
	res 2,(ix+040h)		;4383 - Otherwise, set centipede segment
				;       to move up screen

	;; Check if segment has been at bottom of screen before
	bit 4,(ix+040h)		;4387 - Bit 4 of segment status
				;       indicates if so
	jr nz,l4395h		;438b - If so, move on

	;;  Increase count of centipede segments that have been near
	;;  bottom of screen
	ld hl,BOTTOM_ROW_CNT	;438d
	inc (hl)		;4390

	set 4,(ix+040h)		;4391

	;; If centipede has just reached bottom of screen, randomly
	;; choose whether centipede moves left or right. This code
	;; only runs after the centipede has hit object or edge of
	;; playing area and moved down to bottom row, so direction
	;; persists, once selected.
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

	jp l433dh		;43b2 - Move on to update segment

l43b5h:	res 1,(ix+040h)		;43b5 - Set centipede to move left

	jp l433dh		;43b9 - Move on to update segment
	
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

	;; GOT THIS FAR
	;; Move centipede body segment
	;;
	;; On entry:
	;;   BC - location of segment
	;;   IX - points to segment in centipede data structure
l43d0h:	call GET_CHAR		;43d0
	cp UDG_CENT_B		;43d3 - Check if body segment displayed
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

	cp UDG_CENT_B		;43f5 - Check if body segment displayed
	jr nz,l4401h		;43f7   and jump forward if not.

	ld a,(ix+061h)		;43f9 - Move masked character from next 
	ld (ix+060h),a		;43fc   segment into current

	jr l4423h		;43ff

l4401h:	cp UDG_CENT_H		;4401 - Check if head
	jr nz,l4416h		;4403 - Jump forward, if not

	;; Print body character
	ld a,UDG_CENT_B		;4405
	call PUT_CHR		;4407

	ld a,(ix+061h)		;440a
	ld (ix+060h),a		;440d
	ld (ix+061h),008h	;4410

	jr l4423h		;4414

l4416h:	cp UDG_CENT_H			;4416
	jr nc,l4423h		;4418

	ld (ix+060h),a		;441a
	ld a,008h		;441d
	call PUT_CHR		;441f

	nop			;4422

l4423h:	ld a,b			;4423 - Check if on bottom row
	cp 016h			;4424
	jr nz,l4436h		;4426

	;; Check if first time at bottom of screen?
	bit 4,(ix+040h)		;4428 - Check if segment has previously
				;       reached bottom of screen
	jr nz,l4436h		;442c - Move on, if so

	ld hl,BOTTOM_ROW_CNT	;442e - Increase counter and set Bit 4 of
	inc (hl)		;4431   segment's status register
	set 4,(ix+040h)		;4432 - Set flag to indicate segment has
				;       reached bottom of screen

	;; Update coordinates and move on to next segment
l4436h:	ld (ix+000h),b		;4436
	ld (ix+020h),c		;4439

	jp l42a2h		;443c

	nop			;443f

sub_4440h:
	ld a,(ix+040h)		;4440 - Extract and save info as to whether 
	and %00010000		;4443   segment has reached bottom of
	ld h,a			;4445   screen
	
	ld a,(ix+041h)		;4446
	and %11101110		;4449 - Mask off head and reached-bottom-
				;       of-screen bit
	or h			;444b - Restore reached-bottom-of-screen
	ld (ix+040h),a		;444c   bit from previous segment

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

	;; Check if centipede hit by dart
CHECK_C_HIT:
	push ix		;4460
	push bc		;4462
	push hl		;4463
	push af		;4464

	ld ix,l4100h	;4465 - One before start of centipede

l4469h:	inc ix		;4469 - Advance to next segment

	;; Check if done (last segment)
	push ix		;446b - 
	pop bc		;446d
	ld a,c		;446e
	cp 01fh		;446f
	
	jr nz,l4479h	;4471

	pop af			;4473
	pop hl			;4474
	pop bc			;4475
	pop ix			;4476
	
	ret			;4478

l4479h:	bit 6,(ix+040h)		;4479 - Check if segment is active
	jr z,l4469h		;447d - Move on to next segment, if not
	
	ld b,(ix+000h)		;447f - Retrieve coordinates of segment
	ld c,(ix+020h)		;4482
	call GET_CHAR		;4485 - and then character at those
				;       coordinates
	cp 006h			;4488 - Check if dart
	jr nz,l44afh		;448a - If not, check if masked
				;       character is a dart and return
				;       to follow code below, if it is

	;; Segment hit by dart, so replace by mushroom and, if
	;; necessary, split centipede
l448ch:	ld a,UDG_MUSH_4		;448c - Replace character with mushroom
	call PUT_CHR		;448e

	res 6,(ix+040h)		;4491 - Reset segment-active flag
	ld hl,01000h		;4495 - Assume score for hitting body
				;       (10 pts)
	bit 0,(ix+040h)		;4498 - Check if have hit head
	jr z,l44a1h		;449c - Jump forward, if not
	ld hl,00001h		;449e - Update score for hitting head
				;       (100 points)

l44a1h:	call sub_4908h		;44a1 - Update score and decrement count
				;       of segments that have reached
				;       bottom of playing area, if
				;       necessary

	set 0,(ix+03fh)		;44a4 - Set previous segment to be head
				;       (if first segment, this will
				;       update address 0x4100, which is
				;       otherwise unused)

	ld hl,SEGMENT_CNT	;44a8 - Reduce segment count
	dec (hl)		;44ab
	
	jp l4469h		;44ac - Continue to next segment
	
l44afh:	jp l46d0h		;44af
	nop			;44b2
	nop			;44b3
	nop			;44b4
	nop			;44b5

	;; Copy of centipede legs
CENTIPEDE_LEGS:	db %01000100
	db %00100010

	;; Move legs on centipede
ANIM_C_LEGS:	push af
	push hl

	;; Load current leg pattern into H and L
	ld hl,(CENTIPEDE_LEGS)	;44ba

	;; Alternate legs
	ld a,h			;44bd
	xor %01100110		;44be
	ld h,a			;44c0
	ld a,l			;44c1
	xor %01100110		;44c2
	ld l,a			;44c4

	;; Store new leg pattern
	ld (CENTIPEDE_LEGS),hl		;44c5

	;; Update centipede graphic with new leg pattern
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


	;; Service centipede -- called from Game Routine #4 (44e8)
sub_44d8h:
	call CHECK_C_HIT	;44d8 - Check if centipede hit by dart
	call ANIM_C_LEGS	;44db - Animate centipede's legs
	call MOVE_C		;44de - Move centipede
	call CHECK_NEW_H	;44e1 - Check if should add new
				;       one-segment centipede

	ret 			;44e4

	nop			;44e5
	nop			;44e6
	nop			;44e7


	;; ------------------------------------------------------------
	;; Game Routine #4
	;; ------------------------------------------------------------
	;; 
	;; ------------------------------------------------------------
GAME_STEP_4:
	push af			;44e8

	;; Check if centipede is visible
	ld a,(SEGMENT_CNT)	;44e9 - Retrieve number of segments 
	and a			;44ec   and check if zero
	jp z,l44f8h		;44ed - Jump forward to new-centipede
				;       timer, if no centipede

	;; Otherwise, move centipede
	call sub_44d8h		;44f0

	pop af			;44f3

	ret			;44f4

	nop			;44f5
	nop			;44f6
l44f7h:	nop			;44f7

	;; Check if time to introduce new centipede which happens, when
	;; a centipede is destroyed or after player loses a life, on a
	;; count of 40h iterations
l44f8h:	ld a,(NEW_CENT_TIMER)	;44f8 - Check if timer is zero, which
	and a			;44fb   means needs reset
	jp nz,l4508h		;44fc - Otherwise, service timer (NOTE:
				;       Could be JR NZ)

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

	;; If non-zero, balance stack and done
	pop af			;450e

	ret			;450f - return to main game loop

	;; Initialise new centipede
l4510h:	ld a,(INIT_GAME_STATS)	;4510
	ld (SEGMENT_CNT),a	;4513

	ld a,000h		;4516
	ld (BOTTOM_ROW_CNT),a	;4518
	ld (XTRA_CENT_FLAG),a	;451b

	;; Increase centipede count
	ld a,(CENTIPEDE_COUNT)	;451e
	inc a			;4521
	cp 00dh			;4522 - Check if reached limit
	jr z,l452bh		;4524 - Reset if so
	ld (CENTIPEDE_COUNT),a	;4526

	jr l4533h		;4529

	;; Reset centipede count and enable double-speed option
l452bh:	ld a,001h		;452b
	ld (CENTIPEDE_COUNT),a	;452d
	ld (DBL_SPEED_FLAG),a	;4530
	
l4533h:	call CREATE_CENTIPEDE	;4533 - Initialise and display centipede

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

	;; Arrive here if player moves bug-buster into enemy (centipede
	;; or flea) or enemy moves onto bug-buster. Arrive here from
	;; l3e58h
l4540h:	call DISP_EXPLOSION	;4540 - Display explosion

	ld ix,l4101h		;4543 - Pointer to centipede

	;; Delete centipede
l4547h:	bit 6,(ix+040h)		;4547 - Check if segment is active
	jr z,l455fh		;454b - Jump forward, if not
	bit 5,(ix+040h)		;454d - Check if segment masked another
				;       character
	jr z,l455fh		;4551 - Jump forward, if not

	;; Restore masked character (from under centipede)
	ld b,(ix+000h)		;4553 - Row value of segment
	ld c,(ix+020h)		;4556 - Column value of segment
	ld a,(ix+060h)		;4559 - Masked character
	call PUT_CHR		;455c

l455fh:	inc ix			;455f - Move to next segment

	;; Check if done (i.e., all segments deleted), otherwise repeat.
	push ix			;4561
	pop bc			;4563
	ld a,c			;4564
	cp 01fh			;4565
	jr nz,l4547h		;4567

	;; Delete everything other than mushrooms from game board
	ld hl,02420h		;4569 - Move to start of game board (row
				;       1, column 0)
l456ch:	ld a,(hl)		;456c - Retrieve character and check if
	cp UDG_MUSH_4+1		;456d   mushroom
	jr c,l4573h		;456f - Skip forward if is
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

	cp UDG_MUSH_4		;4588 - If not partial mushroom, move on
	jr nc,l459ch		;458a   to check next cell *** could
				;       probably move to next column
				;       here ***

	call GET_CHAR		;458c - Invert character
	xor 080h		;458f
	call PUT_CHR		;4591

	call REGEN_MUSHROOM	;4594 - Play mushroom regeneration sound
				;       and add to score

	ld a,UDG_MUSH_4		;4597 - Replace (inverted) partial
	call PUT_CHR		;4599   mushroom with whole mushroom

l459ch:	djnz l4582h		;459c - Advance to next cell up (if any
				;       more) by decrementing B

	;; Adavance to next column (if anymore)
	inc c			;459e - Increment column
	ld a,c			;459f - Check if reached righthand side
	cp 020h			;45a0   of screen
	jr nz,l4580h		;45a2 - Repeat if not

	ld sp,(SP_STR)		;45a4 - Restore stack pointer ???

	;; Disable flea
	ld a,000h		;45a8
	ld (FLEA_FLAG),a	;45aa

	call RESTORE_FORTH		;45ad - Restore Forth
				;       environment (*** NOTE: not
				;       needed as done in subsequemt
				;       code block ***)

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
REGEN_MUSHROOM:
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
	call RESTORE_FORTH	;45d7 - Otherwise, restore Forth
				;       environment *** NOTE: This would
				;       be better done in routine at
				;       address 0x4900 ***

	jp CHECK_HIGH_SCORE		;45da - Move on to check if high score
	
	nop			;45dd
	nop			;45de
	nop			;45df

	;; Decrease number of lives and reset level
l45e0h:	dec a			;45e0
	ld (NO_LIVES),a		;45e1

	;; Update number of spare bug-busters displayed at top of screen
	ld hl,(NEXT_SHIP_LOCN)	;45e4
	ld (hl),000h		;45e7
	dec hl			;45e9
	ld (NEXT_SHIP_LOCN),hl	;45ea

	;; Restore centipede count to zero
	ld a,000h		;45ed
	ld (SEGMENT_CNT),a	;45ef

	;; Reduce difficulty???
	ld a,(CENTIPEDE_COUNT)	;45f2
	dec a			;45f5
	ld (CENTIPEDE_COUNT),a	;45f6

	;; Reset bug-buster location to starting location
	ld bc,0160fh		;45f9
	ld a,UDG_BUGB		;45fc
	call PUT_CHR		;45fe
	ld (BUGB_COORD),bc	;4601

	;; Reset any in-flight darts
	ld bc,00000h		;4605
	ld (DART_COORD),bc	;4608

	jp l3c78h		;460c - Return to start of main game
				;       loop (having first
				;       re-initialised the AY sound
				;       chip)
	
	nop			;460f
	nop			;4610
	nop			;4611
	nop			;4612
	nop			;4613
	nop			;4614
	nop			;4615
	nop			;4616
	nop			;4617

	;; Set initial status of head-only centipede
	;;
	;; On entry:
	;;   IX - points to corresponding centipede segment
	;;
	;; On exit:
	;; 
sub_4618h:
	push af			;4618

	;; Create status byte for segment, possibly single-speed/
	;; double-speed, moving left/ right, definitely moving down and
	;; a head
	call RND		;4619
	and %00001010		;461c - Randomly select moving left/
				;right (bit 1) and double-speed (bit 3)
				;double-speed
	or %01000101		;461e - Set bit 6 (active), bit 3
				;       (moving down), and bit 0 (head)
	ld (ix+040h),a		;4620 - Store status

	;; Check if should be double-speed
	ld a,(DBL_SPEED_FLAG)	;4623
	cp 001h			;4626
	jr nz,l462eh		;4628
	set 3,(ix+040h)		;462a

	;; Restore register and done
l462eh:	pop af			;462e

	ret			;462f

	;; ------------------------------------------------------------
	;; Check if time to introduce extra, one-segment centipede. Once
	;; all centipede segments have visited bottom row of screen,
	;; additional one-segment centipedes are introduced one by one
	;; after set amounts of time. The time until each extra
	;; centipede appears reduces as each new centipede appears.
	;; ------------------------------------------------------------
CHECK_NEW_H:
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

	;; Otherwise time to introduce a new one-segment centipede
	
	;; First, reduce start-length of extra-centipede timer, unless has
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
	jp nz,l4676h		;4689 - Loop if segment is active (NOTE:
				;could be JR)

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
l469dh:	ld a,(DBL_SPEED_FLAG)	;469d
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

	;; Set masked character to be space
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
	cp UDG_DART		;46d3 - Check if dart
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
FLEA_COORD:	db 0x0D, 0x16	;46e1 - Flea column and ruw number
FLEA_ENABLE:	db 0x01			;46e3 - Flea enable
FLEA_SPEED:	db 0x00			;46e4
FLEA_TIMER:	db 0x01			;46e5
	
CHAR_SAVE:
	db 0x20
	db 0x00
	
	;; Initialisation #5 - Initialise (and disable) flea
INIT_FLEA:
	push af			;46e8

	ld a,000h		;46e9
	ld (FLEA_FLAG),a	;46eb - Flea is not active
	ld (FLEA_ENABLE),a	;46ee - Flea is disabled

	pop af			;46f1
	
	ret			;46f2

	nop			;46f3
	nop			;46f4
	nop			;46f5
	nop			;46f6
	nop			;46f7


	;; Game Routine #5 - Service Flea
	;;
	;; Once the first centipede has been destroyed, fleas randomly
	;; drop down from top of screen, occasionally depositing new
	;; mushrooms as they go.
	;;
	;; This routine checks if there is an active flea and, if so,
	;; moves it. If no flea, the routine potentially introduces a
	;; flea.
	;;
	;; On entry:
	;;
	;; On exit:
	;; - All registers preserved
GAME_STEP_5:
	;; Save registers
	push bc			;46f8
	push de			;46f9
	push hl			;46fa
	push af			;46fb

	;; Check if flea is active and move it, if so
	ld a,(FLEA_FLAG)	;46fc
	and a			;46ff
	jp nz,l4750h		;4700

	;; Check if past first level. If so, maybe introduce flea
	ld a,(FLEA_ENABLE)	;4703
	and a			;4706
	jp nz,l471dh		;4707

	;; If there are two active centipedes, then time to enable flea
	ld a,(CENTIPEDE_COUNT)	;470a
	cp 002h			;470d
	jr z,l4716h		;470f

l4711h:	pop af			;4711
	pop hl			;4712
	pop de			;4713
	pop bc			;4714

	ret			;4715

	;; Enable flea feature for game
l4716h:	ld a,001h		;4716
	ld (FLEA_ENABLE),a	;4718
	jr l4711h		;471b - Done

	;; At this point, flea feature is enabled but no fleas are
	;; active, so check if time to activate flea (one in four
	;; chance)
l471dh:	call RND		;471d - RND(4) with zero indicating
				;       introduction of flea
	and 03fh		;4720 - Mask off lowest two bits so can
				;       test a one-in-four chance
	jr nz,l4711h		;4722 - If non-zero, done
	
	ld b,001h		;4724 - Set flea row-coordinate to top
				;       of screen
	call RND		;4726 - Compute random column for flea 
	and 01fh		;4729   in range 0,...,31
	ld c,a			;472b
	ld (FLEA_COORD),bc	;472c - Save flea coordinate
	ld a,001h		;4730
	ld (FLEA_FLAG),a	;4732 - Note flea is active

	;; Check and save the character at new flea's location
	call GET_CHAR		;4735
	ld (CHAR_SAVE),a	;4738

	;; Print flea
	ld a,UDG_FLEA		;473b
	call PUT_CHR		;473d

	;; Decide speed of flea - 50/50 chance of being full speed of
	;; half speed
	ld h,0x01		;4740 *** BUG: Was ld l,001h ***
	call RND		;4742 *** NOTE: This could be much
				;         simpler - `call RND` / `xor
				;         0x01` ***
	and h			;4745
	xor h			;4746
	ld (FLEA_SPEED),a	;4747
				;    
	jp l4711h		;474a - Done

	nop			;474d
	nop			;474e
	nop			;474f

	;; Service flea
l4750h:	ld a,(FLEA_TIMER)	;4750 - Toggle timer between 1 and 0
	xor 001h		;4753
	ld (FLEA_TIMER),a	;4755

	;; Check if half-speed flea or full-speed flea. If half-speed
	;; and if timer is zero, do nothing
	ld h,a			;4758
	ld a,(FLEA_SPEED)	;4759
	and a			;475c
	jp nz,l4764h		;475d
	or h			;4760
	jp z,l4711h		;4761 - Done

	;; Retrieve location of flea and check if hit by dart
l4764h:	ld bc,(FLEA_COORD)	;4764
	call GET_CHAR		;4768
	cp UDG_DART		;476b
	jp nz,l4783h		;476d - Move on if not

	;; Flea hit by dart, so replace by mushroom
	ld a,UDG_MUSH_4		;4770
	call PUT_CHR		;4772

	;; Update score
	ld hl,00005h		;4775 - 500 points
	call UPDATE_SCORE	;4778

	;; Deactivate flea
	ld a,000h		;477b
	ld (FLEA_FLAG),a	;477d

	;; Done
	jp l4711h		;4780 - Done

l4783h:	ld a,(CHAR_SAVE)	;4783 - Retrieve character masked by flea
	cp UDG_BLANK		;4786 - Check if flea is on blank cell
	jr z,l4794h		;4788   and move to check if drops
				;       mushroom
	cp UDG_MUSH_4+1		;478a - Check if flea is on mushroom
	jr nc,l4790h		;478c   Move on to replace by space if not
	jr l47a0h		;478e - Move on to restore previous
				;       character
l4790h:
	ld a,000h		;4790 - Set previous character to space
	jr l47a0h		;4792   and jump forward to print it

	;; Decide whether flea deposits mushroom (one in four
	;; chance).
	;; 
	;; *** NOTE: In Atari original game, flea only deposits mushroom
	;; if there are fewer than a certain number on screen ***
l4794h:	ld h,UDG_BLANK		;4794 - Assume flea will deposit a space

	call RND		;4796 - Compute RND(4)
	and 003h		;4799
	
	jr nz,l479fh		;479b - If 1, 2, or 3, move on, or
	ld h,UDG_MUSH_4		;479d   set to mushroom if 0

l479fh:	ld a,h			;479f - Retrieve space/ mushroom and print it

l47a0h:	call PUT_CHR		;47a0

	;; Retrieve character at new location for flea and save it
	inc b			;47a3 - Advance to next row
	call GET_CHAR		;47a4 - Retrieve character
	ld (CHAR_SAVE),a	;47a7 - Save it

	;; Check if at bottom of screen
	ld a,b			;47aa
	cp 017h			;47ab
	jr nz,l47bbh		;47ad

	;; If so, make sure previous flea location is blank and set flea
	;; as inactive
	ld a,UDG_BLANK		;47af
	dec b			;47b1
	call PUT_CHR		;47b2
	ld (FLEA_FLAG),a	;47b5

	;; Done
	jp l4711h		;47b8

	;; Print flea and store new flea coordinates
l47bbh:	ld a,UDG_FLEA		;47bb 
	call PUT_CHR		;47bd
	ld (FLEA_COORD),bc	;47c0

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
	
	;; ------------------------------------------------------------
	;; Play flea-dropping sound effect on AY chip
	;; ------------------------------------------------------------
	push af			;47d0 - Does not seem to be used: entry
				;       point is usually at next command
				;       with AF already stacked

l47d1h:	ld a,(FLEA_FLAG)	;47d1 - Check if flea active
	and a			;47d4
	jr nz,l47e0h		;47d5 - Jump forward if so

	call WRITE_TO_AY	;47d7 - Otherwise mute channel B
	db AY_VOL_B, $00
	
l47dch:	pop af			;47dc - Restore A
	
	jp l3ee3h		;47dd - Move on to next part of Game
				;       Routine #2

l47e0h:	call WRITE_TO_AY	;47e0
	db AY_MIXER, %00110101	; Channel A - sound; Channel B - noise;
				; Channel C - off

	;; Set volumne for Channel B
	call WRITE_TO_AY	;47e5
	db AY_VOL_B, $0C

	;; Set tone for flea-drop based on row coordinate of flea
	ld a,(FLEA_COORD+1)	;47ea - Retrieve row number
	add a,a			;47ed - A = 8*A
	add a,a			;47ee
	add a,a			;47ef

	call WRITE_TO_AY	;47f0 - Set coarse tone for channel B
	db AY_TONE_B+1, $05

	ld (l47fch),a		;47f5 - Set fine tone for Channel B,
				;       based on A
	call WRITE_TO_AY	;47f8 - 
	db AY_TONE_B
l47fch:	db $b0

	jr l47dch		;47fd - Jump back to wrap-up for routine

	
	nop			;47ff

	;; ------------------------------------------------------------
	;; End-game sequence
	;; ------------------------------------------------------------
	;; Player has run out of lives, so check if new high score,
	;; before returning to Forth.
	;; ------------------------------------------------------------
CHECK_HIGH_SCORE:	
	call sub_4968h		;4800 - Turn of AY sound and clear all
				;       but top row of screen. On exit,
				;       HL = DISPLAY-01

	;; Check for high score???
	ld de,02417h		;4803 - One less than largest possible
				;       digit of score

l4806h:	inc de			;4806 - Advance to next digit of high score
	inc hl			;4807 - Advance to next digit of score
	ld a,l			;4808 - Check if done
	cp 009h			;4809
	jr nz,l4810h		;480b - Jump forward if not

l480dh:	jp END_GAME		;480d - Move on, not a high score

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

	jp GET_NAME		;482e - Jump forward to read player
				;       initials

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
GET_NAME:
	call 04838h		;4850 - *** BUG: was call 04830h ***
	db 0x24, 0xC5		; Screen location for message
	dm "Well done! You got th"
	db 0xE5

	call 04838h		; - *** BUG: was call 04830h ***
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

END_GAME:
	call sub_4980h		;4900 - Print Game Over

	jp (iy)			;4903 - Return to Forth 
	
l4905h:	nop			;4905
	nop			;4906
	nop			;4907

	;; Increase score for centipede segment destroyed and, if
	;; necessary, adjust count of segments that have reached bottom
	;; of playing area
sub_4908h:
	call UPDATE_SCORE	;4908

l490bh:	bit 4,(ix+040h)		;490b - Check if segment had reached
	ret z			;490f   bottom of playing area and return
				;       if not
	ld hl,BOTTOM_ROW_CNT	;4910 - Decrement count of segments that
	dec (hl)		;4913   have reached bottom of playing
				;       area

	ret			;4914 - Done

	ds $4922-$		; Padding so follow-on word begins at
				; correct location in dictionary
	
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

	;; Play sound for flea, if is active
	;; 
	;; Accessed by Game routine #2
	;;
	;; 
l4940h:	push af			;4940

	;; Check if flea is active
	ld a,(FLEA_FLAG)	;4941
	and a			;4944

	;;  Proceed to next part of routine, if not
	jp z,l47d1h		;4945 - BUG: This doesn't look to be
				;useful, as the routine at 47d1h makes
				;the same check as here, before
				;proceeding to next part of Game Routine
				;#2.

	;; Retrieve row coordinate of flea and use it to determine tone
	;; of beeper sound to play
	ld a,(FLEA_COORD+1)	;4948 - Retrieve row number for flea
	add a,040h		;494b - A = -(A+40)
	neg			;494d

	ld (l4958h),a		;494f
	ld (l495ch),a		;4952

	call PLAY_BEEPER	;4955 - Play [flea] sound
l4958h: db $AA, $00, $08, $00
l495ch:	db $AA

	jp l47d1h		;495d - Proceeed to routine, which plays
				;       AY sound of flea
	nop			;4960
	nop			;4961
	nop			;4962
	nop			;4963
	nop			;4964
	nop			;4965
	nop			;4966
	nop			;4967

	;; Turn off sound and clear (all but top row of) screen
	;;
	;; On entry:
	;; 
	;; On exit:
	;;   HL - 0x23FF (immediately before start of display)
	;; 
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

	ld hl,DISPLAY-1		;497a

	ret			;497d
	
	nop			;497e
	nop			;497f

sub_4980h:
	call 04838h		; - *** BUG: was call 04830h ***
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

	;; Play dart-fire sound (internal speaker and AY)
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


	;; Play sound effect for mushroom being regenerated when game
	;; level is being reset
REGEN_BPR:	
	call sub_499dh		;49c5 - Dart-fired beeper
	call sub_499dh		;49c8 - Dart-fired beeper

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


	;; Continuation of Game Step Routine #2 
l4a00h:	push af			;4a00
	push hl			;4a01

	;; Check if flea is active
	ld a,(FLEA_FLAG)	;4a02
	and a			;4a05

	;; If no flea, play background game sound
	call z,BACKGROUND_SOUND	;4a06

	;; Set game timing by waiting for next frame
	ld hl,FRAMES		;4a09
	ld a,(hl)		;4a0c

l4a0dh:	cp (hl)			;4a0d
	jr z,l4a0dh		;4a0e

	;; Restore registers
	pop hl			;4a10
	pop af			;4a11

	;; Done
	ret			;4a12

BS_TIMER:	db 0x04			;4a13 - Timer for background sound
BS_BEEPER_TONE: db 0xA0			;4a14 - Tone for background sound
BS_AY_TONE:	ld (bc),a		;4a15
	nop			;4a16
	nop			;4a17

	;; ------------------------------------------------------------
	;; Play background sound (only called if no flea on screen)
	;;
	;; Sound effect played first via Beeper and then via AY sound
	;; card
	;;
	;; On entry:
	;;
	;; On exit:
	;;   A and HL corrupt
	;; ------------------------------------------------------------
BACKGROUND_SOUND:
	;; Check timer, which counts down from 0F to 00, playing a
	;; sound when counter reaches 00, or reducing the volume based
	;; on the value otherwise
	ld a,(BS_TIMER)		;4a18
	dec a			;4a1b
	ld (BS_TIMER),a		;4a1c

	jr nz,l4a50h		;4a1f

	;; Cycle tone to next value in sequence 0x0A, 0x0C, 0x0E, 0x0A,
	;; ...
	ld a,(BS_BEEPER_TONE)	;4a21
	add a,020h		;4a24
	cp 000h			;4a26
	jr nz,l4a2ch		;4a28
	ld a,0A0h		;4a2a - Reset counter
l4a2ch:	ld (BS_BEEPER_TONE),a	;4a2c

	;; Reset timer
	ld a,00fh		;4a2f
	ld (BS_TIMER),a		;4a31
	nop			;4a34
	nop			;4a35
	nop			;4a36
	nop			;4a37
	nop			;4a38
	nop			;4a39
	nop			;4a3a
	nop			;4a3b
	nop			;4a3c
	ld a,(BS_BEEPER_TONE)		;4a3d - Retrieve tone value
	ld (l4a49h),a		;4a40   and use to populate parameters 
	ld (l4a4dh),a		;4a43   for call to beeper below

	call PLAY_BEEPER	;4a46 - Play sound
l4a49h:	db $A0, $00, $08, $00	;4a49
l4a4dh:	db $A0			;4a4d

	nop			;4a4e
	nop			;4a4f

	;; Cycle through 4-step AY sound effect, with each tone value
	;; playing for 15 frames with a reducing volume from 15 to 1
l4a50h:	ld a,(BS_TIMER)		;4a50 - Retrieve timer and check if 
	cp 001h			;4a53   has reached 1
	jr nz,l4a88h		;4a55 - Skip forward to set volume for
				;       sound effect, if not

	;; Cycle AY tone parameter through 0, 1, 2, and 3
	ld a,(BS_AY_TONE)	;4a57
	inc a			;4a5a
	and 003h		;4a5b
	ld (BS_AY_TONE),a	;4a5d

	;; Set tone based on value of tone parameter
	ld hl,00a00h		;4a60 - Tone if A = 0
	and a			;4a63
	jr z,l4a75h		;4a64

	ld hl,00b00h		;4a66 - Tone if A = 1
	dec a			;4a69
	jr z,l4a75h		;4a6a

	ld hl,00a00h		;4a6c - Tone if A = 2
	dec a			;4a6f
	jr z,l4a75h		;4a70

	ld hl,00f00h		;4a72 - Tone if A = 3

	;; Write tone to AY chip
l4a75h:	ld a,AY_TONE_B		;4a75
	out (AY_REG_PORT),a	;4a77
	ld a,l			;4a79
	out (AY_DATA_WRITE_PORT),a	;4a7a
	ld a,AY_TONE_B+1	;4a7c
	out (AY_REG_PORT),a	;4a7e
	ld a,h			;4a80
	out (AY_DATA_WRITE_PORT),a	;4a81

	ret			;4a83 - Done

	nop			;4a84
	nop			;4a85
	nop			;4a86
	nop			;4a87

	;; Set volume of channel B based on timer
l4a88h:	ld a,AY_VOL_B		;4a88
	out (AY_REG_PORT),a	;4a8a
	ld a,(BS_TIMER)		;4a8c
	out (AY_DATA_WRITE_PORT),a	;4a8f
	
	ret			;4a91 - Done
	
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

l4af2h:	nop			;4af2
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

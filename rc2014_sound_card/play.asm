	;; Register mappings for AY-3-8910/ AY-3-8912 card
	IFDEF SWAPCHANS
AY_TONE_1:	EQU 0x04
AY_TONE_2:	EQU 0x00
AY_TONE_3:	EQU 0x02
	ELSE
AY_TONE_1:	EQU 0x00
AY_TONE_2:	EQU 0x02
AY_TONE_3:	EQU 0x04
	ENDIF	
AY_NOISE_FREQ:	EQU 0x06
AY_MIXER:	EQU 0x07
AY_VOL_1:	EQU 0x08
AY_ENV_P:	EQU 0x0B
AY_ENV_SH:	EQU 0x0D

AY_MAX_VOL:	EQU 0x0F
AY_MAX_CHANNEL:	EQU 0x03	; Three channels
DEF_TEMPO:	EQU 7920/120	; 120 beats per minute @ 3.5 MHz
DEF_ENV:	EQU 8000	; Default envelope period
DEF_ENV_SH:	EQU 0		; Default envelope shape
AY_WAIT_UNIT:	EQU 0x0042	; Unit of duration (calibrate to clock)

	;; Set origin to 0xC000 unless building for inclusion in
	;; dictionary. In which case, use address of holding word.
	org 0x3C5D		; Default = 0xC000 (or address of
				; parameter field of MCODE)
	
PLAY_INFO:
	dw CHANNEL_0_INFO	; Address of Channel 0 info
	dw CHANNEL_1_INFO	; Address of Channel 1 info
	dw CHANNEL_2_INFO	; Address of Channel 2 info

START:	di			; Disable interrupts (break-check incl.)
	ld (IY_SAVE),iy		; and save monitor copy of IY
	ld (SP_SAVE),sp		; Save SP to allow stack to be easily
				; balanced, in case of exit on error
	
	;; Initialise sound card
	call INIT_AY		

	;; Initialise each channel
	xor a			; Start with Channel 0
	
INIT:	push af			; Store channel number
	call INIT_CHANNEL	; Initialise channel
	pop af			; Retrieve channel number

	inc a			; Next channel
	cp AY_MAX_CHANNEL	; Check if done
	jr nz, INIT		; Loop, if not

	;; Iterative over each channel's Play string, until all are
	;; done
LOOP:
	call GET_CHAN_POINTER	; Set IY to point to channel info (100)
	
	;;  Check if channel is active
	bit 7,(IY + CH_N)	; Bit 7 set indicates inactive (20)
	jr z, CHANNEL_ACTIVE 	; (T=12/ 7)

	;; Add timing delay here for T=129-7-12=110 T states, to avoid
	;; noticable change in timing when a channel is not used/
	;; terminates before others
	ld b, 0x06		; (T=7)
NN_WAIT:
	nop 			; (T=4)
	djnz NN_WAIT		; (T=13 / 8)
	
	jr NEXT_CHAN		; (T=12)

	;; Check if note being played
CHANNEL_ACTIVE:
	ld e,(IY + CH_CNT)	; Retrieve countdown timer (T=19)
	ld d,(IY + CH_CNT+1)	; (T=19)
	
	ld a,d			; Check if zero (T=4)
	or e			; (T=4)

	jr nz, DEC_COUNT	; Jump forward, if not (T=12/ 7)

	;; Retrieve next note (and any preceeding commands)
	ld a,(CUR_CH)		; Retrieve channel number
	call MUTE_CHAN
	
	call NEXT_COMM		; Get next Play string value
	
	jr c, NEXT_CHAN	       	; Channel ended
	jr ACT_CHAN
	
DEC_COUNT:
	dec de			; Decrement counter and save (T=6)
	ld (IY + CH_CNT),e	; (T=19)
	ld (IY + CH_CNT+1),d	; (T=19)

ACT_CHAN:
	ld hl,ACT_CH		; Confirm channel active (T=10)
	inc (hl)		; (T=11)
	
NEXT_CHAN:
	ld a, (CUR_CH)		; (13)
	inc a			; (4)
	ld (CUR_CH),a		; (13)
	
	cp AY_MAX_CHANNEL	; (7)
	jr nz, LOOP		; (12/7)

	xor a			; Back to Channel 0
	ld (CUR_CH),a

	;;  Check if any active channels
	ld a, (ACT_CH)
	and a
	jr z, DONE

	;; Reset active channel count
	xor a
	ld (ACT_CH),a
	
	jr LOOP
	
NEXT_COMM:
	call GET_NEXT_NOTE	; Retrieve next note, if available
	jr nc, PROCESS_COMM	; Carry set, indicates end of channel

	;;  Close down channel and associated play string
	call CLOSE_CHANNEL
	
	set 7,(IY + CH_N)	; Set bit 7 to indicate channel inactive

	scf			; Done
	ret			
	
PROCESS_COMM:
	;; Check for number
	cp '0'			; Check if 1, ..., 9 (new note duration)
	jr c, NOT_NUM
	cp '9'+1
	jr nc, NOT_NUM

	;; First character is digit, so must be change of note duration.
	;; So back up one character and read whole number
	call PREV_NOTE
	call GET_NUM

	;; Check is in range, for note duration
	ld a,h
	and a			; High byte should be zero
	jp nz, ERR_NUM

	ld a,l			; Low byte should be in 1...9
	and a
	jp z, ERR_NUM
	cp 0x0a
	jp nc, ERR_NUM
	
	;; If number, update default note duration
	dec a			; Normalise on 1
	ld e,a			; Transfer to DE for look-up
	ld d,0
	ld hl, NOTE_DURATIONS
	add hl,de		; Address of duration value
	
	ld b,(HL)		; Loop counter
	
	ld de, (TEMPO)		; Basic unit of duration
	ld hl, 0x000		; Reset duration

ADD_TO_DUR:
	add hl,de
	djnz ADD_TO_DUR
	
	ld (IY+7),l		; Store new duration
	ld (IY+8),h
	
	jr NEXT_COMM		; Get next note
	
NOT_NUM:
	;; Get relevant command
	ld hl, PLAY_COMMANDS
	ld bc, 0x0009		; Eight possible commands
	cpir
	
	sla c			; Multiply C by two to get offset
	ld hl, PLAY_COMM_JUMPS
	add hl, bc		; Work out offset

	;; Retrieve routine address and move to HL
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de,hl

	;; Call routine
	call JUMP_TO_IT

	ret nc			; Return if new note set.
 	jr NEXT_COMM		; Otherwise process next command

DONE:	call SND_OFF

	ld iy, (IY_SAVE)	; Recover return address
	ei

	
	IFDEF ZXSPECTRUM
	ret			; Return to BASIC
	ELSE
	jp (iy)			; Return to FORTH
	ENDIF

	
NEW_NOTE:
	call NOTE_TO_FREQ

	ld b,(IY + CH_VOL)

	;; Check for rest
	ld a,h
	or l
	jr nz, NO_REST
	
	ld b, 0x00		; Mute channel

NO_REST:
	push bc			; Save volume
	;; Set tone
	ld a,(CUR_CH)
	sla a
	
	ld e,l
	ld d,a	
	call WRITE_TO_AY

	ld e,h
	inc d
	call WRITE_TO_AY

	;;  Set volume
	pop bc			; Restore volume
	ld a, (CUR_CH)
	add a, AY_VOL_1
	ld d,a
	ld e,b			; Volume / mute
	call WRITE_TO_AY
	
	;; If needed, reset envelope waveform
	bit 4,(IY + CH_VOL)
	jr z, RESET_COUNT

	ld a,(ENV_SHAPE)
	ld e,a
	ld d, AY_ENV_SH
	call WRITE_TO_AY

RESET_COUNT:
	ld e,(IY+7)		; Reset duration counter
	ld d,(IY+8)
	ld (IY+9),e
	ld (IY+10),d

	and a			; Clear carry
	ret

CHANGE_VOL:
	call GET_NUM
	;; Check is valid volume (0...15)
	ld a,h
	and a
	jp nz, ERR_NUM
	ld a,l
	cp 0x10
	jp nc, ERR_NUM
	
	ld a, (CUR_CH)		; Retrieve current channel number
	add a, AY_VOL_1		; Work out corresponding sound card register

	ld d,a
	ld e,l
	call WRITE_TO_AY

	;; Save in channel info
	ld (iy + CH_VOL),l
	
	scf			; Indicates need to read another command
	ret

CHANGE_TEMPO:
	call GET_NUM		; Retrieve new tempo (crochets/ min)

	;; Check is Channel 0, otherwise ignore command
	ld a,(CUR_CH)
	and a
	jr z, CHANGE_T
	
	scf			; Indicate need to process another note
	ret

	;; Work out new tempo
CHANGE_T:
	ex de, hl		; Put divisor into DE
	ld a, 0x1e		; Put 7,920d into AC
	ld c, 0xf0
	call DIV16		; Divide AC by DE, answer in AC
	ld b,a			; Move answer into BC
	ld hl, TEMPO		; Store new tempo
	ld (hl),c
	inc hl
	ld (hl),b

	scf			; Need to process another note
	ret			; Done

CHANGE_MIXER:
	call GET_NUM		; Retrieve parameter
	
	ld a,h			; Check high byte is zero
	and a
	jp nz, ERR_NUM

	ld a,l
	cp 0x40			; Check is <64
	jp nc, ERR_NUM

	cpl			; Bit reset to activate feature

	ld d,AY_MIXER
	ld e,a
	call WRITE_TO_AY

	scf			; Indicates need to read 
				; another command
	
	ret
	
DUMMY_NOTE:
	scf
	ret
	
CHANGE_OCTAVE:
	call GET_NUM		; Retrieve desired octave number

	;; Check is in range (1...10)
	ld a,l
	cp 0x0B	    ; Octave 10 is highest
	jp nc, ERR_NUM
	and a	    ; Octave 1 is lowest
	jp z, ERR_NUM

	;; Multiply by 12 to work out offset in semi-tones
	xor a
	ld b, 0x0C		; Twelve semi-tones in an octave
CO_LOOP:
	add l
	djnz CO_LOOP

	;; Save new octave info
	ld (iy + CH_OCT), a
	
	scf
	ret
	
ACTIVATE_ENVELOPE:
	ld a,(IY + CH_VOL)	; Retrieve current volume
	or 0x1F			; Set bit 4 to activate envelope
	ld (IY + CH_VOL),a	; Store

	ld e,a
	ld a,(CUR_CH)
	add a,AY_VOL_1
	ld d,a
	call WRITE_TO_AY

	ld hl, ENVELOPE
	ld c,(hl)
	inc hl
	ld b,(hl)
	ld d, AY_ENV_P
	ld e,c
	push bc
	call WRITE_TO_AY
	pop bc
	inc d
	ld e,b
	call WRITE_TO_AY

	ld a,(ENV_SHAPE)
	ld e,a
	ld d, AY_ENV_SH
	call WRITE_TO_AY

	scf			; Indicate need for another command
	ret

CHANGE_WAVEFORM:
	call GET_NUM
	;; Check is valid waveform (0...7)
	ld a,h
	and a
	jp nz, ERR_NUM
	ld a,l
	cp 0x08
	jp nc, ERR_NUM

	ld b,0
	ld c,a
	ld hl, WAVEFORM_TABLE
	add hl,bc
	ld a,(hl)

	ld (ENV_SHAPE),a  	; Update waveform
	ld e,a			; Retrieve current channel number
	ld d,AY_ENV_SH		; Work out corresponding sound card register
	call WRITE_TO_AY

	scf
	ret

WAVEFORM_TABLE:
	db 0x00, 0x04, 0x0b, 0x0d, 0x08, 0x0c, 0x0e, 0x0a

SET_ENV_P:
	call GET_NUM		; Retrieve the new period length

	ex de,hl
	ld hl, ENVELOPE
	ld (hl),e
	inc hl
	ld (hl),d

	ex de,hl

	ld d,AY_ENV_P
	ld e,l
	call WRITE_TO_AY
	
	inc d
	ld e,h
	call WRITE_TO_AY

	scf
	ret
	
PLAY_COMMANDS:
	dm "OVNTMUWX"		; List of recognised Play commands

PLAY_COMM_JUMPS:
	dw NEW_NOTE		; Process note
	dw SET_ENV_P
	dw CHANGE_WAVEFORM
	dw ACTIVATE_ENVELOPE	
	dw CHANGE_MIXER
	dw CHANGE_TEMPO
	dw DUMMY_NOTE		; 'N' - Separator to avoid ambiguity
	dw CHANGE_VOL		; 'V' - New volume
	dw CHANGE_OCTAVE	; 'O' - New octave

	;;  Allows CALL (HL)
JUMP_TO_IT:
	jp (hl)
	
	;; Read next character from play string and update play
	;; string pointer.
	;;
	;; On entry:
	;;   IY = addr of start of channel info
	;;
	;; On exit:
	;;   Carry reset, A = character read (success)
	;;   Carry set, A corrupted (end of string)
	;;   HL corrupted (always)
GET_NEXT_NOTE:
	ld l, (iy + 3)		; Retrieve current location
	ld h, (iy + 4)
	
	;; Check if end of string
	ld a, l
	cp (iy + 5)
	jr nz, NN_CONT

	ld a, h
	cp (iy + 6)
	jr z, NN_END_OF_STR

	;; Retrieve character
NN_CONT:
	ld a, (hl)


	;;  Update current location
	inc (iy + 3)		; Increment low byte
	jr nz, NN_DONE		; Return, if overflow

	inc (iy + 4)		; Increment high byte

NN_DONE:
	and a			; Reset carry
	ret

NN_END_OF_STR:
	scf
	ret

	
NOTE_TO_FREQ:
	;; Translate current note token into sound-card tone value
	;; On entry:
	;;   A = current character in Play string
	;;
	;; On exit:
	;;   Carry Flag cleared, if valid note
	;;   HL = frequency value for sound chip (or 0x0000 for rest)
	;; or:
	;;   Carry Flag set, invalid note
	ld c, 0x00		; Start from lower 'c' in current octave

CHECK_SHARP:	
	cp '#'			; Check for Sharp
	jr nz, CHECK_FLAT

	inc c
	call GET_NEXT_NOTE
	jr CHECK_SHARP

CHECK_FLAT:
	cp '$'
	jr nz, CHECK_REST

	dec c
	call GET_NEXT_NOTE
	jr CHECK_SHARP

CHECK_REST:
	cp '&'
	jr nz, CHECK_NOTE

	ld hl, 0x0000
	ret
	
CHECK_NOTE:
	bit 5,a	; Is note lower case?
	jr nz, LOWER_CASE

        push af           ; Increase step by
        ld   a,$0C        ; an octave
        add  c	          ; (add 12 semitones)
        ld   c,a          ;
        pop  af           ;

LOWER_CASE:
	and 0xDF	; Convert note to upper case
	sub 'A'		; Normalise value
	jp c, ERR_NOTE	; Error, if below 'A'
	cp 0x07
	jp nc, ERR_NOTE		; Error, if above 'G'
	
	ld hl, SEMITONES	; Start of lookup table

	ld e,a
	ld d,0
	add hl, de		; Update reference

	ld a,(hl)
	add a,c			; Add modifier

	;; Now adjust octave
	add (IY + CH_OCT)	; Add octave offset
	sub 0x15	; Remove 21 semitones, as Octave 1
			; contains only three notes
	jr nc, COMP_OFFSET
	ld hl, 0x0fbf		; Notes below 21 cannot be played
				; accurately, so default to O1, A
	ret

COMP_OFFSET:
	cp 0x6c		       	; Check is in range
	jp nc, ERR_NOTE
	
	sla a			; Multiply by two to get address offset

	ld HL, NOTES
	ld e,a
	ld d,0
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)

	ex de,hl		; Put result in HL

	and a			; Reset carry
	
	ret

SEMITONES:
	db $09          ; 'A'
        db $0B          ; 'B'
        db $00          ; 'C'
        db $02          ; 'D'
        db $04          ; 'E'
        db $05          ; 'F'
        db $07          ; 'G'

	;; Update channel pointer to point to previous note.
	;; Sometimes needed, if overshot. No check is made for
	;; underflow
PREV_NOTE:
	ld a,(iy + 0x03)	; Save old value

	dec (iy + 0x03)		; Decrement low byte

	and a			; Check if was zero

	ret nz			; Return if not

	dec (iy + 0x04)		; Decrement high byte, also

	ret

	;; Read ASCII-encoded number from play string
GET_NUM:
	ld hl, 0x0000		; Place-holder for number
	ld d, 0 		; Holds number of digits read

GN_NEXT:
	push hl
	call GET_NEXT_NOTE
	pop hl
	
	jr c, GN_DONE_2		; Carry set means end of string

	;; Check for number
	cp '0'			
	jr c, GN_DONE

	cp '9'+1
	jr nc, GN_DONE

	;; Found a digit
	sub '0'		; Remove ASCII encoding
	
	call MULT_BY_10		; Multiply number-so-far by 10
	
	ld c,a			; Add to running total
	ld b,0
	add hl, bc		; No error checking
	inc d			; Increase digit count

	jr GN_NEXT
GN_DONE:
	call PREV_NOTE		; Rewind, as overshot
GN_DONE_2:	
	ld a,d			; Check if any digits read
	
	and a
	ret nz			; At least one digit read
	
	scf
	ret

MULT_BY_10:
	ld d,h			; Copy number to DE
	ld e,l
	ld b,0x09		; Add nine copies
	
MU_LOOP:	
	add hl,de
	ret c			; Return if overflow

	djnz MU_LOOP

	ret			; Done
	

	;; Initialise sound card and driver variables.
	;; Turn off any active sounds, 
INIT_AY:
	call SND_OFF

	xor a			; Start with channel 0
	ld (CUR_CH),a		; Store for later

	xor a			; Reset active channel count
	ld (ACT_CH),a

	;; Reset tempo to default
	ld de,DEF_TEMPO
	ld hl,TEMPO
	ld (hl),e
	inc hl
	ld (hl),d

	;; Reset envelope period to default
	ld bc, DEF_ENV		; Reset envelope pattern
	ld hl, ENVELOPE
	ld (hl),c
	inc hl
	ld (hl),b

	ld d, AY_ENV_P
	ld e,c
	push bc
	call WRITE_TO_AY
	pop bc
	inc d
	ld e,b
	call WRITE_TO_AY

	ld a, DEF_ENV_SH
	ld (ENV_SHAPE),a
	ld e,a
	ld d, AY_ENV_SH
	call WRITE_TO_AY
	
	ret

	;; -------------------------------------------------------------
	;; Calculate address of channel's information and store in IY.
	;;
	;; On entry:
	;;   -
	;;
	;; On exit:
	;;   A - current channel number
	;;   IY - address
	;;   BC, HL are corrupted
	;; -------------------------------------------------------------
GET_CHAN_POINTER:
	;; Compute address of channel pointer
	ld a,(CUR_CH)		; Retrieve channel number (13)
	ld hl, PLAY_INFO	; Start of play info (10)
	ld c,a			; Move channel number to C (4)
	sla c			; Multiply C by two to get offset (8)
	ld b,0			; (7)
	add hl, bc		; Pointer stored at PLAY_INFO + 2*CHAN (11)
	
	ld c, (hl)		; Retrieve channel pointer (7)
	inc hl			; (6)
	ld b, (hl)		; (7)

	push bc			; Transfer to IY (11)
	pop iy 			; (10)

	ret			; (10)

	;; -------------------------------------------------------------
	;; Close channel, disable sound and noise of mixer.
	;;
	;; On entry:
	;;   A = channel number to close
	;;
	;; On exit:
	;;   Current registers corrupted
	;; -------------------------------------------------------------
CLOSE_CHANNEL:
	ld b,a			; Move current channel to B
	inc b
	ld a, %10000000		; Mixer mask

CL_ROT:	rlca			; Rotate activation bit to
	djnz CL_ROT		; correct channel

	ld hl, MIX_MA		; Apply mask
	or (hl)

	ld (hl),a		; Update record of mask

	ld d,AY_MIXER		; Update sound card
	ld e,a			; with new mask
	call WRITE_TO_AY

	ret

	;; -------------------------------------------------------------
	;; Initialise sound card channel: set IY to point to channel
	;; info; set mixer to play sound on channel; set volume to
	;; default; set note duration to crochet; set current-pointer to
	;; start of play string; and set current counter to zero.
	;;
	;; On entry:
	;;   A = channel number to initialise
	;;
	;; On exit:
	;;   IY = address of channel info
	;;   current registers are corrupted
	;; -------------------------------------------------------------
INIT_CHANNEL:
	push af			; Save channel number

	;; Calculate pointer to channel information
	ld hl, PLAY_INFO	; Start of play info
	sla a			; Multiply A by two to get offset
	ld c,a			; Compute address of channel pointer
	ld b,0
	add hl, bc
	
	ld c, (hl)		; Retrieve channel pointer
	inc hl
	ld b, (hl)

	push bc			; Transfer to IY
	pop iy

	;; Set channel as active 
	pop af			; Recover channel number
	push af			; and save again

	ld (iy + CH_N),a	; N.B. Bit 7 is reset,
				; indicating channel is active
	
	ld b,a			; Move to B
	inc b			; Need to complete CH_N+1 rotations to
				; get channel mask
	ld a, %01111111		; Mixer mask

IC_ROT:	rlca			; Rotate activation bit to
	djnz IC_ROT		; correct channel

	ld hl, MIX_MA		; Apply mask
	and (hl)
	ld (hl),a		; Update record of mask

	ld d, AY_MIXER		; Also, update sound card
	ld e,a			; with new mask
	call WRITE_TO_AY

	pop af			; Recover channel number
	add AY_VOL_1 		; Find volume register for channel
	
	ld d,a 			; Set initial volume
	ld e, AY_MAX_VOL	; Maximum volume
	call WRITE_TO_AY
	ld (IY + CH_VOL), e	; Also store in channel info

	ld a, 5*0x0c	   	; Set default octave to O5
	ld (IY + CH_OCT), a
	
	;; Set current posn to start of play string
	ld a,(iy + CH_STA)		
	ld (iy + CH_CUR),a		
	ld a,(iy + CH_STA + 1)
	ld (iy + CH_CUR + 1),a

	;; Set (duration) counter to zero -- i.e., no note playing
	ld (iy+CH_CNT), 0x00
	ld (iy+CH_CNT+1), 0x00

	;; Set default note to a crochet
	ld de, AY_WAIT_UNIT	; Basic unit of duration
	ld hl, 0x000		; Reset duration
	ld b, 0x18
CH_ADD_TO:
	add hl,de
	djnz CH_ADD_TO

	;; Store note duration
	ld (iy + CH_DUR),l
	ld (iy + CH_DUR+1),h
	
	ret			; Done

	;; Mute sound/ noise on all channels
SND_OFF:
	ld a, %11111111		; Mixer mask (all off)
	ld hl, MIX_MA
	ld (hl),a		; Store mixer mask 
	
	ld d, AY_MIXER		; and write to sound card
	ld e, a
	call WRITE_TO_AY

	ld d, AY_VOL_1
	ld e, 0x00
	call WRITE_TO_AY

	inc d
	ld e, 0x00
	call WRITE_TO_AY

	inc d
	ld e, 0x00
	call WRITE_TO_AY

	ret			

	;; Set volume of channel to 0.
	;; On entry:
	;;   A - channel to mute
	;;
	;; On exit:
	;;   BC, DE - corrupted
MUTE_CHAN:
	add AY_VOL_1

	ld d,a
	ld e,0
	call WRITE_TO_AY
	ret

	;; Write data in E to sound-card register D
	;; On entry:
	;;   D - sound-card register to write to
	;;   E - value to write
	;;
	;; On exit:
	;;   AF, BC - corrupted
WRITE_TO_AY:
	ld a, d			; Retrieve register
	ld bc, AY_REG_PORT	; and address of register port
	out (c),a		; Write it

	ld a,e			; Retrieve data
	ld bc, AY_WRITE_PORT	; and address of data port
	out (c),a		; Write it

	ret

	;; Read data from sound-card register D
	;; On entry:
	;;   D - sound-card register to read from
	;;
	;; On exit:
	;;   E - value read
	;;   AF, BC - corrupted
READ_FROM_AY:
	ld a, d			; Retrieve register
	ld bc, AY_REG_PORT	; and address of register port
	out (c),a		; Write it

	ld bc, AY_READ_PORT	; Select port for reading value
	in e,(c)		; Retrieve value

	ret
	
	;; Divide 16-bit number in AC by 16-bin number in DE. 
DIV16:	ld hl, 0x0000
	ld b, 0x10
LOOP16:	rl c
	rla
	adc hl,hl
	sbc hl,de
	jr nc, SKIP16
	add hl, de
SKIP16:	ccf
	djnz LOOP16
	rl c
	rla
	ret
	

IY_SAVE:	dw 0x0000
SP_SAVE:	dw 0x0000
NOTE_DURATIONS:
        db $06          ; Semi-quaver          (sixteenth note).
        db $09          ; Dotted semi-quaver   (3/32th note).
        db $0C          ; Quaver               (eighth note).
        db $12          ; Dotted quaver        (3/16th note).
        db $18          ; Crotchet             (quarter note).
        db $24          ; Dotted crotchet      (3/8th note).
        db $30          ; Minim                (half note).
        db $48          ; Dotted minim         (3/4th note).
        db $60          ; Semi-breve           (whole note).
        db $04          ; Triplet semi-quaver  (1/24th note).
        db $08          ; Triplet quaver       (1/12th note).
        db $10          ; Triplet crochet      (1/6th note).

	;; -----------------
	;; Note Lookup Table
	;; -----------------
	;; Each word gives the value of the sound generator tone
	;; registers for a given note.  There are 9 octaves, containing a
	;; total of 108 notes. These represent notes 21 to 128. Notes 0
	;; to 20 cannot be reproduced on the sound chip and so note 21
	;; will be used for all of these (they will however be sent to a
	;; MIDI device if one is assigned to a channel). [Note that both
	;; the sound chip and the MIDI port can not play note 128 and so
	;; its inclusion in the table is a waste of 2 bytes]. The PLAY
	;; command does not allow octaves higher than 8 to be selected
	;; directly. Using PLAY "O8G" will select note 115. To select
	;; higher notes, sharps must be included, e.g. PLAY "O8#G" for
	;; note 116, PLAY "O8##G" for note 117, etc, up to PLAY
	;; "O8############G" for note 127. Attempting to access note 128
	;; using PLAY "O8#############G" will lead to error report "m
	;; Note out of range".
NOTES:
	IFDEF ZXSPECTRUM
	INCLUDE "spectrum_note_table.asm"	
	ELSE
	INCLUDE "minstrel_note_table.asm"
	ENDIF	

	;; Abort routines for different errors
ERR_NUM:
	call SND_OFF
	ld sp,(SP_SAVE)
	ld iy,(IY_SAVE)
	IFDEF ZXSPECTRUM
	rst 0x08
	db #0a			; Number out of range
	ELSE
	rst 0x20
	db #08			; Overflow in floating-point
	ENDIF
ERR_NOTE:
	call SND_OFF
	ld sp,(SP_SAVE)
	ld iy,(IY_SAVE)
	IFDEF ZXSPECTRUM
	rst 0x08
	db #26			; Invalid note name
	ELSE
	rst 0x20
	db #0c			; Word not defined
	ENDIF

PLAY_CHAN:	EQU 0x00
PLAY_START:	EQU 0x01
PLAY_CURR:	EQU 0x03
PLAY_END:	EQU 0x05
PLAY_DUR:	EQU 0x07
PLAY_COUNT:	EQU 0x09
PLAY_OCTAVE:	EQU 0x0B
PLAY_VOL:	EQU 0x0C

MIX_MA:	db 0xFF			; Mixer mask
CUR_CH:	db 0x00			; Current channel
ACT_CH:	db 0x00			; Number of active channels
TEMPO:	dw DEF_TEMPO		; Initial
ENVELOPE:	dw 8000		; Envelope period
ENV_SHAPE:	db 0x00		; Envelope shape
	
CH_N:	EQU 00
CH_STA:	EQU 01
CH_CUR:	EQU 03
CH_END:	EQU 05
CH_DUR:	EQU 07
CH_CNT:	EQU 09
CH_OCT:	EQU 11
CH_VOL:	EQU 12

CHANNEL_0_INFO:
	db 0x00			; Channel number
	dw MK1			; Start of Play string
	dw 0x0000		; Current location in Play string
	dw MK1E			; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x30			; Octave 5 by default
	db 0x0F			; Volume

CHANNEL_1_INFO:
	db 0x01			; Channel number
	dw MK2			; Start of Play string
	dw 0x0000		; Current location in Play string
	dw MK2E			; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x30			; Octave 5 by default
	db 0x0F			; Volume

CHANNEL_2_INFO:
	db 0x01			; Channel number
	dw MK3			; Start of Play string
	dw 0x0000		; Current location in Play string
	dw MK3E			; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x30			; Octave 5 by default
	db 0x0F			; Volume

	;; Demo tune "Hall Of the Mountain King", E. Grieg
MK1:	dm "O5T120N3e#fgabg5bN3#a#f5#a3af5aN3e#fgabgbENDbgb7D"
MK1E:
MK2:	dm "O5V6N3b#C#DE#F#D5#FN3G#D5G3#F#D5#FN3b#C#DE#F#D5#FN3G#D5G7#F"
MK2E:
MK3:	dm "O5V6N3Dbgb7DN5&E7&N5&E7&N3e#fgabgbE"
MK3E:	

END:	

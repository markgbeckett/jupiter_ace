	IFDEF ZXSPECTRUM
AY_REG_PORT: EQU 0xFFFD		; Port addresses used on Spectrum 128k
AY_DAT_PORT: EQU 0xBFFD		; models
	ELSE
AY_REG_PORT: EQU 216		; Default port settings for RC2014 
AY_DAT_PORT: EQU 208		; sound card
	ENDIF

	;; Register mappings for AY-3-8910/ AY-3-8912 card
AY_TONE_1:	EQU 0x00
AY_TONE_2:	EQU 0x02
AY_TONE_3:	EQU 0x04
AY_NOISE_FREQ:	EQU 0x06
AY_MIXER:	EQU 0x07
AY_VOL_1:	EQU 0x08
AY_VOL_2:	EQU 0x08
AY_VOL_3:	EQU 0x08

AY_MAX_VOL:	EQU 0x0F
AY_MAX_CHANNEL:	EQU 0x03	; Three channels
AY_WAIT_UNIT:	EQU 0x0042	; Basic unit of duration
	
	org 0xC000
	
PLAY_INFO:
	dw CHANNEL_0_INFO	; Address of Channel 0 info
	dw CHANNEL_1_INFO	; Address of Channel 1 info
	dw CHANNEL_2_INFO	; Address of Channel 2 info

START:	di			; Disable interrupts (break-check incl.)
	ld (IY_SAVE),iy		; and save monitor copy of IY

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
	call GET_CHAN_POINTER	; Set IY to point to channel info
	
	;;  Check if channel is active
	ld a,(IY + CH_N)	; Retrieve channel number
	and 0x80		; Bit 7 set indicates inactive
	jr z, CHANNEL_ACTIVE 	; (T=12/ 7)

	;; Add timing delay here for T=129-7-12=110 T states
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

	jr nz, DEC_COUNT	; Jump forward, if not (T=12)

	;; Retrieve next note (and any preceeding commands)
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
	ld a, (CUR_CH)
	inc a
	ld (CUR_CH),a
	
	cp AY_MAX_CHANNEL
	jr nz, LOOP

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
	ld a,(CUR_CH)		; Retrieve channel number
	call CLOSE_CHANNEL
	
	set 7,(IY + CH_N)	; Set bit 7 to indicate channel inactive

	scf			; Done
	ret			
	
PROCESS_COMM:
	cp '1'			; Check if 1, ..., 9 (new note duration)
	jr c, NOT_NUM
	cp '9'+1
	jr nc, NOT_NUM

	;; If number, update default note duration
	sub '1'			; Normalise number
	ld e,a			; Transfer to DE for look-up
	ld d,0
	ld hl, NOTE_DURATIONS
	add hl,de		; Address of duration value
	
	ld b,(HL)		; Loop counter
	
	ld de, AY_WAIT_UNIT	; Basic unit of duration
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
	ld bc, 0x0004
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

	ret nc			; Return if new note set
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
	
RESET_COUNT:
	ld e,(IY+7)		; Reset duration counter
	ld d,(IY+8)
	ld (IY+9),e
	ld (IY+10),d

	and a			; Clear carry
	ret

CHANGE_VOL:
	call GET_NUM
	ld a, (CUR_CH)		; Retrieve current channel number
	add a, AY_VOL_1		; Work out corresponding sound card register

	ld d,a
	ld e,l
	call WRITE_TO_AY

	;; Save in channel info
	ld (iy + CH_VOL),l	; Move volume to A
	
	scf			; Indicates need to read another command
	ret

DUMMY_NOTE:
	scf
	ret
	
CHANGE_OCTAVE:
	call GET_NUM		; Retrieve desired octave number
	
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
	
PLAY_COMMANDS:
	dm "OVN"			; List of recognised Play commands

PLAY_COMM_JUMPS:
	dw NEW_NOTE		; Process note
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
	
	ld hl, SEMITONES	; Start of lookup table

	ld e,a
	ld d,0
	add hl, de		; Update reference

	ld a,(hl)
	add a,c			; Add modifier

	;; Now adjust octave
	add (IY + 11)	; Add octave offset
	sub 0x15	; Remove 21 semitones, as Octave 1
			; contains only three notes
	sla a		; Multiply by two to get address offset

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
	

INIT_AY:
	call SND_OFF

	xor a			; Start with channel 0
	ld (CUR_CH),a		; Store for later

	xor a			; Reset active channel count
	ld (ACT_CH),a

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
	ld a,(CUR_CH)		; Retrieve channel number
	ld hl, PLAY_INFO	; Start of play info
	ld c,a			; Move channel number to C
	sla c			; Multiply C by two to get offset
	ld b,0
	add hl, bc		; Pointer stored at PLAY_INFO + 2*CHAN
	
	ld c, (hl)		; Retrieve channel pointer
	inc hl
	ld b, (hl)

	push bc			; Transfer to IY
	pop iy

	ret

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

	;; Write data in E to sound-card register D
WRITE_TO_AY:
	ld a, d			; Retrieve register
	ld bc, AY_REG_PORT	; and address of register port
	out (c),a		; Write it

	ld a,e			; Retrieve data
	ld bc, AY_DAT_PORT	; and address of data port
	out (c),a		; Write it

	ret

IY_SAVE:	dw 0x0000

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
	dw $0FBF        ; Octave  1, Note  21 - A  (27.50 Hz, Ideal=27.50 Hz, Error=-0.01%) C0
        dw $0EDC        ; Octave  1, Note  22 - A# (29.14 Hz, Ideal=29.16 Hz, Error=-0.08%)
        dw $0E07        ; Octave  1, Note  23 - B  (30.87 Hz, Ideal=30.87 Hz, Error=-0.00%)

        dw $0D3D        ; Octave  2, Note  24 - C  (32.71 Hz, Ideal=32.70 Hz, Error=+0.01%) C1
        dw $0C7F        ; Octave  2, Note  25 - C# (34.65 Hz, Ideal=34.65 Hz, Error=-0.00%)
        dw $0BCC        ; Octave  2, Note  26 - D  (36.70 Hz, Ideal=36.71 Hz, Error=-0.01%)
        dw $0B22        ; Octave  2, Note  27 - D# (38.89 Hz, Ideal=38.89 Hz, Error=+0.01%)
        dw $0A82        ; Octave  2, Note  28 - E  (41.20 Hz, Ideal=41.20 Hz, Error=+0.00%)
        dw $09EB        ; Octave  2, Note  29 - F  (43.66 Hz, Ideal=43.65 Hz, Error=+0.00%)
        dw $095D        ; Octave  2, Note  30 - F# (46.24 Hz, Ideal=46.25 Hz, Error=-0.02%)
        dw $08D6        ; Octave  2, Note  31 - G  (49.00 Hz, Ideal=49.00 Hz, Error=+0.00%)
        dw $0857        ; Octave  2, Note  32 - G# (51.92 Hz, Ideal=51.91 Hz, Error=+0.01%)
        dw $07DF        ; Octave  2, Note  33 - A  (55.01 Hz, Ideal=55.00 Hz, Error=+0.01%)
        dw $076E        ; Octave  2, Note  34 - A# (58.28 Hz, Ideal=58.33 Hz, Error=-0.08%)
        dw $0703        ; Octave  2, Note  35 - B  (61.75 Hz, Ideal=61.74 Hz, Error=+0.02%)

        dw $069F        ; Octave  3, Note  36 - C  ( 65.39 Hz, Ideal= 65.41 Hz, Error=-0.02%) C2
        dw $0640        ; Octave  3, Note  37 - C# ( 69.28 Hz, Ideal= 69.30 Hz, Error=-0.04%)
        dw $05E6        ; Octave  3, Note  38 - D  ( 73.40 Hz, Ideal= 73.42 Hz, Error=-0.01%)
        dw $0591        ; Octave  3, Note  39 - D# ( 77.78 Hz, Ideal= 77.78 Hz, Error=+0.01%)
        dw $0541        ; Octave  3, Note  40 - E  ( 82.41 Hz, Ideal= 82.41 Hz, Error=+0.00%)
        dw $04F6        ; Octave  3, Note  41 - F  ( 87.28 Hz, Ideal= 87.31 Hz, Error=-0.04%)
        dw $04AE        ; Octave  3, Note  42 - F# ( 92.52 Hz, Ideal= 92.50 Hz, Error=+0.02%)
        dw $046B        ; Octave  3, Note  43 - G  ( 98.00 Hz, Ideal= 98.00 Hz, Error=+0.00%)
        dw $042C        ; Octave  3, Note  44 - G# (103.78 Hz, Ideal=103.83 Hz, Error=-0.04%)
        dw $03F0        ; Octave  3, Note  45 - A  (109.96 Hz, Ideal=110.00 Hz, Error=-0.04%)
        dw $03B7        ; Octave  3, Note  46 - A# (116.55 Hz, Ideal=116.65 Hz, Error=-0.08%)
        dw $0382        ; Octave  3, Note  47 - B  (123.43 Hz, Ideal=123.47 Hz, Error=-0.03%)

        dw $034F        ; Octave  4, Note  48 - C  (130.86 Hz, Ideal=130.82 Hz, Error=+0.04%) C3
        dw $0320        ; Octave  4, Note  49 - C# (138.55 Hz, Ideal=138.60 Hz, Error=-0.04%)
        dw $02F3        ; Octave  4, Note  50 - D  (146.81 Hz, Ideal=146.83 Hz, Error=-0.01%)
        dw $02C8        ; Octave  4, Note  51 - D# (155.68 Hz, Ideal=155.55 Hz, Error=+0.08%)
        dw $02A1        ; Octave  4, Note  52 - E  (164.70 Hz, Ideal=164.82 Hz, Error=-0.07%)
        dw $027B        ; Octave  4, Note  53 - F  (174.55 Hz, Ideal=174.62 Hz, Error=-0.04%)
        dw $0257        ; Octave  4, Note  54 - F# (185.04 Hz, Ideal=185.00 Hz, Error=+0.02%)
        dw $0236        ; Octave  4, Note  55 - G  (195.83 Hz, Ideal=196.00 Hz, Error=-0.09%)
        dw $0216        ; Octave  4, Note  56 - G# (207.57 Hz, Ideal=207.65 Hz, Error=-0.04%)
        dw $01F8        ; Octave  4, Note  57 - A  (219.92 Hz, Ideal=220.00 Hz, Error=-0.04%)
        dw $01DC        ; Octave  4, Note  58 - A# (232.86 Hz, Ideal=233.30 Hz, Error=-0.19%)
        dw $01C1        ; Octave  4, Note  59 - B  (246.86 Hz, Ideal=246.94 Hz, Error=-0.03%)

        dw $01A8        ; Octave  5, Note  60 - C  (261.42 Hz, Ideal=261.63 Hz, Error=-0.08%) C4 Middle C
        dw $0190        ; Octave  5, Note  61 - C# (277.10 Hz, Ideal=277.20 Hz, Error=-0.04%)
        dw $0179        ; Octave  5, Note  62 - D  (294.01 Hz, Ideal=293.66 Hz, Error=+0.12%)
        dw $0164        ; Octave  5, Note  63 - D# (311.35 Hz, Ideal=311.10 Hz, Error=+0.08%)
        dw $0150        ; Octave  5, Note  64 - E  (329.88 Hz, Ideal=329.63 Hz, Error=+0.08%)
        dw $013D        ; Octave  5, Note  65 - F  (349.65 Hz, Ideal=349.23 Hz, Error=+0.12%)
        dw $012C        ; Octave  5, Note  66 - F# (369.47 Hz, Ideal=370.00 Hz, Error=-0.14%)
        dw $011B        ; Octave  5, Note  67 - G  (391.66 Hz, Ideal=392.00 Hz, Error=-0.09%)
        dw $010B        ; Octave  5, Note  68 - G# (415.13 Hz, Ideal=415.30 Hz, Error=-0.04%)
        dw $00FC        ; Octave  5, Note  69 - A  (439.84 Hz, Ideal=440.00 Hz, Error=-0.04%)
        dw $00EE        ; Octave  5, Note  70 - A# (465.72 Hz, Ideal=466.60 Hz, Error=-0.19%)
        dw $00E0        ; Octave  5, Note  71 - B  (494.82 Hz, Ideal=493.88 Hz, Error=+0.19%)

        dw $00D4        ; Octave  6, Note  72 - C  (522.83 Hz, Ideal=523.26 Hz, Error=-0.08%) C5
        dw $00C8        ; Octave  6, Note  73 - C# (554.20 Hz, Ideal=554.40 Hz, Error=-0.04%)
        dw $00BD        ; Octave  6, Note  74 - D  (586.46 Hz, Ideal=587.32 Hz, Error=-0.15%)
        dw $00B2        ; Octave  6, Note  75 - D# (622.70 Hz, Ideal=622.20 Hz, Error=+0.08%)
        dw $00A8        ; Octave  6, Note  76 - E  (659.77 Hz, Ideal=659.26 Hz, Error=+0.08%)
        dw $009F        ; Octave  6, Note  77 - F  (697.11 Hz, Ideal=698.46 Hz, Error=-0.19%)
        dw $0096        ; Octave  6, Note  78 - F# (738.94 Hz, Ideal=740.00 Hz, Error=-0.14%)
        dw $008D        ; Octave  6, Note  79 - G  (786.10 Hz, Ideal=784.00 Hz, Error=+0.27%)
        dw $0085        ; Octave  6, Note  80 - G# (833.39 Hz, Ideal=830.60 Hz, Error=+0.34%)
        dw $007E        ; Octave  6, Note  81 - A  (879.69 Hz, Ideal=880.00 Hz, Error=-0.04%)
        dw $0077        ; Octave  6, Note  82 - A# (931.43 Hz, Ideal=933.20 Hz, Error=-0.19%)
        dw $0070        ; Octave  6, Note  83 - B  (989.65 Hz, Ideal=987.76 Hz, Error=+0.19%)

        dw $006A        ; Octave  7, Note  84 - C  (1045.67 Hz, Ideal=1046.52 Hz, Error=-0.08%) C6
        dw $0064        ; Octave  7, Note  85 - C# (1108.41 Hz, Ideal=1108.80 Hz, Error=-0.04%)
        dw $005E        ; Octave  7, Note  86 - D  (1179.16 Hz, Ideal=1174.64 Hz, Error=+0.38%)
        dw $0059        ; Octave  7, Note  87 - D# (1245.40 Hz, Ideal=1244.40 Hz, Error=+0.08%)
        dw $0054        ; Octave  7, Note  88 - E  (1319.53 Hz, Ideal=1318.52 Hz, Error=+0.08%)
        dw $004F        ; Octave  7, Note  89 - F  (1403.05 Hz, Ideal=1396.92 Hz, Error=+0.44%)
        dw $004B        ; Octave  7, Note  90 - F# (1477.88 Hz, Ideal=1480.00 Hz, Error=-0.14%)
        dw $0047        ; Octave  7, Note  91 - G  (1561.14 Hz, Ideal=1568.00 Hz, Error=-0.44%)
        dw $0043        ; Octave  7, Note  92 - G# (1654.34 Hz, Ideal=1661.20 Hz, Error=-0.41%)
        dw $003F        ; Octave  7, Note  93 - A  (1759.38 Hz, Ideal=1760.00 Hz, Error=-0.04%)
        dw $003B        ; Octave  7, Note  94 - A# (1878.65 Hz, Ideal=1866.40 Hz, Error=+0.66%)
        dw $0038        ; Octave  7, Note  95 - B  (1979.30 Hz, Ideal=1975.52 Hz, Error=+0.19%)

        dw $0035        ; Octave  8, Note  96 - C  (2091.33 Hz, Ideal=2093.04 Hz, Error=-0.08%) C7
        dw $0032        ; Octave  8, Note  97 - C# (2216.81 Hz, Ideal=2217.60 Hz, Error=-0.04%)
        dw $002F        ; Octave  8, Note  98 - D  (2358.31 Hz, Ideal=2349.28 Hz, Error=+0.38%)
        dw $002D        ; Octave  8, Note  99 - D# (2463.13 Hz, Ideal=2488.80 Hz, Error=-1.03%)
        dw $002A        ; Octave  8, Note 100 - E  (2639.06 Hz, Ideal=2637.04 Hz, Error=+0.08%)
        dw $0028        ; Octave  8, Note 101 - F  (2771.02 Hz, Ideal=2793.84 Hz, Error=-0.82%)
        dw $0025        ; Octave  8, Note 102 - F# (2995.69 Hz, Ideal=2960.00 Hz, Error=+1.21%)
        dw $0023        ; Octave  8, Note 103 - G  (3166.88 Hz, Ideal=3136.00 Hz, Error=+0.98%)
        dw $0021        ; Octave  8, Note 104 - G# (3358.81 Hz, Ideal=3322.40 Hz, Error=+1.10%)
        dw $001F        ; Octave  8, Note 105 - A  (3575.50 Hz, Ideal=3520.00 Hz, Error=+1.58%)
        dw $001E        ; Octave  8, Note 106 - A# (3694.69 Hz, Ideal=3732.80 Hz, Error=-1.02%)
        dw $001C        ; Octave  8, Note 107 - B  (3958.59 Hz, Ideal=3951.04 Hz, Error=+0.19%)

        dw $001A        ; Octave  9, Note 108 - C  (4263.10 Hz, Ideal=4186.08 Hz, Error=+1.84%) C8
        dw $0019        ; Octave  9, Note 109 - C# (4433.63 Hz, Ideal=4435.20 Hz, Error=-0.04%)
        dw $0018        ; Octave  9, Note 110 - D  (4618.36 Hz, Ideal=4698.56 Hz, Error=-1.71%)
        dw $0016        ; Octave  9, Note 111 - D# (5038.21 Hz, Ideal=4977.60 Hz, Error=+1.22%)
        dw $0015        ; Octave  9, Note 112 - E  (5278.13 Hz, Ideal=5274.08 Hz, Error=+0.08%)
        dw $0014        ; Octave  9, Note 113 - F  (5542.03 Hz, Ideal=5587.68 Hz, Error=-0.82%)
        dw $0013        ; Octave  9, Note 114 - F# (5833.72 Hz, Ideal=5920.00 Hz, Error=-1.46%)
        dw $0012        ; Octave  9, Note 115 - G  (6157.81 Hz, Ideal=6272.00 Hz, Error=-1.82%)
        dw $0011        ; Octave  9, Note 116 - G# (6520.04 Hz, Ideal=6644.80 Hz, Error=-1.88%)
        dw $0010        ; Octave  9, Note 117 - A  (6927.54 Hz, Ideal=7040.00 Hz, Error=-1.60%)
        dw $000F        ; Octave  9, Note 118 - A# (7389.38 Hz, Ideal=7465.60 Hz, Error=-1.02%)
        dw $000E        ; Octave  9, Note 119 - B  (7917.19 Hz, Ideal=7902.08 Hz, Error=+0.19%)

        dw $000D        ; Octave 10, Note 120 - C  ( 8526.20 Hz, Ideal= 8372.16 Hz, Error=+1.84%) C9
        dw $000C        ; Octave 10, Note 121 - C# ( 9236.72 Hz, Ideal= 8870.40 Hz, Error=+4.13%)
        dw $000C        ; Octave 10, Note 122 - D  ( 9236.72 Hz, Ideal= 9397.12 Hz, Error=-1.71%)
        dw $000B        ; Octave 10, Note 123 - D# (10076.42 Hz, Ideal= 9955.20 Hz, Error=+1.22%)
        dw $000B        ; Octave 10, Note 124 - E  (10076.42 Hz, Ideal=10548.16 Hz, Error=-4.47%)
        dw $000A        ; Octave 10, Note 125 - F  (11084.06 Hz, Ideal=11175.36 Hz, Error=-0.82%)
        dw $0009        ; Octave 10, Note 126 - F# (12315.63 Hz, Ideal=11840.00 Hz, Error=+4.02%)
        dw $0009        ; Octave 10, Note 127 - G  (12315.63 Hz, Ideal=12544.00 Hz, Error=-1.82%)
        dw $0008        ; Octave 10, Note 128 - G# (13855.08 Hz, Ideal=13289.60 Hz, Error=+4.26%)


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
	dw TEST_STRING_0	; Start of Play string
	dw 0x0000		; Current location in Play string
	dw TEST_STRING_0_END	; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x18			; Octave 6 by default
	db 0x0F			; Volume

CHANNEL_1_INFO:
	db 0x01			; Channel number
	dw TEST_STRING_1	; Start of Play string
	dw 0x0000		; Current location in Play string
	dw TEST_STRING_1_END	; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x30			; Octave 5 by default
	db 0x0F			; Volume

CHANNEL_2_INFO:
	db 0x01			; Channel number
	dw TEST_STRING_2	; Start of Play string
	dw 0x0000		; Current location in Play string
	dw TEST_STRING_2_END	; End of Play string
	dw 0xFFFF		; Default note duration
	dw 0x0000		; Current note counter
	db 0x30			; Octave 6 by default
	db 0x0F			; Volume


TEST_STRING_0:			; Simple scale
	dm "O5N3e#fgabg5b&&&3#a#f5#a3af5a3e#fgabgbEDbgb7D"
TEST_STRING_0_END:
	
TEST_STRING_1:			; Simple scale
	dm "O5V8N3b#C#DE#F#D5#F&&&N3G#D5G3#F#D5#FN3b#C#DE#F#D5#FN3G#D5G7#F"
TEST_STRING_1_END:
	
TEST_STRING_2:			; Simple scale
	;; 	dm "N"
TEST_STRING_2_END:
	
	

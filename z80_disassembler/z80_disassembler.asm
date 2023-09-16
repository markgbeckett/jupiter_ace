	org 0x6800

	;; Lookup table of lengths of different Z80 instructions

TYPES: 
	db $C2,$C3,$C4,$C5,$C8,$CC,$80,$C1		; $6800
	db $42,$C3,$44,$C5,$81,$53,$D0,$00		; $6808
	db $42,$C3,$44,$C5,$81,$41,$C6,$00		; $6810
	db $B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7		; $6818
	db $4E,$DA,$DA,$4E,$C3,$C3,$50,$CF		; $6820
	db $50,$C5,$D0,$CD,$00,$00,$00,$00		; $6828
	db $41,$44,$44,$20,$41,$AC,$41,$44		; $6830
	db $43,$20,$41,$AC,$53,$55,$42,$A0		; $6838
	db $53,$42,$43,$20,$41,$AC,$41,$4E		; $6840
	db $44,$A0,$58,$4F,$52,$A0,$4F,$52		; $6848
	db $A0,$43,$50,$A0                        ; $6850
	
	;; Addresses of eigth subroutines
SUBRTS:	dw SPLIT
	dw LITERAL
	dw LIST_G
	dw LIST_H
	dw SELECT_G
	dw SELECT_H
	dw SKIP
	dw QSKIP

	;; Control sequence for different values of F (and CB/DE
	;; modifiers)
DATADS:	dw DATA_S0		; $6AE2 
	dw DATA_S1         	; $6B7F
	dw DATA_S2         	; $6B84
	dw DATA_S3         	; $6B86
	dw DATA_S4       	; $6C1A
	dw DATA_S5       	; $6C32
	dw DATA_S6       	; $6C38
	dw DATA_S7       	; $6C3E
	dw $0000		; Invalid op-code
	dw DATA_S8       	; $6C44
	dw DATA_S9       	; $6CC9
	dw $0000              	; Invalid op-code

	;; Replace current byte in DISS (x, y, v, and w) as required
	;; with IX, IT, (HL), etc.
	;; 
	;; On entry, HL points to current location in DISS
REPLACE:
	pop ix			; Retrieve pointer to subroutine arguments

	ld de,(DISS)		; Retrieve address of start of DISS

	and a			; Compute length of string to modify (HL
	sbc hl,de		; points to current location in
				; DISS). Assume answer is one byte long
				; (i.e., fits in L)

	ld a,(de)		; Retrieve length of DISS
	sub l			; and compute length of remaining string
	inc a			; in A

	push af			; Save length of string remainder
	ld a,(de)		; Retrieve length of DISS
	ld l,a			; Save it

	;; Work out new length of string
	add a,(ix+0x00)		; Add length of parameter field
	dec a
	ld (de),a		; and update length of DISS
	
	add hl,de		; Set HL to point to end of DISS

	;; Compute end of topical string
	ld e,(ix+0x00)		; DE = Length of replacement string
	ld d,0x00		; 
	push hl			; Save HL
	add hl,de		; Compute address of end of topical
	dec hl			; string
	ex de,hl		; Move to DE (new end of DISS)
	pop hl			; Restore HL (old end of DISS)
	pop af			; Restore length

	push bc			; Save BC
	ld c,a			; Move length to BC
	ld b,0x00		; Effectively insert space into string
	lddr

	;; Insert replacement text
	ex de,hl		; DE now points to insertion point in
	inc de			; string

	ld c, (ix+0x00)		; Length of insertion text
	push ix
	pop hl
	inc hl			; HL is start of string to insertion
	ld b,0x00
	ldir			; Insert new text into DISS

	ex de,hl		; DE points to byte after parameter
				; field for RETURN
	dec hl			; HL points to new, current location in
				; DISS
	
	pop bc			; Restore BC
	push de			; Push address of code past parameter
				; field

	ret			; Jump to (DE)
	
	;; Add character to the end of the current string, DIS
CHR:
	push af			; Save registers
	push bc
	push hl

	and %01111111		; Ignore bit 7

	ld hl, (DISS)		; Retrieve start of DIS

	;; Increase length count (first byte of DIS)
	ld c,(hl)
	inc c
	ld (hl),c

	ld b,0x00 		; BC - length of string

	add hl,bc		; Advance HL to last byte of string
	ld (hl),a		; Store new character

	;; Restore registers
	pop hl
	pop bc
	pop af

	ret
	
	;; Print contents of BC in hex
HP_BC:	ld a,b
	call HP_A
	ld a,c

	;; Print contents of A in hex
HP_A:	push af			; Save A
	rra			; Isolate high nibble
	rra
	rra
	rra
	call HP_AL
	
	pop af			; Retrieve A

	;; Print lower nibble of A in hex
HP_AL:
	and %00001111		; Isolate lower nibble

	cp 0x0A			; Convert to ASCII
	sbc a,0x69
	daa

	call PRINT_A

	ret

	;; Insert next byte (two characters) of subject program into DIS
	;; (HL)
INS:
	;; Retrieve number from BC'
	exx
	ld a,(bc)
	inc bc
	exx

	push af			; Save A
	call INS_2		; Insert lower nibble
	pop af			; Restore A

	rra 			; Move upper nibble into lower nibble
	rra			; ready to be inserted
	rra
	rra
INS_2:	and 0x0F		; Isolate lower nibble

	;; Convert to character code (relies on A...F being after 0...9)
	add a, _0
	cp _9 + 1
	jr c,INS_CH
	add a, _A - _9 - 1

	;; Insert character
INS_CH:	ld (hl),a
	dec hl

	ret

RETURN:	bit 6,e
	jr z, NOCOMMA
	ld a, _COMMA
	call CHR		; Deposit character in DIS
NOCOMMA:
	bit 7,e
	jp z, CONTROL

	;; Decode DIS and print final output
DECODE:	exx
	ld a,d
	exx
	ld c,a

	;; Point to start of DIS and retrieve length
	ld hl,(DISS)
	ld b,(hl)

DECODE_LP:
	inc hl
	ld a,(hl)
	and a
	jr nz, DECODE_2
	ld a,c
	and a
	jr nz, DECODE_3

	call REPLACE
	db 0x04, _LEFTPARENTH, _H, _L, _RIGHTPARENTH

	jr DECODE_2

DECODE_3:	
	dec a
	jr nz, DECODE_5
	call REPLACE
	db 0x06, _LEFTPARENTH, _I, _X, _PLUS, 0x02, _RIGHTPARENTH
	jr DECODE_2

DECODE_5:
	call REPLACE
	db 0x06, _LEFTPARENTH, _I, _Y, _PLUS, 0x02, _RIGHTPARENTH

DECODE_2:
	ld a,(hl)
	dec a
	jr nz, DECODE_4
	ld a,c
	and a
	jr nz, DECODE_6
	call REPLACE
	db 0x02, _H, _L
	jr DECODE_4

DECODE_6:
	dec a
	jr nz, DECODE_7
	call REPLACE
	db 0x02, _I, _X
	jr DECODE_4

DECODE_7:
	call REPLACE
	db 0x02, _I, _Y

DECODE_4:
	djnz DECODE_LP
	ld hl,(DISS)
	ld b,(hl)

DECODE_LP_2:
	inc hl
	ld a,(hl)
	sub 0x02
	jr nz, DECODE_8
	call REPLACE
	db 0x02, _NULL, _NULL
	exx
	ld a,e
	rra
	sbc a,a
	and d
	exx
	push af
	jr z, DECODE_9
	exx
	dec bc
	dec bc
	exx
DECODE_9:
	call INS
	pop af
	jr z, DECODE_10

	exx
	inc bc
	nop
	exx
	jr DECODE_10
;
DECODE_8:
	dec a
	jr nz,DECODE_11

	call REPLACE
	defb $04,_NULL, _NULL, _NULL, _NULL
	
	call INS
	call INS

	inc hl
	inc hl

DECODE_10:
	inc hl
	inc hl

DECODE_11:
	djnz DECODE_LP_2
	ld hl,(DISS)
	ld b,(hl)
	
DECODE_LP_3:
	inc hl
	ld a,(hl)
	call PRINT_A
	djnz DECODE_LP_3
	jr RESTART

	;; Entry point for disassembler
START:	call INIT		; System specific initialisation

	;; Retrieve ADDRESS into BC' and zero DE'
	exx
	ld bc, (ADDRESS)
	exx

RESTART:
	ld hl,(DISS)
	ld (hl),0x00
	
	exx
	ld de, 0x0000
	exx
	
MAIN:	ld a, _CARRIAGERETURN	; Print newline
	call PRINT_A

	;; Print current address followed by space
	exx
	call HP_BC

	ld a,_SPACE
	call PRINT_A

	;; Retrieve next byte to disassemble and advance pointer
MAIN_LOOP_1:
	ld a,(bc)
	inc bc

	;; Retrieve status info
	push de			; D=INDEX; C=CLASS
	exx
	pop bc

	cp 0x76			; Test for HALT
	jr nz, MAIN_CHECK_PREFIX

	;; Check if CLASS is zero (otherwise is not HALT)
	;; 	inc c			; Different from Toni's original code
	dec c
	jr z, MAIN_2

	ld hl, HALT_STR
	ld b, 0x04

HALT_LOOP:
	ld a,(hl)
	inc hl
	call PRINT_A
	djnz HALT_LOOP
	jr MAIN

HALT_STR:
	db _H, _A, _L, _T
	
	;; Check for special codes
MAIN_2:	inc c
MAIN_CHECK_PREFIX:
	cp 0xCB
	jr z, CB_INST

	cp 0xED
	jr z, ED_INST

	cp 0xDD
	jr z, DD_INST

	cp 0xFD
	jr nz, MAIN_PROC_INST

	;; FD instruction (prefix for IY)
	ld b, 0x02
	jr MAIN_NEXT_INST

	;; DD instruction (prefix for IX)
DD_INST:
	ld b, 0x01
	jr MAIN_NEXT_INST

	;; ED instruction (CLASS=2)
ED_INST:
	ld c, 0x02
	jr MAIN_NEXT_INST

	;; CB instruction (CLASS=1)
CB_INST:
	ld c,0x01		
	inc b			; Check INDEX=0
	dec b
	jr z, MAIN_NEXT_INST

	;; Interpret next two bytes in reverse order
	exx
	inc bc
	exx

MAIN_NEXT_INST:
	push bc
	exx
	pop de

	jr MAIN_LOOP_1

MAIN_PROC_INST:
	ld d,a			; Retrieve op code

	;; Extract 'F'
	and %11000000		; Isolate bit 7 and 6 
	or c			; Augment with CLASS
	
	rlca			; Bit 7 and 6 move to Bit 2 and 1,
	rlca			; respectively. Bit 1 and 0 move to 4
	rlca			; and 3, respectively

	;; Next step relies on low-order bytes of types being zero
	add a, DATADS & 0xFF
	ld l,a
	ld h, (DATADS >> 8) & 0xFF		; 0x68
	ld c, (hl)
	inc hl
	ld b,(hl)

	push bc
	exx
	pop hl
	exx
CONTROL:			; Was called MASTER in original listing
	exx
	ld a, (hl)		; Find byte of data and increment pointer
	inc hl
	exx
	
	;; Save copy of byte (needed again later)
	ld e,a

	and %00000111		; Mask off bottom three bits
	rla			; Multiple by two (to create offset)
	ld c,a			; Move offset to BC
	ld b,0x00

	;; Set return addres for minor subroutines
	ld hl, RETURN		
	push hl

	;; Find appropriate subroutine and retrieve address
	ld hl, SUBRTS
	add hl,bc

	ld c,(hl)
	inc hl
	ld b,(hl)

	;; Jump to subroutine
	push bc
	ret

	;; Retrieve n'th address from list pointed to by HL' and load
	;; that address into HL'
SPLIT: 	ld a,d
	exx			; Save active registers

	;; Isolate lower three bits and multply by two to get offset to
	;; routine
	and %00000111
	rla

	;; Copy into DE (saving previous value first)
	push de
	ld e,a
	ld d,0x00

	;; Retrieve addresss into HL
	add hl,de
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl

	;; Restore previous value of DE
	pop de

	exx

	ret

	;; Append string from control sequence to DIS
LITERAL:
	exx
LIT_LP:	ld a,(hl) 		; Retrieve next character
	inc hl			; and increase pointer
	
	call CHR		; Add to DIS
	
	rla			; Check if done (bit 7 high)
	jr nc, LIT_LP		; Repeat, if not

	exx

	bit 3,e			; Check if need a space
	ret z			; Done, if not

	ld a,_SPACE		; Add space to DIS and done
	jp CHR

	;; Select (A+1)'th item from the following list
FIND:
	exx
	push hl
	exx
	pop hl
SELECT:	ld b,a
	inc b
	dec b
	ret z

FIND_LP:
	ld a,(hl)
	inc hl
	rla
	jr nc, FIND_LP
	djnz FIND_LP

	ret

LIST_G: ld a,d
	rra
	rra
	rra
	jr LIST_CONT
	
LIST_H:	ld a,d

LIST_CONT:	
	and %00000111
	call FIND

LIST_LP:
	ld a,(hl)
	inc hl
	call CHR
	rla
	jr nc, LIST_LP

	ld a,e
	rra
	rra
	rra
	and %00000111
	inc a
	call FIND

	push hl
	exx
	pop hl
	exx

	ret

SELECT_G:
	ld a,d
	rra
	rra
	rra
	jr SELECT_CONT

SELECT_H:
	ld a,d

SELECT_CONT:
	and %00000111

	push af

	ld a,e
	and 0x38
	ld l,a
	ld h, 0x68
	pop af

	call SELECT

SELECT_LP:
	ld a,(hl)
	inc hl
	call CHR

	rla
	jr nc, SELECT_LP

	ret

	;; Subsequent step based on value of Q (0/1)
QSKIP:
	ld a,d			; Retrieve saved copy of Op Code
	rra			; Shift P right one bit (into Bits 4 and 5)
	and %00011000		; and isolate it (so A contains P*8)
	ld b,a			; Save it
	ld a,d			; Retried Op Code again
	rla			; Move Q left twice (to Bit 6) ...
	rla
	and %00100000		; ... and isolate it
	or b			; Combine with relocated P
	xor d			; Complement with original P and Q
	and %00111000		; 
	xor d
	ld d,a			; D contains modified inst with P and Q swapped
	
SKIP: 	bit 5,d			; Test value of Q
	jr nz, SKIP_CONT	; If set, skip forward 'n' steps in sequence
	exx			; Otherwise, advance to next step in sequence
	inc hl 
	exx
	ret

SKIP_CONT:
	res 5,d

	exx

	push bc

	ld c,(hl)
	inc hl
	ld b,0x00
	add hl, bc

	pop bc

	exx

	ret

	ds 0x6ae2-$
	
ADDRESS:	dw 0x0000
	
DATA:
	;;  Control sequence entries XCDDDNNN, where:
	;;     NNN - routine number
	;;     DDD - data for routine
	;;     C - insert comma after routine
	;;     X - terminal sequence
	
	;; Sequence for X=0 (see sub-sequences for details)
DATA_S0:			
	db $00					; SPLIT (on H)
	dw DATA_S0a, DATA_S0b, DATA_S0c, DATA_S0d
	dw DATA_S0e, DATA_S0f, DATA_S0g, DATA_S0h
	
DATA_S0a:	; Relative jumps and assorted ops
	db $06,$17			   	; SKIP ($17)
	db $9A					; LIST-G (4)
	db _N,_O,_P+$80			
	db _E,_X,_SPACE,_A,_F,_COMMA,_A,_F,_APOSTROPHE+$80
	db _D,_J,_N,_Z,_SPACE,$02+$80	
	db _J,_R,_SPACE,$02+$80
						; TERMINATE
	db $09,_J,_R+$80			; LITERAL (inc space)
	db $64					; SELECT-G (C(G)) (inc comma)
	db $81, $02+$80				; LITERAL
						; TERMINATE

DATA_S0b:	; 16-bit load immediate/ add
	db $07,$07		   	; K-SKIP
	db $09,_L,_D+$80		; LITERAL (inc space)
	db $4C				; SELECT-G (s(G))
	db $81,$03+$80			; LITERAL
					; TERMINATE
	db $00
	db $41,_A,_D,_D,_SPACE, $01+$80	; LITERAL (inc comma) 
	db $8C				; SELECT-G (s(G))
					; TERMINATE

DATA_S0c:	; Indirect loads
	db $09,_L,_D+$80		   	; LITERAL (inc space)
	db $BA					; LIST-G(8) (10111010)
	db _LEFTPARENTH,_B,_C,_RIGHTPARENTH,_COMMA,_A+$80		; 
	db _A,_COMMA,_LEFTPARENTH,_B,_C,_RIGHTPARENTH+$80
	db _LEFTPARENTH,_D,_E,_RIGHTPARENTH,_COMMA,_A+$80
	db _A,_COMMA,_LEFTPARENTH,_D,_E,_RIGHTPARENTH+$80
	db _LEFTPARENTH,$03,_RIGHTPARENTH,_COMMA,$01+$80
	db $01,_COMMA,_LEFTPARENTH,$03,_RIGHTPARENTH+$80	
	db _LEFTPARENTH,$03,_RIGHTPARENTH,_COMMA,_A+$80
	db _A,_COMMA,_LEFTPARENTH,$03,_RIGHTPARENTH+$80

DATA_S0d:	; 16-bit INC/ DEC
	db $07,$05		   	; K-SKIP
	db $09,_I,_N,_C+$80		; LITERAL (inc space)
	db $8C				; SELECT-G (S(G))
					; TERMINATE
	db $09,_D,_E,_C+$80		; LITERAL (inc space)
	db $8C				; SELECT-G (S(G))
					; TERMINATE
	
DATA_S0g: 	; 8-bit load immediate
	db $09,_L,_D+$80		; LITERAL (inc space)
	db $44				; SELECT-G (r(G)) (inc comma)
	db $81,$02+$80			; LITERAL
					; TERMINATE
	
DATA_S0h:	; Assorted operations on accumulator/ flags
	db $BA				; LIST-G (8) %10111010
	db _R,_L,_C,_A+$80
	db _R,_R,_C,_A+$80
	db _R,_L,_A+$80
	db _R,_R,_A+$80
	db _D,_A,_A+$80
	db _C,_P,_L+$80
	db _S,_C,_F+$80
	db _C,_C,_F+$80
					; TERMINATE

	;; Sequence for X=1 (8-bit LD between registers)
DATA_S1:
	db $09,_L,_D+$80	; LITERAL (inc. space)
	db $44			; SELECT-G (r(G) plus comma)
	db $85			; SELECT-H (r(G)))
				; TERMINATE

	;; Sequence for X=2 (operations involving ALU and another reg)
DATA_S2: 
	db $34			; SELECT-G (x(G))
	db $85		 	; SELECT-H (r(G))
				; TERMINATE

	;; Sequence for X=3 (see subcategories for details)
DATA_S3:
	db $00			; SPLIT (on H)
	dw DATA_S3a
	dw DATA_S3b
	dw DATA_S3c
	dw DATA_S3d
	dw DATA_S3e
	dw DATA_S3f
	dw DATA_S3g
	dw DATA_S3h

DATA_S3a:			; Conditional returns
	db $09,_R,_E,_T+$80
	db $A4				; SELECT-G(c(G)) (inc. comma)
					; TERMINATE
	
DATA_S3b:
	db $07,$05	; K-SKIP
	db $09,_P,_O,_P+$80	; $6BA0 O...RE.E
	db $94			; SELECT-G(q(G)
				; TERMINATE
	db $9A 		; LIST-G(4) 10011010
	db _R,_E,_T+$80
	db _E,_X,_X+$80
	db _J,_P,_SPACE,_LEFTPARENTH,$01,_RIGHTPARENTH+$80
	db _L,_D,_SPACE,_S,_P,_COMMA,$01+$80
				; TERMINATE

DATA_S3c:		; Conditional jumps
	db $09,_J,_P+$80	; LITERAL (inc. space)
	db $64			; SELECT-G(c(G)) (inc. comma)
	db $81,$03+$80		; LITERAL
				; TERMINATE

DATA_S3d: 		; Assorted operations
	db $BA				   ; LIST-G(8)
	db _J,_P,_SPACE,$03+$80
	db _SPACE+$80
	db _O,_U,_T,_SPACE,_LEFTPARENTH,$02,_RIGHTPARENTH,_COMMA,_A+$80
	db _I,_N,_SPACE,_A,_COMMA,_LEFTPARENTH,$02,_RIGHTPARENTH+$80
	db _E,_X,_SPACE,_LEFTPARENTH,_S,_P,_RIGHTPARENTH,_COMMA,$01+$80
	db _E,_X,_SPACE,_D,_E,_COMMA,_H,_L+$80
	db _D,_I+$80
	db _E,_I+$80

DATA_S3e:		; Conditional call
	db $09,_C,_A,_L,_L+$80			; LITERAL (inc. space)
	db $64					; SELECT-G(c(G)) (inc. comma)
	db $81,$03+$80				; LITERAL
						; TERMINATE

	;; Sequence for X=3 and Z=5 (CALL or PUSH)
DATA_S3f:		; PUSH and various ops
	db $07,$06 				; KSKIP 6 
	db $09,_P,_U,_S,_H+$80			; LITERAL (inc. space)
	db $94					; SELECT-G (s(G))
						; TERMINATE
	db $81,_C, _A, _L, _L, _SPACE, $80+3	; LITERAL
						; TERMINATE

DATA_S3g:			; Operate on accumulator and immediate
				; operand
	db $34					; SELECT-G(x(G))
	db $81,$02+$80				; LITERAL
						; TERMINATE

DATA_S3h:			; Restart routines
	db $09,_R,_S,_T+$80			; LITERAL (inc space)
	db $BA					; LIST-G(8)
	db _0,_0+$80
	db _0,_8+$80
	db _1,_0+$80
	db _1,_1+$80
	db _2,_0+$80
	db _2,_8+$80
	db _3,_0+$80
	db _3,_8+$80

	;; Sequence for X=0, CLASS=1 (CB prefix) (rotate instructions
	;; not involving ALU)
DATA_S4:
	db $3A 			; LIST-G (8 ITEMS) %00111010
	db _R,_L,_C+$80
	db _R,_R,_C+$80
	db _R,_L+$80
	db _R,_R+$80
	db _S,_L,_A+$80
	db _S,_R,_A+$80
	db _SPACE+$80		; *** This looks like error ***
	db _S,_R,_L+$80
	db $01,_SPACE+$80			; LITERAL
	db $85					; SELECT-H
						; TERMINATE

	;; Sequence for X=1, CLASS=1 (CB prefix) (BIT instructions)
DATA_S5:
	db $09,_B,_I,_T+$80 			; LITERAL (inc space)
	db $5C		    			; SELECT-G (n(G))
	db $85		    			; SELECT-H (r(G))
						; TERMINATE

	;; Sequence for X=2, CLASS=1 (CB prefix) (RES instructions)
DATA_S6:	
	db $09,_R,_E,_S+$80 			; LITERAL (inc space)
	db $5C		    			; SELECT-G (n(G))
	db $85		    			; SELECT-H (r(G))
						; TERMINATE

	;; Sequence for X=3, CLASS=1 (CB prefix) (SET instructions)
DATA_S7:
	db $09,_S,_E,_T+$80			; LITERAL (inc space)
	db $5C		    			; SELECT-G (n(G))
	db $85		    			; SELECT-H (r(G))
						; TERMINATE

	;; Sequence for X=0, CLASS=2 (ED prefix) Invalid opcode

	;; Sequence for X=1, CLASS=2 (ED prefix) (various, see
	;; sub-sequences for details)
DATA_S8:	
	db $00
	dw DATA_S8a
	dw DATA_S8b
	dw DATA_S8c
	dw DATA_S8d
	dw DATA_S8e
	dw DATA_S8f
	dw DATA_S8g
	dw DATA_S8h

DATA_S8a:		; Input from port with 16-bit address
	db $09,_I,_N+$80			; LITERAL (inc space)
	db $44					; SELECT G(r(G)) (inc comma)
	db $81,_LEFTPARENTH,_C,_RIGHTPARENTH+$80
						; LITERAL
						; TERMINATE

DATA_S8b:		; Output to port with 16-bit address
	db $41,_O,_U,_T,_SPACE,_LEFTPARENTH,_C,_RIGHTPARENTH+$80
						; LITERAL (inc comma)
	db $84					; SELECT G(r(G))
						; TERMINATE
DATA_S8c:	
	db $07,$08			   	; K-SKIP
	db $41,_S,_B,_C,_SPACE,_H,_L+$80	; LITERAL (inc comma)
	db $8C					; SELECT-G(s(G))
						; TERMINATE
	db $41,_A,_D,_C,_SPACE,_H,_L+$80	; LITERAL (inc. comma)
	db $8C					; SELECT-G(s(G))
						; TERMINATE
	
DATA_S8d:	
	db $07,$08	; K-SKIP
	db $41,_L,_D,_SPACE,_LEFTPARENTH,$03,_RIGHTPARENTH+$80
 						; LITERAL (inc comma)
	db $8C					; SELECT-G(s(G))
						; TERMINATE
	db $09,_L,_D+$80	; LITERAL (inc space)
	db $4C			; SELECT-G(s(G)) (inc comma)
	db $81,_LEFTPARENTH,$03,_RIGHTPARENTH+$80
				; TERMINATE
DATA_S8e:
	db $81,_N,_E,_G+$80		; LITERAL

DATA_S8f:	
	db $07,$05			; K-SKIP
	db $81,_R,_E,_T,_N+$80		; LITERAL
					; TERMINATE
	db $81,_R,_E,_T,_I+$80		; LITERAL
					; TERMINATE
	
DATA_S8g:	
	db $9A	; LIST-G(4)
	db _I,_M,_SPACE,_0+$80
	db _SPACE+$80
	db _I,_M,_SPACE,_1+$80
	db _I,_M,_SPACE,_2+$80
					; TERMINATE

DATA_S8h:	
	db $BA				; LIST-G(8)
	db _L,_D,_SPACE,_I,_COMMA,_A+$80
	db _L,_D,_SPACE,_R,_COMMA,_A+$80
	db _L,_D,_SPACE,_A,_COMMA,_I+$80
	db _L,_D,_SPACE,_A,_COMMA,_R+$80
	db _R,_R,_D+$80
	db _R,_L,_D+$80
	db _SPACE+$80
	db _SPACE+$80
					; TERMINATE

	;; Sequence for X=2, CLASS=2 (ED prefix) (block instructions)
DATA_S9:	
	db $1B					; LIST-H (4)
	db _L,_D+$80
	db _C,_P+$80
	db _I,_N+$80
	db _O,_T+$80
	db $BA					; LIST-G(8)
	db _SPACE+$80
	db _SPACE+$80
	db _SPACE+$80
	db _SPACE+$80
	db _I+$80
	db _D+$80
	db _I,_R+$80
	db _D,_R+$80
						;  TERMINATE
	
DATA_S0e:	
	db $09,_I,_N,_C+$80			; LITERAL (inc space)
	db $84					; SELECT-G (r(G))
						; TERMINATE

DATA_S0f:
	db $09,_D,_E,_C+$80		  	; LITERAL (inc space)
	db $84					; SELECT-G (r(G))
						; TERMINATE

	;; Not sure any of this is needed
	db $1C	; $6CE0 ...DE...
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6CE8 ........ 
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6CF0 ........
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6CF8 ........
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6D00 ........
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6D08 ........
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6D10 ........
	db $00,$00,$00,$00,$00,$00,$00,$00	; $6D18 ........

	;; Sequence for X=3, CLASS=2 (ED prefix) Invalid opcode


LENS:	db 0x5F, 0x55, 0x55, 0xA5, 0x55, 0x55, 0x55, 0xA5
        db 0xAF, 0x55, 0x55, 0xA5, 0xA5, 0x55, 0x55, 0xA5
        db 0xAF, 0xF5, 0x55, 0xA5, 0xA5, 0xF5, 0x55, 0xA5
        db 0xAF, 0xF5, 0x99, 0xE5, 0xA5, 0xF5, 0x55, 0xA5
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x99, 0x99, 0x99, 0x59, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0x55, 0x55, 0x95, 0x55, 0x55, 0x55, 0x95
        db 0x55, 0xFF, 0xF5, 0xA5, 0x55, 0xFE, 0xFF, 0xA5
        db 0x55, 0xFA, 0xF5, 0xA5, 0x55, 0xFA, 0xF5, 0xA5
        db 0x55, 0xF5, 0xF5, 0xA5, 0x55, 0xF5, 0xFA, 0xA5
        db 0x55, 0xF5, 0xF5, 0xA5, 0x55, 0xF5, 0xF5, 0xA5


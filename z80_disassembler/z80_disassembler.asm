	org 0x6800

ADDRESS:	equ 0x7ff8
	
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

	ld de,(STKEND)		; Retrieve address of start of DISS

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

	ld hl, (STKEND)		; Retrieve start of DIS

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
	ld hl,(STKEND)
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
	db 0x04, _OPENBRACKET, _H, _L, _CLOSEBRACKET

	jr DECODE_2

DECODE_3:	
	dec a
	jr nz, DECODE_5
	call REPLACE
	db 0x06, _OPENBRACKET, _I, _X, _PLUS, 0x02, _CLOSEBRACKET
	jr DECODE_2

DECODE_5:
	call REPLACE
	db 0x06, _OPENBRACKET, _I, _Y, _PLUS, 0x02, _CLOSEBRACKET

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
	ld hl,(STKEND)
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
	ld hl,(STKEND)
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
	ld hl,(STKEND)
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
	
DATA:
	;;  Control sequence entries XCDDDNNN, where:
	;;     NNN - routine number
	;;     DDD - data for routine
	;;     C - insert comma after routine
	;;     X - terminal sequence
	
	;; Sequence for X=0 (see sub-sequences for details)
DATA_S0:			; SPLIT (on H)
	db $00
	db $F3,$6A,$12,$6B,$22		; $6AE2 ..j.k"
	db $6B,$52,$6B,$DD,$6C,$E2,$6C,$5E	; $6AE8 kRk.l.l^
	db $6B,$64,$6B,$06,$17,$9A,$4E,$4F	; $6AF0 kdk...NO
	db $D0,$45,$58,$20,$41,$46,$20,$41	; $6AF8 .EX AF A
	db $46,$A7,$44,$4A,$4E,$5A,$20,$82	; $6B00 F.DJNZ .
	db $4A,$52,$20,$82,$09,$4A,$D2,$64	; $6B08 JR ..J.d
	db $81,$82,$07,$07,$09,$4C,$C4,$4C	; $6B10 .....L.L
	db $81,$83,$00,$41,$41,$44,$44,$20	; $6B18 ...AADD 
	db $81,$8C,$09,$4C,$C4,$BA,$28,$42	; $6B20 ...L..(B
	db $43,$29,$2C,$C1,$41,$2C,$28,$42	; $6B28 C),.A,(B
	db $43,$A9,$28,$44,$45,$29,$2C,$C1	; $6B30 C.(DE),.
	db $41,$2C,$28,$44,$45,$A9,$28,$03	; $6B38 A,(DE.(.
	db $29,$2C,$81,$01,$2C,$28,$03,$A9	; $6B40 ),..,(..
	db $28,$03,$29,$2C,$C1,$41,$2C,$28	; $6B48 (.),.A,(
	db $03,$A9,$07,$05,$09,$49,$4E,$C3	; $6B50 .....IN.
	db $8C,$09,$44,$45,$C3,$8C,$09,$4C	; $6B58 ..DE...L
	db $C4,$44,$81,$82,$BA,$52,$4C,$43	; $6B60 .D...RLC
	db $C1,$52,$52,$43,$C1,$52,$4C,$C1	; $6B68 .RRC.RL.
	db $52,$52,$C1,$44,$41,$C1,$43,$50	; $6B70 RR.DA.CP
	db $CC,$53,$43,$C6,$43,$43,$C6		; $6B78 .SC.CC.

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
        db $97 
	db $6B,$9C,$6B,$B7,$6B,$BD,$6B,$E9	; $6B88 k.k.k.k.
	db $6B,$F1,$6B,$00,$6C,$03,$6C,$09	; $6B90 k.k.l.l.
	db $52,$45,$D4,$A4,$07,$05,$09,$50	; $6B98 RE.....P
	db $4F,$D0,$94,$9A,$52,$45,$D4,$45	; $6BA0 O...RE.E
	db $58,$D8,$4A,$50,$20,$28,$01,$A9	; $6BA8 X.JP (..
	db $4C,$44,$20,$53,$50,$2C,$81,$09	; $6BB0 LD SP,..
	db $4A,$D0,$64,$81,$83,$BA,$4A,$50	; $6BB8 J.d...JP
	db $20,$83,$A0,$4F,$55,$54,$20,$28	; $6BC0  ..OUT (
	db $02,$29,$2C,$C1,$49,$4E,$20,$41	; $6BC8 .),.IN A
	db $2C,$28,$02,$A9,$45,$58,$20,$28	; $6BD0 ,(..EX (
	db $53,$50,$29,$2C,$81,$45,$58,$20	; $6BD8 SP),.EX 
	db $44,$45,$2C,$48,$CC,$44,$C9,$45	; $6BE0 DE,H.D.E
	db $C9,$09,$43,$41,$4C,$CC,$64,$81	; $6BE8 ..CAL.d.
	db $83					; $6BF0 . 

	;; Sequence for X=3 and Z=5 (CALL or PUSH) 
	db $07,$06 				; KSKIP 6 
	db $09,_P,_U,_S,_H+$80			; LITERAL (inc. space)
	db $94					; SELECT-G (s(G))
						; TERMINATE
	db $81,_C, _A, _L, _L, _SPACE, $80+3	; LITERAL
						; TERMINATE

	db $34,$81,$82,$09,$52,$53,$D4,$BA	; $6C00 4...RS..
	db $30,$B0,$30,$38,$20,$82,$31,$B0	; $6C08 0.08 .1.
	db $31,$B8,$32,$B0,$32,$B8,$33,$B0	; $6C10 1.2.2.3.
	db $33,$B8	; $6C18 3.:RL.RR

	;; Sequence for X=0, CLASS=1 (CB prefix) (rotate instructions
	;; not involving ALU)
DATA_S4:
	db $3A 			; LIST-G (8 ITEMS) %00111010
	db _R,_L,_C+80
	db _R,_R,_C+$80
	db _R,_L+$80
	db _R,_R+$80
	db _S,_L,_A+$80
	db _S,_R,_A+$80
	db _SPACE+$80		; *** This looks like error ***
	db _S,_R,_L+$80
	db $01,_SPACE+80	; LITERAL
	db $85			; SELECT-H
				; Terminate

	;; Sequence for X=1, CLASS=1 (CB prefix) (BIT instructions)
DATA_S5:
	db $09,$42,$49,$D4,$5C,$85	; $6C32 ...BI.\.

	;; Sequence for X=2, CLASS=1 (CB prefix) (RES instructions)
DATA_S6:	
	db $09,$52,$45,$D3,$5C,$85	; $6C38 .RE.\.

	;; Sequence for X=3, CLASS=1 (CB prefix) (SET instructions)
DATA_S7:
	db $09,$53				; .S
	db $45,$D4,$5C,$85

	;; Sequence for X=0, CLASS=2 (ED prefix) Invalid opcode

	;; Sequence for X=1, CLASS=2 (ED prefix) (various, see
	;; sub-sequences for details)
DATA_S8:	
	db $00,$55,$6C,$5D	; $6C40 E.\..Ul]
	db $6C,$66,$6C,$78,$6C,$6A,$6C,$8E	; $6C48 lflxljl.
	db $6C,$9A,$6C,$A8,$6C,$09,$49,$CE	; $6C50 l.l.l.I.
	db $44,$81,$28,$43,$A9,$41,$4F,$55	; $6C58 D.(C.AOU
	db $54,$20,$28,$43,$A9,$84,$07,$08	; $6C60 T (C....
	db $41,$53,$42,$43,$20,$48,$CC,$8C	; $6C68 ASBC H..	
	db $41,$41,$44,$43,$20,$48,$CC,$8C	; $6C70 AADC H..
	db $07,$08,$41,$4C,$44,$20,$28,$03	; $6C78 ..ALD (.
	db $A9,$8C,$09,$4C,$C4,$4C,$81,$28	; $6C80 ...L.L.(
	db $03,$A9,$81,$4E,$45,$C7,$07,$05	; $6C88 ...NE...
	db $81,$52,$45,$54,$CE,$81,$52,$45	; $6C90 .RET..RE
	db $54,$C9,$9A,$49,$4D,$20,$B0,$A0	; $6C98 T..IM ..
	db $49,$4D,$20,$B1,$49,$4D,$20,$B2	; $6CA0 IM .IM .
	db $BA,$4C,$44,$20,$49,$2C,$C1,$4C	; $6CA8 .LD I,.L
	db $44,$20,$52,$2C,$C1,$4C,$44,$20	; $6CB0 D R,.LD 
	db $41,$2C,$C9,$4C,$44,$20,$41,$2C	; $6CB8 A,.LD A,
	db $D2,$52,$52,$C4,$52,$4C,$C4,$A0	; $6CC0 .RR.RL..
	db $A0					; $6CC8 ..L.C.I.

	;; Sequence for X=2, CLASS=2 (ED prefix) (block instructions)
DATA_S9:	
	db $1B,$4C,$C4,$43,$D0,$49,$CE		; $6CC9 ..L.C.I.
	db $4F,$D4,$BA,$A0,$A0,$A0,$A0,$C9	; $6CD0 O.......
	db $C4,$49,$D2,$44,$D2,$09,$49,$4E	; $6CD8 .I.D..IN
	db $C3,$84,$09,$44,$45,$C3,$84,$1C	; $6CE0 ...DE...
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


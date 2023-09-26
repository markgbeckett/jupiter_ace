	;; Z80 Disassembler, by Toni Baker, published in 'Mastering
	;; Machine Code on Your ZX Spectrum', Interface Publications Ltd
	;; (1983).
	;;
	;; Adapted to be portable to a range of Z80-based systems and
	;; commented to make easier to understand the program flow by
	;; George Beckett (2023)

	;; Z80 disassembler is based on an algorithm, as described in
	;; http://www.z80.info/decoding.htm, which enables a very
	;; compact implementation (in this case, a little under 1.5
	;; kilobytes). The in-line comments use naming convention in
	;; that description.
	;;
	;; The bits that make up the opcode byte (having first checked
	;; for any prefixes (CB, DD, ED, or FD) as follows:
	;;
	;; Bits in opcode (MSB -> LSB)
	;;  7   6   5   4   3   2   1   0
	;; <--x--> <----y----> <----z---->
	;;         <--p--><-q->

	;; 	jp START
	
	;; Table to enable blocks of similar instructions to be
	;; represented in a compact form
TYPES:
	;; 8-bit registers -- denoted "r" in description of algorithm
	db _B+$80
	db _C+$80
	db _D+$80
	db _E+$80
	db _H+$80
	db _L+$80
	db EXT_ADDR+$80
	db _A+$80

	;; Register pairs featuring SP -- denoted "rp" in description of
	;; algorithm
	db _B,_C+$80
	db _D,_E+$80
	db IND_ADDR+$80
	db _S,_P+$80
	db $00			; padding 

	;; Register pairs featuring AF -- denoted "rp2" in description
	;; of algorithm
	db _B,_C+$80
	db _D,_E+$80
	db IND_ADDR+$80
	db _A,_F+$80
	db $00			; padding
	
	;; Bit references for index operations -- not included in
	;; original version of algorithm, though denoted by "n" in this
	;; source code
	db _0+$80
	db _1+$80
	db _2+$80
	db _3+$80
	db _4+$80
	db _5+$80
	db _6+$80
	db _7+$80
	
	;; Conditions -- denoted "cc" in description of algorithm
	db _N,_Z+$80
	db _Z+$80
	db _N,_C+$80
	db _C+$80
	db _P,_O+$80
	db _P,_E+$80
	db _P+$80
	db _M+$80
	db $00,$00,$00,$00 	; padding

	;; Arithmetic/ logic operations -- denoted "alu" in description
	;; of algorithm
	db _A,_D,_D,_SPACE,_A,_COMMA+$80
	db _A,_D,_C,_SPACE,_A,_COMMA+$80
	db _S,_U,_B,_SPACE+$80
	db _S,_B,_C,_SPACE,_A,_COMMA+$80
	db _A,_N,_D,_SPACE+$80
	db _X,_O,_R,_SPACE+$80
	db _O,_R,_SPACE+$80
	db _C,_P,_SPACE+$80

	
	;; Table of jump addresses for the eight subroutines that
	;; encapsulate the key manipulations required for the algorithm
SUBRTS:	dw SPLIT
	dw LITERAL
	dw LIST_Y
	dw LIST_Z
	dw SELECT_Y
	dw SELECT_Z
	dw SKIP
	dw QSKIP

	;; Control sequence for different values of 'x' (and CB/DE
	;; prefix)
DATADS:	dw DATA_S0		; 'x' = 0
	dw DATA_S1		; 'x' = 1
	dw DATA_S2		; 'x' = 2
	dw DATA_S3		; 'x' = 3
	dw DATA_S4		; 'x' = 0, CB prefix
	dw DATA_S5		; 'x' = 1, CB prefix
	dw DATA_S6		; 'x' = 2, CB prefix
	dw DATA_S7		; 'x' = 3, CB prefix
	dw $0000		; Invalid op-code
	dw DATA_S8		; 'x' = 1, ED prefix
	dw DATA_S9		; 'x' = 2, ED prefix
	dw $0000              	; Invalid op-code

	
	;; 
	;; Replace current byte in DISS by a string of one or more bytes.
	;; 
	;; On entry:
	;;   HL - insert location in DISS
	;;   TOS - return address (TOS) contains address of counted
	;;         string to be substituted.
	;;
	;; On exit:
	;;   HL - new insert location in DISS
	;;   AF, DE, and IX - corrupted
	;; 
REPLACE:
	pop ix			; Retrieve pointer to string

	ld de,(DISS)		; Retrieve address of start of DISS

	;; Compute length of remaining string (to right of current
	;; location) which needs to be moved to allow insertion
	and a			; Reset carry
	sbc hl,de		; Compute length of string to left of
				; DE.  Assume answer is one byte long
				; (i.e., fits in L and H is zero)
	ld a,(de)		; Retrieve length of DISS
	sub l			; and compute length of remaining string
	inc a			; (inc. current byte)

	;; Insert space for replacement string
	push af			; Save length of string remainder
	ld a,(de)		; Retrieve length of DISS
	ld l,a			; Save it

	;; Update length of DISS (one less than length of replacement
	;; string)
	add a,(ix+0x00)		; Retrieve length of replacement string
	dec a			; Reduce by one
	ld (de),a		; and update length of DISS

	;; Set HL to point to end of DISS (L saved previously)
	add hl,de		; H should still be 0

	;; Compute end of new DISS (after insertion)
	ld e,(ix+0x00)		; Set DE to length of replacement
	ld d,0x00		; string
	push hl			; Save HL (end of original string)
	add hl,de		; Compute address of end of new string
	dec hl 			; One character is removed as part of
				; substitution
	ex de,hl		; Set DE to end of new string
	pop hl			; Restore HL (end of original string)

	;; Retrieve length of remainder of string into BC
	pop af			; Restore length

	push bc			; Save BC
	ld c,a			; Move length to BC
	ld b,0x00		; Effectively insert space into string

	;;  Move string tail to make space for insertion
	lddr

	;; Insert replacement text
	ex de,hl		; Set DE to insertion point for
	inc de			; insertiong string

	ld c, (ix+0x00)		; Retrieve length of insertion text
	ld b,0x00		; into BC

	;; Set HL to start of insertion text
	push ix
	pop hl
	inc hl			; HL is start of string to insertion
	
	ldir			; Insert new text into DISS

	ex de,hl		; DE points to byte after parameter
				; field for RETURN
	dec hl			; HL points to new, current location in
				; DISS
	
	pop bc			; Restore BC

	push de			; Push address of code past parameter
				; field, ready for return

	ret			; Jump to (DE)

	;; 
	;; Add character to the end of the current string, DIS
	;;
	;; On entry:
	;;   A - character to insert
	;;
	;; On exit:
	;;   All registers preserved
CHR:
	push af			; Save registers
	push bc
	push hl

	and %01111111		; Ignore bit 7

	ld hl,(DISS)		; Retrieve start of DIS

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

	;; 
	;; Print contents of BC in hex to screen
	;;
	;; On entry:
	;;   BC - number to print
	;;
	;; On exit:
	;;   A - corrupted
HP_BC:	ld a,b
	call HP_A
	ld a,c

	;; 
	;; Print contents of A in hex
	;; 
	;; On entry:
	;;   A - number to print
	;;
	;; On exit:
	;;   A - corrupted
HP_A:	push af			; Save A
	rra			; Isolate high nibble
	rra
	rra
	rra
	call HP_AL
	
	pop af			; Retrieve A

	;; 
	;; Print lower nibble of A in hex (generalised to cope with
	;; systems that do not use ASCII character coding (e.g., ZX80)
	;; 
HP_AL:
	and %00001111		; Isolate lower nibble
	add a,_0		; Assume is 0,...,9
	cp _9+1			; Check if actually A,...,F
	jr c, HP_CONT		; Jump forward if not

	add a,_A-_9-1		; Adjust for A,...,F
HP_CONT:
	call PRINT_A		; Print to display

	ret

	;; 
	;; Insert next byte (two characters) of subject program into DIS
	;; (HL) and advice pointer into object code
	;; 
INS:
	;; Retrieve number from BC' (current location in object code)
	exx
	ld a,(bc)
	inc bc
	exx

INS2:	
	push af			; Save A
	call INS_2		; Insert lower nibble
	pop af			; Restore A

	rra 			; Move upper nibble into lower nibble
	rra			; ready to be inserted
	rra
	rra
INS_2:	and 0x0F		; Isolate lower nibble

	;; Convert to character code
	add a, _0
	cp _9 + 1
	jr c,INS_CH
	add a, _A - _9 - 1

	;; Insert character
INS_CH:	ld (hl),a
	dec hl

	ret

RETURN:	bit 6,e			; Check if need to add comma to current
				; string
	jr z, NOCOMMA
	ld a, _COMMA
	call CHR		; Deposit character in DIS
NOCOMMA:
	bit 7,e			; Check if done (indicated by bit 7
				; being high)
	jp z, CONTROL

	;; Decode DIS and print final output
	;; 
	;; At this point:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to control sequence for particular 'x' and
	;;         CLASS
	;; - D   = current op-code
DECODE:	exx
	ld a,d			; Retrieve INDEX from DE'
	exx
	ld c,a			; ... and save it in C

	;; Point to start of DISS and retrieve length
	ld hl,(DISS)
	ld b,(hl)

DECODE_LP:
	inc hl
	ld a,(hl)
	sub EXT_ADDR
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
	db 0x06, _LEFTPARENTH, _I, _X, _PLUS, IMM_ADDR, _RIGHTPARENTH
	jr DECODE_2

DECODE_5:
	call REPLACE
	db 0x06, _LEFTPARENTH, _I, _Y, _PLUS, IMM_ADDR, _RIGHTPARENTH

DECODE_2:
	ld a,(hl)
	sub IND_ADDR
	jr nz, DECODE_4
	ld a,c			; Check INDEX
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
	sub IMM_ADDR
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

DECODE_8:
	dec a
	jr nz,DECODE_11

	call REPLACE
	defb $04,_NULL, _NULL, _NULL, _NULL
	
	call INS
	call INS

	inc hl
	inc hl

	jr DECODE_10
	
DECODE_11:
	dec a
	jr nz,DECODE_12

	;; Insert four spaces
	call REPLACE
	defb $04,_NULL, _NULL, _NULL, _NULL
	
	;; Retrieve relative address
	exx
	ld a,(bc)
	inc bc
	exx

	push bc
	
	ld c,a
	
	cp 0x80			; Check if positive or negative
	ccf
	sbc a,a
	ld b,a

	push hl
	
	exx
	push bc
	exx
	pop hl

	add hl,bc
	ld c,l
	ld b,h
	
	pop hl
	
	ld a,c
	call INS2

	ld a,b
	call INS2

	pop bc
	
	inc hl
	inc hl
	
DECODE_10:
	inc hl
	inc hl

DECODE_12:	
	djnz DECODE_LP_2
	ld hl,(DISS)
	ld b,(hl)
	
DECODE_LP_3:
	inc hl
	ld a,(hl)
	call PRINT_A
	djnz DECODE_LP_3
	jr RESTART

	;; 
	;; Entry point for disassembler
	;; 
START:	call INIT		; System-specific initialisation

	;; Retrieve ADDRESS into BC'
	exx
	ld bc, (ADDRESS)
	exx

	;; Next instruction
RESTART:
	ld hl,(DISS)		; Reset DISS string
	ld (hl),0x00

	;; Reset CLASS and INDEX (in D' and E', respectively)
	exx
	ld de, 0x0000
	exx
	
MAIN:	ld a,_CARRIAGERETURN	; Print newline
	call PRINT_A

	;; Print current address followed by space
	exx
	call HP_BC

	ld a,_SPACE
	call PRINT_A

	;; Retrieve next byte to disassemble and advance pointer
MAIN_LOOP_1:
	ld a,(bc)		; Retrieve next byte of program
	inc bc			; Advance pointer

	;; Retrieve status info
	push de			; D=INDEX; C=CLASS
	exx
	pop bc

	cp 0x76			; Test for HALT (special case, would
				; decode to ld (hl),(hl))

	jr nz, MAIN_CHECK_PREFIX

	;; Check if CLASS is 1 (then is not 'halt', but 'bit 6,(hl)'
	dec c			; Does not deal with case ED,76, which	
	jr z, MAIN_2		; is not a valid opcode

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
	
	;; Check for prefix codes
MAIN_2:	inc c			; Restore CLASS value

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
	;; Update DE' (long-term copy of CLASS and INDEX)
	push bc
	exx
	pop de

	jr MAIN_LOOP_1

	;; At this point:
	;; - A   = opcode of current instruction
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
MAIN_PROC_INST:
	ld d,a			; Save op code

	;; Extract 'x'
	and %11000000		; Isolate bit 7 and 6 
	or c			; Augment with CLASS
	
	rlca			; Bit 7 and 6 move to Bit 2 and 1,
	rlca			; respectively. Bit 1 and 0 move to 4
	rlca			; and 3, respectively

	;; At this point, A = 4*CLASS + x
	
	;; Work out offset into DATADS for appropriate command sequence
	ld c,a
	ld b,0x00
	ld hl, DATADS
	add hl, bc
	
	;; ld l,a
	;; ld h, (DATADS >> 8) & 0xFF		; 0x68

	;; Retrieve address of command sequence into BC
	ld c, (hl)
	inc hl
	ld b,(hl)

	;; Move address of sequence into HL'
	push bc
	exx
	pop hl
	exx
	
	;; At this point:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to control sequence for particular 'x' and
	;;         CLASS
	;; - D   = current op-code
CONTROL:			; Was called MASTER in original listing
	exx
	ld a, (hl)		; Retrieve next control command
	inc hl			; Advance control-sequence pointer
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

	;; At this point:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
	;; - BC  = address of control routine to call
	
	;; Jump to subroutine
	push bc
	ret

	;; Retrieve (z+1)'th address from list pointed to by HL' and load
	;; that address into HL'
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
SPLIT: 	ld a,d			; Retrieve op-code
	exx			; Save active registers

	;; Isolate lower three bits and multply by two to get offset to
	;; routine
	and %00000111
	rla

	;; Copy into DE (saving previous value first)
	push de
	ld e,a
	ld d,0x00

	;; Skip forward 'z' words in control sequence
	add hl,de

	;; Retrieve addresss into HL' (new location in control sequence)
	ld e,(hl)
	inc hl
	ld d,(hl)
	ex de,hl

	;; Restore previous value of DE
	pop de

	exx

	;; Done
	ret

	;; Append string from control sequence (terminated by character
	;; with bit 7 high) to DISS. If control data has bit 3 set,
	;; append a space to end of string
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
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

	;; Skip forward B lists, where list end is indicated by Bit 7
	;; being high in list entry
FIND_LP:
	ld a,(hl)
	inc hl
	rla
	jr nc, FIND_LP
	djnz FIND_LP

	ret

	;; Select (y+1)th entry in subsequent list of strings and append
	;; to DISS (each string terminates with character with bit 7
	;; set). Control byte data (bits 3,4, and 5) specify whether
	;; list has 4 or 8 entries.
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
LIST_Y: ld a,d			; Retrieve current op-code
	rra			; Rotate Y into bits 0, 1, and 2, then
	rra			; continue as for LIST_Z
	rra
	
	jr LIST_CONT
	
	;; Select (z+1)th entry in subsequent list of strings and append
	;; to DISS (each string terminates with character with bit 7
	;; set). Control byte data (bits 3,4, and 5) specify whether
	;; list has 4 or 8 entries.
	;;
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
LIST_Z:	ld a,d

LIST_CONT:	
	and %00000111		; Isolate index (lower three bits)
	call FIND		; Find corresponding string

LIST_LP:
	ld a,(hl)		; Retrieve next character from string
	inc hl			; Advance pointer
	call CHR		; Add to DISS
	rla			; Check if done
	jr nc, LIST_LP

	;; Update HL to point beyond string list
	ld a,e			; Retrieve length of list
	rra
	rra
	rra
	and %00000111
	inc a			; One more that number of strings
	call FIND		; Find end of list

	push hl			; Save it
	exx
	pop hl
	exx

	ret

	;; Insert string into DISS from one of the TYPES lists
	;; (determined by control data), as follows: -
	;;  000 - r(y)
	;;  001 - rp(y)
	;;  010 - rp2(y)
	;;  011 - n(y)
	;;  100 - cc(y)
	;;  101 - not used
	;;  110 - alu(y)
	;;  111 - not used
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
SELECT_Y:
	ld a,d			; Retrieve op code
	rra			; Move Y into bits 0,1, and 2
	rra
	rra
	jr SELECT_CONT		; Proceed as for SELECT_Z

	;; Insert string into DISS from one of the TYPES lists
	;; (determined by control data), as follows: -
	;;  000 - r(z)
	;;  001 - rp(z)
	;;  010 - rp2(z)
	;;  011 - n(z)
	;;  100 - cc(z)
	;;  101 - not used
	;;  110 - alu(z)
	;;  111 - not used
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
SELECT_Z:
	ld a,d			; Retrieve op code

SELECT_CONT:			
	and %00000111		; Isolate lower three bits

	push af

	ld a,e			; Retreive data from current control-
	and 0x38		; sequence command (conveniently,
				; already x8)
	
	ld c,a
	ld b,0x00
	ld hl,TYPES
	add hl,bc
	
	;; add a, TYPES & 0xFF
	;; ld l,a
	;; ld h, (TYPES >> 8) & 0xFF 
	pop af

	call SELECT

SELECT_LP:
	ld a,(hl)
	inc hl
	call CHR

	rla
	jr nc, SELECT_LP

	ret

	;; Subsequent step based on value of 'q' (0/1)
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
QSKIP:
	ld a,d			; Retrieve saved copy of Op Code
	rra			; Shift P right one bit (into Bits 4 and 5)
	and %00011000		; and isolate it (so A contains 'p'*8)
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
	
	;; Skip forward n bytes in control sequence is bit 5 of op-code
	;; is high (setting low first)
	;;
	;; On entry:
	;; - BC' = address of next byte in program
	;; - DE' = CLASS and INDEX
	;; - HL' = pointer to next value control sequence for particular
	;;         'x' and CLASS
	;; - D   = current op-code
	;; - E   = current control-sequence command
SKIP: 	bit 5,d			; Test value of p(1) 
	jr nz, SKIP_CONT	; If set, skip forward 'n' steps in sequence

	exx			; Otherwise, advance to next step in sequence
	inc hl 
	exx

	ret

SKIP_CONT:
	res 5,d			; Reset p(1)

	;; Skip forward 'n' bytes in control sequence
	exx

	push bc

	ld c,(hl)
	inc hl
	ld b,0x00
	add hl,bc

	pop bc

	exx

	ret

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
	db _D,_J,_N,_Z,_SPACE,REL_ADDR+$80	
	db _J,_R,_SPACE,REL_ADDR+$80
						; TERMINATE
	db $09,_J,_R+$80			; LITERAL (inc space)
	db $64					; SELECT-G (C(G)) (inc
						; comma)
	db $81, REL_ADDR+$80				; LITERAL
						; TERMINATE

DATA_S0b:	; 16-bit load immediate/ add
	db $07,$07		   	; K-SKIP
	db $09,_L,_D+$80		; LITERAL (inc space)
	db $4C				; SELECT-G (s(G))
	db $81,IMM_EXT_ADDR+$80			; LITERAL
					; TERMINATE
	db $00
	db $41,_A,_D,_D,_SPACE,IND_ADDR+$80	; LITERAL (inc comma) 
	db $8C				; SELECT-G (s(G))
					; TERMINATE

DATA_S0c:	; Indirect loads
	db $09,_L,_D+$80		   	; LITERAL (inc space)
	db $BA					; LIST-G(8) (10111010)
	db _LEFTPARENTH,_B,_C,_RIGHTPARENTH,_COMMA,_A+$80		; 
	db _A,_COMMA,_LEFTPARENTH,_B,_C,_RIGHTPARENTH+$80
	db _LEFTPARENTH,_D,_E,_RIGHTPARENTH,_COMMA,_A+$80
	db _A,_COMMA,_LEFTPARENTH,_D,_E,_RIGHTPARENTH+$80
	db _LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH,_COMMA,IND_ADDR+$80
	db IND_ADDR,_COMMA,_LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH+$80	
	db _LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH,_COMMA,_A+$80
	db _A,_COMMA,_LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH+$80

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
	db $81,IMM_ADDR+$80			; LITERAL
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
	db _J,_P,_SPACE,_LEFTPARENTH,IND_ADDR,_RIGHTPARENTH+$80
	db _L,_D,_SPACE,_S,_P,_COMMA,IND_ADDR+$80
				; TERMINATE

DATA_S3c:		; Conditional jumps
	db $09,_J,_P+$80	; LITERAL (inc. space)
	db $64			; SELECT-G(c(G)) (inc. comma)
	db $81,IMM_EXT_ADDR+$80		; LITERAL
				; TERMINATE

DATA_S3d: 		; Assorted operations
	db $BA				   ; LIST-G(8)
	db _J,_P,_SPACE,IMM_EXT_ADDR+$80
	db _SPACE+$80
	db _O,_U,_T,_SPACE,_LEFTPARENTH,IMM_ADDR,_RIGHTPARENTH,_COMMA,_A+$80
	db _I,_N,_SPACE,_A,_COMMA,_LEFTPARENTH,IMM_ADDR,_RIGHTPARENTH+$80
	db _E,_X,_SPACE,_LEFTPARENTH,_S,_P,_RIGHTPARENTH,_COMMA,IND_ADDR+$80
	db _E,_X,_SPACE,_D,_E,_COMMA,_H,_L+$80
	db _D,_I+$80
	db _E,_I+$80

DATA_S3e:		; Conditional call
	db $09,_C,_A,_L,_L+$80			; LITERAL (inc. space)
	db $64					; SELECT-G(c(G)) (inc. comma)
	db $81,IMM_EXT_ADDR+$80				; LITERAL
						; TERMINATE

	;; Sequence for X=3 and Z=5 (CALL or PUSH)
DATA_S3f:		; PUSH and various ops
	db $07,$06 				; KSKIP 6 
	db $09,_P,_U,_S,_H+$80			; LITERAL (inc. space)
	db $94					; SELECT-G (s(G))
						; TERMINATE
	db $81,_C, _A, _L, _L, _SPACE,IMM_EXT_ADDR+$80	; LITERAL
						; TERMINATE

DATA_S3g:			; Operate on accumulator and immediate
				; operand
	db $34					; SELECT-G(x(G))
	db $81,IMM_ADDR+$80				; LITERAL
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
	db $41,_L,_D,_SPACE,_LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH+$80
 						; LITERAL (inc comma)
	db $8C					; SELECT-G(s(G))
						; TERMINATE
	db $09,_L,_D+$80	; LITERAL (inc space)
	db $4C			; SELECT-G(s(G)) (inc comma)
	db $81,_LEFTPARENTH,IMM_EXT_ADDR,_RIGHTPARENTH+$80
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

	;; Z80 implementation of the popular Commodore scrolling-maze
	;; example, for the Jupiter Ace/ Minstrel 4th, written as part
	;; of an investigation into the differences between Z80 and 6502
	;; processors
	;;
	;; Source code should be straightforward to assemble with any
	;; modern Z80 assembler. I have used Z80ASM
	;; (https://savannah.nongnu.org/projects/z80asm).
	;; 
	;; Routine is written to be inserted into the parameter field of
	;; a dictionary entry created with `CREATE SCRCODE 128 ALLOT`
	;; (word name is not important). You should set the origin to
	;; the address of the SCRCODE parameter field -- that is, value
	;; returned by `SCRCODE .`.
	;;
	;; 128 bytes is ample space for the source code as is, though
	;; you may need to create more space if you extend the routine
	;; significantly. The size of the routine can be checked by
	;; calculating END-MAIN below.
	;;
	;; The routine assumes the two graphics characters to be printed
	;; (corresponding to diagonal lines from top-left to
	;; bottom-right or vice versa, in the Commodore character set)
	;; are stored in characters 2 and 3. These can defined in FORTH
	;; using something like:
	;;
	;; ```
	;; 1 2 4 8 16 32 64 128 2 GR
	;; 128 64 32 16 8 4 2 1 3 GR
	;; ```
	;;
	;; --where GR is defined on page 71 of the Jupiter Ace FORTH
	;; Programming guide.
	;;  
	;; Written by George Beckett, 2024

	org 0x3C8C		; Address of code block for SCRCODE in
				; dictionary

DISP:	equ 0x2400		; Start of Jupiter Ace display buffer
ROW:	equ 0x20		; Length of a row on Ace display

MAIN:	di			; Disable interrupts to ensure
				; consistent timing
	call SCROLL		; Scroll screen up and randomly fill
				; bottom row
	jr MAIN			; Infinite loop (reset to stop)

	;; Scroll screen one row up and fill bottom row with random maze
	;; characters
SCROLL:
	;; Scroll lines 2--24 up by one using a block transfer
	ld de, DISP		; (10)
	ld hl, DISP+ROW		; (10)
	ld bc, 23*ROW		; (10)

	ldir			; (736*21 + 16 = 15,472 (profiler says 15,461))

	;; Fill bottom row with random characters (code 2 or 3)
SCROLL2:
	ld de, DISP+23*ROW	; Start of bottom row
	ld b, ROW		; Length of row

LOOP:	ld c, 02		; Character

	push bc			; Store counter and character
	call RAND16		; Generate random number
	pop bc			; Retrieve counter and character

	rra			; Bit 7 of A used to determine which
				; character to display
	jr nc,SKIP		; If 0, print character 2
	inc c			; Otherwise, character 3

SKIP:	ld a,c			; Print to screen 
	ld (de),a		
	inc de 			; Advance to next column
	djnz LOOP		; Repeat if not done

	ret			; Done
	
	;; Pseudo-random-number generator, ported from 6502
	;; implementation. You can get 8-bit random numbers in A or
	;; 16-bit numbers in SEED.
	;;
	;; Requires 116 clock cycles
	;; 
	;; See
	;; https://codebase64.org/doku.php?id=base:16bit_xorshift_random_generator
RAND16:
	ld hl,SEED+1		; (10)
	srl (hl)		; (15)
	dec hl			; (6)
	ld a,(hl)		; (7)
	rra			; (4)
	inc hl			; (6)
	xor (hl)		; (7)
	ld (hl),a		; (7)
	rra			; (4)
	dec hl			; (6)
	xor (hl)		; (7)
	ld (hl),a		; (7)
	inc hl			; (6)
	xor (hl)		; (7)
	ld (hl),a		; (7)

	ret			; (10)

SEED:	dw 0x0001
	
END:	

	;; Port of Multitech Micro-Professor (MPF-I) 2K Monitor Program
	;; to the Minstrel 4th

START:	equ 0x8000		; Locate to upper RAM for testing
	
	org START		; Locate to upper RAM for now

	;; Core monitor loop: updates display, reads keyboard and actions
	;; valid key entries.
MAIN:	ld sp, SYSSTK		; Initialise system stack
	call SCAN		; Scan display and input keys

	call BEEP

	jr MAIN

	;; Scan the keyboard and display. Loop until a key is detected.
	;; Ignore any key being pressed, when routine is called.
	;;
	;; Input:
	;;         IX - buffer containing display pattern
	;;
	;; Output:
	;;         A - code of key being pressed
	;; Corrupted:
	;;         F, B, HL, AF', BC', DE'
SCAN:	push ix			; Save

	;; Check for illegal key entry
	ld hl, TEST
	bit 7,(hl)
	jr z, SCPRE		; Skip foward, if no illegal key
	ld ix,BLANK

	;; Wait until no keys pressed for a few milliseconds
SCPRE:	ld b,4
SCNX:	call SCAN1
	jr nc, SCPRE		; Key pressed, so start countdown again

	djnz SCNX
	res 7,(hl)		; Clear error flag
	
	pop ix			; Restore message address

	;; Wait for key press
SCLOOP:	call SCAN1
	jr c, SCLOOP

;; 	;; Convert keypress to internal code format
;; KEYMAP:	ld hl, KEYTAB
;; 	add a,l
;; 	ld l,a
;; 	ld a,(hl)
	
	ret

BEEP:	ret

	;; Check for key press
SCAN1:	ret

	
	;; System RAM area

	;; Aim for org START+0x1F9F
	ds START + 0x1F9F - $
USERSTK:			; User stack
	ds 0x10
SYSSTK:				; System stack

ADSAVE:	ds 02			; Record for current memory address
TEST:	ds 01			; Flag:
	                        ;    b0 - function/ subfunction key
				;    b7 - illegal key entered

BLANK:	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

	;; Parameters
XMODEM_SOH:	equ 0x01
XMODEM_EOT:	equ 0x04
XMODEM_ACK:	equ 0x06
XMODEM_NAK:	equ 0x15
XMODEM_BS:	equ 0x80
CTRL_PORT:	equ 0x80
DATA_PORT:	equ 0x81

	org 0xf800		      ; Start at 63,488 (dec)
	
	;; Receive byte from serial port
	;; On entry:
	;;     B = no. seconds before timeout
	;; On exit,
	;;     Carry Flag Set - Timed out
	;;     Carry Flag Clear - A = value read
	;;     Always - B, DE corrupt
	
RECV:	ld de, 0xBBBB		; Equiv. of 1 second
CHECKR:	xor a
	in a,(CTRL_PORT)	; Check if byte ready
	and 0x01		; Bit zero set, if so
	jr nz, READ_BYTE
	dec de
	ld a,d
	or e
	jr nz, CHECKR
	djnz CHECKR

	scf			; Set carry, to indicate timeout

	ret
READ_BYTE:
	xor a
	in a, (DATA_PORT)
	and a 			; Reset carry, to indicate success
	ret
	
	;; Send byte to serial port
	;; On entry:
	;;     A = byte to send
	;; On exit,
	;;     Carry Flag Set - Timed out
	;;     Carry Flag Clear - Success
	;;     Always - AF, BC corrupted
	
SEND:	ld bc, 0xBBBB		; Maximum retries
	push af			; Save byte to send
CHECKS:	xor a			; Check if ready to send
	in a, (CTRL_PORT)
	bit 1,a

	jr nz, SEND_BYTE
	dec bc
	ld a,b
	or c
	jr nz, CHECKS

	pop af			; Balance stack
	scf

	ret			; Set carry, to indicate timeout

SEND_BYTE:
	pop af			; Recover byte to send
	out (DATA_PORT),a	; Send byte
	and a			; Reset carry, to indicate success
	ret

	;; Send block of 128 bytes, w/ checksum, in line with
	;; XMODEM protocol
	;; 
	;; On entry:
	;;   A  - Sector number to send
	;;   HL - Address of block to send
	;; 
	;; One exit:
	;;   Carry Flag Set - Timed out (or other error)
	;;   Carry Flag clear - Send completed and acknowledged
SEND_BLOCK:
	;; Send header information
	push hl			; Save start address
	push af			; Save Sector number

	;; Report send
	ld hl, SECTMSG
	call PRINT_MSG
	pop af			; Retrieve block number
	pop hl			; Restore block address
	push af			; Store block number
	add a,'0'		; Transform to ASCII
	rst 0x08
	ld a, 0x0d
	rst 0x08
	ld a, XMODEM_SOH
	call SEND
	
	pop af			; Restore Sector number
	push af			; Save Sector number
	call SEND
	
	pop af			; Restore Sector number
	cpl			; Work out 0xFF - reg_A
	call SEND
	
	xor a			; Reset checksum
	ld e,a			; and store in reg_E
	ld b, XMODEM_BS		; Size of payload to be sent
	
SB_LOOP:
	ld c,(hl)		; Retrieve byte to send
	inc hl
	ld a,e
	add a,c			; Update checksum
	ld e,a			; Save it
	ld a,c
	push bc
	call SEND
	pop bc
	djnz SB_LOOP		; Loop to send next byte

	;; Send checksum
	ld a,e
	call SEND

	;; Get acknowledgement
	ld b,4			; Wait for up to four seconds
	call RECV

	;; Check for error
	ret c 			; Carry set indicates error

	cp XMODEM_ACK		; If successful, carry flag clear
	ret nc

	scf			; Otherwise, indicate fail
	ret

	;; Print status message to console
	;; On entry:
	;; 	HL points to start of message
	;; On exit:
	;; 	A, HL, and alternative registers are corrupt
	;; 
PRINT_MSG:
	ld a, (hl)
	and a			; Null byte indicates end of message
	ret z
	inc hl
	push hl
	rst 0x08
	pop hl
	jr PRINT_MSG
	
TEST:	
	ld a,1			; Block number
	ld hl,0x0000		; Start of block to send
	ld b,5			; Number of retries
TEST_LOOP:
	push bc
	call SEND_BLOCK
	pop bc
	jr nc, TEST_CONT_1
	djnz TEST_LOOP
TEST_CONT_1:
	ld a, XMODEM_EOT
	call SEND

	jp (iy) 		; Return to FORTH

	
SECTMSG:
	db "SENDING SECTOR ", 0x00
	
END:	

	;; Serial interface parameters
CTRL_PORT:	equ 0x80
DATA_PORT:	equ 0x81
RTS_LOW:	equ 0x16 	; Clock div: +64, 8+1-bit
RTS_HIGH:	equ 0x56	; Clock div: +64, 8+1-bit
RESET:		equ 0x57	; 8+1-bit, interrupt off, RTS low
	
	;; XMODEM protocol parameters
XMODEM_SOH:	equ 0x01
XMODEM_EOT:	equ 0x04
XMODEM_ACK:	equ 0x06
XMODEM_NAK:	equ 0x15
XMODEM_BS:	equ 0x80

	;; Miscellaneous params
CR:		equ 0x0d
	
	org 0xf800		      ; Start at 63,488 (dec)
	
	;; (Non-blocking) receive byte from serial port
	;; 
	;; On entry:
	;; 	None
	;; On exit,
	;;     	Carry Set 	- No data
	;;     	Carry Clear 	- A, value read
	;;     	Always 		- A' corrupt
	
RECV:	ld a, RTS_LOW		; Set RTS low
	out (CTRL_PORT),a  	; Confirm ready to receive

	in a,(CTRL_PORT)	; Check if byte ready
	and 0x01		; Bit zero set, if so

	jr nz, READ_BYTE

	scf			; Set carry, to indicate timeout
	ret
	
READ_BYTE:
	in a, (DATA_PORT)	; Read byte
	
	ex af,af'		; Save character
	ld a, RTS_HIGH		; Set RTS high
	out (CTRL_PORT),a	; Hold receiver
	pop af

	ex af,af'		; Restore character
	
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
	add a,'0'		; Transform to ASCII (assume 1-digit)
	rst 0x08
	ld a, CR
	rst 0x08
	
	;; Send header
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
	ld bc,0x8000		; Number of retries

SB_LOOP_2:
	call RECV

	jr nc, SB_CONT

	dec bc
	ld a, b
	or c
	jr nz, SB_LOOP_2

	scf			; Carry set indicates error

	ret  

SB_CONT:	
	cp XMODEM_ACK		; If successful, carry flag clear
	ret z

	scf			; Otherwise, indicate fail
	ret

RX:
	call RECV
	
	jr c, RX_NO_BYTE

	ld e,a
	ld d,0
	rst 0x10

	jp (iy)
	
RX_NO_BYTE:
	ld de, 0xffff
	
	rst 0x10

	jp (iy)

TX:
	ld DE,0x0000
	call SEND

	jr c,TX_NO_SEND

	rst 0x10
	jp (iy)

TX_NO_SEND:
	dec DE

	rst 0x10
	jp (iy)
	
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

	;; Paramaters
CTRL_PORT:	equ 0x80
DATA_PORT:	equ 0x81


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

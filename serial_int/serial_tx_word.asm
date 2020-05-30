	;; TX ( <VALUE> -- <FLAG> )
	;; 
	;; Transmit byte via serial interface
	;; 
	;; On entry:
	;;   VALUE = value to send (low byte only)
	;; 
	;; On exit:
	;;   FLAG = 0x0000 (Byte transmitted)
	;;   FLAG = 0xFFFF (Operation timed out)

MAX_RETRY: EQU 10000

TX:	rst 0x18		; Pop stack into DE
	push de			; Save value to be transmitted
	ld bc, MAX_RETRY

CHECK_SEND:
	xor a
	in a, (0x80)		; Check status
	bit 1,a			; Still tranmitting?

	jr nz, SEND_BYTE

	dec bc			; Decrement timeout counter
	ld a,b
	or c
	jr nz, CHECK_SEND

	pop de			; Balance stack
	ld de, 0xFFFF		; Indicates time-out
	rst 0x10		; Push DE onto stack
	jp (iy)			; Return to FORTH

SEND_BYTE:
	pop de			; Retrieve byte to send
	ld a,e			; Low byte is sent
	out (0x81), a		; Transmit byte
	ld de, 0x0000		; Indicates success
	rst 0x10		; Push DE onto stack
	jp (iy)			; Return to Forth
TX_END:	

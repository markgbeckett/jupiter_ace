	;; RX ( -- <VALUE> )
	;; 
	;; Receive byte via serial interface
	;; 
	;; On entry:
	;; 
	;; On exit:
	;;   VALUE = 0x00NN (Byte received)
	;;   VALUE = 0xFFFF (Operation timed out, NN nonsense)
	
	include "serial_comm.asm"

RX:	
	xor a	
	in a, (0x80)
	and 0x01

	jr nz, READ_BYTE

	ld de, 0xFFFF		; Indicate no date available
	rst 0x10		; Push DE onto stack
	jp (iy)			; Return to FORTH

READ_BYTE:
	xor a
	in a, (0x81)		; Read byte

	ld e,a
	xor a
	ld d,a

	rst 0x10		; Push DE onto stack
	
	ld a, RTS_HIGH
	out (0x80), a		; Indicate read

	jp (iy)			; Return to FORTH
RX_END:	

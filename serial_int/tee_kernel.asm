	;; Routine to echo screen to serial device
	;; On entry, A contains the character to send
TEE_KERNEL:
	ld b,a			; Save character
	xor a
	in a, (0x80)		; Check if read to submit
	and 0x02
	ld a,b
	jr z, NO_SEND_BYTE

	out (0x81),a
	
NO_SEND_BYTE:
	jp 0x03ff		; Back to ROM routine
TEE_KERNEL_END:	

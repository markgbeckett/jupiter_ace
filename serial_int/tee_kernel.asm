	;; TEE_KERNEL 
	;; 
	;; M/code routine for Minstrel 4th/ Jupiter Ace, to echo
	;; screen output to RC2014 serial card.
	;;
	;; Accessed from ROM print routine, by setting system variable
	;; EXSRCH to the address of the entry point TEE_KERNEL.
	;; 
	;; On entry, A contains the character to send. Serial card must
	;; previously have been initialised.
	
TEE_KERNEL:
	ld b,a			; Save character
	xor a
	
	in a, (0x80)		; Check if ready to transmit
	and 0x02
	
	ld a,b			; Restore character
	jr z, DONE		; Exit, if serial device not ready

	cp 0x0D			; Check for CR (as needs LF)

	out (0x81),a		; Transmit character

	jr nz, DONE		; If not CR, then done
	
	ld a, 0x0A		; Transmit LF 
	out (0x81),a		; (We assume device is still ready)

	ld a, 0x0D		; Restore CR for ROM printing
DONE:
	jp 0x03ff		; Back to ROM printing routine
TEE_KERNEL_END:	

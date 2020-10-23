	;; Routine to check clock speed of system
	;; Runs counter loop until an interrupt is detected
	;; (based on a change in value of FRAMES). An iteration of 
	;; the loop takes 25 T states (plus 7 T states for
	;; initialisation so (allowing 300 T-states for interrupt service
	;; routine), a 3.25 MHz clock should return around 2,500
	;; iterations, whereas a 6.5 MHz clock should return around 5,300
	;; iterations on a 50 Hz set-up.
	;;
	;; CHECKCLOCK ( -- ITERS )
	
	org 0x8000		; Code is relocatable, so can go anywhere
	
FRAMES:	equ 0x3c2b		; Lowest byte of clock in Sys Variables

START:	ld de, 0x0000		; Reset counter
	ld hl, FRAMES		
	halt			; Synchronise to interrupt
	ld a, (hl)		; Save initial FRAMES value
LOOP:	inc de			; Increment counter
	cp (hl)			; See if FRAMES has changed
	jr z, LOOP		; It not, loop again

	rst 0x10		; Push DE onto Forth stack

	jp (iy)			; Return to FORTH
END:	

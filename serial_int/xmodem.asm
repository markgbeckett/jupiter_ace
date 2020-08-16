	;; Serial interface parameters
CTRL_PORT:	equ 0x80
DATA_PORT:	equ 0x81
RESET:		equ 0x03	; Reset the serial device
RTS_LOW:	equ 0x16 	; Clock div: +64, 8+1-bit
RTS_HIGH:	equ 0x56	; Clock div: +64, 8+1-bit
RECV_RETRY:	equ 0x1000	; Retry count for RECV op
SEND_RETRY:	equ 0x1000	; Retry count for SEND op
	
	;; XMODEM protocol parameters
XMODEM_SOH:	equ 0x01
XMODEM_EOT:	equ 0x04
XMODEM_ACK:	equ 0x06
XMODEM_NAK:	equ 0x15
XMODEM_BS:	equ 0x80
XMODEM_MAX_RETRY:	equ 0x08

ERROR_TO:	equ 0xF0
ERROR_PE:	equ 0xF1
	
	;; Minstrel System Variables
FLAGS:	equ 0x3c3e

	;; Miscellaneous params and workspace
CR:		equ 0x0d
LF:		equ 0x0a
	
LAST_PACKET: 	equ 0x2701	; Temporary store for length of last
				; packet in PAD
CURR_PACKET: 	equ 0x2702	; Temporary story for packet number
				; in PAD
	
	OUTPUT "xmodem.bin"
	
LINK = #3c49		     		; Link field of word 'FORTH'
	include forth-word-macro.asm 	; Auto-generate headers
	
	org 0x3c51	      ; Immediately after word 'FORTH'

	;; FORTH header for library routines
.name:
        ABYTEC 0 "XMODEM"	; Name field
.name_end:
        dw XMODEM_END - .name_end ; Length field
        dw LINK			; Link field
        SET_VAR LINK, $		; Update link for next word
        db .name_end - .name	; Name-length
        dw 0x0fec		; Indicates a CREATE word
	
	;; ========================================================
	;; (Part-blocking) receive byte from serial port
	;;
	;; On entry:
	;;      None
	;;
	;; On exit:
	;;      Carry Flag	- Timed out, no data
	;;     	Carry Clear 	- A, value read
	;;     	Always 		- BC corrupt
	;; ========================================================
RECVW:	ld bc, RECV_RETRY
	
RECVW_LOOP:
	call RECV
	ret nc

	dec bc
	ld a,b
	or c

	jr nz, RECVW_LOOP

	scf
	ret
	
	;; ========================================================
	;; (Non-blocking) receive byte from serial port
	;; 
	;; On entry:
	;; 	None
	;; On exit,
	;;     	Carry Set 	- No data
	;;     	Carry Clear 	- A, value read
	;;     	Otherwise	- A corrupt
	;; ========================================================
	
RECV:	ld a, RTS_LOW		; Set RTS low
	out (CTRL_PORT),a  	; Confirm ready to receive

	in a,(CTRL_PORT)	; Check if byte ready
	and 0x01		; Bit zero set, if so

	jr z, RECV_NO_BYTE	; No data available

	ld a, RTS_HIGH		; Set RTS high
	out (CTRL_PORT),a	; Hold receiver

	in a, (DATA_PORT)	; Read byte
	
	and a 			; Reset carry, to indicate success

	ret

RECV_NO_BYTE:	
	ld a, RTS_HIGH
	out (CTRL_PORT),a
	
	scf			; Set carry, to indicate timeout

	ret

	;; ========================================================
	;; Part-blocking send byte to serial port
	;; 
	;; On entry:
	;;     A = byte to send
	;; 
	;; On exit,
	;;     Carry Set 	- Timed out
	;;     Carry Clear 	- Success
	;;     Always 		- AF, BC corrupted
	;; ========================================================

SENDW:	ld bc, SEND_RETRY	; Maximum retries
	
	push af			; Save byte to send

SENDW_CHECK:
	xor a			;
	in a,(CTRL_PORT)	; Check if ready to send
	and 0x02		;

	jr nz, SEND_BYTE	; Ready to send
	
	dec bc			; Try again
	ld a,b
	or c
	jr nz, SENDW_CHECK

	pop af			; Balance stack
	
	scf			; Indicates time-out

	ret
	
SEND_BYTE:
	pop af			; Retrieve data to send
	out (DATA_PORT),a
	
	and a			; Indicates success	
	
	ret

	;; ========================================================
	;; Send packet of 128 bytes, w/ checksum, in line with
	;; XMODEM protocol
	;; 
	;; On entry:
	;;   A  - Packet number to send
	;;   HL - Address of block to send
	;; 
	;; One exit:
	;;   Carry Set 		- Timed out (or other error)
	;;   Carry Clear 	- Send completed and acknowledged
	;; ========================================================

SEND_BLOCK:
	push af			; Store packet number

	;; Send header
SB_CONT_3:
	ld a, XMODEM_SOH
	call SENDW
	
	pop af			; Restore packet  number
	push af			; Save packet number
	call SENDW
	
	pop af			; Restore Sector number
	cpl			; Work out 0xFF - reg_A
	call SENDW
	
	xor a			; Reset checksum
	ld e,a			; and store in reg_E
	
	ld b, XMODEM_BS		; Size of payload to be sent
	
SB_LOOP:
	ld c,(hl)		; Retrieve byte to send
	inc hl			; Advance to next location
	
	ld a,e			; 
	add a,c			; Update checksum
	ld e,a			; 
	
	ld a,c			; 
	push bc			; 
	call SENDW		; Send byte
	pop bc			;
	
	djnz SB_LOOP		; Loop to send next byte

	;; Send checksum
	ld a,e
	call SENDW

	;; Get acknowledgement
	ld bc,0x8000

SB_LOOP_2:	
	call RECV

	jr nc, SB_CONT		; Byte received

	dec bc			;
	ld a,b			; Try again
	or c			;
	jr nz,SB_LOOP_2		;

	scf			; Indicates failure
	
	ret			

SB_CONT:	
	cp XMODEM_ACK		; Check for acknowledgement
	ret z			; If successful, carry flag clear

	scf			; Otherwise, indicate fail
	
	ret

	;; ========================================================
	;; Print contents of A register as a two-digit hex number
	;; On entry:
	;; 	A contains value to be printed
	;; On exit:
	;; 	A and alternate registers corrupted
	;; ========================================================

PRINT_HEX:	
	push af
	srl a			; Shift high nibble into low nibble
	srl a
	srl a
	srl a
	call PRINT_DGT
	pop af			; Retrieve number
	and 0x0F		; Isolate low nibble
PRINT_DGT:
	cp 0x0a			; Is it higher than '9'
	jr c, PRINT_CNT		; If not, skip forward
	add a, 0x07		; Correction for letters
PRINT_CNT:
	add a, '0'		; Convert to ASCII code
	rst 0x08		; Print it
	ret			; Return to next digit or calling routine

	;; ========================================================
	;; Print status message to console
	;; On entry:
	;; 	HL points to start of message
	;; On exit:
	;; 	A, HL, and alternative registers are corrupt
	;; ========================================================
PRINT_MSG:
	ld a, (hl)		; Retrieve next character
	
	and a			; Null byte indicates end of message
	ret z
	
	inc hl			; Advance to next character

	rst 0x08		; Print it

	jr PRINT_MSG		; Next

	;; ========================================================
	;; Messages
	;; ========================================================
SECTMSG:
	db "SENDING SECTOR ", 0x00
RECVMSG:
	db "RECEIVE SECTOR ", 0x00
ERRMSG:	
	db "SEND FAILED ", 0x00
OKAYMSG:
	db "SEND COMPLETE ", 0x00
EOTMSG:	db "EOT RECEIVED", 0x00
SOHMSG:	db "SOH RECEIVED", 0x00
NORMSG:	db "NO RESPONSE", 0x00
PCKMSG:	db "PACKET ERROR", 0x00
NOPMSG:	db "WRONG PACKET", 0X00

	;; ========================================================
	;; Attempt to read an XMODEM packet via serial interface
	;; Packet consists of 132 bytes, as follows:
	;; - SOH
	;; - packet number
	;; - 255-packet number
	;; - 128 bytes of data
	;; - 8-bit checksum
	;;
	;; On entry:
	;; 	a - initiation byte for retrieving packet (ACK/ NAK)
	;;      de - destination address for payload of packet
	;;
	;; On exit
	;; 	Carry reset 	- success
	;; 			- A=SOH / EOT
	;;                      - L=packet number
	;; 			- DE=one past last address written to
	;; 	Carry set 	- failure
	;; 			- B = 132 - bytes read
	;; 			- A=error code
	;; ========================================================
GET_BLOCK:
	call SENDW		; Transmit initiation code to sender (corrupts AF and BC)

	;; Get header
	call RECVW
	jr c, GB_TO
	
	cp XMODEM_EOT		; Is it end-of-transmission?
	ret z			; If so, done

	cp XMODEM_SOH		; Is it start-of-header
	jr nz, GB_PE		; If not packet error

	;; Read in packet number
	call RECVW
	jr c, GB_TO
	
	ld l,a			; Save it

	;; Read complement
	call RECVW
	jr c, GB_TO

	cpl			; Compute 255-A
	cp l			; Compare to packet number
	jr nz, GB_PE		; If not matching, packet error

	;; Read payload
	push de			; Save original value of DE
	ld b, 0x80		; 128 bytes in XMODEM packet
	ld c, 0			; Zero checksum
GB_LOOP:	
	push bc			; Save counter
	call RECVW		; Read next byte (corrupts AF and BC)
	pop bc			; Retrieve counter

	jr nc, GB_SAVE_BYTE
	pop de			; Restore start address of block
	jr GB_TO		; Exit, if timed out

GB_SAVE_BYTE:	
	ld (de),a		; Store byte read
	inc de			; Move to next address
	add a, c		; Update checksum
	ld c,a
	
	djnz GB_LOOP		; Repeat if more data expected

	;; Get checksum
	inc sp			; Discard old value of DE
	inc sp
	
	push bc			; Save checksum
	call RECVW		; Retrieve sender copy of checksum
	pop bc			; Retrieve checksum

	jr c, GB_TO

	cp c			; Compare to computed checksum

	jr nz, GB_PE		; Packet error if no match
	
	;; Done
	ld a, XMODEM_SOH	; Indicates full packet read
	and a			; Reset carry flag
	
	ret
	
GB_TO:
	ld A, ERROR_TO		; Indicates timout
	scf			; Indicate error
	ret

GB_PE:
	ld A, ERROR_PE		; Indicates packet error
	scf
	ret

	;; ========================================================
	;; Discard any stale data in buffer
	;;
	;; On entry
	;;   --
	;;
	;; On exit
	;;   A and BC corrupt
	;; ========================================================
DRAIN_SENDER:
	call RECVW
	jr nc, DRAIN_SENDER	; Read whole packet

	ret

	;;  End of library word
XMODEM_END:
	

	;; ========================================================
	;; Reset Serial interface and configure for 8-bit and
	;; 1 stop bit, RTS high to indicate not ready; serial-card
	;; interuupts off
	;; 
	;; On entry
	;;   --
	;; 
	;; On exit
	;;   --
	;; ========================================================
w_sreset:
	FORTH_WORD "SRESET"
	ld a, RESET
	out (CTRL_PORT),a	; Reset serial device

	ld a, RTS_HIGH
	out (CTRL_PORT),a	; +64; 8 bits+1 stop; RTS high; no int

	jp (iy)			; Return to FORTH
.word_end:
	
	;; ========================================================
	;; Attempt to receive a byte from serial interface
	;;
	;; On entry:
	;;   --
	;;
	;; On exit:
	;;   TOS  	- byte read (-1, if no data)
	;; ========================================================
w_rx:
	FORTH_WORD "RX"
	ld de, 0xffff

	call RECV
	
	jr c, .cont		; No byte received

	ld e,a
	ld d,0
.cont:	
	rst 0x10

	jp (iy)
.word_end:
	
	;; ========================================================
	;; Send a byte from serial interface
	;;
	;; On entry:
	;;   TOS	- byte to be sent
	;;
	;; On exit:
	;;   TOS	- Status (0=success; -1=fail)
	;; ========================================================
W_TX:
	FORTH_WORD "TX"
	rst 0x18		; Retrieve value from stack to DE
	ld a,e
	
	ld de,0x0000
	
	call SENDW

	jr nc,.cont		; Jump forward if success
	dec de			; DE = -1, if failed
.cont:	
	rst 0x10
	jp (iy)
.word_end:
	
	;; ========================================================
	;; Receive a block of memory via serial interface, using
	;; XMODEM protocol
	;;
	;; On entry:
	;;   TOS 	- address to which to write data
	;; 
	;; On exit:
	;;   TOS 	- error code (0000 indicates success)
	;; ========================================================
W_XBGET:
	FORTH_WORD "XBGET"

	ld a,(FLAGS)		; If VIS, move print posn to new line
	bit 4,a
	jr nz, .cont0
	ld a, CR
	rst 0x08

.cont0	
	di 
	;; Drain any stale data
	call DRAIN_SENDER	; Corrupts A
	
	;; Initialise packet number
	ld hl, 0x0000
	ld (CURR_PACKET),hl
	
	rst 0x18		; Retrieve TOS into DE

	;; Send initiation string
	ld a, XMODEM_NAK	; Initiate transfer with NAK

.next_packet	
	ld bc, (CURR_PACKET)	; Expect next packet
	inc bc
	ld (CURR_PACKET),bc

	ld b,XMODEM_MAX_RETRY
.loop
	;; Print block-receive information
	ld l,a
	ld a,(FLAGS)
	bit 4,a
	ld a,l
	jr nz, .cont2

	;; Log receive
	push af
	push hl
	
	ld hl,RECVMSG
	call PRINT_MSG
	
	ld a,(CURR_PACKET)
	call PRINT_HEX
	
	ld a, CR
	rst 0x08
	
	pop hl
	pop af

.cont2
	push bc
	call GET_BLOCK 
	pop bc

	jr nc, .cont4		; Skip forward if successful
	
	cp ERROR_PE		; Check for Packet Error
	jr z, .pe		; Jump forward if so,

.to	
	ld a,(FLAGS)
	bit 4,a
	jr nz,.err

	;; Log receive
	ld hl,NORMSG
	call PRINT_MSG
	
	ld a, CR
	rst 0x08
	
	jr .err
	
.pe	
	ld a,(FLAGS)
	bit 4,a
	jr nz,.err

	;; Log receive
	ld hl,PCKMSG
	call PRINT_MSG
	
	ld a, CR
	rst 0x08
	
	jr .err

.wp	
	ld a,(FLAGS)
	bit 4,a
	jr nz,.err

	;; Log receive
	ld hl,NOPMSG
	call PRINT_MSG
	
	ld a, CR
	rst 0x08
	
	;; jr RECV_ERR
	
.err
	push bc
	call DRAIN_SENDER
	pop bc
	
	ld a, XMODEM_NAK
	djnz .loop		; If not max retry, try again

	;; Otherwise error
	ld de, 0xFFFF		; Indicates failure
	rst 0x10		; Push onto FORTH stack

	ei
	
	jp (iy)
	
.cont4	
	;; Check for EOT
	cp XMODEM_EOT
	jr z, .done
	
	;; Check is correct packet
	ld a,(CURR_PACKET)
	cp l

	jr nz, .wp

	;; Confirm packet received
	ld a, XMODEM_ACK

	jp .next_packet

.done
	ld a,XMODEM_ACK		; Acknowledge receipt
	call SENDW
	
	ld de, 0x0000		; Indicates success
	rst 0x10

	ei
	
	jp (iy)
.word_end
	
	;; ========================================================
	;; Send a block of memory via serial interface, using XMODEM
	;; protocol
	;;
	;; On entry:
	;;   2OS - Address of start of block
	;;   TOS - Length of block
	;; On exit:
	;;   TOS - error code (0000 indicates success)
	;; ========================================================
W_XBPUT:
	FORTH_WORD "XBPUT"
	ld a,(FLAGS)		; If VIS, move print posn to new line
	bit 4,a
	jr nz, .cont0
	ld a, CR
	rst 0x08

.cont0	
	rst 0x18		; Retrieve TOS into DE

	;; Work out number of packets to send. Instead of dividing
	;; by 128, we multiple by 2 and ignore lowest byte.
	xor a			; Multiple DE by 2, leaving
	sla e			; result in ADE
	rl d
	rla

	;; Transfer number of packets to BC
	ld b,a
	ld c,d

	;; Check for remainder
	ld a,e
	srl a			; Divide by 2
	and a
	jr z, .cont1
	inc bc			; One extra packet for remainder

.cont1
	ld (LAST_PACKET),a	; Store for later

	;; Initialise packet number
	ld hl, 0x0000		; XMODEM starts packet count at 1
	                        ; though value incremented at
	                        ; beginning of each send opp
	ld (CURR_PACKET),hl	; Store for later
	
	;;  Retrieve start of block into HL
	rst 0x18
	ld h,d
	ld l,e
	
	;; Move no. blocks to DE
	ld d,b
	ld e,c
	
	;; At this point:
	;;     HL = start
	;;     DE = no packets
	;;     CURR_PACKET = packet number

	;; Wait for NAK (need to add test for break, to prevent
	;; infinite loop)
.start:
	call RECV
	jr c, .cont2	; No response
	cp XMODEM_NAK
	jr nz, .cont1
	jr .loop
.cont2:	
	dec bc
	ld a,b
	or c
	jr nz, .start

.loop:
	;; Increase current packet
	ld bc,(CURR_PACKET)
	inc bc
	ld (CURR_PACKET),bc
	
	ld b,XMODEM_MAX_RETRY	; Number of retries
.loop2
	push de
	push hl
	push bc

	;; Print block-sending information
	ld a,(FLAGS)		; Check if VIS enabled
	bit 4,a
	jr nz, .cont3

	;; Log send to screen
	push hl
	ld hl, SECTMSG
	call PRINT_MSG
	ld a, (CURR_PACKET)
	call PRINT_HEX
	ld a, CR
	rst 0x08
	pop hl
	
.cont3	
	ld a,(CURR_PACKET)	; Low byte of CURR_PACKET value
	call SEND_BLOCK
	pop bc
	jr nc, .cont5		; Succeeded, so move on
	pop hl			; Otherwise, retry send
	pop de
	djnz .cont2		; If not at maximum retries

	;; Abandon transfer and report error
	ld a,(FLAGS)
	bit 4,a
	jr nz, .cont4

	ld hl, ERRMSG
	call PRINT_MSG
	ld a, CR
	rst 0x08

.cont4
	ld de, 0xFFFF		; Indicate error
	rst 0x10		; Push onto FORTH stack

	jp (iy)			; Return to FORTH
	
.cont5
	pop de 			; Effectively discard old value of HL
	pop de			; Retrieve no. packets left to transmit

	dec de			; Decrease no. packets to send
	ld a,d			; Check if we are done
	or e
	
	jr nz, .loop		; If not, loop back for next packet

	;;  If done, indicate End of Transfer
	ld a, XMODEM_EOT	
	call SENDW

	;; Confirm success
	ld a,(FLAGS)
	bit 4,a
	jr nz, .cont6

	ld hl, OKAYMSG
	call PRINT_MSG
	ld a, CR
	rst 0x08

.cont6:
	ld de,0x0000		; Indicates success
	rst 0x10		; Push onto stack

	jp (iy) 		; Return to FORTH
.word_end:

END:	
	DISPLAY "1. Set SPARE (0x3C3B) to be ", END + 0x0c
	DISPLAY "2. Set STACKBOT (0x3C37) to be ", END
	DISPLAY "3. Load code block to 0x3C51"	
	DISPLAY "4. Set 0x3C4C to be ", W_XBPUT + 0x09
	DISPLAY "5. Set DICT (0x3C39) to be ", W_XBPUT + 0x05
	DISPLAY "6. Set ", W_XBPUT + 0x05, " to be 0x0000"
	OUTEND

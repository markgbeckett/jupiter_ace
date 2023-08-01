	;; -------------------------------------------------------------
	;; JUPITER ACE 'CASSETTE INTERFACE' ROUTINES
	;;
	;; Disassembled by George Beckett, July 2023.
	;; -------------------------------------------------------------

	;; -------------------------------------------------------------
	;; Save bytes to tape
	;;
	;; On entry:
	;;   HL - address of start of block to save (header at 2301h)
	;;   DE - length of block (header length is 19h)
	;;   C  - 00h = header; FFh = code block
	;;
	;; On exit:
	;;   HL - corrupted
	;; 
	;; (Usually) in routine:
	;;   A - used to hold bit pattern for tape port
	;;   IY - address of next byte to save
	;;   DE - length of data left to save
	;;   B - counter for timing routines
	;;   C - bit pattern to alternate tape outout
	;;   H - current checksum 
	;;   L - current byte to save
	;; -------------------------------------------------------------
L1820:  PUSH    IY		; Save IY

        PUSH    HL		; Move start address for block
        POP     IY		; into IY

        LD      HL,L1892	; Set return address to 
        PUSH    HL		; clean-up routine

	;; Set HL for header (FC00h) or code block (E000h) to length
	;; of leader tone. Length is based on 10000h - HL
        LD      HL,$E000	; E000h is for code block
        BIT     7,C		; Check if header or code block
        JR      Z,L1832		; Skip forward if header
        LD      H,$FC		; Adjust length, if code block

	;; Save one more byte than block length (for block type)
L1832:  INC     DE		
        DEC     IY

	;; Interrupts off to ensure precise timing
        DI

	;; 
	;; Send tape pilot tone (typical half wavelength is 2017 T
	;; states)
	;; 
        XOR     A	; (4) Bit pattern for tape port (0xFE, bit 3)

	;; Pause for 1,965 T states
L1837:  LD      B,$97		; (7) 97h = 151d
L1839:  DJNZ    L1839           ; (13/8)

	OUT     ($FE),A		; (11) Output to tape port
        XOR     %00001000	; (7) Alternate bit 3 of Port 0xFE bit pattern
	                        ; i.e., off-to-on or on-to-off

	;; INC HL, setting Z flag as appropriate
        INC     L		; (4)
        JR      NZ,L1843        ; (12/7) Assume do not jump direct to
				; L1837 to maintain timing
        INC     H		; (4)
L1843:  JR      NZ,L1837        ; (12/7) Repeat if non-zero

	;;  At this point, A=0 and HL=0, and tape output is high

	;;
	;; Send sync signal (high part is 601 T states and low part is
	;; 791 T states)
	;;

	;; Pause for 561 T states
	LD      B,$2B		; (7)
L1847:  DJNZ    L1847           ; (13/8)

	;; Set tape output low
        OUT     ($FE),A		; (11) Bit 3 = 0 
        LD      L,C		; (4) Move header/ block indicator to L
        LD      BC,$3B08	; (10) Set counter in B, and bit pattern
				; for 0xFE (bit 3 on)

	;; Pause for 762 T states
L184F:  DJNZ    L184F           ; (13/8)

	;; Output to tape port
        LD      A,C		; (4) Set tape output high
        OUT     ($FE),A         ; (11) bit 3 on

	;; Set timing for next signal
        LD      B,$38		; (7) Wait time for a '1'
        JP      L188A           ; (10)

	;; Entry point for second half of waveform for bit transmit
L1859:  LD      A,C		; (4) Set tape output to high
        BIT     7,B		; (7) Set zero flag (for second half of wave)

	;; Entry point for first half of waveform for bit transmit
L185C:  DJNZ    L185C           ; (13/8) Wait for B=38h loops

        JR      NC,L1864	; (12/7) Jump forward if '0' bit

        LD      B,$3D		; (7) Extend wait for '1' bit
L1862:  DJNZ    L1862           ; (13/8) Note: does not affect Z flag

L1864:  OUT     ($FE),A		; (11) Set tape output to low/high
        LD      B,$3A		; (7) New wait time (+1)?

        JP      NZ,L1859	; (10) Jump back if half-way through bit
				; transmit
        DEC     B		; (4) Reduce first-half wait for new bit
        XOR     A		; (4) Set tape output low
L186D:  RL      L		; (4) Move next bit into carry (and reset zero)
        JP      NZ,L185C        ; (11) Jump if more data to send?

	;; Next byte
        DEC     DE		; (6) Reduce length of block 
        INC     IY		; (10) Move to next address to send
        LD      B,$2E		; (7)

	;; Check if Break pressed
        LD      A,$7F		; (7)
        IN      A,($FE)		; (11)
        RRA			; (4)
        RET     NC		; (11/5) Return if Carry reset, via cleanup
				; routine

	;; Check if done (including sending the checksum); DE = FFFFh
        LD      A,D		; (4)
        CP      $FF		; (7)
        RET     NC		; (11/5) Return, Carry reset

	;; Check if all data sent
        OR      E		; (4) Check if DE=0000h (A = D)
        JR      Z,L188F         ; (12/7) Move to send checksum

	;; Retrieve next byte to send and prepare to send first bit
        LD      L,(IY+$00)	; (19)

	;; Update checksum
L1887:  LD      A,H 		; (4)
        XOR     L		; (4)
        LD      H,A		; (4)
	
L188A:  XOR     A		; (4) Set tape output low and set zero
        SCF			; (4) Set marker for end of byte
        JP      L186D           ; (10) Jump back

; ---

	;; Save checksum, at end of block
L188F:  LD      L,H		; (4)
        JR      L1887           ; (12)

	;; 
	;; Exit routine (accessed by pushing L1892 onto stack, so return
	;; is via this routine)
	;; 
L1892:  POP     IY              ; (14) restore the original IY value
                                ; so that words can be used
                                ; gain.
        EX      AF,AF'          ; (4) Save flag

	;;
	;; Send end marker
	;;
	
	;; Tape output is high. Wait for 13*58+8 = 762 T states 
        LD      B,$3B          	; (7)
L1897:  DJNZ    L1897           ; (13/8) self-loop for delay.

	;; Set tape output low
        XOR     A		; (4)
        OUT     ($FE),A		; (11)

	;; Check for break
        LD      A,$7F           ; (7) read the port $7FFE
        IN      A,($FE)         ; (11) keyrows SPACE to V.
        RRA			; (4)
        EI                      ; (4) Enable Interrupts.

        JP      NC,L04F0        ; (10) jump if SPACE pressed to Error 3
                               	; 'BREAK pressed'.

        EX      AF,AF'          ; (4) Restore flags
        RET                     ; (10) Done

	;; -------------------------------------------------------------
	;; Read bytes from tape
	;;
	;; On entry:
	;;   HL - destination address to write data to (header = 231Ah)
	;;   DE - number of bytes to read (header = 19h)
	;;   C - 00h = header; FFh = code block
	;;   Carry Flag - Set = Load; Reset = Verify
	;; 
	;; On exit:
	;;   Carry - Set = Success; Reset = Error
	;;   AF, AF', BC, DE, HL - corrupted
	;; -------------------------------------------------------------
	
L18A7:  DI			; Disable interrupts for accurate timing

        PUSH    IY		; Save IY and move destination address
        PUSH    HL 		; into IY
        POP     IY

        LD      HL,L1892	; Set return address to be clean-up
        PUSH    HL 		; routine

        LD      H,C		; H indicates header or code block
        EX      AF,AF'          ; save user-supplied carry
        XOR     A
        LD      C,A		; Target signal indicator

L18B5:  RET     NZ

L18B6:  LD      L,$00		; Reset Counter for reading pilot tone

	;; Attempt to read in pilot tone (following loop is repeated 256
	;; times)
L18B8:  LD      B,$B8		; (7) Timer 
        CALL    L1911           ; (17) Read one wave length (high/ low)
        JR      NC,L18B5        ; (12/7) Try again, if fails

	;; Check length of pilot tone wavelength, which should be
	;; approximately 4022 T states. Wavelength accepted if more than
	;; ($DF-B8-1)*59 + 776 + 65 = 3,083 T-states.
        LD      A,$DF		; (7)
        CP      B		; (4) Is B > $DF?
        JR      NC,L18B6        ; (12/7) Waveform too short, so start
				; again

        INC     L		; (4) Increase counter
        JR      NZ,L18B8        ; (12/7) Check for 256 successive
				; confirmed pilot tones, in which case
				; move on to look for sync tone.

	;; Attempt to read half of sync tone
L18C7:  LD      B,$CF		; Reset timer
        CALL    L1915           ; Read half waveform
        JR      NC,L18B5        ; Start again if fails

	;; Check length of half of sync tone < ($D8-$CF-1)*59 + 344 = 816 T
	;; states)
        LD      A,B
        CP      $D8
        JR      NC,L18C7        ; Wait for next waveform if too long
				; (assume still receiving pilot tone)

	;; Read second half of sync tone (do not worry about length)
        CALL    L1915		; Read second half of waveform
        RET     NC		; Throw error, if fails at this point

	;; Read block-type byte into L (Z will be set if block type is
	;; correct. H previously contains required block type, which is
	;; zeroed by checksum update, if is correct)
L18D7:	CALL    L18FC           ; Read byte from tape port
        RET     NC		; Indicates failure
        CCF			; Reset carry flag
        RET     NZ		; Return if not right block-type

        JR      L18F0		; Jump forward to load header/ code
				; block

	;; Check user-supplied Carry Flag and either load or verify byte
	;; read
L18DF:  EX      AF,AF'		; Retrieve user-supplied flags
        JR      NC,L18E7        ; Jump forward, if verify
        LD      (IY+$00),L	; Write byte to memory
        JR      L18EC           ; Continue to next byte

	;; Check byte read against value in memory
L18E7:  LD      A,(IY+$00)
        XOR     L
        RET     NZ		; Return if not equal

L18EC:  INC     IY		; Increment address
        DEC     DE		; and decrement byte count
        EX      AF,AF'		; Save user-supplied flag

L18F0:  CALL    L18FC           ; Read byte from tape port

        RET     NC		; Exit, if error (NC = fail)

	;; Check if done (DE = 0)
        LD      A,D
        OR      E
        JR      NZ,L18DF        ; Loop back to next byte

        LD      A,H		; Checksum should be 00h, so carry will
        CP      $01		; be set if so
	
L18FB:  RET

	;; -------------------------------------------------------------
	;; Read eight bits from tape port into L (bit 7 read first,
	;; followed by bit 6, and so on, reading bit 0 last).
	;; 
	;; On entry:
	;;   C - expected waveform -- %0001000 = high/ low ; %00000000 =
	;;       low/ high
	;;   H - current checksum 
	;;
	;; On exit:
	;;   Carry Set - Success; Carry Reset - Failed
	;;   L - byte read
	;;   H - updated checksum
	;;   A, B - corrupted
	;; -------------------------------------------------------------

L18FC:  LD      L,$01		; (7) Set marker bit to confirm when done
L18FE:  LD      B,$C7		; (7) Set initial timing/ timeout

        CALL    L1911           ; (17) Measure wavelength of next waveform
        RET     NC		; (11/5) Return if failed

	;; Timing is based on 776 + (E2h-C7h-1)*59 = 2,310 T states
	;; (plus 54 T states for cost of processing each bit). Wavelegth
	;; for '0' should be approx 1,596 T states and wavelength for
	;; '1' should be approx 3,176 T states. Midpoint between two is
	;; 2,366 T states. B value of E3h means wavelength no less than
	;; 2,365 T states and B value of E2h means wavelength no more
	;; than 2,384 T states.
        LD      A,$E2		; (7) If B>$E2, then interpret as '1',
        CP      B		; (4) otherwise '0': this is
				; automatically reflected in Carry

	;; Rotate bits read and check for end marker
        RL      L		; (4) Rotate carry into next bit
        JP      NC,L18FE	; (10) Loop back if not done. Assume
				; using JP for consistent timing?

	;; Update checksum
        LD      A,H		; (4)
        XOR     L		; (4)
        LD      H,A		; (4)

	;; Confirm success
        SCF			; (4)
	
        RET			; (10)

	;; -------------------------------------------------------------
	;; Measure length of one period / half period of a tonal wave
	;; from tape port. Entry point is L1911 for full wave or L1915
	;; for half wave.
	;;
	;; On entry:
	;;   B - initial value of timer (also specifies timeout)
	;;   C (bit 4) - first output level to check (0=low; 1=high)
	;; 
	;; On exit
	;;   B - length of whole/ half waveform read (relative to
	;;       initial value)
	;;   C - next output level (0=low; 1=high)
	;;   Carry - True = success; False = fail
	;;   A - corrupted
	;;
	;; Timing:
	;;   Half wave - approx 344 + 59*(B_out - B_in - 1) T states,
	;;               plus any time in the calling routine since last
	;;               time tape port was read.
	;;   Full wave - approx 776 + 59*(B_out - B_in - 1) T states,
	;;               plus any time in the calling routine since last
	;;               time tape port was read.
	;; -------------------------------------------------------------
L1911:  CALL    L1915		; (17) Routine is executed twice for
				; full waveform
        RET     NC		; (11/5) Return if measure of first half
				; of waveform failed

	;; 
	;; Measure length of half of waveform
	;;

	;; Pause of 7 + (20-1)*16 + 11 = 322 T states
L1915:  LD      A,$14		; (7)
L1917:  DEC     A		; (4)
        JR      NZ,L1917	; (12/7) Timing loop

        AND     A		; (4) Reset carry flag

	;; Iteration of following loop has runtime of 59/ 54 T states,
	;; ignoring failure modes
L191B:  INC     B		; (4) Increase counter
        RET     Z		; (11/5) Exit, if timed out

	;; Read tape signal (and check for break)
        LD      A,$7F		; (7) Port 0x7FFE is bottom right row of
				; keyboard
        IN      A,($FE)		; (11) Read (keyboard and) tape port
        RRA			; (4) Rotate status of Space into
				; Carry. Also moves tape port from bit 5
				; to bit 4
        RET     NC		; (11/5) Exit if Space pressed

        XOR     C		; (4) C contains expected input level
				; (bit 4), so bit 4 will be reset if
				; level continues
        AND     %00010000	; (7) Check if signal has changed (NZ = yes)
        JR      Z,L191B		; (12/7) Loop again, if not

        LD      A,C		; (4) Flip expected input level
        CPL			; (4)
        LD      C,A		; (4)
	
        SCF			; (4) Indicates success/ good to proceed
				; with measuring second half of waveform
	RET			; (10)

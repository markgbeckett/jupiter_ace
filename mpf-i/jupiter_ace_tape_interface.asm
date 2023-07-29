; ---------------------------------
; THE 'CASSETTE INTERFACE' ROUTINES
; ---------------------------------
; ---
; tape???
; ---

	;; Save bytes to tape
	;;
	;; On entry:
	;;   HL - address of start of block to save (header at 2301h)
	;;   DE - length of block (header length is 19h)
	;;   C  - 00h = header; FFh = code block
	;;
	;; On exit:
	;;
	;; (Usually) in routine:
	;;   A - used to hold bit pattern for tape port
	;;   IY - address of next byte to save
	;;   DE - length of data left to save
	;;   B - counter for timing routines
	;;   C - bit pattern to alternate tape outout
	;;   H - current checksum 
	;;   L - current byte to save
L1820:  PUSH    IY		; Save IY

        PUSH    HL		; Move start address for block
        POP     IY		; into IY

        LD      HL,L1892	; Set return address to 
        PUSH    HL		; clean-up routine

	;; Set HL for header (FC00h) or code block (E000h) to length
	;; of leader tone. Length is based on 10000h - HL
        LD      HL,$E000	; E000 is for code block
        BIT     7,C		; Check if header or code block
        JR      Z,L1832		; Skip forward if header
        LD      H,$FC		; Adjust length, if code block

	;; Save one more byte than block length
L1832:  INC     DE		
        DEC     IY

	;; Interrupts off to ensure precise timing
        DI

	;; 
	;; Send tape leader tone
	;; 
        XOR     A		; Bit pattern for tape poirt (0xFE, bit
				; 3)

	;; Pause for 1,965 T states
L1837:  LD      B,$97		; (7) 97h = 151d
L1839:  DJNZ    L1839           ; ( 150*13+8 )

	;;  
	OUT     ($FE),A		; Update tape port
        XOR     $08		; Alternate bit 3 of Port 0xFE bit pattern
	                        ; i.e., off-to-on or on-to-off
	;; Inc HL but setting Z flag
        INC     L		; (4)
        JR      NZ,L1843        ; (12/7)
        INC     H		; (4)
L1843:  JR      NZ,L1837        ; (12/7) Repeat if non-zero

	;;  At end of this code, A = 0 and HL=0

	;;
	;; Send sync signal
	;;

	;; Tape output is high at this point
	;; Pause for 561 T states
	LD      B,$2B		; (7) $2B = 43
L1847:  DJNZ    L1847           ; (13*42+8)

	;; Set tape output low
        OUT     ($FE),A		; (11) Bit 3 = 0 
        LD      L,C		; (4) Move header/ block indicator to L
        LD      BC,$3B08	; (10) Set counter in B, and bit pattern
				; for 0xFE (bit 3 on)

	;; Pause for 762 T states
L184F:  DJNZ    L184F           ; (13*58 + 8)

	;; Output to tape port
        LD      A,C		; (4) Set tape output high
        OUT     ($FE),A         ; (11) bit 3 on

	;; Set timing for next signal
        LD      B,$38		; Wait time for a '1'
        JP      L188A           ;

	;; Entry point for second half of waveform for bit transmit
L1859:  LD      A,C		; Set tape output to high
        BIT     7,B		; Set zero flag (for second half of wave)

	;; Entry point for first half of waveform for bit transmit
L185C:  DJNZ    L185C           ; Wait for B=38h loops

        JR      NC,L1864	; Jump forward if '0' bit

        LD      B,$3D		; Extend wait for '1' bit
L1862:  DJNZ    L1862           ;

L1864:  OUT     ($FE),A		; Set tape output to low/high
        LD      B,$3A		; New wait time (+1)?

        JP      NZ,L1859	; Jump back if half-way through bit
				; transmit
        DEC     B		; Reduce first-half wait for new bit
        XOR     A		; Set tape output low
L186D:  RL      L		; Move next bit into carry (and reset zero)
        JP      NZ,L185C        ; Jump if more data to send?

	;; Next byte
        DEC     DE		; Reduce length of block 
        INC     IY		; Move to next address to send
        LD      B,$2E

	;; Check if Break pressed
        LD      A,$7F
        IN      A,($FE)
        RRA
        RET     NC		; Return if Carry reset, via cleanup
				; routine

	;; Check if done (including sending the checksum); DE = FFFFh
        LD      A,D
        CP      $FF
        RET     NC		; Return, Carry reset

	;; Check if all data sent
        OR      E		; Check if DE=0000h (A = D)
        JR      Z,L188F         ; Move to send checksum

	;; Retrieve next byte to send and prepare to send first bit
        LD      L,(IY+$00)

	;; Update checksum
L1887:  LD      A,H 	
        XOR     L	
        LD      H,A	
	
L188A:  XOR     A		; Set tape output low and set zero
        SCF			; Set marker for end of byte
        JP      L186D           ; JUMP back

; ---

	;; Save checksum, at end of block
L188F:  LD      L,H
        JR      L1887                   ;

	;; 
	;; Exit routine (accessed by pushing L1892 onto stack, so return
	;; is via this routine)
	;; 
L1892:  POP     IY              ; restore the original IY value
                                ; so that words can be used
                                ; gain.
        EX      AF,AF'          ; Save flag

	;;
	;; Send end marker
	;;
	
	;; Tape output is high. Wait for 13*58+8 = 762 T states 
        LD      B,$3B                   ; (7)
L1897:  DJNZ    L1897                   ; (13/8) self-loop for delay.

	;; Set tape output low
        XOR     A
        OUT     ($FE),A

	;; Check for break
        LD      A,$7F                   ; read the port $7FFE
        IN      A,($FE)                 ; keyrows SPACE to V.
        RRA
        EI                              ; Enable Interrupts.

        JP      NC,L04F0                ; jump if SPACE pressed to Error 3
                                	; 'BREAK pressed'.

        EX      AF,AF'                  ; Restore flags
        RET                             ; Done

; ---
; READ BYTES FROM TAPE
; ---

L18A7:  DI
        PUSH    IY
        PUSH    HL
        POP     IY
        LD      HL,L1892
        PUSH    HL
        LD      H,C
        EX      AF,AF'                  ; save carry
        XOR     A
        LD      C,A

L18B5:  RET     NZ

L18B6:  LD      L,$00
L18B8:  LD      B,$B8

        CALL    L1911                   ;

        JR      NC,L18B5                ;

        LD      A,$DF
        CP      B
        JR      NC,L18B6                ;

        INC     L
        JR      NZ,L18B8                ;

L18C7:  LD      B,$CF

        CALL    L1915                   ;

        JR      NC,L18B5                ;

        LD      A,B
        CP      $D8
        JR      NC,L18C7                ;

        CALL    L1915                   ;
        RET     NC

        CALL    L18FC                   ;
        RET     NC

        CCF
        RET     NZ

        JR      L18F0                   ;

; ---

L18DF:  EX      AF,AF'
        JR      NC,L18E7                ;
        LD      (IY+$00),L
        JR      L18EC                   ;

; ---

L18E7:  LD      A,(IY+$00)
        XOR     L
        RET     NZ

L18EC:  INC     IY
        DEC     DE
        EX      AF,AF'

L18F0:  CALL    L18FC                   ;

        RET     NC

        LD      A,D
        OR      E
        JR      NZ,L18DF                ;

        LD      A,H
        CP      $01
L18FB:  RET

; ---

L18FC:  LD      L,$01
L18FE:  LD      B,$C7

        CALL    L1911                   ;

        RET     NC

        LD      A,$E2
        CP      B
        RL      L
        JP      NC,L18FE                ;

        LD      A,H
        XOR     L
        LD      H,A
        SCF
        RET

; ---

L1911:  CALL    L1915                   ;
        RET     NC

L1915:  LD      A,$14
L1917:  DEC     A

        JR      NZ,L1917                ;

        AND     A

L191B:  INC     B
        RET     Z

        LD      A,$7F
        IN      A,($FE)
        RRA
        RET     NC

        XOR     C
        AND     $10
        JR      Z,L191B                 ;

        LD      A,C
        CPL
        LD      C,A
        SCF
        RET

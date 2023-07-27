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
	
L1820:  PUSH    IY		; Save IY

        PUSH    HL		; Move start address for block
        POP     IY		; into IY

        LD      HL,L1892	; Set return address to 
        PUSH    HL		; clean-up routine

	;; Set HL for header (FC00h) or code block (E000h) to length
	;; of leader tone. Length is based on 10000h - HL
        LD      HL,$E000	; E000 is for code block
        BIT     7,C		; Check if header or code block ?
        JR      Z,L1832		; Skip forward if header
        LD      H,$FC

	;; Save one more byte than block length
L1832:  INC     DE		
        DEC     IY

	;; Interrupts off for timing
        DI

	;; 
	;; Send tape leader tone
	;; 
        XOR     A		; Bit pattern for 0xFE (bit 3)

L1837:  LD      B,$97
L1839:  DJNZ    L1839                   ;

	;;  
	OUT     ($FE),A		; Update tape port
        XOR     $08		; Alternate bit 3 of Port 0xFE bit pattern
	                        ; i.e., off-to-on or on-to-off
	;; Inc HL but setting Z flag
        INC     L
        JR      NZ,L1843                ;
        INC     H
L1843:  JR      NZ,L1837                ; Repeat if non-zero
	;;  At end of this code, A = 0 and HL=0

	;;
	;; Now move on to data
	;;

	;; Pause for ??? T states
	LD      B,$2B
L1847:  DJNZ    L1847                   ;

	;; Write to tape output
        OUT     ($FE),A		; Bit 3 = 0 
	
        LD      L,C		; Move header/ block indicator to L

        LD      BC,$3B08	; Set counter in B, and bit pattern
				; for 0xFE (bit 3 on)

	;; Pause for ??? T states
L184F:  DJNZ    L184F           

	;; Output to tape port
        LD      A,C
        OUT     ($FE),A

	;;  *** GOT THIS FAR ***
        LD      B,$38
        JP      L188A                   ;

L1859:  LD      A,C
        BIT     7,B

L185C:  DJNZ    L185C                   ;

        JR      NC,L1864                ;

        LD      B,$3D
L1862:  DJNZ    L1862                   ;

L1864:  OUT     ($FE),A
        LD      B,$3A
        JP      NZ,L1859                ;
        DEC     B
        XOR     A
L186D:  RL      L
        JP      NZ,L185C                ;
        DEC     DE
        INC     IY
        LD      B,$2E

        LD      A,$7F
        IN      A,($FE)
        RRA
        RET     NC

        LD      A,D
        CP      $FF
        RET     NC

        OR      E
        JR      Z,L188F                 ;

        LD      L,(IY+$00)
L1887:  LD      A,H
        XOR     L
        LD      H,A
L188A:  XOR     A
        SCF
        JP      L186D                   ; JUMP back

; ---

L188F:  LD      L,H
        JR      L1887                   ;

L1892:  POP     IY                      ; restore the original IY value so that
                                        ; words can be used gain.

        EX      AF,AF'                  ;;
        LD      B,$3B                   ;

L1897:  DJNZ    L1897                   ; self-loop for delay.

        XOR     A
        OUT     ($FE),A

        LD      A,$7F                   ; read the port $7FFE
        IN      A,($FE)                 ; keyrows SPACE to V.
        RRA
        EI                              ; Enable Interrupts.

        JP      NC,L04F0                ; jump if SPACE pressed to Error 3
                                        ; 'BREAK pressed'.

        EX      AF,AF'                  ;;
        RET                             ; return.

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

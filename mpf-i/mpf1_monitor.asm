;*********************************************************
;*                                                       *
;*    COPYRIGHT , MULTITECH INDUSTRIAL CORP. 1981        *
;*    All right reserved.                                *
;*    No part of this software may be wopied without     *
;*    the express written consent of MULTITECH           *
;*    INDUSTRIAL CORP.                                   *
;*                                                       *
;*********************************************************
;
; Disassembed with z80dasm 1.1.5 at 2020-12-12
; and original comments copied by hand, fjkraan@electrickery.nl
; Assembled with z80pack/z80asm/z80asm -fh -v -l mpf1_u6_monitor.asm
; Reconstructed version v0.4

BASE:	equ 0x0000
UMEM:	equ 0x4000

	;; Load in Jupiter Ace character set encoding
	include "..\3d_monster_maze\jupiter_chars.asm"
P8255:		equ		0FFh	;8255 I control port
DIGIT:		equ		0FFh	;8255 I port C
SEG7:		equ		0FFh	;8255 I port B
KIN:		equ		0FFh	;8255 I port A
PWCODE:		equ		0A5h	;Power-up code
ZSUM:		equ		71h	;This will make the sum of all
					;monitor codes to be zero.
;

COLDEL:		equ		201		;
							;
F1KHZ:		equ		255		;
							;
F2KHZ:		equ		124		;
							;
MPERIOD:	equ		42		;
							;
; 

ONE_1K:		equ		4
ONE_2K:		equ		4
ZERO_1K:	equ		2
ZERO_2K:	equ		8

; 
;                                       p 1

	org	BASE

l0000h:
	ld b,000h
l0002h:
	djnz l0002h
	;
	ld a,090h
	out (P8255),a
	;
	ld a,0c0h
	out (DIGIT),a
	ld sp,SYSSTK
;                                       p 2

	ld a,(POWERUP)
	cp 0a5h
	call nz,INIM		; Minstrel ROM initialisation
	;
	ld hl,UMEM
	call RAMCHK
	jr z,PREPC
	ld h,080h
	
PREPC:
	ld (USERPC),hl
	ld h,000h
	;
	jr RESET1
	;
RST28:	
	;; org 28h
	;
	ex (sp),hl	
	dec hl	
	ex (sp),hl	
	ld (HLTEMP),hl
	jr CONT28
	;
RST30:	
	;; org	30h
	jr NMI
;                                       p 3

RESET1:
	ld (USERIF),hl
	jr RESET2

	ld (hl),c		; ROM checksum
	;
	
RST38:	
	;; org 38h
;
	push hl	
	ld hl,(09feeh)
	ex (sp),hl	
	;
	ret	
	
CONT28:
	ld (ATEMP),a
	;
	ld hl,(BRAD)
	ld a,(BRDA)
	ld (hl),a
;                                       p 4
	
	ld a,10000000B ; 080h
	out (002h),a
	ld a,(ATEMP)
	ld hl,(HLTEMP)
	nop	
	ret	
	
RESET2:
	ld hl,USERSTK
	ld (USERSP),hl
	xor a	
	ld (TEST),a
	ld ix,MPF_I
	jp SETSTO
;
	;; 	org	66h
	ds BASE+0x66-$
NMI:
	ld (ATEMP),a
	ld a,10010000B ; 090h
	out (P8255),a
	ld a,0c0h
	out (DIGIT),a
	ld a,(ATEMP)
RGSAVE:	ld (HLTEMP),hl
	pop hl	
	ld (ADSAVE),hl
	ld (USERPC),hl
	ld hl,(HLTEMP)
	ld (USERSP),sp
	ld sp,USERIY+2
	push iy
;                                       p 5

	push ix
	exx	
	push hl	
	push de	
	push bc	
	exx	
	ex af,af'	
	push af	
	ex af,af'	
	push hl	
	push de	
	push bc	
	push af	
	;
	
	ld a,i
	ld (USERIF+1),a
	;
	
	ld a,000h
	jp po,SETIF
	ld a,001h
SETIF:
	ld (USERIF),a
	;
	
	ld sp,SYSSTK
	;
	
	ld hl,(USERSP)
	ld ix,ERR_SP
	dec hl	
	call RAMCHK
	jr nz,SETSTO
	dec hl	
	call RAMCHK
	jr nz,SETSTO
	;
	
	ld ix,SYS_SP
	nop	
	nop	
	ld de,-USERSTK+1
	add hl,de	
	jr c,SETSTO
	ld ix,DISPBF
;                                       p 6

	scf	
	jr BRRSTO
SETSTO:
	xor a	
	ld (STATE),a
BRRSTO:
	ld a,(BRDA)
	ld hl,(BRAD)
	ld (hl),a	
	call c,MEMDP2
MAIN:
	ld sp,SYSSTK
	call SCAN
	call BEEP
	jr MAIN
	
KEYEXEC:
	cp 010h
	jr c,KHEX
	
;                                       p 7

	ld hl,TEST
	set 0,(hl)
	;
	
	sub 010h
	cp 008h
	ld hl,KSUBFUN
	jp c,BRANCH
	;
	
	ld ix,DISPBF
	sub 008h
	ld hl,STATE
	ld (hl),a	
	ld hl,STMINOR
	ld (hl),000h
	ld hl,KFUN
	jp BRANCH
	
;                                       p 8
	
KHEX:
	ld c,a	
	ld hl,HTAB
BR1:
	ld a,(STATE)
	jp BRANCH
	;
;                                       p 9

KINC:
	ld hl,ITAB
	jr BR1
	
KDEC:
	ld hl,DTAB
	jr BR1
	
KGO:
	ld hl,GTAB
	jr BR1
	
KSTEP:
	call TESTM
	jp nz,IGNORE
	ld a,080h
	jp PREOUT
	
KDATA:
	call TESTM
	jr nz,TESTRG
	call MEMDP2
	ret	
	
TESTRG:
	cp 008h
	jp c,IGNORE
;                                       p 10

	call REGDP9
	ret	
	;
KSBR:
	call TESTM
	jp nz,IGNORE
	ld hl,(ADSAVE)
	call RAMCHK
	jp nz,IGNORE
	ld (BRAD),hl
	call MEMDP2
	ret	
	;
	
KINS:
	call TESTM
	jp nz,IGNORE
	ld hl,(ADSAVE)
	nop	
	ld (STEPBF),hl
	inc hl	
	ld (STEPBF+4),hl
	call RAMCHK
	jp nz,IGNORE

	ld de,0fffeh		; (End of user RAM)-1
	
;                                       p 11
	ld a,h	
	cp 040h
	;; jr c,SKIPH1
	;; cp 020h
	jp c,IGNORE
	;; ld d,027h
SKIPH1:
	ld (STEPBF+2),de
	;
	
DOMV:
	call GMV
	xor a	
	ld (de),a	
	ld hl,(STEPBF+4)
	ld (ADSAVE),hl
	call MEMDP2
	ret	
	;
KDEL:
	call TESTM
	jp nz,IGNORE
	
;                                       p 12

	ld hl,(ADSAVE)
	nop	
	ld (STEPBF+4),hl
	call RAMCHK
	jp nz,IGNORE
	ld de,0ffffh
	ld a,h	
	;; cp 01eh
	;; jr c,SKIPH2
	cp 040h
	jp c,IGNORE
	;; ld d,028h
SKIPH2:
	ld (STEPBF+2),de
	inc hl	
	ld (STEPBF),hl
	jr DOMV
	;
	
KPC:
	ld hl,(USERPC)
	ld (ADSAVE),hl
	call MEMDP2
	ret	
	
KCBR:
	call CLRBR
	ld (ADSAVE),hl
	call MEMDP2
	ret
	
KREG:	
	ld ix,REG_
	
;                                       p 13

	call FCONV
	ret	
	;
KADDR:	
	call MEMDP1
	ret	

KMV:

KRL:
	ld hl,(ADSAVE)
	ld (STEPBF),hl
	
KWT:
	;
KRT:
	call STEPDP
	ret
	;
;                                       p 14

HFIX:	
	jp IGNORE
	;
HDA:
	ld hl,(ADSAVE)
	call RAMCHK
	jp nz,IGNORE
	call PRECL1
	ld a,c	
	rld
	call MEMDP2
	ret	
	;
HAD:
	ld hl,ADSAVE
	call PRECL2
	ld a,c	
	rld
	inc hl	
	rld
	call MEMDP1
	ret	
	;
HRGAD:
HRGFIX:
	ld a,c	
	ld ix,DISPBF
	ld hl,STMINOR
	add a,a	
	ld (hl),a	
	call REGDP8
	ret	
	;
HRT:
HWT:
HRL:
;                                       p 15

HMV:
	call LOCSTBF
	call PRECL2
	ld a,c	
	rld
	inc hl	
	rld
	call STEPDP
	ret	
	;
HRGDA:
	call LOCRGBF
	call PRECL1
	ld a,c	
	rld
	call REGDP9
	ret	
	;
IFIX:
IRGFIX:
	jp IGNORE
	;
IAD:
IDA:
	ld hl,(ADSAVE)
	inc hl	
	ld (ADSAVE),hl
	call MEMDP2
	ret	
	;
IRT:
IWT:
IRL:
IMV:
	ld hl,STMINOR
;                                       p 16

	inc (hl)	
	call LOCSTNA
	jr nz,ISTEP
	dec (hl)	
	jp IGNORE
ISTEP:
	call STEPDP
	ret	
	;
IRGAD:
IRGDA:
	ld hl,STMINOR
	inc (hl)	
	ld a,01fh
	cp (hl)	
	jr nc,IRGNA
	ld (hl),000h
IRGNA:
	call REGDP9
	ret	
	;
DFIX:
DRGFIX:
	jp IGNORE
	;
DAD:
DDA:
	ld hl,(ADSAVE)
	dec hl	
	ld (ADSAVE),hl
	call MEMDP2
	ret	
	;
DRT:
DWT:
DRL:
DMV:
	ld hl,STMINOR
;                                       p 17

	dec (hl)	
	call LOCSTNA
	jr nz,DSTEP
	inc (hl)	
	jp IGNORE
DSTEP:
	call STEPDP
	ret	
	;
DRGAD:
DRGDA:
	ld hl,STMINOR
	dec (hl)	
	ld a,01fh
	cp (hl)	
	jr nc,DRGNA
	ld (hl),01fh
DRGNA:
	call REGDP9
	ret	
	;
GFIX:
GRGFIX:
GRGAD:
GRGDA:
	jp IGNORE
	;
GAD:
GDA:
	ld hl,(BRAD)
	ld (hl),0efh
	ld a,0ffh
PREOUT:
	ld (TEMP),a
	ld a,(USERIF)
	bit 0,a
;                                       p 18

	ld hl,0c9fbh		;'EI','RET'
	jr nz,EIDI
	ld l,0f3h
EIDI:
	ld (TEMP+1),hl
	ld sp,01fbch
	;
	pop af	
	pop bc	
	pop de	
	pop hl	
	ex af,af'	
	pop af	
	ex af,af'	
	exx	
	pop bc	
	pop de	
	pop hl	
	exx	
	pop ix
	pop iy
	ld sp,(USERSP)
	ld (USERAF+1),a
	ld a,(USERIF+1)
	ld i,a
	push hl	
	;
	ld hl,(ADSAVE)
	ex (sp),hl	
	ld a,(TEMP)
	;
	out (DIGIT),a
	ld a,(USERAF+1)
	;
	jp TEMP+1
	;
;                                       p 19

GMV:
	ld hl,STEPBF
	call GETP
	jr c,ERROR
	ld de,(STEPBF+4)
	sbc hl,de
	jr nc,MVUP
	ex de,hl	
	add hl,bc	
	dec hl	
	ex de,hl	
	ld hl,(STEPBF+2)
	lddr
	inc de	
	jr ENDFUN
MVUP:
	add hl,de	
	ldir
	dec de	
	jr ENDFUN
	;
GRL:
	ld de,(STEPBF)
	;
	inc de	
	;
	inc de	
	ld hl,(STEPBF+2)
	;
	or a	
	sbc hl,de
	ld a,l	
;                                       p 20

	rla	
	ld a,h	
	adc a,000h
	jr nz,ERROR
	ld a,l	
	dec de	
	ld (de),a	
	;
ENDFUN:
	ld (ADSAVE),de
	call MEMDP2
	ret	
	;
GWT:
	;; Reset header
	call CLEARHEADER	; Prep user header

	;; Check and retrieve user-specified parameters
	call GETPTR		; Retrieve start (HL) and length (BC) of block
	jr c, ERROR

	;; Prepare header
	ld (U_FILE_HDR + 0x0B),bc
	ld (U_FILE_HDR + 0x0D),hl

	;; Save block dimensions
	push hl
	push bc

	;; Write file id to header
	ld hl,U_FILE_HDR + 0x01
	ld de,(STEPBF)		; Location of file id
	call WORD2ASCII

	;; Write header
	ld hl, U_FILE_HDR
	ld de, 0x19		; Length of Ace header
	ld c,d			; C=0 indicates header
	call WRITE_TO_TAPE

	call PAUSE
	
	;; Retrieve block dimensions
	pop de
	pop hl

	;; Write code block
	ld c,0xFF		; Indicates code block
	call WRITE_TO_TAPE

	;; Write code block
	
	;; call SUM1
	;; jr c,ERROR
	;; ld (STEPBF+6),a
	;; ld hl,4000
	;; call TONE1K
	;; ld hl,STEPBF
	;; ld bc,00007h
	;; call TAPEOUT
	;; ld hl,4000
	;; call TONE2K
	;; call GETPTR
	;; call TAPEOUT
	;; ld hl,4000
	;; call TONE2K
ENDTAPE:
	ld de,(STEPBF+4)
;                                       p 21

	jr ENDFUN
ERROR:
	ld ix,ERR_
	jp SETSTO

	;; Load file from tape
GRT:
	ld hl,(STEPBF)		; Retrieve file id
	ld (TEMP),hl		; and store temporarily
LEAD:
	;; Init display
	call INIT_DISP

	;; Load header
	ld hl,U_FILE_HDR	; Destination for file header
	ld de, 0x0019		; Length of header
	ld c,0x00		; Indicates header
	scf			; Indicates load
	call READ_FROM_TAPE

	;; Try again, if not successful
	jr nc, LEAD

	;; Display name of file found
	ld hl,U_FILE_HDR+1
	ld de, 0x2401
	ld bc,0x0004
	ldir

	call PAUSE
	
	;; Check if right file
	ld hl, U_FILE_HDR+1
	call GETNUM

	ld hl,(TEMP)
	and a
	sbc hl,bc

	ld a,h
	or l
	jr nz, LEAD
	
	;; Load code block
	ld de, (U_FILE_HDR + 0x0B)
	ld hl, (U_FILE_HDR + 0x0D)
	ld c, 0xFF
	scf
	call READ_FROM_TAPE

	jr nc, ERROR

	ld de, (U_FILE_HDR + 0x0B)
	ld hl, (U_FILE_HDR + 0x0D)
	add hl,de
	ex de,hl
	jp ENDFUN
	
	
;; 	ld a,01000000B ; 040h
;; 	out (SEG7),a
;; 	ld hl,1000	
;; LEAD1:
;; 	call PERIOD
;; 	jr c,LEAD
;; 	dec hl	
;; 	ld a,h	
;; 	or l	
;; 	jr nz,LEAD1
;; LEAD2:
;; 	call PERIOD
;; 	jr nc,LEAD2
;; 	;
;; 	ld hl,STEPBF
;; 	ld bc,00007h
;; 	call TAPEIN
;; 	jr c,LEAD
;; 	ld de,(STEPBF)
;; 	call ADDRDP
;; 	ld b,096h
;; FILEDP:
;; 	call SCAN1
;; 	djnz FILEDP
;; 	ld hl,(TEMP)
;; 	or a	
;; 	sbc hl,de
;; 	jr nz,LEAD
;; 	ld a,002h
;; ;                                       p 22

;; 	out (001h),a
;; 	call GETPTR
;; 	jr c,ERROR
;; 	call TAPEIN
;; 	jr c,ERROR
;; 	call SUM1
;; 	ld hl,STEPBF+6
;; 	cp (hl)	
;; 	jr nz,ERROR
;; 	jr ENDTAPE

	;; Align BRANCH
	;; 	ds BASE+0x03B0-$
	
BRANCH:
	ld e,(hl)	
	inc hl	
	ld d,(hl)	
	inc hl	
	add a,l	
	ld l,a	
	ld l,(hl)	
	ld h,000h
	add hl,de	
	jp (hl)	
;                                       p 23

IGNORE:
	ld hl,TEST
	set 7,(hl)
	ret	
	;
INI:
	ld ix,BLANK
	ld c,007h
INI1:
	ld b,038h
INI2:
	call SCAN1
	djnz INI2
	dec ix
	dec c	
	jr nz,INI1
	;
	ld a,PWCODE
	jp INI3
INI4:
	ld hl,NMI
	ld (IM1AD),hl
CLRBR:
	;
	ld hl,0ffffh
	ld (BRAD),hl
	ret	
	;
TESTM:	; Check for states 1 or 2 (i.e., with address-data display)
;                                       p 24

	ld a,(STATE)
l03e8h:
	cp 001h
	ret z	
	cp 002h
	ret	
	;
PRECL1:
	ld a,(TEST)
	or a	
	ret z	
	ld a,000h
	ld (hl),a	
	ld (TEST),a
	ret	
	;
PRECL2:
	call PRECL1
	ret z	
	inc hl	
	ld (hl),a	
	dec hl	
	ret	
	;
MEMDP1:
	ld a,001h
	ld b,004h
	ld hl,DISPBF+2
	jr SAV12
;                                       p 25

MEMDP2:
	ld a,002h
	ld b,002h
	ld hl,DISPBF
SAV12:
	ld (STATE),a
	exx	
	ld de,(ADSAVE)
	call ADDRDP
	ld a,(de)	
	call DATADP
	
BRTEST:
	ld hl,(BRAD)
	ld a,(hl)	
	ld (BRDA),a
	or a	
	sbc hl,de
	jr nz,SETPT1
	ld b,006h
	ld hl,DISPBF
	exx	
SETPT1:
	exx	
SETPT:
	set 6,(hl)
	inc hl	
	djnz SETPT
	ret	
	;
;                                       p 26

STEPDP:
	call LOCSTBF
	ld e,(hl)	
	inc hl	
	ld d,(hl)	
	call ADDRDP
	ld hl,DISPBF+2
	ld b,004h
	call SETPT
	call LOCSTNA
	ld l,a	
	ld h,002h
	ld (DISPBF),hl
	ret	
	;
LOCSTBF:
	ld a,(STMINOR)
	add a,a	
	ld hl,STEPBF
	add a,l	
	ld l,a	
	ret	
	;
LOCSTNA:
	ld a,(STATE)
	sub 004h
	add a,a	
	add a,a	
	ld de,STEPTAB
	add a,e	
	ld e,a	
;                                       p 27

	ld a,(STMINOR)
	add a,e	
	ld e,a	
	ld a,(de)	
	or a	
	ret	
	;
REGDP8:
	ld a,008h
	jr RGSTIN
REGDP9:
	ld a,009h
RGSTIN:
	ld (STATE),a
	ld a,(STMINOR)
	res 0,a
	ld b,a	
	call RGNADP
;                                       p 28

	ld a,b	
	call LOCRG
	ld e,(hl)	
	inc hl	
	ld d,(hl)	
	ld (ADSAVE),de
	call ADDRDP
	ld a,(STATE)
	cp 009h
	ret nz	
	ld hl,DISPBF+2
	ld a,(STMINOR)
	bit 0,a
	jr z,LOCPT
	inc hl	
	inc hl	
LOCPT:
	set 6,(hl)
	inc hl	
	set 6,(hl)
	call FCONV
	ret	
	;
RGNADP:
	ld hl,RGTAB
	add a,l	
	ld l,a	
	ld e,(hl)	
	inc hl	
	ld d,(hl)	
	ld (DISPBF),de
	ret	
	;
LOCRGBF:
	ld a,(STMINOR)
LOCRG:
	ld hl,REGBF
;                                       p 29

	add a,l	
	ld l,a	
	ret	
	;
FCONV:
	ld a,(STMINOR)
	or a	
	rra	
	cp 00bh
	jr z,FLAGX
	ld c,a	
	ld hl,USERIF
	ld a,(hl)	
	and 00000001B ; 001h
	ld (hl),a	
	ld a,c	
FLAGX:
	cp 00ch
	jr nc,FCONV2
FCONV1:
	ld a,(USERAF)
	call DECODE
	ld (FLAGH),hl
	call DECODE
	ld (FLAGL),hl
	ld a,(UAFP)
	call DECODE
	ld (FLAGHP),hl
	call DECODE
;                                       p 30

	ld (FLAGLP),hl
	ret	
FCONV2:
	ld hl,(FLAGH)
	call ENCODE
	ld hl,(FLAGL)
	call ENCODE
	ld (USERAF),a
	;
	ld hl,(FLAGHP)
	call ENCODE
	ld hl,(FLAGLP)
	call ENCODE
	ld (UAFP),a
	ret	
	;
DECODE:
	ld b,004h
DRL4:
	add hl,hl	
	add hl,hl	
	add hl,hl	
	rlca	
	adc hl,hl
	djnz DRL4
	ret	
	;
ENCODE:
	ld b,004h
ERL4:
	add hl,hl	
	add hl,hl	
	add hl,hl	
	add hl,hl	
	rla	
;                                       p 31

	djnz ERL4
	ret	
	;
SUM1:
	call GETPTR
	ret c	
SUM:
	xor a	
SUMCAL:
	add a,(hl)	
	cpi
	jp pe,SUMCAL
	or a	
	ret	
	;
GETPTR:
	ld hl,STEPBF+2
GETP:
	ld e,(hl)	
	inc hl	
	ld d,(hl)	
	inc hl	
	ld c,(hl)	
	inc hl	
	ld h,(hl)	
	ld l,c	
	or a	
	sbc hl,de
	ld c,l	
	ld b,h	
	inc bc	
;                                       p 32

	ex de,hl	
	ret	
	;
TAPEIN:
	xor a	
	ex af,af'	
TLOOP:
	call GETBYTE
	ld (hl),e	
	cpi
	jp pe,TLOOP
	ex af,af'	
	ret	
	;
GETBYTE:
	call GETBIT
	ld d,008h
BLOOP:
	call GETBIT
	rr e
	dec d	
	jr nz,BLOOP
	call GETBIT
	ret	
	;
GETBIT:
;                                       p 33

	exx	
	;
	ld hl,l0000h
	;
COUNT:
	call PERIOD
	inc d	
	;
	dec d	
	jr nz,TERR
	;
	jr c,SHORTP
	;
	dec l	
	;
	dec l	
	set 0,h
	jr COUNT
SHORTP:
	inc l	
	bit 0,h
	jr z,COUNT
;                                       p 34

	rl l
	exx	
	ret	
TERR:
	ex af,af'	
	scf	
	ex af,af'	
	exx	
	ret	
	;
PERIOD:
	ld de,l0000h
LOOPH:
	in a,(0xFE)
	inc de	
	rla
	rla
	rla
	rla
	jr c,LOOPH
	ld a,11111111B ; 0ffh
	out (0xFE),a
LOOPL:
	in a,(0xFE)
	inc de	
	rla
	rla
	rla
	rla
	jr nc,LOOPL
	ld a,01111111B ; 07fh
	
	out (0xFE),a
	ld a,e	
	
	cp MPERIOD
	ret	
	;
TAPEOUT:
	ld e,(hl)	
	call OUTBYTE
	cpi
	jp pe,TAPEOUT
;                                       p 35

	ret	
	;
OUTBYTE:
	ld d,008h
	or a	
	call OUTBIT
OLOOP:
	rr e
	call OUTBIT
	dec d	
	jr nz,OLOOP
	scf	
	call OUTBIT
	ret	
	;
OUTBIT:
	exx	
	ld h,000h
	jr c,OUT1
OUT0:
	ld l,ZERO_2K
	call TONE2K
	ld l,ZERO_1K
	jr BITEND
OUT1:
	ld l,ONE_2K
	call TONE2K
	ld l,ONE_1K
BITEND:
	call TONE1K
	exx	
	ret	
	;

	ds 0x05DE-$

TONE1K:
	ld c,F1KHZ
	jr TONE
TONE2K:
;                                       p 36

	ld c,F2KHZ
TONE:
	add hl,hl	
	ld de,0001h
	ld a,0ffh
SQWAVE:
	in a, (0xFE)
	ld b,c	
l05edh:
	djnz l05edh
	out (0xFE),a
	sbc hl,de
	jr nz,SQWAVE
	ret	
	;
	ds 0x05F6-$
	
RAMCHK:
	ld a,(hl)	
	cpl	
	ld (hl),a	
	ld a,(hl)	
	cpl	
	ld (hl),a	
	cp (hl)	
	ret	
	;
	ds 0x05FE-$		; Pad, so SCAN is properly aligned
SCAN:
	push ix
	ld hl,TEST
	bit 7,(hl)
	jr z,SCPRE
	ld ix,BLANK
;                                       p 37

SCPRE:
	ld b,004h
SCNX:
	call SCAN1
	jr nc,SCPRE
	djnz SCNX
	res 7,(hl)
	pop ix
	;
SCLOOP:
	call SCAN1
	jr c,SCLOOP
	;
KEYMAP:
	;; ld hl,KEYTAB
	;; add a,l	
	;; ld l,a	
	;; ld a,(hl)	
	ret	
	;
	ds BASE+0x0624-$
	
SCAN1:	exx	; Save primary registers

	;; Update display
	push hl 		; Save HL'
	
	push ix
	pop hl
	ld de, 0x2407 ; DISPLAY_LINE
	ld c, 0x00

	;; Display data
	ld b, 0x02
S1PR:	ld a,(hl)
	call MPF2ACE
	ld (de),a
	inc hl
	dec de
	djnz S1PR

	ld a, _SPACE
	ld (de),a
	dec de

	;; Display address
	ld b, 0x04
S1PR2:	ld a,(hl)
	call MPF2ACE
	ld (de),a
	inc hl
	dec de
	djnz S1PR2

	;; Retrieve any key values
	call GETKEY
	cp 0xFF			; Carry will be reset for no/ invalid key
	ccf			; Complement to match original version
KEYPRESSED:
	;; Restore HL'
	pop hl
	
	exx			; Restore main registers

	ret

	ds BASE+0x0665-$		; Ensure location of next routine not changed
	
ADDRDP:
	ld hl,DISPBF+2
	ld a,e	
	call HEX7SG
	ld a,d	
	call HEX7SG
	ret	
	;
DATADP:
	ld hl,DISPBF
	call HEX7SG
	ret	
	;
HEX7SG:
	push af	
	call HEX7
	ld (hl),a	
	inc hl	
	pop af	
	rrca
;                                       p 40
	
	rrca	
	rrca	
	rrca	
	call HEX7
	ld (hl),a	
	inc hl	
	ret	
	;
HEX7:
	push hl	
	ld hl,SEGTAB
	and 0x0F
	add a,l	
	ld l,a	
	ld a,(hl)	
	pop hl	
	ret	

RAMTEST:
	ld hl,01800h
	ld bc,00800h
RAMT:
	call RAMCHK
	jr z,TNEXT
	halt	
TNEXT:
	cpi
	jp pe,RAMT
	rst 0	
	;
ROMTEST:
	ld hl,l0000h
	ld bc,00800h
	call SUM
;                                       p 41

	jr z,SUMOK
	halt	
SUMOK:
	rst 0	
INI3:
	ld (POWERUP),a
	ld a,055h
	ld (BEEPSET),a
	ld a,044h
	ld (FBEEP),a
	ld hl,TBEEP
	ld (hl),02fh
	inc hl	
	ld (hl),000h
	jp INI4
	
BEEP:
	push af	
	ld hl,FBEEP
	ld c,(hl)	
	ld hl,(TBEEP)
	ld a,(BEEPSET)
	cp 055h
	jr nz,NOTONE
	call TONE
	
NOTONE:
	pop af	
	jp KEYEXEC
	
	ds BASE+0x0737-$
KSUBFUN:
		defw	KINC
		defb	-KINC+KINC
		defb	-KINC+KDEC
		defb	-KINC+KGO
		defb	-KINC+KSTEP
		defb	-KINC+KDATA
		defb	-KINC+KSBR
		defb	-KINC+KINS
		defb	-KINC+KDEL
		
KFUN:	defw	KPC	
		defb	-KPC+KPC
		defb	-KPC+KADDR
;                                       p 42

		defb	-KPC+KCBR
		defb	-KPC+KREG
		defb	-KPC+KMV
		defb	-KPC+KRL
		defb	-KPC+KWT
		defb	-KPC+KRT
		
HTAB:	defw	HFIX
		defb	-HFIX+HFIX
		defb	-HFIX+HAD
		defb	-HFIX+HDA
		defb	-HFIX+HRGFIX
		defb	-HFIX+HMV
		defb	-HFIX+HRL
		defb	-HFIX+HWT
		defb	-HFIX+HRT
		defb	-HFIX+HRGAD
		defb	-HFIX+HRGDA

ITAB:	defw	IFIX
		defb	-IFIX+IFIX
		defb	-IFIX+IAD
		defb	-IFIX+IDA
		defb	-IFIX+IRGFIX
		defb	-IFIX+IMV
		defb	-IFIX+IRL
		defb	-IFIX+IWT
		defb	-IFIX+IRT
		defb	-IFIX+IRGAD
		defb	-IFIX+IRGDA

DTAB:	defw	DFIX
		defb	-DFIX+DFIX
		defb	-DFIX+DAD
		defb	-DFIX+DDA
		defb	-DFIX+DRGFIX
		defb	-DFIX+DMV
		defb	-DFIX+DRL
		defb	-DFIX+DWT
		defb	-DFIX+DRT
		defb	-DFIX+DRGAD
		defb	-DFIX+DRGDA

GTAB:	defw	GFIX
		defb	-GFIX+GFIX
		defb	-GFIX+GAD
		defb	-GFIX+GDA
		defb	-GFIX+GRGFIX
		defb	-GFIX+GMV
		defb	-GFIX+GRL
		defb	-GFIX+GWT
		defb	-GFIX+GRT
		defb	-GFIX+GRGAD
		defb	-GFIX+GRGDA

KEYTAB:
K0:		defb	03h		; HEX_3
K1:		defb	07h		; HEX_7
K2:		defb	0bh		; HEX_B
K3:		defb	0fh		; HEX_F
;                                       p 43

K4:		defb	20h		;NOT_USED
K5:		defb	21h		;NOT_USED
K6:		defb	02h		;HEX_2
K7:		defb	06h		;HEX_6
K8:		defb	0ah		;HEX_A
K9:		defb	0eh		;HEX_E
K0A:	defb	22h		;NOT_USED
K0B:	defb	23h		;NOT_USED
K0C:	defb	01h		;HEX_1
K0D:	defb	05h		;HEX_5
K0E:	defb	09h		;HEX_9
K0F:	defb	0dh		;HEX_D
K10:	defb	13h		;STEP
K11:	defb	1fh		;TAPERD
K12:	defb	00h		;HEX_0
K13:	defb	04h		;HEX_4
K14:	defb	08h		;HEX_8
K15:	defb	0ch		;HEX_C
K16:	defb	12h		;GO
K17:	defb	1eh		;TAPEWR
K18:	defb	1ah		;CBR
K19:	defb	18h		;PC
K1A:	defb	1bh		;REG
K1B:	defb	19h		;ADDR
K1C:	defb	17h		;DEL
K1D:	defb	1dh		;RELA
K1E:	defb	15h		;SBR
K1F:	defb	11h		;-
K20:	defb	14h		;DATA
K21:	defb	10h		;+
K22:	defb	16h		;INS
K23:	defb	1ch		;MOVE

;	org	079fh
;	org	079fh
MPF_I:	defb	030h	;'1'
		defb	002h	;'-'
		defb	002h	;'-'
		defb	0fh		;'F'
		defb	1Fh		;'P'
		defb	0B5h	;'u'
BLANK:	defb	0
		defb	0
		defb	0
		defb	0
ERR_:	defb	0
		defb	0
		defb	3		;'R'
		defb	3		;'R'
		defb	8fh		;'E'
		defb	2		;'-'
SYS_SP:	defb	1fh		;'P'
		defb	0aeh	;'S'
		defb	02h		;'-'
		defb	0aeh	;'S'
		defb	0b6h	;'Y'
		defb	0aeh	;'S'	
;                                       p 44

ERR_SP: defb	1fh		;'P'
		defb	0aeh	;'S'
		defb	02		;'-'
		defb	03		;'R'
		defb	03		;'R'
		defb	8fh		;'E'
		defb	0

STEPTAB: defb	0aeh	;'S'
		defb	08fh	;'E'
		defb	0b3h	;'D'
		defb	0		;
		defb	0aeh	;'S'
		defb	0b3h	;'D'
		defb	0		;
		defb	0		;
		defb	0fh		;'F'
		defb	0aeh	;'S'
		defb	08fh	;'E'
		defb	0		;
		defb	0fh		;'F'
		defb	0		;

REG_:	defb	0
		defb	0
		defb	02h		;'-'
		defb	0adh	;'G'
		defb	08fh	;'E'
		defb	03h		;'R'

RGTAB:	defw	3f0fh	;'AF'
		defw	0a78dh	;'BC'
		defw	0b38fh	;'DE'
		defw	3785h	;'HL'
		defw	7f4fh	;'AF.'
		defw	0e7cdh	;'BC.'
		defw	0f3cfh	;'DE.'
		defw	77c5h	;'HL.'
		defw	3007h	;'IX'
		defw	30b6h	;'IY'
		defw	0ae1fh	;'SP'
		defw	300fh	;'IF'
		defw	0f37h	;'FH'
		defw	0f85h	;'FL'
		defw	4f77h	;'FH.'
		defw	4fc5h	;'FL.'

SEGTAB:	db	0bdh	;'0'
	db	30h		;'1'
	db	09bh	;'2'
	db	0bah	;'3'
	db	36h		;'4'
	db	0aeh	;'5'
	db	0afh	;'6'
	db	38h		;'7'
	db	0bfh	;'8'
	db	0beh	;'9'
	db	3fh		;'A'
	db	0a7h	;'B'
	db	08dh	;'C'
	db	0b3h	;'D'
	db	08fh	;'E'
	db	0fh		; 'F'

	;;
	;; Extra code for Jupiter Ace
	;;

	;; Mimic HALT plus MON key. Wait for key press and then jump to
	;; NMI so user can inspect the status of registers/ memory/
	;; stack at point program was halted.
	;;
	;; 
HALT:	push hl		; Save current register set (as will be
	push de		; corrupted by GETKEY)
	push bc
	push af

	;; Display HALT message
	ld hl, HALT_MSG
	ld de, 0x241C
	ld b,4
HALT_LP1:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	djnz HALT_LP1
	
	;; Wait for no key to be pressed (to prevent pre-existing key
	;; press tripping the call to NMI early)
CHECKKEY1:	
	call GETKEY
	inc a
	jr nz, CHECKKEY1

	;;  Now wait for keypress
CHECKKEY2:	
	call GETKEY
	inc a
	jr z, CHECKKEY2

	;; Display HALT message
	ld hl, HALT_CLR
	ld de, 0x241C
	ld b,4
HALT_LP2:
	ld a,(hl)
	ld (de),a
	inc hl
	inc de
	djnz HALT_LP2

	;; Restore registers
	pop af
	pop bc
	pop de
	pop hl
	
	jp NMI

HALT_MSG:	db _H+0x80, _A+0x80, _L+0x80, _T+0x80
HALT_CLR:	db _SPACE, _SPACE, _SPACE, _SPACE

	
	;; Read keypress
	;;
	;; On entry:
	;;
	;; On exit:
	;;   A - character code of key pressed, or #FF if none/ invalid
	;;       key press
	;;   F, BC, DE, HL - corrupted
GETKEY:	ld      bc,$FEFE                ; port address - B is also an 8 counter

        in      d,(c)                   ; read from port to D.
                                        ; when a key is pressed, the
                                        ; corresponding bit is reset.

        ld      e,d                     ; save in E

        srl     d                       ; read the outer SHIFT key.

        sbc     a,a                     ; $00 if SHIFT else $FF.
        and     $D8                     ; $00 if SHIFT else $D8.

        srl     d                       ; read the symbol shift bit
        jr      c,L0347                 ; skip if not pressed.

        ld      a,$28                   ; load A with 40 decimal.

L0347:  add     a,$57                   ; A = $2F (47d) - no modifier
					;     $57 (87d) - Caps shift
					;     $7F (127d) - Symbol shift 

; Since 8 will be subtracted from the initial key value there are three
; distinct ranges 0 - 39, 40 - 79, 80 - 119.

        ld      l,a                     ; save key range value in L
        ld      a,e                     ; fetch the original port reading
        or      $03                     ; cancel the two shift bits (key
					; press corresponds to bit being
					; reset)

        ld      e,$FF                   ; used as flag to detect
					; multiple keys

; KEY_LINE the half-row loop.
L034F:  cpl                             ; complement bits (key press
					; now corresponds to a bit being
					; set)

        and     $1F                     ; mask off the rightmost five key bits.
        ld      d,a                     ; save a copy in D.
        jr      z,L0362                 ; forward if no keys pressed to do the
                                        ; next row.

        ld      a,l                     ; else fetch the key modifier
        inc     e                       ; test E for $FF
        jr      nz,L036B                ; forward if not now zero to quit

L0359:  sub     $08                     ; subtract 8 from key value

        srl     d                       ; test next bit affecting zero and carry

        jr      nc,L0359                ; loop back until the set bit is found.

        ld      e,a                     ; transfer key value to E.
        jr      nz,L036B                ; forward to abort if more than one key
                                        ; is pressed in the row.

L0362:  dec     l                       ; decrement the key value for next row.

        rlc     b                       ; rotate the 8 counter and port address

        jr      nc,L036D                ; skip forward when all 8 rows have
                                        ; been read.

        in      a,(c)                   ; else read the next half-row.
        jr      L034F                   ; and back to KEY_LINE.

; ---
; ABORTKEY

L036B:  ld      e,$FF                   ; signal invalid key.

; the normal exit checks if E holds a key and not $FF.

L036D:  ld      a,e                     ; fetch possible key value.
        cp     0xFF                     ; check for no key
        ret     z                       ; return if was $FF as original.

        ld      hl,L0376                ; else address KEY TABLE
        add     hl,de                   ; index into table.
                                        ; (D is zero)

        ld      a,(hl)                  ; pick up character.

        ret                             ; return with translated character.


L0376:  db    $00 ; $76                     ; V - v
        db    $13 ; $68                     ; H - h
        db    $19 ; $79                     ; Y - y
        db    $06 ; $36                     ; 6 - 6
        db    $05 ; $35                     ; 5 - 5
        db    $1E ; $74                     ; T - t
        db    $12 ; $67                     ; G - g
        db    $0C ; $63                     ; C - c
        db    $0B ; $62                     ; B - b
        db    $15 ; $6A                     ; J - j
        db    $14 ; $75                     ; U - u
        db    $07 ; $37                     ; 7 - 7
        db    $04 ; $34                     ; 4 - 4
        db    $1F ; $72                     ; R - r
        db    $0F ; $66                     ; F - f
        db    $17 ; $78                     ; X - x
        db    $1D ; $6E                     ; N - n
        db    $1A ; $6B                     ; K - k
        db    $1B ; $69                     ; I - i
        db    $08 ; $38                     ; 8 - 8
        db    $03 ; $33                     ; 3 - 3
        db    $0E ; $65                     ; E - e
        db    $0D ; $64                     ; D - d
        db    $16 ; $7A                     ; Z - z
        db    $1C ; $6D                     ; M - m
        db    $00 ; $6C                     ; L - l
        db    $00 ; $6F                     ; O - o
        db    $09 ; $39                     ; 9 - 9
        db    $02 ; $32                     ; 2 - 2
        db    $00 ; $77                     ; W - w
        db    $00 ; $73                     ; S - s
        db    $00 ; $00                     ; SYMBOL
        db    $00 ; $20                     ; SPACE
        db    $00 ; $0D                     ; ENTER
        db    $18 ; $70                     ; P - p
        db    $00 ; $30                     ; 0 - 0
        db    $01 ; $31                     ; 1 - 1
        db    $00 ; $71                     ; Q - q
        db    $0A ; $61                     ; A - a
        db    $00 ; $00                     ; SHIFT

; ---------------------
; THE '40 SHIFTED KEYS'
; ---------------------

        db    $00                     ; V - V
        db    $00                     ; H - H
        db    $00                     ; Y - Y
        db    $00                     ; 6 - 7 KEY-UP
        db    $00                     ; 5 - 1 KEY-LEFT
        db    $00                     ;
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00                     ; 7 - 9 KEY-DOWN
        db    $00                     ; 4 - 8 INV-VIDEO
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00                     ; 8 - 3 KEY-RIGHT
        db    $00                     ; 3 - 3
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00                     ; 9 - 4 GRAPH
        db    $00                     ; 2 - 2 CAPS LOCK
        db    $00                     ; W - W
        db    $00                     ; S - S
        db    $00                     ; SYMB
        db    $00                     ; SPACE
        db    $00                     ; ENTER
        db    $00                     ; P - P
        db    $00                     ; 0 - 5   DEL
        db    $00                     ; 1 - 0A  DEL_LINE
        db    $00                     ; Q - Q
        db    $00                     ; A - A
        db    $00                     ; SHIFT

; --------------------------
; THE '40 SYMBOL SHIFT KEYS'
; --------------------------

        db    $00                     ; V - /
        db    $00                     ; H - ^
        db    $00                     ; Y - [
        db    $00                     ; 6 - &
        db    $00                     ; 5 - %
        db    $00                     ; T - >
        db    $00                     ;
        db    $00
        db    $00
        db    $11		; J - -
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $10		; K - +
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00
        db    $00                     ; 2 - @
        db    $00                     ; W - W
        db    $00                     ; S
        db    $00                     ; SYMB
        db    $00                     ; SPACE
        db    $00                     ; ENTER
        db    $00                     ; P - " $22
        db    $00                     ; 0 - _
        db    $00                     ; 1 - !
        db    $00                     ; Q - Q
        db    $00                     ; A - ~
        db    $00                     ; SHIFT

; end of key tables

	;; 
	;; Extra initialisation required for Minstrel 4th/ 4D
	;; 
INIM:	
	;;  Initialise character set in RAM
; There are 128 bit-mapped 8x8 characters.
; Define the 8 Battenberg graphics ($10 to $17) from low byte of address.
; This routine also sets the other characters $00 to $0F and $18 to $1F
; to copies of this range. The inverse form of character $17 is used as the
; normal cursor - character $97.

L0052:  LD      HL,$2C00                ; point to the start of the 1K write-
                                        ; only Character Set RAM.
L0055:  LD      A,L                     ; set A to low byte of address
        AND     $BF                     ; AND %10111111
        RRCA                            ; rotate
        RRCA                            ; three times
        RRCA                            ; to test bit 2
        JR      NC,L005F                ; forward if not set.

        RRCA                            ; else rotate
        RRCA                            ; twice more.

L005F:  RRCA                            ; set carry from bit (3) or (6)

        LD      B,A

        SBC     A,A                     ; $00 or $FF
        RR      B
        LD      B,A
        SBC     A,A
        XOR     B
        AND     $F0
        XOR     B
        LD      (HL),A                  ; insert the byte.
        INC     L                       ; increment low byte of address
        JR      NZ,L0055                ; loop back until the first 256 bytes
                                        ; have been filled with 32 repeating
                                        ; characters.

; Now copy the bit patterns at the end of this ROM to the last 768 bytes of
; the Character RAM, filling in some blank bytes omitted to save ROM space.
; This process starts at high memory and works downwards.

L006E:  LD      DE,$2FFF                ; top of destination.
        LD      HL,L1FFB                ; end of copyright character.
        LD      BC,$0008                ; 8 characters

        LDDR                            ; copy the  ©  character

        EX      DE,HL                   ; switch pointers.

        LD      A,$5F                   ; set character counter to ninety five.
                                        ; i.e. %0101 1111
                                        ; bit 5 shows which 32-character sector
                                        ; we are in.

; enter a loop for the remaining characters supplying zero bytes as required.

L007C:  LD      C,$07                   ; set byte counter to seven.

        BIT     5,A                     ; test bit 5 of the counter.
        JR      Z,L0085                 ; forward if not in middle section
                                        ; which includes "[A-Z]"

        LD      (HL),B                  ; else insert a zero byte.
        DEC     HL                      ; decrement the destination address.
        DEC     C                       ; and the byte counter.

L0085:  EX      DE,HL                   ; switch pointers.

        LDDR                            ; copy the 5 or 6 characters.

        EX      DE,HL                   ; switch pointers.

        LD      (HL),B                  ; always insert the blank top byte.
        DEC     HL                      ; decrement the address.

        DEC     A                       ; decrement the character counter.

        JR      NZ,L007C                ; back for all 95 characters.

	;; Clear the screen
        xor a		; clear accumulator.
        ld ($2700),a	; make location after screen zero.

	ld hl, 0x2400		; Start of video RAM
	ld (hl), _SPACE		; Space
	ld de, 0x2401
	ld bc, 0x2FF
	ldir

	;; Print instructions
	ld de, MPF1_HELP	; Start of instructions

NEW_LINE:
	ld hl, 0x2400		; Start of display

	ld a,(de)		; Retrieve command
	inc de			; Advance pointer
	
	;; Check if done
	cp 0xFF
	jr z, DONE

	push de			; Save pointer
	ld b,a			; Move row number into B (must be >0)
	ld de, 0x0020		; Length of a row

ADD_ROW:
	add hl,de		; Advance one row
	djnz ADD_ROW

	pop de			; Retrieve pointers
	
	ld a,(de)		; Retrieve column number
	inc de			; Advance pointer

	add a,l			; Add to current display pointer
	ld l,a			; Should be no overflow

	;; HL points to next location in display file
PR_CHR: ld a,(de)		; Retrieve character
	inc de			; Advance pointer
	cp 0x0D			; Check for CR
	jr z, NEW_LINE		; Jump if so

	ld (hl),a		; Print character
	inc hl			; Advance display-file pointer

	jr PR_CHR		; Next character
	
	;; Return to the MPF-1 initialisation routine
DONE:	jp INI

MPF1_HELP:	
	;; 	db  8, 7, _MINUS, _MINUS, _MINUS, _SPACE, _C, _O, _M, _M, _A, _N, _D, _S, _SPACE, _MINUS, _MINUS, _MINUS,  0x0D
	db  9, 2, _P, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _P, _C, 0x0D
	db 10, 2, _Y, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _A, _D, _D, _R, 0x0D
	db 11, 2, _U, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _D, _A, _T, _A, 0x0D
	db 12,  2, _I, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _R, _E, _G, 0x0D
	db 13,  2, _G, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _G, _O, 0x0D
	db 14, 2, _S, _MINUS, _K, _SPACE, _MINUS, _SPACE, _PLUS, 0x0D
	db 15, 2, _S, _MINUS, _J, _SPACE, _MINUS, _SPACE, _MINUS, 0x0D
	db 16, 2, _R, _E, _S, _SPACE, _MINUS, _SPACE, _R, _E, _S, _E, _T, 0x0D
	db  9, 17, _N, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _R, _E, _L, _A, 0x0D
	db 10, 17, _J, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _S, _B, _R, 0x0D
	db 11, 17, _K, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _C, _B, _R, 0x0D
	db 12, 17, _M, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _M, _O, _V, _E, 0x0D
	db 13, 17, _Z, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _I, _N, _S, 0x0D
	db 14, 17, _X, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _D, _E, _L, 0x0D
	db 15, 17, _R, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _T, _A, _P, _E, _R, 0x0D
	db 16, 17, _T, _SPACE, _SPACE, _SPACE, _MINUS, _SPACE, _T, _A, _P, _E, _W, 0x0D
	;; 	db 18, 7, _MINUS, _MINUS, _MINUS, _SPACE, _R, _E, _G, _I, _S, _T, _E, _R, _SPACE, _MINUS, _MINUS, _MINUS, 0x0D
	db 19, 4, _0, _MINUS, _A, _F, _SPACE, _SPACE, _1, _MINUS, _B, _C, _SPACE, _SPACE
	db _2, _MINUS, _D, _E, _SPACE, _SPACE, _3, _MINUS, _H, _L, 0x0D
	db 20, 4, _4, _MINUS, _A+0x80, _F+0x80, _SPACE, _SPACE, _5, _MINUS, _B+0x80, _C+0x80, _SPACE, _SPACE
	db _6, _MINUS, _D+0x80, _E+0x80, _SPACE, _SPACE, _7, _MINUS, _H+0x80, _L+0x80, 0x0D
	db 21, 4, _8, _MINUS, _I, _X, _SPACE, _SPACE, _9, _MINUS, _I, _Y, _SPACE, _SPACE
	db _A, _MINUS, _S, _P, _SPACE, _SPACE, _B, _MINUS, _I, _F
	db 0x0D
	db 22, 4, _C, _MINUS, _F, _H, _SPACE, _SPACE, _D, _MINUS, _F, _L, _SPACE, _SPACE
	db _E, _MINUS, _F+0x80, _H+0x80, _SPACE, _SPACE, _F, _MINUS, _F+0x80, _L+0x80
	db 0x0D
	db 0xFF


; -------------------
; THE 'CHARACTER SET'
; -------------------
; The 96 ASCII character bitmaps are copied to RAM during initialization and
; the 8x8 characters can afterwards be redefined by the user.
; Some ROM space is saved by supplying the blank top line of most characters
; and in case of the middle range (capitals with no descenders) the bottom
; line as well. Only the final copyright symbol is held in ROM as an 8x8
; character.


; $20 - Character: ' '          CHR$(32)

L1D7B:  DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $21 - Character: '!'          CHR$(33)

        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000

; $22 - Character: '"'          CHR$(34)

        DEFB    %00100100
        DEFB    %00100100
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $23 - Character: '#'          CHR$(35)

        DEFB    %00100100
        DEFB    %01111110
        DEFB    %00100100
        DEFB    %00100100
        DEFB    %01111110
        DEFB    %00100100
        DEFB    %00000000

; $24 - Character: '$'          CHR$(36)

        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00101000
        DEFB    %00111110
        DEFB    %00001010
        DEFB    %00111110
        DEFB    %00001000

; $25 - Character: '%'          CHR$(37)

        DEFB    %01100010
        DEFB    %01100100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100110
        DEFB    %01000110
        DEFB    %00000000

; $26 - Character: '&'          CHR$(38)

        DEFB    %00010000
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00101010
        DEFB    %01000100
        DEFB    %00111010
        DEFB    %00000000

; $27 - Character: '''          CHR$(39)

        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $28 - Character: '('          CHR$(40)

        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00000000

; $29 - Character: ')'          CHR$(42)

        DEFB    %00100000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %00000000

; $2A - Character: '*'          CHR$(42)

        DEFB    %00000000
        DEFB    %00010100
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00010100
        DEFB    %00000000

; $2B - Character: '+'          CHR$(43)

        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000000

; $2C - Character: ','          CHR$(44)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00010000

; $2D - Character: '-'          CHR$(45)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $2E - Character: '.'          CHR$(46)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00011000
        DEFB    %00011000
        DEFB    %00000000

; $2F - Character: '/'          CHR$(47)

        DEFB    %00000000
        DEFB    %00000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %00000000

; $30 - Character: '0'          CHR$(48)

        DEFB    %00111100
        DEFB    %01000110
        DEFB    %01001010
        DEFB    %01010010
        DEFB    %01100010
        DEFB    %00111100
        DEFB    %00000000

; $31 - Character: '1'          CHR$(49)

        DEFB    %00011000
        DEFB    %00101000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110
        DEFB    %00000000

; $32 - Character: '2'          CHR$(50)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00000010
        DEFB    %00111100
        DEFB    %01000000
        DEFB    %01111110
        DEFB    %00000000

; $33 - Character: '3'          CHR$(51)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00001100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $34 - Character: '4'          CHR$(52)

        DEFB    %00001000
        DEFB    %00011000
        DEFB    %00101000
        DEFB    %01001000
        DEFB    %01111110
        DEFB    %00001000
        DEFB    %00000000

; $35 - Character: '5'          CHR$(53)

        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $36 - Character: '6'          CHR$(54)

        DEFB    %00111100
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $37 - Character: '7'          CHR$(55)

        DEFB    %01111110
        DEFB    %00000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $38 - Character: '8'          CHR$(56)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100
        DEFB    %00000000

; $39 - Character: '9'          CHR$(57)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111110
        DEFB    %00000010
        DEFB    %00111100
        DEFB    %00000000

; $3A - Character: ':'          CHR$(58)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000

; $3B - Character: ';'          CHR$(59)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00100000

; $3C - Character: '<'          CHR$(60)

        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00000000

; $3D - Character: '='          CHR$(61)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00111110
        DEFB    %00000000
        DEFB    %00000000

; $3E - Character: '>'          CHR$(62)

        DEFB    %00000000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00000000

; $3F - Character: '?'          CHR$(63)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00000000
        DEFB    %00001000

; $40 - Character: '@'          CHR$(64)

        DEFB    %00111100
        DEFB    %01001010
        DEFB    %01010110
        DEFB    %01011110
        DEFB    %01000000
        DEFB    %00111100

; $41 - Character: 'A'          CHR$(65)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111110
        DEFB    %01000010
        DEFB    %01000010

; $42 - Character: 'B'          CHR$(66)

        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100

; $43 - Character: 'C'          CHR$(67)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000010
        DEFB    %00111100

; $44 - Character: 'D'          CHR$(68)

        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000100
        DEFB    %01111000

; $45 - Character: 'E'          CHR$(69)

        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111110

; $46 - Character: 'F'          CHR$(70)

        DEFB    %01111110
        DEFB    %01000000
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000

; $47 - Character: 'G'          CHR$(71)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000000
        DEFB    %01001110
        DEFB    %01000010
        DEFB    %00111100

; $48 - Character: 'H'          CHR$(72)

        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111110
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010

; $49 - Character: 'I'          CHR$(73)

        DEFB    %00111110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00111110

; $4A - Character: 'J'          CHR$(74)

        DEFB    %00000010
        DEFB    %00000010
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100

; $4B - Character: 'K'          CHR$(75)

        DEFB    %01000100
        DEFB    %01001000
        DEFB    %01110000
        DEFB    %01001000
        DEFB    %01000100
        DEFB    %01000010

; $4C - Character: 'L'          CHR$(76)

        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111110

; $4D - Character: 'M'          CHR$(77)

        DEFB    %01000010
        DEFB    %01100110
        DEFB    %01011010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010

; $4E - Character: 'N'          CHR$(78)

        DEFB    %01000010
        DEFB    %01100010
        DEFB    %01010010
        DEFB    %01001010
        DEFB    %01000110
        DEFB    %01000010

; $4F - Character: 'O'          CHR$(79)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111100

; $50 - Character: 'P'          CHR$(80)

        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000000
        DEFB    %01000000

; $51 - Character: 'Q'          CHR$(81)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01010010
        DEFB    %01001010
        DEFB    %00111100

; $52 - Character: 'R'          CHR$(82)

        DEFB    %01111100
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01111100
        DEFB    %01000100
        DEFB    %01000010

; $53 - Character: 'S'          CHR$(83)

        DEFB    %00111100
        DEFB    %01000000
        DEFB    %00111100
        DEFB    %00000010
        DEFB    %01000010
        DEFB    %00111100

; $54 - Character: 'T'          CHR$(84)

        DEFB    %11111110
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000

; $55 - Character: 'U'          CHR$(85)

        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00111110

; $56 - Character: 'V'          CHR$(86)

        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %00100100
        DEFB    %00011000

; $57 - Character: 'W'          CHR$(87)

        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01000010
        DEFB    %01011010
        DEFB    %00100100

; $58 - Character: 'X'          CHR$(88)

        DEFB    %01000010
        DEFB    %00100100
        DEFB    %00011000
        DEFB    %00011000
        DEFB    %00100100
        DEFB    %01000010

; $59 - Character: 'Y'          CHR$(89)

        DEFB    %10000010
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000

; $5A - Character: 'Z'          CHR$(90)

        DEFB    %01111110
        DEFB    %00000100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %01111110

; $5B - Character: '['          CHR$(91)

        DEFB    %00001110
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001110

; $5C - Character: '\'          CHR$(92)

        DEFB    %00000000
        DEFB    %01000000
        DEFB    %00100000
        DEFB    %00010000
        DEFB    %00001000
        DEFB    %00000100

; $5D - Character: ']'          CHR$(93)

        DEFB    %01110000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %01110000

; $5E - Character: '^'          CHR$(94)

        DEFB    %00010000
        DEFB    %00111000
        DEFB    %01010100
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000

; $5F - Character: '_'          CHR$(95)

        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %11111111

; $60 - Character:  £           CHR$(96)

        DEFB    %00011100
        DEFB    %00100010
        DEFB    %01111000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %01111110
        DEFB    %00000000

; $61 - Character: 'a'          CHR$(97)

        DEFB    %00000000
        DEFB    %00111000
        DEFB    %00000100
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %00111110
        DEFB    %00000000

; $62 - Character: 'b'          CHR$(98)

        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00111100
        DEFB    %00100010
        DEFB    %00100010
        DEFB    %00111100
        DEFB    %00000000

; $63 - Character: 'c'          CHR$(99)

        DEFB    %00000000
        DEFB    %00011100
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00011100
        DEFB    %00000000

; $64 - Character: 'd'          CHR$(100)

        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111110
        DEFB    %00000000

; $65 - Character: 'e'          CHR$(101)

        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000100
        DEFB    %01111000
        DEFB    %01000000
        DEFB    %00111100
        DEFB    %00000000

; $66 - Character: 'f'          CHR$(102)

        DEFB    %00001100
        DEFB    %00010000
        DEFB    %00011000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00000000

; $67 - Character: 'g'          CHR$(103)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00111000

; $68 - Character: 'h'          CHR$(104)

        DEFB    %01000000
        DEFB    %01000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00000000

; $69 - Character: 'i'          CHR$(105)

        DEFB    %00010000
        DEFB    %00000000
        DEFB    %00110000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00111000
        DEFB    %00000000

; $6A - Character: 'j'          CHR$(106)

        DEFB    %00000100
        DEFB    %00000000
        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00000100
        DEFB    %00100100
        DEFB    %00011000

; $6B - Character: 'k'          CHR$(107)

        DEFB    %00100000
        DEFB    %00101000
        DEFB    %00110000
        DEFB    %00110000
        DEFB    %00101000
        DEFB    %00100100
        DEFB    %00000000

; $6C - Character: 'l'          CHR$(108)

        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00000000

; $6D - Character: 'm'          CHR$(109)

        DEFB    %00000000
        DEFB    %01101000
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %00000000

; $6E - Character: 'n'          CHR$(110)

        DEFB    %00000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00000000

; $6F - Character: 'o'          CHR$(111)

        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111000
        DEFB    %00000000

; $70 - Character: 'p'          CHR$(112)

        DEFB    %00000000
        DEFB    %01111000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01111000
        DEFB    %01000000
        DEFB    %01000000

; $71 - Character: 'q'          CHR$(113)

        DEFB    %00000000
        DEFB    %00111100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00000110

; $72 - Character: 'r'          CHR$(114)

        DEFB    %00000000
        DEFB    %00011100
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00100000
        DEFB    %00000000

; $73 - Character: 's'          CHR$(115)

        DEFB    %00000000
        DEFB    %00111000
        DEFB    %01000000
        DEFB    %00111000
        DEFB    %00000100
        DEFB    %01111000
        DEFB    %00000000

; $74 - Character: 't'          CHR$(116)

        DEFB    %00010000
        DEFB    %00111000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00000000

; $75 - Character: 'u'          CHR$(117)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000000

; $76 - Character: 'v'          CHR$(118)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00000000

; $77 - Character: 'w'          CHR$(119)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %01010100
        DEFB    %00101000
        DEFB    %00000000

; $78 - Character: 'x'          CHR$(120)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %00101000
        DEFB    %00010000
        DEFB    %00101000
        DEFB    %01000100
        DEFB    %00000000

; $79 - Character: 'y'          CHR$(121)

        DEFB    %00000000
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %01000100
        DEFB    %00111100
        DEFB    %00000100
        DEFB    %00111000

; $7A - Character: 'z'          CHR$(122)

        DEFB    %00000000
        DEFB    %01111100
        DEFB    %00001000
        DEFB    %00010000
        DEFB    %00100000
        DEFB    %01111100
        DEFB    %00000000

; $7B - Character: '{'          CHR$(123)

        DEFB    %00001110
        DEFB    %00001000
        DEFB    %00110000
        DEFB    %00110000
        DEFB    %00001000
        DEFB    %00001110
        DEFB    %00000000

; $7C - Character: '|'          CHR$(124)

        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00001000
        DEFB    %00000000

; $7D - Character: '}'          CHR$(125)

        DEFB    %01110000
        DEFB    %00010000
        DEFB    %00001100
        DEFB    %00001100
        DEFB    %00010000
        DEFB    %01110000
        DEFB    %00000000

; $7E - Character: '~'          CHR$(126)

        DEFB    %00110010
        DEFB    %01001100
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000
        DEFB    %00000000

; $7F - Character:  ©           CHR$(127)

        DEFB    %00111100
        DEFB    %01000010
        DEFB    %10011001
        DEFB    %10100001
        DEFB    %10100001
        DEFB    %10011001
        DEFB    %01000010
L1FFB:  DEFB    %00111100

	;; Convert an MPF-1 character code to Ace character code
	;; 
	;; On entry:
	;;   A - MPF-1 character code
	;;
	;; On exit:
	;;   A - Ace character code
	;;
MPF2ACE:
	;; Save registers
	push bc
	push de
	push hl
	
	ld b,a			; Save code

	and %01000000		; Isolate and rotate
	sla a			; decimal point
	
	ld c,a			; Store for decimal point
	ld a,b			; Recover char
	and %10111111		; Remove decimal point
	ld hl, MPF2ACEMAP	; Start of lookup table
	ld d,0			; Offset to DE
	ld e,a
	add hl,de		
	ld a,(hl)		; Retrieve value
	
	or c			; Restore decimal point

	;; Restore registers
	pop hl
	pop de
	pop bc
	
	ret

	;; Reset user header to all spaces ready to be part-populated
	;; with data for real header
CLEARHEADER:
	ld hl, U_FILE_HDR	; Start of header
	ld de, U_FILE_HDR+1	; First destination
	ld bc, 0x0019-1		; Length of header-1
	ld a, _SPACE		;
	ld (hl),a		; Fill in first byte
	ldir			; Replicate across header

	ret
	
	;; Convert (16-bit) word into ASCII format and write to memory
	;; (high nibble first)
	;;
	;; On entry:
	;;   DE - byte to be converted
	;;   HL - address in which to store ASCII format (4 bytes)
	;;
	;; On exit:
	;;   HL - address immediately after the stored ASCII format
	;;   A, B - corrupted
WORD2ASCII:
	ld a,d
	call BYTE2ASCII
	ld a,e
	call BYTE2ASCII

	ret

	;; Convert ASCII representation of a hexadecimal byte into
	;; number. No error checking: requires a valid hexadecimal
	;; number to be provided
	;;
	;; On entry:
	;;   DE - ASCII number to convert (D - high nibble; E - low
	;;        nibble)
	;;
	;; On exit:
	;;   A - number interpretted
	;;   D, E - corrupted
ASCII2BYTE:
	ld a,d			; Retrieve high nibble
	call ASCII2NIBBLE	; Convert to hex
	add a,a			; Multiple by 16
	add a,a
	add a,a
	add a,a
	ld d,a			; Save to D
	
	ld a,e			; Retrieve low nibble
	call ASCII2NIBBLE	; Convert to hex
	or d			; Combine with high nibble, leaving
				; answer in A
	ret

ASCII2NIBBLE:
	sub a,'0'		; Normalise based on ASCII code of '0'
	cp 0x10			; Check if larger than 9 -- i.e., A...F
	ret c			; Return if not
	sub a,'A'-'0'-10	; Adjust for A...F
	ret
	

	;; Convert byte into ASCII format and write to memory (high
	;; nibble first)
	;;
	;; On entry:
	;;   A - byte to be converted
	;;   HL - address in which to store ASCII format (2 bytes)
	;;
	;; On exit:
	;;   HL - address immediately after the stored ASCII format
	;;   A, B - corrupted
BYTE2ASCII:
	ld b,a			; Store copy for later

	srl a			; Isolate high nibble
	srl a
	srl a
	srl a
	call NIBBLE2ASCII	; Convert it
	ld (hl),a		; Store in B
	inc hl
	
	ld a,b			; Retrieve original number
	and 0x0F		; Isolate low nibble
	call NIBBLE2ASCII	; Convert it
	ld (hl),a		; Store in C
	inc hl
	
	ret			; Done

	;; Optimised conversion noted at
	;; https://forum.vcfed.org/index.php?threads/binary-to-ascii-hex-conversion-rehash-of-an-old-idea.26636/
NIBBLE2ASCII:
	cp 0x0A
	sbc a,0x69
	daa

	ret

	;; Read string containing four-digit hex number
	;;
	;; On entry:
	;;   HL - address of start of string
	;;
	;; On exit:
	;;   BC - value read
	;;   HL - address beyond end of string
	;;   DE, AF - corrupted
GETNUM:	ld d,(hl)
	inc hl
	ld e,(hl)
	inc hl
	call ASCII2BYTE

	ld b,a
	
	ld d,(hl)
	inc hl
	ld e,(hl)
	inc hl
	call ASCII2BYTE

	ld c,a

	ret
	
	;; Init display
INIT_DISP:
	ld hl, 0x2401
	ld b,4

GRT_POINT:
	ld (hl),_FULLSTOP
	inc hl
	djnz GRT_POINT

	ret
	
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
WRITE_TO_TAPE:	
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
        NOP 			; DI

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
        nop                     ; EI (4) Enable Interrupts.

        RET NC        ; (10) jump if SPACE pressed to Error 3
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

READ_FROM_TAPE:	
L18A7:  NOP			; DI Disable interrupts for accurate timing

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


PAUSE:	ld bc, 0x000
P_LOOP:	djnz P_LOOP
	dec c
	jr nz,P_LOOP
	ret
	
MPF2ACEMAP:
	db 0x20, 0x00, 0x2D, 0x52, 0x00, 0x00, 0x00, 0x58 ; 00-07
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x46 ; 08-0F
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 10-17
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x50 ; 18-1F
	db 0x00, 0x00, 0x00, 0x4E, 0x00, 0x00, 0x00, 0x00 ; 20-27
	db 0x00, 0x00, 0x00, 0x4D, 0x00, 0x00, 0x00, 0x00 ; 28-2F
	db 0x31, 0x00, 0x2B, 0x00, 0x00, 0x00, 0x34, 0x48 ; 30-37
	db 0x37, 0x00, 0x00, 0x00, 0x00, 0x00, 0x51, 0x41 ; 38-3F
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 40-47
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 48-4F
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 50-57
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 58-5F
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 60-67
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 68-6F
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 70-77
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; 78-7F
	db 0x00, 0x00, 0x00, 0x28, 0x00, 0x4C, 0x00, 0x54 ; 80-87
	db 0x00, 0x00, 0x5A, 0x00, 0x00, 0x43, 0x00, 0x45 ; 88-8F
	db 0x49, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x4B ; 90-97
	db 0x00, 0x00, 0x00, 0x32, 0x00, 0x00, 0x00, 0x00 ; 98-9F
	db 0x00, 0x00, 0x29, 0x4F, 0x00, 0x00, 0x53, 0x42 ; A0-A7
	db 0x00, 0x57, 0x00, 0x00, 0x00, 0x47, 0x35, 0x36 ; A8-AF
	db 0x00, 0x4A, 0x00, 0x44, 0x00, 0x55, 0x59, 0x56 ; B0-B7
	db 0x00, 0x00, 0x33, 0x00, 0x00, 0x30, 0x39, 0x38 ; B8-BF
	db 0x2C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; C0-C7
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; C8-CF
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; D0-D7
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; D8-DF
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; E0-E7
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; E8-EF
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; F0-F7
	db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; F8-FF

	;; Populate rest of ROM with $FF
	ds BASE+0x2000-$
	
;SYSTEM RAM AREA:
USERSTK:	equ			UMEM-$80
SYSSTK:		equ			UMEM

SYSVARS:	equ UMEM-$0200	; Originally $9faf
STEPBF:		equ SYSVARS + $00
DISPBF:		equ SYSVARS + $07
REGBF:		equ SYSVARS + $0d
USERAF:		equ SYSVARS + $0d
USERBC:		equ SYSVARS + $0f
USERDE:		equ SYSVARS + $11
USERHL:		equ SYSVARS + $13
UAFP: 		equ SYSVARS + $15
UBCP:		equ SYSVARS + $17
UDEP:		equ SYSVARS + $19
UHLP:		equ SYSVARS + $1b
USERIX:		equ SYSVARS + $1d
USERIY:		equ SYSVARS + $1f
USERSP:		equ SYSVARS + $21
USERIF:		equ SYSVARS + $23
FLAGH:		equ SYSVARS + $25
FLAGL:		equ SYSVARS + $27
FLAGHP:		equ SYSVARS + $29
FLAGLP:		equ SYSVARS + $2b
USERPC:		equ SYSVARS + $2d
ADSAVE:		equ SYSVARS + $2f
BRAD:		equ SYSVARS + $31
BRDA:		equ SYSVARS + $33
STMINOR:	equ SYSVARS + $34
STATE:		equ SYSVARS + $35
POWERUP:	equ SYSVARS + $36
TEST:		equ SYSVARS + $37
ATEMP:		equ SYSVARS + $38
HLTEMP:		equ SYSVARS + $39
TEMP:		equ SYSVARS + $3b
IM1AD:		equ SYSVARS + $3f
BEEPSET:	equ SYSVARS + $41
FBEEP:		equ SYSVARS + $42
TBEEP:		equ SYSVARS + $43
U_FILE_HDR:	equ SYSVARS + $45 ; User-specified file header
S_FILE_HDR:	equ SYSVARS + $5E ; System-read file-header

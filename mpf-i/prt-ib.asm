; z80dasm 1.1.6
;
;
; command line:
;   wget https://electrickery.hosting.philpem.me.uk/comp/mpf1/doc/prt-ib.hex
;   xxd -r -p prt-ib.hex > prt-ib.bin
;   z80dasm -g 0x6000 -a -l prt-ib.bin
	
PR_PRT_1:	equ 0cah
PR_PRT_2:	equ 0cbh
	
PRT_STACK:	equ UMEM-0x0100	; 01f7ch
LINE_BUFFER:	equ 0x3C00	; 01f7dh (35 bytes long)
PR_VAR_1:	equ 0x3CE4	; Was 01ff4
PR_VAR_2:	equ 0x3CE5	; Was 01ff5
PR_VAR_3:	equ 0x3CE7	; Was 01ff7
PR_VAR_4:	equ 0x3CE8	; Was 01ff8
PR_VAR_5:	equ 0x3CE9	; Was 01ff9
PR_VAR_6:	equ 0x3CEB	; Was 01ffa
PR_VAR_7:	equ 0x3CED	; Was 01ffc
PR_VAR_8:	equ 0x3CEE	; Was 01ffd
NEXT_ADDR:	equ 0x3CEF      ; Was 01ffe
SCROLL_COUNT:	equ 0x3CF1	; Scroll counter
NEXT_CELL:	equ 0x3CF2	; Temp location
	
	;; System RAM areas
	;;
	;; PRT-MPF stack grows down from 1F7Ch
	;; Line buffer stored in 1F7Dh--1F9Fh
	;; System variables (?) stored in 1FF4--1FFF
	
	;;
	;; Z80 Disassembler
	;; 
DISASSEM:
	ld sp,PRT_STACK		;6000
	xor a
	ld (SCROLL_COUNT),a
	call sub_636ah		;6003 - Set STATE=4 and initialise display
l6006h:
	ld ix,DISPBF		;6006
	call SCAN		;600a
	call PR_BEEP		;600d
	call sub_6015h		;6010
	jr l6006h		;6013
	
sub_6015h:
	cp 010h			;6015
	jr c,l6025h		;6017 Digit 0...F
	jr z,l602ah		;6019 '+'
	cp 012h			;601b
	jr z,l6047h		;601d 'GO'
	jr c,l602eh		;601f '-'
	call IGNORE		;6021
	ret			;6024
l6025h:
	ld c,a			;6025
	call HMV		;6026
	ret			;6029
l602ah:
	call IMV		;602a
	ret			;602d
l602eh:
	call DMV		;602e
	ret			;6031
sub_6032h:
	ld hl,(DISPBF-3)	;6032
	ld a,l			;6035
	or h			;6036
	jr nz,l603ch		;6037
	ld hl,(STEPBF)		;6039
l603ch:
	ld (NEXT_ADDR),hl		;603c Was 1ffeh
	ret			;603f
l6040h:
	ld hl,007a9h		;6040
	call sub_62bfh		;6043
	ret			;6046
l6047h:
	call PLINE		;6047 - Line feed
	ld hl,STEPBF		;604a - Read parameters
	call GETP		;604d
	jr c,l6040h		;6050 - Jump if invalid
	push hl			;6052 - Move start addr to ix
	pop ix		;6053
	push bc			;6055 - ... and length to iy
	pop iy		;6056
	ld (USERSTK-2),hl	;6058
	call sub_6032h		;605b - ???
l605eh:
	xor a			;605e
	ld (0x3CF4),a		;605f
	ld (PR_VAR_4),a		;6062
	ld (PR_VAR_3),a		;6065
	call sub_6451h		;6068
	call PR_ADDR		;606b
	ld (LINE_BUFFER+7),a	;606e - Space after instruction op-code
	ld a,(ix+000h)		;6071
	push af			;6074
	call GETN		;6075
	pop af			;6078
	cp 0cbh		;6079
	jr z,l6096h		;607b
	cp 0ddh		;607d
	jr z,l60a3h		;607f
	cp 0edh		;6081
	jr z,l60dah		;6083
	cp 0fdh		;6085
	jr z,l60ebh		;6087
	jr l60fah		;6089
sub_608bh:
	inc ix		;608b
sub_608dh:
	dec iy		;608d
	push iy		;608f
	pop bc			;6091
	ld a,b			;6092
	or c			;6093
	and a			;6094
	ret			;6095
l6096h:				; CB instructions
	ld hl,l6c04h		;6096
	ld a,(ix+001h)		;6099
	cp 0ffh		;609c
	jp z,l6117h		;609e
	jr l60f0h		;60a1
l60a3h:				; DD instruction
	ld hl,l6fb8h		;60a3
	ld a,(ix+001h)		;60a6
	cp 0cbh		;60a9
	jr z,l60bfh		;60ab
	ld e,000h		;60ad
l60afh:
	ld c,a			;60af
l60b0h:
	ld a,(hl)			;60b0
	cp c			;60b1
	jr z,l60c9h		;60b2
	ld a,e			;60b4
	cp 046h		;60b5
	jr c,l60bbh		;60b7
	jr l60cfh		;60b9
l60bbh:
	inc e			;60bb
	inc hl			;60bc
	jr l60b0h		;60bd
l60bfh:
	ld e,027h		;60bf
	ld d,000h		;60c1
	add hl,de			;60c3
	ld a,(ix+003h)		;60c4
	jr l60afh		;60c7
l60c9h:
	ld a,e			;60c9
	ld hl,l6cd5h		;60ca
	jr l60f0h		;60cd
l60cfh:
	call sub_623ah		;60cf
	call sub_608bh		;60d2
	jp z,l6502h		;60d5
	jr l6129h		;60d8
l60dah:				; ED instruction
	ld a,(ix+001h)		;60da
	and a			;60dd
	sbc a,040h		;60de
	jr c,l60cfh		;60e0
	cp 07ch		;60e2
	jr nc,l60cfh		;60e4
	ld hl,l6e19h		;60e6
	jr l60f0h		;60e9
l60ebh:				; FD instruction
	ld (PR_VAR_3),a		;60eb
	jr l60a3h		;60ee
l60f0h:
	push af			;60f0
	call sub_608bh		;60f1
	jp z,l6502h		;60f4
	pop af			;60f7
	jr l60fdh		;60f8
l60fah:				; Standard instruction
	ld hl,l689eh		;60fa
l60fdh:
	ld de,LINE_BUFFER+8		;60fd
	ld (0x3CF5),de		;6100
	cp 0ffh		;6104
	jr nz,l6123h		;6106
	ld a,052h		;6108
	ld (de),a			;610a
	inc de			;610b
	ld hl,06bfeh		;610c
l610fh:
	ld bc,00006h		;610f
	ldir		;6112
	dec de			;6114
	jr l6129h		;6115
l6117h:
	ld a,053h		;6117
	ld de,LINE_BUFFER+8		;6119
	ld (de),a			;611c
	inc de			;611d
	ld hl,l62a0h		;611e
	jr l610fh		;6121
l6123h:
	call sub_6156h		;6123
	call sub_618bh		;6126
l6129h:
	ld a,00dh		;6129
	inc de			;612b
	ld (de),a			;612c
	ld a,(PR_VAR_3)		;612d
	and a			;6130
	jr z,l614ah		;6131
	ld hl,LINE_BUFFER+8		;6133
l6136h:
	ld a,(hl)			;6136
l6137h:
	inc hl			;6137
	cp 049h		;6138
	jr z,l6142h		;613a
	cp 00dh		;613c
	jr nz,l6136h		;613e
	jr l614ah		;6140
l6142h:
	ld a,(hl)			;6142
	cp 058h		;6143
	jr nz,l6137h		;6145
	inc (hl)			;6147
	jr l6136h		;6148
l614ah:
	call sub_6562h		;614a
	call sub_608bh		;614d
	jp z,l6502h		;6150
	jp l605eh		;6153
sub_6156h:
	inc a			;6156
	ld e,a			;6157
	ld c,000h		;6158
l615ah:
	ld a,e			;615a
	cp c			;615b
	ret z			;615c
	ld a,(hl)			;615d
	bit 7,a		;615e
	jr nz,l6165h		;6160
	inc hl			;6162
	jr l615ah		;6163
l6165h:
	ld d,a			;6165
	cp 0a1h		;6166
	jr z,l6179h		;6168
	cp 080h		;616a
	jr z,l6181h		;616c
	cp 0e1h		;616e
	jr nc,l6179h		;6170
	ld a,(0x3CF4)		;6172
	cp 0e1h		;6175
	jr nc,l617ah		;6177
l6179h:
	inc c			;6179
l617ah:
	inc hl			;617a
	ld a,d			;617b
	ld (0x3CF4),a		;617c
	jr l615ah		;617f
l6181h:
	ld a,007h		;6181
	add a,c			;6183
	cp e			;6184
	ret nc			;6185
	and a			;6186
	ret z			;6187
	ld c,a			;6188
	jr l617ah		;6189
sub_618bh:
	ld a,d			;618b
	cp 081h		;618c
	jp z,l622dh		;618e
	cp 0a1h		;6191
	jp z,sub_623ah		;6193
	cp 0e1h		;6196
	jp nc,l6247h		;6198
	jp l62a9h		;619b
l619eh:
	inc ix		;619e
	call sub_6393h		;61a0
	dec ix		;61a3
	dec ix		;61a5
	call sub_6393h		;61a7
	inc ix		;61aa
	jr l61b1h		;61ac
l61aeh:
	call sub_6393h		;61ae
l61b1h:
	ld a,005h		;61b1
	ld (PR_VAR_4),a		;61b3
	jp l6255h		;61b6
l61b9h:
	ld a,(ix+001h)		;61b9
	ld c,a			;61bc
	ld b,000h		;61bd
	push ix		;61bf
	bit 7,a		;61c1
	jr nz,l61e3h		;61c3
	ld ix,(NEXT_ADDR)		;61c5
	add ix,bc		;61c9
	push ix		;61cb
	pop bc			;61cd
l61ceh:
	inc bc			;61ce
	inc bc			;61cf
	pop ix		;61d0
	ld a,b			;61d2
	push bc			;61d3
	call GETN		;61d4
	pop bc			;61d7
	ld a,c			;61d8
	call GETN		;61d9
	call sub_608bh		;61dc
	jp z,l6502h		;61df
	ret			;61e2
l61e3h:
	push hl			;61e3
	neg		;61e4
	ld hl,(NEXT_ADDR)		;61e6
	ld c,a			;61e9
	sbc hl,bc		;61ea
	ld c,l			;61ec
	ld b,h			;61ed
	inc bc			;61ee
	pop hl			;61ef
	jr l61ceh		;61f0
l61f2h:
	push hl			;61f2
	ld hl,l62c8h		;61f3
	ld bc,00004h		;61f6
	inc de			;61f9
	ldir		;61fa
	pop hl			;61fc
	dec de			;61fd
	ld a,(ix+000h)		;61fe
	cp 0cbh		;6201
	ld a,(ix+001h)		;6203
	jr z,l6222h		;6206
l6208h:
	call GETN		;6208
	ld a,029h		;620b
	inc de			;620d
	ld (de),a			;620e
	inc hl			;620f
	ld a,(hl)			;6210
	cp 02ch		;6211
	dec hl			;6213
	jr nz,l6217h		;6214
	xor a			;6216
l6217h:
	ld (PR_VAR_4),a		;6217
	call sub_608bh		;621a
	jp z,l6502h		;621d
	jr l6255h		;6220
l6222h:
	call sub_608bh		;6222
	jp z,l6502h		;6225
	ld a,(ix+000h)		;6228
	jr l6208h		;622b
l622dh:
	dec hl			;622d
	ld a,(hl)			;622e
	cp 0e1h		;622f
	jr nc,l6235h		;6231
	jr l622dh		;6233
l6235h:
	ld (PR_VAR_4),a		;6235
	jr l624eh		;6238
sub_623ah:
	ld hl,l62a6h		;623a
	ld de,01f85h		;623d
	ld bc,00003h		;6240
	ldir		;6243
	dec de			;6245
	ret			;6246
l6247h:
	ex af,af'			;6247
	xor a			;6248
	ld (0x3CF4),a		;6249
	ex af,af'			;624c
	dec hl			;624d
l624eh:
	and 05fh		;624e
	ld de,(0x3CF5)		;6250
l6254h:
	ld (de),a			;6254
l6255h:
	inc hl			;6255
	ld a,(hl)			;6256
	bit 7,a		;6257
	jr nz,l6274h		;6259
	cp 05dh		;625b
	jp z,l619eh		;625d
	cp 05bh		;6260
	jp z,l61aeh		;6262
	cp 05eh		;6265
	jr z,l61f2h		;6267
	cp 040h		;6269
	jp z,l61b9h		;626b
	cp 023h		;626e
	ret z			;6270
	inc de			;6271
	jr l6254h		;6272
l6274h:
	cp 081h		;6274
	ld c,a			;6276
	jr c,l62cch		;6277
	ret z			;6279
	cp 0a1h		;627a
	ret z			;627c
	cp 0e1h		;627d
	ret nc			;627f
	ld a,(PR_VAR_4)		;6280
	and a			;6283
	ret nz			;6284
	ld a,(0x3CF4)		;6285
	and a			;6288
	jr z,l629ah		;6289
l628bh:
	dec a			;628b
	jp m,l629ah		;628c
	ld b,a			;628f
l6290h:
	inc hl			;6290
	ld a,(hl)			;6291
	ld c,a			;6292
	bit 7,a		;6293
	jr z,l6290h		;6295
	ld a,b			;6297
	jr l628bh		;6298
l629ah:
	ld a,c			;629a
	inc de			;629b
	and 07fh		;629c
	jr l6254h		;629e
l62a0h:
	ld b,l			;62a0
	ld d,h			;62a1
	jr nz,$+57		;62a2
	inc l			;62a4
	ld b,c			;62a5
l62a6h:
	ccf			;62a6
	ccf			;62a7
	ccf			;62a8
l62a9h:
	ld b,000h		;62a9
	dec hl			;62ab
l62ach:
	dec hl			;62ac
	ld a,(hl)			;62ad
	bit 7,a		;62ae
	jr nz,l62b4h		;62b0
	jr l62ach		;62b2
l62b4h:
	cp 0e1h		;62b4
	jr nc,l624eh		;62b6
	inc b			;62b8
	ld a,b			;62b9
	ld (0x3CF4),a		;62ba
	jr l62ach		;62bd
sub_62bfh:
	ld bc,00006h		;62bf
	ld de,DISPBF		;62c2
	ldir		;62c5
	ret			;62c7
l62c8h:
	jr z,l6313h		;62c8
	ld e,b			;62ca
	dec hl			;62cb
l62cch:
	push hl			;62cc
	push de			;62cd
	ld a,(ix+000h)		;62ce
	and 007h		;62d1
	ld hl,l6696h		;62d3
	ld e,a			;62d6
	ld d,000h		;62d7
	add hl,de			;62d9
	cp 007h		;62da
	jr nz,l62e2h		;62dc
	ld a,041h		;62de
	jr l62e7h		;62e0
l62e2h:
	cp 006h		;62e2
	jr z,l62ech		;62e4
	ld a,(hl)			;62e6
l62e7h:
	pop de			;62e7
	inc de			;62e8
	ld (de),a			;62e9
	pop hl			;62ea
	ret			;62eb
l62ech:
	pop de			;62ec
	inc de			;62ed
	ld bc,00004h		;62ee
	ldir		;62f1
	dec de			;62f3
	pop hl			;62f4
	ret			;62f5
l62f6h:
	ld a,00dh		;62f6
	inc de			;62f8
	ld (de),a			;62f9
	call sub_6562h		;62fa
	jp l6502h		;62fd

	;;
	;; Memory Dump Utility
	;; 
DUMP_MEM:
	ld sp,PRT_STACK		;6300
	xor a
	ld (SCROLL_COUNT),a
	call sub_636ah		;6003 - Set STATE=4 and initialise display
l6306h:
	ld ix,DISPBF		;6306
	call SCAN		;630a
	call PR_BEEP		;630d Beeper
	call sub_6315h		;6310
l6313h:
	jr l6306h		;6313 Repeat
	
sub_6315h:
	cp 010h			;6315 '+'
	jp c,l6025h		;6317 DIGIT
	jp z,l602ah		;631a NEXT PARAM
	cp 012h			;631d 'GO'
	jr z,l6328h		;631f RUN DUMP
	jp c,l602eh		;6321 '-'
	call IGNORE		;6324
	ret			;6327

	;;
	;; GO
	;; 
l6328h:
	call PLINE		;6328
	ld hl,STEPBF		;632b
	call GETP		;632e
	push bc			;6331 - Length
	pop iy			;6332 - Store length
	jp c,l6040h		;6334 Negative length detected in GETP
	call sub_6032h		;6337 Set contents of NEXT_ADDR
	ld hl,(STEPBF)		;633a
l633dh:
	push hl			;633d
	ld hl,(NEXT_ADDR)	;633e - Was 1ffeh
	call PR_ADDR		;6341 - Print Adress to buffer (and init buffer)
	inc hl			;6344 - Update NEXT_ADDR (four bytes further)
	inc hl			;6345
	inc hl			;6346
	inc hl			;6347
	ld (NEXT_ADDR),hl	;6348
	pop hl			;634b
	ld b,004h		;634c Four bytes per line
l634eh:
	push bc			;634e
	ld a,(hl)		;634f - Retrieve data
	call GETN		;6350 - Write to buffer
	call sub_608dh		;6353 - Decrement IY and check for zero
	jr z,l62f6h		;6356 - Exit if done???
	pop bc			;6358
	inc de			;6359
	ld a,020h		;635a - Print space
	ld (de),a		;635c
	inc hl			;635d - Next address
	djnz l634eh		;635e - Repeat if not done
	
	ld a,00dh		;6360 - End of line
	ld (de),a		;6362
	push hl			;6363
	call sub_6562h		;6364
	pop hl			;6367

	jr l633dh		;6368 - Next line

sub_636ah:
	xor a			;636a
	ld (STMINOR),a		;636b - Parameter count
	ld a,004h		;636e
	ld (STATE),a		;6370 - STATE = 4 (params for MV)
	ld hl,00000h		;6373
	ld (DISPBF-3),hl	;6376
	ld hl,(ADSAVE)		;6379
	ld (STEPBF),hl		;637c
	call STEPDP		; Display step buffer and its parameter name
	ret			;6382

	;; Initialise Buffer and Print Address (Memory Dump)
	;;
	;; On entry:
	;;   HL - address from which to dump memory
	;;
	;; On exit:
	;;   (LINE_BUFFER, ...) - buffer containing data
	;;   DE - next location in buffer
PR_ADDR:
	ld a,h			;6383
	ld de,LINE_BUFFER-1	;6384 Start of output buffer
	call GETN		;6387 Convert h to ASCII and write to buffer
	ld a,l			;638a
	call GETN		;638b Convert l to ASCII and write to buffer
	ld a,020h		;638e Space character
	inc de			;6390
	ld (de),a		;6391
	ret			;6392
sub_6393h:
	call sub_608bh		;6393
	jp z,l6502h		;6396
	ld a,(ix+000h)		;6399
	call GETN		;639c
	ret			;639f

	;;
	;; GETN - Convert hexadecimal number into ASCII
	;;
	;; On entry:
	;;   A - number to convert
	;;   DE - address at which to store ASCII rep (two bytes)
GETN:
	ld c,a			;63a0 Save value
	and 00fh		;63a1 Isolate low nibble
	call sub_63b7h		;63a3 Convert to ASCII
	ld b,a			;63a6 Save 
	ld a,c			;63a7 Retrieve original number
	and 0f0h		;63a8 Isolate high nibble
	rrca			;63aa
	rrca			;63ab
	rrca			;63ac
	rrca			;63ad
	call sub_63b7h		;63ae Convert to ASCII
	inc de			;63b1 Store result
	ld (de),a		;63b2
	inc de			;63b3
	ld a,b			;63b4
	ld (de),a			;63b5
	ret			;63b6

	
sub_63b7h:
	cp 00ah		;63b7
	jr nc,l63bfh		;63b9
	or 030h		;63bb
	jr l63c3h		;63bd
l63bfh:
	sub 009h		;63bf
	or 040h		;63c1
l63c3h:
	ret			;63c3
	
	;;
	;; Issue line feed
	;; 
PLINEFD:
	push hl
	push de
	call SCROLL
	pop de
	pop hl
	ret

	;; 	ds BASE+0x13d9-$
	
;; 	ld a,080h		;63c4
;; 	out (PR_PRT_1),a		;63c6
;; 	ld b,050h		;63c8
;; l63cah:
;; 	call sub_665bh		;63ca
;; 	djnz l63cah		;63cd
;; l63cfh:
;; 	in a,(PR_PRT_2)		;63cf
;; 	bit 1,a			;63d1
;; 	jr z,l63cfh		;63d3
;; 	xor a			;63d5
;; 	out (PR_PRT_1),a		;63d6
;; 	ret			;63d8
	
l63d9h:
	ld sp,PRT_STACK		;63d9
	ld hl,l688dh		;63dc
	call sub_62bfh		;63df
	ld hl,01fe6h		;63e2
	set 0,(hl)		;63e5
l63e7h:
	ld ix,DISPBF		;63e7
	call SCAN		;63eb
	call PR_BEEP		;63ee Sound beeper
	cp 010h		;63f1
	call c,sub_641bh		;63f3
	cp 012h		;63f6
	jr nz,l6416h		;63f8
	jp l6469h		;63fa
	rst 38h			;63fd
	rst 38h			;63fe
	rst 38h			;63ff

	;;
	;; BASIC Program Listing Utility
	;; 
	jr l63d9h		;6400
l6402h:
	call PLINE		;6402
	ld a,0ffh		;6405
	ld (018e7h),a		;6407
	ld hl,00800h		;640a
	ld a,(hl)			;640d
	cp 0afh		;640e
	jp z,00817h		;6410
	jp 02017h		;6413
l6416h:
	call IGNORE		;6416
	jr l63e7h		;6419
sub_641bh:
	ld c,a			;641b
	ld hl,PR_VAR_8		;641c
	call 003eeh		;641f
	ld a,c			;6422
	rld		;6423
	ld a,(PR_VAR_8)		;6425
	call 00671h		;6428
	ld hl,01fb7h		;642b
	ld a,(hl)			;642e
	cp 0bdh		;642f
	jr nz,l6435h		;6431
	xor a			;6433
	ld (hl),a			;6434
l6435h:
	ld hl,l688fh		;6435
	ld bc,00004h		;6438
	ld de,01fb8h		;643b
	ldir		;643e
	ret			;6440
l6441h:
	ld hl,l6893h		;6441
	ld de,LINE_BUFFER		;6444
	ld bc,0000bh		;6447
	ldir		;644a
	call sub_6562h		;644c
	jr l6402h		;644f
sub_6451h:
	ld bc,(USERSTK-2)	;6451
	push ix			;6455
	pop hl			;6457
	and a			;6458
	sbc hl,bc		;6459
	ld c,l			;645b
	ld b,h			;645c
	ld hl,(NEXT_ADDR)		;645d
	add hl,bc			;6460
	ld (NEXT_ADDR),hl		;6461
	ld (USERSTK-2),ix		;6464
	ret			;6468
l6469h:
	ld ix,018e8h		;6469
	ld a,(ix-001h)		;646d
	cp 0ffh		;6470
	jr nz,l6441h		;6472
	ld a,(ix+000h)		;6474
	cp 0ffh		;6477
	jr z,l6441h		;6479
	cp 02ah		;647b
	jr nc,l6441h		;647d
l647fh:
	ld hl,LINE_BUFFER		;647f
	ld (PR_VAR_5),hl		;6482
l6485h:
	ld a,(ix+000h)		;6485
	cp 0ffh		;6488
	jp z,l6402h		;648a
	bit 7,a		;648d
	jr nz,l6498h		;648f
	call sub_6536h		;6491
	inc ix		;6494
	jr l6485h		;6496
l6498h:
	and 07fh		;6498
	call sub_6536h		;649a
	ld a,00dh		;649d
	ld de,(PR_VAR_5)		;649f
	ld (de),a			;64a3
	ld hl,01f82h		;64a4
l64a7h:
	ld a,(hl)			;64a7
	cp 00dh		;64a8
	jr z,l64edh		;64aa
	cp 030h		;64ac
	jr c,l64b4h		;64ae
	cp 03ah		;64b0
	jr c,l64b7h		;64b2
l64b4h:
	inc hl			;64b4
	jr l64a7h		;64b5
l64b7h:
	cp 030h		;64b7
	jr z,l64cbh		;64b9
l64bbh:
	cp 00dh		;64bb
	jr z,l64edh		;64bd
	cp 030h		;64bf
	jr c,l64b4h		;64c1
	cp 03ah		;64c3
	jr nc,l64b4h		;64c5
	inc hl			;64c7
	ld a,(hl)			;64c8
	jr l64bbh		;64c9
l64cbh:
	inc hl			;64cb
	ld a,(hl)			;64cc
	dec hl			;64cd
	cp 030h		;64ce
	jr c,l64d6h		;64d0
	cp 03ah		;64d2
	jr c,l64d9h		;64d4
l64d6h:
	inc hl			;64d6
	jr l64a7h		;64d7
l64d9h:
	push hl			;64d9
	ld de,01f9dh		;64da
	and a			;64dd
	ex de,hl			;64de
	sbc hl,de		;64df
	ld c,l			;64e1
	ld b,h			;64e2
	ex de,hl			;64e3
	ld e,l			;64e4
	ld d,h			;64e5
	inc hl			;64e6
	ldir		;64e7
	pop hl			;64e9
	ld a,(hl)			;64ea
	jr l64b7h		;64eb
l64edh:
	call sub_6562h		;64ed
	ld a,(PR_VAR_8)		;64f0
	dec a			;64f3
	ld (PR_VAR_8),a		;64f4
	jp z,l6402h		;64f7
	inc ix		;64fa
	jp l647fh		;64fc
	rst 38h			;64ff

	;;
	;; Printer line feed
	;; 
	jr l6505h		;6500
l6502h:
	call PLINE		;6502
l6505h:
	call PLINEFD		;6505
	xor a			;6508
	out (PR_PRT_1),a		;6509
	ld ix,l6887h		;650b Display "LF    "
	call SCAN		;650f
	jr l6505h		;6512
PR_BEEP:
	push af			;6514
	ld hl,FBEEP		;6515
	ld c,(hl)		;6518
	ld hl,(TBEEP)		;6519
	ld a,(BEEPSET)		;651c
	cp 055h			;651f
	jr nz,l6526h		;6521
	call TONE		;6523
l6526h:
	pop af			;6526
	ret			;6527
	
l6528h:
	ld de,(PR_VAR_5)		;6528
	call sub_63b7h		;652c
	ld (de),a			;652f
	inc de			;6530
	ld (PR_VAR_5),de		;6531
	ret			;6535
sub_6536h:
	cp 010h		;6536
	jr c,l6528h		;6538
	sub 010h		;653a
	ld l,a			;653c
	ld h,000h		;653d
	add hl,hl			;653f
	ld de,067edh		;6540
	add hl,de			;6543
	ld c,(hl)			;6544
	inc hl			;6545
	ld b,(hl)			;6546
	inc hl			;6547
	ld e,(hl)			;6548
	inc hl			;6549
	ld d,(hl)			;654a
	ld l,c			;654b
	ld h,b			;654c
	ex de,hl			;654d
	and a			;654e
	sbc hl,de		;654f
	ld de,(PR_VAR_5)		;6551
	ld a,l			;6555
	ld l,c			;6556
	ld h,b			;6557
	ld c,a			;6558
	ld b,000h		;6559
	ldir		;655b
	ld (PR_VAR_5),de		;655d
	ret			;6561


	;; Print LINE BUFFER
sub_6562h:
	xor a			;6562
	ld (PR_VAR_7),a		;6563

	;; Check we have complete line
	ld b,016h		;6566
	ld hl,LINE_BUFFER	;6568
l656bh:
	ld a,(hl)		;656b
	cp 00dh			;656c - Check for end of line
	jr z,l6594h		;656e
	inc hl			;6570
	djnz l656bh		;6571

	;; Duplicate part of user stack ???
	ld hl,USERSTK-0x0D	;6573
	ld de,USERSTK-0x09	;6576
	ld bc,00005h		;6579
	ldir		;657c
	
	ld a,001h		;657e
	ld (PR_VAR_7),a		;6580
	ld a,00dh		;6583
	ld hl,USERSTK-0x0D	;6585
	ld (hl),a		;6588
	ld b,004h		;6589
	ld hl,USERSTK-0x0C	;658b
	ld a,020h		;658e
l6590h:
	ld (hl),a		;6590
	inc hl			;6591
	djnz l6590h		;6592
l6594h:
	ld (PR_VAR_6),ix		;6594
	ld ix,LINE_BUFFER	;6598
l659ch:
	call MTPPRT		;659c - Print Char
	ld hl,PR_VAR_7		;659f
	ld a,(hl)		;65a2
	and a			;65a3
	jr z,l661dh		;65a4
	dec (hl)		;65a6
	inc ix			;65a7
	jp l659ch		;65a9

	;;
	;; MTPRINT - Printer Driver Utility to print out the contents
	;; of the line buffer
	;; 
	;; 
MTPPRT1:
	call PLINEFD
MTPPRT:
	push af			;65ac
	push bc			;65ad
	push de			;65ae
	push hl			;65af
l65b0h:
	;; xor a
	;; ld (SCROLL_COUNT),a
;; 	in a,(PR_PRT_2)		;65b0
;; 	bit 1,a			;65b2
;; 	jr z,l65bch		;65b4
;; 	ld a,080h		;65b6
;; 	out (PR_PRT_1),a		;65b8
;; 	jr l65c6h		;65ba
;; l65bch:
;; 	ld a,080h		;65bc
;; 	out (PR_PRT_1),a		;65be
;; l65c0h:
;; 	in a,(PR_PRT_2)		;65c0
;; 	bit 1,a		;65c2
;; 	jr z,l65c0h		;65c4
;; l65c6h:

;; 	ld b,012h		;65c6
;; l65c8h:
;; 	call sub_665bh		;65c8
;; 	djnz l65c8h		;65cb

;; 	ld b,003h		;65cd
;; l65cfh:
;; 	call sub_662bh		;65cf
;; 	call sub_663bh		;65d2
;; 	djnz l65cfh		;65d5

	;; Print line buffer
l65d7h:
	ld a,(ix+000h)		;65d7 Start of line buffer
	cp 00ah			;65da Check for Line Feed
	jr nz,l65e5h		;65dc
	call PLINEFD		;65de
	inc ix			;65e1
	jr l65b0h		;65e3
l65e5h:
	cp 00dh			;65e5 Check for form feed (end of buffer)
	jr nz,l65f1h		;65e7
	call PLINEFD
	;; 	out (PR_PRT_1),a	;65ea

	pop hl			;65ec
	pop de			;65ed
	pop bc			;65ee
	pop af			;65ef
	ret			;65f0
l65f1h:
	ld hl,(NEXT_CELL)
	or 0x80
	ld (hl),a
	inc hl
	inc ix
	ld (NEXT_CELL),hl
;; 	call sub_6665h		;65f1 - Get charater pattern (HL)
;; 	ld b,005h		;65f4
;; l65f6h:
;; 	ld a,(hl)		;65f6
;; 	rrca			;65f7
;; 	out (PR_PRT_1),a		;65f8
;; 	push bc			;65fa
;; 	ld b,018h		;65fb
;; l65fdh:
;; 	call sub_6653h		;65fd
;; 	djnz l65fdh		;6600
;; 	pop bc			;6602
;; 	call sub_662bh		;6603
;; 	ld a,080h		;6606
;; 	out (PR_PRT_1),a		;6608
;; 	call sub_663bh		;660a
;; 	inc hl			;660d
;; 	djnz l65f6h		;660e
;; 	ld b,002h		;6610
;; l6612h:
;; 	call sub_662bh		;6612
;; 	call sub_663bh		;6615
;; 	djnz l6612h		;6618
	jp l65d7h		;661a

	;; ds BASE+$0161d-$
l661dh:
	call sub_665bh		;661d - Pause
	call sub_665bh		;6620 - Pause
	nop
	nop
	;; xor a			;6623
	;; out (PR_PRT_1),a		;6624
	ld ix,(PR_VAR_6)		;6626
	ret			;662a
sub_662bh:
	exx			;662b
	ld b,005h		;662c
l662eh:
	call sub_664bh		;662e
	in a,(PR_PRT_2)		;6631
	bit 0,a		;6633
	jr z,l662eh		;6635
	djnz l662eh		;6637
	exx			;6639
	ret			;663a
sub_663bh:
	exx			;663b
	ld b,005h		;663c
l663eh:
	call sub_664bh		;663e
	in a,(PR_PRT_2)		;6641
	bit 0,a		;6643
	jr nz,l663eh		;6645
	djnz l663eh		;6647
	exx			;6649
	ret			;664a
sub_664bh:
	push bc			;664b
	ld b,003h		;664c
l664eh:
	nop			;664e
	djnz l664eh		;664f
	pop bc			;6651
	ret			;6652
sub_6653h:
	push bc			;6653
	ld b,00ah		;6654
l6656h:
	nop			;6656
	djnz l6656h		;6657
	pop bc			;6659
	ret			;665a
sub_665bh:
	push bc			;665b
	ld b,0ffh		;665c
l665eh:
	nop			;665e
	djnz l665eh		;665f
	pop bc			;6661
	ret			;6662
l6663h:
	ld a,03fh		;6663
sub_6665h:
	cp 020h		;6665
	jr c,l6663h		;6667
	cp 060h		;6669
	jr nc,l6663h		;666b
	cp 054h		;666d
	jr nc,l6683h		;666f
	and a			;6671
	ld c,020h		;6672
	sbc a,c			;6674
	ld b,a			;6675
	add a,a			;6676
	add a,a			;6677
	add a,b			;6678
	ld hl,l66adh		;6679
l667ch:
	ld e,a			;667c
	ld d,000h		;667d
	add hl,de			;667f
	inc ix		;6680
	ret			;6682
l6683h:
	ld c,054h		;6683
	sbc a,c			;6685
	ld b,a			;6686
	add a,a			;6687
	add a,a			;6688
	add a,b			;6689
	ld hl,l67b1h		;668a
	jr l667ch		;668d
PLINE:
	call PLINEFD		;668f
	call PLINEFD		;6692
	ret			;6695
l6696h:
	ld b,d			;6696
	ld b,e			;6697
	ld b,h			;6698
	ld b,l			;6699
	ld c,b			;669a
	ld c,h			;669b
	jr z,$+74		;669c
	ld c,h			;669e
	add hl,hl			;669f

	;;
	;; SHIFT - Drive the thermal head shift right
	;; 

SHIFT:	ld a,080h		;66a0
	out (PR_PRT_1),a		;66a2
l66a4h:
	call sub_665bh		;66a4
	djnz l66a4h		;66a7
	xor a			;66a9
	out (PR_PRT_1),a		;66aa
	ret			;66ac
l66adh:
	ld bc,00101h		;66ad
	ld bc,00101h		;66b0
	ld bc,001fbh		;66b3
	ld bc,0e101h		;66b6
	ld bc,001e1h		;66b9
	add hl,hl			;66bc
	rst 28h			;66bd
	ld bc,029efh		;66be
	dec h			;66c1
	ld d,l			;66c2
	rst 10h			;66c3
	ld d,l			;66c4
	ld c,c			;66c5
	rst 0			;66c6
	ret			;66c7
	ld de,0c727h		;66c8
	ld l,l			;66cb
	sub e			;66cc
	ld l,e			;66cd
	dec b			;66ce
	dec bc			;66cf
	ld bc,0e101h		;66d0
	pop hl			;66d3
	ld bc,03901h		;66d4
	ld b,l			;66d7
	add a,e			;66d8
	ld bc,08301h		;66d9
	ld b,l			;66dc
	add hl,sp			;66dd
	ld bc,03955h		;66de
	ld a,l			;66e1
	add hl,sp			;66e2
	ld d,l			;66e3
	ld de,07d11h		;66e4
	ld de,00111h		;66e7
	ld bc,01d1bh		;66ea
	ld bc,01111h		;66ed
	ld de,01111h		;66f0
	ld bc,00701h		;66f3
	rlca			;66f6
	ld bc,00907h		;66f7
	ld de,0c121h		;66fa
	ld bc,0837dh		;66fd
	add a,e			;6700
l6701h:
	ld a,l			;6701
	ld bc,0ff43h		;6702
	inc bc			;6705
	ld bc,0934fh		;6706
	sub e			;6709
	sub e			;670a
	ld h,e			;670b
	ld b,l			;670c
	add a,e			;670d
	sub e			;670e
	sub e			;670f
	ld l,l			;6710
	add hl,de			;6711
	add hl,hl			;6712
	ld c,c			;6713
	rst 38h			;6714
	add hl,bc			;6715
	push hl			;6716
	and e			;6717
	and e			;6718
	and e			;6719
	sbc a,l			;671a
	dec a			;671b
	ld d,e			;671c
	sub e			;671d
	sub e			;671e
	dec c			;671f
	add a,a			;6720
	adc a,c			;6721
	sub c			;6722
	and c			;6723
	pop bc			;6724
	ld l,l			;6725
	sub e			;6726
	sub e			;6727
	sub e			;6728
	ld l,l			;6729
	ld h,c			;672a
	sub e			;672b
	sub e			;672c
	sub l			;672d
	ld a,c			;672e
	ld bc,l6701h		;672f
	ld h,a			;6732
	ld bc,00101h		;6733
	in a,(0ddh)		;6736
	ld bc,02911h		;6738
	ld b,l			;673b
	add a,e			;673c
	ld bc,02929h		;673d
	add hl,hl			;6740
	add hl,hl			;6741
	add hl,hl			;6742
	ld bc,04583h		;6743
	add hl,hl			;6746
	ld de,04101h		;6747
	add a,c			;674a
	sbc a,e			;674b
	ld h,c			;674c
	rst 38h			;674d
	add a,e			;674e
	cp e			;674f
	xor e			;6750
	ei			;6751
	ccf			;6752
	ld c,c			;6753
	adc a,c			;6754
	ld c,c			;6755
	ccf			;6756
	add a,e			;6757
	rst 38h			;6758
	sub e			;6759
	sub e			;675a
	ld l,l			;675b
	ld a,l			;675c
	add a,e			;675d
	add a,e			;675e
	add a,e			;675f
	ld b,l			;6760
	add a,e			;6761
	rst 38h			;6762
	add a,e			;6763
	add a,e			;6764
	ld a,l			;6765
	rst 38h			;6766
	sub e			;6767
	sub e			;6768
	add a,e			;6769
	add a,e			;676a
	rst 38h			;676b
	sub c			;676c
	sub c			;676d
	add a,c			;676e
	add a,c			;676f
	ld a,l			;6770
	add a,e			;6771
	add a,e			;6772
	sub e			;6773
	sbc a,a			;6774
	rst 38h			;6775
	ld de,01111h		;6776
	rst 38h			;6779
	ld bc,0ff83h		;677a
	add a,e			;677d
	ld bc,00305h		;677e
	inc bc			;6781
	inc bc			;6782
	defb 0fdh,0ffh,011h	;illegal sequence		;6783
	add hl,hl			;6786
	ld b,l			;6787
	add a,e			;6788
	rst 38h			;6789
	inc bc			;678a
	inc bc			;678b
	inc bc			;678c
	inc bc			;678d
	rst 38h			;678e
	ld b,c			;678f
	ld sp,0ff41h		;6790
	rst 38h			;6793
	ld b,c			;6794
	ld hl,0ff11h		;6795
	rst 38h			;6798
	add a,e			;6799
	add a,e			;679a
	add a,e			;679b
	rst 38h			;679c
	rst 38h			;679d
	sub c			;679e
	sub c			;679f
	sub c			;67a0
	ld h,c			;67a1
	ld a,l			;67a2
	add a,e			;67a3
	adc a,e			;67a4
	add a,l			;67a5
	ld a,e			;67a6
	rst 38h			;67a7
	sub c			;67a8
	sbc a,c			;67a9
	sub l			;67aa
	ld h,e			;67ab
	ld b,l			;67ac
	and e			;67ad
	sub e			;67ae
	adc a,e			;67af
	ld b,l			;67b0
l67b1h:
	add a,c			;67b1
	add a,c			;67b2
	rst 38h			;67b3
	add a,c			;67b4
	add a,c			;67b5
	defb 0fdh,003h,003h	;illegal sequence		;67b6
	inc bc			;67b9
	pop iy		;67ba
	add hl,de			;67bc
	rlca			;67bd
	add hl,de			;67be
	pop hl			;67bf
	rst 38h			;67c0
	dec b			;67c1
	add hl,bc			;67c2
	dec b			;67c3
	rst 38h			;67c4
	rst 0			;67c5
	add hl,hl			;67c6
	ld de,0c729h		;67c7
	pop bc			;67ca
	ld hl,0211fh		;67cb
	pop bc			;67ce
	add a,a			;67cf
	adc a,e			;67d0
	sub e			;67d1
	and e			;67d2
	jp 0ff01h		;67d3
	add a,e			;67d6
	add a,e			;67d7
	ld bc,021c1h		;67d8
	ld de,00709h		;67db
	ld bc,08383h		;67de
	rst 38h			;67e1
	ld bc,04121h		;67e2
	rst 38h			;67e5
	ld b,c			;67e6
	ld hl,03911h		;67e7
	ld d,l			;67ea
	ld de,02311h		;67eb
	ld l,b			;67ee
	jr z,$+106		;67ef
	dec l			;67f1
	ld l,b			;67f2
	ld sp,03268h		;67f3
	ld l,b			;67f6
	inc sp			;67f7
	ld l,b			;67f8
	inc (hl)			;67f9
	ld l,b			;67fa
	dec (hl)			;67fb
	ld l,b			;67fc
	scf			;67fd
	ld l,b			;67fe
	jr c,l6869h		;67ff
	add hl,sp			;6801
	ld l,b			;6802
	ld a,(03b68h)		;6803
	ld l,b			;6806
	inc a			;6807
	ld l,b			;6808
	ld b,b			;6809
	ld l,b			;680a
	ld b,(hl)			;680b
	ld l,b			;680c
	ld c,e			;680d
	ld l,b			;680e
	ld d,d			;680f
	ld l,b			;6810
	ld e,c			;6811
	ld l,b			;6812
	ld e,a			;6813
	ld l,b			;6814
	ld h,(hl)			;6815
	ld l,b			;6816
	ld l,e			;6817
	ld l,b			;6818
	ld (hl),c			;6819
	ld l,b			;681a
	halt			;681b
	ld l,b			;681c
	ld a,d			;681d
	ld l,b			;681e
	add a,b			;681f
	ld l,b			;6820
	add a,(hl)			;6821
	ld l,b			;6822
	jr nz,l6873h		;6823
	ld c,a			;6825
	ld d,h			;6826
	jr nz,l6849h		;6827
	ld b,c			;6829
	ld c,(hl)			;682a
	ld b,h			;682b
	jr nz,l684eh		;682c
	ld c,a			;682e
	ld d,d			;682f
	jr nz,l685dh		;6830
	dec l			;6832
	ld hl,(02a2fh)		;6833
	ld hl,(03c3dh)		;6836
	ld a,04dh		;6839
	ld d,b			;683b
	jr nz,l6892h		;683c
	ld c,a			;683e
	jr nz,l6861h		;683f
	ld d,h			;6841
	ld c,b			;6842
	ld b,l			;6843
	ld c,(hl)			;6844
	jr nz,l6867h		;6845
	ld c,h			;6847
	ld b,l			;6848
l6849h:
	ld d,h			;6849
	jr nz,l686ch		;684a
	ld d,b			;684c
	ld d,d			;684d
l684eh:
	ld c,c			;684e
	ld c,(hl)			;684f
	ld d,h			;6850
	jr nz,l6873h		;6851
	ld c,c			;6853
	ld c,(hl)			;6854
	ld d,b			;6855
	ld d,l			;6856
	ld d,h			;6857
	jr nz,$+34		;6858
	ld c,(hl)			;685a
	ld b,l			;685b
	ld e,b			;685c
l685dh:
	ld d,h			;685d
	jr nz,$+34		;685e
	ld b,a			;6860
l6861h:
	ld c,a			;6861
	ld d,e			;6862
	ld d,l			;6863
	ld b,d			;6864
	jr nz,l6887h		;6865
l6867h:
	ld d,d			;6867
	ld b,l			;6868
l6869h:
	ld d,h			;6869
	jr nz,l688ch		;686a
l686ch:
	ld b,a			;686c
	ld c,a			;686d
	ld d,h			;686e
	ld c,a			;686f
	jr nz,l6892h		;6870
	ld b,(hl)			;6872
l6873h:
	ld c,a			;6873
	ld d,d			;6874
	jr nz,l6897h		;6875
	ld c,c			;6877
	ld b,(hl)			;6878
	jr nz,l689bh		;6879
	ld b,e			;687b
	ld b,c			;687c
	ld c,h			;687d
	ld c,h			;687e
	jr nz,l68a1h		;687f
	ld d,e			;6881
	ld d,h			;6882
	ld c,a			;6883
	ld d,b			;6884
	jr nz,$+50		;6885

	;; Status Message "    FL"
l6887h:
	db 0x00, 0x00, 0x00, 0x00, 0x0F
l688ch:
	db 0x85			;688c
l688dh:
	nop			;688d
	nop			;688e
l688fh:
	nop			;688f
	add a,a			;6890
	xor (hl)			;6891
l6892h:
	add a,l			;6892
l6893h:
	ld c,(hl)			;6893
	ld c,a			;6894
	jr nz,l68e7h		;6895
l6897h:
	ld d,d			;6897
	ld c,a			;6898
	ld b,a			;6899
	ld d,d			;689a
l689bh:
	ld b,c			;689b
	ld c,l			;689c
	dec c			;689d
l689eh:
	xor 04fh		;689e
	ld d,b			;68a0
l68a1h:
	call pe,02044h		;68a1
	jp nz,02c43h		;68a4
	ld e,l			;68a7
	xor b			;68a8
	ld b,d			;68a9
	ld b,e			;68aa
	add hl,hl			;68ab
	inc l			;68ac
	ld b,c			;68ad
	jp (hl)			;68ae
	ld c,(hl)			;68af
	ld b,e			;68b0
	jr nz,l68f5h		;68b1
	jp 08123h		;68b3
	call po,04345h		;68b6
	jr nz,l68fdh		;68b9
	call pe,02044h		;68bb
	ld b,d			;68be
	inc l			;68bf
	ld e,e			;68c0
	jp p,0434ch		;68c1
	ld b,c			;68c4
	push hl			;68c5
	ld e,b			;68c6
	jr nz,l690ah		;68c7
	ld b,(hl)			;68c9
	inc l			;68ca
	ld b,c			;68cb
	ld b,(hl)			;68cc
	daa			;68cd
	pop hl			;68ce
	ld b,h			;68cf
	ld b,h			;68d0
	jr nz,$+74		;68d1
	ld c,h			;68d3
	inc l			;68d4
	ld b,d			;68d5
	ld b,e			;68d6
	call pe,02044h		;68d7
	ld b,c			;68da
	inc l			;68db
	jr z,l6920h		;68dc
	ld b,e			;68de
	add hl,hl			;68df
	call po,04345h		;68e0
	jr nz,l6927h		;68e3
	ld b,e			;68e5
	jp (hl)			;68e6
l68e7h:
	ld c,(hl)			;68e7
	ld b,e			;68e8
	jr nz,l692eh		;68e9
	call po,04345h		;68eb
	jr nz,l6933h		;68ee
	call pe,02044h		;68f0
	ld b,e			;68f3
	inc l			;68f4
l68f5h:
	ld e,e			;68f5
	jp p,04352h		;68f6
	ld b,c			;68f9
	call po,04e4ah		;68fa
l68fdh:
	ld e,d			;68fd
	jr nz,l6940h		;68fe
	call pe,02044h		;6900
	call nz,02c45h		;6903
	ld e,l			;6906
	xor b			;6907
	ld b,h			;6908
	ld b,l			;6909
l690ah:
	add hl,hl			;690a
	inc l			;690b
	ld b,c			;690c
	jp (hl)			;690d
	ld c,(hl)			;690e
	ld b,e			;690f
	jr nz,l6956h		;6910
	push bc			;6912
	inc hl			;6913
	add a,c			;6914
	call po,04345h		;6915
	jr nz,l695eh		;6918
	call pe,02044h		;691a
	ld b,h			;691d
	inc l			;691e
	ld e,e			;691f
l6920h:
	jp p,0414ch		;6920
	jp pe,02052h		;6923
	ld b,b			;6926
l6927h:
	pop hl			;6927
	ld b,h			;6928
	ld b,h			;6929
	jr nz,$+74		;692a
	ld c,h			;692c
	inc l			;692d
l692eh:
	ld b,h			;692e
	ld b,l			;692f
	call pe,02044h		;6930
l6933h:
	ld b,c			;6933
	inc l			;6934
	jr z,$+70		;6935
	ld b,l			;6937
	add hl,hl			;6938
	call po,04345h		;6939
	jr nz,l6982h		;693c
	ld b,l			;693e
	jp (hl)			;693f
l6940h:
	ld c,(hl)			;6940
	ld b,e			;6941
	jr nz,l6989h		;6942
	call po,04345h		;6944
	jr nz,l698eh		;6947
	call pe,02044h		;6949
	ld b,l			;694c
	inc l			;694d
	ld e,e			;694e
	jp p,04152h		;694f
	jp pe,02052h		;6952
	ld c,(hl)			;6955
l6956h:
	ld e,d			;6956
	inc l			;6957
	ld b,b			;6958
	call pe,02044h		;6959
	ret z			;695c
	ld c,h			;695d
l695eh:
	inc l			;695e
	ld e,l			;695f
	xor b			;6960
	ld e,l			;6961
	add hl,hl			;6962
	inc l			;6963
	ld c,b			;6964
	ld c,h			;6965
	jp (hl)			;6966
	ld c,(hl)			;6967
	ld b,e			;6968
	jr nz,l69b3h		;6969
	call z,08123h		;696b
	call po,04345h		;696e
	jr nz,l69bbh		;6971
	call pe,02044h		;6973
	ld c,b			;6976
	inc l			;6977
	ld e,e			;6978
	call po,04141h		;6979
	jp pe,02052h		;697c
	ld e,d			;697f
	inc l			;6980
	ld b,b			;6981
l6982h:
	pop hl			;6982
	ld b,h			;6983
	ld b,h			;6984
	jr nz,$+74		;6985
	ld c,h			;6987
	inc l			;6988
l6989h:
	ld c,b			;6989
	ld c,h			;698a
	call pe,02044h		;698b
l698eh:
	ld c,b			;698e
	ld c,h			;698f
	inc l			;6990
	jr z,$+95		;6991
	add hl,hl			;6993
	call po,04345h		;6994
	jr nz,$+74		;6997
	ld c,h			;6999
	jp (hl)			;699a
	ld c,(hl)			;699b
	ld b,e			;699c
	jr nz,l69ebh		;699d
	call po,04345h		;699f
	jr nz,$+78		;69a2
	call pe,02044h		;69a4
	ld c,h			;69a7
	inc l			;69a8
	ld e,e			;69a9
	ex (sp),hl			;69aa
	ld d,b			;69ab
	ld c,h			;69ac
	jp pe,02052h		;69ad
	ld c,(hl)			;69b0
	ld b,e			;69b1
	inc l			;69b2
l69b3h:
	ld b,b			;69b3
	call pe,02044h		;69b4
	out (050h),a		;69b7
	inc l			;69b9
	ld e,l			;69ba
l69bbh:
	xor b			;69bb
	ld e,l			;69bc
	add hl,hl			;69bd
	inc l			;69be
	ld b,c			;69bf
	jp (hl)			;69c0
	ld c,(hl)			;69c1
	ld b,e			;69c2
	jr nz,$-43		;69c3
	ld d,b			;69c5
	inc hl			;69c6
	xor b			;69c7
	ld c,b			;69c8
	ld c,h			;69c9
	add hl,hl			;69ca
	call po,04345h		;69cb
	jr nz,$+42		;69ce
	ld c,b			;69d0
	ld c,h			;69d1
	add hl,hl			;69d2
	call pe,02044h		;69d3
	jr z,l6a20h		;69d6
	ld c,h			;69d8
	add hl,hl			;69d9
	inc l			;69da
	ld e,e			;69db
	di			;69dc
	ld b,e			;69dd
	ld b,(hl)			;69de
	jp pe,02052h		;69df
	ld b,e			;69e2
	inc l			;69e3
	ld b,b			;69e4
	pop hl			;69e5
	ld b,h			;69e6
	ld b,h			;69e7
	jr nz,l6a32h		;69e8
	ld c,h			;69ea
l69ebh:
	inc l			;69eb
l69ech:
	ld d,e			;69ec
	ld d,b			;69ed
	call pe,02044h		;69ee
	ld b,c			;69f1
	inc l			;69f2
	jr z,l6a52h		;69f3
	add hl,hl			;69f5
	call po,04345h		;69f6
	jr nz,$+85		;69f9
	ld d,b			;69fb
	jp (hl)			;69fc
l69fdh:
	ld c,(hl)			;69fd
	ld b,e			;69fe
	jr nz,l6a42h		;69ff
l6a01h:
	call po,04345h		;6a01
	jr nz,$+67		;6a04
	call pe,02044h		;6a06
	ld b,c			;6a09
	inc l			;6a0a
	ld e,e			;6a0b
	ex (sp),hl			;6a0c
	ld b,e			;6a0d
	ld b,(hl)			;6a0e
	call pe,02044h		;6a0f
	ld b,d			;6a12
	inc l			;6a13
	add a,b			;6a14
	call pe,02044h		;6a15
	ld b,e			;6a18
	inc l			;6a19
	add a,b			;6a1a
	call pe,02044h		;6a1b
	ld b,h			;6a1e
	inc l			;6a1f
l6a20h:
	add a,b			;6a20
	call pe,02044h		;6a21
	ld b,l			;6a24
	inc l			;6a25
	add a,b			;6a26
	call pe,02044h		;6a27
	ld c,b			;6a2a
	inc l			;6a2b
	add a,b			;6a2c
	call pe,02044h		;6a2d
	ld c,h			;6a30
	inc l			;6a31
l6a32h:
	add a,b			;6a32
	call pe,02044h		;6a33
	jr z,$+74		;6a36
	ld c,h			;6a38
	add hl,hl			;6a39
	inc l			;6a3a
	jp nz,0c323h		;6a3b
	inc hl			;6a3e
	call nz,0c523h		;6a3f
l6a42h:
	inc hl			;6a42
	ret z			;6a43
	inc hl			;6a44
	call z,041e8h		;6a45
	ld c,h			;6a48
	ld d,h			;6a49
	call pe,02044h		;6a4a
	jr z,l6a97h		;6a4d
	ld c,h			;6a4f
	add hl,hl			;6a50
	inc l			;6a51
l6a52h:
	ld b,c			;6a52
	call pe,02044h		;6a53
	ld b,c			;6a56
	inc l			;6a57
	add a,b			;6a58
	pop hl			;6a59
	ld b,h			;6a5a
	ld b,h			;6a5b
	jr nz,l6a9fh		;6a5c
	inc l			;6a5e
	add a,b			;6a5f
	pop hl			;6a60
	ld b,h			;6a61
	ld b,e			;6a62
	jr nz,l6aa6h		;6a63
	inc l			;6a65
	add a,b			;6a66
	di			;6a67
	ld d,l			;6a68
	ld b,d			;6a69
	jr nz,l69ech		;6a6a
	di			;6a6c
	ld b,d			;6a6d
	ld b,e			;6a6e
	jr nz,l6ab2h		;6a6f
	inc l			;6a71
	add a,b			;6a72
	pop hl			;6a73
	ld c,(hl)			;6a74
	ld b,h			;6a75
	jr nz,$-126		;6a76
	ret m			;6a78
	ld c,a			;6a79
	ld d,d			;6a7a
	jr nz,l69fdh		;6a7b
	rst 28h			;6a7d
	ld d,d			;6a7e
	jr nz,l6a01h		;6a7f
	ex (sp),hl			;6a81
	ld d,b			;6a82
	jr nz,$-126		;6a83
	jp p,05445h		;6a85
	jr nz,$+80		;6a88
	ld e,d			;6a8a
	ret p			;6a8b
	ld c,a			;6a8c
	ld d,b			;6a8d
	jr nz,l6ad2h		;6a8e
	ld b,e			;6a90
	jp pe,02050h		;6a91
	adc a,05ah		;6a94
	inc l			;6a96
l6a97h:
	ld e,l			;6a97
	jp pe,02050h		;6a98
	ld e,l			;6a9b
	ex (sp),hl			;6a9c
	ld b,c			;6a9d
	ld c,h			;6a9e
l6a9fh:
	ld c,h			;6a9f
	jr nz,l6af0h		;6aa0
	ld e,d			;6aa2
	inc l			;6aa3
	ld e,l			;6aa4
	ret p			;6aa5
l6aa6h:
	ld d,l			;6aa6
	ld d,e			;6aa7
	ld c,b			;6aa8
	jr nz,$+68		;6aa9
	ld b,e			;6aab
	pop hl			;6aac
	ld b,h			;6aad
	ld b,h			;6aae
	jr nz,l6af2h		;6aaf
	inc l			;6ab1
l6ab2h:
	ld e,e			;6ab2
	jp p,05453h		;6ab3
	jr nz,l6ae8h		;6ab6
	jp p,05445h		;6ab8
	and b			;6abb
	ld e,d			;6abc
	inc hl			;6abd
	add a,c			;6abe
	jp pe,02050h		;6abf
	ld e,d			;6ac2
	inc l			;6ac3
	ld e,l			;6ac4
	and c			;6ac5
	ex (sp),hl			;6ac6
	ld b,c			;6ac7
	ld c,h			;6ac8
	ld c,h			;6ac9
	jr nz,l6b26h		;6aca
	inc l			;6acc
	ld e,l			;6acd
	ex (sp),hl			;6ace
	ld b,c			;6acf
	ld c,h			;6ad0
	ld c,h			;6ad1
l6ad2h:
	jr nz,l6b31h		;6ad2
	pop hl			;6ad4
	ld b,h			;6ad5
	ld b,e			;6ad6
	jr nz,$+67		;6ad7
	inc l			;6ad9
	ld e,e			;6ada
	jp p,05453h		;6adb
	jr nz,l6b18h		;6ade
	jp p,05445h		;6ae0
	jr nz,$+80		;6ae3
	ld b,e			;6ae5
	ret p			;6ae6
	ld c,a			;6ae7
l6ae8h:
	ld d,b			;6ae8
	jr nz,l6b2fh		;6ae9
	ld b,l			;6aeb
	jp pe,02050h		;6aec
	ld c,(hl)			;6aef
l6af0h:
	ld b,e			;6af0
	inc l			;6af1
l6af2h:
	ld e,l			;6af2
	rst 28h			;6af3
	ld d,l			;6af4
	ld d,h			;6af5
	jr nz,l6b20h		;6af6
	ld e,e			;6af8
	add hl,hl			;6af9
	inc l			;6afa
	ld b,c			;6afb
	ex (sp),hl			;6afc
	ld b,c			;6afd
	ld c,h			;6afe
	ld c,h			;6aff
	jr nz,l6b50h		;6b00
	ld b,e			;6b02
	inc l			;6b03
	ld e,l			;6b04
	ret p			;6b05
	ld d,l			;6b06
	ld d,e			;6b07
	ld c,b			;6b08
	jr nz,$+70		;6b09
	ld b,l			;6b0b
	di			;6b0c
	ld d,l			;6b0d
	ld b,d			;6b0e
	jr nz,l6b6ch		;6b0f
	jp p,05453h		;6b11
	jr nz,$+51		;6b14
	jr nc,l6b60h		;6b16
l6b18h:
	jp p,05445h		;6b18
	jr nz,l6b60h		;6b1b
	push hl			;6b1d
	ld e,b			;6b1e
	ld e,b			;6b1f
l6b20h:
	jp pe,02050h		;6b20
	ld b,e			;6b23
	inc l			;6b24
	ld e,l			;6b25
l6b26h:
	jp (hl)			;6b26
	ld c,(hl)			;6b27
	jr nz,l6b6bh		;6b28
	inc l			;6b2a
	jr z,l6b88h		;6b2b
	add hl,hl			;6b2d
	ex (sp),hl			;6b2e
l6b2fh:
	ld b,c			;6b2f
	ld c,h			;6b30
l6b31h:
	ld c,h			;6b31
	jr nz,l6b77h		;6b32
	inc l			;6b34
	ld e,l			;6b35
	and c			;6b36
	di			;6b37
	ld b,d			;6b38
	ld b,e			;6b39
	jr nz,$+67		;6b3a
	inc l			;6b3c
	ld e,e			;6b3d
	jp p,05453h		;6b3e
	jr nz,l6b74h		;6b41
	jr c,l6b8dh		;6b43
	jp p,05445h		;6b45
	jr nz,l6b9ah		;6b48
	ld c,a			;6b4a
	ret p			;6b4b
	ld c,a			;6b4c
	ld d,b			;6b4d
	jr nz,l6b98h		;6b4e
l6b50h:
	ld c,h			;6b50
	jp pe,02050h		;6b51
	ld d,b			;6b54
	ld c,a			;6b55
	inc l			;6b56
	ld e,l			;6b57
	push hl			;6b58
	ld e,b			;6b59
	jr nz,l6b84h		;6b5a
	ld d,e			;6b5c
	ld d,b			;6b5d
	add hl,hl			;6b5e
	inc l			;6b5f
l6b60h:
	ld c,b			;6b60
	ld c,h			;6b61
	ex (sp),hl			;6b62
	ld b,c			;6b63
	ld c,h			;6b64
	ld c,h			;6b65
	jr nz,l6bb8h		;6b66
	ld c,a			;6b68
	inc l			;6b69
	ld e,l			;6b6a
l6b6bh:
	ret p			;6b6b
l6b6ch:
	ld d,l			;6b6c
	ld d,e			;6b6d
	ld c,b			;6b6e
	jr nz,l6bb9h		;6b6f
	ld c,h			;6b71
	pop hl			;6b72
	ld c,(hl)			;6b73
l6b74h:
	ld b,h			;6b74
	jr nz,l6bd2h		;6b75
l6b77h:
	jp p,05453h		;6b77
	jr nz,l6baeh		;6b7a
	jr nc,$+74		;6b7c
	jp p,05445h		;6b7e
	jr nz,$+82		;6b81
	ld b,l			;6b83
l6b84h:
	jp pe,02050h		;6b84
	xor b			;6b87
l6b88h:
	ld c,b			;6b88
l6b89h:
	ld c,h			;6b89
	add hl,hl			;6b8a
	inc hl			;6b8b
	ret nc			;6b8c
l6b8dh:
	ld b,l			;6b8d
l6b8eh:
	inc l			;6b8e
	ld e,l			;6b8f
	push hl			;6b90
	ld e,b			;6b91
	jr nz,$+70		;6b92
	ld b,l			;6b94
	inc l			;6b95
	ld c,b			;6b96
	ld c,h			;6b97
l6b98h:
	ex (sp),hl			;6b98
	ld b,c			;6b99
l6b9ah:
	ld c,h			;6b9a
l6b9bh:
	ld c,h			;6b9b
	jr nz,l6beeh		;6b9c
	ld b,l			;6b9e
	inc l			;6b9f
l6ba0h:
	ld e,l			;6ba0
	and c			;6ba1
	ret m			;6ba2
	ld c,a			;6ba3
	ld d,d			;6ba4
	jr nz,l6c02h		;6ba5
	jp p,05453h		;6ba7
	jr nz,l6bdeh		;6baa
	jr c,l6bf6h		;6bac
l6baeh:
	jp p,05445h		;6bae
	jr nz,$+82		;6bb1
	ret p			;6bb3
	ld c,a			;6bb4
	ld d,b			;6bb5
	jr nz,l6bf9h		;6bb6
l6bb8h:
	ld b,(hl)			;6bb8
l6bb9h:
	jp pe,02050h		;6bb9
	ld d,b			;6bbc
	inc l			;6bbd
	ld e,l			;6bbe
	call po,0e349h		;6bbf
	ld b,c			;6bc2
	ld c,h			;6bc3
	ld c,h			;6bc4
	jr nz,l6c17h		;6bc5
	inc l			;6bc7
	ld e,l			;6bc8
	ret p			;6bc9
	ld d,l			;6bca
	ld d,e			;6bcb
	ld c,b			;6bcc
	jr nz,$+67		;6bcd
	ld b,(hl)			;6bcf
	rst 28h			;6bd0
	ld d,d			;6bd1
l6bd2h:
	jr nz,$+93		;6bd2
	jp p,05453h		;6bd4
	jr nz,l6c0ch		;6bd7
	jr nc,l6c23h		;6bd9
	jp p,05445h		;6bdb
l6bdeh:
	jr nz,l6c2dh		;6bde
	call pe,02044h		;6be0
	ld d,e			;6be3
	ld d,b			;6be4
	inc l			;6be5
	ld c,b			;6be6
	ld c,h			;6be7
	jp pe,02050h		;6be8
	ld c,l			;6beb
	inc l			;6bec
	ld e,l			;6bed
l6beeh:
	push hl			;6bee
	ld c,c			;6bef
	ex (sp),hl			;6bf0
	ld b,c			;6bf1
	ld c,h			;6bf2
	ld c,h			;6bf3
	jr nz,$+79		;6bf4
l6bf6h:
	inc l			;6bf6
	ld e,l			;6bf7
	and c			;6bf8
l6bf9h:
	ex (sp),hl			;6bf9
	ld d,b			;6bfa
	jr nz,$+93		;6bfb
	jp p,05453h		;6bfd
	jr nz,$+53		;6c00
l6c02h:
	jr c,l6c4ch		;6c02
l6c04h:
	jp p,0434ch		;6c04
	jr nz,l6b89h		;6c07
	jp p,04352h		;6c09
l6c0ch:
	jr nz,l6b8eh		;6c0c
	jp p,0204ch		;6c0e
	add a,b			;6c11
	jp p,02052h		;6c12
	add a,b			;6c15
	di			;6c16
l6c17h:
	ld c,h			;6c17
	ld b,c			;6c18
	jr nz,l6b9bh		;6c19
	di			;6c1b
	ld d,d			;6c1c
	ld b,c			;6c1d
	jr nz,l6ba0h		;6c1e
	and c			;6c20
	and c			;6c21
	and c			;6c22
l6c23h:
	and c			;6c23
	and c			;6c24
	and c			;6c25
	and c			;6c26
	and c			;6c27
	di			;6c28
	ld d,d			;6c29
	ld c,h			;6c2a
	jr nz,$-126		;6c2b
l6c2dh:
	jp po,05449h		;6c2d
	jr nz,$+50		;6c30
	inc l			;6c32
	add a,b			;6c33
	jp po,05449h		;6c34
	jr nz,l6c6ah		;6c37
	inc l			;6c39
	add a,b			;6c3a
	jp po,05449h		;6c3b
	jr nz,l6c72h		;6c3e
	inc l			;6c40
	add a,b			;6c41
	jp po,05449h		;6c42
	jr nz,l6c7ah		;6c45
	inc l			;6c47
	add a,b			;6c48
	jp po,05449h		;6c49
l6c4ch:
	jr nz,$+54		;6c4c
	inc l			;6c4e
	add a,b			;6c4f
	jp po,05449h		;6c50
	jr nz,$+55		;6c53
	inc l			;6c55
	add a,b			;6c56
	jp po,05449h		;6c57
	jr nz,l6c92h		;6c5a
	inc l			;6c5c
	add a,b			;6c5d
	jp po,05449h		;6c5e
	jr nz,$+57		;6c61
	inc l			;6c63
	add a,b			;6c64
	jp p,05345h		;6c65
	jr nz,$+50		;6c68
l6c6ah:
	inc l			;6c6a
	add a,b			;6c6b
	jp p,05345h		;6c6c
	jr nz,l6ca2h		;6c6f
	inc l			;6c71
l6c72h:
	add a,b			;6c72
	jp p,05345h		;6c73
	jr nz,l6caah		;6c76
	inc l			;6c78
	add a,b			;6c79
l6c7ah:
	jp p,05345h		;6c7a
	jr nz,l6cb2h		;6c7d
	inc l			;6c7f
	add a,b			;6c80
	jp p,05345h		;6c81
	jr nz,l6cbah		;6c84
	inc l			;6c86
	add a,b			;6c87
	jp p,05345h		;6c88
	jr nz,l6cc2h		;6c8b
	inc l			;6c8d
	add a,b			;6c8e
	jp p,05345h		;6c8f
l6c92h:
	jr nz,l6ccah		;6c92
	inc l			;6c94
	add a,b			;6c95
	jp p,05345h		;6c96
	jr nz,$+57		;6c99
	inc l			;6c9b
	add a,b			;6c9c
	di			;6c9d
	ld b,l			;6c9e
	ld d,h			;6c9f
	jr nz,$+50		;6ca0
l6ca2h:
	inc l			;6ca2
	add a,b			;6ca3
	di			;6ca4
	ld b,l			;6ca5
	ld d,h			;6ca6
	jr nz,l6cdah		;6ca7
	inc l			;6ca9
l6caah:
	add a,b			;6caa
	di			;6cab
	ld b,l			;6cac
	ld d,h			;6cad
l6caeh:
	jr nz,l6ce2h		;6cae
	inc l			;6cb0
	add a,b			;6cb1
l6cb2h:
	di			;6cb2
	ld b,l			;6cb3
	ld d,h			;6cb4
	jr nz,l6ceah		;6cb5
	inc l			;6cb7
	add a,b			;6cb8
	di			;6cb9
l6cbah:
	ld b,l			;6cba
	ld d,h			;6cbb
	jr nz,$+54		;6cbc
	inc l			;6cbe
	add a,b			;6cbf
	di			;6cc0
	ld b,l			;6cc1
l6cc2h:
	ld d,h			;6cc2
	jr nz,l6cfah		;6cc3
	inc l			;6cc5
	add a,b			;6cc6
	di			;6cc7
	ld b,l			;6cc8
	ld d,h			;6cc9
l6ccah:
	jr nz,l6d02h		;6cca
	inc l			;6ccc
	add a,b			;6ccd
	di			;6cce
	ld b,l			;6ccf
	ld d,h			;6cd0
	jr nz,$+57		;6cd1
	inc l			;6cd3
	add a,b			;6cd4
l6cd5h:
	pop hl			;6cd5
	ld b,h			;6cd6
	ld b,h			;6cd7
	jr nz,l6d23h		;6cd8
l6cdah:
	ld e,b			;6cda
	inc l			;6cdb
	jp nz,02343h		;6cdc
	call nz,0ec45h		;6cdf
l6ce2h:
	ld b,h			;6ce2
	jr nz,l6caeh		;6ce3
	ld e,b			;6ce5
	inc l			;6ce6
	ld e,l			;6ce7
	xor b			;6ce8
	ld e,l			;6ce9
l6ceah:
	add hl,hl			;6cea
	inc l			;6ceb
	ld c,c			;6cec
	ld e,b			;6ced
	jp (hl)			;6cee
	ld c,(hl)			;6cef
	ld b,e			;6cf0
	jr nz,$+75		;6cf1
	ld e,b			;6cf3
	pop hl			;6cf4
	ld b,h			;6cf5
	ld b,h			;6cf6
	jr nz,l6d42h		;6cf7
	ld e,b			;6cf9
l6cfah:
	inc l			;6cfa
	ld c,c			;6cfb
	ld e,b			;6cfc
	call pe,02044h		;6cfd
	ld c,c			;6d00
	ld e,b			;6d01
l6d02h:
	inc l			;6d02
	jr z,l6d62h		;6d03
	add hl,hl			;6d05
	call po,04345h		;6d06
	jr nz,l6d54h		;6d09
	ld e,b			;6d0b
	jp (hl)			;6d0c
	ld c,(hl)			;6d0d
	ld b,e			;6d0e
	jr nz,l6d6fh		;6d0f
	call po,04345h		;6d11
	jr nz,l6d74h		;6d14
	call pe,02044h		;6d16
	ld e,(hl)			;6d19
	inc l			;6d1a
	ld e,e			;6d1b
	pop hl			;6d1c
	ld b,h			;6d1d
	ld b,h			;6d1e
	jr nz,l6d6ah		;6d1f
	ld e,b			;6d21
	inc l			;6d22
l6d23h:
	ld d,e			;6d23
	ld d,b			;6d24
	call pe,02044h		;6d25
	jp nz,05e2ch		;6d28
	jp 05e2ch		;6d2b
	call nz,05e2ch		;6d2e
	push bc			;6d31
	inc l			;6d32
	ld e,(hl)			;6d33
	ret z			;6d34
	inc l			;6d35
	ld e,(hl)			;6d36
	call z,05e2ch		;6d37
	call pe,02044h		;6d3a
	ld e,(hl)			;6d3d
	inc l			;6d3e
	jp nz,0c323h		;6d3f
l6d42h:
	inc hl			;6d42
	call nz,0c523h		;6d43
	inc hl			;6d46
	ret z			;6d47
	inc hl			;6d48
	call z,0c123h		;6d49
	call pe,02044h		;6d4c
	ld b,c			;6d4f
	inc l			;6d50
	ld e,(hl)			;6d51
	pop hl			;6d52
	ld b,h			;6d53
l6d54h:
	ld b,h			;6d54
	jr nz,l6d98h		;6d55
	inc l			;6d57
	ld e,(hl)			;6d58
	pop hl			;6d59
	ld b,h			;6d5a
	ld b,e			;6d5b
	jr nz,l6d9fh		;6d5c
	inc l			;6d5e
	ld e,(hl)			;6d5f
	di			;6d60
	ld d,l			;6d61
l6d62h:
	ld b,d			;6d62
	jr nz,l6dc3h		;6d63
	di			;6d65
	ld b,d			;6d66
	ld b,e			;6d67
	jr nz,$+67		;6d68
l6d6ah:
	inc l			;6d6a
	ld e,(hl)			;6d6b
	pop hl			;6d6c
	ld c,(hl)			;6d6d
	ld b,h			;6d6e
l6d6fh:
	jr nz,l6dcfh		;6d6f
	ret m			;6d71
	ld c,a			;6d72
	ld d,d			;6d73
l6d74h:
	jr nz,l6dd4h		;6d74
	rst 28h			;6d76
	ld d,d			;6d77
	jr nz,l6dd8h		;6d78
l6d7ah:
	ex (sp),hl			;6d7a
	ld d,b			;6d7b
	jr nz,l6ddch		;6d7c
	ret p			;6d7e
	ld c,a			;6d7f
	ld d,b			;6d80
	jr nz,l6dcch		;6d81
	ld e,b			;6d83
	push hl			;6d84
	ld e,b			;6d85
	jr nz,$+42		;6d86
	ld d,e			;6d88
	ld d,b			;6d89
	add hl,hl			;6d8a
	inc l			;6d8b
	ld c,c			;6d8c
	ld e,b			;6d8d
	ret p			;6d8e
	ld d,l			;6d8f
	ld d,e			;6d90
	ld c,b			;6d91
	jr nz,l6dddh		;6d92
	ld e,b			;6d94
	jp pe,02050h		;6d95
l6d98h:
	jr z,$+75		;6d98
	ld e,b			;6d9a
	add hl,hl			;6d9b
	call pe,02044h		;6d9c
l6d9fh:
	ld d,e			;6d9f
	ld d,b			;6da0
	inc l			;6da1
	ld c,c			;6da2
	ld e,b			;6da3
	jp p,0434ch		;6da4
	jr nz,l6e07h		;6da7
	jp p,04352h		;6da9
	jr nz,l6e0ch		;6dac
	jp p,0204ch		;6dae
	ld e,(hl)			;6db1
l6db2h:
	jp p,02052h		;6db2
	ld e,(hl)			;6db5
	di			;6db6
	ld c,h			;6db7
	ld b,c			;6db8
	jr nz,l6e19h		;6db9
	di			;6dbb
	ld d,d			;6dbc
	ld b,c			;6dbd
	jr nz,l6e1eh		;6dbe
	di			;6dc0
	ld d,d			;6dc1
	ld c,h			;6dc2
l6dc3h:
	jr nz,l6e23h		;6dc3
	jp po,05449h		;6dc5
	jr nz,l6d7ah		;6dc8
	inc l			;6dca
	ld e,(hl)			;6dcb
l6dcch:
	or c			;6dcc
	inc l			;6dcd
	ld e,(hl)			;6dce
l6dcfh:
	or d			;6dcf
	inc l			;6dd0
	ld e,(hl)			;6dd1
	or e			;6dd2
	inc l			;6dd3
l6dd4h:
	ld e,(hl)			;6dd4
	or h			;6dd5
	inc l			;6dd6
	ld e,(hl)			;6dd7
l6dd8h:
	or l			;6dd8
	inc l			;6dd9
	ld e,(hl)			;6dda
	or (hl)			;6ddb
l6ddch:
	inc l			;6ddc
l6dddh:
	ld e,(hl)			;6ddd
	or a			;6dde
	inc l			;6ddf
	ld e,(hl)			;6de0
	jp p,05345h		;6de1
	jr nz,$-78		;6de4
	inc l			;6de6
	ld e,(hl)			;6de7
	or c			;6de8
	inc l			;6de9
	ld e,(hl)			;6dea
	or d			;6deb
	inc l			;6dec
	ld e,(hl)			;6ded
	or e			;6dee
	inc l			;6def
	ld e,(hl)			;6df0
	or h			;6df1
	inc l			;6df2
	ld e,(hl)			;6df3
	or l			;6df4
	inc l			;6df5
	ld e,(hl)			;6df6
	or (hl)			;6df7
	inc l			;6df8
	ld e,(hl)			;6df9
	or a			;6dfa
	inc l			;6dfb
	ld e,(hl)			;6dfc
	di			;6dfd
	ld b,l			;6dfe
	ld d,h			;6dff
	jr nz,l6db2h		;6e00
	inc l			;6e02
	ld e,(hl)			;6e03
	or c			;6e04
	inc l			;6e05
	ld e,(hl)			;6e06
l6e07h:
	or d			;6e07
	inc l			;6e08
	ld e,(hl)			;6e09
	or e			;6e0a
	inc l			;6e0b
l6e0ch:
	ld e,(hl)			;6e0c
	or h			;6e0d
	inc l			;6e0e
	ld e,(hl)			;6e0f
	or l			;6e10
	inc l			;6e11
	ld e,(hl)			;6e12
	or (hl)			;6e13
	inc l			;6e14
	ld e,(hl)			;6e15
	or a			;6e16
	inc l			;6e17
	ld e,(hl)			;6e18
l6e19h:
	jp (hl)			;6e19
	ld c,(hl)			;6e1a
	jr nz,l6e5fh		;6e1b
	inc l			;6e1d
l6e1eh:
	jr z,l6e63h		;6e1e
	add hl,hl			;6e20
	rst 28h			;6e21
	ld d,l			;6e22
l6e23h:
	ld d,h			;6e23
	jr nz,l6e4eh		;6e24
	ld b,e			;6e26
	add hl,hl			;6e27
	inc l			;6e28
	ld b,d			;6e29
	di			;6e2a
	ld b,d			;6e2b
	ld b,e			;6e2c
	jr nz,l6e77h		;6e2d
	ld c,h			;6e2f
	inc l			;6e30
	ld b,d			;6e31
	ld b,e			;6e32
	call pe,02044h		;6e33
	jr z,$+95		;6e36
	add hl,hl			;6e38
	inc l			;6e39
	ld b,d			;6e3a
	ld b,e			;6e3b
	xor 045h		;6e3c
	ld b,a			;6e3e
	jp p,05445h		;6e3f
	ld c,(hl)			;6e42
	jp (hl)			;6e43
	ld c,l			;6e44
	jr nz,l6e77h		;6e45
	call pe,02044h		;6e47
	ld c,c			;6e4a
	inc l			;6e4b
	ld b,c			;6e4c
	jp (hl)			;6e4d
l6e4eh:
	ld c,(hl)			;6e4e
	jr nz,l6e94h		;6e4f
	inc l			;6e51
	jr z,l6e97h		;6e52
	add hl,hl			;6e54
	rst 28h			;6e55
	ld d,l			;6e56
	ld d,h			;6e57
	jr nz,l6e82h		;6e58
	ld b,e			;6e5a
	add hl,hl			;6e5b
	inc l			;6e5c
	ld b,e			;6e5d
	pop hl			;6e5e
l6e5fh:
	ld b,h			;6e5f
	ld b,e			;6e60
	jr nz,l6eabh		;6e61
l6e63h:
	ld c,h			;6e63
	inc l			;6e64
	ld b,d			;6e65
	ld b,e			;6e66
	call pe,02044h		;6e67
	ld b,d			;6e6a
	ld b,e			;6e6b
	inc l			;6e6c
	jr z,l6ecch		;6e6d
	add hl,hl			;6e6f
	and c			;6e70
	jp p,05445h		;6e71
	ld c,c			;6e74
	and c			;6e75
	and c			;6e76
l6e77h:
	jp (hl)			;6e77
	ld c,(hl)			;6e78
	jr nz,l6ebfh		;6e79
	inc l			;6e7b
	jr z,$+69		;6e7c
	add hl,hl			;6e7e
	rst 28h			;6e7f
	ld d,l			;6e80
	ld d,h			;6e81
l6e82h:
	jr nz,$+42		;6e82
	ld b,e			;6e84
	add hl,hl			;6e85
	inc l			;6e86
	ld b,h			;6e87
	di			;6e88
	ld b,d			;6e89
	ld b,e			;6e8a
	jr nz,l6ed5h		;6e8b
	ld c,h			;6e8d
	inc l			;6e8e
	ld b,h			;6e8f
	ld b,l			;6e90
	call pe,02044h		;6e91
l6e94h:
	jr z,l6ef3h		;6e94
	add hl,hl			;6e96
l6e97h:
	inc l			;6e97
	ld b,h			;6e98
	ld b,l			;6e99
	and c			;6e9a
	and c			;6e9b
	jp (hl)			;6e9c
	ld c,l			;6e9d
	jr nz,l6ed1h		;6e9e
	call pe,02044h		;6ea0
	ld b,c			;6ea3
	inc l			;6ea4
	ld c,c			;6ea5
	jp (hl)			;6ea6
	ld c,(hl)			;6ea7
	jr nz,$+71		;6ea8
	inc l			;6eaa
l6eabh:
	jr z,$+69		;6eab
	add hl,hl			;6ead
	rst 28h			;6eae
	ld d,l			;6eaf
	ld d,h			;6eb0
	jr nz,l6edbh		;6eb1
	ld b,e			;6eb3
	add hl,hl			;6eb4
	inc l			;6eb5
	ld b,l			;6eb6
	pop hl			;6eb7
	ld b,h			;6eb8
	ld b,e			;6eb9
	jr nz,l6f04h		;6eba
	ld c,h			;6ebc
	inc l			;6ebd
	ld b,h			;6ebe
l6ebfh:
	ld b,l			;6ebf
	call pe,02044h		;6ec0
	ld b,h			;6ec3
	ld b,l			;6ec4
	inc l			;6ec5
	jr z,l6f25h		;6ec6
	add hl,hl			;6ec8
	and c			;6ec9
	and c			;6eca
	jp (hl)			;6ecb
l6ecch:
	ld c,l			;6ecc
	jr nz,l6f01h		;6ecd
	and c			;6ecf
	jp (hl)			;6ed0
l6ed1h:
	ld c,(hl)			;6ed1
	jr nz,l6f1ch		;6ed2
	inc l			;6ed4
l6ed5h:
	jr z,l6f1ah		;6ed5
	add hl,hl			;6ed7
	rst 28h			;6ed8
	ld d,l			;6ed9
	ld d,h			;6eda
l6edbh:
	jr nz,l6f05h		;6edb
	ld b,e			;6edd
	add hl,hl			;6ede
	inc l			;6edf
	ld c,b			;6ee0
	di			;6ee1
	ld b,d			;6ee2
	ld b,e			;6ee3
	jr nz,l6f2eh		;6ee4
	ld c,h			;6ee6
	inc l			;6ee7
	ld c,b			;6ee8
	ld c,h			;6ee9
	and c			;6eea
	and c			;6eeb
	and c			;6eec
	and c			;6eed
	jp p,04452h		;6eee
	jp (hl)			;6ef1
	ld c,(hl)			;6ef2
l6ef3h:
	jr nz,l6f41h		;6ef3
	inc l			;6ef5
	jr z,l6f3bh		;6ef6
	add hl,hl			;6ef8
	rst 28h			;6ef9
	ld d,l			;6efa
	ld d,h			;6efb
	jr nz,l6f26h		;6efc
	ld b,e			;6efe
	add hl,hl			;6eff
	inc l			;6f00
l6f01h:
	ld c,h			;6f01
	pop hl			;6f02
	ld b,h			;6f03
l6f04h:
	ld b,e			;6f04
l6f05h:
	jr nz,l6f4fh		;6f05
	ld c,h			;6f07
	inc l			;6f08
	ld c,b			;6f09
	ld c,h			;6f0a
	and c			;6f0b
	and c			;6f0c
	and c			;6f0d
	and c			;6f0e
	jp p,0444ch		;6f0f
	and c			;6f12
	and c			;6f13
	di			;6f14
	ld b,d			;6f15
	ld b,e			;6f16
	jr nz,l6f61h		;6f17
	ld c,h			;6f19
l6f1ah:
	inc l			;6f1a
	ld d,e			;6f1b
l6f1ch:
	ld d,b			;6f1c
	call pe,02044h		;6f1d
	jr z,l6f7fh		;6f20
	add hl,hl			;6f22
	inc l			;6f23
	ld d,e			;6f24
l6f25h:
	ld d,b			;6f25
l6f26h:
	and c			;6f26
	and c			;6f27
	and c			;6f28
	and c			;6f29
	jp (hl)			;6f2a
	ld c,(hl)			;6f2b
	jr nz,l6f6fh		;6f2c
l6f2eh:
	inc l			;6f2e
	jr z,l6f74h		;6f2f
	add hl,hl			;6f31
	rst 28h			;6f32
	ld d,l			;6f33
	ld d,h			;6f34
	jr nz,l6f5fh		;6f35
	ld b,e			;6f37
	add hl,hl			;6f38
	inc l			;6f39
	ld b,c			;6f3a
l6f3bh:
	pop hl			;6f3b
	ld b,h			;6f3c
	ld b,e			;6f3d
	jr nz,l6f88h		;6f3e
	ld c,h			;6f40
l6f41h:
	inc l			;6f41
	ld d,e			;6f42
	ld d,b			;6f43
	call pe,02044h		;6f44
	ld d,e			;6f47
	ld d,b			;6f48
	inc l			;6f49
	jr z,$+95		;6f4a
	add hl,hl			;6f4c
	and c			;6f4d
	and c			;6f4e
l6f4fh:
	and c			;6f4f
	and c			;6f50
	and c			;6f51
	and c			;6f52
	and c			;6f53
	and c			;6f54
	and c			;6f55
	and c			;6f56
	and c			;6f57
	and c			;6f58
	and c			;6f59
	and c			;6f5a
	and c			;6f5b
	and c			;6f5c
	and c			;6f5d
	and c			;6f5e
l6f5fh:
	and c			;6f5f
	and c			;6f60
l6f61h:
	and c			;6f61
	and c			;6f62
	and c			;6f63
	and c			;6f64
	and c			;6f65
	and c			;6f66
	and c			;6f67
	and c			;6f68
	and c			;6f69
	and c			;6f6a
	and c			;6f6b
	and c			;6f6c
	and c			;6f6d
	and c			;6f6e
l6f6fh:
	and c			;6f6f
	and c			;6f70
	call pe,04944h		;6f71
l6f74h:
	ex (sp),hl			;6f74
	ld d,b			;6f75
	ld c,c			;6f76
	jp (hl)			;6f77
	ld c,(hl)			;6f78
	ld c,c			;6f79
	rst 28h			;6f7a
	ld d,l			;6f7b
	ld d,h			;6f7c
	ld c,c			;6f7d
	and c			;6f7e
l6f7fh:
	and c			;6f7f
	and c			;6f80
	and c			;6f81
	call pe,04444h		;6f82
	ex (sp),hl			;6f85
	ld d,b			;6f86
	ld b,h			;6f87
l6f88h:
	jp (hl)			;6f88
	ld c,(hl)			;6f89
	ld b,h			;6f8a
	rst 28h			;6f8b
	ld d,l			;6f8c
	ld d,h			;6f8d
	ld b,h			;6f8e
	and c			;6f8f
	and c			;6f90
	and c			;6f91
	and c			;6f92
	call pe,04944h		;6f93
	ld d,d			;6f96
	ex (sp),hl			;6f97
	ld d,b			;6f98
	ld c,c			;6f99
	ld d,d			;6f9a
	jp (hl)			;6f9b
	ld c,(hl)			;6f9c
	ld c,c			;6f9d
	ld d,d			;6f9e
	rst 28h			;6f9f
	ld d,h			;6fa0
	ld c,c			;6fa1
	ld d,d			;6fa2
	and c			;6fa3
	and c			;6fa4
	and c			;6fa5
	and c			;6fa6
	call pe,04444h		;6fa7
	ld d,d			;6faa
	ex (sp),hl			;6fab
	ld d,b			;6fac
	ld b,h			;6fad
	ld d,d			;6fae
	jp (hl)			;6faf
	ld c,(hl)			;6fb0
	ld b,h			;6fb1
	ld d,d			;6fb2
	rst 28h			;6fb3
	ld d,h			;6fb4
	ld b,h			;6fb5
	ld d,d			;6fb6
	rst 38h			;6fb7
l6fb8h:
	add hl,bc			;6fb8
	add hl,de			;6fb9
	ld hl,02322h		;6fba
	add hl,hl			;6fbd
	ld hl,(0342bh)		;6fbe
	dec (hl)			;6fc1
	ld (hl),039h		;6fc2
	ld b,(hl)			;6fc4
	ld c,(hl)			;6fc5
	ld d,(hl)			;6fc6
	ld e,(hl)			;6fc7
	ld h,(hl)			;6fc8
	ld l,(hl)			;6fc9
	ld (hl),b			;6fca
	ld (hl),c			;6fcb
	ld (hl),d			;6fcc
	ld (hl),e			;6fcd
	ld (hl),h			;6fce
	ld (hl),l			;6fcf
	ld (hl),a			;6fd0
	ld a,(hl)			;6fd1
	add a,(hl)			;6fd2
	adc a,(hl)			;6fd3
	sub (hl)			;6fd4
	sbc a,(hl)			;6fd5
	and (hl)			;6fd6
	xor (hl)			;6fd7
	or (hl)			;6fd8
	cp (hl)			;6fd9
	pop hl			;6fda
	ex (sp),hl			;6fdb
	push hl			;6fdc
	jp (hl)			;6fdd
	ld sp,hl			;6fde
	ld b,00eh		;6fdf
	ld d,01eh		;6fe1
	ld h,02eh		;6fe3
	ld a,046h		;6fe5
	ld c,(hl)			;6fe7
	ld d,(hl)			;6fe8
	ld e,(hl)			;6fe9
	ld h,(hl)			;6fea
	ld l,(hl)			;6feb
	halt			;6fec
	ld a,(hl)			;6fed
	add a,(hl)			;6fee
	adc a,(hl)			;6fef
	sub (hl)			;6ff0
	sbc a,(hl)			;6ff1
	and (hl)			;6ff2
	xor (hl)			;6ff3
	or (hl)			;6ff4
	cp (hl)			;6ff5
	add a,0ceh		;6ff6
	sub 0deh		;6ff8
	and 0eeh		;6ffa
	or 0feh		;6ffc
	sub l			;6ffe
	rst 38h			;6fff

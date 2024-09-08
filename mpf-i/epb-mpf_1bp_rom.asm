; z80dasm 1.1.6
; command line: z80dasm -a -l -g 36864 -o mpf1_1pb_rom.asm EPB-MPF-1BP.bin

	;; Entry point for MPF1 (as opposed to MPF1P) is $9800 (labelled
	;; MPF1_START)

	;; MPF1 to EPB Key mapping
	;; REG  	= READ 		= $1B
	;; GO   	= GO   		= $12
	;; SBR  	= PROGRAM 	= $15
	;; INS          = INS		= $16
	;; DEL		= DEL		= $17
	;; PC		= VERIFY	= $18
	;; CBR		= LIST 		= $1A
	;; TAPE_WRITE	= TAPE_WRITE	= $1E
	;; TAPE_READ	= TAPE_READ	= $1F
	
	include "mpf1_monitor.sym"

EPB_VAR: equ SYSVARS-$0100 ; Location of system variables
	
	org	09000h

	call 009b9h		;9000
	ld hl,0d800h		;9003
	ld bc,00800h		;9006
l9009h:
	call 00819h		;9009
	jr nz,$+10		;900c
	cpi		;900e
	jp pe,l9009h		;9010
	jr l901ch		;9013
	ld a,021h		;9015
	nop			;9017
	sub a			;9018
	call sub_934eh		;9019
l901ch:
	ld hl,0e000h		;901c
	ld bc,00800h		;901f
l9022h:
	call 00819h		;9022
	jr nz,l902fh		;9025
	cpi		;9027
	jp pe,l9022h		;9029
	jr l9035h		;902c
	adc a,(hl)			;902e
l902fh:
	ld hl,l9711h		;902f
	call sub_934eh		;9032
l9035h:
	ld hl,0e800h		;9035
	ld bc,00800h		;9038
l903bh:
	call 00819h		;903b
	jr nz,$+10		;903e
	cpi		;9040
	jp pe,l903bh		;9042
	jr l904eh		;9045
	jr z,l906ah		;9047
	ld (0cd97h),hl		;9049
	ld c,(hl)			;904c
	sub e			;904d
l904eh:
	ld hl,0f000h		;904e
	ld bc,00800h		;9051
l9054h:
	call 00819h		;9054
	jr nz,l9061h		;9057
	cpi		;9059
	jp pe,l9054h		;905b
	jr l9067h		;905e
	ld c,l			;9060
l9061h:
	ld hl,l9733h		;9061
	call sub_934eh		;9064
l9067h:
	call sub_9171h		;9067
l906ah:
	call 009b9h		;906a
	ld hl,0fd05h		;906d
	ld (hl),003h		;9070
l9072h:
	ld a,023h		;9072
	call 00924h		;9074
	call 009d4h		;9077
	ld hl,(0ff86h)		;907a
	ld a,(hl)			;907d
	inc hl			;907e
	ld (0ff86h),hl		;907f
	ld (0ff7eh),hl		;9082
	push af			;9085
	call 0093bh		;9086
	pop af			;9089
	call sub_9090h		;908a
	jr l9072h		;908d
	ld (hl),h			;908f
sub_9090h:
	cp 043h		;9090
	jp z,l913eh		;9092
	cp 04eh		;9095
	jr z,l9102h		;9097
	cp 053h		;9099
	jr z,l9109h		;909b
	cp 058h		;909d
	jr z,l9114h		;909f
	cp 048h		;90a1
	jr z,l911ah		;90a3
	cp 04dh		;90a5
	jp z,l920bh		;90a7
	cp 044h		;90aa
	jp z,l9291h		;90ac
	cp 049h		;90af
	jp z,l92c7h		;90b1
	cp 046h		;90b4
	jp z,l930fh		;90b6
	cp 04ch		;90b9
	jp z,l93edh		;90bb
	cp 057h		;90be
	jp z,l93c4h		;90c0
	cp 052h		;90c3
	jp z,l93f3h		;90c5
	cp 050h		;90c8
	jp z,l949ch		;90ca
	cp 056h		;90cd
	jp z,l9365h		;90cf
	cp 051h		;90d2
	jr z,l910fh		;90d4
l90d6h:
	call 009b9h		;90d6
	ld a,03fh		;90d9
	jp 00924h		;90db
l90deh:
	call 009b9h		;90de
	call 009cah		;90e1
	call 00399h		;90e4
	ld hl,004b0h		;90e7
	ld c,01eh		;90ea
	call 00874h		;90ec
	ld a,0ffh		;90ef
	out (092h),a		;90f1
l90f3h:
	ld b,040h		;90f3
	ld ix,0ff2ch		;90f5
l90f9h:
	call 0029bh		;90f9
	djnz l90f9h		;90fc
	call 009b9h		;90fe
	ret			;9101
l9102h:
	call sub_9171h		;9102
	call 009b9h		;9105
	ret			;9108
l9109h:
	ld hl,0fd05h		;9109
	ld (hl),001h		;910c
	ret			;910e
l910fh:
	pop hl			;910f
	call 007f6h		;9110
	ret			;9113
l9114h:
	ld hl,0fd05h		;9114
	ld (hl),003h		;9117
	ret			;9119
l911ah:
	ld hl,(0fd00h)		;911a
	call 009b9h		;911d
	call 00a89h		;9120
	call 00a95h		;9123
	ld a,(0fd05h)		;9126
	cp 001h		;9129
	jr nz,l9133h		;912b
	ld hl,l97c6h		;912d
	jr l9136h		;9130
	dec a			;9132
l9133h:
	ld hl,l97cch		;9133
l9136h:
	call 009cah		;9136
	call 00399h		;9139
	jr l90f3h		;913c
l913eh:
	ld de,00000h		;913e
	ld hl,0d800h		;9141
	ld bc,(0fd03h)		;9144
l9148h:
	ld a,e			;9148
	add a,(hl)			;9149
	ld e,a			;914a
	ld a,d			;914b
	adc a,000h		;914c
	ld d,a			;914e
	cpi		;914f
	jp pe,l9148h		;9151
	ld hl,l97d1h		;9154
	call 009cah		;9157
	ld h,d			;915a
	ld l,e			;915b
	call 00a89h		;915c
	call 00399h		;915f
	ld ix,0ff2ch		;9162
l9166h:
	call 00246h		;9166
	cp 051h		;9169
	jr nz,l9166h		;916b
	call 009b9h		;916d
	ret			;9170
sub_9171h:
	ld hl,l9746h		;9171
	call 009cah		;9174
l9177h:
	call 0066fh		;9177
	call 00854h		;917a
	jr c,l9177h		;917d
	call 008dfh		;917f
	ld (0fd00h),hl		;9182
	ld a,h			;9185
	cp 025h		;9186
	jr nz,l91b1h		;9188
	ld a,l			;918a
	ld hl,0fd02h		;918b
	cp 008h		;918e
	jr nz,l9196h		;9190
	ld (hl),001h		;9192
	jr l91d9h		;9194
l9196h:
	cp 016h		;9196
	jr nz,l919eh		;9198
	ld (hl),003h		;919a
	jr l91d9h		;919c
l919eh:
	cp 032h		;919e
	jr nz,l91a6h		;91a0
	ld (hl),005h		;91a2
	jr l91d9h		;91a4
l91a6h:
	cp 064h		;91a6
	jr nz,l91aeh		;91a8
	ld (hl),007h		;91aa
	jr l91d9h		;91ac
l91aeh:
	scf			;91ae
	jr l9177h		;91af
l91b1h:
	cp 027h		;91b1
	jr nz,l91aeh		;91b3
	ld a,l			;91b5
	ld hl,0fd02h		;91b6
	cp 058h		;91b9
	jr nz,l91c1h		;91bb
	ld (hl),000h		;91bd
	jr l91d9h		;91bf
l91c1h:
	cp 016h		;91c1
	jr nz,l91c9h		;91c3
	ld (hl),002h		;91c5
	jr l91d9h		;91c7
l91c9h:
	cp 032h		;91c9
	jr nz,l91d1h		;91cb
	ld (hl),004h		;91cd
	jr l91d9h		;91cf
l91d1h:
	cp 064h		;91d1
	jr nz,l91aeh		;91d3
	ld (hl),006h		;91d5
	jr l91d9h		;91d7
l91d9h:
	ld a,(hl)			;91d9
	ld hl,l978ah		;91da
	bit 0,a		;91dd
	jr z,l91e3h		;91df
	sub 001h		;91e1
l91e3h:
	add a,l			;91e3
	ld l,a			;91e4
	ld de,0fd03h		;91e5
	ld bc,00002h		;91e8
	ldir		;91eb
	ld hl,l9791h+1		;91ed
	call sub_9200h		;91f0
	ld (0fd06h),hl		;91f3
	ld hl,l97a2h		;91f6
	call sub_9200h		;91f9
	ld (0fd08h),hl		;91fc
	ret			;91ff
sub_9200h:
	ld a,(0fd02h)		;9200
	add a,a			;9203
	add a,l			;9204
	ld l,a			;9205
	ld a,(hl)			;9206
	inc hl			;9207
	ld h,(hl)			;9208
	ld l,a			;9209
	ret			;920a
l920bh:
	push hl			;920b
	call sub_9347h		;920c
	pop hl			;920f
	jp c,l90d6h		;9210
	ld (0ff7eh),hl		;9213
	call 008e5h		;9216
	ld bc,0d800h		;9219
	add hl,bc			;921c
	ld (0fef8h),hl		;921d
	ld a,(de)			;9220
	cp 03ah		;9221
	jp z,l924eh		;9223
	cp 02fh		;9226
	jp z,09259h		;9228
l922bh:
	call sub_9282h		;922b
	call 00328h		;922e
	ld a,h			;9231
	sub 0d8h		;9232
	ld h,a			;9234
	call 00a89h		;9235
	call 00386h		;9238
l923bh:
	call 00246h		;923b
	cp 069h		;923e
	jr z,l926dh		;9240
	cp 05eh		;9242
	jr z,l9279h		;9244
	cp 051h		;9246
	jr nz,l923bh		;9248
	call 009b9h		;924a
	ret			;924d
l924eh:
	push hl			;924e
	call 008e5h		;924f
	pop hl			;9252
	ld (hl),a			;9253
	ret z			;9254
	inc hl			;9255
	jr l924eh		;9256
	jr l927ch		;9258
	ret nc			;925a
	cp 0cdh		;925b
	push hl			;925d
	ex af,af'			;925e
	add hl,bc			;925f
	ld (0fed2h),hl		;9260
	call 008e5h		;9263
	add hl,bc			;9266
	ld (0fed4h),hl		;9267
	jp 00365h		;926a
l926dh:
	ld hl,(0fef8h)		;926d
	inc hl			;9270
	inc hl			;9271
	inc hl			;9272
	inc hl			;9273
l9274h:
	ld (0fef8h),hl		;9274
	jr l922bh		;9277
l9279h:
	ld hl,(0fef8h)		;9279
l927ch:
	dec hl			;927c
	dec hl			;927d
	dec hl			;927e
	dec hl			;927f
	jr l9274h		;9280
sub_9282h:
	call 009b9h		;9282
	push hl			;9285
	ld hl,l9775h		;9286
	call 009cah		;9289
	call 00399h		;928c
	pop hl			;928f
	ret			;9290
l9291h:
	push hl			;9291
	call sub_9347h		;9292
	pop hl			;9295
	jp c,l90d6h		;9296
	ld (0ff7eh),hl		;9299
	call 008e5h		;929c
	jp z,l90d6h		;929f
	push af			;92a2
	ld bc,0d800h		;92a3
	add hl,bc			;92a6
	ld (0fed4h),hl		;92a7
	inc hl			;92aa
	ld (0fed0h),hl		;92ab
	pop af			;92ae
	jr z,l92bbh		;92af
	call 008e5h		;92b1
	jp nz,l90d6h		;92b4
	add hl,bc			;92b7
	ld (0feebh),hl		;92b8
l92bbh:
	ld hl,(0feebh)		;92bb
	ld (0fed2h),hl		;92be
	call 00365h		;92c1
	xor a			;92c4
	ld (de),a			;92c5
	ret			;92c6
l92c7h:
	push hl			;92c7
	call sub_9347h		;92c8
	pop hl			;92cb
	jp c,l90d6h		;92cc
	ld (0ff7eh),hl		;92cf
	call 008e5h		;92d2
	jp z,l90d6h		;92d5
	ld bc,0d800h		;92d8
	add hl,bc			;92db
	push hl			;92dc
	call 008e5h		;92dd
	add hl,bc			;92e0
	ld (0feebh),hl		;92e1
	pop hl			;92e4
l92e5h:
	ld (0fed0h),hl		;92e5
	inc hl			;92e8
	ld (0fed4h),hl		;92e9
	ld de,(0feebh)		;92ec
	dec de			;92f0
	ld (0fed2h),de		;92f1
	inc de			;92f5
	and a			;92f6
	sbc hl,de		;92f7
	jp nc,l90d6h		;92f9
	call 008e5h		;92fc
	push af			;92ff
	call 00365h		;9300
	ld hl,(0fed4h)		;9303
	ld (hl),a			;9306
	ld hl,(0fed0h)		;9307
	inc hl			;930a
	pop af			;930b
	ret z			;930c
	jr l92e5h		;930d
l930fh:
	push hl			;930f
	call 00854h		;9310
	pop hl			;9313
	jp c,l90d6h		;9314
	ld (0ff7eh),hl		;9317
	ld bc,0d800h		;931a
	call 008e5h		;931d
	jp z,l90d6h		;9320
	add hl,bc			;9323
	push hl			;9324
	call 008e5h		;9325
	pop de			;9328
	jp z,l90d6h		;9329
	push de			;932c
	add hl,bc			;932d
	push hl			;932e
	call 008e5h		;932f
	pop hl			;9332
	pop de			;9333
	jp nz,l90d6h		;9334
	and a			;9337
	ld (de),a			;9338
	sbc hl,de		;9339
	ret z			;933b
	jp c,l90d6h		;933c
	ld b,h			;933f
	ld c,l			;9340
	ld h,d			;9341
	ld l,e			;9342
	inc de			;9343
	ldir		;9344
	ret			;9346
sub_9347h:
	call 008e5h		;9347
	ret c			;934a
	ret z			;934b
	jr sub_9347h		;934c
sub_934eh:
	call 009cah		;934e
	ld ix,0ff2ch		;9351
l9355h:
	call 00246h		;9355
	cp 00dh		;9358
	jr z,l9361h		;935a
	cp 051h		;935c
	jr nz,l9355h		;935e
	pop hl			;9360
l9361h:
	call 009b9h		;9361
	ret			;9364
l9365h:
	call sub_968bh		;9365
	jp c,l90d6h		;9368
	jp nz,l90d6h		;936b
l936eh:
	call sub_940ch		;936e
	cpi		;9371
	jr nz,l937fh		;9373
	inc de			;9375
	jp pe,l936eh		;9376
	ld hl,l9759h		;9379
	jp l90deh		;937c
l937fh:
	push af			;937f
	push hl			;9380
	ld a,023h		;9381
	call 00924h		;9383
	ld a,056h		;9386
	call 00924h		;9388
	call 00a95h		;938b
	ld h,d			;938e
	ld l,e			;938f
	call 00a92h		;9390
	pop hl			;9393
	dec hl			;9394
	ld a,(hl)			;9395
	call 00a9ah		;9396
	call 00a95h		;9399
	pop af			;939c
	call 00a9ah		;939d
	inc hl			;93a0
	inc de			;93a1
	push hl			;93a2
	push de			;93a3
	push bc			;93a4
	ld ix,0ff2ch		;93a5
l93a9h:
	call 00246h		;93a9
	cp 051h		;93ac
	jr nz,l93b7h		;93ae
	call 009b9h		;93b0
	pop bc			;93b3
	pop de			;93b4
	pop hl			;93b5
	ret			;93b6
l93b7h:
	cp 00dh		;93b7
	jr nz,l93a9h		;93b9
	call 009b9h		;93bb
	pop bc			;93be
	pop de			;93bf
	pop hl			;93c0
	jr l936eh		;93c1
	ld d,h			;93c3
l93c4h:
	call 008e5h		;93c4
	jp c,l90d6h		;93c7
	jp z,l90d6h		;93ca
	ld bc,0d800h		;93cd
	add hl,bc			;93d0
	ld (0fed4h),hl		;93d1
	call 008e5h		;93d4
	jp c,l90d6h		;93d7
	jp z,l90d6h		;93da
	add hl,bc			;93dd
	ld (0fed6h),hl		;93de
	call 0068fh		;93e1
l93e4h:
	ld a,(0ff05h)		;93e4
	cp 045h		;93e7
	ret nz			;93e9
	jp l90d6h		;93ea
l93edh:
	call 006d0h		;93ed
	jr l93e4h		;93f0
	ld l,d			;93f2
l93f3h:
	call sub_968bh		;93f3
	jp c,l90d6h		;93f6
	jp nz,l90d6h		;93f9
l93fch:
	call sub_940ch		;93fc
	ld (hl),a			;93ff
	inc de			;9400
	cpi		;9401
	jp pe,l93fch		;9403
	ld hl,l974eh		;9406
	jp l90deh		;9409
sub_940ch:
	push hl			;940c
	ld a,090h		;940d
	out (07fh),a		;940f
	ld hl,(0fd06h)		;9411
	jp (hl)			;9414
	ld a,e			;9415
	out (07dh),a		;9416
	ld a,d			;9418
	and 017h		;9419
	or 020h		;941b
	out (07eh),a		;941d
	bit 3,d		;941f
	jr z,$+7		;9421
	ld a,008h		;9423
	jr $+5		;9425
	ld a,03eh		;9427
	jr z,$-43		;9429
	ld (hl),b			;942b
	nop			;942c
	in a,(07ch)		;942d
	push af			;942f
	xor a			;9430
	out (070h),a		;9431
	ld a,008h		;9433
	out (07eh),a		;9435
	pop af			;9437
	pop hl			;9438
	ret			;9439
	ld a,e			;943a
	out (07dh),a		;943b
	ld a,d			;943d
	and 00fh		;943e
	out (07eh),a		;9440
	ld a,008h		;9442
	out (070h),a		;9444
	nop			;9446
	in a,(07ch)		;9447
	push af			;9449
	xor a			;944a
	out (070h),a		;944b
	pop af			;944d
	pop hl			;944e
	ret			;944f
	ld a,e			;9450
	out (07dh),a		;9451
	ld a,d			;9453
	and 00fh		;9454
	or 030h		;9456
	out (07eh),a		;9458
	bit 4,d		;945a
	jr z,l9462h		;945c
	ld a,008h		;945e
	jr l9464h		;9460
l9462h:
	ld a,028h		;9462
l9464h:
	out (070h),a		;9464
	ld a,d			;9466
	and 00fh		;9467
	out (07eh),a		;9469
	nop			;946b
	in a,(07ch)		;946c
	push af			;946e
	xor a			;946f
	out (078h),a		;9470
	pop af			;9472
	pop hl			;9473
	ret			;9474
l9475h:
	call 009b9h		;9475
	ld hl,l9779h		;9478
	call 009cah		;947b
	ld hl,00258h		;947e
	ld c,01eh		;9481
	call 00874h		;9483
	ld ix,0ff2ch		;9486
l948ah:
	call 00246h		;948a
	cp 00dh		;948d
	jr z,l94e0h		;948f
	cp 051h		;9491
	jr nz,l948ah		;9493
	pop bc			;9495
	pop de			;9496
	pop hl			;9497
	call 009b9h		;9498
	ret			;949b
l949ch:
	call sub_968bh		;949c
	jp c,l90d6h		;949f
	jp nz,l90d6h		;94a2
	push hl			;94a5
	push de			;94a6
	push bc			;94a7
	call 009b9h		;94a8
	ld hl,l97b0h+2		;94ab
	call 009cah		;94ae
	ld hl,00258h		;94b1
	ld c,01eh		;94b4
	call 00874h		;94b6
	ld ix,0ff2ch		;94b9
l94bdh:
	call 00246h		;94bd
	cp 059h		;94c0
	jr z,l94cfh		;94c2
	cp 04eh		;94c4
	jr nz,l94bdh		;94c6
	pop bc			;94c8
	pop de			;94c9
	pop hl			;94ca
	call 009b9h		;94cb
	ret			;94ce
l94cfh:
	pop bc			;94cf
	pop de			;94d0
	push de			;94d1
	push bc			;94d2
l94d3h:
	call sub_940ch		;94d3
	cp 0ffh		;94d6
	jr nz,l9475h		;94d8
	inc de			;94da
	cpi		;94db
	jp pe,l94d3h		;94dd
l94e0h:
	pop bc			;94e0
	pop de			;94e1
	pop hl			;94e2
l94e3h:
	ld a,(hl)			;94e3
	cp 0ffh		;94e4
	jr z,l9510h		;94e6
	push bc			;94e8
	push af			;94e9
	call sub_9563h		;94ea
	call sub_940ch		;94ed
	ld b,a			;94f0
	pop af			;94f1
	cp b			;94f2
	jr nz,l951ch		;94f3
	pop bc			;94f5
	ex af,af'			;94f6
	cp 011h		;94f7
	jr nz,l9510h		;94f9
l94fbh:
	push hl			;94fb
	push bc			;94fc
	push de			;94fd
	call 00246h		;94fe
	pop de			;9501
	pop bc			;9502
	pop hl			;9503
	cp 00dh		;9504
	jr z,l9510h		;9506
	cp 051h		;9508
	jr nz,l94fbh		;950a
	call 009b9h		;950c
	ret			;950f
l9510h:
	inc de			;9510
	cpi		;9511
	jp pe,l94e3h		;9513
l9516h:
	ld hl,l9764h		;9516
	jp l90deh		;9519
l951ch:
	push hl			;951c
	push de			;951d
	push af			;951e
	call 009b9h		;951f
	ld a,023h		;9522
	call 00924h		;9524
	ld a,050h		;9527
	call 00924h		;9529
	call 00a95h		;952c
	ld h,d			;952f
	ld l,e			;9530
	call 00a89h		;9531
	call 00a95h		;9534
	pop af			;9537
	call 00a9ah		;9538
	call 00a95h		;953b
	ld a,b			;953e
	call 00a9ah		;953f
	ld ix,0ff2ch		;9542
l9546h:
	call 00246h		;9546
	cp 00dh		;9549
	jr z,l9551h		;954b
	cp 051h		;954d
	jr nz,l9546h		;954f
l9551h:
	call 009b9h		;9551
	pop de			;9554
	pop hl			;9555
	pop bc			;9556
	cp 051h		;9557
	ret z			;9559
	inc de			;955a
	cpi		;955b
	jp pe,l94e3h		;955d
	jr l9516h		;9560
	ld a,d			;9562
sub_9563h:
	push af			;9563
	push hl			;9564
	push af			;9565
	ld a,080h		;9566
	out (07fh),a		;9568
	ld hl,(0fd08h)		;956a
	jp (hl)			;956d
	ld a,0f1h		;956e
	pop hl			;9570
	out (07ch),a		;9571
	xor a			;9573
	out (07eh),a		;9574
	ld a,010h		;9576
	out (070h),a		;9578
	ld a,e			;957a
	out (07dh),a		;957b
	ld a,d			;957d
	and 007h		;957e
	or 008h		;9580
	out (07eh),a		;9582
	pop af			;9584
	call sub_9646h		;9585
	xor a			;9588
	out (070h),a		;9589
	ld b,028h		;958b
l958dh:
	djnz l958dh		;958d
	ret			;958f
	pop af			;9590
	pop hl			;9591
	out (07ch),a		;9592
	ld a,010h		;9594
	out (070h),a		;9596
	ld a,e			;9598
	out (07dh),a		;9599
	ld a,d			;959b
	and 00fh		;959c
	out (07eh),a		;959e
	nop			;95a0
	ld a,018h		;95a1
	out (070h),a		;95a3
	pop af			;95a5
	call sub_9646h		;95a6
	xor a			;95a9
	out (070h),a		;95aa
	ld b,028h		;95ac
l95aeh:
	djnz l95aeh		;95ae
	ret			;95b0
	pop af			;95b1
	pop hl			;95b2
	out (07ch),a		;95b3
	ld a,008h		;95b5
	out (07eh),a		;95b7
	ld a,e			;95b9
	out (07dh),a		;95ba
	bit 3,d		;95bc
	ld a,024h		;95be
	jr z,l95c4h		;95c0
	ld a,004h		;95c2
l95c4h:
	out (070h),a		;95c4
	ld a,d			;95c6
	and 007h		;95c7
	or 008h		;95c9
	out (07eh),a		;95cb
	nop			;95cd
	and 007h		;95ce
	out (07eh),a		;95d0
	pop af			;95d2
	call sub_9646h		;95d3
	ld a,0ffh		;95d6
	out (07eh),a		;95d8
	xor a			;95da
	out (070h),a		;95db
	ld b,028h		;95dd
l95dfh:
	djnz l95dfh		;95df
	ret			;95e1
	pop af			;95e2
	pop hl			;95e3
	out (07ch),a		;95e4
	ld a,e			;95e6
	out (07dh),a		;95e7
	ld a,d			;95e9
	and 00fh		;95ea
	out (07eh),a		;95ec
	ld a,020h		;95ee
	bit 4,d		;95f0
	jr z,l95f6h		;95f2
	ld a,000h		;95f4
l95f6h:
	out (070h),a		;95f6
	or 009h		;95f8
	nop			;95fa
	out (070h),a		;95fb
	pop af			;95fd
	call sub_9646h		;95fe
	ld a,020h		;9601
	bit 4,d		;9603
	jr z,l9608h		;9605
	xor a			;9607
l9608h:
	out (070h),a		;9608
	ld b,028h		;960a
l960ch:
	djnz l960ch		;960c
	ret			;960e
	pop af			;960f
	pop hl			;9610
	out (07ch),a		;9611
	ld a,020h		;9613
	out (07eh),a		;9615
	ld a,e			;9617
	out (07dh),a		;9618
	ld a,001h		;961a
	bit 3,d		;961c
	jr nz,l9622h		;961e
	set 5,a		;9620
l9622h:
	out (070h),a		;9622
	ld a,d			;9624
	and 007h		;9625
	or 020h		;9627
	bit 4,d		;9629
	jr z,l962fh		;962b
	set 4,a		;962d
l962fh:
	out (07eh),a		;962f
	and 0dfh		;9631
	nop			;9633
	out (07eh),a		;9634
	pop af			;9636
	call sub_9646h		;9637
	ld a,028h		;963a
	out (07eh),a		;963c
	xor a			;963e
	out (070h),a		;963f
	ld b,028h		;9641
l9643h:
	djnz l9643h		;9643
	ret			;9645
sub_9646h:
	push bc			;9646
	push de			;9647
	push hl			;9648
	push af			;9649
	ld a,(0fd05h)		;964a
	ld b,a			;964d
	pop af			;964e
l964fh:
	call 009b9h		;964f
	push af			;9652
	ld a,023h		;9653
	call 00924h		;9655
	ld a,050h		;9658
	call 00924h		;965a
	call 00a95h		;965d
	ld h,d			;9660
	ld l,e			;9661
	call 00a89h		;9662
	call 00a95h		;9665
	pop af			;9668
	call 00a9ah		;9669
	call 00399h		;966c
	ld ix,0ff2ch		;966f
	call 0029bh		;9673
	djnz l964fh		;9676
	jr c,l9687h		;9678
	cp 01eh		;967a
	jr nz,l9687h		;967c
	in a,(082h)		;967e
	bit 5,a		;9680
	jr nz,l9686h		;9682
	ld a,011h		;9684
l9686h:
	ex af,af'			;9686
l9687h:
	pop hl			;9687
	pop de			;9688
	pop bc			;9689
	ret			;968a
sub_968bh:
	push hl			;968b
	call sub_9347h		;968c
	pop hl			;968f
	ret c			;9690
	push hl			;9691
	call 008b1h		;9692
	pop hl			;9695
	jr z,l96c2h		;9696
	ld (0ff7eh),hl		;9698
	call 008e5h		;969b
	ld d,h			;969e
	ld e,l			;969f
	jr nz,l96a7h		;96a0
	ld bc,00001h		;96a2
	jr l96c9h		;96a5
l96a7h:
	push de			;96a7
	call 008e5h		;96a8
	pop de			;96ab
	ret nz			;96ac
	ld b,h			;96ad
	ld c,l			;96ae
	ld hl,(0fd03h)		;96af
	dec hl			;96b2
	ld a,l			;96b3
	sub e			;96b4
	ld l,a			;96b5
	ld a,h			;96b6
	sbc a,d			;96b7
	ld h,a			;96b8
	ret c			;96b9
	inc hl			;96ba
	ld a,l			;96bb
	sub c			;96bc
	ld a,h			;96bd
	sbc a,b			;96be
	ret c			;96bf
	jr l96c9h		;96c0
l96c2h:
	ld de,00000h		;96c2
	ld bc,(0fd03h)		;96c5
l96c9h:
	ld hl,0d800h		;96c9
	add hl,de			;96cc
	xor a			;96cd
	ret			;96ce
	rst 38h			;96cf
	rst 38h			;96d0
	rst 38h			;96d1
	rst 38h			;96d2
	rst 38h			;96d3
	rst 38h			;96d4
	rst 38h			;96d5
	rst 38h			;96d6
	rst 38h			;96d7
	rst 38h			;96d8
	rst 38h			;96d9
	rst 38h			;96da
	rst 38h			;96db
	rst 38h			;96dc
	rst 38h			;96dd
	rst 38h			;96de
	rst 38h			;96df
	rst 38h			;96e0
	rst 38h			;96e1
	rst 38h			;96e2
	rst 38h			;96e3
	rst 38h			;96e4
	rst 38h			;96e5
	rst 38h			;96e6
	rst 38h			;96e7
	rst 38h			;96e8
	rst 38h			;96e9
	rst 38h			;96ea
	rst 38h			;96eb
	rst 38h			;96ec
	rst 38h			;96ed
	rst 38h			;96ee
	rst 38h			;96ef
	rst 38h			;96f0
	rst 38h			;96f1
	rst 38h			;96f2
	rst 38h			;96f3
	rst 38h			;96f4
	rst 38h			;96f5
	rst 38h			;96f6
	rst 38h			;96f7
	rst 38h			;96f8
	rst 38h			;96f9
	rst 38h			;96fa
	rst 38h			;96fb
	rst 38h			;96fc
	rst 38h			;96fd
	rst 38h			;96fe
	rst 38h			;96ff
	ld d,d			;9700
	ld b,c			;9701
	ld c,l			;9702
	jr nz,l975ah		;9703
	dec (hl)			;9705
	dec l			;9706
	ld b,l			;9707
	ld d,b			;9708
	ld b,d			;9709
	jr nz,l9751h		;970a
	ld d,d			;970c
	ld d,d			;970d
	ld c,a			;970e
	ld d,d			;970f
	dec c			;9710
l9711h:
	ld d,d			;9711
	ld b,c			;9712
	ld c,l			;9713
	jr nz,l976bh		;9714
	ld (hl),02dh		;9716
	ld b,l			;9718
	ld d,b			;9719
	ld b,d			;971a
	jr nz,l9762h		;971b
	ld d,d			;971d
	ld d,d			;971e
	ld c,a			;971f
	ld d,d			;9720
	dec c			;9721
	ld d,d			;9722
	ld b,c			;9723
	ld c,l			;9724
	jr nz,l977ch		;9725
	scf			;9727
	dec l			;9728
	ld b,l			;9729
	ld d,b			;972a
	ld b,d			;972b
	jr nz,l9773h		;972c
	ld d,d			;972e
	ld d,d			;972f
	ld c,a			;9730
	ld d,d			;9731
	dec c			;9732
l9733h:
	ld d,d			;9733
	ld b,c			;9734
	ld c,l			;9735
	jr nz,l978dh		;9736
	inc (hl)			;9738
	dec l			;9739
	ld c,l			;973a
	ld d,b			;973b
	dec l			;973c
	ld c,c			;973d
	ld d,b			;973e
	jr nz,l9786h		;973f
	ld d,d			;9741
	ld d,d			;9742
	ld c,a			;9743
	ld d,d			;9744
	dec c			;9745
l9746h:
	inc a			;9746
	ld d,h			;9747
	ld e,c			;9748
	ld d,b			;9749
	ld b,l			;974a
	ld a,03dh		;974b
	dec c			;974d
l974eh:
	ld d,d			;974e
	jr nz,l9794h		;974f
l9751h:
	ld c,a			;9751
	ld c,l			;9752
	ld d,b			;9753
	ld c,h			;9754
	ld b,l			;9755
	ld d,h			;9756
	ld b,l			;9757
	dec c			;9758
l9759h:
	ld d,(hl)			;9759
l975ah:
	jr nz,l979fh		;975a
	ld c,a			;975c
	ld c,l			;975d
	ld d,b			;975e
	ld c,h			;975f
	ld b,l			;9760
	ld d,h			;9761
l9762h:
	ld b,l			;9762
	dec c			;9763
l9764h:
	ld d,b			;9764
	jr nz,l97a8h		;9765
	ld c,(hl)			;9767
	ld b,h			;9768
	jr nz,l97c1h		;9769
l976bh:
	jr nz,l97b0h		;976b
	ld c,a			;976d
	ld c,l			;976e
	ld d,b			;976f
	ld c,h			;9770
	ld b,l			;9771
	ld d,h			;9772
l9773h:
	ld b,l			;9773
	dec c			;9774
l9775h:
	inc hl			;9775
	ld c,l			;9776
	jr nz,l9786h		;9777
l9779h:
	ld c,(hl)			;9779
	ld c,a			;977a
	ld d,h			;977b
l977ch:
	jr nz,l97c3h		;977c
	ld c,l			;977e
	ld d,b			;977f
	ld d,h			;9780
	ld e,c			;9781
	jr nz,l97ach		;9782
	ld b,e			;9784
	cpl			;9785
l9786h:
	ld d,c			;9786
	add hl,hl			;9787
	dec a			;9788
	dec c			;9789
l978ah:
	nop			;978a
	inc b			;978b
	nop			;978c
l978dh:
	ex af,af'			;978d
	nop			;978e
	djnz l9791h		;978f
l9791h:
	jr nz,l97cdh		;9791
	sub h			;9793
l9794h:
	ld a,(03a94h)		;9794
	sub h			;9797
	ld a,(01594h)		;9798
	sub h			;979b
	ld a,(01594h)		;979c
l979fh:
	sub h			;979f
	ld d,b			;97a0
	sub h			;97a1
l97a2h:
	ld l,a			;97a2
	sub l			;97a3
	ld l,a			;97a4
	sub l			;97a5
	ld l,a			;97a6
	sub l			;97a7
l97a8h:
	ld l,a			;97a8
	sub l			;97a9
	or c			;97aa
	sub l			;97ab
l97ach:
	sub b			;97ac
	sub l			;97ad
	rrca			;97ae
	sub (hl)			;97af
l97b0h:
	jp po,04595h		;97b0
	ld d,b			;97b3
	ld d,d			;97b4
	ld c,a			;97b5
	ld c,l			;97b6
	jr nz,$+84		;97b7
	ld b,l			;97b9
	ld b,c			;97ba
	ld b,h			;97bb
	ld e,c			;97bc
	ccf			;97bd
	jr nz,l97e8h		;97be
	ld e,c			;97c0
l97c1h:
	cpl			;97c1
	ld c,(hl)			;97c2
l97c3h:
	add hl,hl			;97c3
	dec a			;97c4
	dec c			;97c5
l97c6h:
	ld d,e			;97c6
	ld c,b			;97c7
	ld c,a			;97c8
	ld d,d			;97c9
	ld d,h			;97ca
	dec c			;97cb
l97cch:
	ld c,h			;97cc
l97cdh:
	ld c,a			;97cd
	ld c,(hl)			;97ce
	ld b,a			;97cf
	dec c			;97d0
l97d1h:
	ld b,e			;97d1
	ld c,b			;97d2
	ld b,l			;97d3
	ld b,e			;97d4
	ld c,e			;97d5
	jr nz,l982bh		;97d6
	ld d,l			;97d8
	ld c,l			;97d9
	dec a			;97da
	dec c			;97db
	rst 38h			;97dc
	rst 38h			;97dd
	rst 38h			;97de
	rst 38h			;97df
	rst 38h			;97e0
	rst 38h			;97e1
	rst 38h			;97e2
	rst 38h			;97e3
	rst 38h			;97e4
	rst 38h			;97e5
	rst 38h			;97e6
	rst 38h			;97e7
l97e8h:
	rst 38h			;97e8
	rst 38h			;97e9
	rst 38h			;97ea
	rst 38h			;97eb
	rst 38h			;97ec
	rst 38h			;97ed
	rst 38h			;97ee
	rst 38h			;97ef
	rst 38h			;97f0
	rst 38h			;97f1
	rst 38h			;97f2
	rst 38h			;97f3
	rst 38h			;97f4
	rst 38h			;97f5
	rst 38h			;97f6
	rst 38h			;97f7
	rst 38h			;97f8
	rst 38h			;97f9
	rst 38h			;97fa
	rst 38h			;97fb
	rst 38h			;97fc
	rst 38h			;97fd
	rst 38h			;97fe
	rst 38h			;97ff

	;;
	;; Entry point for MPF-1 version of monitor
	;; 

	;; Memory map
	;;  9000-97FF - Programmer ROM (MPF-1P version)
	;;  9800-9FFF - Programmer ROM (MPF-1 version)
	;;  D800-EFFF - Programmer RAM (MPF-1 version)
	;;  D800-F7FF - Available RAM (MPF-1P version)
MPF1_START:
	ld sp,03f80h 	;; ld sp,01f00h		;9800

EPB_EPROM_MODEL: equ EPB_VAR 	; 01f20h - EPROM model number
EBP_KEY_SAVE: equ EPB_VAR+$01	; 01f21h
EPB_01F22_B: equ EPB_VAR+$02	; 01f22h
EPB_01F23_W: equ EPB_VAR+$03 	; 01f23h - Store for EPROM model string
EPB_DISP_MODE: equ EPB_VAR+$09	; 01f29h - ADDR/ DATA mode
EPB_EPROM_CAPACITY: equ EPB_VAR+$0A	; 01f2ah
EPB_01F2C_W: equ EPB_VAR+$0C	; 01f2ch
EPB_01F2E_B: equ EPB_VAR+$0E 	; 01f2eh
EPB_ADSAVE_1: equ EPB_VAR+$0F	; 01f2fh
EPB_ADSAVE_2: equ EPB_VAR+$11	; 01f31h
EPB_ADSAVE_3: equ EPB_VAR+$13	; 01f33h
EPB_01F36_B: equ EPB_VAR+$16	; 01f36h
EPB_WRITE_STATUS: equ EPB_VAR+$1A	; 01f3ah - Write status (2 -
					; good; 0 - err)
EPB_01F3B_B: equ EPB_VAR+$1B	; 01f3bh
EPB_01F3C_B: equ EPB_VAR+$1C	; 01f3ch	
EPB_01F3D_B: equ EPB_VAR+$1D	; 01f3dh	
EPB_01F3E_B: equ EPB_VAR+$1E	; 01f3eh	
EPB_01F45_B: equ EPB_VAR+$25 	; 01f45h - EPROM model (2758=0; 2508=1;
				;          2716=2; 2516=3; 2732=4; 2532=5;
				;          2764=6; 2564=7)
EPB_01F46_W: equ EPB_VAR+$26	; 01f46h - EPROM memory (no 2K blocks) -
				;          little endian
EPB_EPROM_READ: equ EPB_VAR+$29	; 01f49h - Address of EPROM read routine?
EPB_EPROM_WRITE: equ EPB_VAR+$2B	; 01f4bh - Address of EPROM write routine?

	;; Check RAM (D800--D8FF)
	ld hl,0d800h		;9803 (start of EPROM RAM)
	ld bc,00800h		;9806 2 kilobytes
U5_RAM_CHK:
	call RAMCHK		;9809 RAMCHK (Z set for RAM; reset for ROM)
	jr nz,U5_RAM_FAIL	;980c Jump forward if not RAM
	cpi			;980e Inc HL, Dec BC, compute A-(HL) - not used
	jp pe,U5_RAM_CHK	;9810 Repeat if BC non-zero

	;; At this point, first 2K of RAM tested successfully
	jr l982bh		;9813 Jump forward to next test

	db $08			; Not used

U5_RAM_FAIL:
	ld hl,$9F99	        ; Error message 'BADU05'
	call sub_9e17h		; 9819 Write error message to display buffer
	
l981ch:
	ld ix,DISPBF		;981c IX = display buffer
	call SCAN		;9820 'SCAN' - wait for keypress
				;(returned in A)

	call EPB_BEEP		;9823 - Sound beeper
	cp 012h			;9826 - Check for 'GO'
	jp nz,l981ch		;9828 - Loop if not 

	;; Check RAM (E000--E7FF)
l982bh: ld hl,0e000h		;982b - Start of RAM
	ld bc,00800h		;982e - 2 kilobytes
l9831h:
	call RAMCHK		;9831 - RAMCHECK
	jr nz,l983eh		;9834 
	cpi			;9836 - Inc HL, Dec BC, compute A-(HL)
	jp pe,l9831h		;9838 - Repeat, if BC non-zero

	;; At this point, second 2K of RAM tested successfully
	jr l9853h		;983b 
	adc a,(hl)		;983d - Not used

l983eh:
	ld hl,l9f9fh		;983e Error message 'BADU6'
	call sub_9e17h		;9841 Copy message to display buffer
l9844h:
	ld ix,DISPBF		;9844
	call SCAN		;9848
	call EPB_BEEP		;984b
	cp 012h			;984e
	jp nz,l9844h		;9850

	;; Check RAM (E800--EFFF)
l9853h:	ld hl,0e800h		;9853
	ld bc,00800h		;9856
l9859h:
	call RAMCHK		;9859 - RAMCHK
	jr nz,l9866h		;985c
	cpi		;985e
	jp pe,l9859h		;9860
	jr l9872h		;9863
	db $28		;9865
	
l9866h: 
	ld hl,$9FA5		;9867 Error message 'BADU07'
	call sub_9e17h		;9869
	jr l988ah		;986c

l986eh:
	;; Reset EPB_01F3C_B
	xor a			;986e
	ld (EPB_01F3C_B),a	;986f

	;; At this point, the memory check has completed, though Monitor
	;; doesn't seem to keep a note of any memory issues, other than
	;; flagging to the user.
l9872h:
	;; Initialise display message
	ld bc,00006h		;9872 - six characters
	ld hl,l9f93h		;9875 - Message "0000-E"
	ld de,DISPBF		;9878
	ldir			;987b

	;; Highlights address field in display
	ld hl,DISPBF+2		;987d
	ld b,004h		;9880
	call SETPT		;9882 - Set point

	;; Set state = 1
	ld a,001h		;9885
	ld (STATE),a		;9887

	;; Main loop
l988ah:
	ld ix,DISPBF		;988a
	call SCAN		;988e - Read keyboard
	call EPB_BEEP		;9891 - Beep
	call EPB_PROCESS_KEY	;9894 - Process key

	ld a,(EPB_01F3C_B)	;9897
	and a			;989a
	jr nz,l986eh		;989b

	jr l988ah		;989d

	
	;; Process keypress.
	;;
	;; On entry, A contains keypress read by SCAN
EPB_PROCESS_KEY:
	cp 010h			;989f - Jump forward if
	jr c,l98e2h		;98a1 - hex digit

	;;  Otherwise is a command
	ld hl,TEST		;98a3
	set 0,(hl)		;98a6
	ld (EBP_KEY_SAVE),a	;98a8 - Save 'A'
	cp 015h			;98ab 'SBR' / 'PROGRAM'
	jr z,l98bbh		;98ad
	cp 018h			;98af 'PC'
	jr z,l98bbh		;98b1
	cp 01ah			;98b3 'CBR'
	jr c,l98cah		;98b5 Jump forward if 10 '+', 11 '-', 12
				;'GO', 13 'STEP', 14 'DATA', 16 'INS',
				;17 'DEL', or 19 'ADDR' (STATE=0)
	cp 01dh			;98b7 Jump forward if 'RELA'
	jr z,l98cah		;98b9 (STATE=0)
	
l98bbh: 			; Key press is one of 15 'SBR', 1A
				; 'CBR', 1B 'REG', 1C 'MOVE', 1E 'TPWR',
				; 1F 'TPRD' and these key presses
				; require a change of state

	;; Work out new STATE 'READ' = 3 (not set here); 'PROGRAM' =
	;; '4'; LIST='5'; TP_WR='6'; TP_RD='7'; VERIFY='8'
	sub 014h		;98bb
	ld hl,l9fc9h		;98bd
	add a,l			;98c0
	ld l,a			;98c1
	ld a,(hl)		;98c2
	ld (STATE),a		;98c3
	xor a			;98c6
	ld (STMINOR),a		;98c7

l98cah:
	ld a,(EBP_KEY_SAVE)	;98ca - Retrieve keypress
	cp 012h			;98cd
	jr z,l98dah		;98cf - Skip forward if key is 'GO'
	push af			;98d1
	xor a			;98d2
	ld (EPB_01F3D_B),a	;98d3
	ld (EPB_01F3E_B),a	;98d6
	pop af			;98d9

l98dah:
	sub 010h		;98da
	ld hl,l9f55h		;98dc
	jp BRANCH		;98df

	;; Deal with hex digits (based on STATE)
l98e2h:	ld c,a			;98e2 - Save A
	ld hl,l9f67h		;98e3
l98e6h:
	ld a,(STATE)		;98e6
	jp BRANCH		;98e9


	;; Process '+'
	ld hl,l9f72h		;98ec
	jr l98e6h		;98ef

	;; Process '-'
	ld hl,09f7dh		;98f1
	jr l98e6h		;98f4

	;; Process 'GO'
	ld hl,09f88h		;98f6
	jr l98e6h		;98f9

	;; Process 'DATA'
	ld a,055h		;98fb
	ld (EPB_01F3C_B),a	;98fd
	ret			;9900

	;; Process 'GO' (STATE=5) and 'DATA'
l9901h:
	ld a,(STATE)		;9901
	cp 005h		;9904
	jr z,l990ch		;9906

	call IGNORE		;9908
	ret			;990b

	;; Processing LIST
l990ch:
	ld a,002h		;990c - Switch display to Data mode
	ld (EPB_DISP_MODE),a	;990e

	call sub_9e27h		;9911

	ret			;9914

	;; Handle 'ADDR'
	ld a,(STATE)		;9915
	
	cp 005h			;9918 - Check if LIST mde
	jr z,l9920h		;991a
	
	call IGNORE		;991c Otherwise do nothing

	ret			;991f
	
l9920h:
	xor a			;9920 - Switch display to Addr mode
	ld (EPB_DISP_MODE),a	;9921

	call sub_9e20h		;9924

	ret			;9927
	
	;; Process 'INS'
	ld a,(STATE)		;9928 - only valid in STATE=5
	cp 005h			;992b
	jr z,l9933h		;992d

	call IGNORE		;992f

	ret			;9932

	;; Process 'INS' with STATE=5
l9933h:
	ld de,0d800h		;9933 - Start of memory buffer
	ld hl,(ADSAVE)		;9936 - Current address (relative)
	add hl,de		;9939 - Work out actual RAM address

	ld (EPB_ADSAVE_1),hl	;993a - Store it
	inc hl			;993d - Next address
	ld (EPB_ADSAVE_3),hl	;993e - Store it
l9941h:
	call RAMCHK		;9941 - Check next address is vald RAM
	jp nz,IGNORE		;9944
	ld de,0efffh		;9947 - End of memory buffer
	ld (EPB_ADSAVE_2),de	;994a - Store it

	call sub_9e71h		;994e

	ret			;9951

	;; Process 'DEL'
	ld a,(STATE)		;9952

	cp 005h			;9955 - Only valid if STATE=5
	jr z,l995dh		;9957

	call IGNORE		;9959

	ret			;995c

	;; Process 'DEL' with STATE=5
l995dh:
	ld hl,(ADSAVE)		;995d
	ld de,0d800h		;9960
	add hl,de		;9963
	ld (EPB_ADSAVE_3),hl	;9964
	inc hl			;9967
	ld (EPB_ADSAVE_1),hl	;9968
	jr l9941h		;996b - Continue as for 'INS'

	;; Process READ
	call sub_9976h		;996d
l9970h:
	ld a,003h		;9970
	ld (STATE),a		;9972
	ret			;9975

	;; Process VEFIFY
sub_9976h:
	;; Set start address for read to 0000h
	ld hl,00000h		;9976
	ld (STEPBF),hl		;9979
	
	;; Set end address to size of EPROM
	;; Branch based on EPROM model
	ld a,(EPB_EPROM_MODEL)		;997c
	cp 002h		;997f
	jr c,l998dh	;9981 - Branch if EPROM type 0 or 1 (1k)
	cp 004h		;9983
	jr c,l9995h	;9985 - Branch if EPROM type 2 or 3 (2k)
	cp 006h		;9987
	jr c,l999dh	;9989 - Branch if EPROM type 4 or 5 (4k)
	jr l99a3h	;998b - Assume is type 6 or 7 (8k)

l998dh: 			; EPROM type 0 or 1
	ld hl,003ffh		;998d
	ld (STEPBF+2),hl		;9990
	jr l99a9h		;9993
l9995h: 			; EPROM type 2 or 3
	ld hl,007ffh		;9995
	ld (STEPBF+2),hl		;9998
	jr l99a9h		;999b
l999dh: 			; EPROM type 4 or 5
	ld hl,00fffh		;999d *** should this be 00afff ***
	ld (STEPBF+2),hl		;99a0
	;; *** Should there not be a branch here ***
l99a3h: 			; EPROM type 6 or 7
	ld hl,00fffh		;99a3
	ld (STEPBF+2),hl	;99a6
	
l99a9h:
	;; Retrieve input parameters
	ld a,005h		;99a9 - Set state to 5 for retrieving params
	ld (STATE),a		;99ab
	call STEPDP		;99ae
	
	ld a,008h		;99b1
	ld (STATE),a		;99b3
	ret			;99b6

	ld hl,EPB_01F23_W	;99b7
	jp sub_9e17h		;99ba

	call 003bbh		;99bd
	ret			;99c0

	;; Handle 'LIST' key press
	ld hl,l9fb7h		;99c1
	jp sub_9e17h		;99c4

	;; Handle PROGRAM
	xor a			;99c7
	ld (EPB_01F3B_B),a	;99c8

	;; Handle TP_RD and TP_WR
	call STEPDP		;99cb

	ret			;99ce

	;; Handle address entry
	call HAD		;99cf - Hex address entry

	;; Refresh last two characters to be '-E'
	ld a,08fh		;99d2 'E'
	ld (DISPBF),a		;99d4
	ld a,002h		;99d7 '-'
	ld (DISPBF+1),a		;99d9

	;; Done
	ret			;99dc

	
	;; Process hex digit in STATE=5 (LIST)
	ld a,(EPB_DISP_MODE)	;99dd - Check if address/ data mode?
	and a			;99e0
	jr z,l99fah		;99e1 - Jump if address mode
	
	ld hl,(ADSAVE)		;99e3
	ld de,0d800h		;99e6
	add hl,de			;99e9
	call RAMCHK		;99ea
	jp nz,IGNORE		;99ed
	call PRECL1		;99f0
	ld a,c			;99f3
	rld		;99f4
	call sub_9e27h		;99f6

	ret			;99f9

l99fah:
	ld hl,ADSAVE		;99fa
	call PRECL2		;99fd
	ld a,c			;9a00
	rld		;9a01
	inc hl			;9a03
	rld		;9a04
	call sub_9e20h		;9a06

	ret			;9a09

	;; Process hex digit in STATE=3 (READ)
	call HMV		;9a0a - GOT THIS FAR
	ld a,(STMINOR)		;9a0d
	and a			;9a10
	jr nz,l9a19h		;9a11
	ld a,0aeh		;9a13 - 'S'
	ld (DISPBF),a		;9a15
	ret			;9a18

l9a19h:
	ld a,08fh		;9a19 - 'E'
	ld (DISPBF),a		;9a1b 
	ret			;9a1e


	call HMV		;9a1f
	ret			;9a22

	;; Handle '+' for STATE=1
	ld hl,(ADSAVE)		;9a23 - though ADSAVE looks to have EPROM number
	inc hl			;9a26
	ld (ADSAVE),hl		;9a27
	ld a,002h		;9a2a - Switch display to Data mode
	ld (EPB_DISP_MODE),a	;9a2c
	call sub_9e27h		;9a2f
	ret			;9a32

	;; Handle '+' for STATE=3
	call sub_9a39h		;9a33
	jp l9970h		;9a36 - Restore STATE=3 and done

sub_9a39h:
	ld a,005h		;9a39
	ld (STATE),a		;9a3b
	call IMV		;9a3e
	ld a,008h		;9a41
	ld (STATE),a		;9a43
	ld a,08fh		;9a46
	ld (DISPBF),a		;9a48
	ret			;9a4b

	;; Handle '+' for STATE 4
	call IMV		;9a4c
	ret			;9a4f
	
	ld hl,(ADSAVE)		;9a50
	dec hl			;9a53
	ld (ADSAVE),hl		;9a54

	ld a,002h		;9a57 - Switch display to Data mode
	ld (EPB_DISP_MODE),a	;9a59
	call sub_9e27h		;9a5c

	ret			;9a5f

	;; Handle '-' for STATE=3
	call sub_9a66h		;9a60
	jp l9970h		;9a63 - Restore STATE=3 and done

sub_9a66h:
	ld a,005h		;9a66
	ld (STATE),a		;9a68
	call DMV		;9a6b
	ld a,008h		;9a6e
	ld (STATE),a		;9a70
	ret			;9a73

	;; Handle '-' for STATE=4
	call DMV		;9a74
	ret			;9a77

	;; Handle 'GO' for STATE=0, 1, 2
	call sub_9e03h		;9a78 - De-highlight text on display
	call sub_9efeh		;9a7b - Check if valid EPROM model
	call sub_9b9bh		;9a7e - Populate system variables based
				;       on model information
	
	ret			;9a81

	;; Handle 'GO' for STATE=5 (i.e., LIST)
	ld de,00000h		;9a82 - Set start address to zero
	ld (ADSAVE),de		;9a85

	jp l9901h		;9a89

	;; Handle 'GO' for STATE=6 (i.e., TAPE_READ)
	ld hl,(STEPBF+2)	;9a8c - Retrieve start of save buffer
	ld de,0d800h		;9a8f - Turn into physical RAM address
	add hl,de		;9a92
	ld (STEPBF+2),hl	;9a93 - Store it

	ld hl,(STEPBF+4)	;9a96 - Retrieve emd of save buffer
	add hl,de		;9a99 - Turn into physical RAM address
	ld (STEPBF+4),hl	;9a9a - Save it

	call GWT		;9a9d - Write tape

	;;  Set STATE to 6
	ld a,006h		;9aa0
	ld (STATE),a		;9aa2
	
	ld a,0bdh		;9aa5 - Character '0'
	ld (DISPBF+5),a		;9aa7
	
	ret			;9aaa - Done
	
	;; Handle 'GO' for STATE=7 (i.e., TAPE_WRITE)
	call GRT		;9aab - Read tape

	;; Set STATE to 7
	ld a,007h		;9aae
	ld (STATE),a		;9ab0
	ld a,0bdh		;9ab3 - Character '0'
	ld (DISPBF+5),a		;9ab5
	
	ret			;9ab8 - Done

	;; Process 'GO' based on STATE=8 (VERIFY)
	ld hl,(STEPBF+2)	;9ab9 - Parameter 'E'
	ld de,(STEPBF)		;9abc - Parameter 'S'
	and a			;9ac0 - Work out length
	sbc hl,de		;9ac1
	jp c,l9e49h		;9ac3 - Jump if negative
	
	ld a,(EPB_EPROM_MODEL)	;9ac6 - Not needed? Overwritten in next call
	call sub_9eabh		;9ac9 - BC = length_of_read_op + 1

	;; Work out start address in RAM (i.e., absolute address)
	ld hl,0d800h		;9acc - Start of RAM buffer
	ld de,(STEPBF)		;9acf - Parameter 'S'
	push de			;9ad3
	ld a,d			;9ad4
	and 00fh		;9ad5
	ld d,a			;9ad7
	add hl,de		;9ad8
	pop de			;9ad9

	;; HL = start, BC = length, DE=offset on EPROM
l9adah:	call sub_9c86h		;9ada - Read byte
	cpi			;9add - A-(HL), inc HL, dec BC
	jp nz,l9ebch		;9adf - Jump if discrepancy
	inc de			;9ae2 - Otherwise advance to next byte
	jp pe,l9adah		;9ae3   and repeat

	ld hl,l9fc3h		;9ae6 - Pointer to "PASS V" message
	jp sub_9e17h		;9ae9 - Display message and done
	
	ld ix,EPB_01F22_B	;9aec
	jp BRANCH		;9af0

	;; Handle 'GO' on STATE=3
	ld hl,(STEPBF+2)	;9af3 - Parameter "E"
	ld de,(STEPBF)		;9af6 - Parameter "S"
	and a			;9afa - Work out length of read op
	sbc hl,de		;9afb 
	jp c,l9e49h		;9afd - Branch if S > E (i.e., error)

	ld a,(EPB_EPROM_MODEL)	;9b00 - Retrieve EPROM model code

	call sub_9eabh		;9b03 - BC = length_of_read_op + 1

	ld hl,0d800h		;9b06 - Start of memory buffer
	ld de,(STEPBF)		;9b09 - Parameter "S"

	;; Adjust HL based on read offset
	push de			;9b0d 
	ld a,d			;9b0e
	and 00fh		;9b0f - Max 4k offset
	ld d,a			;9b11
	add hl,de		;9b12
	pop de			;9b13

	;; At this point, DE is 'S', HL points to start of destination
	;; buffer in memory and BC = length+1 of read
l9b14h:
	call sub_9c86h		;9b14

	;; Store byte read
	ld (hl),a		;9b17

	;; Advance buffers for next byte read
	inc de			;9b18
	inc hl			;9b19
	dec bc			;9b1a
	
	ld a,b			;9b1b - Check if done
	or c			;9b1c
	jr nz,l9b14h		;9b1d - Repeat if not

	ld hl,l9fbdh		;9b1f - PASS message
	jp sub_9e17h		;9b22 - Done

	
	ld ix,EPB_01F22_B	;9b25
	jp BRANCH		;9b29

	
	;; Handle 'GO' on STATE=5 (PROGRAM)
	ld a,(EPB_01F3B_B)	;9b2c
	cp 065h			;9b2f
	jr nz,l9b3ch		;9b31
	call sub_9dech		;9b33
	call sub_9c47h		;9b36
	jp l9b82h		;9b39

l9b3ch:
	ld a,002h		;9b3c
	ld (EPB_WRITE_STATUS),a	;9b3e
	ld a,(EPB_EPROM_MODEL)	;9b41
	ld ix,EPB_01F2E_B	;9b44

	;; Branch based on model (in A)
	cp 002h		;9b48
	jr c,l9b56h		;9b4a - Model 0 or 1
	cp 004h		;9b4c
	jr c,l9b5bh		;9b4e - Model 2 or 3
	cp 006h		;9b50
	jr c,l9b60h		;9b52 - Model 4 or 5

	jr l9b65h		;9b54 - Model 6 or 7

l9b56h: 			; Model 0 or 1
	ld hl,0fc00h		;9b56 - HL = 10000 - 0400
	jr l9b68h		;9b59
l9b5bh:				; Model 2 or 3
	ld hl,0f800h		;9b5b - HL = 10000 - 0800
	jr l9b68h		;9b5e
l9b60h:				; Model 4 or 5
	ld hl,0f000h		;9b60 - HL = 10000 - 1000
	jr l9b68h		;9b63
l9b65h:				; Model 6 or 7
	ld hl,0e000h		;9b65 - HL = 10000 - 2000

l9b68h:
	ld (EPB_EPROM_CAPACITY),hl	;9b68

	call sub_9dech		;9b6b - Retrieve Start (BC), End (DE),
				;       and Offset (HL)
	call sub_9c47h		;9b6e

	;; Check ???
	ld a,(EPB_WRITE_STATUS)	;9b71
	and a			;9b74
	jp z,l9e44h		;9b75 - Error

	call sub_9c6dh		;9b78 - Check EPROM is writeable ?

	ld a,(EPB_WRITE_STATUS)	;9b7b
	and a			;9b7e

	jp z,l9e4eh		;9b7f - Error

	;; Program EPROM (HL = start; DE = destination; BC=length)
l9b82h:
	ld a,(hl)		;9b82 - Byte to write
	
	push hl			;9b83
	push bc			;9b84
	push af			;9b85

	call sub_9cefh		;9b86 - Write byte
	call sub_9c86h		;9b89 - Read byte

	ld b,a			;9b8c - Check byte
	pop af			;9b8d
	cp b			;9b8e
	jp nz,l9c24h		;9b8f - Break if error

	;;  Restore BC and HL
	pop bc			;9b92
	pop hl			;9b93

	;; Advance EPROM pointer
	inc de			;9b94
	cpi			;9b95 - A = (HL); HL++; BC--
	jp pe,l9b82h		;9b97 - Repeat if BC non-zero

	ret			;9b9a

sub_9b9bh:
	ld hl,(ADSAVE)		;9b9b - Retrieve model number

	ld a,h			;9b9e - Check if 25XX
	cp 025h			;9b9f
	jr nz,l9bcah		;9ba1 - Jump if not 25XX

	ld a,l			;9ba3
	ld hl,EPB_01F45_B	;9ba4 - 

	cp 008h			;9ba7 - Check if 2508
	jr nz,l9bafh		;9ba9 - Jump if not
	
	ld (hl),001h		;9bab

	jr l9bf2h		;9bad

l9bafh:
	cp 016h			;9baf - Check if 2516
	jr nz,l9bb7h		;9bb1 - Jump if not
	
	ld (hl),003h		;9bb3
	
	jr l9bf2h		;9bb5
	
l9bb7h:
	cp 032h			;9bb7 - Check if 2532
	jr nz,l9bbfh		;9bb9 - Jump if not

	ld (hl),005h		;9bbb

	jr l9bf2h		;9bbd

l9bbfh:
	cp 064h			;9bbf - Check if 2564
	jr nz,l9bc7h		;9bc1 - Error if not
	
	ld (hl),007h		;9bc3

	jr l9bf2h		;9bc5

	;; Handle error in model number specification (possibly should
	;; never be reached, as model number checked previously).
	;; *** Looks to be an infinite loop ***
l9bc7h:
	scf			;9bc7
	jr sub_9b9bh		;9bc8 - Revalidate EPROM model

l9bcah:
	cp 027h			;9bca - Check if 27xx
	jr nz,l9bc7h		;9bcc - Error if not

	ld a,l			;9bce - retrieve low digits
	ld hl,EPB_01F45_B	;9bcf

	cp 058h			;9bd2 - Check if 2758
	jr nz,l9bdah		;9bd4

	ld (hl),000h		;9bd6

	jr l9bf2h		;9bd8

l9bdah:
	cp 016h			;9bda - Check if 2716
	jr nz,l9be2h		;9bdc - Jump if not
	
	ld (hl),002h		;9bde

	jr l9bf2h		;9be0

l9be2h:
	cp 032h			;9be2 - Check if 2732
	jr nz,l9beah		;9be4 - Jumo if not
	
	ld (hl),004h		;9be6
	
	jr l9bf2h		;9be8
	
l9beah:
	cp 064h			;9bea - Check if 2764
	jr nz,l9bc7h		;9bec - Error if not

	ld (hl),006h		;9bee

	jr l9bf2h		;9bf0

l9bf2h:
	ld a,(hl)		;9bf2 - Retrieve model code from
				;       EPB_01F45_B
	ld hl,l9f2dh		;9bf3 - Store for memory information

	;; Zero bit 0 of model code
	bit 0,a			;9bf6 - Could replace with "AND $FE"?
	jr z,l9bfch		;9bf8
	sub 001h		;9bfa
	
l9bfch:
	add a,l			;9bfc
	ld l,a			;9bfd

	;; Copy memory info into EPB_01F46_W
	ld de,EPB_01F46_W	;9bfe
	ld bc,00002h		;9c01
	ldir			;9c04

	;; Work out address of read routine
	ld hl,l9f35h		;9c06
	call sub_9c19h		;9c09
	ld (EPB_EPROM_READ),hl	;9c0c - Store it

	;; Work out address of write route 
	ld hl,09f45h		;9c0f
	call sub_9c19h		;9c12
	ld (EPB_EPROM_WRITE),hl	;9c15 - Store it
	
	ret			;9c18

	;; Retrieve address of read routine for specific EPROM model
sub_9c19h:
	ld a,(EPB_01F45_B)	;9c19 - Retrive model code
	add a,a			;9c1c - Multply by 2
	add a,l			;9c1d - Compute offset into buffer
	ld l,a			;9c1e
	ld a,(hl)		;9c1f
	inc hl			;9c20
	ld h,(hl)		;9c21
	ld l,a			;9c22
	
	ret			;9c23
l9c24h:
	pop hl			;9c24
	pop bc			;9c25
	inc de			;9c26
	cpi		;9c27
	ld (STEPBF+4),de		;9c29
	ld de,0d800h		;9c2d
	and a			;9c30
	sbc hl,de		;9c31
	ld (STEPBF),hl		;9c33
	add hl,bc			;9c36
	dec hl			;9c37
	ld (STEPBF+2),hl		;9c38
	ld a,037h		;9c3b
	ld (DISPBF),a		;9c3d
	ld (DISPBF+1),a		;9c40
	call EPB_BEEP		;9c43
	ret			;9c46

	;; Compute (and check) program parameter
	;; 
	;; On entry:
 	;;   BC - Start of RAM to be written
	;;   DE - End of RAM to be written
	;;   HL - Offset on EPROM
	;;
	;; On exit
	;;   BC - Length+1
	;;   DE - Start (RAM)
	;;   HL - Offset (EPROM)
	;; 
sub_9c47h:
	;; Check PROGRAM parameters against EPROM model.
	push bc			;9c47 - Save start and offset
	push hl			;9c48
	ex de,hl		;9c49 - HL = end; DE = Offset
	or a			;9c4a - Clear carry
	sbc hl,bc		;9c4b - HL = length of buffer
	jr c,l9c62h		;9c4d - Error if negative

	ld c,l			;9c4f - Move length to BC
	ld b,h			;9c50

	;; Check EPROM has capacity
	ld de,(EPB_EPROM_CAPACITY)	;9c51 - DE = 10000-CAPACITY
	add hl,de		;9c55
	jr c,l9c62h		;9c56 - Error if too big

	pop hl			;9c58 - Restore Length
	push hl			;9c59

	add hl,de		;9c5a - DE = 10000-CAPACITY
	jr c,l9c62h		;9c5b - Error if too big

	add hl,bc		;9c5d
	jr c,l9c62h		;9c5e - Error if too big
	
	jr l9c69h		;9c60 0 - All good

l9c62h:
	pop de			;9c62
	pop hl			;9c63
	xor a			;9c64
	ld (EPB_WRITE_STATUS),a	;9c65
	ret			;9c68

l9c69h:
	inc bc			;9c69 - BC = Length+1
	pop de			;9c6a - DE = Start (RAM)
	pop hl			;9c6b - HL = Offset (EPROM)

	ret			;9c6c

sub_9c6dh:
	push de			;9c6d
	push bc			;9c6e
l9c6fh:
	call sub_9c86h		;9c6f - Read byte from EPROM
	cp 0ffh			;9c72 - Check if FF
	jr z,l9c7dh		;9c74

	xor a			;9c76 - Error???
	ld (EPB_WRITE_STATUS),a	;9c77
	pop bc			;9c7a
	pop de			;9c7b
	ret			;9c7c

l9c7dh:
	inc de			;9c7d
	dec bc			;9c7e
	ld a,b			;9c7f
	or c			;9c80
	jr nz,l9c6fh		;9c81
	pop bc			;9c83
	pop de			;9c84
	ret			;9c85

	;; Read byte from EPROM
	;; DE=address of byte to read from eprom
	;; a=EPROM model
	;; BC and HL should be preserved
sub_9c86h:
	push hl			;9c86

	ld a,090h		;9c87
	out (07fh),a		;9c89
	
	ld hl,(EPB_EPROM_READ)	;9c8b - Retrieve address of
				;model-specific code (see table at $9F35
				;for addresses)
	
	jp (hl)			;9c8e

	;; Read byte from EPROM (model 4 and 6)
	;; Om entry, DE=address to read from
	;; On exit, A=byte read
	ld a,e			;9c8f
	out (07dh),a		;9c90
	ld a,d			;9c92
	and 017h		;9c93
	or 020h			;9c95
	out (07eh),a		;9c97
	bit 3,d			;9c99
	jr z,$+7		;9c9b
	ld a,008h		;9c9d
	jr $+5			;9c9f
	ld a,03eh		;9ca1
	jr z,$-43		;9ca3
	ld (hl),b		;9ca5
	nop			;9ca6
	in a,(07ch)		;9ca7
	push af			;9ca9
	xor a			;9caa
	out (070h),a		;9cab
	ld a,008h		;9cad
	out (07eh),a		;9caf
	pop af			;9cb1
	pop hl			;9cb2
	ret			;9cb3

	;; Read byte from EPROM (model 0,1,2,3,5)
	;; Om entry, DE=address to read from
	;; On exit, A=byte read
	ld a,e			;9cb4
	out (07dh),a		;9cb5
	ld a,d			;9cb7
	and 00fh		;9cb8
	out (07eh),a		;9cba
	ld a,008h		;9cbc
	out (070h),a		;9cbe
	nop			;9cc0
	in a,(07ch)		;9cc1
	push af			;9cc3
	xor a			;9cc4
	out (070h),a		;9cc5
	pop af			;9cc7
	pop hl			;9cc8
	ret			;9cc9

	;; Read byte from EPROM (model 7)
	;; Om entry, DE=address to read from
	;; On exit, A=byte read
	ld a,e			;9cca
	out (07dh),a		;9ccb
	ld a,d			;9ccd
	and 00fh		;9cce
	or 030h			;9cd0
	out (07eh),a		;9cd2
	bit 4,d			;9cd4
	jr z,l9cdch		;9cd6
	ld a,008h		;9cd8
	jr l9cdeh		;9cda
l9cdch:
	ld a,028h		;9cdc
l9cdeh:
	out (070h),a		;9cde
	ld a,d			;9ce0
	and 00fh		;9ce1
	out (07eh),a		;9ce3
	nop			;9ce5
	in a,(07ch)		;9ce6
	push af			;9ce8
	xor a			;9ce9
	out (078h),a		;9cea
	pop af			;9cec
	pop hl			;9ced
	ret			;9cee


	;; Write byte to EPROM (A=byte; DE=EPROM address)
sub_9cefh:
	push af			;9cef
	push hl			;9cf0
	push af			;9cf1

	ld a,080h		;9cf2
	out (07fh),a		;9cf4

	ld hl,(EPB_EPROM_WRITE)	;9cf6
	jp (hl)			;9cf9

	db $3E			; Not used

	;; Write byte to EPROM types 0, 1, 2, and 3
	;; On entry:
	;;   DE = EPROM address
	;;   TOS = AF (byte) ; 2OS = HL (source addr); 3OS=AF
	pop af			;9cfb
	pop hl			;9cfc
	
	out (07ch),a		;9cfd
	xor a			;9cff
	out (07eh),a		;9d00
	ld a,010h		;9d02
	out (070h),a		;9d04

	ld a,e			;9d06
	out (07dh),a		;9d07
	ld a,d			;9d09
	and 007h		;9d0a
	or 008h			;9d0c
	out (07eh),a		;9d0e

	pop af			;9d10
	call sub_9dd2h		;9d11 - Update display
	
	xor a			;9d14
	out (070h),a		;9d15

	ld b,028h		;9d17
l9d19h:
	djnz l9d19h		;9d19

	ret			;9d1b

	;; Write byte to EPROM types 5
	;; On entry:
	;;   DE = EPROM address
	;;   TOS = AF (byte) ; 2OS = HL (source addr); 3OS=AF
	pop af			;9d1c
	pop hl			;9d1d
	out (07ch),a		;9d1e
	ld a,010h		;9d20
	out (070h),a		;9d22
	ld a,e			;9d24
	out (07dh),a		;9d25
	ld a,d			;9d27
	and 00fh		;9d28
	out (07eh),a		;9d2a
	nop			;9d2c
	ld a,018h		;9d2d
	out (070h),a		;9d2f
	pop af			;9d31
	call sub_9dd2h		;9d32 - Update display
	xor a			;9d35
	out (070h),a		;9d36
	ld b,028h		;9d38
l9d3ah:
	djnz l9d3ah		;9d3a

	ret			;9d3c

	
	;; Write byte to EPROM types 4
	;; 
	;; On entry:
	;;   DE = EPROM address
	;;   TOS = AF (byte) ; 2OS = HL (source addr); 3OS=AF
	pop af			;9d3d
	pop hl			;9d3e
	out (07ch),a		;9d3f
	ld a,008h		;9d41
	out (07eh),a		;9d43
	ld a,e			;9d45
	out (07dh),a		;9d46
	bit 3,d			;9d48
	ld a,024h		;9d4a
	jr z,l9d50h		;9d4c
	ld a,004h		;9d4e
l9d50h:
	out (070h),a		;9d50
	ld a,d			;9d52
	and 007h		;9d53
	or 008h			;9d55
	out (07eh),a		;9d57
	nop			;9d59
	and 007h		;9d5a
	out (07eh),a		;9d5c
	pop af			;9d5e
	call sub_9dd2h		;9d5f - Update display
	ld a,0ffh		;9d62
	out (07eh),a		;9d64
	xor a			;9d66
	out (070h),a		;9d67
	ld b,028h		;9d69
l9d6bh:
	djnz l9d6bh		;9d6b
	ret			;9d6d


	;; Write byte to EPROM types 7
	;; On entry:
	;;   DE = EPROM address
	;;   TOS = AF (byte) ; 2OS = HL (source addr); 3OS=AF
	pop af			;9d6e
	pop hl			;9d6f
	out (07ch),a		;9d70
	ld a,e			;9d72
	out (07dh),a		;9d73
	ld a,d			;9d75
	and 00fh		;9d76
	out (07eh),a		;9d78
	ld a,020h		;9d7a
	bit 4,d			;9d7c
	jr z,l9d82h		;9d7e
	ld a,000h		;9d80
l9d82h:
	out (070h),a		;9d82
	or 009h			;9d84
	nop			;9d86
	out (070h),a		;9d87
	pop af			;9d89
	call sub_9dd2h		;9d8a - Update display
	ld a,020h		;9d8d
	bit 4,d			;9d8f
	jr z,l9d94h		;9d91
	xor a			;9d93
l9d94h:
	out (070h),a		;9d94
	ld b,028h		;9d96
l9d98h:
	djnz l9d98h		;9d98
	ret			;9d9a

	;; Write byte to EPROM types 6
	;; On entry:
	;;   DE = EPROM address
	;;   TOS = AF (byte) ; 2OS = HL (source addr); 3OS=AF
	pop af			;9d9b
	pop hl			;9d9c
	out (07ch),a		;9d9d
	ld a,020h		;9d9f
	out (07eh),a		;9da1
	ld a,e			;9da3
	out (07dh),a		;9da4
	ld a,001h		;9da6
	bit 3,d			;9da8
	jr nz,l9daeh		;9daa
	set 5,a			;9dac
l9daeh:
	out (070h),a		;9dae
	ld a,d			;9db0
	and 007h		;9db1
	or 020h		;9db3
	bit 4,d		;9db5
	jr z,l9dbbh		;9db7
	set 4,a		;9db9
l9dbbh:
	out (07eh),a		;9dbb
	and 0dfh		;9dbd
	nop			;9dbf
	out (07eh),a		;9dc0
	pop af			;9dc2
	call sub_9dd2h		;9dc3 - Update display
	ld a,028h		;9dc6
	out (07eh),a		;9dc8
	xor a			;9dca
	out (070h),a		;9dcb
	ld b,028h		;9dcd
l9dcfh:
	djnz l9dcfh		;9dcf
	ret			;9dd1

sub_9dd2h:
	push bc			;9dd2
	push de			;9dd3
	push hl			;9dd4

	push af			;9dd5
	ld b,005h		;9dd6
	call ADDRDP		;9dd8
	pop af			;9ddb

	call DATADP		;9ddc
l9ddfh:
	ld ix,DISPBF		;9ddf
	call SCAN1		;9de3
	djnz l9ddfh		;9de6
	
	pop hl			;9de8
	pop de			;9de9
	pop bc			;9dea

	ret			;9deb

	;; Retrieve start and end address (and offset) for PROGRAM
	;;
	;; On exit:
	;;   BC - Start of RAM to be written
	;;   DE - Edn of RAM to be written
	;;   HL - Offset on EPROM
sub_9dech:
	ld hl,(STEPBF)		;9dec - Parameter 'S'
	ld de,0d800h		;9def - Start of RAM used for EPROM data
	add hl,de		;9df2
	ld (EPB_01F2C_W),hl	;9df3

	ld hl,(STEPBF+2)	;9df6 - Parameter 'E'
	add hl,de		;9df9 - 
	ex de,hl		;9dfa - DE holds end of RAM to be written

	ld hl,(STEPBF+4)	;9dfb - 'D' (offset)
	ld bc,(EPB_01F2C_W)	;9dfe - Start of RAM to be written
	
	ret			;9e02

	;; De-highlight text on display
sub_9e03h:
	ld b,006h		;9e03
	ld hl,DISPBF		;9e05
l9e08h:
	res 6,(hl)		;9e08
	inc hl			;9e0a
	djnz l9e08h		;9e0b
	ret			;9e0d

	ld a,090h		;9e0e
	out (0cfh),a		;9e10
	ld a,0d0h		;9e12
	out (0ceh),a		;9e14
	ret			;9e16

	;;  Copy six bytes from 1FB6 to HL
sub_9e17h:
	ld bc,00006h		;9e17
	ld de,DISPBF		;9e1a
	ldir			;9e1d
	ret			;9e1f

	;; Refresh address field
sub_9e20h:
	ld b,004h		;9e20
	ld hl,DISPBF+2		;9e22
	jr l9e2ch		;9e25

	;; Refresh data field
sub_9e27h:
	ld b,002h		;9e27
	ld hl,DISPBF		;9e29
l9e2ch:
	exx			;9e2c
	ld de,(ADSAVE)		;9e2d
	call ADDRDP		;9e31

	;; Work out actual memory address by adding base to relative
	;; address
	ld hl,(ADSAVE)		;9e34
	ld de,0d800h		;9e37
	add hl,de		;9e3a

	;; Retrieve value
	ld a,(hl)		;9e3b
	call DATADP		;9e3c
	
	exx			;9e3f
	call SETPT		;9e40

	ret			;9e43
	
l9e44h:
	ld a,002h		;9e44
	ld (EPB_WRITE_STATUS),a	;9e46

l9e49h:
	ld hl,ERR_		;9e49 - Error message
	jr sub_9e17h		;9e4c - Copy to display and return

l9e4eh:
	ld a,002h		;9e4e
	ld (EPB_WRITE_STATUS),a	;9e50
	ld a,065h		;9e53
	ld (EPB_01F3B_B),a	;9e55
	ld hl,l9fabh		;9e58
	jr sub_9e17h		;9e5b

EPB_BEEP:
	push af			;9e5d
	ld hl,FBEEP		;9e5e
	ld c,(hl)		;9e61
	ld hl,(TBEEP)		;9e62
	ld a,(BEEPSET)		;9e65
	cp 055h			;9e68
	jr nz,l9e6fh		;9e6a
	call TONE		;9e6c
l9e6fh:
	pop af			;9e6f
	ret			;9e70

	;; Insert byte 
sub_9e71h:
	ld hl,EPB_ADSAVE_1	;9e71 - Retrieve start of buffer
	call GETP		;9e74 - Computes length of buffer (sets
				;       HL to start of buffer)
	ld de,(EPB_ADSAVE_3)	;9e77
	sbc hl,de		;9e7b
	jr nc,l9e8bh		;9e7d
	ex de,hl		;9e7f
	add hl,bc		;9e80
	dec hl			;9e81
	ex de,hl		;9e82
	ld hl,(EPB_ADSAVE_2)	;9e83
	lddr			;9e86
	inc de			;9e88
	jr l9e8fh		;9e89
l9e8bh:
	add hl,de		;9e8b
	ldir			;9e8c
	dec de			;9e8e
l9e8fh:
	xor a			;9e8f
	ld (de),a		;9e90
	ld hl,(EPB_ADSAVE_3)	;9e91
	ld de,0d800h		;9e94
	and a			;9e97
	sbc hl,de		;9e98
	ld (ADSAVE),hl		;9e9a
	call sub_9e27h		;9e9d - Display
	ld a,005h		;9ea0
	ld (STATE),a		;9ea2

	ld a,002h		;9ea5 - Switch display to Data mode
	ld (EPB_DISP_MODE),a	;9ea7

	ret			;9eaa

	;; Check and work out size of memory range ('S' ... 'E')
	;;
	;; On entry:
	;;  Parameters stored in STEPBF[] - 'S' and 'E'
	;; 
	;; On exit:
	;;   BC = length of buffer+1
sub_9eabh:
	ld hl,(STEPBF+2)	;9eab - End of buffer 'E'
	ld de,(STEPBF)		;9eae - Start of buffer 'S'
	and a			;9eb2 - Work out length
	sbc hl,de		;9eb3
	jp c,l9e49h		;9eb5 - Error if S > E

	inc hl			;9eb8 - Increase length and 
	push hl			;9eb9   put in BC
	pop bc			;9eba

	ret			;9ebb

	;; Error detected during verify
l9ebch:	push af			;9ebc - Store value read from EPROM
	dec hl			;9ebd - Restore read address
	ld a,(hl)		;9ebe - and retrieve corresponding value
				;       from memory
	ld (EPB_01F36_B),a	;9ebf
	ld (ADSAVE),de		;9ec2 - Save EPROM offset
	inc de			;9ec6
	push de			;9ec7
	call sub_9e27h		;9ec8 - Display buffer
	ld b,0b0h		;9ecb
	ld ix,DISPBF		;9ecd
l9ed1h:
	call SCAN1		;9ed1 - Display for $B0 cycles
	djnz l9ed1h		;9ed4
	
	ld ix,BLANK		;9ed6
	ld b,032h		;9eda
l9edch:
	call SCAN1		;9edc Display for $32 cycles
	djnz l9edch		;9edf

	pop hl			;9ee1
	ld (STEPBF),hl		;9ee2
	ld a,0cfh		;9ee5
	ld (DISPBF+5),a		;9ee7
l9eeah:
	ld a,0f3h		;9eea
	ld (DISPBF+2),a		;9eec
	ld a,(EPB_01F36_B)		;9eef
	ld hl,DISPBF		;9ef2
	call HEX7SG		;9ef5
	inc hl			;9ef8
	pop af			;9ef9
	call HEX7SG		;9efa

	ret			;9efd

	;; Check if user has entered a valid EPROM model number
	;;
	;; Some issues in here:
	;; - First command `xor b` looks to be unnecessary
	;; - Counter, C, and pointer, HL, point at mid-point of a model
	;;   number
sub_9efeh:
	xor b			;9efe - B=0 (because of subroutine at
				;9e03 and A is the low byte of the
				;offset of previous BRANCH
				;command)). Not sure what this is for
	ld hl,EPB_EPROM_MODELS	; 9eff - Table of supported EPROM models
	ld c,011h		;9f02 - 2*no models + 1
l9f04h:
	ld de,(ADSAVE)		;9f04 - Points to word containing
				;candidate EPROM model

	;; Check if C is negative (i.e., have checked all models)
	;; Return to model entry, if so.
	ld a,c			;9f08
	and a			;9f09
	jp m,l986eh		;9f0a

	;; Check high byte of EPROM model
	ld a,d			;9f0d - Retrieve high byte of EPROM model
	cpi			;9f0e - Comp A to (HL), dec BC, inc HL
	jr nz,l9f18h		;9f10 Skip if not a match

	;; Check low byte of EPROM model
	ld a,e			;9f12
	cpi			;9f13
	dec hl			;9f15 - Restore HL (does not affect Z)
	jr z,l9f1ch		;9f16 - Jump forward if match
	;; Not a match
l9f18h:
	inc b			;9f18 - Advance to next candidate model
	inc hl			;9f19
	jr l9f04h		;9f1a - Repeat

	;; Match made
l9f1ch:
	ld a,b			; 9f1c - Retrieve EPROM model
	ld (EPB_EPROM_MODEL),a	; 9f1d - Store

	;; Copy model string into buffer
	ld hl,DISPBF		; 9f20
	ld de,EPB_01F23_W	; 9f23
	ld bc,00006h		; 9f26
	ldir			; 9f29
	
	ret			;9f2b

	
	ld c,(hl)		;9f2c

	;; EPROM model memory information (number of 2k blocks, little
	;; endian)
l9f2dh:
	db $00, $04
	db $00, $08
	db $00, $10
	db $00, $20

	;; Table of read routines for different EPROM models
l9f35h:	dw $9CB4
	dw $9CB4
	dw $9CB4
	dw $9CB4
	dw $9C8F
	dw $9CB4
	dw $9C8F
	dw $9CCA

	
	;; Table of write routines for different EPROM models
l9f45h:	dw $9CFB
	dw $9CFB
	dw $9CFB
	dw $9CFB
	dw $9D3D
	dw $9D1C
	dw $9D9B
	dw $9D6E

	;; BRANCH table for various main-loop functions
l9f55h: dw $98EC
	db $00, $05, $0A, $0F, $15, $DB, $3C, $66
	db $8A, $29, $D5, $81, $CB, $D1, $DF, $DF

	;; BRANCH table for hex digits
l9f67h:
	dw $99CF
	db $00, $00, $00, $3B, $50, $0E, $50, $50
	db $3B

	;; Branch table for '+'
l9f72h:	dw $9a23
	db $00, $00, $00, $10, $29, $00, $29, $29
	db $16

	;; Branch table for '-'
l9f7dh:	dw $9a50
	db $00, $00, $00, $10, $24, $00, $24, $24
	db $16			;9f87

l09f88h: ; Branch table for 'GO' (based on STATE)
	dw $9a78
	db $00, $00, $00, $7B, $B4, $0A, $14, $33
	db $41

l9f93h: ; Message - "E-0000"
	db $8F, $02, $BD, $BD, $BD, $BD 

L9f99h:	; Error message for RAM - "50-UdAb"
	db $AE, $BD, $B5, $B3, $3F, $A7

l9f9fh: ; Error message for RAM - "60-UdAb"
	db $AF, $BD, $B5, $B3, $3F, $A7

l9fa5h:	; Error message for RAM - "60-UdAb"
	db $38, $BD, $B5, $B3, $3F, $A7

l9fabh:
	nop			;9fab
	nop			;9fac
	add a,l			;9fad
	add a,l			;9fae
	or l			;9faf
	rrca			;9fb0
	nop			;9fb1
	nop			;9fb2
	or e			;9fb3
	ccf			;9fb4
	adc a,a			;9fb5
	inc bc			;9fb6

	;; List message "00T5IL"
l9fb7h:	db $00, $00, $87, $AE, $89, $85

	;; Pass message "R-SSAP"
l9fbdh:	db $03, $02, $AE, $AE, $3F, $1F

	;; Verify message "V 55AP"
l9fc3h:	db $B7, $00, $AE, $AE, $3F, $1F 

l9fc9h: ; Jump table for commands
	db $02, $04, $00, $00, $08, $01, $05, $03
	db $00, $00, $06, $07

EPB_EPROM_MODELS:
	db $27, $58 		; Model 0
	db $25, $08		; Model 1
	db $25, $16		; Model 2
	db $27, $16		; Model 3
	db $25, $32		; Model 4
	db $27, $32		; Model 5
	db $25, $64		; Model 6
	db $27, $64		; Model 7

	rst 38h			;9fe5
	rst 38h			;9fe6
	rst 38h			;9fe7
	rst 38h			;9fe8
	rst 38h			;9fe9
	rst 38h			;9fea
	rst 38h			;9feb
	rst 38h			;9fec
	rst 38h			;9fed
	rst 38h			;9fee
	rst 38h			;9fef
	rst 38h			;9ff0
	rst 38h			;9ff1
	rst 38h			;9ff2
	rst 38h			;9ff3
	rst 38h			;9ff4
	rst 38h			;9ff5
	rst 38h			;9ff6
	rst 38h			;9ff7
	rst 38h			;9ff8
	rst 38h			;9ff9
	rst 38h			;9ffa
	rst 38h			;9ffb
	rst 38h			;9ffc
	rst 38h			;9ffd
	rst 38h			;9ffe
	rst 38h			;9fff

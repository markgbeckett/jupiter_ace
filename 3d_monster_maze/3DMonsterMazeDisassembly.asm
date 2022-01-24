; ***************
; 3D Monster Maze
; ***************
; (c)1981 New Generation Software Ltd, written by Malcolm Evans.
; For the 16KB ZX81.
;
; Disassembled by Paul Farrow (www.fruitcake.plus.com), 27 November 2016 (revised 26 December 2020).

; ======================================================================================================================================================

; ====================
; Assembler Directives
; ====================
; For TASM assembler.

#define DEFB .BYTE
#define DEFW .WORD
#define DEFM .TEXT
#define DEFS .BLOCK
#define EQU  .EQU
#define ORG  .ORG
#define END  .END

; =======
; Options
; =======

; Include the following directive to create a P81 file, otherwise a P file will be generated.
;#define MAKE_P81

; Include the following directive to create the version of the game released by J. K. Greye Software,
; otherwise the version of the game released by New Generation Software will be created.
;#define JK_GREYE

; ======================================================================================================================================================

; =======================
; Character Set Constants
; =======================

_SPACE                          EQU     $00     ; 0
_TOPLEFTBLACK                   EQU     $01     ; 1
_TOPRIGHTBLACK                  EQU     $02     ; 2
_TOPBLACK                       EQU     $03     ; 3
_BOTTOMLEFTBLACK                EQU     $04     ; 4
_LEFTBLACK                      EQU     $05     ; 5
_BOTTOMLEFTTOPRIGHT             EQU     $06     ; 6
_BOTTOMRIGHTWHITE               EQU     $07     ; 7
_CHEQUERBOARD                   EQU     $08     ; 8
_TOPWHITEBOTTOMCHEQUER          EQU     $09     ; 9
_TOPCHEQUERBOTTOMWHITE          EQU     $0A     ; 10
_QUOTE                          EQU     $0B     ; 11
_POUND                          EQU     $0C     ; 12
_DOLLAR                         EQU     $0D     ; 13
_COLON                          EQU     $0E     ; 14
_QUESTIONMARK                   EQU     $0F     ; 15
_OPENBRACKET                    EQU     $10     ; 16
_CLOSEBRACKET                   EQU     $11     ; 17
_GREATERTHAN                    EQU     $12     ; 18
_LESSTHAN                       EQU     $13     ; 19
_EQUALS                         EQU     $14     ; 20
_PLUS                           EQU     $15     ; 21
_MINUS                          EQU     $16     ; 22
_ASTERISK                       EQU     $17     ; 23
_DIVIDE                         EQU     $18     ; 24
_SEMICOLON                      EQU     $19     ; 25
_COMMA                          EQU     $1A     ; 26
_FULLSTOP                       EQU     $1B     ; 27
_0                              EQU     $1C     ; 28
_1                              EQU     $1D     ; 29
_2                              EQU     $1E     ; 30
_3                              EQU     $1F     ; 31
_4                              EQU     $20     ; 32
_5                              EQU     $21     ; 33
_6                              EQU     $22     ; 34
_7                              EQU     $23     ; 35
_8                              EQU     $24     ; 36
_9                              EQU     $25     ; 37
_A                              EQU     $26     ; 38
_B                              EQU     $27     ; 39
_C                              EQU     $28     ; 40
_D                              EQU     $29     ; 41
_E                              EQU     $2A     ; 42
_F                              EQU     $2B     ; 43
_G                              EQU     $2C     ; 44
_H                              EQU     $2D     ; 45
_I                              EQU     $2E     ; 46
_J                              EQU     $2F     ; 47
_K                              EQU     $30     ; 48
_L                              EQU     $31     ; 49
_M                              EQU     $32     ; 50
_N                              EQU     $33     ; 51
_O                              EQU     $34     ; 52
_P                              EQU     $35     ; 53
_Q                              EQU     $36     ; 54
_R                              EQU     $37     ; 55
_S                              EQU     $38     ; 56
_T                              EQU     $39     ; 57
_U                              EQU     $3A     ; 58
_V                              EQU     $3B     ; 59
_W                              EQU     $3C     ; 60
_X                              EQU     $3D     ; 61
_Y                              EQU     $3E     ; 62
_Z                              EQU     $3F     ; 63
_RND                            EQU     $40     ; 64
_INKEY                          EQU     $41     ; 65
_PI                             EQU     $42     ; 66
_CURSORUP                       EQU     $70     ; 112
_CURSORDOWN                     EQU     $71     ; 113
_CURSORLEFT                     EQU     $72     ; 114
_CURSORRIGHT                    EQU     $73     ; 115
_GRAPHICS                       EQU     $74     ; 116
_EDIT                           EQU     $75     ; 117
_NEWLINE                        EQU     $76     ; 118
_RUBOUT                         EQU     $77     ; 119
_MODE                           EQU     $78     ; 120
_FUNCTION                       EQU     $79     ; 121
_NUMBER                         EQU     $7E     ; 126
_CURSOR                         EQU     $7F     ; 127
_BLACK                          EQU     $80     ; 128
_TOPLEFTWHITE                   EQU     $81     ; 129
_TOPRIGHTWHITE                  EQU     $82     ; 130
_BOTTOMBLACK                    EQU     $83     ; 131
_BOTTOMLEFTWHITE                EQU     $84     ; 132
_RIGHTBLACK                     EQU     $85     ; 133
_TOPLEFTBOTTOMRIGHT             EQU     $86     ; 134
_BOTTOMRIGHTBLACK               EQU     $87     ; 135
_INVCHEQUERBOARD                EQU     $88     ; 136
_TOPBLACKBOTTOMCHEQUER          EQU     $89     ; 137
_TOPCHEQUERBOTTOMBLACK          EQU     $8A     ; 138
_INVQUOTE                       EQU     $8B     ; 139
_INVPOUND                       EQU     $8C     ; 140
_INVDOLLAR                      EQU     $8D     ; 141
_INVCOLON                       EQU     $8E     ; 142
_INVQUESTIONMARK                EQU     $8F     ; 143
_INVOPENBRACKET                 EQU     $90     ; 144
_INVCLOSEBRACKET                EQU     $91     ; 145
_INVGREATERTHAN                 EQU     $92     ; 146
_INVLESSTHAN                    EQU     $93     ; 147
_INVEQUALS                      EQU     $94     ; 148
_INVPLUS                        EQU     $95     ; 149
_INVMINUS                       EQU     $96     ; 150
_INVASTERISK                    EQU     $97     ; 151
_INVDIVIDE                      EQU     $98     ; 152
_INVSEMICOLON                   EQU     $99     ; 153
_INVCOMMA                       EQU     $9A     ; 154
_INVFULLSTOP                    EQU     $9B     ; 155
_INV0                           EQU     $9C     ; 156
_INV1                           EQU     $9D     ; 157
_INV2                           EQU     $9E     ; 158
_INV3                           EQU     $9F     ; 159
_INV4                           EQU     $A0     ; 160
_INV5                           EQU     $A1     ; 161
_INV6                           EQU     $A2     ; 162
_INV7                           EQU     $A3     ; 163
_INV8                           EQU     $A4     ; 164
_INV9                           EQU     $A5     ; 165
_INVA                           EQU     $A6     ; 166
_INVB                           EQU     $A7     ; 167
_INVC                           EQU     $A8     ; 168
_INVD                           EQU     $A9     ; 169
_INVE                           EQU     $AA     ; 170
_INVF                           EQU     $AB     ; 171
_INVG                           EQU     $AC     ; 172
_INVH                           EQU     $AD     ; 173
_INVI                           EQU     $AE     ; 174
_INVJ                           EQU     $AF     ; 175
_INVK                           EQU     $B0     ; 176
_INVL                           EQU     $B1     ; 177
_INVM                           EQU     $B2     ; 178
_INVN                           EQU     $B3     ; 179
_INVO                           EQU     $B4     ; 180
_INVP                           EQU     $B5     ; 181
_INVQ                           EQU     $B6     ; 182
_INVR                           EQU     $B7     ; 183
_INVS                           EQU     $B8     ; 184
_INVT                           EQU     $B9     ; 185
_INVU                           EQU     $BA     ; 186
_INVV                           EQU     $BB     ; 187
_INVW                           EQU     $BC     ; 188
_INVX                           EQU     $BD     ; 189
_INVY                           EQU     $BE     ; 190
_INVZ                           EQU     $BF     ; 191
_DOUBLEQUOTE                    EQU     $C0     ; 192
_AT                             EQU     $C1     ; 193
_TAB                            EQU     $C2     ; 194
_CODE                           EQU     $C4     ; 196
_VAL                            EQU     $C5     ; 197
_LEN                            EQU     $C6     ; 198
_SIN                            EQU     $C7     ; 199
_COS                            EQU     $C8     ; 200
_TAN                            EQU     $C9     ; 201
_ASN                            EQU     $CA     ; 202
_ACS                            EQU     $CB     ; 203
_ATN                            EQU     $CC     ; 204
_LN                             EQU     $CD     ; 205
_EXP                            EQU     $CE     ; 206
_INT                            EQU     $CF     ; 207
_SQR                            EQU     $D0     ; 208
_SGN                            EQU     $D1     ; 209
_ABS                            EQU     $D2     ; 210
_PEEK                           EQU     $D3     ; 211
_USR                            EQU     $D4     ; 212
_STR                            EQU     $D5     ; 213
_CHR                            EQU     $D6     ; 214
_NOT                            EQU     $D7     ; 215
_DOUBLEASTERISK                 EQU     $D8     ; 216
_OR                             EQU     $D9     ; 217
_AND                            EQU     $DA     ; 218
_LESSTHANEQUAL                  EQU     $DB     ; 219
_GREATERTHANEQUAL               EQU     $DC     ; 220
_NOTEQUAL                       EQU     $DD     ; 221
_THEN                           EQU     $DE     ; 222
_TO                             EQU     $DF     ; 223
_STEP                           EQU     $E0     ; 224
_LPRINT                         EQU     $E1     ; 225
_LLIST                          EQU     $E2     ; 226
_STOP                           EQU     $E3     ; 227
_SLOW                           EQU     $E4     ; 228
_FAST                           EQU     $E5     ; 229
_NEW                            EQU     $E6     ; 230
_SCROLL                         EQU     $E7     ; 231
_CONT                           EQU     $E8     ; 232
_DIM                            EQU     $E9     ; 233
_REM                            EQU     $EA     ; 234
_FOR                            EQU     $EB     ; 235
_GOTO                           EQU     $EC     ; 236
_GOSUB                          EQU     $ED     ; 237
_INPUT                          EQU     $EE     ; 238
_LOAD                           EQU     $EF     ; 239
_LIST                           EQU     $F0     ; 240
_LET                            EQU     $F1     ; 241
_PAUSE                          EQU     $F2     ; 242
_NEXT                           EQU     $F3     ; 243
_POKE                           EQU     $F4     ; 244
_PRINT                          EQU     $F5     ; 245
_PLOT                           EQU     $F6     ; 246
_RUN                            EQU     $F7     ; 247
_SAVE                           EQU     $F8     ; 248
_RAND                           EQU     $F9     ; 249
_IF                             EQU     $FA     ; 250
_CLS                            EQU     $FB     ; 251
_UNPLOT                         EQU     $FC     ; 252
_CLEAR                          EQU     $FD     ; 253
_RETURN                         EQU     $FE     ; 254
_COPY                           EQU     $FF     ; 255

; ======================================================================================================================================================

; ============
; Program Name
; ============
; The ZX81 program name consists of one or more non-inverted characters, with the last character inverted.

#ifdef MAKE_P81

        ORG  $3FFA

        DEFB _3
        DEFB _D
        DEFB _SPACE
        DEFB _M
        DEFB _O
        DEFB _N
        DEFB _S
        DEFB _T
        DEFB _E
        DEFB _R
        DEFB _SPACE
        DEFB _M
        DEFB _A
        DEFB _Z
        DEFB _E + $80

#endif

; ======================================================================================================================================================

; ================
; System Variables
; ================

ERR_NR  EQU                       16384         ; $4000
FLAGS   EQU                       16385         ; $4001
ERR_SP  EQU                       16386         ; $4002
RAMTOP  EQU                       16388         ; $4004
MODE    EQU                       16390         ; $4006
PPC     EQU                       16391         ; $4007

; The ZX81 program is saved from the following location onwards.

        ORG  $4009

PROG_START:

VERSN:  DEFB $00                ; 16393           $4009

#ifdef JK_GREYE
E_PPC:  DEFW $03E8              ; 16394           $400A  Line 1000 has the program cursor.
#else
E_PPC:  DEFW $0000              ; 16394           $400A  Line 0 has the program cursor.
#endif

D_FILE: DEFW L6627              ; 16396           $400C
DF_CC:  DEFW L6627+$0001        ; 16398           $400E
VARS:   DEFW L6940              ; 16400           $4010
DEST:   DEFW L6940              ; 16402           $4012
E_LINE: DEFW L6940+$0001        ; 16404           $4014
CH_ADD: DEFW L5FA4-$0001        ; 16406           $4016
X_PTR:  DEFW $C000              ; 16408           $4018
STKBOT: DEFW L6940+$0001        ; 16410           $401A
STKEND: DEFW L6940+$0001        ; 16412           $401C
BERG:   DEFB $03                ; 16414           $401E
MEM:    DEFW MEMBOT             ; 16415           $401F
SPARE1: DEFB $00                ; 16417 - unused  $4021
DF_SZ:  DEFB $02                ; 16418           $4022

#ifdef JK_GREYE
S_TOP:  DEFW $0082              ; 16419           $4023  Line 130 is at the top of the BASIC listing.
#else
S_TOP:  DEFW $1798              ; 16419           $4023  Line 6040 is at the top of the BASIC listing.
#endif

LAST_K  DEFW $FFFF              ; 16421           $4025
DBOUNC: DEFB $FF                ; 16423           $4027
MARGIN: DEFB $37                ; 16424           $4028
NXTLIN: DEFW L5FA4              ; 16425           $4029  The BASIC program will auto-run from line 1015.
OLDPPC: DEFW $0401              ; 16427           $402B
FLAGX:  DEFB $00                ; 16429           $402D
STRLEN: DEFW $E673              ; 16430           $402E
T_ADDR: DEFW $0C8D              ; 16432           $4030
SEED:   DEFW $9A41              ; 16434           $4032

#ifdef JK_GREYE
FRAMES: DEFW $F01A              ; 16436           $4034
#else
FRAMES: DEFW $A056              ; 16436           $4034
#endif

COORDS: DEFW $2000              ; 16438           $4036
PR_CC:  DEFB $BC                ; 16440           $4038
S_POSN: DEFB $21                ; 16441           $4039
        DEFB $18                ; 16442           $403A
CDFLAG: DEFB $40                ; 16443           $403B  Temporary FAST mode.
PRBUFF: DEFW $0000, $0000       ; 16444           $403C
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFW $0000, $0000
        DEFB _NEWLINE           ; 16476           $405C
MEMBOT: DEFW $0000, $0000       ; 16477           $405D
        DEFW $8200, $0000
        DEFW $0000, $8080
        DEFW $8080, $8080
        DEFW $8080, $8080

#ifdef JK_GREYE
        DEFW $8380, $9194
#else
        DEFW $8880, $9294
#endif

        DEFW $0090, $0000
        DEFW $0000
SPARE2: DEFB $00                ; 16507           $407B  Unused.
SPARE3: DEFB $00                ; 16508           $407C  Unused.

; ======================================================================================================================================================

; ========================================
; BASIC Line 0 - Contains the Machine Code
; ========================================

L407D:  DEFB 0 >> 8
        DEFB 0 & $FF
        DEFW L5BAB - L4081
L4081:  DEFB _REM

; ------------------------------------------------------------------------------------------------------------------------------------------------------

; -----------------
; Program Constants
; -----------------

; Maze constants
; --------------
; The code for the wall must have bit 7 set whereas the other codes must have bit 7 reset.

_MW     EQU  _BLACK                             ; Wall.
_MP     EQU  _SPACE                             ; Passageway.
_MR     EQU  _M                                 ; Rex.
_ME     EQU  _H                                 ; Exit.
_MT     EQU  _CHEQUERBOARD                      ; Trail left by Rex (this value is entered into the maze by setting bit 3 at L4AD3+$0003). The inserted trail is never actually used or displayed.

; -----------------
; Program Variables
; -----------------

#ifdef JK_GREYE
L4082:  DEFB $02                                ; Holds the low byte of the current insertion location when inserting a passageway into the maze.
                                                ; Holds a random offset within the maze when placing the Exit.
                                                ; Holds the low byte of the player's position within the maze when running the game loop.
                                                ; Holds a counter used to determine whether to display a line of the instructions (bit 0=0) or a blank row (bit 0=1).
L4083:  DEFB (L55A2+$0016) & $FF                ; Holds the high byte of the current insertion location when inserting a passageway into the maze.
                                                ; Holds the high byte of the player's position within the maze when running the game loop.
                                                ; Holds the low byte of the address of the next line of the instructions to display.
L4084:  DEFB (L55A2+$0016) >> 8                 ; Holds the desired length of the passageway beign inserted when constructing the maze.
                                                ; Holds the direction the player is facing when running the game loop ($00=North, $01=West, $02=South, $03=East).
                                                ; Holds the high byte of the address of the next line of the instructions to display.
#else
L4082:  DEFB $0D                                ; Holds the low byte of the current insertion location when inserting a passageway into the maze.
                                                ; Holds a random offset within the maze when placing the Exit.
                                                ; Holds the low byte of the player's position within the maze when running the game loop.
                                                ; Holds a counter used to determine whether to display a line of the instructions (bit 0=0) or a blank row (bit 0=1).
L4083:  DEFB (L55A2+$009A) & $FF                ; Holds the high byte of the current insertion location when inserting a passageway into the maze.
                                                ; Holds the high byte of the player's position within the maze when running the game loop.
                                                ; Holds the low byte of the address of the next line of the instructions to display.
L4084:  DEFB (L55A2+$009A) >> 8                 ; Holds the desired length of the passageway beign inserted when constructing the maze.
                                                ; Holds the direction the player is facing when running the game loop ($00=North, $01=West, $02=South, $03=East).
                                                ; Holds the high byte of the address of the next line of the instructions to display.
#endif

L4085:  DEFB $01                                ; Holds the passageway direction when inserting a passageway into the maze ($00=North, $01=West, $02=South, $03=East).
                                                ; Holds the distance from the player when drawing a section (wall or passageway) of the 3D view.
L4086:  DEFB $04                                ; Holds the width of the section being drawn when creating the 3D view.
L4087:  DEFB $02                                ; Flags:
                                                ;   Bit 7: 1=The player has been caught.
                                                ;   Bit 6: 1=The player has moved forwards.
                                                ;   Bit 5: 1=The player has not moved and so there is no need to redraw the view of the maze.
                                                ;   Bit 4: 1=The Exit is visible.
                                                ;   Bit 3: 1=Rex has moved.
                                                ;   Bit 2: 1=Rex has moved into a new location.
                                                ;   Bit 1: 1=Rex has his left foot forward, 0=Rex has his right foot forward.
                                                ;   Bit 0: Controls the movement speed of Rex. It combines with bits 1 and 2 to form a 3 bit counter. Bit 0 will be forced to 1
                                                ;          when the played is moving thereby forcing Rex to take quicker steps.
L4088:  DEFW L4670+$000C                        ; Holds the address of Rex within the maze.
L408A:  DEFB $23                                ; Holds the key press INKEY$ code, used by the game loop.
L408B:  DEFB $08                                ; Holds a timeout used to determine when to clear the status message area (maximum value=$08, $00 means countdown expired so clear the status message).
L408C:  DEFB $01                                ; Temporary store used when the view is being drawn to determine the distance to Rex ($00=Rex is at the same location as the player).
L408D:  DEFB $07                                ; Holds the distance Rex is away from the player when in direct line of site. It is used to determine the sprite to display for Rex ($00=Rex at the same location as the player, $06=Rex is beyond visible range).

; ----------------
; Rex Sprite Table
; ----------------
; Rex is visible from 10 steps away. Rex takes 2 steps within each maze location, first a right step (right foot forward) and then a left step (left foot forward).

L408E:  DEFB L50C8 >> 8, L50C8 & $FF            ; Distance 0 left step: "You Have Been Posthumously Awarded" Screen.
        DEFB L4E33 >> 8, L4E33 & $FF            ; Distance 0 right step: Rex Mouth Open Screen.
        DEFB L42E9 >> 8, L42E9 & $FF            ; Distance 1 left step.
        DEFB L4214 >> 8, L4214 & $FF            ; Distance 1 right step.
        DEFB L4194 >> 8, L4194 & $FF            ; Distance 2 left step.
        DEFB L4138 >> 8, L4138 & $FF            ; Distance 2 right step.
        DEFB L40FD >> 8, L40FD & $FF            ; Distance 3 left step.
        DEFB L40D9 >> 8, L40D9 & $FF            ; Distance 3 right step.
        DEFB L40C0 >> 8, L40C0 & $FF            ; Distance 4 left step.
        DEFB L40AE >> 8, L40AE & $FF            ; Distance 4 right step.
        DEFB L40A6 >> 8, L40A6 & $FF            ; Distance 5 left step.
        DEFB L42E1 >> 8, L42E1 & $FF            ; Distance 5 right step.

; -------------------
; Rex Sprite Graphics
; -------------------
; The format of each sprite is:
; - The high byte of an offset into the display file from the current location.
; - An entry per row of the sprite:
;   - The low byte of an offset into the display file from the current location (high byte will be $00 on the second and subsequent rows).
;     A value of $00 denotes the end of sprite, hence an offset into the display file is always at least $01.
;   - The number of characters in the row.
;   - The characters for the row.

; Distance 5 left step.

L40A6:  DEFB $01
        DEFB $78, $01, _BLACK
        DEFB $20, $01, _BLACK
        DEFB $00

; Distance 4 right step.

L40AE:  DEFB $01
        DEFB $57, $01, _BOTTOMBLACK
        DEFB $1F, $02, _BOTTOMRIGHTBLACK, _BLACK
        DEFB $1F, $03, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK
        DEFB $1E, $02, _TOPRIGHTBLACK, _TOPLEFTBLACK
        DEFB $00

; Distance 4 left step.

L40C0:  DEFB $01
        DEFB $35, $02, _BOTTOMRIGHTBLACK, _BOTTOMBLACK
        DEFB $1F, $02, _TOPRIGHTBLACK, _BOTTOMRIGHTWHITE
        DEFB $1F, $03, _BLACK, _TOPLEFTWHITE, _TOPRIGHTWHITE
        DEFB $1E, $03, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMLEFTTOPRIGHT
        DEFB $1E, $03, _TOPBLACK, _TOPBLACK, _TOPRIGHTWHITE
        DEFB $00

; Distance 3 right step.

L40D9:  DEFB $01
        DEFB $35, $03, _RIGHTBLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1E, $03, _TOPRIGHTBLACK, _BLACK, _TOPLEFTBLACK
        DEFB $1D, $04, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMBLACK, _LEFTBLACK
        DEFB $1D, $04, _RIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $1E, $03, _BLACK, _BLACK, _BLACK
        DEFB $1D, $05, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPLEFTBLACK
        DEFB $00

; Distance 3 left step.

L40FD:  DEFB $01
        DEFB $14, $03, _TOPLEFTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $1D, $04, _RIGHTBLACK, _TOPRIGHTWHITE, _BLACK, _TOPLEFTWHITE
        DEFB $1D, $04, _TOPRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _TOPBLACK, _TOPLEFTBOTTOMRIGHT
        DEFB $1D, $05, _RIGHTBLACK, _BLACK, _BOTTOMBLACK, _BLACK, _LEFTBLACK
        DEFB $1C, $05, _TOPRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $1C, $05, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1C, $05, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1B, $06, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _LEFTBLACK, _TOPBLACK, _BLACK, _LEFTBLACK
        DEFB $1F, $02, _TOPBLACK, _TOPBLACK
        DEFB $00

; Distance 2 right step.

L4138:  DEFB $00
        DEFB $D2, $03, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK
        DEFB $1E, $04, _BOTTOMRIGHTWHITE, _BLACK, _BOTTOMRIGHTWHITE, _LEFTBLACK
        DEFB $1C, $05, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1C, $05, _RIGHTBLACK, _BOTTOMLEFTBLACK, _TOPBLACK, _TOPLEFTBLACK, _TOPRIGHTWHITE
        DEFB $1C, $06, _BLACK, _TOPRIGHTWHITE, _SPACE, _TOPLEFTWHITE, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1A, $07, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1A, $07, _RIGHTBLACK, _LEFTBLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $1A, $07, _TOPRIGHTBLACK, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1B, $06, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $1B, $06, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _TOPLEFTWHITE, _BLACK
        DEFB $1B, $07, _BOTTOMLEFTWHITE, _BLACK, _RIGHTBLACK, _BLACK, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMBLACK
        DEFB $19, $03, _BOTTOMBLACK, _BLACK, _LEFTBLACK
        DEFB $00

; Distance 2 left step.

L4194:  DEFB $00
        DEFB $B0, $04, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE
        DEFB $1D, $05, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1C, $05, _BLACK, _TOPLEFTWHITE, _BLACK, _TOPRIGHTWHITE, _LEFTBLACK
        DEFB $1B, $07, _RIGHTBLACK, _TOPRIGHTBLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPLEFTWHITE, _SPACE
        DEFB $1A, $07, _TOPLEFTWHITE, _LEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK
        DEFB $1A, $07, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _SPACE, _BLACK, _BLACK, _BLACK
        DEFB $1A, $08, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _BLACK, _LEFTBLACK
        DEFB $19, $08, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _TOPRIGHTBLACK, _BLACK
        DEFB $19, $08, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _TOPBLACK
        DEFB $18, $08, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $19, $09, _BLACK, _BLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _LEFTBLACK
        DEFB $18, $09, _BOTTOMLEFTWHITE, _BLACK, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _TOPLEFTBLACK
        DEFB $17, $0A, _BOTTOMBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _TOPRIGHTBLACK, _BLACK, _LEFTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $1E, $03, _BOTTOMLEFTWHITE, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK
        DEFB $00

; Distance 1 right step.

L4214:  DEFB $00
        DEFB $6F, $04, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMLEFTBLACK
        DEFB $1C, $06, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $1A, $07, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $1A, $07, _RIGHTBLACK, _TOPRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _BOTTOMRIGHTWHITE
        DEFB $19, $09, _BOTTOMRIGHTBLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $17, $0A, _SPACE, _BLACK, _BLACK, _TOPRIGHTBLACK, _BLACK, _TOPLEFTWHITE, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _BLACK, _TOPRIGHTWHITE
        DEFB $17, $0A, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _BOTTOMRIGHTBLACK, _BLACK, _BLACK
        DEFB $17, $0A, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _SPACE, _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB $16, $0B, _BOTTOMRIGHTBLACK, _BLACK, _LEFTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE
        DEFB $16, $0B, _RIGHTBLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPLEFTBLACK
        DEFB $16, $0B, _RIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $17, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $16, $0B, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $16, $0B, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE
        DEFB $16, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $17, $0A, _RIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPLEFTBOTTOMRIGHT, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $15, $0C, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _TOPBLACK, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK
        DEFB $15, $05, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK, _SPACE
        DEFB $00

; Distance 5 right step.

L42E1:  DEFB $01
        DEFB $78, $01, _BOTTOMBLACK
        DEFB $20, $01, _TOPBLACK
        DEFB $00

; Distance 1 left step.

L42E9:  DEFB $00
        DEFB $4D, $06, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMLEFTBLACK
        DEFB $1A, $08, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $18, $0A, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _SPACE
        DEFB $16, $0B, _SPACE, _TOPLEFTWHITE, _BLACK, _O, _BLACK, _BLACK, _BLACK, _BLACK, _O, _BLACK, _LEFTBLACK
        DEFB $16, $0B, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $16, $0B, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $15, $0D, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _TOPRIGHTWHITE, _SPACE
        DEFB $13, $0E, _SPACE, _BLACK, _BLACK, _LEFTBLACK, _TOPCHEQUERBOTTOMWHITE, _V, _V, _TOPBLACKBOTTOMCHEQUER, _TOPBLACKBOTTOMCHEQUER, _V, _V, _INVCHEQUERBOARD, _BLACK, _LEFTBLACK
        DEFB $13, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _TOPWHITEBOTTOMCHEQUER, _SPACE, _SPACE, _TOPCHEQUERBOTTOMWHITE, _TOPCHEQUERBOTTOMWHITE, _SPACE, _TOPWHITEBOTTOMCHEQUER, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _SPACE
        DEFB $12, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $12, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _INVCHEQUERBOARD, _SPACE, _SPACE, _SPACE, _SPACE, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $12, $0F, _SPACE, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _TOPWHITEBOTTOMCHEQUER, _SPACE, _SPACE, _TOPWHITEBOTTOMCHEQUER, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK
        DEFB $12, $10, _SPACE, _TOPCHEQUERBOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE
        DEFB $11, $10, _SPACE, _BOTTOMLEFTWHITE, _TOPCHEQUERBOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $12, $0F, _TOPRIGHTBLACK, _BLACK, _TOPCHEQUERBOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $12, $0F, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _LEFTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _INVCHEQUERBOARD, _BLACK, _BLACK, _SPACE
        DEFB $13, $0E, _RIGHTBLACK, _BLACK, _BLACK, _LEFTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _BOTTOMRIGHTWHITE, _SPACE
        DEFB $11, $0F, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _RIGHTBLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE
        DEFB $12, $0F, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK, _SPACE, _RIGHTBLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK
        DEFB $1C, $06, _SPACE, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK
        DEFB $1C, $05, _TOPRIGHTBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK, _TOPLEFTBLACK
        DEFB $00

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L441A:  DEFB $00, $00

        DEFB $00, $04
        DEFW $0110
        DEFB _REM

; -------------
; Fill the Maze
; -------------
; The maze is 18 x 16 positions in size, although the very north, south and west locations will always contain walls.
; Therefore the active maze sixe is 16 x 15. This routine fills all positions with wall cells. It is called from BASIC.

L4421:  LD   HL,L45F0                           ; Point to the first location of the maze.
        LD   BC,$011F                           ; The size of the maze-1.
        LD   DE,L45F0+$0001                     ; Point to the second location of the maze.
        LD   (HL),_MW                           ; Fill the first location with a wall.
        LDIR                                    ; Copy the wall to all other locations within the maze.

        LD   HL,L46F0+$000F                     ; Point to the far south-east location.
        LD   (L4082),HL                         ; Set as the player position.
        RET

; ---------------------------------
; Insert a Passageway into the Maze
; ---------------------------------
; This routine is called from BASIC. A direction and length for the passageway has been selected at random from BASIC beforehand.
; The first passageway begins at the player's initial location (the very south-east of the maze). Each subsequent passageway
; begins where the previous one terminated.

L4435:  LD   A,(L4084)                          ; Fetch the passageway length.
        LD   B,A

; Enter a loop to examine each position along the passageway length.

L4439:  LD   DE,$0010                           ; The width of the maze.
        LD   HL,(L4082)                         ; Fetch the current passageway insertion location.

        LD   A,(L4085)                          ; Fetch the passageway direction.
        CP   $00                                ; Is the passageway to the north?
        JP   Z,L4465                            ; Jump if so.

        CP   $01                                ; Is the passageway to the west?
        JP   Z,L449B                            ; Jump if so.

        CP   $02                                ; Is the passageway to the south?
        JP   Z,L445E                            ; Jump if so.

        CP   $03                                ; Is the passageway to the east?
        JP   Z,L4457                            ; Jump if so.

; Should never reach here.

        RET

; The passageway is to the east
; -----------------------------

L4457:  INC  HL                                 ; Point at the location to the east.

        LD   A,$0F
        AND  L                                  ; At the far east of the maze?
        JR   NZ,L44A4                           ; Jump if not.

; At the far east of the maze so the passageway can progress no further.

        RET

; The passageway is to the south
; ------------------------------

L445E:  ADD  HL,DE                              ; Point to the location to the south.

        LD   A,$F0                              ; At the far south of the maze?
        AND  L
        JR   NZ,L446E                           ; Jump if not.

; At the far south of the maze so the passageway can progress no further.

        RET

; The passageway is to the north
; ------------------------------

L4465:  LD   A,$F0                              ; At the far north of the maze?
        AND  L
        JR   NZ,L446B                           ; Jump if not.

; At the far north of the maze so the passageway can progress no further.

        RET

; The passageway is to the north.

L446B:  AND  A
        SBC  HL,DE                              ; Point to the location to the north.

; Joins here when the passageway is to the south.

L446E:  LD   A,(HL)                             ; Fetch the contents of the location.
        CP   _MP                                ; Does it already contain a passageway?
        JR   Z,L448F                            ; Jump ahead if so.

; The location contains a wall so is a candidate for inserting a passageway.

        LD   A,$0F
        AND  L                                  ; At the far west?
        JR   Z,L4482                            ; Jump ahead if so.

; Not at the far west.

        DEC  HL                                 ; Point to the location to the west.

        LD   A,(HL)                             ; Fetch the contents of the location.
        CP   _MP                                ; Does it already contain a passageway?
        JR   NZ,L4481                           ; Jump ahead if not.

; The location to the west contains a passageway.

        RET

; The loop back to examine the next position along the passageway length jumps to here since the distance to
; the loop start is too far to relative jump to in one go.

L447F:  JR   L4439                              ; Jump to the loop start.

; Continues here when the passageway is to the north or south.

L4481:  INC  HL                                 ; Reverse the decrement above to point back to the original location.

; Joins here when the passageway is not at the far west.

L4482:  INC  HL                                 ; Point to the location to the east.

        LD   A,$0F
        AND  L                                  ; At the far east?
        JR   Z,L448E                            ; Jump ahead if so.

; Not at the far east.

        LD   A,(HL)                             ; Fetch the contents of the location.
        CP   _MP                                ; Does it already contain a passageway?
        JR   NZ,L448E                           ; Jump ahead if not.

; The location to the east contains a passageway.

        RET

; The passageway is to the north or south and walls are to the west and east.

L448E:  DEC  HL                                 ; Reverse the increment above to point back to the original location.

; Joins here when the passageway can be progressed into this location, or the location already contains a passageway.

L448F:  LD   A,_MP
        LD   (L4082),HL                         ; Store as the new passageway insertion position.

        EX   DE,HL
        LD   (DE),A                             ; Insert a passageway into the maze at the current position.

        DJNZ L4439                              ; Loop back to examine the next position along the desired passageway length.

        LD   B,D
        LD   C,E                                ; Return the end location of the passageway [never used].
        RET

; The passageway is to the west
; -----------------------------

L449B:  LD   A,L
        AND  $0F                                ; At the far west of the maze?
        CP   $01
        JR   NZ,L44A3                           ; Jump if not.

; At the far west of the maze so the passageway can progress no further.

        RET

; Not at the far west.

L44A3:  DEC  HL                                 ; Point to the location to the east.

; Joins here when the passageway is to the east.

L44A4:  LD   A,(HL)                             ; Fetch the contents of the position.
        CP   _SPACE                             ; Does it already contain a passageway?
        JR   Z,L44C7                            ; Jump ahead if so.

; The location contains a wall so is a candidate for inserting a passageway.

        LD   A,$F0
        AND  L                                  ; At the far north or far south?
        JR   Z,L44B8                            ; Jump ahead if so.

; Not at the far north or far south.

        AND  A
        SBC  HL,DE

        LD   A,(HL)                             ; Does the location to the north contain a passageway?
        CP   _SPACE
        JR   NZ,L44B7                           ; Jump ahead if not.

; The location to the north contains a passageway.

        RET

; The location to the north does not contain a passageway.

L44B7:  ADD  HL,DE                              ; Reverse the subtraction above to point back to the original location.

; Joins here when at the far north.

L44B8:  ADD  HL,DE                              ; Point to the location to the south.
        LD   A,$F0
        AND  L                                  ; At the far south?
        JR   Z,L44C4                            ; Jump ahead if so.

; Not at the far south.

        LD   A,(HL)                             ; Does the location to the south contain a passageway?
        CP   _SPACE
        JR   NZ,L44C4                           ; Jump ahead if not.

; The location to the south contains a passageway.

        RET

; The location to the south does not contain a passageway.

L44C4:  AND  A
        SBC  HL,DE                              ; Reverse the addition above to point back to the original location.

; Joins here when the passageway can be progressed into this location, or the location already contains a passageway.

L44C7:  LD   (L4082),HL                         ; Store as the new passageway insertion position.

        EX   DE,HL
        LD   A,_SPACE
        LD   (DE),A                             ; Insert a passageway into the maze at the current position.

        DJNZ L447F                              ; Loop back to examine the next position along the desired passageway length.

        RET

; -----------------------------
; Insert the Exit into the Maze
; -----------------------------

L44D1:  LD   HL,L4630                           ; Point at row 4 column 0 within the maze, which is the starting search position.

        LD   A,(L4082)                          ; Fetch the random offset within the maze.
        ADD  A,L
        LD   L,A                                ; Apply it to the starting search position.

        LD   A,(HL)
        CP   _MP                                ; Does the maze location contain a passageway?
        RET  NZ                                 ; Return if it does not, i.e. it contains a wall.

; The location contains a passageway.

        LD   (HL),_ME                           ; Insert the Exit into the maze.
        CALL L4D7C                              ; Perform a program protection check and fetches an offset to apply to point to the position to the north.

        LD   C,$00                              ; Signal that an adjacent passageway has not yet been found.
        CALL L4504                              ; Check the position to the north.

        LD   DE,$000F                           ; Offset to point to the position to the west.
        CALL L4504                              ; Check the position to the west.

        LD   DE,$0002                           ; Offset to point to the position to the east.
        CALL L4504                              ; Check the position to the east.

        LD   DE,$000F                           ; Offset to point to the position to the south.
        CALL L4504                              ; Check the position to the south.

; By here the Exit position is now only reachable from one direction.

        LD   HL,L46F0+$000F                     ; The address of row 16 column 15 - the start location for the player.
        LD   (HL),_MP                           ; Ensure this location contains a passageway.

        LD   HL,L4082                           ; The low address of the player's position (the high byte will always be $46).
        LD   (HL),$FF                           ; Set the player's start location to $46FF.
        RET

; ---------------------------------------
; Check Adjacent Location Around the Exit
; ---------------------------------------
; This routine is called to check the locations around the Exit position. Only one passageway is allowed
; to be adjacent to the Exit position. The locations around the Exit are checked in the following order:
; North, East, West, South. Only the first passageway found is retained; the others are filled in with walls.

L4504:  ADD  HL,DE                              ; Apply the position offset to the Exit location.

        LD   A,(HL)
        CP   _MP                                ; Does this location contain a passageway?
        JR   NZ,L4512                           ; Jump ahead if not to make a return.

; The location contains a passageway.

        BIT  0,C                                ; Has an adjacent passageway already been found?
        JR   Z,L4510                            ; Jump ahead if not.

; This is another adjacent passageway.

        LD   (HL),_MW                           ; Fill in the position with a wall.

; This is the first adjacent passageway found.

L4510:  LD   C,$01                              ; Signal that an adjacent passageway has been found.

L4512:  RET

; ------------------------
; Insert Rex into the Maze
; ------------------------
; An attempt is made to insert Rex at row 1 column 5. If a wall exists here then an attempt is made to the east (column 6).
; If this also contains a wall then the process is repeated for columns 7 to 10. If a passageway location has still not been found
; then the search moves to row 2 column 5 and continues across to column 10. If a passageway location is still not found then the
; process moves to row 3 column 5, and continues across and down the maze until the first passageway location is found.
; This routine is called from BASIC.

L4513:  LD   HL,L4600+$0005                     ; Point at row 1 column 5 within the maze.

L4516:  LD   B,$06                              ; There are 6 possible positions to consider in the current row (spanning columns 5 to 10).

L4518:  BIT  7,(HL)                             ; Does the location contain a wall?
        JR   Z,L4525                            ; Jump ahead if it does not.

; The location contains a wall.

        INC  HL                                 ; Advance to the east.
        DJNZ L4518                              ; Repeat for all test positions.

; A passageway location was not found so the search is repeated on the next row.

        LD   BC,$000A
        ADD  HL,BC                              ; Advance to the 6th column in the row below.

        JR   L4516                              ; Jump back to search 6 positions within the new row.

; A passageway location was found.

L4525:  LD   (L4088),HL                         ; Note the location of Rex.
        LD   (HL),_MR                           ; Insert Rex into the maze.

        JP   L4D92                              ; Jump to attempt to insert a passageway to the east 10 tiles long.

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L452D:
        DEFB $00, $00, $00

        DEFB $00, $05
        DEFW $01F7
        DEFB _REM

        DEFB $00

; -----
; Score
; -----
; The maximum score is 9995. A wrap back to 0 will then occur.

L4536:  DEFB _0, _0, _0, _0

; --------------------------------------------
; Score Increment of 200 for Escaping the Maze
; --------------------------------------------
; The most significant digit is first.

L453A:  DEFB $00, $02, $00, $00

; -----------------------------------------
; Score Increment of 5 for Avoiding Capture
; -----------------------------------------
; The most significant digit is first.

L453E:  DEFB $00, $00, $00, $05

; ---------------
; Status Messages
; ---------------

; "   REX LIES IN WAIT   "

L4542:  DEFB _SPACE, _SPACE, _SPACE, _R, _E, _X, _SPACE, _L, _I, _E, _S, _SPACE, _I, _N, _SPACE, _W, _A, _I, _T, _SPACE, _SPACE, _SPACE

; " run HE IS BEHIND YOU "

L4558:  DEFB _SPACE, _INVR, _INVU, _INVN, _SPACE, _H, _E, _SPACE, _I, _S, _SPACE, _B, _E, _H, _I, _N, _D, _SPACE, _Y, _O, _U, _SPACE

; " run HE IS BESIDE YOU "

L456E:  DEFB _SPACE, _INVR, _INVU, _INVN, _SPACE, _H, _E, _SPACE, _I, _S, _SPACE, _B, _E, _S, _I, _D, _E, _SPACE, _Y, _O, _U, _SPACE

; "   REX HAS SEEN YOU   "

L4584:  DEFB _SPACE, _SPACE, _SPACE, _R, _E, _X, _SPACE, _H, _A, _S, _SPACE, _S, _E, _E, _N, _SPACE, _Y, _O, _U, _SPACE, _SPACE, _SPACE

; " FOOTSTEPS APPROACHING"

L459A:  DEFB _SPACE, _F, _O, _O, _T, _S, _T, _E, _P, _S, _SPACE, _A, _P, _P, _R, _O, _A, _C, _H, _I, _N, _G

; " HE IS HUNTING FOR YOU"

L45B0:  DEFB _SPACE, _H, _E, _SPACE, _I, _S, _SPACE, _H, _U, _N, _T, _I, _N, _G, _SPACE, _F, _O, _R, _SPACE, _Y, _O, _U

; --------------------------
; Blank Instruction Row Text
; --------------------------

L45C6:  DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; --------
; Not Used
; --------

L45DC:  DEFB $00, $00, $00, $00, $00, $00

; --------------------------------------------
; The Characters Displayed in the Exit Pattern
; --------------------------------------------
; The characters forming the concentric squares of the Exit patterns, listed from the outermost to innermost.

L45E2:  DEFB _V, _INVQUOTE, _DIVIDE, _W, _X, _B, _I, _V, _INVC, _S, _G

; ---------------------------
; Next Exit Pattern Character
; ---------------------------
; Holds a value between $00 and $7F indicating the next character to display in the Exit pattern.
; Values of $40 and above represent inverse characters.

L45ED:  DEFB $4D

; --------
; Not Used
; --------

L45EE:  DEFB $00, $00

; ----
; Maze
; ----
; The maze lies on a page boundary, allowing the code to check only the low byte of its address.
; The maze is 18 positions north-to-south (rows 0 to 17) and 16 positions west-to-east (columns 0 to 15).
;
;    N
;    |
; W -+- E
;    |
;    S
;
; Key: $80=Wall, $00=Passageway, $08=Trail left by Rex, $32=Rex, $2D=Exit.

L45F0:  DEFB _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW
L4600:  DEFB _MW, _MP, _MW, _MP, _MW, _MW, _MR, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MP
L4610:  DEFB _MW, _MP, _MP, _MP, _MP, _MP, _MT, _MP, _MP, _MP, _MP, _MP, _MP, _MW, _MW, _MP
L4620:  DEFB _MW, _MP, _MW, _MP, _MW, _MW, _MT, _MW, _MW, _MW, _MP, _MW, _MW, _MW, _MW, _MP
L4630:  DEFB _MW, _MT, _MT, _MT, _MT, _MT, _MT, _MW, _MW, _MW, _MP, _MP, _MP, _MP, _MP, _MP
L4640:  DEFB _MW, _MT, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MW, _ME, _MW, _MW, _MW, _MW, _MP
L4650:  DEFB _MW, _MT, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MP
L4660:  DEFB _MW, _MT, _MP, _MT, _MP, _MP, _MT, _MT, _MT, _MT, _MT, _MW, _MW, _MW, _MW, _MP
L4670:  DEFB _MW, _MT, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MW, _MT, _MT, _MT, _MT, _MP, _MP
L4680:  DEFB _MW, _MT, _MW, _MT, _MW, _MW, _MT, _MT, _MT, _MT, _MW, _MW, _MT, _MW, _MW, _MP
L4690:  DEFB _MW, _MT, _MT, _MT, _MT, _MT, _MT, _MW, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MP
L46A0:  DEFB _MW, _MP, _MW, _MT, _MW, _MW, _MP, _MW, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MP
L46B0:  DEFB _MW, _MP, _MW, _MT, _MW, _MW, _MP, _MW, _MW, _MT, _MW, _MW, _MT, _MW, _MW, _MP
L46C0:  DEFB _MW, _MP, _MP, _MT, _MT, _MT, _MT, _MT, _MT, _MT, _MT, _MT, _MT, _MP, _MP, _MP
L46D0:  DEFB _MW, _MP, _MW, _MP, _MW, _MW, _MP, _MW, _MW, _MP, _MW, _MW, _MP, _MW, _MW, _MW
L46E0:  DEFB _MW, _MP, _MW, _MP, _MW, _MW, _MP, _MW, _MW, _MP, _MW, _MW, _MP, _MP, _MP, _MP
L46F0:  DEFB _MW, _MP, _MP, _MP, _MP, _MP, _MP, _MP, _MP, _MP, _MP, _MP, _MW, _MW, _MW, _MP
L4700:  DEFB _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW, _MW

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L4710:  DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

        DEFB $00, $07
        DEFW $0676
        DEFB _REM

; ---------------
; Game Loop Cycle
; ---------------

L4730:  LD   HL,L4087                           ; Point at the flags byte.

        LD   A,(L408A)                          ; Fetch the key code.
        CP   $00                                ; Has a key been pressed?
        JR   NZ,L4743                           ; Jump ahead if it has.

; A key has not been pressed.

L473A:  SET  5,(HL)                             ; Signal the player has not moved and so there is no need to redraw the view of the maze.
        BIT  4,(HL)                             ; [Redundant]
        JP   L4D6C                              ; Jump to animate the Exit pattern and then redraw the 3D view.

L4741:  JR   L4770                              ; Jump to attempt to move Rex and draw the 3D view. [Redundant]

; A key has been pressed.

L4743:  CP   _7                                 ; Is it forwards?
        JR   NZ,L474B                           ; Jump ahead if not.

; Move forward was selected.

        SET  6,(HL)                             ; Signal to move the player forward.
        JR   L476C                              ; Jump ahead to continue.

; The player did not move forwards.

L474B:  CP   _5                                 ; Is it turn left?
        JR   NZ,L475B                           ; Jump ahead if not.

; Turn left was selected.

        LD   A,(L4084)                          ; Fetch the player's direction.
        INC  A                                  ; Rotate the player left.
        CP   $04                                ; Has the player rotated all the way round?
        JR   NZ,L4769                           ; Jump ahead if not.

        LD   A,$00                              ; Wrap round the player's direction.
        JR   L4769                              ; Jump ahead to continue.

; The player did not rotate left.

L475B:  CP   _8                                 ; Is it turn right?
        JR   NZ,L473A                           ; Jump back to signal no valid key was pressed.

; Turn right was selected.

        LD   A,(L4084)                          ; Fetch the player's direction.
        CP   $00                                ; Will the rotation cause a wrap around?
        JR   NZ,L4768                           ; Jump ahead if not.

        LD   A,$04                              ; Wrap round the player's direction.

L4768:  DEC  A                                  ; Rotate the player right.

L4769:  LD   (L4084),A                          ; Store the new direction ($00=North, $01=West, $02=South, $03=East).

L476C:  RES  5,(HL)                             ; Signal the player has moved and so the view of the maze will need to be redrawn.
        RES  7,(HL)                             ; Signal the player has not been caught.

; -------------------
; Attempt to Move Rex
; -------------------
; The following actions are performed:
; - If the player is at the Exit then
;   - Draw the Exit pattern
; - Else
;   - Attempt to move Rex towards the player
;   - If Rex has caught the player then
;     - Draw screen showing Rex has caught the player
;   - Else
;     - If the player moved forwards but there was a wall ahead then
;       - Attempt to draw Rex on top of the existing 3D view
;     - Else
;       - Draw the 3D view

L4770:  LD   HL,(L4082)                         ; Fetch the location of the player.

        LD   A,(HL)                             ; Fetch the contents of the player's location.
        CP   _H                                 ; Is the player at the Exit?
        JP   Z,L4B2F                            ; Jump ahead if so.

; The player is not at the Exit.

        LD   A,$00
        LD   (L408C),A                          ; Assume Rex is at the same location as the player.

        LD   A,$07
        LD   (L408D),A                          ; Set the frame display index for Rex such that Rex is beyond the visible range.

        CALL L4A52                              ; Attempt to move Rex.
        CALL L4A34                              ; Has Rex caught the player? This call only returns if not.

        LD   A,(L4084)                          ; Fetch the player's direction.
        CP   $00                                ; Is the player facing north?
        JR   NZ,L4798                           ; Jump ahead if not.

; The player is facing north.

        LD   DE,$FFF0                           ; Offset for position in front of the player (-16).
        LD   BC,$0001                           ; Offset to the location to the right of the direction the player is facing (to the east).
        JR   L47B9                              ; Jump ahead to continue.

; The player is not facing north.

L4798:  CP   $01                                ; Is the player facing west?
        JR   NZ,L47A4                           ; Jump ahead if not.

; The player is facing west.

        LD   DE,$FFFF                           ; Offset for position in front of the player (-1).
        LD   BC,$FFF0                           ; Offset to the location to the right of the direction the player is facing (to the north).
        JR   L47B9                              ; Jump ahead to continue.

; The player is not facing west.

L47A4:  CP   $02                                ; Is the player facing south?
        JR   NZ,L47B0                           ; Jump ahead if not.

; The player is facing south.

        LD   DE,$0010                           ; Offset for position in front of the player (+16).
        LD   BC,$FFFF                           ; Offset to the location to the right of the direction the player is facing (to the west).
        JR   L47B9                              ; Jump ahead to continue.

; The player is not facing south.

L47B0:  CP   $03                                ; Is the player facing east?
        RET  NZ                                 ; Return if not (must be an invalid direction - should never happen).

; The player is facing east.

        LD   DE,$0001                           ; Offset for position in front of the player (+1).
        LD   BC,$0010                           ; Offset to the location to the right of the direction the player is facing (to the south).

; Joins here to check whether to move the player and hence redraw the view of the maze.

L47B9:  LD   HL,L4087                           ; Point at the flags byte.
        BIT  5,(HL)                             ; Did the player move and so the view of the maze needs to be redrawn?
        LD   HL,(L4082)                         ; Fetch the location of the player.
        JP   NZ,L4ADF                           ; Jump if not to determine the distance to Rex and to display him (on top of the current view).

; The player moved and so the entire maze view needs to be redrawn.

        LD   A,(L4087)                          ; Fetch the flags byte.
        BIT  6,A                                ; Did the player move forwards?
        JR   Z,L47D9                            ; Jump ahead if not.

; The player requested to move forwards.

        ADD  HL,DE                              ; Point to the new location.
        BIT  7,(HL)                             ; Does it contain a wall?
        JP   Z,L47D9                            ; Jump ahead if not.

; The new position contains a wall.

        RES  6,A                                ; Clear the player moved forwards flag.
        LD   (L4087),A                          ; Save the updated flags.

        JP   L4AF4                              ; Jump ahead to just draw Rex on top of the current view, overwriting the previous Rex sprite (if present).

; The player has moved forwards and the new location contains a passageway, or the player has turned to the left or right.

L47D9:  LD   A,(L4087)
        RES  4,A                                ; Assume the Exit is not visible.
        LD   (L4087),A

        LD   (L4082),HL                         ; Store the player's new location.

; ----------------
; Draw the 3D View
; ----------------
; The view is divided into 7 sections that correspond to different distances:
; - Section 0 is 24 characters tall and 1 character wide.
; - Section 1 is 22 characters tall and 4 characters wide.
; - Section 2 is 14 characters tall and 3 characters wide
; - Section 3 is 8 characters tall and 2 characters wide.
; - Section 4 is 4 characters tall and 1 character wide.
; - Section 5 is 2 characters tall and 1 character wide.
; - Section 6 is 2 characters tall and 1 character wide.
;
; 0|    |   |  | | | | | |  |   |    |0              |    |   |  | | | | | |  |   |    |0
; 0|1   |   |  | | | | | |  |   |   1|0             0|1   |   |  | | | | | |  |   |    |0
; 0|11  |   |  | | | | | |  |   |  11|0             0|11  |   |  | | | | | |  |   |    |0
; 0|111 |   |  | | | | | |  |   | 111|0             0|111 |   |  | | | | | |  |   |    |0
; 0|1111|   |  | | | | | |  |   |1111|0             0|1111|   |  | | | | | |  |   |    |0
; 0|1111|2  |  | | | | | |  |  2|1111|0             0|1111|   |  | | | | | |  |  2|1111|0
; 0|1111|22 |  | | | | | |  | 22|1111|0             0|1111|   |  | | | | | |  | 22|1111|0
; 0|1111|222|  | | | | | |  |222|1111|0             0|1111|   |  | | | | | |  |222|1111|0
; 0|1111|222|3 | | | | | | 3|222|1111|0             0|1111|222|3 | | | | | |  |222|1111|0
; 0|1111|222|33| | | | | |33|222|1111|0             0|1111|222|33| | | | | |  |222|1111|0
; 0|1111|222|33|4| | | |4|33|222|1111|0             0|1111|222|33| | | | |4|33|222|1111|0
; 0|1111|222|33|4|5|6|5|4|33|222|1111|0             0|1111|222|33|4|5|6|5|4|33|222|1111|0
; 0|1111|222|33|4|5|6|5|4|33|222|1111|0             0|1111|222|33|4|5|6|5|4|33|222|1111|0
; 0|1111|222|33|4| | | |4|33|222|1111|0             0|1111|222|33| | | | |4|33|222|1111|0
; 0|1111|222|33| | | | | |33|222|1111|0             0|1111|222|33| | | | | |  |222|1111|0
; 0|1111|222|3 | | | | | | 3|222|1111|0             0|1111|222|3 | | | | | |  |222|1111|0
; 0|1111|222|  | | | | | |  |222|1111|0             0|1111|   |  | | | | | |  |222|1111|0
; 0|1111|22 |  | | | | | |  | 22|1111|0             0|1111|   |  | | | | | |  | 22|1111|0
; 0|1111|2  |  | | | | | |  |  2|1111|0             0|1111|   |  | | | | | |  |  2|1111|0
; 0|1111|   |  | | | | | |  |   |1111|0             0|1111|   |  | | | | | |  |   |    |0
; 0|111 |   |  | | | | | |  |   | 111|0             0|111 |   |  | | | | | |  |   |    |0
; 0|11  |   |  | | | | | |  |   |  11|0             0|11  |   |  | | | | | |  |   |    |0
; 0|1   |   |  | | | | | |  |   |   1|0             0|1   |   |  | | | | | |  |   |    |0
; 0|ssss|sss|ss|s|s|s|s|s|ss|sss|sss |0              |ssss|sss|ss|s|s|s|s|s|ss|sss|sss |0
;
; The status message appears on row 23 between columns 1 and 22.
;
; Section 6 will display as chequerboard if there is a wall at this distance, or black if not.
; Rex is only visible at distance 5 or closer.
;
;
; The following actions are performed:
; - Draw the wall side / passageway gap next to the player on the right (section 0)
; - Draw the wall side / passageway gap next to the player on the left (section 0)
; - Enter a loop for sections 1 to 5 performing the following actions:
;    - If a wall is in front of the player then
;      - Draw the wall face
;      - If at the Exit then
;        - Draw the Exit pattern
;    - Else
;      - Draw the wall side / passageway gap on the right
;      - Draw the wall side / passageway gap on the left
; - Draw distance 6, which is either a wall face (chequerboard) or further distance not visible (black)
; - Enter a loop from section 5 and moving towards the player performing the following actions:
;   - Draw all visible wall faces on the left
;   - Draw all visible wall faces on the right
; - If Rex is ahead and within visible range then
;   - Draw Rex

; HL=Location of the player.
; DE=The offset ahead in the direction player is facing.
; BC=The offset from the direction the player is facing to the location to the right.

        PUSH DE                                 ; Save the offset to the position ahead in the direction the player is facing.
        PUSH BC                                 ; Save the offset from the direction the player is facing to the location to the right.
        PUSH HL                                 ; Save the location of the player.

; Draw wall sides for section 0
; -----------------------------

        ADD  HL,BC                              ; Point at the location to the right of the direction being faced.

        LD   BC,$0100                           ; B=Section is 1 character wide. C=Distance is next to player.
        LD   (L4085),BC                         ; Save the details of the section.

        CALL L4884                              ; Draw the section (wall or passageway) on the right at distance 0.

        POP  HL                                 ; Retrieve the location of the player, i.e. the view location.
        POP  BC                                 ; Retrieve the offset from the direction the player is facing to the location to the right.
        PUSH HL                                 ; Save the view location.

        AND  A
        SBC  HL,BC                              ; Subtract the offset to point to the position to the left of the direction the player is facing.

        PUSH BC                                 ; Save the offset from the direction the player is facing to the location to the right.

        CALL L4904                              ; Draw the section (wall or passageway) on the left at distance 0.

; Draw wall sides for sections 1 to 5
; -----------------------------------

        LD   BC,$0401                           ; B=Section is 4 characters wide. C=Distance begins in front of the player.

; Enter a loop to draw each section. Each section reduces in width as the distance increases, capping at a width of 1 for distances 4 and 5.

L47FF:  LD   (L4085),BC                         ; Save the details of the section.

        LD   HL,L408C
        INC  (HL)                               ; Increment the distance count of Rex from the player.

        POP  BC                                 ; Retrieve the offset from the direction the player is facing to the location to the right.
        POP  HL                                 ; Retrieve the view location.
        POP  DE                                 ; Retrieve the offset to the position ahead in the direction the player is facing.

        ADD  HL,DE                              ; Advance the next location.
        BIT  7,(HL)                             ; Does it contain a wall?
        JP   NZ,L49F6                           ; Jump ahead if it does.

; The location ahead does not contain a wall.

        LD   A,(L4088)                          ; Fetch the low byte of Rex's location.
        CP   L                                  ; Is Rex at this location?
        JR   NZ,L481C                           ; Jump ahead if not.

; Rex is at this location.

        LD   A,(L408C)                          ; Fetch the distance count of Rex from the player.
        LD   (L408D),A                          ; Store it as the frame to display for Rex.

L481C:  LD   A,(HL)
        CP   _ME                                ; Is the Exit at this location?
        JR   NZ,L4829                           ; Jump ahead if not.

; The Exit is at this location.

        LD   A,(L4087)                          ; Fetch the flags.
        SET  4,A                                ; Signal the Exit is visible.
        LD   (L4087),A                          ; Store the updated flags.

L4829:  PUSH DE                                 ; Save the offset to the position ahead in the direction the player is facing.
        PUSH BC                                 ; Save the offset from the direction the player is facing to the location to the right.
        PUSH HL                                 ; Save the new view location.

        ADD  HL,BC                              ; Point at the location to the right of the direction being faced.

        CALL L4884                              ; Draw the section (wall or passageway) on the right at the current distance.

        POP  HL                                 ; Retrieve the new new location.
        POP  BC                                 ; Retrieve the offset from the direction the player is facing to the location to the right.
        PUSH HL                                 ; Save the view location.

        AND  A
        SBC  HL,BC                              ; Subtract the offset to point to the position to the left of the direction the player is facing.

        PUSH BC

        CALL L4904                              ; Draw the section (wall or passageway) on the left at the current distance.

; C holds the distance of the next section further away from the player.

        LD   A,(L4086)                          ; Fetch the width of the section.
        LD   B,A
        DJNZ L47FF                              ; Decrement the width and draw the next section unless the width was 1.

; All sections that have a width of 2 or more have now been draw, i.e. sections 1, 2 and 3.
; Sections 4 and 5 are only 1 character wide.

        LD   B,$01                              ; The section has a width of 1.
        LD   A,C                                ; Fetch the distance.
        CP   $0C                                ; Has distance 12, i.e. section 6, been reached?
        JR   C,L47FF                            ; Jump back if not to draw the next section.

; Sections 1 to 5 have now been drawn.

        POP  DE                                 ; Discard the offset from the direction the player is facing to the location to the right.
        POP  HL                                 ; Retrieve the view location.
        POP  DE                                 ; Retrieve the offset to the position ahead in the direction the player is facing.

        ADD  HL,DE                              ; Advance to the next location ahead.
        PUSH HL                                 ; Save the the maze location.

; Draw section 6
; --------------
; HL=Maze location being drawn.

; Clear column 12 of the display file to all spaces, i.e. centre column of the 3D view.

        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        PUSH BC                                 ; [Redundant]

        LD   BC,$000D
        ADD  HL,BC                              ; Point at row 0 column 12.

        LD   DE,$0021                           ; Each row is 33 characters wide.
        LD   B,$17                              ; There are 23 rows.

L4859:  LD   (HL),_SPACE                        ; Insert a space into the display file.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L4859                              ; Repeat for all rows.

        POP  BC                                 ; [Redundant]

; Now determine what to draw for this section.

        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$0178                           ; Offset to row 11 column 12 - the centre of the 3D view.
        ADD  HL,DE

        POP  DE                                 ; Retrieve the maze location.
        EX   DE,HL                              ; Transfer it to HL.

        BIT  7,(HL)                             ; Is there a wall at this location?
        JR   NZ,L4878                           ; Jump ahead if so.

; There is not a wall so insert black to show that the location is too far away to see its detail.

        LD   A,_BOTTOMBLACK
        LD   (DE),A                             ; Insert the top of the wall.
        LD   HL,$0021
        ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_TOPBLACK                     ; Insert the bottom of the wall.

        JP   L4987                              ; Jump ahead to draw all visible wall faces.

; There is a wall so insert chequerboard for the wall face.

L4878:  LD   A,_TOPWHITEBOTTOMCHEQUER
        LD   (DE),A                             ; Insert the top of the wall face.
        LD   HL,$0021
        ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_TOPCHEQUERBOTTOMWHITE        ; Insert the bottom of the wall face.

        JP   L4987                              ; Jump ahead to draw all visible wall faces.

; -----------------------
; Draw Right Hand Section
; -----------------------

L4884:  LD   BC,(L4085)                         ; Fetch the details for the section: B=Width of section, C=Distance of section from player.
        BIT  7,(HL)                             ; Is there a wall at this location?
        JR   NZ,L48C1                           ; Jump if so to draw it.

; Draw passageway gap on the right
; --------------------------------
; Entry: C=Distance from player (0=Next to player).
;        B=Width of characters in this section.

; Enter a loop to draw columns of the passageway within this section, starting from point closest to the
; player and advancing towards the horizon.

L488C:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   A,$19
        SUB  C                                  ; Determine the column of this position within the section in the display file.

        LD   E,A
        LD   D,$00
        ADD  HL,DE                              ; Advance across the screen to the column to draw.

; HL=Point to the column within the display file to draw.

        LD   DE,$0021                           ; There are 33 characters per row.

        LD   A,C                                ; Fetch the distance.
        CP   $00                                ; Is this position next to the player?
        LD   A,B                                ; Fetch the offset into the section.
        LD   B,$17                              ; The height of the column within the section to draw.
        JR   NZ,L48A2                           ; Jump ahead if the position is not next to the player.

        INC  B                                  ; There is an extra row to blank out if right next to the player.

; Enter a loop to blank the entire column at this position.

L48A2:  LD   (HL),_SPACE                        ; Insert a space into the display file.
        ADD  HL,DE                              ; Advance to the next display file row.
        DJNZ L48A2                              ; Repeat for the height of the section column.

; The column has been blanked.

        LD   B,A                                ; Fetch the offset into the section.
        LD   A,C                                ; Fetch the distance.
        CP   $0B                                ; Has the furthest visible distance been reached?
        JR   Z,L48B1                            ; Jump ahead if so.

        INC  C                                  ; Increment the distance.
        DJNZ L488C                              ; Repeat for all positions within this section.

        RET

; The furthest visible distance has been reached, so insert a wall face.

L48B1:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$0179                           ; Offset to row 11 column 13.
        ADD  HL,DE
        LD   DE,$0021                           ; The offset to the row below.
        LD   (HL),_TOPWHITEBOTTOMCHEQUER        ; Insert the top of the wall face.
        ADD  HL,DE                              ; Advance to the row below.
        LD   (HL),_TOPCHEQUERBOTTOMWHITE        ; Insert the bottom of the wall face.
        RET

; Draw wall side on the right
; ---------------------------
; Entry: C=Distance from player (0=Next to player).
;        B=Width of characters in this section.

; Enter a loop to draw columns of the wall within this section, starting from point closest to the
; player and advancing towards the horizon.

L48C1:  PUSH BC                                 ; Save the section distance and width.

        LD   DE,$0019                           ; Offset to row 0 column 24.
        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        ADD  HL,DE                              ; Advance to row 0 column 24.

        LD   DE,$0021                           ; There are 33 characters per row.

        LD   A,$16                              ; There are 22 rows (omitting the top and bottom diagonals) of the wall height.
        LD   B,C                                ; Transfer the current distance to B, which dictates how much to reduce the wall height for display at this distance.
        SLA  B                                  ; Multiply by 2 since the wall progresses up and down.
        SUB  B                                  ; Determine the height of the wall to display.

        LD   B,$00
        AND  A
        SBC  HL,BC                              ; Determine the column within the section of the wall to draw.

        LD   B,C                                ; Fetch the distance, which dictates the number of blank rows above and below the wall.

        PUSH AF                                 ; Save the wall height.

        LD   A,B                                ; Are any blank rows required at the top of the displayed wall?
        CP   $00
        JR   Z,L48E3                            ; Jump ahead if not.

; Draw the spaces in this column above the wall.

L48DE:  LD   (HL),_SPACE                        ; Insert a space into the display file.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L48DE                              ; Repeat until the top of the wall is reached.

L48E3:  POP  AF                                 ; Retrieve the wall height.

; Draw the top diagonal of the wall at this column position.

        LD   (HL),_TOPLEFTWHITE                 ; Insert the top diagonal of the wall.
        LD   B,A                                ; Transfer the wall height to B.
        CP   $00                                ; Is the wall tall enough for its body to be visible?
        JR   Z,L48F0                            ; Jump ahead if not.

; Draw the body of the wall at this column position.

L48EB:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_BLACK                        ; Insert a block of the wall.
        DJNZ L48EB                              ; Repeat for the height of the wall.

; Draw the bottom diagonal of the wall at this column position.

L48F0:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_BOTTOMLEFTWHITE              ; Insert the bottom diagonal of the wall.

        LD   A,C                                ; Fetch the distance.
        CP   $02                                ; Is a column of blank spaces required below the wall?
        JR   C,L48FF                            ; Jump if there is no room or the status message is below.

; Draw the spaces in this column below the wall.

        LD   B,A                                ; Fetch the distance, which determines the number of black spaces required below the wall.
        DEC  B                                  ; Decrement to omit the message status row.

L48FA:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_SPACE                        ; Insert a space into the display file.
        DJNZ L48FA                              ; Repeat until the bottom of the view has been reached.

; The column of the view has been drawn.

L48FF:  POP  BC                                 ; Retrieve the wall section distance and width.
        INC  C                                  ; Increment the distance.
        DJNZ L48C1                              ; Repeat for all positions within this wall section.

        RET

; ----------------------
; Draw Left Hand Section
; ----------------------
; Exit: C=Distance of the next section further away from the player.

L4904:  LD   BC,(L4085)                         ; Fetch the details for the section: B=Width of section, C=Distance of section from player.
        BIT  7,(HL)                             ; Is there a wall at this location?
        JR   NZ,L4949                           ; Jump if so to draw it.

; Draw passageway gap on the left
; -------------------------------
; Entry: C=Distance from player (0=Next to player).
;        B=Width of characters in this section.

; Enter a loop to draw columns of the passageway within this section, starting from point closest to the
; player and advancing towards the horizon.

L490C:  LD   D,$00
        LD   E,C
        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        INC  HL                                 ; Advance to row 0 column 0.
        ADD  HL,DE                              ; Advance across the screen to the column to draw.

; HL=Point to the column within the display file to draw.

        LD   DE,$0021                           ; There are 33 characters per row.

        LD   A,C                                ; Fetch the distance.
        CP   $00                                ; Is this position next to the player?
        LD   A,B                                ; Fetch the offset into the section.
        LD   B,$17                              ; The height of the passageway at this distance.
        JR   NZ,L4920                           ; Jump ahead if the position is not next to the player.

        INC  B                                  ; There is an extra row to blank out if right next to the player.

; Enter a loop to blank the entire column at this position.

L4920:  LD   (HL),_SPACE                        ; Insert a space into the display file.
        ADD  HL,DE                              ; Advance to the next display file row.
        DJNZ L4920                              ; Repeat for the height of the section column.

; The column has been blanked.

        LD   B,A                                ; Fetch the offset into the section.
        LD   A,C                                ; Fetch the distance.
        CP   $0B                                ; Has the furthest visible distance been reached?
        JR   Z,L4936                            ; Jump ahead if so.

        INC  C                                  ; Increment the distance.
        DJNZ L490C                              ; Repeat for all positions within this section.

; The section has been drawn.

        LD   BC,(L4085)                         ; Fetch the details for the section just drawn: B=Width of section, C=Distance of section from player.
        LD   A,B
        ADD  A,C
        LD   C,A                                ; Determine the distance of the next section to draw.
        RET

; The furthest visible distance has been reached, so insert a wall face.

L4936:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$0177                           ; Offset to row 11 column 11.
        ADD  HL,DE
        LD   DE,$0021                           ; The offset to the row below.
        LD   (HL),_TOPWHITEBOTTOMCHEQUER        ; Insert the top of the wall face.
        ADD  HL,DE                              ; Advance to the row below.
        LD   (HL),_TOPCHEQUERBOTTOMWHITE        ; Insert the bottom of the wall face.

        LD   BC,$000C                           ; Set the next section at the furthest visible distance.
        RET

; Draw wall side on the left
; --------------------------
; Entry: C=Distance from player (0=Next to player).
;        B=Width of characters in this section.

; Enter a loop to draw columns of the wall within this section, starting from point closest to the
; player and advancing towards the horizon.

L4949:  PUSH BC                                 ; Save the section distance and width.

        LD   DE,$0021                           ; There are 33 characters per row.

        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        INC  HL                                 ; Point to row 0 column 0.

        LD   A,$16                              ; There are 22 rows (omitting the top and bottom diagonals) of the wall height.
        LD   B,C                                ; Transfer the current distance to B, which defines how much to reduce the displayed wall height at this distance.
        SLA  B                                  ; Multiply by 2 since the wall progresses up and down from the centre row.
        SUB  B                                  ; Determine the height of the wall to display.

        LD   B,$00
        ADD  HL,BC                              ; Determine the column within the section of the wall to draw.

        LD   B,C                                ; Fetch the distance.

        PUSH AF                                 ; Save the wall height.

        LD   A,B                                ; Are any blank rows required at the top of the displayed wall?
        CP   $00
        JR   Z,L4966                            ; Jump ahead if not.

; Draw the spaces in this column above the wall.

L4961:  LD   (HL),_SPACE                        ; Insert a space into the display file.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L4961                              ; Repeat until the top of the wall is reached.

; The top of the row has been reached.

L4966:  POP  AF                                 ; Retrieve the wall height.

; Draw the top diagonal of the wall at this column position.

        LD   (HL),_TOPRIGHTWHITE                ; Insert the top diagonal of the wall.
        LD   B,A                                ; Transfer the wall height to B.
        CP   $00                                ; Is the wall tall enough to be visible?
        JR   Z,L4973                            ; Jump ahead if not.

; Draw the body of the wall at this column position.

L496E:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_BLACK                        ; Insert a block of the wall.
        DJNZ L496E                              ; Repeat for the height of the wall.

; Draw the bottom diagonal of the wall at this column position.

L4973:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_BOTTOMRIGHTWHITE             ; Insert the bottom diagonal of the wall.

        LD   B,C                                ; Fetch the distance.

        LD   A,C                                ; Fetch the distance.
        CP   $02                                ; Is a column of blank spaces required below the wall?
        JR   C,L4982                            ; Jump if there is no room or the status message is below.

; Draw the spaces in this column below the wall.

        DEC  B                                  ; Determine the number of blank spaces required below the wall, decrementing to omit the message status row.

L497d:  ADD  HL,DE                              ; Advance to the next row of the display file.
        LD   (HL),_SPACE                        ; Insert a space into the display file.
        DJNZ L497D                              ; Repeat until the bottom of the view has been reached.

; The column of the view has been drawn.

L4982:  POP  BC                                 ; Retrieve the section distance and width.
        INC  C                                  ; Increment the distance.
        DJNZ L4949                              ; Repeat for all positions within this wall section.

        RET

; -------------------------
; Draw Left Hand Wall Faces
; -------------------------
; All 6 sections of the view either side of the player have been processed to draw the sides of the walls or gaps for the passageways.
; The walling faces of passageways now need to be drawn, first all those on the left of the view and then all those on the right.
; A test is made from the furthest visible distance progressing towards the player looking for the top of the wall side within the display file.
; If a wall character is not found then this must be part of a passageway gap and the current display file row represents the top of the
; wall face to draw. A column of the wall face is drawn and then the whole process is repeated to check the next column within the
; display file to see if it contains a wall. If not then this must also show a wall face of the same height as previously drawn.

; Find the starting display file position for the left hand side.

L4987:  LD   BC,$000C                           ; C=Furthest visible distance.
        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        ADD  HL,BC                              ; Offset to row 0 column 11, furthest visible distance of the left hand area.

        LD   B,$01                              ; If a passageway is found then it will be the first position within it.

        LD   DE,$016B                           ; Offset by 11 rows down to row 11 column 11.
        ADD  HL,DE

        LD   DE,$0021                           ; Each row is 33 characters wide.

; Enter a loop to check all display columns to the left of the player.
; B holds the position within the passageway.

L4997:  AND  A
        SBC  HL,DE                              ; Point to the row above.
        DEC  HL                                 ; Point to the column to the left.
        DEC  C                                  ; Decrement the distance.
        JR   Z,L49BD                            ; Jump if all distances up to the player have been examined.

; HL=Position at which the top of the wall side would be within this display file column if it were present.

        LD   A,(HL)                             ; Fetch the contents of the display file location.
        CP   _SPACE                             ; Is there a wall character at this distance?
        JR   Z,L49A7                            ; Jump if not.

; There is a wall character at this position and so there is no need to draw a wall face.

        LD   B,$01                              ; If a passageway is found then it will be the first position within it.
        JR   L4997                              ; Loop back to examine the next column.

; There is a passageway gap at this position and so a wall face must be drawn.
; B increments with each new column of a wall face to be drawn and is used to ensure the wall face is drawn starting from the
; same row each time and therefore appears of a constant height.

L49A7:  LD   A,$0D                              ; The maximum height of a wall face.
        SUB  C                                  ; Decrease it by the distance into the view.
        SUB  B                                  ; Decrease it further by the position within this passageway.
        SLA  A                                  ; Multiply by 2 since the wall spans above and below the centre point.

        PUSH BC                                 ; Save the distance and section position.
        PUSH HL                                 ; Save the display file position of the top of the wall / passageway.

L49AF:  ADD  HL,DE                              ; Advance to the row below.
        DJNZ L49AF                              ; Repeat until the top of the wall face is reached.

        LD   B,A                                ; Fetch the height of the wall face to draw.

L49B3:  LD   (HL),_CHEQUERBOARD                 ; Insert a wall face character.
        ADD  HL,DE                              ; Advance to the row below.
        DJNZ L49B3                              ; Repeat for all rows within the height of the wall face.

        POP  HL                                 ; Retrieve the display file position of the top of the wall / passageway.
        POP  BC                                 ; Retrieve the distance and section position.

        INC  B                                  ; Increment the section position.
        JR   L4997                              ; Loop back to examine the next column.

; --------------------------
; Draw Right Hand Wall Faces
; --------------------------

; Find the starting display file position for the right hand side.

L49BD:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$0179                           ; Offset to row 11 column 13.
        ADD  HL,DE

        LD   BC,$010C                           ; If a passageway is found then it will be the first position within it. C holds the furthest visible distance.
        LD   DE,$0021                           ; Each row is 33 characters wide.

; Enter a loop to check all display columns to the right of the player.
; B holds the position within the passageway.

L49CA:  AND  A
        SBC  HL,DE                              ; Point to the row above.
        INC  HL                                 ; Point to the column to the right.
        DEC  C                                  ; Decrement the distance.
        JR   NZ,L49D7                           ; Jump if all distances up to the player have not yet been examined.

; All wall faces on the right have been drawn.

        CALL L4A34                              ; Has Rex caught the player? This call only returns if not.
        JP   L4AF4                              ; Jump ahead to draw Rex.

; HL=Position at which the top of the wall side would be within this display file column if it were present.

L49D7:  LD   A,(HL)                             ; Fetch the contents of the display file location.
        CP   _SPACE                             ; Is there a wall character at this distance?
        JR   Z,L49E0                            ; Jump if not.

; There is a wall character at this position and so there is no need to draw a wall face.

        LD   B,$01                              ; If a passageway is found then it will be the first position within it.
        JR   L49CA                              ; Loop back to examine the next column.

; There is a passageway gap at this position and so a wall face must be drawn.
; B increments with each new column of a wall face to be drawn and is used to ensure the wall face is drawn starting from the
; same row each time and therefore appears of a constant height.

L49E0:  LD   A,$0D                              ; The maximum height of a wall face.
        SUB  C                                  ; Decrease it by the distance into the view.
        SUB  B                                  ; Decrease it further by the position within this passageway.
        SLA  A                                  ; Multiply by 2 since the wall spans above and below the centre point.

        PUSH BC                                 ; Save the distance and section position.
        PUSH HL                                 ; Save the display file position of the top of the wall / passageway.

L49E8:  ADD  HL,DE                              ; Advance to the row below.
        DJNZ L49E8                              ; Repeat until the top of the wall face is reached.

        LD   B,A                                ; Fetch the height of the wall face to draw.

L49EC:  LD   (HL),_CHEQUERBOARD                 ; Insert a wall face character.
        ADD  HL,DE                              ; Advance to the row below.
        DJNZ L49EC                              ; Repeat for all rows within the height of the wall face.

        POP  HL                                 ; Retrieve the display file position of the top of the wall / passageway.
        POP  BC                                 ; Retrieve the distance and section position.

        INC  B                                  ; Increment the section position.
        JR   L49CA                              ; Loop back to examine the next column.

; ----------------------------
; Draw Wall in Front of Player
; ----------------------------
; A wall has been found directly in front of the player within visible range and so a wall face must be drawn centred within the view.
; The wall face is one character wider than it is high.

L49F6:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        INC  HL                                 ; Advance to row 0 column 0.
        LD   DE,$0021                           ; Each row is 33 characters wide.

        LD   BC,(L4085)                         ; Fetch the details for the section: B=Width of section, C=Distance of section from player.
        LD   B,$00
        ADD  HL,BC                              ; Advance across the screen to the current distance of the wall.

        LD   A,$19                              ; The width of the view.
        LD   B,C                                ; Fetch the distance.
        SLA  B                                  ; Multiply the distance by 2 since the wall be spans to the left and right of the centre column of the view.
        SUB  B                                  ; Determine the width of the wall face.
        LD   B,A                                ; B=Width of the wall face (it will be an odd number of characters).

        SUB  $01                                ; Determine the wall height (it will be an even number of characters).

; Enter a loop to draw each column of the wall face.

L4A0D:  PUSH BC                                 ; Save the wall face width.
        PUSH HL                                 ; Save the address within the display file.

        LD   B,C                                ; Fetch the distance, which corresponds to the number of blank rows to show above the wall face.

L4A10:  LD   (HL),_SPACE                        ; Insert a space above the wall face.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L4A10                              ; Repeat for all rows above the wall face.

        LD   B,A                                ; Fetch the wall height.

L4A16:  LD   (HL),_CHEQUERBOARD                 ; Insert a wall face character into the display file.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L4A16                              ; Repeat for all rows forming the height of the wall face.

        LD   B,C                                ; Fetch the distance, which corresponds the the number of blank rows to show above the wall face.
        DEC  B                                  ; There is one less blank row below the wall face than above it due to the status message row.
        JR   Z,L4A24                            ; Jump if there are no rows below the wall to blank.

L4A1F:  LD   (HL),_SPACE                        ; Insert a space below the wall face.
        ADD  HL,DE                              ; Advance to the next row.
        DJNZ L4A1F                              ; Repeat for all rows below the wall face.

L4A24:  POP  HL                                 ; Retrieve the address within the display file.
        INC  HL                                 ; Advance to the next column to the right.

        POP  BC                                 ; Retrieve the wall face width.
        DJNZ L4A0D                              ; Repeat for all columns of the wall face.

; The wall face has been drawn.

        LD   A,(L4087)                          ; Fetch the flags byte.
        BIT  4,A                                ; Is the Exit visible?
        CALL NZ,L4B2F                           ; If so then draw the Exit pattern.
        JP   L4987                              ; Jump to draw any visible left and right passageway wall faces.

; -------------------------------------------
; Determine Whether Rex Has Caught the Player
; -------------------------------------------

L4A34:  LD   HL,(L4082)                         ; Fetch the location of the player.
        LD   A,(L4088)                          ; Fetch the low byte of Rex's location.
        CP   L                                  ; Is Rex at the same location as the player?
        RET  NZ                                 ; Return if not.

; Rex is at the same location as the player but must have taken a step forward in order to catch the player.

        POP  AF                                 ; Discard the return address.

        LD   A,$00                              ; Select to show frame 0 for Rex, i.e. the player has been caught frame.
        LD   (L408D),A

        LD   A,(L4087)                          ; Fetch the flags byte.
        BIT  1,A                                ; Has Rex taken a right step?
        JP   Z,L4AF4                            ; Jump ahead if not to draw Rex.

; Rex has taken a right step within this location and so has caught the player.

        SET  7,A                                ; Signal the player has been caught.
        LD   (L4087),A

        JP   L4AF4                              ; Jump ahead to draw Rex.

; -------------------
; Attempt to Move Rex
; -------------------
; This routine attempts to move Rex towards the player. The difference between the player's location and Rex's
; location is computed in both the north-south axis and the west-east axis. An attempt is made to move Rex along the
; axis with the largest delta, but if this is not possible then an attempt is made to move him along the other axis.
;
; Rex takes two steps per location - first he moves his left foot forward and then he moves his right foot forward.
; Rex moves at two speeds:
; - It takes 4 cycles for Rex to move through a location when the player has not moved.
; - It takes 2 cycles for Rex to move through a location when the player has just moved.
;
; Flags ($4087):
;
; Bit: 2 1 0
;      -----
;      0 0 0  Right foot forward
;      0 0 1  Right foot forward
;      0 1 0  Left  foot forward
;      0 1 1  Left  foot forward
;      1 0 0  Right foot forward   Rex moved to a new location. The 3 bits are reset to 000.
;
; Bit 1 is used to determine whether to draw Rex with his left or right foot forward.
; The player is caught when Rex moves into the same location and has his left foot forward.

L4A52:  LD   HL,L4087                           ; Point at the flags byte.
        LD   A,(HL)
        BIT  5,A                                ; Did the player move?
        JR   NZ,L4A5C                           ; Jump if not.

; The player moved. Set Rex on his right step so that the move will place him on his left step, which will
; either be half way through the current location or a move to a new location.

        SET  0,A                                ; Set Rex to be on his right step.

L4A5C:  INC  A                                  ; Increment the step count for Rex.

        BIT  2,A                                ; Has Rex moved into a new location?
        JR   NZ,L4A63                           ; Jump if so.

; Res is still within the same location.

        LD   (HL),A                             ; Store the new flags.
        RET

; Rex has moved to a new location.

L4A63:  AND  $F0                                ; Mask off the previous Rex movement bits.
        LD   (HL),A                             ; Store the new flags.

; Attempt to move Rex towards the player
; --------------------------------------

; Extract the player's and Rex's north-south and west-east positions.

        LD   HL,L4082                           ; Point to the location holding the player's position within the maze.
        LD   A,$00                              ; 0x(yz). y=North-south, z=West-east.
        RRD                                     ; 0y(zx).
        LD   B,A                                ; B=z0 -> High nibble of (HL) = player's west-east position.

        RRD                                     ; 0z(xy).
        LD   D,A                                ; D=0y -> Low nibble of (HL) = player's north-south position.

        RRD                                     ; 0x(yz) -> Restore (HL) back to its original value.

        LD   HL,L4088                           ; Point to the location holding Rex's position.
        RRD                                     ; 0y(zx). y=North-south, z=West-east.
        LD   C,A                                ; C=z0 -> High nibble of (HL) = Rex's west-east position.

        PUSH BC                                 ; Save the player's (B) and Rex's (C) west-east positions.

        RRD                                     ; 0z(xy).
        LD   E,A                                ; E=0y -> Low nibble of (HL) = Rex's north-south position.

        PUSH DE                                 ; Save the player's (D) and Rex's (E) north-south positions.

        RRD                                     ; 0x(yz) -> Restore (HL) back to its original value.

; Compute the west-east delta.

        LD   A,B                                ; Fetch the player's west-east position.
        CP   C                                  ; Compare to Rex's west-east position.
        JR   NC,L4A88                           ; Jump if the player is east of Rex.

; The player is west of Rex.

        LD   A,C                                ; Fetch the Rex's west-east position.
        SUB  B                                  ; Determine how the west-east delta.
        JR   L4A89                              ; Jump ahead to continue.

; The player is east of Rex.

L4A88:  SUB  C                                  ; Determine the west-east delta.

L4A89:  LD   C,A                                ; Save the west-east delta.

; Compute the north-south delta.

        LD   A,D                                ; Fetch the player's north-south position.
        CP   E                                  ; Compare to Rex's north-south position.
        JR   NC,L4A92                           ; Jump if the player is south of Rex.

; The player is north of Rex.

        LD   A,E                                ; Fetch the Rex's north-south position.
        SUB  D                                  ; Determine the north-south delta.
        JR   L4A93                              ; Jump ahead to continue.

; The player is south of Rex.

L4A92:  SUB  E                                  ; Determine the north-south delta.

; Attempt to move Rex towards the player. The axis with the largest delta is attempted first.
; If Rex cannot move along one axis then a check is made along the other.

L4A93:  CP   C                                  ; Is the north-south delta is the same or larger then the west-east delta?

        POP  DE                                 ; Retrieve the player's (D) and Rex's (E) north-south positions.
        POP  BC                                 ; Retrieve the player's (B) and Rex's (C) west-east positions.

        CALL NC,L4AA0                           ; If the north-south delta is the same or larger then the west-east delta then attempt to move Rex in the north-south direction.

; The carry flag will be set if either:
; - The north-south delta was smaller than the west-east delta.
; - Rex is in line north-south with the player and so did not move.
; - Rex could not move north-south due to a wall.

        CALL C,L4ABE                            ; If Rex has not been moved then attempt to move Rex west or east.

; The carry flag will be set if either:
; - Rex is in line west-east with the player and so did not move.
; - Rex could not move west-east due to a wall.

        CALL C,L4AA0                            ; If Rex has not been moved then attempt to move Rex north or south.
        RET

; --------------------------------------------------
; North-South Delta Same/Larger Than West-East Delta
; --------------------------------------------------
; The north-south delta between the player's position and Rex's position is the same or larger than the west-east delta.
; If Rex can be moved then the return address is dropped causing the return to by-pass further attempts to move Rex.
; Entry: D=Player's north-south position.
;        E=Rex's north-south position.
; Exit : Carry set if a move was not possible (a wall was in the way) or was not required (Rex already in line with the player).

L4AA0:  LD   HL,(L4088)                         ; Fetch Rex's location.
        LD   A,D                                ; Fetch the player's north-south position.

        PUSH BC                                 ; Save the player's (B) and Rex's (C) west-east positions.

        LD   BC,$0010                           ; Offset used to move north or south.

        CP   E                                  ; Is Rex in line or to the south of the player?
        JR   NC,L4AB0                           ; Jump if so.

; Rex to the north of the player.

        AND  A
        SBC  HL,BC                              ; Move Rex to the north.
        JR   L4AB3                              ; Jump ahead to continue.

; Rex is in line with the player or to the south of the player.

L4AB0:  JR   Z,L4ABB                            ; Jump if Rex is in line north-south with the player.

; Rex is south of the player.

        ADD  HL,BC                              ; Move Rex to the south.

L4AB3:  POP  BC                                 ; Retrieve the player's (B) and Rex's (C) west-east positions.

        BIT  7,(HL)                             ; Does the new location contain a wall?
        SCF                                     ; Signal a move could not occur.
        RET  NZ                                 ; Return if the new location contains a wall.

        AND  A                                  ; Signal a move could occur.
        JR   L4AD3                              ; Jump ahead to continue.

; Rex is in line north-south with the player.

L4ABB:  POP  BC                                 ; Retrieve the player's (B) and Rex's (C) west-east positions.

        SCF                                     ; Signal a move west or east is not required.
        RET

; -------------------------------------------
; North-South Delta Less Than West-East Delta
; -------------------------------------------
; The north-south delta between the player's position and Rex's position is the less than the west-east delta.
; If Rex can be moved then the return address is dropped causing the return to by-pass further attempts to move Rex.
; Entry: B=Player's west-east position.
;        C=Rex's west-east position.
; Exit : Carry set if a move was not possible (a wall was in the way) or was not required (Rex already in line with the player).

L4ABE:  LD   HL,(L4088)                         ; Fetch Rex's location.

        LD   A,B                                ; Fetch the player's west-east position.
        CP   C                                  ; Is Rex in line or to the west of the player?
        JR   NC,L4AC8                           ; Jump if so.

; Rex is to the east of the player.

        DEC  HL                                 ; Move Rex to the west.
        JR   L4ACB

; Rex is in line or to the west of the player.

L4AC8:  JR   Z,L4AD1                            ; Jump if Rex is in line west-east with the player.

; Rex is east of the player.

        INC  HL                                 ; Move Rex to the east.

L4ACB:  BIT  7,(HL)                             ; Does the new location contain a wall?
        SCF                                     ; Signal a move could not occur.
        RET  NZ                                 ; Return if the new location contains a wall.

        JR   L4AD3                              ; Jump ahead to continue.

; Rex is in line west-east with the player.

L4AD1:  SCF                                     ; Signal a move north or south is not required.
        RET

; Rex has moved.

L4AD3:  LD   (L4088),HL                         ; Store the new location for Rex.
        SET  3,(HL)                             ; Enter a trail character into the maze at Rex's new location.

        LD   HL,L4087                           ; Point at the flags byte.
        SET  3,(HL)                             ; Signal that Rex has moved.

        POP  DE                                 ; Discard the return address so that further attempts to move Rex are not made.
        RET

; -------------------------
; Determine Distance to Rex
; -------------------------
; HL=Location of the player.
; DE=Movement offset to apply when the player moves forwards.

L4ADF:  LD   B,$00                              ; Initially assume Rex is at the location of the player.
        LD   A,(L4088)                          ; Fetch the low byte Rex's location.
        JR   L4AED                              ; Jump ahead to enter the loop below.

; This loop continually applies an offset to the player's location in the direction being faced to determine
; whether Rex is visible and if so how far away.

L4AE6:  ADD  HL,DE                              ; Apply the offset.
        BIT  7,(HL)                             ; Does the location contain a wall?
        JP   NZ,L4B92                           ; Jump if so as Rex is not visible.

; Rex is visible.

        INC  B                                  ; Increment the distance.

L4AED:  CP   L                                  ; Is Rex at the new location?
        JR   NZ,L4AE6                           ; Loop back if not.

; The search has reached Rex.

        LD   A,B                                ; Fetch the distance.
        LD   (L408D),A                          ; Store at as the frame to display or Rex.

; Joins here when the player requested to move forwards but there was a wall ahead, or when Rex has caught the player.

; --------
; Draw Rex
; --------

L4AF4:  LD   A,(L408D)                          ; Fetch the frame display index for Rex.
        CP   $06                                ; Is Rex beyond the visible range?
        JP   NC,L4B92                           ; Jump if so.

; Rex is within visible range.

        LD   DE,L408E                           ; Point at the Rex sprite table.
        LD   HL,L4087                           ; Point at the flags byte.
        SLA  A                                  ; Multiply by 2 because of the left/right frames.
        SLA  A                                  ; Multiply by 2 to offset into the 16-bit entry table.

        BIT  1,(HL)                             ; Does Rex have left or right foot forward?
        JR   NZ,L4B0D                           ; Jump if the left foot is forward.

        LD   L,$02                              ; Add an offset so that the sprite with Rex's right foot forward is accessed.
        ADD  A,L

L4B0D:  LD   L,A                                ; Transfer the offset to HL.
        LD   H,$00
        ADD  HL,DE                              ; Index into the Rex sprite table.

        LD   D,(HL)
        INC  HL
        LD   E,(HL)                             ; Fetch the address of the sprite image.
        EX   DE,HL                              ; Transfer to DE.

        LD   B,(HL)                             ; Fetch the high byte of the starting offset into the display file.
        INC  HL

        LD   DE,(D_FILE)                        ; Fetch the location of the display file.

L4B1B:  EX   DE,HL                              ; DE=Display file, HL=Sprite data.

        LD   A,(DE)                             ; Fetch the start of the next entry?
        CP   $00                                ; Has the end of the data been reached?
        JP   Z,L4CB3                            ; Jump ahead if so.

; There is more data to display.

        LD   C,A                                ; Fetch the low byte of the display file offset.
        ADD  HL,BC                              ; HL=Display file address to draw graphics at.

        INC  DE                                 ; Point at the number of characters in the graphic row.
        LD   A,(DE)                             ; Fetch the number of characters.
        LD   B,$00
        LD   C,A                                ; Transfer the number of characters to BC.

        INC  DE                                 ; Point to the start of the characters to display.
        EX   DE,HL                              ; HL=Address of the characters, DE=Destination within display file.
        LDIR                                    ; Copy the graphic characters into the display file.

        JR   L4B1B                              ; Loop back to process the next entry.

; -------------------------
; The Player is at the Exit
; -------------------------
; The following draws the concentric squares forming the Exit pattern.

; First fetch the next character to be displayed in the Exit pattern.

L4B2F:  LD   A,(L45ED)                          ; Fetch the next character to display in the Exit pattern.
        CP   $40                                ; Has the end of the non-inverted characters been reached?
        JR   C,L4B38                            ; Jump ahead if not.

        ADD  A,$40                              ; Advance to the inverted characters.

L4B38:  LD   (L45ED),A                          ; Store as the next Exit pattern character.

; Shift the list of previous Exit pattern characters from the innermost to the outermost.

        LD   HL,L45E2+$0001                     ; Point at penultimate outermost character.
        LD   DE,L45E2                           ; Point at the outermost character.
        LD   BC,$000C                           ; There are 12 characters to shift.
        LDIR                                    ; Shift the characters along.

; Determine the number of layers of the Exit pattern that are visible.

        LD   BC,(L4085)                         ; C=Distance of Exit from player.
        LD   B,$00                              ; Used to hold the size of the current layer of the Exit pattern to draw.
        LD   A,$0C                              ; The maximum number of visible steps ahead.
        SUB  C                                  ; Determine the number of steps to the Exit.

        SLA  A                                  ; Determine the number of layers of the Exit pattern to display,
        LD   C,A                                ; and hold it in the C register.

        CP   $04                                ; Is there at least 4 layers of Exit pattern to display?
        RET  C                                  ; Return if not, i.e. the Exit is too far away to display.

; The Exit is close enough to be visible.

        LD   DE,(D_FILE)                        ; Fetch the location of the display file.
        LD   HL,$0199                           ; Offset to row 12 column 12 - the centre of view perspective, and hence Exit pattern.
        ADD  HL,DE

        LD   DE,L45E2+$000A                     ; Point to the innermost pattern character.
        LD   A,(DE)
        LD   (HL),A                             ; Insert it into the display file.

; Enter a loop to display all layers of the Exit pattern. Each layer is a square centred around
; the middle of the view, and form a concentric set of squares with each formed from a different
; character that has been chosen at random.

L4B62:  DEC  DE                                 ; Point to the next outer pattern character.
        PUSH DE                                 ; Save it.

; Draw the top edge of the square.

        LD   A,(DE)                             ; Fetch the next outer pattern character.
        INC  B
        INC  B                                  ; Increment the square width by 2 since it grows both to the left and right.
        PUSH BC                                 ; Save the width.

        DEC  HL                                 ; Point to the display file position to the left (reversed in the loop below).
        LD   DE,$0021
        AND  A
        SBC  HL,DE                              ; Point to the row above in the display file.

L4B6F:  INC  HL                                 ; Advance to the next display file location.
        LD   (HL),A                             ; Insert the pattern character into the display file.
        DJNZ L4B6F                              ; Repeat for all characters in the top edge of the square.

; Draw the right edge of the square.

        POP  BC                                 ; Retrieve the width.
        DEC  B                                  ; Decrement the width as the top position of the right edge has already been drawn.
        PUSH BC                                 ; Save the reduced width.

L4B76:  ADD  HL,DE                              ; Advance to the row below.
        LD   (HL),A                             ; Insert the pattern character into the display file.
        DJNZ L4B76                              ; Repeat for all characters in the right edge of the square.

; Draw the bottom line of the square.

        POP  BC                                 ; Retrieve the width.
        INC  B                                  ; Increment back to the original width.
        PUSH BC                                 ; Save the width.

L4B7D:  DEC  HL                                 ; Point to the previous display file location.
        LD   (HL),A                             ; Insert the pattern character into the display file.
        DJNZ L4B7D                              ; Repeat for all characters in the bottom edge of the square.

; Draw the left line of the square.

        POP  BC                                 ; Retrieve the width.
        DEC  B                                  ; Decrement the width as the bottom position of the left edge has already been drawn.
        PUSH BC                                 ; Save the reduced width.

L4B84:  AND  A
        SBC  HL,DE                              ; Advance to the row above.
        LD   (HL),A                             ; Insert the pattern character into the display file.
        DJNZ L4B84                              ; Repeat for all characters in the left edge of the square.

; A layer of the Exit pattern has now been drawn.

        POP  BC                                 ; Retrieve the width.
        INC  B                                  ; Increment the width for the next outer square of the Exit pattern.
        POP  DE                                 ; Fetch the pointer to the next pattern character.

        LD   A,B
        CP   C                                  ; Have all layers of the Exit pattern been displayed?
        JR   C,L4B62                            ; Loop back if not to display the next outer layer.

; The Exit pattern has been displayed.

        RET

; ------------------------------------------
; Rex is Not Visible or Beyond Visible Range
; ------------------------------------------
; When determining the sprite image to display for Rex, Rex was found not to be visible from the player's
; location and the direction being faced, or Rex was found to be beyond the visible range.
;
; The status message displayed at the bottom of the view is determined as follows:
; - If Rex moved then
;   - If Rex is at a distance of 7 or above then
;     - If Rex is at distance 7 or 8 then
;       - Display "FOOTSTEPS APPROACHING"
;     - Else if timer not expired then
;       - Display "HE IS HUNTING YOU"
;     - Else
;       - Set the countdown timer to clear the status message area
;   - Else if Rex is in line of sight of the player then
;     - If Rex is at distance 0, 1 or 2
;       - Display "run REX IS BEHIND YOU" / "run REX IS BESIDE YOU" (depending upon orientation of the player compared to Rex)
;     - Else
;       - Display "REX HAS SEEN YOU"
; - Else
;   - If countdown timer not expired then
;     - Increment the countdown timer (capping at a maximum of 8)
;   - Display "REX LIES IN WAIT"

L4B92:  LD   A,(L4087)                          ; Fetch the flags byte.
        BIT  3,A                                ; Did Rex move?
        JR   NZ,L4BB9                           ; Jump ahead if so to determine and display the status message.

; Rex did not move.

        LD   HL,L408B                           ; Point to the status area display timeout.
        LD   A,$08
        CP   (HL)                               ; Is the timeout already at its maximum value?
        JR   Z,L4BA2                            ; Jump ahead if not.

        INC  (HL)                               ; Increment the timeout value.

; Display "REX LIES IN WAIT" and the score.

L4BA2:  LD   DE,L4542-L4542                     ; Offset for status message "   REX LIES IN WAIT   ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; -----------
; ABS(Number)
; -----------
; Entry: A=Value.
; Exit : A=ABS(Value).

L4BA8:  BIT  7,A                                ; Is the number negative?
        RET  Z                                  ; Return if not.

        CPL                                     ; Negate the number.
        INC  A
        RET

; ----------------------------
; Extract High and Low Nibbles
; ----------------------------
; Entry: HL=Address of location containing 8 bit value.
; Exit : B=High nibble of value.
;        C=Low nibble of value.

L4BAE:  LD   A,$00                              ; 0x(yz).
        RRD                                     ; 0y(zx).
        LD   C,A                                ; C=z0 -> High nibble of (HL).

        RRD                                     ; 0z(xy).
        LD   B,A                                ; B=0y -> Low nibble of (HL).

        RRD                                     ; 0x(yz) -> Restore (HL) back to its original value.
        RET

; ------------------------
; Determine Status Message
; ------------------------
; The following code determines how close Rex is to the player to determine the status message that should be displayed.

L4BB9:  LD   HL,L4088                           ; Point to the location holding Rex's location.
        CALL L4BAE                              ; B=High nibble of low byte of Rex's location (north-south). C=Low nibble of low byte of Rex's location (west-east).

        PUSH BC
        POP  DE                                 ; Transfer Rex's location information to DE.

        LD   HL,L4082                           ; Point at the location holding the player's position.
        CALL L4BAE                              ; B=High nibble of low byte of player's location (north-south). C=Low nibble of low byte of player's location (west-east).

; BC=Player location details.
; DE=Rex location details.

        LD   A,B                                ; Fetch the high nibble of the low byte of the player's location (north-south value).
        SUB  D                                  ; Determine the delta between the player and Rex's north-south location (Positive if player to the south of Rex).
        LD   B,A                                ; Store the north-south delta in B.

        LD   A,C                                ; Fetch the low nibble of the low byte of the player's location (west-east value).
        SUB  E                                  ; Determine the delta between the player and Rex's west-east location (Positive if player to the east of Rex).
        LD   C,A                                ; Store the west-east delta in C.

        CP   $00                                ; Is Rex's in line west-east with the player?
        JR   NZ,L4BF9                           ; Jump ahead if not.

; Rex is in line with the player west-east.

        LD   A,B                                ; Fetch the north-south delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).

        CP   $07                                ; Is Rex close enough to be within visible range?
        JR   NC,L4C26                           ; Jump ahead if not.

; Rex is close enough north-south to be within visible range.

        PUSH BC                                 ; Save the north-south and west-east deltas.
        CALL L4C57                              ; Determine whether Rex is in line of sight with the player. A return is only made if he is, else execution continues at L4C26.
        POP  BC                                 ; Retrieve the north-south and west-east deltas.

; Rex is in line of sight of the player.

        LD   A,B                                ; Fetch the north-south delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).

        CP   $03                                ; Is Rex close to the player?
        JR   NC,L4C51                           ; Jump if not.

; Rex is close to the player.

        LD   A,(L4084)                          ; Fetch the direction the player is facing ($00=North, $01=West, $02=South, $03=East).
        BIT  0,A                                ; Is the player facing west or east?
        JR   NZ,L4BF3                           ; Jump if so, i.e. Rex is beside the player.

; Rex is behind the player.

        LD   DE,L4558-L4542                     ; Offset for status message " run HE IS BEHIND YOU ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is beside the player.

L4BF3:  LD   DE,L456E-L4542                     ; Offset for status message " run HE IS BESIDE YOU ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is not in line with the player west-east.

L4BF9:  LD   A,B                                ; Fetch the north-south delta.
        CP   $00                                ; Is Rex in line north-south with the player?
        JR   NZ,L4C26                           ; Jump ahead if not.

; Rex is not in line with the player west-east but is in line with the player north-south.

        LD   A,C                                ; Fetch the west-east delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).

        CP   $07                                ; Is Rex close enough to be within visible range?
        JR   NC,L4C26                           ; Jump ahead if not.

; Rex is close enough west-east to be within visible range.

        PUSH BC                                 ; Save the north-south and west-east deltas.
        CALL L4C57                              ; Determine whether Rex is in line of sight with the player. A return is only made if he is, else execution continues at L4C26.
        POP  BC                                 ; Retrieve the north-south and west-east deltas.

; Rex is in line of sight of the player.

        LD   A,C                                ; Fetch the west-east delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).

        CP   $03                                ; Is Rex close to the player?
        JR   NC,L4C51                           ; Jump if not.

; Rex is close to the player.

        LD   A,(L4084)                          ; Fetch the direction the player is facing ($00=North, $01=West, $02=South, $03=East).
        BIT  0,A                                ; Is the player facing north or south?
        JR   Z,L4C20                            ; Jump if so, i.e. Rex is beside the player.

; Rex is behind the player.

        LD   DE,L4558-L4542                     ; Offset for status message " run HE IS BEHIND YOU ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is beside the player.

L4C20:  LD   DE,L456E-L4542                     ; Offset for status message " run HE IS BESIDE YOU ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is in line with the player north-south or west-east but is not within visible range, or
; Rex is not in line with the player north-south and not in line with the player west-east, or
; Rex is in line with the player but there is a wall in between Rex and the player.

L4C26:  LD   A,B                                ; Fetch the north-south delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).
        LD   B,A                                ; Store the absolute north-south delta in B.

        LD   A,C                                ; Fetch the west-east delta.
        CALL L4BA8                              ; Convert to an absolute delta, i.e. A=ABS(A).

        ADD  A,B                                ; Determine the total distance from the player.

        CP   $09                                ; Is Rex close enough to be heard approaching?
        JR   C,L4C45                            ; Jump if so.

; Rex is not close enough to be heard approaching.

        LD   A,(L408B)                          ; Is it time to clear the status message area?
        CP   $00
        JR   Z,L4C4B                            ; Jump ahead if so to clear the status message area.

; A message is being displayed so decrement the display timeout.

        DEC  A                                  ; Decrement the timeout value.
        LD   (L408B),A                          ; Store the new value.

        LD   DE,L45B0-L4542                     ; Offset for status message " HE IS HUNTING FOR YOU".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is close enough to be heard but is not within line of sight.

L4C45:  LD   DE,L459A-L4542                     ; Offset for status message " FOOTSTEPS APPROACHING".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Clear status message.

L4C4B:  LD   DE,L45C6-L4542                     ; Offset for status message "                      ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; Rex is in line of sight but not next to the player.

L4C51:  LD   DE,L4584-L4542                     ; Offset for status message "   REX HAS SEEN YOU   ".
        JP   L4CB0                              ; Jump ahead to display the status message and score.

; ---------------------------------------------------
; Check Whether Rex is in Line of Sight of the Player
; ---------------------------------------------------
; This subroutine only returns if Rex is in line of sight of the player, else it drops the return address
; and continues by jumping to L4C26.
; Entry: B=North-south delta between Rex and player (positive if player is to the south).
;        C=West-east delta between Rex and player (positive if player is to the east).

L4C57:  LD   A,B                                ; Fetch the north-south delta.
        CP   $00                                ; Is Rex in line with the player?
        JR   Z,L4C6E                            ; Jump ahead if so.

; Rex is not in line with the player north-south.

        CALL L4BA8                              ; Convert to an absolute north-south delta, i.e. A=ABS(A).
        BIT  7,B                                ; Is the player to the south of Rex?
        LD   B,A                                ; Transfer the absolute north-south delta to B.
        JR   Z,L4C69                            ; Jump ahead if the player is to the south of Rex.

; The player is to the north of Rex.

        LD   DE,$0010                           ; Movement offset to the south. A check for Rex will be made to the south.
        JR   L4C7F

; The player is to the south of Rex.

L4C69:  LD   DE,$FFF0                           ; Movement offset to the north. A check for Rex will be made to the north.
        JR   L4C7F

; Rex is in line with the player north-south.

L4C6E:  LD   A,C                                ; Fetch the west-east delta.
        CALL L4BA8                              ; Convert to an absolute west-east delta, i.e. A=ABS(A).
        BIT  7,C                                ; Is the player to the east of Rex?
        LD   B,A                                ; Transfer the absolute west-east delta to B.
        JR   Z,L4C7C                            ; Jump ahead if the player is to the east of Rex.

; The player is to the west of Rex.

        LD   DE,$0001                           ; Movement offset to the east. A check for Rex will be made to the east.
        JR   L4C7F

; The player is to the east of Rex.

L4C7C:  LD   DE,$FFFF                           ; Movement offset to the west. A check for Rex will be made to the west.

; B holds axis delta.
; DE holds offset.

; Search along the length of the delta checking whether there is a wall in between the player and Rex.

L4C7F:  LD   HL,(L4082)                         ; Fetch the location of the player.

L4C82:  ADD  HL,DE                              ; Add the check direction offset.

        BIT  7,(HL)                             ; Has a wall be reached?
        JR   NZ,L4C8A                           ; Jump ahead if so.

        DJNZ L4C82                              ; Repeat for the length of the delta distance.

; Rex is in line of sight with the player.

        RET

L4C8A:  POP  DE                                 ; Discard the return address.
        POP  BC                                 ; Retrieve stacked delta values.
        JP   L4C26                              ; Return to the logic branch that handles the condition when Rex is not able to see the player.

; ----------------------
; Display Status Message
; ----------------------
; Both "HE IS HUNTING YOU" and "REX LIES IN WAIT" display for a fixed length of time before being automatically cleared. A timeout value
; is used to control when the message is cleared from the screen.
; Entry: DE=Offset to the required status message.

L4C8F:  LD   A,E
        CP   (L45B0-L4542) & $FF                ; Is the message "HE IS HUNTING YOU"?
        JR   Z,L4C9D                            ; Jump ahead if so.

        CP   (L4542-L4542) & $FF                ; Is the message "REX LIES IN WAIT"?
        JR   Z,L4C9D                            ; Jump ahead if so.

; The status message does not use a timeout.

        LD   A,$00                              ; Clear the status message timeout.
        LD   (L408B),A

; Continue below.

; -----------------------------------------
; Copy Status Message into the Display File
; -----------------------------------------
; Entry: DE=Offset to the required status message.

L4C9D:  LD   HL,L4542                           ; Address of the status message table.
        ADD  HL,DE                              ; Offset to the required message.
        EX   DE,HL                              ; Transfer the message address to DE.

        LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   BC,$02F9                           ; Offset to row 23 column 1.
        ADD  HL,BC
        EX   DE,HL                              ; DE=Display file address, HL=Message address.

        LD   BC,$0016                           ; The status message is 22 characters in length.
        LDIR                                    ; Copy the status message into the display file.
        RET

; --------------------------------
; Display Status Message and Score
; --------------------------------

L4CB0:  CALL L4C8F                              ; Insert the status message into the display file, setting the clear message timeout as appropriate.

L4CB3:  LD   HL,L4087                           ; Point at the flags byte.
        LD   A,$48                              ; The flags for the player moved forward and Rex moved.
        AND  (HL)                               ; Keep only these flags.
        CP   $48                                ; Did the player move forward and Rex also moved?
        RES  6,(HL)                             ; Clear the player moved forwards flag.
        JR   NZ,L4CC5                           ; Jump ahead if not.

; The player moved forwards and Rex also moved so increment the score by 5 points.

        LD   DE,L453E+$0003                     ; Point to the score increment of 5 for step avoiding capture.
        CALL L4D0D                              ; Add the increment to the score.

; Check whether Rex has caught the player.

L4CC5:  LD   HL,L4087                           ; Point at the flags byte.
        BIT  7,(HL)                             ; Has the player been caught?
        JR   Z,L4CD1                            ; Jump ahead if not.

; The player has been caught so display the final score.

        LD   DE,$018D                           ; Offset to row 12 column 0;
        JR   L4CEF                              ; Jump ahead to display the score.

; The player has not been caught.

L4CD1:  LD   HL,(L4082)                         ; Fetch the location of the player.
        LD   A,(HL)                             ; Fetch the contents of the location.
        CP   _ME                                ; Is the player at the Exit?
        JR   NZ,L4CE1                           ; Jump ahead if not.

; The player is at the Exit.

        LD   DE,L453A+$0003                     ; Point to the score increment of 200 for exiting the maze.
        CALL L4D0D                              ; Add the increment to the score.

        JR   L4D28                              ; Jump ahead to display the escaped message text.

; The player is not at the Exit.

L4CE1:  LD   A,(L408D)                          ; Fetch the frame display index for Rex.
        JP   L4D58                              ; Jump ahead to continue, returning to LC4CE7 if Rex is not immediately next to the player.

; Rex is not immediately next to the player.
; DE=Points at the blank status message.

L4CE7:  CP   $06                                ; Is Rex within visible range?
        CALL C,L4C9D                            ; If so then clear the status message area.

; -----------------
; Display the Score
; -----------------

L4CEC:  LD   DE,$0166                           ; Offset to row 10 column 27.

L4CEF:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        ADD  HL,DE                              ; Point at row 10 column 27.
        EX   DE,HL                              ; Transfer the display file location to DE.

        LD   HL,L4536                           ; Point to the digits of the score.
        LD   B,$04                              ; There are 4 digits.

L4CF9:  LD   A,(HL)                             ; Fetch a digit of the score.
        CP   _0                                 ; Is it 0?
        JR   NZ,L4D06                           ; Jump ahead if not to display it.

; The digit is a leading zero so replace with a space.

        LD   A,_SPACE
        LD   (DE),A                             ; Insert a space into the display file.
        INC  HL                                 ; Advance to the next score digit.
        INC  DE                                 ; Advance to the next display file location.
        DJNZ L4CF9                              ; Loop back to consider the next digit of the score.

        RET

L4D06:  LD   A,(HL)                             ; Copy the digit of the score into the display file.
        LD   (DE),A
        INC  HL                                 ; Advance to the next score digit.
        INC  DE                                 ; Advance to the next display file location.
        DJNZ L4D06                              ; Copy of digits of the score.

        RET

; ------------------
; Increase the Score
; ------------------
; Entry: DE=The amount to add to the score.

L4D0D:  LD   HL,L4536+$0003                     ; Point to the least significant digit of the score.
        LD   B,$04                              ; There are four digits forming the score.
        AND  A                                  ; Clear the carry flag.

; Enter a loop to add each digit of the score increment to the digits of the score.

L4D13:  LD   A,(DE)                             ; Fetch a digit of the score increment.
        ADC  A,(HL)                             ; Add it to the corresponding digit of the score.
        DEC  DE                                 ; Point at the next significant digit of the score increment.
        CP   _A                                 ; Has the score digit overflowed?
        JR   C,L4D22                            ; Jump ahead if not.

; The score digit has overflowed and so the next significant digit must be incremented.

        SUB  $0A                                ; Remove the overflow.
        LD   (HL),A                             ; Store the new value for the digit.

        DEC  HL                                 ; Point to the next significant digit of the score.
        SCF                                     ; Signal that an overflow occurred.
        DJNZ L4D13                              ; Loop back to process the next digit of the score.

        RET

; The addition did not cause an overflow of the current score digit.

L4D22:  LD   (HL),A                             ; Store the new value for the digit.
        DEC  HL                                 ; Point to the next significant digit of the score.
        AND  A                                  ; Signal that an overflow did not occur.
        DJNZ L4D13                              ; Loop back to process the next digit of the score.

        RET

; -------------------
; Display Escape Text
; -------------------

L4D28:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$003C                           ; Offset to row 1 column 26.
        ADD  HL,DE

        LD   DE,L4DAA                           ; Point at the successful escape message text.
        EX   DE,HL                              ; DE=Display file address, HL=Message text address.

        LD   B,$13                              ; There are 19 rows of text.

L4D35:  PUSH BC                                 ; Save the row counter.

        LD   BC,$0006                           ; There are 6 columns of text.
        LDIR                                    ; Insert a row of the escape message text into the display file.

        LD   BC,$001B                           ; The offset to the next row.
        EX   DE,HL
        ADD  HL,BC                              ; Advance to the next row.
        EX   DE,HL                              ; DE=Display file address, HL=Message text address.

        POP  BC                                 ; Retrieve the row counter.
        DJNZ L4D35                              ; Repeat for all rows.

        LD   DE,$0103                           ; Offset to row 7 column 27.
        CALL L4CEF                              ; Display the score.

        LD   DE,$0084                           ; Offset to the status message text "                      ".
        JP   L4C9D                              ; Jump to blank out the status message.

; --------
; Not Used
; --------

LD450:  DEFB $00, $00, $00, $00, $00, $00, $00, $00

; ----------------------------------------
; Display Status Message and Score (Patch)
; ----------------------------------------
; This patch is jumped to when the player has not been caught and is not at the Exit.
; A=Frame display index for Rex.

L4D58:  CP   $00                                ; Is Rex next to the player?
        JP   Z,L4CEC                            ; Jump if so to display the score and then make a return.

        LD   DE,L45C6-L4542                     ; Offset to the status message text "                      ".
        JP   L4CE7                              ; Jump to clear the status message area if Rex is within visible range, then display the score and make a return.

; --------
; Not Used
; --------

L4D63:  DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00

; -------------------------------------
; Animate Exit Pattern and Draw 3D View
; -------------------------------------

L4D6C:  LD   A,(L408D)                          ; Fetch the frame display index for Rex, i.e. the distance from the player.
        CP   $00                                ; Has Rex caught the player?
        JP   Z,L4770                            ; Jump if so to attempt to move Rex and draw the 3D view.

        BIT  4,(HL)                             ; Is the Exit visible?
        CALL NZ,L4B2F                           ; If so then draw the Exit pattern, causing it to be drawn twice as fast as the player can move.

        JP   L4770                              ; Jump to attempt to move Rex and draw the 3D view.

; ------------------------------------------------------
; Program Protection Check and Fetch Offset to the North
; ------------------------------------------------------
; This routine verifies that the display file is at the expected memory location and has not been modified.
; It does this by testing whether the last 'n' of 'new generation software' in the copyright notice is present
; at the correct location within the display file.
; Entry: HL=Location of the Exit.
; Exit : DE=Offset to the north.
;        HL=Location of the Exit.

L4D7C:  PUSH HL                                 ; Save the location of the Exit.

        LD   HL,L6627                           ; Hard-coded address of the display file.
        LD   DE,$02E8                           ; Offset to row 22 column 17.
        ADD  HL,DE

        LD   A,(HL)                             ; Fetch the contents of the display file location.

#ifdef JK_GREYE
        CP   _INVG                              ; Is it the 'g' from 'produced by j.k.greye software'?
#else
        CP   _INVN                              ; Is it the last 'n' from 'new generation software'?
#endif

L4D87:  JR   NZ,L4D87                           ; Enter an infinite loop if it is not.

        LD   DE,$FFF0                           ; Offset of -16, used to check the position to the north when inserting the Exit into the maze.
        POP  HL                                 ; Retrieve the location of the Exit.
        RET

; --------
; Not Used
; --------

L4D8E:  DEFB $00, $00, $00, $00

; -------------------------
; Insert Passageway for Rex
; -------------------------
; Attempt to insert a passageway from the location containing Rex to the east for 10 tiles.
; This presumably aims to ensure that Rex is not in an isolated section of the maze.

L4D92:  LD   (L4082),HL                         ; Store as the passageway insertion position.

        LD   HL,L4084
        LD   (HL),$0A                           ; Set a passageway length of 10.
        INC  HL
        LD   (HL),$03                           ; Set the passageway direction to the east.

        JP   L4435                              ; Attempt to insert the passageway.

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L4DA0:  DEFB $00, $00, $00, $00, $00

        DEFB $00, $0A
        DEFW $0085
        DEFB _REM

; ------------------------------
; Successful Escape Message Text
; ------------------------------

L4DAA:  DEFB _SPACE, _Y, _O, _U, _SPACE, _SPACE                         ; " YOU  "
        DEFB _SPACE, _H, _A, _V, _E, _SPACE                             ; " HAVE "
        DEFB _E, _L, _U, _D, _E, _D                                     ; "ELUDED"
        DEFB _SPACE, _H, _I, _M, _SPACE, _SPACE                         ; " HIM  "
        DEFB _SPACE, _A, _N, _D, _SPACE, _SPACE                         ; " AND  "
        DEFB _S, _C, _O, _R, _E, _D                                     ; "SCORED"
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE             ; "      "
        DEFB _P, _O, _I, _N, _T, _S                                     ; "POINTS"
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE             ; "      "
        DEFB _R, _E, _X, _SPACE, _I, _S                                 ; "REX IS"
        DEFB _SPACE, _V, _E, _R, _Y, _SPACE                             ; " VERY "
        DEFB _A, _N, _G, _R, _Y, _FULLSTOP                              ; "ANGRY "
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE             ; "      "
        DEFB _Y, _O, _U, _COMMA, _L, _L                                 ; "YOU,LL"
        DEFB _SPACE, _N, _E, _E, _D, _SPACE                             ; " NEED "
        DEFB _SPACE, _M, _O, _R, _E, _SPACE                             ; " MORE "
        DEFB _SPACE, _L, _U, _C, _K, _SPACE                             ; " LUCK "
        DEFB _SPACE, _T, _H, _I, _S, _SPACE                             ; " THIS "
        DEFB _SPACE, _T, _I, _M, _E, _FULLSTOP                          ; " TIME."

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L4E1C:  DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

L4E2E:  DEFB $00, $0C
        DEFW $0291
        DEFB _REM

; ---------------------
; Rex Mouth Open Screen
; ---------------------
; The format is:
; - The high byte of an offset into the display file from the current location.
; - An entry per row of the sprite:
;   - The low byte of an offset into the display file from the current location (high byte will be $00 on the second and subsequent rows). A value of $00 denotes the end of sprite, hence an offset into the display file is always at least $01.
;   - The number of characters in the row.
;   - The characters for the row.

; Distance 0 right step.

L4E33:  DEFB $00
        DEFB $01, $19, _BLACK, _BLACK, _TOPBLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _RIGHTBLACK, _BLACK, _BLACK
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _TOPRIGHTWHITE, _BLACK, _BLACK
        DEFB $08, $19, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _TOPLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _TOPLEFTBLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACK, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _TOPBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMBLACK, _BOTTOMBLACK, _BOTTOMBLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _TOPRIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _BOTTOMBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _BOTTOMRIGHTWHITE, _BOTTOMLEFTWHITE, _BLACK, _TOPBLACK, _SPACE, _SPACE, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _LEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMLEFTWHITE, _BOTTOMLEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK , _BLACK, _BOTTOMLEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _RIGHTBLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _TOPBLACK
        DEFB $08, $19, _LEFTBLACK, _SPACE, _LEFTBLACK, _TOPRIGHTBLACK, _LEFTBLACK, _SPACE, _LEFTBLACK, _TOPRIGHTBLACK, _LEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _BOTTOMLEFTWHITE, _LEFTBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK , _SPACE, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _RIGHTBLACK, _LEFTBLACK, _SPACE
        DEFB $08, $19, _TOPRIGHTWHITE, _RIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _TOPRIGHTBLACK, _BLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _RIGHTBLACK, _LEFTBLACK, _SPACE
        DEFB $08, $19, _BOTTOMLEFTWHITE, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _TOPBLACK, _TOPBLACK, _SPACE, _SPACE, _SPACE, _BLACK, _BOTTOMRIGHTBLACK
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _SPACE, _TOPLEFTWHITE, _TOPRIGHTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _BOTTOMLEFTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _TOPLEFTBLACK , _SPACE, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _LEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _BOTTOMRIGHTBLACK, _BLACK, _TOPBLACK, _TOPLEFTBLACK , _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _BOTTOMBLACK, _SPACE, _TOPRIGHTWHITE, _BLACK, _TOPLEFTBLACK , _SPACE, _SPACE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPBLACK, _BOTTOMLEFTBLACK, _SPACE, _RIGHTBLACK, _BOTTOMRIGHTWHITE, _TOPLEFTBOTTOMRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBOTTOMRIGHT, _SPACE, _SPACE, _BOTTOMLEFTBLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _TOPLEFTWHITE, _TOPLEFTBLACK , _SPACE, _RIGHTBLACK, _SPACE, _BLACK, _SPACE, _TOPRIGHTBLACK, _BOTTOMLEFTBLACK, _TOPLEFTWHITE, _TOPLEFTBLACK , _SPACE, _TOPLEFTBOTTOMRIGHT, _RIGHTBLACK, _LEFTBLACK
        DEFB $00

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L50BD:  DEFB $00, $00, $00, $00, $00, $00

L50C3:  DEFB $00, $0E
        DEFW $029E
        DEFB _REM

; -------------------------------------------
; "You Have Been Posthumously Awarded" Screen
; -------------------------------------------
; Display Rex's teeth and the following text in between them:
;
; "YOU HAVE BEEN"
; "POSTHUMOUSLY AWARDED"
; "     POINTS AND SENTENCED"
; "TO ROAM THE MAZE FOREVER."
; "    IF YOU WISH TO APPEAL"
; "        PRESS stop, ELSE"
; "             PRESS cont."
;
; There are 24 rows of 25 characters. Rows 9 and 10 consist of 32 characters to erase the score.
;
; The format is:
; - The high byte of an offset into the display file from the current location.
; - An entry per row of the sprite:
;   - The low byte of an offset into the display file from the current location (high byte will be $00 on the second and subsequent rows). A value of $00 denotes the end of sprite, hence an offset into the display file is always at least $01.
;   - The number of characters in the row.
;   - The characters for the row.

; Distance 0 left step.

L50C8:  DEFB $00
        DEFB $01, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _TOPBLACK, _SPACE, _RIGHTBLACK, _BLACK, _LEFTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _TOPLEFTBLACK, _BLACK, _BLACK, _SPACE, _TOPRIGHTBLACK, _TOPBLACK, _BOTTOMRIGHTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _LEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BLACK, _BLACK, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _RIGHTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _SPACE, _BLACK, _BLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPBLACK, _BLACK, _BLACK, _BLACK
        DEFB $08, $19, _TOPRIGHTBLACK, _LEFTBLACK, _RIGHTBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _TOPBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _TOPRIGHTBLACK, _BOTTOMBLACK, _BOTTOMBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _BLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _LEFTBLACK, _SPACE, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB $08, $19, _SPACE, _TOPBLACK, _TOPLEFTWHITE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _BLACK, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _SPACE, _SPACE, _BLACK, _TOPBLACK, _SPACE
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _BOTTOMBLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _SPACE, _SPACE
        DEFB $08, $19, _Y, _O, _U, _SPACE, _H, _A, _V, _E, _SPACE, _B, _E, _E, _N, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK, _LEFTBLACK, _SPACE, _BOTTOMBLACK
        DEFB $08, $20, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK, _BOTTOMBLACK, _TOPBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $01, $20, _P, _O, _S, _T, _H, _U, _M, _O, _U, _S, _L, _Y, _SPACE, _A, _W, _A, _R, _D, _E, _D, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $01, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _P, _O, _I, _N, _T, _S, _SPACE, _A, _N, _D, _SPACE, _S, _E, _N, _T, _E, _N, _C, _E, _D
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _T, _O, _SPACE, _R, _O, _A, _M, _SPACE, _T, _H, _E, _SPACE, _M, _A, _Z, _E, _SPACE, _F, _O, _R, _E, _V, _E, _R, _FULLSTOP
        DEFB $08, $19, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _I, _F, _SPACE, _Y, _O, _U, _SPACE, _W, _I, _S, _H, _SPACE, _T, _O, _SPACE, _A, _P, _P, _E, _A, _L
        DEFB $08, $19, _TOPBLACK, _SPACE, _BLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _SPACE, _SPACE, _BOTTOMRIGHTWHITE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BOTTOMLEFTWHITE, _SPACE, _P, _R, _E, _S, _S, _SPACE, _INVS, _INVT, _INVO, _INVP, _COMMA, _SPACE, _E, _L, _S, _E, _SPACE
        DEFB $08, $19, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _TOPRIGHTWHITE, _BOTTOMLEFTTOPRIGHT, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _SPACE, _RIGHTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMBLACK, _BOTTOMLEFTBLACK, _SPACE, _P, _R, _E, _S, _S, _SPACE, _INVC, _INVO, _INVN, _INVT, _FULLSTOP, _SPACE
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _SPACE, _SPACE, _BOTTOMBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _TOPRIGHTWHITE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BOTTOMRIGHTBLACK, _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMLEFTTOPRIGHT, _SPACE, _TOPLEFTWHITE, _LEFTBLACK, _TOPLEFTBOTTOMRIGHT, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE
        DEFB $08, $19, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BOTTOMBLACK, _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _TOPLEFTWHITE, _BOTTOMRIGHTWHITE, _SPACE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTWHITE, _RIGHTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _TOPBLACK, _BOTTOMLEFTBLACK, _SPACE, _SPACE
        DEFB $00

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L5360:  DEFB $00, $00, $00, $00, $00

        DEFB $00, $10
        DEFW $01AB
        DEFB _REM

; ---------------------------
; Ringmaster Standing Graphic
; ---------------------------

L536A:  DEFB _BLACK, _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _LEFTBLACK, _SPACE, _RIGHTBLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BOTTOMBLACK, _MINUS, _MINUS, _MINUS, _BOTTOMBLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _PLUS, _O, _PLUS, _BLACK, _TOPCHEQUERBOTTOMBLACK, _SPACE, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BOTTOMLEFTBLACK, _EQUALS, _BOTTOMRIGHTBLACK, _BLACK, _BOTTOMRIGHTWHITE, _SPACE, _BLACK
        DEFB _BLACK, _BLACK, _BOTTOMRIGHTWHITE, _TOPRIGHTBLACK, _BOTTOMBLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _LEFTBLACK, _SPACE, _BOTTOMLEFTWHITE
        DEFB _BLACK, _TOPLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _I, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTBLACK, _SPACE, _SPACE, _SPACE, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _I, _SPACE, _SPACE, _BLACK, _SPACE, _BOTTOMRIGHTBLACK, _SPACE, _SPACE, _RIGHTBLACK
        DEFB _LEFTBLACK, _I, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _LEFTBLACK, _SPACE, _TOPLEFTBOTTOMRIGHT, _BOTTOMBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _SPACE, _BOTTOMLEFTTOPRIGHT, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _SPACE, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _LEFTBLACK, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _ASTERISK, _ASTERISK, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _LEFTBLACK, _I, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _TOPRIGHTWHITE, _PLUS, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _ASTERISK, _RIGHTBLACK, _BLACK, _BLACK
        DEFB _BLACK, _BOTTOMLEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _I, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _TOPRIGHTWHITE, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _LEFTBLACK, _ASTERISK, _ASTERISK, _BLACK, _ASTERISK, _ASTERISK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _ASTERISK, _BOTTOMRIGHTBLACK, _BLACK, _ASTERISK, _BOTTOMRIGHTBLACK, _BLACK, _BLACK, _BLACK
        DEFB _TOPBLACK, _TOPBLACK, _TOPLEFTBLACK, _TOPRIGHTBLACK, _TOPBLACK, _SPACE, _TOPBLACK, _TOPBLACK, _TOPBLACK, _TOPBLACK
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; ------------------------------------------------------------
; "produced by j.k.greye software" / "new generation software"
; ------------------------------------------------------------

#ifdef JK_GREYE

L5446:  DEFB _BLACK, _INVP, _INVR, _INVO, _INVD, _INVU, _INVC, _INVE, _INVD, _BLACK, _INVB, _INVY
        DEFB _BLACK, _INVJ, _INVFULLSTOP, _INVK, _INVFULLSTOP, _INVG, _INVR, _INVE, _INVY, _INVE
        DEFB _BLACK, _INVS, _INVO, _INVF, _INVT, _INVW, _INVA, _INVR, _INVE, _BLACK

#else

L5446:  DEFB _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _INVN, _INVE, _INVW
        DEFB _BLACK
        DEFB _INVG, _INVE, _INVN, _INVE, _INVR, _INVA, _INVT, _INVI, _INVO, _INVN
        DEFB _BLACK
        DEFB _INVS, _INVO, _INVF, _INVT, _INVW, _INVA, _INVR, _INVE
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK

#endif

; ----------------
; Copyright Notice
; ----------------

L5466:  DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _INVC, _INVO, _INVP, _INVY, _INVR, _INVI, _INVG, _INVH, _INVT
        DEFB _BLACK, _BLACK,
L5477:  DEFB _INVM, _INVFULLSTOP, _INVE, _INVFULLSTOP
L547B:  DEFB _INVE, _INVV, _INVA, _INVN, _INVS
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK

; --------
; Not Used
; --------

L5486:  DEFB $00, $00, $00, $00, $00, $00

; -------------------------
; Ringmaster Bowing Graphic
; -------------------------

L548C:  DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _BLACK, _TOPBLACKBOTTOMCHEQUER, _BLACK, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _BLACK, _BLACK, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _INVCHEQUERBOARD, _BLACK, _BLACK, _BLACK, _BLACK
        DEFB _BLACK, _TOPLEFTBLACK, _SPACE, _BOTTOMLEFTWHITE, _TOPCHEQUERBOTTOMBLACK, _BOTTOMRIGHTWHITE, _TOPRIGHTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _SPACE, _SPACE, _SPACE, _O, _SPACE, _SPACE, _SPACE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _SPACE, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _TOPBLACK, _BOTTOMBLACK, _BOTTOMRIGHTBLACK, _SPACE, _RIGHTBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _LEFTBLACK, _SPACE, _SPACE, _SPACE, _BOTTOMLEFTWHITE, _SPACE, _RIGHTBLACK, _BLACK
        DEFB _LEFTBLACK, _I, _LEFTBLACK, _SPACE, _SPACE, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _SPACE, _TOPLEFTWHITE, _BLACK
        DEFB _LEFTBLACK, _BOTTOMRIGHTBLACK, _BOTTOMLEFTTOPRIGHT, _BOTTOMBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTBLACK, _BOTTOMRIGHTBLACK, _TOPLEFTWHITE, _BLACK, _BLACK
        DEFB _LEFTBLACK, _I, _ASTERISK, _ASTERISK, _TOPLEFTBOTTOMRIGHT, _BOTTOMBLACK, _TOPLEFTBLACK, _BOTTOMLEFTWHITE, _BLACK, _BLACK
        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _CLOSEBRACKET, _RIGHTBLACK, _SPACE

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L5518:  DEFB _REM

; -----------------------------------
; Insert Ringmaster into Display File
; -----------------------------------
; Entry: B=Number of rows to insert.

L5519:  LD   DE,(D_FILE)                        ; Fetch the location of the display file.
        INC  DE                                 ; Advance past the initial newline character.

L551E:  PUSH BC                                 ; Save the row counter.

        PUSH DE                                 ; Save the display file location.
        LD   BC,$000A                           ; Copy 10 characters of the Ringmaster into the current row.
        LDIR
        POP  DE                                 ; Retrieve the display file location.

        PUSH HL                                 ; Save the pointer into the Ringmaster graphic.
        LD   HL,$0021
        ADD  HL,DE                              ; Advance to the next row of the display file.
        EX   DE,HL
        POP  HL                                 ; Retrieve the pointer to the Ringmaster graphic.

        POP  BC                                 ; Retrieve the row counter.
        DJNZ L551E                              ; Repeat for all rows.

        RET

; ---------------------------------------
; Display Ringmaster and Copyright Notice
; ---------------------------------------

L5531:  LD   HL,L536A                           ; Point to the graphic for the standing Ringmaster.
        LD   B,$16                              ; The Ringmaster is composed of 22 rows.
        CALL L5519                              ; Insert the Ringmaster into the display file.

        LD   BC,$0020                           ; Display at 22,0;"####new generation software#####" (or "#produced by j.k.greye software#" for the J. K. Greye Software release version).
        LDIR
        INC  DE

        LD   BC,$0020                           ; Display at 23,0;"######copyright  m.e.evans######".
        LDIR
        RET

; -------------------------
; Display Ringmaster Bowing
; -------------------------

L5545:  LD   HL,L548C                           ; Point to the graphic for the bowing Ringmaster.
        LD   B,$0D                              ; Only the top 13 rows of the Ringmaster are changed.
        JR   L5519                              ; Insert the Ringmaster into the display file.

; ------------------------------------------
; Scroll New Instruction Text Line up Screen
; ------------------------------------------

L554C:  LD   HL,(D_FILE)                        ; Fetch the location of the display file.
        LD   DE,$000B                           ; Offset to row 0 column 10.
        ADD  HL,DE

; Scroll up one row.

        LD   B,$14                              ; The are 20 characters per instruction row.

L5555:  PUSH BC                                 ; Save the character count.

        PUSH HL
        POP  DE                                 ; DE=Display file location within the current row.
        LD   BC,$0021
        ADD  HL,BC                              ; HL=Display file location within the next row.
        PUSH HL
        LD   BC,$0016                           ; Copy 22 characters up to the row above.
        LDIR
        POP  HL                                 ; HL=Start of the row just copied from.

        POP  BC                                 ; Retrieve the character count.
        DJNZ L5555                              ; Repeat for all characters of the row.

; Display next row of instructions.

        EX   DE,HL                              ; DE=Address of the display file row to insert the new message at.

        LD   HL,L4082                           ; Point to the instruction line counter.
        INC  (HL)                               ; Increment the counter.
        BIT  0,(HL)                             ; Odd or even line, i.e. display instruction line or blank line?
        JR   NZ,L5574                           ; Jump to display blank instruction line.

        LD   HL,L45C6                           ; Point to the blank message.
        JR   L5581                              ; Jump ahead to display it.

L5574:  LD   BC,(L4083)                         ; Fetch the instruction line text pointer.
        LD   HL,$0016
        ADD  HL,BC                              ; Offset to the next instruction line text.
        LD   (L4083),HL                         ; Save the address of the line for use next time.

        PUSH BC
        POP  HL                                 ; Transfer the address of the instruction line text to HL.

; Copy the instruction line into the display file.

L5581:  LD   BC,$0016                           ; There are 22 characters in the new instruction line.
        LDIR                                    ; Copy the instruction line into the display file.
        RET

; -----------------------------------
; Not Used - Remains of REM Statement
; -----------------------------------

L5587:  DEFB $83, $40, $C9, $1B, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00

        DEFB $00, $12
        DEFW $060A
        DEFB _REM

; --------------------------
; Introduction Text Messages
; --------------------------

L55A2:

; "   ROLL UP,ROLL UP,   "

        DEFB _SPACE, _SPACE, _SPACE, _R, _O, _L, _L, _SPACE, _U, _P, _COMMA, _R, _O, _L, _L, _SPACE, _U, _P, _COMMA, _SPACE, _SPACE, _SPACE

; " SEE THE AMAZING      "

        DEFB _SPACE, _S, _E, _E, _SPACE, _T, _H, _E, _SPACE, _A, _M, _A, _Z, _I, _N, _G, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " TYRANNOSAURUS REX    "

        DEFB _SPACE, _T, _Y, _R, _A, _N, _N, _O, _S, _A, _U, _R, _U, _S, _SPACE, _R, _E, _X, _SPACE, _SPACE, _SPACE, _SPACE

; " KING OF THE DINOSAURS"

        DEFB _SPACE, _K, _I, _N, _G, _SPACE, _O, _F, _SPACE, _T, _H, _E, _SPACE, _D, _I, _N, _O, _S, _A, _U, _R, _S

; " IN HIS LAIR.         "

        DEFB _SPACE, _I, _N, _SPACE, _H, _I, _S, _SPACE, _L, _A, _I, _R, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " PERFECTLY PRESERVED  "

        DEFB _SPACE, _P, _E, _R, _F, _E, _C, _T, _L, _Y, _SPACE, _P, _R, _E, _S, _E, _R, _V, _E, _D, _SPACE, _SPACE

; " IN SILICON SINCE     "

        DEFB _SPACE, _I, _N, _SPACE, _S, _I, _L, _I, _C, _O, _N, _SPACE, _S, _I, _N, _C, _E, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " PREHISTORIC TIMES,HE "

        DEFB _SPACE, _P, _R, _E, _H, _I, _S, _T, _O, _R, _I, _C, _SPACE, _T, _I, _M, _E, _S, _COMMA, _H, _E, _SPACE

; " IS BROUGHT TO YOU FOR"

        DEFB _SPACE, _I, _S, _SPACE, _B, _R, _O, _U, _G, _H, _T, _SPACE, _T, _O, _SPACE, _Y, _O, _U, _SPACE, _F, _O, _R

; " YOUR ENTERTAINMENT   "

        DEFB _SPACE, _Y, _O, _U, _R, _SPACE, _E, _N, _T, _E, _R, _T, _A, _I, _N, _M, _E, _N, _T, _SPACE, _SPACE, _SPACE

; " AND EXHILARATION.    "

        DEFB _SPACE, _A, _N, _D, _SPACE, _E, _X, _H, _I, _L, _A, _R, _A, _T, _I, _O, _N, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE

; "   IF YOU DARE TO     "

        DEFB _SPACE, _SPACE, _SPACE, _I, _F, _SPACE, _Y, _O, _U, _SPACE, _D, _A, _R, _E, _SPACE, _T, _O, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " ENTER HIS LAIR,YOU DO"

        DEFB _SPACE, _E, _N, _T, _E, _R, _SPACE, _H, _I, _S, _SPACE, _L, _A, _I, _R, _COMMA, _Y, _O, _U, _SPACE, _D, _O

; " SO AT YOUR OWN RISK. "

        DEFB _SPACE, _S, _O, _SPACE, _A, _T, _SPACE, _Y, _O, _U, _R, _SPACE, _O, _W, _N, _SPACE, _R, _I, _S, _K, _FULLSTOP, _SPACE

; " THE MANAGEMENT ACCEPT"

        DEFB _SPACE, _T, _H, _E, _SPACE, _M, _A, _N, _A, _G, _E, _M, _E, _N, _T, _SPACE, _A, _C, _C, _E, _P, _T

; " NO RESPONSIBILITY FOR"

        DEFB _SPACE, _N, _O, _SPACE, _R, _E, _S, _P, _O, _N, _S, _I, _B, _I, _L, _I, _T, _Y, _SPACE, _F, _O, _R

; " THE HEALTH AND SAFETY"

        DEFB _SPACE, _T, _H, _E, _SPACE, _H, _E, _A, _L, _T, _H, _SPACE, _A, _N, _D, _SPACE, _S, _A, _F, _E, _T, _Y

; " OF THE ADVENTURER WHO"

        DEFB _SPACE, _O, _F, _SPACE, _T, _H, _E, _SPACE, _A, _D, _V, _E, _N, _T, _U, _R, _E, _R, _SPACE, _W, _H, _O

; " ENTERS HIS REALM.THE "

        DEFB _SPACE, _E, _N, _T, _E, _R, _S, _SPACE, _H, _I, _S, _SPACE, _R, _E, _A, _L, _M, _FULLSTOP, _T, _H, _E, _SPACE

; " MANAGEMENT ADVISE    "

        DEFB _SPACE, _M, _A, _N, _A, _G, _E, _M, _E, _N, _T, _SPACE, _A, _D, _V, _I, _S, _E, _SPACE, _SPACE, _SPACE, _SPACE

; " THAT THIS IS NOT A   "

        DEFB _SPACE, _T, _H, _A, _T, _SPACE, _T, _H, _I, _S, _SPACE, _I, _S, _SPACE, _N, _O, _T, _SPACE, _A, _SPACE, _SPACE, _SPACE

; " GAME FOR THOSE OF A  "

        DEFB _SPACE, _G, _A, _M, _E, _SPACE, _F, _O, _R, _SPACE, _T, _H, _O, _S, _E, _SPACE, _O, _F, _SPACE, _A, _SPACE, _SPACE

; " NERVIOUS DISPOSITION."

        DEFB _SPACE, _N, _E, _R, _V, _O, _U, _S, _SPACE, _D, _I, _S, _P, _O, _S, _I, _T, _I, _O, _N, _FULLSTOP, _SPACE

; "   IF YOU ARE IN ANY  "

        DEFB _SPACE, _SPACE, _SPACE, _I, _F, _SPACE, _Y, _O, _U, _SPACE, _A, _R, _E, _SPACE, _I, _N, _SPACE, _A, _N, _Y, _SPACE, _SPACE

; " DOUBT,THEN PRESS stop"

        DEFB _SPACE, _D, _O, _U, _B, _T, _COMMA, _T, _H, _E, _N, _SPACE, _P, _R, _E, _S, _S, _SPACE, _INVS, _INVT, _INVO, _INVP

; " IF INSTRUCTIONS ARE  "

        DEFB _SPACE, _I, _F, _SPACE, _I, _N, _S, _T, _R, _U, _C, _T, _I, _O, _N, _S, _SPACE, _A, _R, _E, _SPACE, _SPACE

; " NEEDED TO PROCEEED,  "

        DEFB _SPACE, _N, _E, _E, _D, _E, _D, _SPACE, _T, _O, _SPACE, _P, _R, _O, _C, _E, _E, _D, _COMMA, _SPACE, _SPACE, _SPACE

; " THEN PRESS       list"

        DEFB _SPACE, _T, _H, _E, _N, _SPACE, _P, _R, _E, _S, _S, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _INVL, _INVI, _INVS, _INVT

; " OTHERWISE PRESS  cont"

        DEFB _SPACE, _O, _T, _H, _E, _R, _W, _I, _S, _E, _SPACE, _P, _R, _E, _S, _S, _SPACE, _SPACE, _INVC, _INVO, _INVN, _INVT

; ----------------------
; Controls Text Messages
; ----------------------

L5820:

; "   THE ONLY CONTROLS  "

        DEFB _SPACE, _SPACE, _SPACE, _T, _H, _E, _SPACE, _O, _N, _L, _Y, _SPACE, _C, _O, _N, _T, _R, _O, _L, _S, _SPACE, _SPACE

; " YOU REQUIRE ARE:-    "

        DEFB _SPACE, _Y, _O, _U, _SPACE, _R, _E, _Q, _U, _I, _R, _E, _SPACE, _A, _R, _E, _COLON, _MINUS, _SPACE, _SPACE, _SPACE, _SPACE

; "   5....TURN LEFT     "

        DEFB _SPACE, _SPACE, _SPACE, _5, _FULLSTOP, _FULLSTOP, _FULLSTOP, _FULLSTOP, _T, _U, _R, _N, _SPACE, _L, _E, _F, _T, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; "   7....MOVE FORWARD  "

        DEFB _SPACE, _SPACE, _SPACE, _7, _FULLSTOP, _FULLSTOP, _FULLSTOP, _FULLSTOP, _M, _O, _V, _E, _SPACE, _F, _O, _R, _W, _A, _R, _D, _SPACE, _SPACE

; "   8....TURN RIGHT    "

        DEFB _SPACE, _SPACE, _SPACE, _8, _FULLSTOP, _FULLSTOP, _FULLSTOP, _FULLSTOP, _T, _U, _R, _N, _SPACE, _R, _I, _G, _H, _T, _SPACE, _SPACE, _SPACE, _SPACE

; " FURTHER INFORMATION  "

        DEFB _SPACE, _F, _U, _R, _T, _H, _E, _R, _SPACE, _I, _N, _F, _O, _R, _M, _A, _T, _I, _O, _N, _SPACE, _SPACE

; " IS PROVIDED DURING   "

        DEFB _SPACE, _I, _S, _SPACE, _P, _R, _O, _V, _I, _D, _E, _D, _SPACE, _D, _U, _R, _I, _N, _G, _SPACE, _SPACE, _SPACE

; " THE ENCOUNTER.       "

        DEFB _SPACE, _T, _H, _E, _SPACE, _E, _N, _C, _O, _U, _N, _T, _E, _R, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; "   FOR EACH MOVE      "

        DEFB _SPACE, _SPACE, _SPACE, _F, _O, _R, _SPACE, _E, _A, _C, _H, _SPACE, _M, _O, _V, _E, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " SCORING IS AS FOLLOWS"

        DEFB _SPACE, _S, _C, _O, _R, _I, _N, _G, _SPACE, _I, _S, _SPACE, _A, _S, _SPACE, _F, _O, _L, _L, _O, _W, _S

; "   5 PTS-WHILE HE IS  "

        DEFB _SPACE, _SPACE, _SPACE, _5, _SPACE, _P, _T, _S, _MINUS, _W, _H, _I, _L, _E, _SPACE, _H, _E, _SPACE, _I, _S, _SPACE, _SPACE

; "         TRACKING YOU."

        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _T, _R, _A, _C, _K, _I, _N, _G, _SPACE, _Y, _O, _U, _FULLSTOP

; " 200 PTS-IF YOU ESCAPE"

        DEFB _SPACE, _2, _0, _0, _SPACE, _P, _T, _S, _MINUS, _I, _F, _SPACE, _Y, _O, _U, _SPACE, _E, _S, _C, _A, _P, _E

; "         HIS LAIR.    "

        DEFB _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _H, _I, _S, _SPACE, _L, _A, _I, _R, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE

; "   SINCE REX IS ALWAYS"

        DEFB _SPACE, _SPACE, _SPACE, _S, _I, _N, _C, _E, _SPACE, _R, _E, _X, _SPACE, _I, _S, _SPACE, _A, _L, _W, _A, _Y, _S

; " TRYING TO MOVE       "

        DEFB _SPACE, _T, _R, _Y, _I, _N, _G, _SPACE, _T, _O, _SPACE, _M, _O, _V, _E, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " TOWARDS HIS PREY,A   "

        DEFB _SPACE, _T, _O, _W, _A, _R, _D, _S, _SPACE, _H, _I, _S, _SPACE, _P, _R, _E, _Y, _COMMA, _A, _SPACE, _SPACE, _SPACE

; " SKILFUL ADVENTURER   "

        DEFB _SPACE, _S, _K, _I, _L, _F, _U, _L, _SPACE, _A, _D, _V, _E, _N, _T, _U, _R, _E, _R, _SPACE, _SPACE, _SPACE

; " CAN CONTROL THE      "

        DEFB _SPACE, _C, _A, _N, _SPACE, _C, _O, _N, _T, _R, _O, _L, _SPACE, _T, _H, _E, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " MONSTERS MOVEMENTS TO"

        DEFB _SPACE, _M, _O, _N, _S, _T, _E, _R, _S, _SPACE, _M, _O, _V, _E, _M, _E, _N, _T, _S, _SPACE, _T, _O

; " IMPROVE HIS SCORE.   "

        DEFB _SPACE, _I, _M, _P, _R, _O, _V, _E, _SPACE, _H, _I, _S, _SPACE, _S, _C, _O, _R, _E, _FULLSTOP, _SPACE, _SPACE, _SPACE

; " THE ESCAPE ROUTE,    "

        DEFB _SPACE, _T, _H, _E, _SPACE, _E, _S, _C, _A, _P, _E, _SPACE, _R, _O, _U, _T, _E, _COMMA, _SPACE, _SPACE, _SPACE, _SPACE

; " WHICH IS AT THE END  "

        DEFB _SPACE, _W, _H, _I, _C, _H, _SPACE, _I, _S, _SPACE, _A, _T, _SPACE, _T, _H, _E, _SPACE, _E, _N, _D, _SPACE, _SPACE

; " OF A CUL-DE-SAC,IS   "

        DEFB _SPACE, _O, _F, _SPACE, _A, _SPACE, _C, _U, _L, _MINUS, _D, _E, _MINUS, _S, _A, _C, _COMMA, _I, _S, _SPACE, _SPACE, _SPACE

; " VISIBLE UP TO 5 MOVES"

        DEFB _SPACE, _V, _I, _S, _I, _B, _L, _E, _SPACE, _U, _P, _SPACE, _T, _O, _SPACE, _5, _SPACE, _M, _O, _V, _E, _S

; " AWAY.                "

        DEFB _SPACE, _A, _W, _A, _Y, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; "   THE GAME ENDS WHEN "

        DEFB _SPACE, _SPACE, _SPACE, _T, _H, _E, _SPACE, _G, _A, _M, _E, _SPACE, _E, _N, _D, _S, _SPACE, _W, _H, _E, _N, _SPACE

; " HE CATCHES YOU.IF YOU"

        DEFB _SPACE, _H, _E, _SPACE, _C, _A, _T, _C, _H, _E, _S, _SPACE, _Y, _O, _U, _FULLSTOP, _I, _F, _SPACE, _Y, _O, _U

; " ESCAPE A NEW MAZE IS "

        DEFB _SPACE, _E, _S, _C, _A, _P, _E, _SPACE, _A, _SPACE, _N, _E, _W, _SPACE, _M, _A, _Z, _E, _SPACE, _I, _S, _SPACE

; " GENERATED AND YOUR   "

        DEFB _SPACE, _G, _E, _N, _E, _R, _A, _T, _E, _D, _SPACE, _A, _N, _D, _SPACE, _Y, _O, _U, _R, _SPACE, _SPACE, _SPACE

; " PREVIOUS SCORE       "

        DEFB _SPACE, _P, _R, _E, _V, _I, _O, _U, _S, _SPACE, _S, _C, _O, _R, _E, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; " CARRIED FORWARD.     "

        DEFB _SPACE, _C, _A, _R, _R, _I, _E, _D, _SPACE, _F, _O, _R, _W, _A, _R, _D, _FULLSTOP, _SPACE, _SPACE, _SPACE, _SPACE, _SPACE

; ----------------------------
; 'Mist of Time' Text Messages
; ----------------------------

L5AE0:

; "   THE MISTS OF TIME  "

        DEFB _SPACE, _SPACE, _SPACE, _T, _H, _E, _SPACE, _M, _I, _S, _T, _S, _SPACE, _O, _F, _SPACE, _T, _I, _M, _E, _SPACE, _SPACE

; " WILL PASS OVER YOU   "

        DEFB _SPACE, _W, _I, _L, _L, _SPACE, _P, _A, _S, _S, _SPACE, _O, _V, _E, _R, _SPACE, _Y, _O, _U, _SPACE, _SPACE, _SPACE

; " FOR ABOUT 30 SECONDS "

        DEFB _SPACE, _F, _O, _R, _SPACE, _A, _B, _O, _U, _T, _SPACE, _3, _0, _SPACE, _S, _E, _C, _O, _N, _D, _S, _SPACE

; " WHILE TRANSPORTING   "

        DEFB _SPACE, _W, _H, _I, _L, _E, _SPACE, _T, _R, _A, _N, _S, _P, _O, _R, _T, _I, _N, _G, _SPACE, _SPACE, _SPACE

; " YOU TO THE LAIR OF   "

        DEFB _SPACE, _Y, _O, _U, _SPACE, _T, _O, _SPACE, _T, _H, _E, _SPACE, _L, _A, _I, _R, _SPACE, _O, _F, _SPACE, _SPACE, _SPACE

; " TYRANNOSAURUS REX.   "

        DEFB _SPACE, _T, _Y, _R, _A, _N, _N, _O, _S, _A, _U, _R, _U, _S, _SPACE, _R, _E, _X, _FULLSTOP, _SPACE, _SPACE, _SPACE

; "   BEST OF LUCK.....  "

        DEFB _SPACE, _SPACE, _SPACE, _B, _E, _S, _T, _SPACE, _O, _F, _SPACE, _L, _U, _C, _K, _FULLSTOP, _FULLSTOP, _FULLSTOP, _FULLSTOP, _FULLSTOP, _SPACE, _SPACE

; --------
; Not Used
; --------

L5B7A:  DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

; ------------------------------------------------------------------------------------------------------------------------------------------------------

; -------------------
; End of BASIC Line 0
; -------------------

L5BAA:  DEFB _NEWLINE

; ======================================================================================================================================================

; =============
; BASIC Program
; =============

; -----------
; Entry Point
; -----------

; 95 RAND                                               ; Set the random number seed based on the FRAMES counter.
; 97 GOTO 1015                                          ; Jump to display the instructions.

; -----------------
; Generate the Maze
; -----------------

; 100 LET A=USR 17441                                   ; Fill the maze with all walls.
; 110 LET T=0                                           ; Initialise the count of the number of passageway insertions attempted into the maze.

; Enter a loop to insert passageways into the maze.

; 120 LET X=INT (RND*4)                                 ; Select a direction ($00=North, $01=West, $02=South, $03=East)
; 130 IF PEEK 16514<16 AND RND<.9 THEN LET X=2          ; If the current position is at the far north of the maze then head south.
; 140 POKE 16517,X                                      ; Store the passageway direction.

; 150 LET X=INT (RND*6)                                 ; Pick a length of passageway.
; 160 LET T=T+X                                         ; Add the length to the passageway counter.
; 170 POKE 16516,X                                      ; Store the passageway length.

; 180 LET A=USR 17461                                   ; Insert a passageway into the maze.
; 190 IF T<800 THEN GOTO 120                            ; Repeat until 800 passageway insertion attempts have been made.

; The maze has now been generated, so now insert the Exit and Rex.

; 200 POKE 16514,INT (RND*113)                          ; Select a random offset within the maze to place the Exit.
; 210 LET A=USR 17617                                   ; Attempt to place the Exit within the maze, which signals its success by setting the player's start position to $46FF.
; 220 IF PEEK 16514<>255 THEN GOTO 200                  ; If the player's start position has not been set (i.e. the Exit location selected was not good) then loop back to select a new random location for the Exit.

; 230 LET A=USR 17683                                   ; Insert Rex into the maze in the first free location within the north of the maze.

; -------------------------
; Display Initial Viewpoint
; -------------------------

; 235 CLS
; 240 SLOW                                              ; Exit from the 'mists of time'.
; 250 PRINT AT 9,27;"SCORE"
; 260 POKE 16514,255                                    ; Set the low byte of the player's start position, which is at the far south-east of the maze.
; 270 POKE 16515,70                                     ; Set the high byte of the player's start position, which is at the far south-east of the maze.
; 280 POKE 16519,0                                      ; Clear all program flags.
; 290 POKE 16523,8                                      ; Set the countdown to when the message status area will be cleared (which will initially be showing "REX LIES IN WAIT").
; 300 POKE 16516,1                                      ; Set the player facing west.
; 310 LET A=USR 18288                                   ; Display 3D view of the maze from the player's position.
; 320 IF INKEY$="" THEN GOTO 320                        ; Wait for a key to be pressed.

; -------------
; The Game Loop
; -------------

; 330 POKE 17901,INT (RND*128)                          ; Set the next character to display in the Exit pattern.
; 335 IF PEEK 21623<>178 THEN                           ; If the copyright notice embedded within the game does not contain 'm' of 'm.e.evans' then
;     POKE ((PEEK 16396+256*PEEK 16397)+66),0           ; change the end of line terminator for the second row of the display file, which will result in a crash.
; 340 POKE 16522,CODE INKEY$                            ; Store the current key press code, which will be checked by the game loop routine.
; 350 LET A=USR 18224                                   ; Run a cycle of the game loop routine, which will process the current key press and will redraw the view.
; 360 IF PEEK 16519>=128 THEN GOTO 5000                 ; Jump if the player has been caught.

; 370 FOR N=0 TO 5                                      ; Perform a delay that dictates the speed of the game.
; 380 NEXT N

; 390 IF PEEK (PEEK 16514+17920)<>45 THEN GOTO 330      ; Loop back if the player is not at the Exit.

; -----------------------
; Player Reached the Exit
; -----------------------

; 400 FOR N=0 TO 30                                     ; The Exit pattern shifts through 30 characters.
; 405 POKE 17901,INT (128*RND)                          ; Select the next random character to display in the Exit pattern.
; 410 LET A=USR 18224                                   ; Run a cycle of the game loop routine, which will display the next Exit pattern.
; 420 FOR M=0 TO 3                                      ; Perform a delay that dictates the speed of the Exit pattern.
; 425 NEXT M
; 430 NEXT N                                            ; Repeat for all characters of the Exit pattern.

; 440 CLS
; 450 GOTO 2520                                         ; Jump to display the 'Mists of Time' instructions and to generate a new maze.

; -------------
; Auto-run Save
; -------------

; 1000 CLEAR                                            ; Ensure all variables are not included in the saved program.
; 1005 CLS
; 1010 SAVE "3D MONSTER MAZe"                           ; The program will continue below after loading.

; ----------------------
; Display Opening Screen
; ----------------------

; 1015 LET N=0                                          ; A counter used to determine when to display the next message.
; 1020 PRINT AT 10,9;"ANYONE THERE?"

; 1025 LET N=N+1                                        ; Increment the counter.
; 1027 IF N=100 THEN
;      PRINT AT 12,3;"WELL PRESS SOMETHING THEN."       ; Display a follow up message after a few seconds have elapsed.
; 1030 IF INKEY$="" THEN GOTO 1025                      ; Loop back until a key has been pressed.

; --------------------------------
; Display Ringmaster and Copyright
; --------------------------------

; 1040 CLS

; 1050 POKE 16514,0                                     ; Reset the instruction line text counter, i.e. the first line of text.
; 1060 POKE 16515,162                                   ; Set the low byte of the instruction text pointer to point at the first instruction text line.
; 1065 IF PEEK 21592<>128 THEN GOTO USR (PEEK 16510)    ; Check the copyright message and reset the computer is found to be incorrect (the black space between 'new generation' and 'software').
; 1070 POKE 16516,85                                    ; Set the high byte of the instruction text pointer to L55A2, which holds the introduction text.

; 1080 LET A=USR 21809                                  ; Display the Ringmaster standing up and the copyright notice.

; ----------------------
; Scroll Up Introduction
; ----------------------

; 1090 LET A=USR 21836                                  ; Scroll up one row and display next introduction line text.
; 1100 GOSUB 3000                                       ; Perform a delay.
; 1110 IF PEEK 16514<58 THEN GOTO 1090                  ; Loop back while there are further lines of introduction text to display.

; 1120 LET A=USR 21829                                  ; Replace the top of the Ringmaster to display him bowing.
; 1125 LET S=7                                          ; The introduction text will be scrolled up 7 rows.
; 1130 GOSUB 4000                                       ; Scroll the instruction text up 7 rows.

; ------------------
; Wait For Key Press
; ------------------

; 1140 IF INKEY$="K" THEN GOTO 2000                     ; Jump if 'LIST' pressed to display the control instructions.
; 1150 IF INKEY$="A" THEN NEW                           ; Jump if 'STOP' pressed to reset the computer.
; 1160 IF INKEY$="C" THEN GOTO 2400                     ; Jump if 'CONT' pressed to display the 'mists of time' instructions.
; 1170 GOTO 1140                                        ; Loop back until a key has been pressed.

; ----------------------------
; Display Control Instructions
; ----------------------------

; 2000 POKE 16514,0                                     ; Reset the instruction line text counter, i.e. the first line of text.
; 2010 LET A=USR 21809                                  ; Display the Ringmaster standing up and the copyright notice.

; 2020 LET A=USR 21836                                  ; Scroll up one row and display next instruction line text.
; 2030 GOSUB 3000                                       ; Perform a delay.
; 2040 IF PEEK 16514<64 THEN GOTO 2020                  ; Loop back while there are further lines of instruction text to display.

; -------------------------
; Display Ringmaster Bowing
; -------------------------

; 2400 GOSUB 6000                                       ; Reset the score to "0000".

; 2500 LET A=USR 21829                                  ; Replace the top of the Ringmaster to display him bowing.
; 2505 LET S=8                                          ; The instruction text will be scrolled up 8 rows.
; 2510 GOSUB 4000                                       ; Scroll the instruction text up 8 rows.

; ------------------------------------
; Display 'Mists of Time' Instructions
; ------------------------------------

; 2520 LET A=USR 21809                                  ; Display the Ringmaster standing up and the copyright notice.

; 2530 POKE 16514,0                                     ; Reset the instruction line text counter, i.e. the first line of text.
; 2540 POKE 16515,224
; 2550 POKE 16516,90                                    ; Set the high byte of the instruction text pointer to L5AE0, which holds the 'mists of time' text.

; 2560 LET A=USR 21836                                  ; Scroll up one row and display next instruction line text.
; 2570 GOSUB 3000                                       ; Perform a delay.
; 2580 IF PEEK 16514<14 THEN GOTO 2560                  ; Loop back while there are further lines of instruction text to display.

; ----------------------------------------
; Display Ringmaster Bowing For Final Time
; ----------------------------------------

; 2585 LET S=3                                          ; The instructions will be scrolled up 3 rows.
; 2590 GOSUB 4000                                       ; Scroll the instruction text up 3 rows.

; 2595 LET A=USR 21829                                  ; Replace the top of the Ringmaster to display him bowing.

; 2600 FOR M=0 TO 10                                    ; Enter a loop to create a delay of 3 seconds.
; 2610 GOSUB 3000                                       ; Perform a 0.3s delay.
; 2620 NEXT M

; -------------------------
; Enter the 'Mists of Time'
; -------------------------

; 2630 FAST                                             ; The display will be black while the maze is being generated.
; 2636 RAND                                             ; Set the random number seed based on the FRAMES counter.
; 2640 GOTO 100                                         ; Start the game play.

; ----------------------------------------------
; Perform a Delay Between Instruction Text Lines
; ----------------------------------------------

; 3000 FOR N=0 TO 10                                    ; The delay will be approximately a third of a second.
; 3010 NEXT N
; 3020 IF PEEK 21627<>170 THEN POKE 16389,68            ; Check that the copyright notice is intact (the 'e' of 'evans'). If not then adjust RAMTOP to 1K, which will cause a crash after the 'mists of time'.
; 3030 RETURN

; -----------------------------------------------
; Scroll Instructions Up Specified Number Of Rows
; -----------------------------------------------

; 4000 FOR M=0 TO S                                     ; Loop for the specified number of lines.
; 4010 POKE 16514,1                                     ; Signal the next text to display is a blank line.
; 4020 LET A=USR 21836                                  ; Scroll up one row and display next instruction line text.
; 4030 GOSUB 3000                                       ; Perform a 0.3s delay.
; 4040 NEXT M                                           ; Repeat for the next line.
; 4050 RETURN

; ----------------------
; Player Has Been Caught
; ----------------------

; 5000 LET A=PEEK 16520                                 ; Fetch the offset within the maze of Rex.
; 5010 IF A>176 AND (A-16*INT (A/16))>9 THEN            ; If Rex is within the 5 locations in an west-east or north-south direction of the player's
;      LET A=USR 17683                                  ; start location then move Rex to the first free location within the north of the maze.
; 5020 IF INKEY$="A" THEN GOTO 5050                     ; Jump if 'STOP' pressed to request to end the game.
; 5030 IF INKEY$="C" THEN GOTO 5150                     ; Jump if 'CONT' pressed to restart the current maze.
; 5040 GOTO 5020                                        ; Loop back until a key has been pressed.

; -----------------------
; Request to End the Game
; -----------------------

; 5050 CLS
; 5060 PRINT AT 10,10;"APPEAL"
; 5070 IF RND>.5 THEN GOTO 5120                         ; Jump if the request has been rejected.

; The request to end the game has been accepted.

; 5080 PRINT AT 12,10;"ACCEPTED"
; 5090 FOR N=0 TO 40                                    ; Perform a short delay.
; 5100 NEXT N
; 5110 NEW                                              ; Reset the computer.

; The request to end the game has been rejected.

; 5120 PRINT AT 12,10;"REJECTED"
; 5130 FOR N=0 TO 30                                    ; Perform a short delay.
; 5140 NEXT N

; Restart the current maze.

; 5150 GOSUB 6000                                       ; Reset the score to "0000".
; 5160 GOTO 235                                         ; Jump to display the initial 3D viewpoint and re-enter the game loop.

; ---------------
; Reset the Score
; ---------------

; 6000 POKE 17718,28                                    ; '0'.
; 6010 POKE 17719,28                                    ; '0'.
; 6020 POKE 17720,28                                    ; '0'.
; 6030 POKE 17721,28                                    ; '0'.
; 6040 RETURN

; ------------------------------------------------------------------------------------------------------------------------------------------------------

; ===================
; BASIC Program Bytes
; ===================

L5BAB:  DEFB 95 >> 8
        DEFB 95 & $FF
        DEFW $0002
        DEFB _RAND, _NEWLINE

        DEFB 97 >> 8
        DEFB 97 & $FF
        DEFW $000C
        DEFB _GOTO, _1, _0, _1, _5, _NUMBER, $8A, $7D, $C0, $00, $00, _NEWLINE

        DEFB 100 >> 8
        DEFB 100 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _7, _4, _4, _1, _NUMBER, $8F, $08, $42, $00, $00, _NEWLINE

        DEFB 110 >> 8
        DEFB 110 & $FF
        DEFW $000B
        DEFB _LET, _T, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _NEWLINE

        DEFB 120 >> 8
        DEFB 120 & $FF
        DEFW $0010
        DEFB _LET, _X, _EQUALS, _INT, _OPENBRACKET, _RND, _ASTERISK, _4, _NUMBER
        DEFB $83, $00, $00, $00, $00, _CLOSEBRACKET, _NEWLINE

        DEFB 130 >> 8
        DEFB 130 & $FF
        DEFW $002D
        DEFB _IF, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00
        DEFB _LESSTHAN, _1, _6, _NUMBER, $85, $00, $00, $00, $00, _AND, _RND, _LESSTHAN
        DEFB _FULLSTOP, _9, _NUMBER, $80, $66, $66, $66, $66, _THEN, _LET, _X, _EQUALS, _2
        DEFB _NUMBER, $82, $00, $00, $00, $00, _NEWLINE

        DEFB 140 >> 8
        DEFB 140 & $FF
        DEFW $000F
        DEFB _POKE, _1, _6, _5, _1, _7, _NUMBER, $8F, $01, $0A, $00, $00, _COMMA, _X, _NEWLINE

        DEFB 150 >> 8
        DEFB 150 & $FF
        DEFW $0010
        DEFB _LET, _X, _EQUALS, _INT, _OPENBRACKET, _RND, _ASTERISK, _6, _NUMBER, $83, $40, $00, $00, $00
        DEFB _CLOSEBRACKET, _NEWLINE

        DEFB 160 >> 8
        DEFB 160 & $FF
        DEFW $0007
        DEFB _LET, _T, _EQUALS, _T, _PLUS, _X, _NEWLINE

        DEFB 170 >> 8
        DEFB 170 & $FF
        DEFW $000F
        DEFB _POKE, _1, _6, _5, _1, _6, _NUMBER, $8F, $01, $08, $00, $00, _COMMA, _X, _NEWLINE

        DEFB 180 >> 8
        DEFB 180 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _7, _4, _6, _1, _NUMBER, $8F, $08, $6A, $00, $00, _NEWLINE

        DEFB 190 >> 8
        DEFB 190 & $FF
        DEFW $0018
        DEFB _IF, _T, _LESSTHAN, _8, _0, _0, _NUMBER, $8A, $48, $00, $00, $00, _THEN, _GOTO
        DEFB _1, _2, _0, _NUMBER, $87, $70, $00, $00, $00, _NEWLINE

        DEFB 200 >> 8
        DEFB 200 & $FF
        DEFW $001C
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _INT, _OPENBRACKET
        DEFB _RND, _ASTERISK, _1, _1, _3, _NUMBER, $87, $62, $00, $00, $00, _CLOSEBRACKET, _NEWLINE

        DEFB 210 >> 8
        DEFB 210 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _7, _6, _1, _7, _NUMBER, $8F, $09, $A2, $00, $00, _NEWLINE

        DEFB 220 >> 8
        DEFB 220 & $FF
        DEFW $0023
        DEFB _IF, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _NOTEQUAL, _2, _5, _5
        DEFB _NUMBER, $88, $7F, $00, $00, $00, _THEN, _GOTO, _2, _0, _0, _NUMBER
        DEFB $88, $48, $00, $00, $00, _NEWLINE

        DEFB 230 >> 8
        DEFB 230 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _7, _6, _8, _3, _NUMBER, $8F, $0A, $26, $00, $00, _NEWLINE

        DEFB 235 >> 8
        DEFB 235 & $FF
        DEFW $0002
        DEFB _CLS, _NEWLINE

        DEFB 240 >> 8
        DEFB 240 & $FF
        DEFW $0002
        DEFB _SLOW, _NEWLINE

        DEFB 250 >> 8
        DEFB 250 & $FF
        DEFW $001B
        DEFB _PRINT, _AT, _9, _NUMBER, $84, $10, $00, $00, $00, _COMMA, _2, _7
        DEFB _NUMBER, $85, $58, $00, $00, $00, _SEMICOLON, _QUOTE, _S, _C, _O, _R, _E, _QUOTE, _NEWLINE

        DEFB 260 >> 8
        DEFB 260 & $FF
        DEFW $0017
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _2, _5, _5
        DEFB _NUMBER, $88, $7F, $00, $00, $00, _NEWLINE

        DEFB 270 >> 8
        DEFB 270 & $FF
        DEFW $0016
        DEFB _POKE, _1, _6, _5, _1, _5, _NUMBER, $8F, $01, $06, $00, $00, _COMMA, _7, _0
        DEFB _NUMBER, $87, $0C, $00, $00, $00, _NEWLINE

        DEFB 280 >> 8
        DEFB 280 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _9, _NUMBER, $8F, $01, $0E, $00, $00, _COMMA, _0
        DEFB _NUMBER, $00, $00, $00, $00, $00, _NEWLINE

        DEFB 290 >> 8
        DEFB 290 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _2, _3, _NUMBER, $8F, $01, $16, $00, $00, _COMMA, _8
        DEFB _NUMBER, $84, $00, $00, $00, $00, _NEWLINE

        DEFB 300 >> 8
        DEFB 300 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _6, _NUMBER, $8F, $01, $08, $00, $00, _COMMA, _1
        DEFB _NUMBER, $81, $00, $00, $00, $00, _NEWLINE

        DEFB 310 >> 8
        DEFB 310 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _8, _2, _8, _8, _NUMBER, $8F, $0E, $E0, $00, $00, _NEWLINE

        DEFB 320 >> 8
        DEFB 320 & $FF
        DEFW $0011
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _QUOTE, _THEN, _GOTO, _3, _2, _0
        DEFB _NUMBER, $89, $20, $00, $00, $00, _NEWLINE

        DEFB 330 >> 8
        DEFB 330 & $FF
        DEFW $001C
        DEFB _POKE, _1, _7, _9, _0, _1, _NUMBER, $8F, $0B, $DA, $00, $00, _COMMA, _INT, _OPENBRACKET
        DEFB _RND, _ASTERISK, _1, _2, _8, _NUMBER, $88, $00, $00, $00, $00, _CLOSEBRACKET, _NEWLINE

        DEFB 335 >> 8
        DEFB 335 & $FF
        DEFW $0052
        DEFB _IF, _PEEK, _2, _1, _6, _2, _3, _NUMBER, $8F, $28, $EE, $00, $00, _NOTEQUAL, _1, _7, _8
        DEFB _NUMBER, $88, $32, $00, $00, $00, _THEN, _POKE, _OPENBRACKET, _OPENBRACKET
        DEFB _PEEK, _1, _6, _3, _9, _6, _NUMBER, $8F, $00, $18, $00, $00, _PLUS, _2, _5, _6
        DEFB _NUMBER, $89, $00, $00, $00, $00, _ASTERISK, _PEEK, _1, _6, _3, _9, _7
        DEFB _NUMBER, $8F, $00, $1A, $00, $00, _CLOSEBRACKET, _PLUS, _6, _6
        DEFB _NUMBER, $87, $04, $00, $00, $00, _CLOSEBRACKET, _COMMA, _0, _NUMBER, $00, $00, $00, $00, $00
        DEFB _NEWLINE

        DEFB 340 >> 8
        DEFB 340 & $FF
        DEFW $0010
        DEFB _POKE, _1, _6, _5, _2, _2, _NUMBER, $8F, $01, $14, $00, $00, _COMMA, _CODE, _INKEY, _NEWLINE

        DEFB 350 >> 8
        DEFB 350 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _8, _2, _2, _4, _NUMBER, $8F, $0E, $60, $00, $00, _NEWLINE

        DEFB 360 >> 8
        DEFB 360 & $FF
        DEFW $0024
        DEFB _IF, _PEEK, _1, _6, _5, _1, _9, _NUMBER, $8F, $01, $0E, $00, $00, _GREATERTHANEQUAL
        DEFB _1, _2, _8, _NUMBER, $88, $00, $00, $00, $00, _THEN, _GOTO, _5, _0, _0, _0
        DEFB _NUMBER, $8D, $1C, $40, $00, $00, _NEWLINE

        DEFB 370 >> 8
        DEFB 370 & $FF
        DEFW $0013
        DEFB _FOR, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _5
        DEFB _NUMBER, $83, $20, $00, $00, $00, _NEWLINE

        DEFB 380 >> 8
        DEFB 380 & $FF
        DEFW $0003
        DEFB _NEXT, _N, _NEWLINE

        DEFB 390 >> 8
        DEFB 390 & $FF
        DEFW $0031
        DEFB _IF, _PEEK, _OPENBRACKET, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00
        DEFB _PLUS, _1, _7, _9, _2, _0, _NUMBER, $8F, $0C, $00, $00, $00, _CLOSEBRACKET, _NOTEQUAL
        DEFB _4, _5, _NUMBER, $86, $34, $00, $00, $00, _THEN, _GOTO, _3, _3, _0
        DEFB _NUMBER, $89, $25, $00, $00, $00, _NEWLINE

        DEFB 400 >> 8
        DEFB 400 & $FF
        DEFW $0014
        DEFB _FOR, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _3, _0
        DEFB _NUMBER, $85, $70, $00, $00, $00, _NEWLINE

        DEFB 405 >> 8
        DEFB 405 & $FF
        DEFW $001C
        DEFB _POKE, _1, _7, _9, _0, _1, _NUMBER, $8F, $0B, $DA, $00, $00, _COMMA, _INT, _OPENBRACKET
        DEFB _1, _2, _8, _NUMBER, $88, $00, $00, $00, $00, _ASTERISK, _RND, _CLOSEBRACKET, _NEWLINE

        DEFB 410 >> 8
        DEFB 410 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _1, _8, _2, _2, _4, _NUMBER, $8F, $0E, $60, $00, $00, _NEWLINE

        DEFB 420 >> 8
        DEFB 420 & $FF
        DEFW $0013
        DEFB _FOR, _M, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _3
        DEFB _NUMBER, $82, $40, $00, $00, $00, _NEWLINE

        DEFB 425 >> 8
        DEFB 425 & $FF
        DEFW $0003
        DEFB _NEXT, _M, _NEWLINE

        DEFB 430 >> 8
        DEFB 430 & $FF
        DEFW $0003
        DEFB _NEXT, _N, _NEWLINE

        DEFB 440 >> 8
        DEFB 440 & $FF
        DEFW $0002
        DEFB _CLS, _NEWLINE

        DEFB 450 >> 8
        DEFB 450 & $FF
        DEFW $000C
        DEFB _GOTO, _2, _5, _2, _0, _NUMBER, $8C, $1D, $80, $00, $00, _NEWLINE

        DEFB 1000 >> 8
        DEFB 1000 & $FF
        DEFW $0002
        DEFB _CLEAR, _NEWLINE

        DEFB 1005 >> 8
        DEFB 1005 & $FF
        DEFW $0002
        DEFB _CLS, _NEWLINE

        DEFB 1010 >> 8
        DEFB 1010 & $FF
        DEFW $0013
        DEFB _SAVE, _QUOTE, _3, _D, _SPACE, _M, _O, _N, _S, _T, _E, _R, _SPACE, _M, _A, _Z, _INVE, _QUOTE
        DEFB _NEWLINE

L5FA4:  DEFB 1015 >> 8
        DEFB 1015 & $FF
        DEFW $000B
        DEFB _LET, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _NEWLINE

        DEFB 1020 >> 8
        DEFB 1020 & $FF
        DEFW $0023
        DEFB _PRINT, _AT, _1, _0, _NUMBER, $84, $20, $00, $00, $00, _COMMA, _9
        DEFB _NUMBER, $84, $10, $00, $00, $00, _SEMICOLON, _QUOTE, _A, _N, _Y, _O, _N, _E, _SPACE
        DEFB _T, _H, _E, _R, _E, _QUESTIONMARK, _QUOTE, _NEWLINE

        DEFB 1025 >> 8
        DEFB 1025 & $FF
        DEFW $000D
        DEFB _LET, _N, _EQUALS, _N, _PLUS, _1, _NUMBER, $81, $00, $00, $00, $00, _NEWLINE

        DEFB 1027 >> 8
        DEFB 1027 & $FF
        DEFW $003D
        DEFB _IF, _N, _EQUALS, _1, _0, _0, _NUMBER, $87, $48, $00, $00, $00, _THEN, _PRINT, _AT
        DEFB _1, _2, _NUMBER, $84, $40, $00, $00, $00, _COMMA, _3, _NUMBER, $82, $40, $00, $00, $00
        DEFB _SEMICOLON, _QUOTE, _W, _E, _L, _L, _SPACE, _P, _R, _E, _S, _S, _SPACE
        DEFB _S, _O, _M, _E, _T, _H, _I, _N, _G, _SPACE, _T, _H, _E, _N, _FULLSTOP, _QUOTE, _NEWLINE

        DEFB 1030 >> 8
        DEFB 1030 & $FF
        DEFW $0012
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _QUOTE, _THEN, _GOTO, _1, _0, _2, _5
        DEFB _NUMBER, $8B, $00, $20, $00, $00, _NEWLINE

        DEFB 1040 >> 8
        DEFB 1040 & $FF
        DEFW $0002
        DEFB _CLS, _NEWLINE

        DEFB 1050 >> 8
        DEFB 1050 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _0
        DEFB _NUMBER, $00, $00, $00, $00, $00, _NEWLINE

        DEFB 1060 >> 8
        DEFB 1060 & $FF
        DEFW $0017
        DEFB _POKE, _1, _6, _5, _1, _5, _NUMBER, $8F, $01, $06, $00, $00, _COMMA, _1, _6, _2
        DEFB _NUMBER, $88, $22, $00, $00, $00, _NEWLINE

        DEFB 1065 >> 8
        DEFB 1065 & $FF
        DEFW $0029
        DEFB _IF, _PEEK, _2, _1, _5, _9, _2, _NUMBER, $8F, $28, $B0, $00, $00, _NOTEQUAL
#ifdef JK_GREYE
        DEFB _1, _8, _3, _NUMBER, $88, $37, $00, $00, $00
#else
        DEFB _1, _2, _8, _NUMBER, $88, $00, $00, $00, $00
#endif
        DEFB _THEN, _GOTO, _USR, _OPENBRACKET, _PEEK, _1, _6, _5, _1, _0
        DEFB _NUMBER, $8F, $00, $FC, $00, $00, _CLOSEBRACKET, _NEWLINE

        DEFB 1070 >> 8
        DEFB 1070 & $FF
        DEFW $0016
        DEFB _POKE, _1, _6, _5, _1, _6, _NUMBER, $8F, $01, $08, $00, $00, _COMMA, _8, _5
        DEFB _NUMBER, $87, $2A, $00, $00, $00, _NEWLINE

        DEFB 1080 >> 8
        DEFB 1080 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _0, _9, _NUMBER, $8F, $2A, $62, $00, $00, _NEWLINE

        DEFB 1090 >> 8
        DEFB 1090 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _3, _6, _NUMBER, $8F, $2A, $98, $00, $00, _NEWLINE

        DEFB 1100 >> 8
        DEFB 1100 & $FF
        DEFW $000C
        DEFB _GOSUB, _3, _0, _0, _0, _NUMBER, $8C, $3B, $80, $00, $00, _NEWLINE

        DEFB 1110 >> 8
        DEFB 1110 & $FF
        DEFW $0023
        DEFB _IF, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _LESSTHAN, _5, _8
        DEFB _NUMBER, $86, $68, $00, $00, $00, _THEN, _GOTO, _1, _0, _9, _0
        DEFB _NUMBER, $8B, $08, $40, $00, $00, _NEWLINE

        DEFB 1120 >> 8
        DEFB 1120 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _2, _9, _NUMBER, $8F, $2A, $8A, $00, $00, _NEWLINE

        DEFB 1125 >> 8
        DEFB 1125 & $FF
        DEFW $000B
        DEFB _LET, _S, _EQUALS, _7, _NUMBER, $83, $60, $00, $00, $00, _NEWLINE

        DEFB 1130 >> 8
        DEFB 1130 & $FF
        DEFW $000C
        DEFB _GOSUB, _4, _0, _0, _0, _NUMBER, $8C, $7A, $00, $00, $00, _NEWLINE

        DEFB 1140 >> 8
        DEFB 1140 & $FF
        DEFW $0013
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _K, _QUOTE, _THEN, _GOTO, _2, _0, _0, _0
        DEFB _NUMBER, $8B, $7A, $00, $00, $00, _NEWLINE

        DEFB 1150 >> 8
        DEFB 1150 & $FF
        DEFW $0009
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _A, _QUOTE, _THEN, _NEW, _NEWLINE

        DEFB 1160 >> 8
        DEFB 1160 & $FF
        DEFW $0013
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _C, _QUOTE, _THEN, _GOTO, _2, _4, _0, _0
        DEFB _NUMBER, $8C, $16, $00, $00, $00, _NEWLINE

        DEFB 1170 >> 8
        DEFB 1170 & $FF
        DEFW $000C
        DEFB _GOTO, _1, _1, _4, _0, _NUMBER, $8B, $0E, $80, $00, $00, _NEWLINE

        DEFB 2000 >> 8
        DEFB 2000 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _0
        DEFB _NUMBER, $00, $00, $00, $00, $00, _NEWLINE

        DEFB 2010 >> 8
        DEFB 2010 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _0, _9, _NUMBER, $8F, $2A, $62, $00, $00, _NEWLINE

        DEFB 2020 >> 8
        DEFB 2020 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _3, _6, _NUMBER, $8F, $2A, $98, $00, $00, _NEWLINE

        DEFB 2030 >> 8
        DEFB 2030 & $FF
        DEFW $000C
        DEFB _GOSUB, _3, _0, _0, _0, _NUMBER, $8C, $3B, $80, $00, $00, _NEWLINE

        DEFB 2040 >> 8
        DEFB 2040 & $FF
        DEFW $0023
        DEFB _IF, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _LESSTHAN, _6, _4
        DEFB _NUMBER, $87, $00, $00, $00, $00, _THEN, _GOTO, _2, _0, _2, _0
        DEFB _NUMBER, $8B, $7C, $80, $00, $00, _NEWLINE

        DEFB 2400 >> 8
        DEFB 2400 & $FF
        DEFW $000C
        DEFB _GOSUB, _6, _0, _0, _0, _NUMBER, $8D, $3B, $80, $00, $00, _NEWLINE

        DEFB 2500 >> 8
        DEFB 2500 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _2, _9, _NUMBER, $8F, $2A, $8A, $00, $00, _NEWLINE

        DEFB 2505 >> 8
        DEFB 2505 & $FF
        DEFW $000B
        DEFB _LET, _S, _EQUALS, _8, _NUMBER, $84, $00, $00, $00, $00, _NEWLINE

        DEFB 2510 >> 8
        DEFB 2510 & $FF
        DEFW $000C
        DEFB _GOSUB, _4, _0, _0, _0, _NUMBER, $8C, $7A, $00, $00, $00, _NEWLINE

        DEFB 2520 >> 8
        DEFB 2520 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _0, _9, _NUMBER, $8F, $2A, $62, $00, $00, _NEWLINE

        DEFB 2530 >> 8
        DEFB 2530 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _0, _NUMBER
        DEFB $00, $00, $00, $00, $00, _NEWLINE

        DEFB 2540 >> 8
        DEFB 2540 & $FF
        DEFW $0017
        DEFB _POKE, _1, _6, _5, _1, _5, _NUMBER, $8F, $01, $06, $00, $00, _COMMA, _2, _2, _4
        DEFB _NUMBER, $88, $60, $00, $00, $00, _NEWLINE

        DEFB 2550 >> 8
        DEFB 2550 & $FF
        DEFW $0016
        DEFB _POKE, _1, _6, _5, _1, _6, _NUMBER, $8F, $01, $08, $00, $00, _COMMA, _9, _0
        DEFB _NUMBER, $87, $34, $00, $00, $00, _NEWLINE

        DEFB 2560 >> 8
        DEFB 2560 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _3, _6, _NUMBER, $8F, $2A, $98, $00, $00, _NEWLINE

        DEFB 2570 >> 8
        DEFB 2570 & $FF
        DEFW $000C
        DEFB _GOSUB, _3, _0, _0, _0, _NUMBER, $8C, $3B, $80, $00, $00, _NEWLINE

        DEFB 2580 >> 8
        DEFB 2580 & $FF
        DEFW $0023
        DEFB _IF, _PEEK, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _LESSTHAN, _1, _4
        DEFB _NUMBER, $84, $60, $00, $00, $00, _THEN, _GOTO, _2, _5, _6, _0
        DEFB _NUMBER, $8C, $20, $00, $00, $00, _NEWLINE

        DEFB 2585 >> 8
        DEFB 2585 & $FF
        DEFW $000B
        DEFB _LET, _S, _EQUALS, _3, _NUMBER, $82, $40, $00, $00, $00, _NEWLINE

        DEFB 2590 >> 8
        DEFB 2590 & $FF
        DEFW $000C
        DEFB _GOSUB, _4, _0, _0, _0, _NUMBER, $8C, $7A, $00, $00, $00, _NEWLINE

        DEFB 2595 >> 8
        DEFB 2595 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _2, _9, _NUMBER, $8F, $2A, $8A, $00, $00, _NEWLINE

        DEFB 2600 >> 8
        DEFB 2600 & $FF
        DEFW $0014
        DEFB _FOR, _M, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _1, _0
        DEFB _NUMBER, $84, $20, $00, $00, $00, _NEWLINE

        DEFB 2610 >> 8
        DEFB 2610 & $FF
        DEFW $000C
        DEFB _GOSUB, _3, _0, _0, _0, _NUMBER, $8C, $3B, $80, $00, $00, _NEWLINE

        DEFB 2620 >> 8
        DEFB 2620 & $FF
        DEFW $0003
        DEFB _NEXT, _M, _NEWLINE

        DEFB 2630 >> 8
        DEFB 2630 & $FF
        DEFW $0002
        DEFB _FAST, _NEWLINE

        DEFB 2636 >> 8
        DEFB 2636 & $FF
        DEFW $0002
        DEFB _RAND, _NEWLINE

        DEFB 2640 >> 8
        DEFB 2640 & $FF
        DEFW $000B
        DEFB _GOTO, _1, _0, _0, _NUMBER, $87, $48, $00, $00, $00, _NEWLINE

        DEFB 3000 >> 8
        DEFB 3000 & $FF
        DEFW $0014
        DEFB _FOR, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _1, _0
        DEFB _NUMBER, $84, $20, $00, $00, $00, _NEWLINE

        DEFB 3010 >> 8
        DEFB 3010 & $FF
        DEFW $0003
        DEFB _NEXT, _N, _NEWLINE

        DEFB 3020 >> 8
        DEFB 3020 & $FF
        DEFW $002E
        DEFB _IF, _PEEK, _2, _1, _6, _2, _7, _NUMBER, $8F, $28, $F6, $00, $00, _NOTEQUAL, _1, _7, _0
        DEFB _NUMBER, $88, $2A, $00, $00, $00, _THEN, _POKE, _1, _6, _3, _8, _9
        DEFB _NUMBER, $8F, $00, $0A, $00, $00, _COMMA, _6, _8, _NUMBER, $87, $08, $00, $00, $00, _NEWLINE

        DEFB 3030 >> 8
        DEFB 3030 & $FF
        DEFW $0002
        DEFB _RETURN, _NEWLINE

        DEFB 4000 >> 8
        DEFB 4000 & $FF
        DEFW $000D
        DEFB _FOR, _M, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _S, _NEWLINE

        DEFB 4010 >> 8
        DEFB 4010 & $FF
        DEFW $0015
        DEFB _POKE, _1, _6, _5, _1, _4, _NUMBER, $8F, $01, $04, $00, $00, _COMMA, _1
        DEFB _NUMBER, $81, $00, $00, $00, $00, _NEWLINE

        DEFB 4020 >> 8
        DEFB 4020 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _USR, _2, _1, _8, _3, _6, _NUMBER, $8F, $2A, $98, $00, $00, _NEWLINE

        DEFB 4030 >> 8
        DEFB 4030 & $FF
        DEFW $000C
        DEFB _GOSUB, _3, _0, _0, _0, _NUMBER, $8C, $3B, $80, $00, $00, _NEWLINE

        DEFB 4040 >> 8
        DEFB 4040 & $FF
        DEFW $0003
        DEFB _NEXT, _M, _NEWLINE

        DEFB 4050 >> 8
        DEFB 4050 & $FF
        DEFW $0002
        DEFB _RETURN, _NEWLINE

        DEFB 5000 >> 8
        DEFB 5000 & $FF
        DEFW $0010
        DEFB _LET, _A, _EQUALS, _PEEK, _1, _6, _5, _2, _0, _NUMBER, $8F, $01, $10, $00, $00, _NEWLINE

        DEFB 5010 >> 8
        DEFB 5010 & $FF
        DEFW $0040
        DEFB _IF, _A, _GREATERTHAN, _1, _7, _6, _NUMBER, $88, $30, $00, $00, $00, _AND, _OPENBRACKET
        DEFB _A, _MINUS, _1, _6, _NUMBER, $85, $00, $00, $00, $00, _ASTERISK, _INT, _OPENBRACKET
        DEFB _A, _DIVIDE, _1, _6, _NUMBER, $85, $00, $00, $00, $00, _CLOSEBRACKET, _CLOSEBRACKET
        DEFB _GREATERTHAN, _9, _NUMBER, $84, $10, $00, $00, $00, _THEN
        DEFB _LET, _A, _EQUALS, _USR, _1, _7, _6, _8, _3, _NUMBER, $8F, $0A, $26, $00, $00, _NEWLINE

        DEFB 5020 >> 8
        DEFB 5020 & $FF
        DEFW $0013
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _A, _QUOTE, _THEN, _GOTO, _5, _0, _5, _0
        DEFB _NUMBER, $8D, $1D, $D0, $00, $00, _NEWLINE

        DEFB 5030 >> 8
        DEFB 5030 & $FF
        DEFW $0013
        DEFB _IF, _INKEY, _EQUALS, _QUOTE, _C, _QUOTE, _THEN, _GOTO, _5, _1, _5, _0
        DEFB _NUMBER, $8D, $20, $F0, $00, $00, _NEWLINE

        DEFB 5040 >> 8
        DEFB 5040 & $FF
        DEFW $000C
        DEFB _GOTO, _5, _0, _2, _0, _NUMBER, $8D, $1C, $E0, $00, $00, _NEWLINE

        DEFB 5050 >> 8
        DEFB 5050 & $FF
        DEFW $0002
        DEFB _CLS, _NEWLINE

        DEFB 5060 >> 8
        DEFB 5060 & $FF
        DEFW $001D
        DEFB _PRINT, _AT, _1, _0, _NUMBER, $84, $20, $00, $00, $00, _COMMA, _1, _0
        DEFB _NUMBER, $84, $20, $00, $00, $00, _SEMICOLON, _QUOTE, _A, _P, _P, _E, _A, _L, _QUOTE, _NEWLINE

        DEFB 5070 >> 8
        DEFB 5070 & $FF
        DEFW $0018
        DEFB _IF, _RND, _GREATERTHAN, _FULLSTOP, _5, _NUMBER, $7F, $7F, $FF, $FF, $FF, _THEN
        DEFB _GOTO, _5, _1, _2, _0, _NUMBER, $8D, $20, $00, $00, $00, _NEWLINE

        DEFB 5080 >> 8
        DEFB 5080 & $FF
        DEFW $001F
        DEFB _PRINT, _AT, _1, _2, _NUMBER, $84, $40, $00, $00, $00, _COMMA, _1, _0
        DEFB _NUMBER, $84, $20, $00, $00, $00, _SEMICOLON, _QUOTE, _A, _C, _C, _E, _P, _T, _E, _D, _QUOTE
        DEFB _NEWLINE

        DEFB 5090 >> 8
        DEFB 5090 & $FF
        DEFW $0014
        DEFB _FOR, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _4, _0
        DEFB _NUMBER, $86, $20, $00, $00, $00, _NEWLINE

        DEFB 5100 >> 8
        DEFB 5100 & $FF
        DEFW $0003
        DEFB _NEXT, _N, _NEWLINE

        DEFB 5110 >> 8
        DEFB 5110 & $FF
        DEFW $0002
        DEFB _NEW, _NEWLINE

        DEFB 5120 >> 8
        DEFB 5120 & $FF
        DEFW $001F
        DEFB _PRINT, _AT, _1, _2, _NUMBER, $84, $40, $00, $00, $00, _COMMA, _1, _0
        DEFB _NUMBER, $84, $20, $00, $00, $00, _SEMICOLON, _QUOTE, _R, _E, _J, _E, _C, _T, _E, _D, _QUOTE
        DEFB _NEWLINE

        DEFB 5130 >> 8
        DEFB 5130 & $FF
        DEFW $0014
        DEFB _FOR, _N, _EQUALS, _0, _NUMBER, $00, $00, $00, $00, $00, _TO, _3, _0
        DEFB _NUMBER, $85, $70, $00, $00, $00, _NEWLINE

        DEFB 5140 >> 8
        DEFB 5140 & $FF
        DEFW $0003
        DEFB _NEXT, _N, _NEWLINE

        DEFB 5150 >> 8
        DEFB 5150 & $FF
        DEFW $000C
        DEFB _GOSUB, _6, _0, _0, _0, _NUMBER, $8D, $3B, $80, $00, $00, _NEWLINE

        DEFB 5160 >> 8
        DEFB 5160 & $FF
        DEFW $000B
        DEFB _GOTO, _2, _3, _5, _NUMBER, $88, $6B, $00, $00, $00, _NEWLINE

        DEFB 6000 >> 8
        DEFB 6000 & $FF
        DEFW $0016
        DEFB _POKE, _1, _7, _7, _1, _8, _NUMBER, $8F, $0A, $6C, $00, $00, _COMMA, _2, _8
        DEFB _NUMBER, $85, $60, $00, $00, $00, _NEWLINE

        DEFB 6010 >> 8
        DEFB 6010 & $FF
        DEFW $0016
        DEFB _POKE, _1, _7, _7, _1, _9, _NUMBER, $8F, $0A, $6E, $00, $00, _COMMA, _2, _8
        DEFB _NUMBER, $85, $60, $00, $00, $00, _NEWLINE

        DEFB 6020 >> 8
        DEFB 6020 & $FF
        DEFW $0016
        DEFB _POKE, _1, _7, _7, _2, _0, _NUMBER, $8F, $0A, $70, $00, $00, _COMMA, _2, _8
        DEFB _NUMBER, $85, $60, $00, $00, $00, _NEWLINE

        DEFB 6030 >> 8
        DEFB 6030 & $FF
        DEFW $0016
        DEFB _POKE, _1, _7, _7, _2, _1, _NUMBER, $8F, $0A, $72, $00, $00, _COMMA, _2, _8
        DEFB _NUMBER, $85, $60, $00, $00, $00, _NEWLINE

        DEFB 6040 >> 8
        DEFB 6040 & $FF
        DEFW $0002
        DEFB _RETURN, _NEWLINE

; ======================================================================================================================================================

; ------------
; Display File
; ------------

L6627:  DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
L6F50:  DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
        DEFB _NEWLINE

; ======================================================================================================================================================

; --------------
; Variables Area
; --------------

L6940:  DEFB $80

; ======================================================================================================================================================

; --------------
; End of Program
; --------------

SV_ELINE:

; ======================================================================================================================================================

        END

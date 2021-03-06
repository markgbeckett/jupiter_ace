	;; Tut-tut for Jupiter Ace
	;; Original Game by David Stephenson 2019
	;; Ported to Jupiter Ace by George Beckett 2020
	;;
	;; This file contains the data for the character bitmaps
	;; of the game, in a format that can be inserted into the
	;; Forth word CHARSET, which is allocated in tut-tut.fs.
	;; To work out how much space is required, assemble this
	;; file with label-file output enabled. The value of the
	;; label END will confirm the number of bytes, xxx, that
	;; should be assigned with:
	;;
	;; CREATE CHARSET xxx ALLOT
	;;
	;; The (assembled) binary file needs to then be loaded
	;; into Ace memory at the address reported by:
	;;
	;; CHARSET .
	;; 
	;; In casse of problems, contact:
	;; markgbeckett@gmail.com

	;; User-defined graphics and Egypt-themed character set
	;; Each row contains
	;;   ASCII code, Row 0, Row 1, ..., Row 7

	org 0x0000
	
CHARSET:
	db   1,127, 65, 91, 67,109,111,127,  0	; Wall 1
	db   2,127, 65, 91, 67,109,111,127,  0 	; Wall 2
	db   3,127, 65, 91, 67,109,111,127,  0	; Wall 3
	db   4,162, 21,168, 85,162, 21,168, 85	; Wall 4
	db   5,  0, 60,102, 66, 66,102, 60,  0	; Bracelet
	db   6,  8, 62, 34, 28,  8, 62,  8,  8	; Amulet
	db   7,  0,  0, 24, 36, 86, 60, 24,  0	; Gem
	db   8, 24,215, 76, 62,  7, 12 ,20, 50	; Mummy #1
	db   9, 24, 24, 18,126,176, 24, 52, 38	; Mummy #2
	db  10, 24, 60, 24, 72,126, 24, 44, 32	; Player #1
	db  11, 24, 60, 24, 19,126, 24, 52,  4	; Player #2
	db  12,204,102, 51,153,204,102, 51,153	; Air
	db  14,204,102, 51,153,204,102, 51,153	; Border
	;; db  49,  0,152,184,148,146,140,128,254  ; Key 1
	;; db  50,  0,144,178,146,158,182,128,254  ; Key 2
	;; db  51,  0,162,170,148,182,156,128,254  ; Key 3
	;; db  52,  0,156,162,162,156,190,128,254  ; Key 4
	db 'A',0,8,20,20,36,34,66,78
	db 'B',0, 126, 68, 72, 112, 72, 6, 126
	db 'C',0,126,68,64,64,64,70,126
	db 'D',0, 124, 68, 66, 66, 66, 2, 124
	db 'E',0,126,68,32,28,32,70,126
	db 'G',0, 122, 68, 64, 78, 66, 66, 126
	db 'H',0, 66, 34, 34, 62, 34, 98, 98
	db 'I',0,56,20,16,16,16,48,56
	db 'K',0,78,36,40,48,40,36,66
	db 'L',64,48,16,16,16,16,48,62
	db 'M',0,68,108,84,84,84,68,70
	db 'P',0, 126, 66, 74, 94, 64, 64, 64
	db 'R',0,126,66,66,94,80,76,66
	db 'S',0,126,68,32,16,8,100,126
	db 'T',0,126,20,16,16,16,48,56
	db 'U',4,66,68,68,68,68,68,124
	db 'V',4,66,68,36,36,40,40,16
	db 'W',0,98,34,42,42,42,54,34
	db 'Y',4,66,36,24,16,16,48,56
	db 13,204, 100, 55, 145, 220, 70, 115, 25
END:	

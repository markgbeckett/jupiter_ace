	;; Tut-tut for Jupiter Ace
	;; Original Game by David Stephenson 2019
	;; Ported to Jupiter Ace by George Beckett 2020
	;;
	;; This file contains the data for the text displayed on
	;; the splash screens of the game, in a format that can
	;; be inserted into the Forth word MESSAGES, which is
	;; allocated in tut-tut.fs.
	;; 
	;; To work out how much space is required, assemble this
	;; file with label-file output enabled. The value of the
	;; label END will confirm the number of bytes, xxx, that
	;; should be assigned with:
	;;
	;; CREATE MESSAGES xxx ALLOT
	;;
	;; The (assembled) binary file needs to then be loaded
	;; into Ace memory at the address reported by:
	;;
	;; MESSAGES .
	;; 
	;; In case of problems, contact:
	;; markgbeckett@gmail.com

	org 0x0000

MESSAGES:
	dw MESSAGE0
	dw MESSAGE1
	dw MESSAGE2
	dw MESSAGE3
	dw MESSAGE4
MESSAGE0:
	db 3, 13, 1, 13
	db 4, 3
	db 1,  1,  1,  1, 1, 32, 1, 32, 32, 32, 32, 1, 32, 1, 1, 1, 1, 1, 13
	db 5, 5
	db 1, 32,  1, 32, 1, 32, 32, 32, 1, 32, 32, 32, 32, 1, 32, 1, 13
	db 6, 5
	db 1, 32, 32, 32, 1, 32, 32, 32, 1, 32, 32, 32, 32, 1, 13
	db 7, 5
	db 1, 32, 32, 32, 1, 32, 32, 32, 1, 32, 32, 32, 32, 1, 13
	db 8, 4
	db 1,  1, 32, 32,  32, 1, 32, 32, 32, 1, 32, 32, 32, 1, 1, 13
	db 9, 4
	db 1, 1, 1, 32, 32, 1, 1, 1, 1, 1, 32, 32, 32, 1, 1, 1, 13
	db 11, 4
	dm "HIGH SCORE:"
	db 13, 16, 3
	dm "EGYPTIAN TOMB RAID"
	db 13, 12
MESSAGE1:
	db 3, 3
	dm "COLLECT TREASURE"
	db 13, 4, 3
	dm "* PHARAOH'S GEMS"
	db 13, 5, 3
	dm "* BRACELETS - HALT"
	db 13, 6, 3
	dm "* AMULETS - FREEZE"
        db 13, 7, 3
	dm "* KEYS SLIDE WALLS"
	db 13, 9, 3
	dm "SURVIVE"
	db 13, 10, 3
	dm "* AVOID MUMMIES"
	db 13, 11, 3
	dm "* AIR RUNS OUT"
	db 13,16,3
	dm "ANCIENT ARTEFACTS"
	db 13, 12
MESSAGE2:
	db 3, 4
	dm "KEYS    1234  10"
	db 13, 4, 4
	dm "GEMS       "
	db 7
	dm "  25"
	db 13, 5, 4
	dm "BRACELET   "
	db 5
	dm "  75"
	db 13, 6, 4
	dm "AMULET     "
	db 6
	dm " 100"
	db 13, 8, 4
	dm "LEVEL EXIT "
	db 180
	dm " 50+"
	db 13, 9, 4
	dm "AIR  LEFT  BONUS"
	db 13, 11, 4
	dm "MUMMIES    "
	db 8
	dm " -25"
	db 13,16,3
	dm "PHARAOH'S TREASURE"
	db 13, 12
MESSAGE3:
	db 3, 3
	dm "KEYBOARD CONTROLS"
	db 13, 5, 7
        dm "* UP    Q"
	db 13, 6, 7
	dm "* DOWN  A"
	db 13, 7, 7
	dm "* LEFT  O"
	db 13, 8, 7
	dm "* RIGHT P"
	db 13, 9, 7
	dm "* PAUSE W"
	db 13, 10, 7
	dm "* RESET R"
	db 13, 16, 3
	dm "SEEK YOUR FORTUNE"
	db 13, 12
MESSAGE4:
	db 3, 3
	dm "JOYSTICK CONTROLS"
	db 13, 5, 3
        dm "* UP    JOY_UP"
	db 13, 6, 3
	dm "* DOWN  JOY_DN"
	db 13, 7, 3
	dm "* LEFT  JOY_LE"
	db 13, 8, 3
	dm "* RIGHT JOY_RI"
	db 13, 9, 3
	dm "* PAUSE      W"
	db 13, 10, 3
	dm "* RESET      R"
	db 13, 16, 3
	dm "SEEK YOUR FORTUNE"
	db 13, 12
END:

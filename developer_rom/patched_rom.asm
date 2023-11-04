	;; Patched version of Minstrel 4th ROM including various
	;; development tools in the additional ROM space in 2800h--3BFFh

	
	;; LINK is used to keep track of address of name-length
	;; field in most recently defined word. Needed to ensure
	;; dictionary (a linked list) is defined correctly.
LINK = #1D58	; Addr of name-length field of UFLOAT

  
	;; Dictionary macros
	include "forth_word_macro.asm"

	;; Original ROM section
	device zxspectrum48 // Only for using SAVEBIN
	org 0x0000
	incbin "ace.rom" ; "ace.rom" = 3.25 MHz / "minstrel.rom" = 6.5MHz
	
	;; Additional ROM section
	;; 
	;; Uncomment lines corresponding to functionality you wish to
	;; include.
	org #2800		; Start of additional ROM

	include "case.asm" 	      	; CASE construct (Optional)
	include "devtools.asm" 		; Additional tools for
					; developers
	
	DISPLAY "Bytes left: ", #3BFF - $
	

;;;;;;;;;;;;;;;;;;;;;;; Dictionary hack place
	;; Update link field address used to create word "FORTH", to
	;; point to name-length field in last word of extended
	;; dictionary.

	org #1ffd
	dw LINK
	savebin "patched.rom", 0, 16384

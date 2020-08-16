;
; This black magic used for automatic generation linked list for forth's words
;
; Usage:
; w_mySomeCode:
;       FORTH_WORD "SOMECODE"
;       ld de, #C0DE
;       rst #10
;       jp (iy)
;
; After compilation your rom will have new your own word in dict.

    MACRO SET_VAR var, addr
        DEFINE _SET_VAR_NAME var
        LUA ALLPASS
            sj.insert_label(sj.get_define("_SET_VAR_NAME"), _c("addr"), false, true)
        ENDLUA
        UNDEFINE _SET_VAR_NAME
    ENDM

    MACRO FORTH_WORD wordname
.name
        ABYTEC 0 wordname
.name_end
	dw .word_end - $
        dw LINK
        SET_VAR LINK, $
        db .name_end - .name
        dw $ + 2
    ENDM

    MACRO FORTH_WORD_ADDR wordname, addr
.name
        ABYTEC 0 wordname
.name_end
	dw .word_end - $
        dw LINK
        SET_VAR LINK, $
        db .name_end - .name
        dw addr
    ENDM

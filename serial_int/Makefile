ASM = sjasmplus
AFLAGS = --sym=xmodem.sym

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = xmodem.asm
HEADERS = 

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm forth-word-macro.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) $<

clean:
	$(ERASE) $(OBJS)

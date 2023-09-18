ASM = z80asm
AFLAGS = -L

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = z80_dis_ace.asm z80_dis_spectrum.asm z80_dis_zx80.asm
HEADERS = z80_disassembler.asm

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) -o $@ $< > $*.sym 2>&1 

clean:
	$(ERASE) *.bin *.sym

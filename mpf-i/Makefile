ASM = z80asm
AFLAGS = -L

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = mpf1_monitor.asm
HEADERS = 

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm Makefile $(HEADERS) prt-ib.asm
	$(ASM) $(AFLAGS) -o $@ $< > $*.sym 2>&1 

clean:
	$(ERASE) *.bin *.sym

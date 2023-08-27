ASM = z80asm
AFLAGS = -L > mpf1_monitor.sym 2>&1

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = mpf1_monitor.asm
HEADERS = 

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) $<

clean:
	$(ERASE) a.bin

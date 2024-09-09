ASM = z80asm
AFLAGS = -L

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = mpf1_monitor.asm epb-mpf_1bp_rom.asm
HEADERS = 

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

mpf1_monitor.bin:	mpf1_monitor.asm prt-ib.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) -o $@ $< > mpf1_monitor.sym 2>&1 
	
epb-mpf_1bp_rom.bin:	epb-mpf_1bp_rom.asm Makefile $(HEADERS) mpf1_monitor.bin
	$(ASM) $(AFLAGS) -o $@ $< > epb_mpf1pb_rom.sym 2>&1
	
clean:
	$(ERASE) *.bin *.sym

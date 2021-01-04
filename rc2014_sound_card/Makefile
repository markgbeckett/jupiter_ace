ASM = sjasmplus
AFLAGS = --sym=play.sym --raw=play.bin # -DZXSPECTRUM

ifeq ($(OS),Windows_NT)
	ERASE = erase
	else
	ERASE = rm
endif

SRC = play.asm
HEADERS = 

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) $<

clean:
	$(ERASE) $(OBJS)

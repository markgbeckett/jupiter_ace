ASM = sjasmplus

# Uncomment corresponding flags for your system
AFLAGS = --sym=play.sym --raw=play.bin -DAY_REG_PORT=0xD8 -DAY_DAT_PORT=0xD0 # RC2014
# AFLAGS = --sym=play.sym --raw=play.bin -DAY_REG_PORT=0xFFFD -DAY_DAT_PORT=0xBFFD # ZX Spectrum+ 128k
# AFLAGS = --sym=play.sym --raw=play.bin -DBOLDFIELD -DAY_REG_PORT=0xFD -DAY_DAT_PORT=0xFF # Boldfield Soundbox

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

ASM = sjasmplus

# Uncomment corresponding flags for your system
# AFLAGS = --sym=play.sym --raw=play.bin -DAY_REG_PORT=0xD8 -DAY_READ_PORT=0xD0 -DAY_WRITE_PORT=0xD0 # RC2014 Rev 5
# AFLAGS = --sym=play.sym --raw=play.bin -DAY_REG_PORT=0xA0 -DAY_READ_PORT=0xA2 -DAY_WRITE_PORT=0xA1 # RC2014 Rev 6
# AFLAGS = --sym=play.sym --raw=play.bin -DAY_REG_PORT=0xFFFD -DAY_READ_PORT=0xFFFD -DAY_WRITE_PORT=0xBFFD # ZX Spectrum+ 128k
AFLAGS = --sym=play.sym --raw=play.bin -DBOLDFIELD -DAY_REG_PORT=0xFD -DAY_READ_PORT=0xFF -DAY_WRITE_PORT=0xFF # Boldfield Soundbox
#-DSWAPCHANS # Swap channels so Channel 1 is centered for stereo output

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

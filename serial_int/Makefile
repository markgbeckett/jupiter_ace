ASM = \opt\bin\z80asm
AFLAGS = -L

SRC = serial_rx_word.asm serial_tx_word.asm tee_kernel.asm
HEADERS = serial_comm.asm

OBJS = $(SRC:.asm=.bin)

all: $(OBJS)

%.bin:	%.asm Makefile $(HEADERS)
	$(ASM) $(AFLAGS) -o $@ $<

clean:
	erase *.bin

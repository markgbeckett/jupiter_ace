ASM = sjasmplus
AFLAGS = --sym=patched_rom.sym

ifeq ($(OS),Windows_NT)
	ERASE = erase
	MERGECMD = copy /b ace.rom+blank_8k.bin+patched.rom+..\mpf-i\mpf-1.rom rom_bank.rom 
	else
	ERASE = rm
	MERGECMD = cat ace.rom blank_8k.bin patched.rom ../mpf-i/mpf-1.rom >rom_bank.rom
endif

SRC = *.asm
# SRC = *.asm ..\..\Minstrel4th-rom-patch\rom-modules\common-uart-ops.asm ..\..\Minstrel4th-rom-patch\rom-modules\uart-dos.asm ..\..\Minstrel4th-rom-patch\rom-modules\uart-xmodem.asm
OBJS = patched.rom

all: toflash.rom

toflash.rom: patched.rom
		$(MERGECMD)

$(OBJS): $(SRC) ace.rom Makefile
		$(ASM) $(AFLAGS) patched_rom.asm

clean:
		$(ERASE) $(OBJS) toflash.rom

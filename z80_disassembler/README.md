# Introduction

A Z80 disassembler is a useful tool to have to hand, both for developing and debugging machine-code programs and for interrogating the computer's ROM routines.

This project takes a compact Z80 disassembler, developed by Toni Baker and described in her book [Machine Code Programming for Your ZX Spectrum](https://ia600604.us.archive.org/view_archive.php?archive=/1/items/World_of_Spectrum_June_2017_Mirror/World%20of%20Spectrum%20June%202017%20Mirror.zip&file=World%20of%20Spectrum%20June%202017%20Mirror/sinclair/books/m/MasteringMachineCodeOnYourZXSpectrum.pdf), and generalises it so it can be used on a range of Z80-based microcomputers (specifically, targetting the Minstrel 4th and Minstrel 2).

Toni's Z80 disassembler is designed to be as compact as possible, occupying around 1.25 kB, meaning it can easily coexist with other development tools and any program being developed. further, for the Minstrel 4th, it can be added to the Ace Forth ROM, in the extra space at 0x2800--03BFF (see (Minstrel Goes Forth)[http://blog.tynemouthsoftware.co.uk/2020/05/minstrel-goes-forth.html]).


## Usage

For this project, I have provided source code: you would typically build your own disassembler package for your specific system and requirements. I have also included three example 'ports' of the disassembler -- for the Jupiter Ace, the ZX80 (4K ROM) and the ZX Spectrum -- which along with these notes should help you get started.

The source code can be assembled with any standard Z80 cross-assembler (I use [the non-GNU z80asm](https://savannah.nongnu.org/projects/z80asm/)). I have included a [Makefile](Makefile) to help with this.

To make the disassembler more portable, I have partitioned the program into two parts:

- [z80_disassembler.asm](z80_disassembler.asm), which contains the core of Toni's Z80 disassembler implementation in a form that can run on almost any Z80 platform with sufficient resouces (most notably, memory). There should be no reason to change this file, unless you wish to change or extend the disassembler's functionality.
- a platform-specific wrapper (e.g., see [z80_dis_ace.asm](z80_dis_ace.asm)) that contains implementations of initialisation and screen handling tailored to the requirements of a specific platform and usage. This is the file you will probably need to create for your system and requirements.

Probably the easiest way to create a new port is to start from one of the existing platform-specific wrappers: whichever one seems most similar to your target system and use.

The platform-specific wrapper needs to include the following elements:
- A character-code mapping file that maps, at least, the alphanumeric characters (A-Z (capitals) and 0-9), space, carriage return, parentheses, comma, plus symbol, an apostrophe, and a null character (Space is fine) to the generic labels, as can be found in [jupiter_chars.asm](../utilities/jupiter_chars.asm) (note: [jupiter_chars.asm](../utilities/jupiter_chars.asm) is a generic character-code mapping file, which defines many more character codes than are needed for the disassembler). In fact, for any system that uses ASCII-like character coding, the Ace definition file is likely to be good enough (possibly with some tweaks).
- A buffer of at least 32 bytes, in RAM, in which the current instruction can be disassembled, pointed to by the label `DISS`. For example, on the Jupiter Ace, I set `DISS` to point to the beginning of the PAD at address 0x2701.
- A label named `ADDRESS` that points to a word (two bytes) in RAM that can be used by the disassembler to store an address. For the Jupiter Ace, I have specified the last two bytes of PAD, at address 0x27FE.
- Five `equ` instructions defining character codes that are mapped to `EXT_ADDR`, `IND_ADDR`, `IMM_ADDR`, `IMM_EXT_ADDR`, and `REL_ADDR` and that the disassembler can use to note special decoding. You should choose codes that do not coincide with the printable letters, numbers, and symbols listed in the requirements for the character-code mapping file above. On most systems, codes 0, 1, 2, 3, and 4 are suitable. The only exception I have found is the ZX80 which maps printable characters onto these codes.
- A callable routine, labelled `INIT`, which does any system-specific initialisation you need. No arguments are passed to this routine and there are no requirements from the disassembler to preserve registers.
- A callable routine, labelled `PRINT_A`, which will insert the character code in the A register ath the current print position and advance the print position by one character. The routine must preserve all current and alternate registers except for A and F.
- A callable routine, labelled `TAB`, which will set the print position (system-specific) to column 14 on the current line. On entry, you may assume that the print position is to the left of column 14 on the current line.
- A callable routine, labelled `NEWLINE`, which will advance the current print position to the beginning of the next line on the screen (or, possibly, scroll the screen up by one line and set the print position to the start of the current line. The current line is assumed to be blank on exit from this routine.


## Further reading

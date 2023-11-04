# Introduction

The Minstrel 4th (and 4D) actually has an additional ROM segment over what is available on the Jupiter Ace. The additional ROM sits in the memory map between 0x2800 and 0x3BFF (inclusive). On the Jupiter Ace, addresses 0x2800--0x2FFF are mapped to the character-set RAM. However, they are write-only addresses (from the Z80 side): trying to read them will produce meaningless answers. Further, addresses 0x3000---0x3BFF map to three copies of the range 0x3C00--0x3FFF and so are essentially redundant. The Minstrel 4th architecture takes advantage of this and allows additonal ROM routines to be placed at 0x2800--0x3BFF. Effectively, Z80 write operations go to the display and character memory and Z80 read operations source from the active (16kB) ROM bank.

Alexander Sharihin (https://github.com/nihirash) formulated a clean and simple way to add words to the standard (that is, ROM-based) Ace Forth dictionary. I have used this approach to extend the Ace FORTH Rom with some much-needed developer tools, including the following additional words:

- `.S ( -- )` prints out a copy of the data stack (without affecting it). `.S` is commonplace word on more modern FORTH systems. This version is based on the listing on page 143 of the Jupiter Ace manual.

- `DIS ( addr -- )` runs the disassembler (see [../z80_disassembler/README.md](../z80_disassembler/README.md)), disassembling from the address on the top of the stack.

- `DUMP ( addr -- )` prints a hex dump of memory (see [../z80_disassembler/README.md](../z80_disassembler/README.md)), starting from the address on the top of the stack.

- `CODE <word>` allows the user to create a word using machine code (see page 147 of the Jupiter Ace manual).

- `HEX ( -- )` switches the interpreter to base 16 (hexadecimal). Effectively, this runs `DECIMAL 16 BASE C!`.

- `CASE`, `OF`, `ENDOF`, `OTHERWISE`, and `ENDCASE` provides a case statement for Ace FORTH (see [../case/case.fs](../case/case.fs)).

## Usage

Theses additonal words are available from an updated (16kB) ROM image [patched.rom](patched.rom), which you can write to a suitable EPROM following the instructions in the Minstrel 4th manual.


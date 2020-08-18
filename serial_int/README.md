# XMODEM support for Minstrel 4th with an Tynemouth Software 6850 serial-port interface

A set of Forth words that can be used to transfer data between the Minstrel 4th and a host PC using the XMODEM protocol, with a typical badnwidth of 4--5 Kilobytes/ second.

# Usage

All functions can be accessed directly from FORTH. Included words are:

 * SRESET - reset serial interface (required before any other commands)
 * XBGET - download block of data to Minstrel 4th using XMODEM protocol. Syntax is `<address> XBGET`. On exit, TOS contains 0, if transfer succeeded, and -1, otherwise.
 * XBPUT - upload block of memory from Minstrel 4th using XMODEM protocol. Syntax is `<address> <size> XBPUT`. On exit, TOS contains 0, if transfer succeeded and -1 otherwise.
 * RX - receive a byte via serial interface (on return, byte received is on TOS (or -1, if no byte available).
 * TX - transmit a byte via serial interface (on return, TOS indicates outcome: 0 means success, -1 means failure).
 * XMODEM - a (CREATE'ed) array used to hold library code with other words. This word is not intended to be used directly from FORTH.

The progress of XBPUT and XPBGET is logged to the screen, unless you surpress it using INVIS. 

For XBPUT, a size of 0 will be interpretted as 64kb (that is, as size = 0x10000). This can be used to create a snapshot of the entire Minstrel memory, using `0 0 XBPUT`.

## Obtaining

Source code and precompiled binaries are available on GitHub [https://github.com/markgbeckett/jupiter_ace/tree/master/serial_int]. The easiest way to obtain the code is to download the pre-assembled tape image (xmodem.tap or xmodem.wav), ready to load into your Minstrel. The words contain non-relocatable machine code, so most be loaded into memory first, before any other words are defined or created.

If you want to build your own version of the tools, the source code and a Makefile (named Makefile.xmodem) are also available from GitHub. You will need the SJASMPLUS cross-assembler to assemble the source.

Once assembled, you will have a binary image called xmodem.bin, which you need to load into an emulator (such as EightyOne) using the following slightly convoluted procedure:

 * Reboot your emulator and type:
 ** `16 BASE C! ( MUCH EASIER TO WORK IN HEXIDECIMAL )`
 ** `3F83 3C3B ! ( RELOCATE STACK TO MAKE SPACE FOR NEW WORDS )`
 ** `3F77 3C37 ! ( WILL BE THE END OF THE DICTIONARY, ONCE LOADED )`
 ** Load the xmodem.bin file into memory at location 0x3C51 (immediately after the FORTH word)
 ** `3EC0 3C39 ! ( UPDATE FORTH VOCAB )`
 ** `3EC0 3C39 ! ( UPDATE DICT SYSTEM VARIABLE )`
 ** `0000 3EC0 ! ( RESET LENGTH FIELD IN NEWEST WORD )`

Having done this, you should VLIST to confirm the new words have appeared correctly in the dictionary, and then save the words to a tape archive, ready to load into a real Minstrel.

The values and addresses above are based on the version of the code, at the time of writing. If you change the source, these values will be likely to need changing. At the end of the assemble process, the correct values will be printed on-screen.


### Acknowledgements

XMODEM routines are inspired by original CP/M code by Ward Christensen, available at:

http://www.vintagecomputer.net/fjkraan/comp/mirror/z80cpu.eu/archive/rlee/L/LOOSECPM/224/MODEM.ASM

--and by proof of concept in FORTH from John Kennedy (@JohnKennedyMSFT).

FORTH-word macro was created by Alexander Sharihin (@nihirash).


### Notes

Current version of send routine has some deviations from the standard in that it will pad the transfer size to the next 128-byte boundary, without putting in padding. For example, if you run the command:

`0000 10 XBPUT`

--the routine will transfer the first 128 bytes of memory, rather than the first 16 plus 112 bytes of padding.

Received data is written directly to memory. If receive routine fails mid-way through transfer, there will be a partially complete copy of the transfer in memory. 

The user is responsible for checking transfers will not overwrite existing data. For example, if you try to load a random block of data into the existing dictionary, you will almost certainly crash the Minstrel.


### Known issues

- Screen logging for receive operation will report receiving one more packet than you might expect. The EOT at the end of the transfer is counted as a packet, which might confuse the user.

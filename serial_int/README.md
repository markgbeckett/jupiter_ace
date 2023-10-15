# XMODEM support for Minstrel 4th with a Tynemouth Software 6850 serial-port interface

A set of Forth words that help you to use the Tynemouth Software 6850 serial-port interface with your Minstrel 4th. The most significant functionality is support for transferring data between the Minstrel 4th and a host PC using the XMODEM protocol, with a typical bandwidth of 4--5 Kilobytes/ second. There are also some basic functionalities that help with code development.

## Usage

All functions can be accessed directly from FORTH. Included words are:

- `SRESET ( -- )` - reset serial interface (required before any other commands)
- `XBGET ( nnnn -- nn )` - download block of data to Minstrel 4th using XMODEM protocol. Syntax is `<address> XBGET`, where <address> is the starting address in memory to write data to. On exit, TOS contains 0, if transfer succeeded, and -1 otherwise. Progress is logged to the screen, unless you surpress it using INVIS. 
- `XBPUT ( nnnn nnnn -- nn )` - upload block of memory from Minstrel 4th using XMODEM protocol. Syntax is `<address> <size> XBPUT`, where <address> is the start of the block and <size> is the length. On exit, TOS contains 0, if transfer succeeded, and -1 otherwise. Progress is logged to the screen, unless you surpress it using INVIS. 
- `RX ( -- nn )` - receive a byte via serial interface. On exit, the byte received will be on Top Of Stack (or -1, if no byte available).
- `TX ( nn -- nn )` - transmit a byte via serial interface. On exit, TOS indicates outcome: 0 means success, -1 means failure.
- `TEE ( -- )` - echo screen output to serial interface. Useful for capturing FORTH word listings or the transcript of an adventure game, for example.
- `UNTEE ( -- )` - disable echoing of screen output to the serial interface.
- `XMODEM` - a (CREATE'ed) array used to hold library code with other words. This word is not intended to be used directly from FORTH. If you use it, the address of the start of the code library code will be added to TOS.

For XBPUT, a size of 0 will be interpretted as 64kb (that is, as size = 0x10000). This can be used to create a snapshot of the entire Minstrel memory, using `0 0 XBPUT`.

You will need to run some kind of terminal program on your PC, such as TeraTerm, and configure the program to connect to the correct serial port at 115,200 baud with hardware flow control. The XMODEM protocol uses a (one-byte) checksum rather than CRC.

XBPUT and XBGET provide a crude way to save the contents of a user's dictionary. You can capture a snapshot of the words in RAM plus relevant system variables using the command `3C31 HERE 3C31 - XBPUT` and restore the words into the Minstrel 4th using `3C31 XBGET`. The process relies on having this serial toolkit loaded into memory at the beginning of the user dictionary and only works with standard dictionary words. If in doubt, you should also save your work to tape, in the usual way, as a backup.

## Obtaining

Source code and precompiled binaries are available on GitHub [https://github.com/markgbeckett/jupiter_ace/tree/master/serial_int]. The easiest way to obtain the code is to download the pre-assembled tape image (xmodem.tap or xmodem.wav), ready to load into your Minstrel 4th. The toolkit contains non-relocatable machine code, so most be loaded into memory first, before any other words are defined or created.

If you want to build your own version of the tools, the source code and a Makefile are also available from GitHub. You will need the SJASMPLUS cross-assembler [https://github.com/z00m128/sjasmplus] to assemble the source.

Once assembled, you will have a binary image called xmodem.bin, which you need to load into an emulator (such as EightyOne) using the following slightly convoluted procedure:

- Reboot your emulator and type:

`16 BASE C! ( MUCH EASIER TO WORK IN HEXIDECIMAL )`

`3FBE 3C3B ! ( RELOCATE STACK TO MAKE SPACE FOR NEW WORDS )`

`3FB2 3C37 ! ( WILL BE THE END OF THE DICTIONARY, ONCE LOADED )`

- Load the xmodem.bin file into memory at location 0x3C51 (immediately after the FORTH word)

- Then, type

`3EFF 3C39 ! ( UPDATE FORTH VOCAB )`

`3EFB 3C39 ! ( UPDATE DICT SYSTEM VARIABLE )`

`0000 3EFB ! ( RESET LENGTH FIELD IN NEWEST WORD )`

Having done this, you should VLIST to confirm the new words have appeared correctly in the dictionary, and then save the words to a tape archive, ready to load into a real Minstrel.

The values and addresses above are based on the version of the code, at the time of writing. If you change the source, these values will be likely to need changing. At the end of the assemble process, the correct values will be printed on-screen.


### Acknowledgements

XMODEM routines are inspired by original CP/M code by Ward Christensen, available at:

http://www.vintagecomputer.net/fjkraan/comp/mirror/z80cpu.eu/archive/rlee/L/LOOSECPM/224/MODEM.ASM

--and by proof of concept in FORTH from John Kennedy (@JohnKennedyMSFT) [https://github.com/GrantMeStrength/Forth].

FORTH-word macro was created by Alexander Sharihin (@nihirash).


### Notes

You must disable echoing command line to serial port (using `UNTEE`) before using XMODEM commands.

The current version of XBPUT has some deviations from the XMODEM standard in that it will pad the transfer size to the next 128-byte boundary, without putting in padding. For example, if you run the command:

`0000 10 XBPUT`

--the routine will transfer the first 128 bytes of memory, rather than the first 16 plus 112 bytes of padding.

Received data is written directly to memory. If receive routine fails mid-way through transfer, there will be a partially complete copy of the transfer in memory. 

The user is responsible for checking transfers will not overwrite existing data. For example, if you try to load a random block of data into the existing dictionary, you will almost certainly crash the Minstrel.


### Known issues

- Screen logging for receive operation will report receiving one more packet than you might expect. The EOT at the end of the transfer is counted as a packet, which might confuse the user.

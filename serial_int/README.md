# Client Code for Minstrel 4th Serial Interface

A set of Forth words that can be used to access a serial interface from the Minstrel 4th.

Individual words are coded in Z80 assembly language. Compiled code needs to be inserted into a pre-allocated parameter field of a corresponding entry in the Forth dictionary.

## XMODEM

Implementation of XMODEM protocol for Minstrel 4th, using the Tynemouth Software 6850 serial port for RC2014. Supported commands are:

 * SRESET - reset serial interface (required before any other commands)
 * XBGET - download block of data to device using XMODEM protocol. Syntax is `<address> XBGET`. On exit, TOS contains 0, if transfer succeeded and -1 otherwise.
 * UXPUT - upload block of memory to server using XMODEM protocol. Syntax is `<address> <size> XBPUT`. On exit, TOS contains 0, if transfer succeeded and -1 otherwise.
 * RX - receive a byte from serial interface.
 * TX - transmit a byte via serial interface.

For send and receive, on exit, stack contains value to indicate outcome: '0' for success; '-1' for failure (timeout). XMODEM transfers will also display progress on-screen, unless INVIS is enabled to surpress screen output.

### Acknowledgements

XMODEM routines are inspired by original CP/M code by Ward Christensen, available at:

http://www.vintagecomputer.net/fjkraan/comp/mirror/z80cpu.eu/archive/rlee/L/LOOSECPM/224/MODEM.ASM

--and by proof of concept in FORTH from John Kennedy (@JohnKennedyMSFT).

FORTH-word macro by Alexander Sharihin (@nihirash).


### Notes

Current version of send routine has some deviations from the standard in that it will pad the transfer size to the next 128-byte boundary, without putting in padding. For example, if you run the command:

`0000 10 XBPUT`

--the routine will transfer the first 128 bytes of memory, rather than the first 16 plus 112 bytes of padding.

Received data is written directly to memory. If receive routine fails mid-way through transfer, there will be a partially complete copy of the transfer in memory. 

### Known issues

- Screen logging for receive operation will report receiving one more packet than you might expect. The EOT at the end of the transfer is counted as a packet, which might confuse the user.

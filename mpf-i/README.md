# Introduction

The Micro-Professor (MPF-1) is a single-board, Z80-based computer produced by Multitech (who are now known as Acer) and first released in 1981. The MPF-1 was intended to teach people about microprocessors, machine-code programming, and electronics.

The computer came housed in a book-like case with a seven-segment LED display and a 32-key keypad.

The MPF-1 shipped with 2 kilobytes of RAM and a built-in monitor program for entering, running, and debugging machine-code programs. Multitech also provided a range of expansion options including a BASIC ROM, memory expansion, EPROM programmer, and a line printer. 

For more information on the Micro Professor, see [https://electrickery.nl/comp/mpf1](https://electrickery.nl/comp/mpf1).

MPF-1s do occasionally appear on auction sites, but tend to be very expensive. Given this, I thought it would be good if people could experience some of the fun of using an MPF-1 without the expense. To this end, I am creating an MPF-1-like environment on the Minstrel 4th (or Minstrel 4D), starting with the MPF-1 monitor.

For the Monitor, I eventually plan to create a ROM image for the Minstrel 4th, to give the most authentic experience. However, the initial version is RAM-based and some functionality is missing (specifically, that functionality that relies on the Z80's page-zero restart routines). Depending on how successful this is, I may also look to tackle some of the expansion options -- e.g., using the RC2014 connectivity of the Minstrel 4th.


## Loading the MPF-1 Monitor on your Minstrel 4th

Power on your Minstrel 4th and load the mmonitor from 'mpf.tap' (or 'mpf.wav') using the following command (case of filename is important):

```
  32768 0 BLOAD MPF1
```

Then, start the monitor by typing:

```
  INVIS CLS 32768 CALL
```

All going well, you should be greeted with the MPF-1 startup message "UPF- -1"

## Using the MPF-1

The real MPF-1 has just 36 keys and a seven-character display. Because of this, the Minstrel 4th output is limited to the top line of the screen and only a subset of the keys are used, as follows:

- 0, 1, ..., 9, A, ..., F -- represent hexadecimal digits (or register pairs, when inspecting the Z80 registers)
- P - `PC`
- Y - `ADDR`
- U - `DATA`
- I - `REG`
- Shift-K - `+`
- Shift-J -- `-`
- G -- `GO`
- J -- `SBR`
- K -- `CBR`
- M -- `MOVE`
- N -- `RELA`
- Z -- `INS`
- X -- `DEL`
- R -- `TAPE RD`
- T -- `TAPE WR`
- Reset -- `RESET` (not implemented)

The easiest way to get familiar with the MPF-1 is to read the [user manual](https://electrickery.hosting.philpem.me.uk/comp/mpf1/doc/MPF-1_usersManual.pdf), but bearing in mind the following changes for the Minstrel 4D environment:

- User memory starts at 0x9000, not 0x1800. E.g., pressing `PC` when you first start the monitor will report the user's PC as being 0x9000.

- Where the Micro-Professor uses fullstops to indicate status on the display, the Minstrel 4th port uses inverse video.

- The following keys are not implemented: `STEP`, `MONI`, `INTR`, `USER KEY`. These require additional hardware to implement.

- Most examples in the user manual end with a `HALT` command. However, this will cause the Minstrel 4th to hang. Instead, you should use `CALL 0x8066` (that is, CD, 66, 80) to return to the Monitor (simulating the use of `MONI` key).

- The Monitor subroutines noted in Section 5 of the User Manual mostly work, though their entry points are all offset by 0x8000 -- e.g., the entry point for SCAN1 is 0x8624 (not 0x0624, as noted in the manual).


## Implementation

The port is based on a commented disassembly by fjkraan@electrickery.nl, which is available from [https://electrickery.nl/comp/mpf1](https://electrickery.nl/comp/mpf1). I have made the following changes to the source code so that the Monitor will run in the upper memory of the Minstrel 4th:

- I set all of the port address for to 8255 chip to 0xFF, as this version does not use that chip and I wanted to avoid interfering with peripherals.

- I quadrupled the frequencies of the parameters F1KHZ and F2KHZ to accommodate both doubling of the clock speed and the fact that the Minstrel 4th version will oscillate the speaker twice as often as the MPF-1 did.

- Set origin address to 0x8000, so code is built to run in upper memory (plus removed other origin directives later in the source, replacing them by 'ds' commands to ensure same code layout in memory.

- Set user-RAM to start at 0x9000.

- Update any references to user RAM (e.g., RESET1 routine and RST38) to point to 0x90?? rather than 0x18??.

- Changed the scroll rate for power-on message (in INI1).

- Replace speaker oscilator code with Minstrel 4th equivalent (issuing IN and OUT to port 0xFE).

- Updated the code in SETPT and LOCPT to set bit 7 (inverted characters) instead of printing decimal point.

- Reimplemented SCAN1 to use Minstrel 4th display and keyboard.


## Further reading

- (Tynemouth Software's Blog article about repairing a Micro-Professor 1)[http://blog.tynemouthsoftware.co.uk/2023/05/multitech-micro-professor-mpf-i-repair.html]. 

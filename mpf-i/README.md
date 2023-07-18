# Introduction

The Micro-Professor (MPF-1) is a single-board, Z80-based computer produced by Multitech (who are now known as Acer) and first released in 1981. The MPF-1 was intended to teach people about microprocessors, machine-code programming, and electronics.

The computer came housed in a book-like case with a seven-segment LED display and a 32-key keypad.

The MPF-1 shipped with 2 kilobytes of RAM and a built-in monitor program for entering, running, and debugging machine-code programs. Multitech also provided a range of expansion options including a BASIC interpretter ROM, memory expansion, EPROM programmer, and a thermal printer. 

For more information on the Micro Professor, see [https://electrickery.nl/comp/mpf1](https://electrickery.nl/comp/mpf1).

MPF-1s do occasionally appear on auction sites, but tend to be very expensive. Given this, I thought it would be good if people could experience some of the fun of using an MPF-1 without the expense. To this end, I am creating an MPF-1-like environment on the Minstrel 4th (or Minstrel 4D), starting with the MPF-1 monitor.

The Monitor can be run in two modes:

- Ideally, if you have an EPROM programmer and a suitable EPROM, you can write a new ROM image for your Minstrel 4th. This will give a more realistic (though not perfect) experience.

- Alternatively, you can load the monitor into RAM and run it from there. This works reasonably well though you need to be careful to avoid using zero-page restart instructions (such as `rst 0x38`) replacing them by suitable calls (something like, `call 0x4038`).

Even the ROM version is missing some functionality, related to debugging and single-stepping. For this, the MPF-1 uses the non-maskable interrupt line and a timer provided by a [74LS90](https://www.ti.com/lit/ds/symlink/sn54ls90.pdf) integrated circuit. To generate an NMI, on the Minstrel 4th, would require an expansion device (such as an RC2014 card).

Accept for this, the port works well: the various Monitor subroutines, listed in the [User Manual](https://electrickery.hosting.philpem.me.uk/comp/mpf1/doc/MPF-1_usersManual.pdf), are available and, based on my testing so far, the various projects and examples (aslo in the usual manual) seem to work as expected.


## Loading the MPF-1 Monitor on your Minstrel 4th

The procedure for accessing the MPF-1 Monitor depends on which version of the monitor you plan to use.

### ROM image

The MPF-1 ROM image 'mpf_1.rom' can be burned onto a suitable EPROM and installed into the Minstrel 4th or Minstrel 4D. Jumpers/ switches on the main board allow you to select between multiple ROMs, so you could set up the standard AceForth ROM in the first ROM bank and the MPF-1 Monitor in the second, for example (see Minstrel 4th User Guide for more information).

Once installed, check the jumpers/ switches are configured to select the correct ROM bank and power on. The MPF-1 should boot as shown in the screenshot.

The ROM image 'mpf-1.rom' has been padded out to 16 kilobytes to fill the ROM bank, even though the Minstrel 4th only addresses the first 8 kilobytes. This means the ROM will probably not work on an emulator (which will expect an 8-kilobyte ROM). To this end, I have also provided 'mpf-1_8k.rom', which is confirmed to work on the EightyOne emulator, at least.


### RAM-based

Power on your Minstrel 4th and load the mmonitor from 'mpf.tap' (or 'mpf.wav') using the following command (case of filename is important):

```
  16384 0 BLOAD MPF1
```

Then, start the monitor by typing:

```
  16384 CALL
```

All going well, you should be greeted with the MPF-1 startup message "UPF--1".


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
- J -- `SBR` (not very functional)
- K -- `CBR` (not very functional)
- M -- `MOVE`
- N -- `RELA`
- Z -- `INS`
- X -- `DEL`
- R -- `TAPE RD`
- T -- `TAPE WR`
- Reset -- `RESET` (not implemented)

The key mapping is displayed on-screen whenever you are using the MPF-1 Monitor, so no need to memorise the list above.

The easiest way to get familiar with the MPF-1 is to read the [user manual](https://electrickery.hosting.philpem.me.uk/comp/mpf1/doc/MPF-1_usersManual.pdf), but bearing in mind the following changes for the Minstrel 4D environment:

- User memory starts at 0x8000, not 0x1800. E.g., pressing `PC` when you first start the monitor will report the user's PC as being 0x8000.

- Where the Micro-Professor uses fullstops to indicate status on the display, the Minstrel 4th port uses inverse video.

- The following keys are not implemented: `STEP`, `MONI`, `INTR`, `USER KEY`. These require additional hardware to implement.

- While you can set and clear breakpoints, this is ignored (again, breakpoints require extra hardware to implement).

- Most examples in the user manual end with a `HALT` command. However, this will cause the Minstrel 4th to hang. Instead, you should use `call 0x66` (ROM) or `call 0x4066` (RAM) to return to the Monitor (this replicates the behaviour of pressing the `MONI` key).

- The Monitor subroutines noted in Section 5 of the User Manual mostly work, though for the RAM version of the monitor, entry points are all offset by 0x4000 -- e.g., the entry point for SCAN1 is 0x4624 (not 0x0624, as noted in the manual).

## Memory Map

The Minstrel 4th version of the Monitor has a simplified memory map compared to the MPF-1. User RAM either starts at 0x4000 (ROM version) or 0x8000 (RAM version). The system variables are stored from 0x3C00 (ROM version) or 0x7C00 (RAM version), the system stack grows down from the start of user memory and the user stack (by default) grows down from the start of user memory-0x80 (either 0x3F80 or 0x7F80).


## Implementation

The port is based on a commented disassembly by fjkraan@electrickery.nl, which is available from [https://electrickery.nl/comp/mpf1](https://electrickery.nl/comp/mpf1). I have made the following changes to the source code so that the Monitor will run in the upper memory of the Minstrel 4th:

- Set all of the port address for to 8255 chip to 0xFF, as this version does not use that chip and I wanted to avoid interfering with peripherals.

- Quadrupled the frequencies of the parameters F1KHZ and F2KHZ to accommodate both doubling of the clock speed and the fact that the Minstrel 4th version will oscillate the speaker twice as often as the MPF-1 did.

- For the RAM version, the origin address is set to 0x8000, so code is built to run in upper memory (plus removed other origin directives later in the source, replacing them by 'ds' commands to ensure same code layout in memory.

- Updated any references to user RAM (e.g., RESET1 routine and RST38) to point to  the correct location in user RAM.

- Changed the scroll rate for power-on message (in INI1).

- Replaced speaker oscilator code with Minstrel 4th equivalent (issuing IN and OUT to port 0xFE).

- Updated the code in SETPT and LOCPT to set bit 7 (inverted characters) instead of printing decimal point.

- Reimplemented SCAN1 to use Minstrel 4th display and keyboard.


## Further reading

- (Tynemouth Software's Blog article about repairing a Micro-Professor 1)[http://blog.tynemouthsoftware.co.uk/2023/05/multitech-micro-professor-mpf-i-repair.html]. 
